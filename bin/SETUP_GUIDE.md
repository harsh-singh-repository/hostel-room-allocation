# Setup Guide: Hostel Room Allocation System

Follow the parts in order: **A. install the software**, then **B. set up the database**,
then **C. run the app in Eclipse**. It takes about 30–45 minutes the first time.

---

## A. Install the software (one time)

| # | Software | Version | Notes |
|---|----------|---------|-------|
| 1 | **JDK** | 17 or 21 | e.g. Eclipse Temurin. Note the install folder. |
| 2 | **Eclipse IDE for Enterprise Java and Web Developers** | 2023-09 or newer | This edition already contains Maven (m2e) and the Tomcat/web tools. The plain "Java Developers" edition is **not** enough. |
| 3 | **Apache Tomcat** | **10.1.x** | Download the *zip* (Core) and extract it, e.g. `C:\tomcat\apache-tomcat-10.1.xx`. ⚠ Tomcat 9 will **not** work (it uses `javax.*`, this project uses `jakarta.*`). |
| 4 | **Oracle Database XE** | 21c (18c also fine) | During install you set a password for SYS / SYSTEM. **Remember it.** |
| 5 | **Oracle SQL Developer** | any recent | Used to run the SQL scripts. (SQL*Plus or SQLcl also work.) |

---

## B. Set up the Oracle database

### B1. Create the application user (run once)

1. Open **SQL Developer** → green **+** (New Connection):

   | Field | Value |
   |---|---|
   | Name | `system-xepdb1` |
   | Username | `system` |
   | Password | *the password you chose while installing Oracle* |
   | Hostname / Port | `localhost` / `1521` |
   | **Service name** (not SID) | `XEPDB1` |

2. Click **Test** → *Status: Success* → **Connect**.
3. Open `database/00_create_user.sql` (File → Open), then press **F5** (*Run Script*).
   This creates the user **`hostel` / `hostel123`**.

> **Oracle 11g XE?** It has no XEPDB1 and no identity columns. This project needs Oracle **12c or newer**.
> With 18c/21c XE always connect to the **XEPDB1** service, not the root container `XE`.

### B2. Create the tables, PL/SQL and demo data

1. Create a second connection:

   | Field | Value |
   |---|---|
   | Name | `hostel` |
   | Username / Password | `hostel` / `hostel123` |
   | Hostname / Port / Service name | `localhost` / `1521` / `XEPDB1` |

2. Using the **hostel** connection, open and run each script with **F5**, in this order:

   1. `01_schema.sql` – tables, constraints, indexes, views
   2. `02_package.sql` – package `HOSTEL_PKG` (should end with *No errors*)
   3. `03_triggers.sql` – triggers
   4. `04_seed_data.sql` – demo data. The output should show
      *"Auto allocation: 6 allotted, 0 waitlisted"* and *"Seed data loaded successfully."*

   *(Shortcut: with SQL\*Plus / SQLcl, `cd` into the `database` folder, connect as hostel and run `@install_all.sql`.)*

3. Quick check, run in the hostel worksheet:

   ```sql
   SELECT object_name, object_type, status FROM user_objects
    WHERE object_type IN ('PACKAGE','PACKAGE BODY','TRIGGER') ORDER BY 2, 1;
   ```
   Every row must show **VALID**. If something is INVALID, run `ALTER PACKAGE hostel_pkg COMPILE BODY;`
   and look at the error with `SHOW ERRORS PACKAGE BODY hostel_pkg;`.

> **To reset the demo data later**, just run scripts **01 → 04** again (01 drops and recreates everything).
> Restart Tomcat afterwards.

---

## C. Run the project in Eclipse

### C1. Import the project

1. Unzip `HostelRoomAllocation.zip` somewhere simple, e.g. `D:\projects\HostelRoomAllocation`.
2. Eclipse → **File → Import… → Maven → Existing Maven Projects** → *Next*.
3. **Root Directory** → Browse to the unzipped `HostelRoomAllocation` folder (the one containing `pom.xml`) → tick the `pom.xml` → **Finish**.
4. Wait for Maven to download the dependencies (bottom-right progress bar; needs internet the first time).
   It downloads: JSTL (API + implementation) and the Oracle JDBC driver `ojdbc11`.
5. If you see red marks: right-click the project → **Maven → Update Project…** → tick *Force Update* → OK.

### C2. Check the Java version

Right-click project → **Properties → Java Build Path → Libraries**: the JRE System Library should be
**JavaSE-17** (or 21). If not: **Properties → Java Compiler** → set *Compiler compliance level* to 17,
and **Window → Preferences → Java → Installed JREs** → add your JDK.

### C3. Add Tomcat 10.1 to Eclipse

1. **Window → Preferences → Server → Runtime Environments → Add…**
2. Choose **Apache → Apache Tomcat v10.1** → *Next*.
3. **Tomcat installation directory** → the extracted Tomcat folder. **JRE** → your JDK 17/21 → **Finish** → *Apply and Close*.
4. Open the **Servers** view (Window → Show View → Servers). Click the link to create a new server →
   **Tomcat v10.1 Server** → *Next* → move **HostelRoomAllocation** to the *Configured* side → **Finish**.

### C4. Point the app at your database

Open `src/main/resources/db.properties`:

```properties
db.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
db.user=hostel
db.password=hostel123
```

Change these only if your database is different (another host, port, password, or service name).

### C5. Run it

Right-click the project → **Run As → Run on Server** → choose the Tomcat 10.1 server → **Finish**.

Open in your browser:

```
http://localhost:8080/HostelRoomAllocation/
```

Sign in with the demo accounts (the login page has one-click buttons that fill them in):

| Role | Email | Password |
|---|---|---|
| Warden / Admin | `admin@hostel.edu` | `admin123` |
| Student | `rahul@student.edu` | `student123` |

---

## D. Things to try in the demo

1. **Warden → Applications**: Karan and Ananya are *pending*. Click **Allocate** on one, or
   **Auto-allocate all**. Watch the bed counters change on *Blocks & Rooms*.
2. **Warden → Blocks & Rooms → Kalpana Block**: send a room for maintenance (gear icon). Try it on an
   occupied room and the **trigger** blocks it with a clear message.
3. **Student (karan@student.edu)**: see the progress tracker; after allocation, pay part of the fee.
4. **Student (aman@student.edu)** already has a *room change* request. **Warden → Requests → Approve**
   moves him to a single room in one transaction.
5. **Warden → Residents → Vacate** someone. If anyone is waitlisted for that room type, they get the
   bed automatically (see *Recent activity* on the dashboard).
6. **Warden → Reports → Print / Save PDF** for a printable report.

---

## E. Troubleshooting

| Problem | Fix |
|---|---|
| **"Cannot reach the Oracle database"** / `ORA-12514`, `ORA-12505`, `IO Error` | Oracle service not running (Windows: *Services* → `OracleServiceXE` and `OracleOraDB21Home1TNSListener` → Start), or wrong `db.url`. For 18c/21c use the service name **XEPDB1** (`@//localhost:1521/XEPDB1`). |
| `ORA-01017: invalid username/password` | `db.user` / `db.password` in `db.properties` don't match the user created in B1. |
| `ORA-00942: table or view does not exist` / `ORA-06550 ... HOSTEL_PKG` | Scripts were run as SYSTEM instead of the **hostel** user, or one script was skipped. Re-run 01 → 04 with the hostel connection. |
| `ORA-04068: existing state of packages has been discarded` | You re-ran the scripts while Tomcat was running. Just refresh the page or restart Tomcat. |
| `ORA-01950: no privileges on tablespace 'USERS'` | Run as SYSTEM: `ALTER USER hostel QUOTA UNLIMITED ON users;` |
| `ClassNotFoundException: jakarta.servlet...` or the server won't start | You are using Tomcat 9 or older. Use **Tomcat 10.1**. |
| JSP error: `Unable to find taglib [c] for URI [jakarta.tags.core]` | Maven dependencies not downloaded: right-click project → **Maven → Update Project (Force Update)**, then *Clean* the server and restart it. |
| `ClassNotFoundException: oracle.jdbc.OracleDriver` | Same as above (ojdbc11 not downloaded). Check *Maven Dependencies* in the project tree contains `ojdbc11-….jar`. |
| "Port 8080 already in use" | Double-click the server in the *Servers* view → change *HTTP/1.1* port to 8081 → save → use `http://localhost:8081/...`. |
| Project shows no "Run on Server" | You imported with the wrong Eclipse edition or as a plain Java project. Use *Eclipse IDE for Enterprise Java and Web Developers* and import as **Existing Maven Project**. |
| Changes in JSP/CSS don't show | Hard refresh the browser (Ctrl + F5). For Java changes Eclipse redeploys automatically; if not, right-click server → *Clean…* → restart. |

### Offline lab / no Maven

If Maven cannot download anything, create a *Dynamic Web Project* instead and copy these jars into
`src/main/webapp/WEB-INF/lib` (download them once from Maven Central on another PC):

- `jakarta.servlet.jsp.jstl-api-3.0.0.jar`
- `jakarta.servlet.jsp.jstl-3.0.1.jar` (org.glassfish.web)
- `ojdbc11-23.5.0.24.07.jar` (any recent ojdbc11 is fine)

Then copy `src/main/java`, `src/main/resources` and `src/main/webapp` from this project into the new
project. The Servlet/JSP API comes from the Tomcat runtime, so no other jars are needed.
