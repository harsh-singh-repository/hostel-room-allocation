package com.hostel.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.UserDAO;
import com.hostel.model.User;
import com.hostel.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/login")
public class LoginServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User u = currentUser(req);
        if (u != null) {
            redirect(req, resp, u.isAdmin() ? "/admin/dashboard" : "/student/dashboard");
            return;
        }
        view(req, resp, "login");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = param(req, "email");
        String password = req.getParameter("password");

        if (email == null || password == null || password.isEmpty()) {
            req.setAttribute("error", "Enter your email and password.");
            req.setAttribute("email", email);
            view(req, resp, "login");
            return;
        }

        try {
            User user = userDAO.login(email, password);

            // new session id after login (prevents session fixation)
            HttpSession old = req.getSession(false);
            if (old != null) {
                old.invalidate();
            }
            HttpSession session = req.getSession(true);
            session.setAttribute(SESSION_USER, user);

            flash(req, "success", "Welcome back, " + user.getFirstName() + "!");
            redirect(req, resp, user.isAdmin() ? "/admin/dashboard" : "/student/dashboard");
        } catch (SQLException e) {
            req.setAttribute("error", DBUtil.friendlyMessage(e));
            req.setAttribute("email", email);
            view(req, resp, "login");
        }
    }
}
