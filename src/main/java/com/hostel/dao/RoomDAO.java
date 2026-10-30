package com.hostel.dao;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import com.hostel.model.Block;
import com.hostel.model.Room;
import com.hostel.util.DBUtil;

/** Hostel blocks and rooms. */
public class RoomDAO {

    // ----------------------------- blocks -----------------------------

    public List<Block> listBlocks() throws SQLException {
        return queryBlocks("SELECT * FROM v_block_occupancy ORDER BY block_name", null);
    }

    public List<Block> listBlocksForGender(String gender) throws SQLException {
        return queryBlocks("SELECT * FROM v_block_occupancy WHERE gender = ? ORDER BY block_name", gender);
    }

    private List<Block> queryBlocks(String sql, String gender) throws SQLException {
        List<Block> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (gender != null) {
                ps.setString(1, gender);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Block b = new Block();
                    b.setBlockId(rs.getInt("block_id"));
                    b.setBlockName(rs.getString("block_name"));
                    b.setGender(rs.getString("gender"));
                    b.setWardenName(rs.getString("warden_name"));
                    b.setDescription(rs.getString("description"));
                    b.setTotalRooms(rs.getInt("total_rooms"));
                    b.setTotalBeds(rs.getInt("total_beds"));
                    b.setOccupiedBeds(rs.getInt("occupied_beds"));
                    list.add(b);
                }
            }
        }
        return list;
    }

    public void addBlock(String name, String gender, String warden, String description) throws SQLException {
        String sql = "INSERT INTO hostel_blocks (block_name, gender, warden_name, description) VALUES (?, ?, ?, ?)";
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setString(2, gender);
            ps.setString(3, warden);
            ps.setString(4, description);
            ps.executeUpdate();
        }
    }

    // ------------------------------ rooms -----------------------------

    public List<Room> listRooms(Integer blockId) throws SQLException {
        String sql = "SELECT * FROM v_room_details "
                   + (blockId != null ? "WHERE block_id = ? " : "")
                   + "ORDER BY block_name, floor_no, LPAD(room_no, 10, '0')";
        List<Room> list = new ArrayList<>();
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            if (blockId != null) {
                ps.setInt(1, blockId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Room r = new Room();
                    r.setRoomId(rs.getInt("room_id"));
                    r.setRoomNo(rs.getString("room_no"));
                    r.setFloorNo(rs.getInt("floor_no"));
                    r.setRoomType(rs.getString("room_type"));
                    r.setCapacity(rs.getInt("capacity"));
                    r.setOccupied(rs.getInt("occupied"));
                    r.setStatus(rs.getString("status"));
                    r.setBlockId(rs.getInt("block_id"));
                    r.setBlockName(rs.getString("block_name"));
                    r.setGender(rs.getString("gender"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    public int addRoom(int blockId, String roomNo, int floor, String type) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             CallableStatement cs = con.prepareCall("{call hostel_pkg.add_room(?, ?, ?, ?, ?)}")) {
            cs.setInt(1, blockId);
            cs.setString(2, roomNo);
            cs.setInt(3, floor);
            cs.setString(4, type);
            cs.registerOutParameter(5, Types.NUMERIC);
            cs.execute();
            return cs.getInt(5);
        }
    }

    /** The trg_room_status trigger blocks maintenance for occupied rooms. */
    public void setRoomStatus(int roomId, String status) throws SQLException {
        try (Connection con = DBUtil.getConnection();
             PreparedStatement ps = con.prepareStatement("UPDATE rooms SET status = ? WHERE room_id = ?")) {
            ps.setString(1, status);
            ps.setInt(2, roomId);
            ps.executeUpdate();
        }
    }
}
