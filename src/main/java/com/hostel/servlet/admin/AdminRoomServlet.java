package com.hostel.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

import com.hostel.dao.RoomDAO;
import com.hostel.model.Block;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/rooms")
public class AdminRoomServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            List<Block> blocks = roomDAO.listBlocks();
            Integer blockId = intParam(req, "block");
            if (blockId == null && !blocks.isEmpty()) {
                blockId = blocks.get(0).getBlockId();
            }
            Block selected = null;
            for (Block b : blocks) {
                if (blockId != null && b.getBlockId() == blockId) {
                    selected = b;
                }
            }
            req.setAttribute("blocks", blocks);
            req.setAttribute("selected", selected);
            req.setAttribute("rooms", selected == null ? List.of() : roomDAO.listRooms(selected.getBlockId()));
            view(req, resp, "admin/rooms");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = param(req, "action");
        Integer blockId = intParam(req, "blockId");

        try {
            switch (action == null ? "" : action) {
                case "addBlock": {
                    String name = param(req, "blockName");
                    String gender = oneOf(param(req, "gender"), "M", "F");
                    if (name == null || gender == null) {
                        flash(req, "error", "Block name and gender are required.");
                    } else {
                        roomDAO.addBlock(name, gender, param(req, "wardenName"), param(req, "description"));
                        flash(req, "success", "Block \"" + name + "\" added.");
                    }
                    break;
                }
                case "addRoom": {
                    String roomNo = param(req, "roomNo");
                    String type = oneOf(param(req, "roomType"), "SINGLE", "DOUBLE", "TRIPLE");
                    Integer floor = intParam(req, "floorNo");
                    if (blockId == null || roomNo == null || type == null) {
                        flash(req, "error", "Room number and type are required.");
                    } else {
                        roomDAO.addRoom(blockId, roomNo, floor == null ? 0 : floor, type);
                        flash(req, "success", "Room " + roomNo + " added.");
                    }
                    break;
                }
                case "status": {
                    Integer roomId = intParam(req, "roomId");
                    String status = oneOf(param(req, "status"), "ACTIVE", "MAINTENANCE");
                    if (roomId != null && status != null) {
                        roomDAO.setRoomStatus(roomId, status);
                        flash(req, "success", "MAINTENANCE".equals(status)
                                ? "Room marked for maintenance." : "Room is active again.");
                    }
                    break;
                }
                default:
                    break;
            }
        } catch (SQLException e) {
            flashError(req, e);
        }
        redirect(req, resp, "/admin/rooms" + (blockId != null ? "?block=" + blockId : ""));
    }
}
