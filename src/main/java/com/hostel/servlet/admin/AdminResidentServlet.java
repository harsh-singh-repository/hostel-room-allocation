package com.hostel.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.AllocationDAO;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/residents")
public class AdminResidentServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final AllocationDAO allocationDAO = new AllocationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("residents", allocationDAO.listActive());
            view(req, resp, "admin/residents");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer studentId = intParam(req, "studentId");
        if ("vacate".equals(param(req, "action")) && studentId != null) {
            try {
                Integer next = allocationDAO.vacate(studentId);
                flash(req, "success", next == null
                        ? "Bed released."
                        : "Bed released and given to waitlisted application #" + next + ".");
            } catch (SQLException e) {
                flashError(req, e);
            }
        }
        redirect(req, resp, "/admin/residents");
    }
}
