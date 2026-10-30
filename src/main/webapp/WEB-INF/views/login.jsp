<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/common/head.jspf" %>
<title>Sign in · Hostel Room Allocation</title>
</head>
<body>
<div class="auth">
<%@ include file="/WEB-INF/views/common/auth-art.jspf" %>

  <section class="auth-form">
    <div class="auth-box">
      <h2>Welcome back</h2>
      <p class="sub">Sign in to your hostel account.</p>

      <%@ include file="/WEB-INF/views/common/flash.jspf" %>
      <c:if test="${not empty error}">
        <div class="alert alert-error"><i class="ti ti-alert-circle"></i><span><c:out value="${error}" /></span></div>
      </c:if>

      <form method="post" action="${ctx}/login" novalidate>
        <div class="field">
          <label for="email">Email</label>
          <div class="input-icon">
            <i class="ti ti-mail"></i>
            <input class="input" type="email" id="email" name="email" value="${fn:escapeXml(email)}"
                   placeholder="you@college.edu" autocomplete="username" required autofocus>
          </div>
        </div>
        <div class="field">
          <label for="password">Password</label>
          <div class="input-icon">
            <i class="ti ti-lock"></i>
            <input class="input" type="password" id="password" name="password"
                   placeholder="Your password" autocomplete="current-password" required>
          </div>
        </div>
        <button class="btn btn-block mt-1" type="submit">Sign in <i class="ti ti-arrow-right"></i></button>
      </form>

      <p class="mt-2 muted">New student? <a href="${ctx}/register">Create an account</a></p>

      <div class="demo">
        <strong>Demo accounts</strong> (from the seed script)<br>
        <button type="button" data-demo-email="admin@hostel.edu" data-demo-pass="admin123">Warden: admin@hostel.edu</button>
        <button type="button" data-demo-email="rahul@student.edu" data-demo-pass="student123">Student: rahul@student.edu</button>
      </div>
    </div>
  </section>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
