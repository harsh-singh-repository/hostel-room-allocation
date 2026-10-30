package com.hostel.servlet;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;

import com.hostel.model.User;
import com.hostel.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/** Helpers shared by every servlet: views, redirects, flash messages, params. */
public abstract class BaseServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    public static final String SESSION_USER = "user";
    private static final String FLASH = "flash";
    private static final String FLASH_TYPE = "flashType";

    protected void view(HttpServletRequest req, HttpServletResponse resp, String page)
            throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/" + page + ".jsp").forward(req, resp);
    }

    protected void redirect(HttpServletRequest req, HttpServletResponse resp, String path) throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
    }

    protected User currentUser(HttpServletRequest req) {
        HttpSession s = req.getSession(false);
        return s == null ? null : (User) s.getAttribute(SESSION_USER);
    }

    /** Message shown once on the next page (survives a redirect). */
    protected void flash(HttpServletRequest req, String type, String message) {
        HttpSession s = req.getSession();
        s.setAttribute(FLASH, message);
        s.setAttribute(FLASH_TYPE, type);   // success | error | info
    }

    protected void flashError(HttpServletRequest req, SQLException e) {
        log("Database error", e);
        flash(req, "error", DBUtil.friendlyMessage(e));
    }

    /** Shows the database-error page for failed GET requests. */
    protected void dbError(HttpServletRequest req, HttpServletResponse resp, SQLException e)
            throws ServletException, IOException {
        log("Database error", e);
        req.setAttribute("errorMessage", DBUtil.friendlyMessage(e));
        view(req, resp, "error");
    }

    protected static String param(HttpServletRequest req, String name) {
        String v = req.getParameter(name);
        if (v == null) {
            return null;
        }
        v = v.trim();
        return v.isEmpty() ? null : v;
    }

    protected static Integer intParam(HttpServletRequest req, String name) {
        String v = param(req, name);
        if (v == null) {
            return null;
        }
        try {
            return Integer.valueOf(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    protected static BigDecimal decimalParam(HttpServletRequest req, String name) {
        String v = param(req, name);
        if (v == null) {
            return null;
        }
        try {
            return new BigDecimal(v);
        } catch (NumberFormatException e) {
            return null;
        }
    }

    /** Accepts only one of the allowed values (case-insensitive), otherwise null. */
    protected static String oneOf(String value, String... allowed) {
        if (value == null) {
            return null;
        }
        for (String a : allowed) {
            if (a.equalsIgnoreCase(value)) {
                return a;
            }
        }
        return null;
    }
}
