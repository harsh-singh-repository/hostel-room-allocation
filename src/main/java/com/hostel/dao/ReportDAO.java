package com.hostel.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

import com.hostel.model.ActivityLog;
import com.hostel.model.DashboardStats;
import com.hostel.util.DBUtil;

/** Read-only queries for the admin dashboard and reports. */
public class ReportDAO {

    public DashboardStats stats() throws SQLException {
        String sql = "SELECT "
                + " (SELECT NVL(SUM(capacity),0) FROM rooms WHERE status = 'ACTIVE') total_beds, "
                + " (SELECT NVL(SUM(occupied),0) FROM rooms) occupied_beds, "
                + " (SELECT COUNT(*) FROM applications WHERE status = 'PENDING') pending_apps, "
                + " (SELECT COUNT(*) FROM applications WHERE status = 'WAITLISTED') waitlisted, "
                + " (SELECT COUNT(*) FROM users WHERE role = 'STUDENT') students, "
                + " (SELECT COUNT(*) FROM room_requests WHERE status = 'PENDING') pending_req, "
                + " (SELECT NVL(SUM(amount),0) FROM fee_payments) collected, "
                + " (SELECT NVL(SUM(hostel_pkg.fee_due(alloc_id)),0) FROM allocations WHERE status = 'ACTIVE') due "
                + "FROM dual";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            DashboardStats s = new DashboardStats();
            if (rs.next()) {
                s.setTotalBeds(rs.getInt("total_beds"));
                s.setOccupiedBeds(rs.getInt("occupied_beds"));
                s.setPendingApplications(rs.getInt("pending_apps"));
                s.setWaitlisted(rs.getInt("waitlisted"));
                s.setTotalStudents(rs.getInt("students"));
                s.setPendingRequests(rs.getInt("pending_req"));
                s.setFeeCollected(rs.getBigDecimal("collected"));
                s.setFeeDue(rs.getBigDecimal("due"));
            }
            return s;
        }
    }

    public List<ActivityLog> recentActivity(int limit) throws SQLException {
        String sql = "SELECT l.action, l.details, l.log_time, u.full_name, "
                   + "       b.block_name || ' - ' || r.room_no room_label "
                   + "  FROM allocation_log l "
                   + "  LEFT JOIN users u ON u.user_id = l.student_id "
                   + "  LEFT JOIN rooms r ON r.room_id = l.room_id "
                   + "  LEFT JOIN hostel_blocks b ON b.block_id = r.block_id "
                   + " ORDER BY l.log_time DESC, l.log_id DESC FETCH FIRST ? ROWS ONLY";
        List<ActivityLog> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ActivityLog a = new ActivityLog();
                    a.setAction(rs.getString("action"));
                    a.setDetails(rs.getString("details"));
                    a.setLogTime(rs.getTimestamp("log_time"));
                    a.setStudentName(rs.getString("full_name"));
                    a.setRoomLabel(rs.getString("room_label"));
                    list.add(a);
                }
            }
        }
        return list;
    }

    /** Beds and fee per room type. Keys: type, rooms, beds, occupied, fee, pct */
    public List<Map<String, Object>> roomTypeSummary() throws SQLException {
        String sql = "SELECT room_type, COUNT(*) rooms, SUM(capacity) beds, SUM(occupied) occupied, "
                   + "       hostel_pkg.calc_fee(room_type) fee "
                   + "  FROM rooms WHERE status = 'ACTIVE' GROUP BY room_type "
                   + " ORDER BY DECODE(room_type, 'SINGLE', 1, 'DOUBLE', 2, 3)";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                int beds = rs.getInt("beds");
                int occupied = rs.getInt("occupied");
                m.put("type", rs.getString("room_type"));
                m.put("rooms", rs.getInt("rooms"));
                m.put("beds", beds);
                m.put("occupied", occupied);
                m.put("free", beds - occupied);
                m.put("fee", rs.getBigDecimal("fee"));
                m.put("pct", beds == 0 ? 0 : Math.round(occupied * 100f / beds));
                list.add(m);
            }
        }
        return list;
    }

    /** Fee position per block. Keys: block, residents, billed, collected, pending, pct */
    public List<Map<String, Object>> feeByBlock() throws SQLException {
        String sql = "SELECT b.block_name, COUNT(a.alloc_id) residents, "
                   + "  NVL(SUM(CASE WHEN a.alloc_id IS NOT NULL THEN hostel_pkg.calc_fee(r.room_type) END), 0) billed, "
                   + "  NVL(SUM(CASE WHEN a.alloc_id IS NOT NULL THEN hostel_pkg.fee_due(a.alloc_id) END), 0) pending "
                   + "  FROM hostel_blocks b "
                   + "  LEFT JOIN rooms r ON r.block_id = b.block_id "
                   + "  LEFT JOIN allocations a ON a.room_id = r.room_id AND a.status = 'ACTIVE' "
                   + " GROUP BY b.block_name ORDER BY b.block_name";
        List<Map<String, Object>> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> m = new LinkedHashMap<>();
                java.math.BigDecimal billed = rs.getBigDecimal("billed");
                java.math.BigDecimal pending = rs.getBigDecimal("pending");
                java.math.BigDecimal collected = billed.subtract(pending);
                m.put("block", rs.getString("block_name"));
                m.put("residents", rs.getInt("residents"));
                m.put("billed", billed);
                m.put("collected", collected);
                m.put("pending", pending);
                m.put("pct", billed.signum() == 0 ? 0
                        : collected.multiply(java.math.BigDecimal.valueOf(100))
                                   .divide(billed, 0, java.math.RoundingMode.HALF_UP).intValue());
                list.add(m);
            }
        }
        return list;
    }
}
