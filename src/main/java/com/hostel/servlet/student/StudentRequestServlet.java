package com.hostel.servlet.student;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.AllocationDAO;
import com.hostel.dao.RequestDAO;
import com.hostel.model.User;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/student/requests")
public class StudentRequestServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final RequestDAO requestDAO = new RequestDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        try {
            req.setAttribute("allocation", allocationDAO.findActiveByStudent(user.getUserId()));
            req.setAttribute("requests", requestDAO.listByStudent(user.getUserId()));
            view(req, resp, "student/requests");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        String type = oneOf(param(req, "reqType"), "VACATE", "CHANGE");
        String newType = oneOf(param(req, "newType"), "SINGLE", "DOUBLE", "TRIPLE");
        String reason = param(req, "reason");

        if (type == null || reason == null) {
            flash(req, "error", "Choose a request type and write a short reason.");
        } else if (reason.length() > 300) {
            flash(req, "error", "Keep the reason under 300 characters.");
        } else {
            try {
                int id = requestDAO.raise(user.getUserId(), type, newType, reason);
                flash(req, "success", "Request #" + id + " sent to the warden.");
            } catch (SQLException e) {
                flashError(req, e);
            }
        }
        redirect(req, resp, "/student/requests");
    }
}
