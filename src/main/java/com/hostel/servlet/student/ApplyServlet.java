package com.hostel.servlet.student;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.AllocationDAO;
import com.hostel.dao.ApplicationDAO;
import com.hostel.dao.RoomDAO;
import com.hostel.model.User;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/student/apply")
public class ApplyServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final ApplicationDAO applicationDAO = new ApplicationDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final RoomDAO roomDAO = new RoomDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        try {
            req.setAttribute("blocks", roomDAO.listBlocksForGender(user.getGender()));
            req.setAttribute("applications", applicationDAO.listByStudent(user.getUserId()));
            req.setAttribute("latest", applicationDAO.findLatestByStudent(user.getUserId()));
            req.setAttribute("allocation", allocationDAO.findActiveByStudent(user.getUserId()));
            view(req, resp, "student/apply");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        String action = param(req, "action");
        try {
            if ("cancel".equals(action)) {
                Integer appId = intParam(req, "appId");
                if (appId != null) {
                    applicationDAO.cancel(appId, user.getUserId());   // procedure checks ownership
                    flash(req, "info", "Your application was cancelled.");
                }
            } else {
                String type = oneOf(param(req, "roomType"), "SINGLE", "DOUBLE", "TRIPLE");
                Integer blockId = intParam(req, "blockId");          // null = any block
                if (type == null) {
                    flash(req, "error", "Choose a room type.");
                    redirect(req, resp, "/student/apply");
                    return;
                }
                int appId = applicationDAO.apply(user.getUserId(), blockId, type);
                flash(req, "success", "Application #" + appId + " submitted. The warden will review it soon.");
            }
        } catch (SQLException e) {
            flashError(req, e);
        }
        redirect(req, resp, "/student/apply");
    }
}
