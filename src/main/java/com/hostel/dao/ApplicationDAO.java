package com.hostel.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.hostel.model.Application;
import com.hostel.util.DBUtil;

/** Room applications and the allocation procedures. */
public class ApplicationDAO {

    private static final String SELECT =
            "SELECT a.app_id, a.student_id, u.full_name, u.roll_no, u.gender, u.year_of_study, "
          + "       a.preferred_block, b.block_name, a.preferred_type, a.status, a.remarks, "
          + "       a.applied_on, a.decided_on "
          + "  FROM applications a "
          + "  JOIN users u ON u.user_id = a.student_id "
          + "  LEFT JOIN hostel_blocks b ON b.block_id = a.preferred_block ";

    public int apply(int studentId, Integer blockId, String type) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.apply_room(?, ?, ?, ?)}")) {
            cs.setInt(1, studentId);
            DaoUtil.setInteger(cs, 2, blockId);
            cs.setString(3, type);
            cs.registerOutParameter(4, Types.NUMERIC);
            cs.execute();
            return cs.getInt(4);
        }
    }

    public void cancel(int appId, int studentId) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.cancel_application(?, ?)}")) {
            cs.setInt(1, appId);
            cs.setInt(2, studentId);
            cs.execute();
        }
    }

    /** @return the resulting status: ALLOTTED or WAITLISTED */
    public String allocate(int appId) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.allocate_room(?, ?, ?)}")) {
            cs.setInt(1, appId);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.registerOutParameter(3, Types.VARCHAR);
            cs.execute();
            return cs.getString(3);
        }
    }

    /** @return {allotted, waitlisted} */
    public int[] autoAllocateAll() throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.auto_allocate_all(?, ?)}")) {
            cs.registerOutParameter(1, Types.NUMERIC);
            cs.registerOutParameter(2, Types.NUMERIC);
            cs.execute();
            return new int[] {cs.getInt(1), cs.getInt(2)};
        }
    }

    public void reject(int appId, String remarks) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.reject_application(?, ?)}")) {
            cs.setInt(1, appId);
            cs.setString(2, remarks);
            cs.execute();
        }
    }

    public Application findLatestByStudent(int studentId) throws SQLException {
        String sql = SELECT + "WHERE a.student_id = ? ORDER BY a.applied_on DESC, a.app_id DESC "
                   + "FETCH FIRST 1 ROWS ONLY";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    public List<Application> listByStudent(int studentId) throws SQLException {
        String sql = SELECT + "WHERE a.student_id = ? ORDER BY a.applied_on DESC, a.app_id DESC";
        return query(sql, studentId, null, 0);
    }

    /** @param status null = all statuses */
    public List<Application> listByStatus(String status) throws SQLException {
        String sql = SELECT
                + (status != null ? "WHERE a.status = ? " : "")
                + "ORDER BY CASE a.status WHEN 'PENDING' THEN 0 WHEN 'WAITLISTED' THEN 1 ELSE 2 END, "
                + "a.applied_on DESC, a.app_id DESC";
        return query(sql, null, status, 0);
    }

    public List<Application> listRecentPending(int limit) throws SQLException {
        String sql = SELECT + "WHERE a.status IN ('PENDING','WAITLISTED') "
                   + "ORDER BY a.applied_on, a.app_id FETCH FIRST ? ROWS ONLY";
        return query(sql, null, null, limit);
    }

    /** Waitlist in the same priority order the PL/SQL allocator uses. */
    public List<Application> listWaitlist() throws SQLException {
        String sql = SELECT + "WHERE a.status = 'WAITLISTED' "
                   + "ORDER BY u.year_of_study DESC NULLS LAST, a.applied_on, a.app_id";
        return query(sql, null, null, 0);
    }

    public Map<String, Integer> countByStatus() throws SQLException {
        Map<String, Integer> counts = new LinkedHashMap<>();
        for (String s : new String[] {"PENDING", "WAITLISTED", "ALLOTTED", "REJECTED", "CANCELLED"}) {
            counts.put(s, 0);
        }
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(
                     "SELECT status, COUNT(*) cnt FROM applications GROUP BY status");
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("status"), rs.getInt("cnt"));
            }
        }
        return counts;
    }

    private List<Application> query(String sql, Integer studentId, String status, int limit) throws SQLException {
        List<Application> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            int i = 1;
            if (studentId != null) {
                ps.setInt(i++, studentId);
            }
            if (status != null) {
                ps.setString(i++, status);
            }
            if (limit > 0) {
                ps.setInt(i, limit);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(map(rs));
                }
            }
        }
        return list;
    }

    private static Application map(ResultSet rs) throws SQLException {
        Application a = new Application();
        a.setAppId(rs.getInt("app_id"));
        a.setStudentId(rs.getInt("student_id"));
        a.setStudentName(rs.getString("full_name"));
        a.setRollNo(rs.getString("roll_no"));
        a.setGender(rs.getString("gender"));
        a.setYearOfStudy(DaoUtil.getInteger(rs, "year_of_study"));
        a.setPreferredBlockId(DaoUtil.getInteger(rs, "preferred_block"));
        a.setPreferredBlockName(rs.getString("block_name"));
        a.setPreferredType(rs.getString("preferred_type"));
        a.setStatus(rs.getString("status"));
        a.setRemarks(rs.getString("remarks"));
        a.setAppliedOn(rs.getTimestamp("applied_on"));
        a.setDecidedOn(rs.getTimestamp("decided_on"));
        return a;
    }
}
