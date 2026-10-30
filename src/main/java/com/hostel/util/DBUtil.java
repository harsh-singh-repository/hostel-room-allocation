package com.hostel.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Opens JDBC connections using the settings in /db.properties and turns
 * Oracle errors into messages that can be shown to the user.
 */
public final class DBUtil {

    private static final Properties PROPS = new Properties();

    static {
        try (InputStream in = DBUtil.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (in == null) {
                throw new IllegalStateException("db.properties not found on the classpath");
            }
            PROPS.load(in);
            Class.forName("oracle.jdbc.OracleDriver");
        } catch (IOException | ClassNotFoundException e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DBUtil() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(
                PROPS.getProperty("db.url"),
                PROPS.getProperty("db.user"),
                PROPS.getProperty("db.password"));
    }

    /**
     * Messages raised with RAISE_APPLICATION_ERROR (-20000..-20999) are
     * business rules written for the user, so they are shown as-is.
     * Everything else becomes a short, generic message.
     */
    public static String friendlyMessage(SQLException e) {
        int code = e.getErrorCode();
        String msg = e.getMessage() == null ? "" : e.getMessage();

        if (code >= 20000 && code <= 20999) {
            String first = msg.split("\\R", 2)[0];               // first line only
            return first.replaceFirst("^ORA-\\d{5}:\\s*", "").trim();
        }
        if (code == 1017) {
            return "Database login failed. Check db.user / db.password in db.properties.";
        }
        if (code == 17002 || code == 12505 || code == 12514 || code == 12541
                || msg.contains("IO Error") || msg.contains("Network Adapter")) {
            return "Cannot reach the Oracle database. Is it running, and is db.url in db.properties correct?";
        }
        if (code == 4068 || code == 4061 || code == 6508) {
            return "The database package was recompiled. Please try again.";
        }
        if (code == 1) {
            return "That record already exists.";
        }
        return "Database error (ORA-" + String.format("%05d", code) + "). " + msg.split("\\R", 2)[0];
    }
}
