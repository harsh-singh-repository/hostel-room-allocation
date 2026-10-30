package com.hostel.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;

import com.hostel.model.User;
import com.hostel.util.DBUtil;

public class UserDAO {

    /** Verifies credentials through hostel_pkg.login and returns the user. */
    public User login(String email, String password) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.login(?, ?, ?, ?, ?)}")) {
            cs.setString(1, email);
            cs.setString(2, password);
            cs.registerOutParameter(3, Types.NUMERIC);
            cs.registerOutParameter(4, Types.VARCHAR);
            cs.registerOutParameter(5, Types.VARCHAR);
            cs.execute();
            return findById(con, cs.getInt(3));
        }
    }

    public int registerStudent(String name, String email, String password, String gender,
                               String phone, String rollNo, String course, Integer year) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall(
                     "{call hostel_pkg.register_student(?, ?, ?, ?, ?, ?, ?, ?, ?)}")) {
            cs.setString(1, name);
            cs.setString(2, email);
            cs.setString(3, password);
            cs.setString(4, gender);
            cs.setString(5, phone);
            cs.setString(6, rollNo);
            cs.setString(7, course);
            if (year == null) {
                cs.setNull(8, Types.NUMERIC);
            } else {
                cs.setInt(8, year);
            }
            cs.registerOutParameter(9, Types.NUMERIC);
            cs.execute();
            return cs.getInt(9);
        }
    }

    public User findById(int userId) throws SQLException {
        try (Connection con = DBUtil.getConnection()) {
            return findById(con, userId);
        }
    }

    private User findById(Connection con, int userId) throws SQLException {
        String sql = "SELECT user_id, full_name, email, role, gender, phone, roll_no, course, "
                   + "year_of_study, created_at FROM users WHERE user_id = ?";
        try (PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? map(rs) : null;
            }
        }
    }

    static User map(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getInt("user_id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setRole(rs.getString("role"));
        u.setGender(rs.getString("gender"));
        u.setPhone(rs.getString("phone"));
        u.setRollNo(rs.getString("roll_no"));
        u.setCourse(rs.getString("course"));
        u.setYearOfStudy(DaoUtil.getInteger(rs, "year_of_study"));
        u.setCreatedAt(rs.getTimestamp("created_at"));
        return u;
    }
}
