package com.hostel.servlet.student;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import com.hostel.dao.AllocationDAO;
import com.hostel.model.Allocation;
import com.hostel.model.User;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 * Hostel fee page. Payments are recorded in the database only - this is a
 * demo, no real payment gateway is involved.
 */
@WebServlet("/student/fees")
public class FeeServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final AllocationDAO allocationDAO = new AllocationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = currentUser(req);
        try {
            req.setAttribute("allocation", allocationDAO.findActiveByStudent(user.getUserId()));
            req.setAttribute("payments", allocationDAO.payments(user.getUserId()));
            view(req, resp, "student/fees");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = currentUser(req);
        BigDecimal amount = decimalParam(req, "amount");
        String mode = oneOf(param(req, "mode"), "UPI", "CARD", "NETBANKING", "CASH");

        try {
            // the allocation always comes from the DB, never from the form
            Allocation alloc = allocationDAO.findActiveByStudent(user.getUserId());
            if (alloc == null) {
                flash(req, "error", "You do not have an allotted room yet.");
            } else if (amount == null || mode == null) {
                flash(req, "error", "Enter a valid amount and choose a payment mode.");
            } else {
                String txn = allocationDAO.payFee(alloc.getAllocId(), amount, mode);
                flash(req, "success", "Payment recorded. Reference: " + txn);
            }
        } catch (SQLException e) {
            flashError(req, e);
        }
        redirect(req, resp, "/student/fees");
    }
}
