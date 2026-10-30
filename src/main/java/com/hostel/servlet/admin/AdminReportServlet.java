package com.hostel.servlet.admin;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.ApplicationDAO;
import com.hostel.dao.ReportDAO;
import com.hostel.dao.RoomDAO;
import com.hostel.servlet.BaseServlet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/admin/reports")
public class AdminReportServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final ReportDAO reportDAO = new ReportDAO();
    private final RoomDAO roomDAO = new RoomDAO();
    private final ApplicationDAO applicationDAO = new ApplicationDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            req.setAttribute("stats", reportDAO.stats());
            req.setAttribute("blocks", roomDAO.listBlocks());
            req.setAttribute("types", reportDAO.roomTypeSummary());
            req.setAttribute("fees", reportDAO.feeByBlock());
            req.setAttribute("waitlist", applicationDAO.listWaitlist());
            req.setAttribute("generatedOn", new java.util.Date());
            view(req, resp, "admin/reports");
        } catch (SQLException e) {
            dbError(req, resp, e);
        }
    }
}
