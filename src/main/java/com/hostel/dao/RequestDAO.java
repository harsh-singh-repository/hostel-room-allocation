package com.hostel.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.hostel.model.RoomRequest;
import com.hostel.util.DBUtil;

/** Vacate / room-change requests. */
public class RequestDAO {

    private static final String SELECT =
            "SELECT q.*, u.full_name, u.roll_no, "
          + "       (SELECT b.block_name || ' - ' || r.room_no "
          + "          FROM allocations a JOIN rooms r ON r.room_id = a.room_id "
          + "          JOIN hostel_blocks b ON b.block_id = r.block_id "
          + "         WHERE a.student_id = q.student_id AND a.status = 'ACTIVE') current_room "
          + "  FROM room_requests q JOIN users u ON u.user_id = q.student_id ";

    public int raise(int studentId, String type, String newType, String reason) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.raise_request(?, ?, ?, ?, ?)}")) {
            cs.setInt(1, studentId);
            cs.setString(2, type);
            cs.setString(3, newType);
            cs.setString(4, reason);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            return cs.getInt(5);
        }
    }

    public void process(int reqId, boolean approve, String note) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.process_request(?, ?, ?)}")) {
            cs.setInt(1, reqId);
            cs.setString(2, approve ? "Y" : "N");
            cs.setString(3, note);
            cs.execute();
        }
    }

    public List<RoomRequest> listByStudent(int studentId) throws SQLException {
        return query(SELECT + "WHERE q.student_id = ? ORDER BY q.created_at DESC, q.req_id DESC", studentId, null);
    }

    /** @param status null = all */
    public List<RoomRequest> listAll(String status) throws SQLException {
        String sql = SELECT + (status != null ? "WHERE q.status = ? " : "")
                   + "ORDER BY CASE q.status WHEN 'PENDING' THEN 0 ELSE 1 END, q.created_at DESC, q.req_id DESC";
        return query(sql, null, status);
    }

    private List<RoomRequest> query(String sql, Integer studentId, String status) throws SQLException {
        List<RoomRequest> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (studentId != null) {
                ps.setInt(1, studentId);
            } else if (status != null) {
                ps.setString(1, status);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    RoomRequest r = new RoomRequest();
                    r.setReqId(rs.getInt("req_id"));
                    r.setStudentId(rs.getInt("student_id"));
                    r.setStudentName(rs.getString("full_name"));
                    r.setRollNo(rs.getString("roll_no"));
                    r.setCurrentRoom(rs.getString("current_room"));
                    r.setReqType(rs.getString("req_type"));
                    r.setNewType(rs.getString("new_type"));
                    r.setReason(rs.getString("reason"));
                    r.setStatus(rs.getString("status"));
                    r.setAdminNote(rs.getString("admin_note"));
                    r.setCreatedAt(rs.getTimestamp("created_at"));
                    r.setResolvedAt(rs.getTimestamp("resolved_at"));
                    list.add(r);
                }
            }
        }
        return list;
    }
}
