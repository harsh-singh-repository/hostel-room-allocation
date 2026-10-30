package com.hostel.servlet.student;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.AllocationDAO;
import com.hostel.dao.ApplicationDAO;
import com.hostel.dao.RequestDAO;
import com.hostel.model.Allocation;
import com.hostel.model.User;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/student/dashboard")
public class StudentDashboardServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final ApplicationDAO applicationDAO = new ApplicationDAO();
    private final AllocationDAO allocationDAO = new AllocationDAO();
    private final RequestDAO requestDAO = new RequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        try {
            Allocation alloc = allocationDAO.findActiveByStudent(user.getUserId());
            req.setAttribute("application", applicationDAO.findLatestByStudent(user.getUserId()));
            req.setAttribute("allocation", alloc);
            if (alloc != null) {
                req.setAttribute("roommates", allocationDAO.roommates(alloc.getRoomId(), user.getUserId()));
            }
            req.setAttribute("requests", requestDAO.listByStudent(user.getUserId()));
            view(req, resp, "student/dashboard");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }
}
