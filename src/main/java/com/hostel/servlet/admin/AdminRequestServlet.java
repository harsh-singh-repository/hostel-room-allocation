package com.hostel.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.RequestDAO;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/requests")
public class AdminRequestServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final RequestDAO requestDAO = new RequestDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String status = oneOf(param(req, "status"), "PENDING", "APPROVED", "REJECTED");
        try {
            req.setAttribute("status", status);
            req.setAttribute("requests", requestDAO.listAll(status));
            view(req, resp, "admin/requests");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        Integer reqId = intParam(req, "reqId");
        String decision = param(req, "decision");
        if (reqId != null && ("approve".equals(decision) || "reject".equals(decision))) {
            boolean approve = "approve".equals(decision);
            try {
                requestDAO.process(reqId, approve, param(req, "note"));
                flash(req, approve ? "success" : "info",
                        "Request #" + reqId + (approve ? " approved." : " rejected."));
            } catch (SQLException e) {
                flashError(req, e);
            }
        }
        redirect(req, resp, "/admin/requests");
    }
}
