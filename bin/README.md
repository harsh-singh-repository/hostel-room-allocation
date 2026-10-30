# Hostel Room Allocation System

A mini project built with **Java Servlets + JSP (JSTL)** on the front and middle tiers and
**Oracle PL/SQL** for the business logic: packages, procedures, functions, cursors, triggers,
custom exceptions, a function-based index and views.

- **Students** register, apply for a room, see their allotted room and roommates, pay the hostel
  fee (demo payments), and raise vacate / room-change requests.
- **The warden (admin)** reviews applications, runs one-click auto-allocation, manages blocks
  and rooms (including maintenance), vacates residents, approves requests, and views reports.

> The full step-by-step setup (Oracle + Eclipse + Tomcat) is in **[SETUP_GUIDE.md](SETUP_GUIDE.md)**.

---

## Tech stack

| Layer      | Technology                                                         |
|------------|--------------------------------------------------------------------|
| UI         | JSP + JSTL 3.0, custom CSS (no framework), vanilla JS               |
| Web tier   | Jakarta Servlet 6.0 (`@WebServlet`, `@WebFilter`), Tomcat 10.1      |
| Data tier  | JDBC (`CallableStatement` → PL/SQL), Oracle JDBC `ojdbc11`          |
| Database   | Oracle XE 21c (any Oracle 12c+ works)                               |
| Build      | Maven (`war` packaging), Java 17+                                   |

Fonts (Plus Jakarta Sans, Bricolage Grotesque) and icons (Tabler) are bundled in
`src/main/webapp/assets/vendor`, so the app looks right even without internet.

---

## Demo logins (created by `04_seed_data.sql`)

| Role    | Email               | Password     |
|---------|---------------------|--------------|
| Warden  | admin@hostel.edu    | admin123     |
| Student | rahul@student.edu   | student123   |
| Student | priya@student.edu   | student123   |
| Student | karan@student.edu   | student123   (application still pending) |

Other seeded students: aman, simran, arjun, neha, ananya `@student.edu` (all `student123`).

---

## Project structure

```
HostelRoomAllocation/
├── pom.xml
├── README.md / SETUP_GUIDE.md
├── database/
│   ├── 00_create_user.sql     run once as SYSTEM: creates user HOSTEL
│   ├── 01_schema.sql          tables, constraints, indexes, views
│   ├── 02_package.sql         HOSTEL_PKG (all business logic)
│   ├── 03_triggers.sql        validation, occupancy counter, audit log
│   ├── 04_seed_data.sql       demo blocks, rooms, students, allocations
│   └── install_all.sql        runs 01-04 in order
└── src/main/
    ├── java/com/hostel/
    │   ├── util/DBUtil.java           JDBC connection + friendly Oracle errors
    │   ├── model/                     User, Block, Room, Application, Allocation, ...
    │   ├── dao/                       UserDAO, RoomDAO, ApplicationDAO, AllocationDAO,
    │   │                              RequestDAO, ReportDAO (CallableStatement calls)
    │   ├── filter/AuthFilter.java     login + role check for /student/* and /admin/*
    │   └── servlet/                   Login, Register, Logout
    │       ├── student/               Dashboard, Apply, Fees, Requests
    │       └── admin/                 Dashboard, Applications, Rooms, Residents,
    │                                  Requests, Reports
    ├── resources/db.properties        <-- your Oracle URL / user / password
    └── webapp/
        ├── assets/css/app.css, assets/js/app.js, assets/vendor/...
        └── WEB-INF/
            ├── web.xml
            └── views/                 all JSPs (not directly reachable from the browser)
                ├── common/            layout fragments (header, footer, flash...)
                ├── student/  admin/
                └── login.jsp, register.jsp, error.jsp, 404.jsp
```

---

## Request flow (MVC)

```
Browser ──► AuthFilter ──► Servlet (controller) ──► DAO ──► {call hostel_pkg.xxx(...)} ──► Oracle
                                 │                                         │ triggers fire
                                 ▼                                         ▼
                         JSP view (WEB-INF/views)  ◄── model objects ◄── result / OUT params
```

- Every **POST** ends in a redirect (Post/Redirect/Get), with a one-time "flash" message.
- Errors raised in PL/SQL with `RAISE_APPLICATION_ERROR(-200xx, 'message')` are shown
  directly to the user (see `DBUtil.friendlyMessage`).

---

## Database design

**Tables:** `users`, `hostel_blocks`, `rooms`, `applications`, `allocations`, `fee_payments`,
`room_requests`, `allocation_log`

**Views:** `v_room_details`, `v_active_allocations`, `v_block_occupancy`

### Where the PL/SQL is used

| Feature                    | PL/SQL object                                   | Concepts shown |
|----------------------------|-------------------------------------------------|----------------|
| Login / register           | `hostel_pkg.login`, `register_student`, `hash_pwd` | SHA-256 via `STANDARD_HASH`, `DUP_VAL_ON_INDEX` handling |
| Apply for room             | `apply_room`, `cancel_application`              | business validation, custom errors |
| Allocate one application   | `allocate_room` → private `do_allocate`         | explicit cursor with `FOR UPDATE SKIP LOCKED`, `%ROWTYPE` |
| Auto-allocate everyone     | `auto_allocate_all`                             | cursor FOR loop, `SAVEPOINT` / `ROLLBACK TO` per row |
| Vacate + promote waitlist  | `vacate_room` → `do_vacate`                     | transaction across tables |
| Room change                | `process_request`                               | all-or-nothing transaction with rollback |
| Fees                       | `calc_fee`, `fee_due`, `pay_fee`                | functions used inside SQL queries |
| Room management            | `add_room`                                      | `CASE` expressions, constraint errors |
| Integrity                  | `trg_alloc_validate`                            | BEFORE INSERT row trigger (full room, maintenance, gender) |
| Occupancy counter + audit  | `trg_alloc_occupancy`, `trg_fee_log`            | AFTER row triggers, `INSERTING` / `UPDATING` |
| Maintenance rule           | `trg_room_status`                               | blocks maintenance on occupied rooms |
| One active room / student  | `ux_alloc_one_active`                           | function-based unique index |

**Allocation rules:** same-gender block, requested room type, preferred block first, then
partially-filled rooms first. Seniors (higher year) get priority, then first-come-first-served.
If nothing is free the application is **WAITLISTED**; when someone vacates, the first matching
waitlisted student is allotted automatically.

**Fees per semester:** Single ₹45,000 · Double ₹35,000 · Triple ₹28,000 (constants in the package body).

---

## Ideas to extend it

- Email / SMS notification when a room is allotted
- Upload ID proof / photo during registration
- Mess menu and mess-fee module
- Complaint / maintenance ticket module for students
- Export reports to Excel (Apache POI)
- Connection pooling with a Tomcat JNDI `DataSource`
