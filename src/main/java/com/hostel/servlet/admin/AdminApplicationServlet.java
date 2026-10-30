package com.hostel.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.ApplicationDAO;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/applications")
public class AdminApplicationServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final ApplicationDAO applicationDAO = new ApplicationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String status = oneOf(param(req, "status"), "PENDING", "WAITLISTED", "ALLOTTED", "REJECTED", "CANCELLED");
        try {
            req.setAttribute("status", status);
            req.setAttribute("counts", applicationDAO.countByStatus());
            req.setAttribute("applications", applicationDAO.listByStatus(status));
            view(req, resp, "admin/applications");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String action = param(req, "action");
        Integer appId = intParam(req, "appId");
        String back = param(req, "back");          // keep the current filter tab

        try {
            if ("auto".equals(action)) {
                int[] r = applicationDAO.autoAllocateAll();
                flash(req, "success", "Auto-allocation finished: " + r[0] + " allotted, "
                        + r[1] + " waitlisted.");
            } else if ("allocate".equals(action) && appId != null) {
                String result = applicationDAO.allocate(appId);
                if ("ALLOTTED".equals(result)) {
                    flash(req, "success", "Application #" + appId + " allotted a room.");
                } else {
                    flash(req, "info", "No matching bed is free. Application #" + appId + " moved to the waitlist.");
                }
            } else if ("reject".equals(action) && appId != null) {
                applicationDAO.reject(appId, param(req, "remarks"));
                flash(req, "info", "Application #" + appId + " rejected.");
            }
        } catch (SQLException e) {
            flashError(req, e);
        }

        String status = oneOf(back, "PENDING", "WAITLISTED", "ALLOTTED", "REJECTED", "CANCELLED");
        redirect(req, resp, "/admin/applications" + (status != null ? "?status=" + status : ""));
    }
}
