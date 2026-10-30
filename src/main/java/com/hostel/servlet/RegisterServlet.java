package com.hostel.servlet;

import java.io.IOException;
import java.sql.SQLException;

import com.hostel.dao.UserDAO;
import com.hostel.util.DBUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/register")
public class RegisterServlet extends BaseServlet {

    private static final long serialVersionUID = 1L;
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        view(req, resp, "register");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String name = param(req, "fullName");
        String email = param(req, "email");
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");
        String gender = oneOf(param(req, "gender"), "M", "F");
        String phone = param(req, "phone");
        String roll = param(req, "rollNo");
        String course = param(req, "course");
        Integer year = intParam(req, "year");

        String error = null;
        if (name == null || email == null || roll == null || course == null) {
            error = "Please fill in all required fields.";
        } else if (!email.matches("^[\\w.+-]+@[\\w-]+(\\.[\\w-]+)+$")) {
            error = "Enter a valid email address.";
        } else if (gender == null) {
            error = "Select your gender.";
        } else if (year == null || year < 1 || year > 5) {
            error = "Select your year of study.";
        } else if (phone != null && !phone.matches("^[0-9+ -]{7,15}$")) {
            error = "Enter a valid phone number.";
        } else if (password == null || password.length() < 6) {
            error = "Password must be at least 6 characters.";
        } else if (!password.equals(confirm)) {
            error = "Passwords do not match.";
        }

        if (error == null) {
            try {
                userDAO.registerStudent(name, email, password, gender, phone, roll, course, year);
                flash(req, "success", "Account created. Sign in to apply for a room.");
                redirect(req, resp, "/login");
                return;
            } catch (SQLException e) {
                error = DBUtil.friendlyMessage(e);
            }
        }

        req.setAttribute("error", error);
        view(req, resp, "register");   // form values are re-filled from ${param.*}
    }
}
