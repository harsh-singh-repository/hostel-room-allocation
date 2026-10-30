<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/common/head.jspf" %>
<title>Create account · Hostel Room Allocation</title>
</head>
<body>
<div class="auth">
<%@ include file="/WEB-INF/views/common/auth-art.jspf" %>

  <section class="auth-form">
    <div class="auth-box wide">
      <h2>Create your account</h2>
      <p class="sub">Register once, then apply for a hostel room.</p>

      <c:if test="${not empty error}">
        <div class="alert alert-error"><i class="ti ti-alert-circle"></i><span><c:out value="${error}" /></span></div>
      </c:if>

      <form method="post" action="${ctx}/register">
        <div class="field">
          <label for="fullName">Full name *</label>
          <input class="input" id="fullName" name="fullName" value="${fn:escapeXml(param.fullName)}" maxlength="100" required>
        </div>

        <div class="row">
          <div class="field">
            <label for="email">Email *</label>
            <input class="input" type="email" id="email" name="email" value="${fn:escapeXml(param.email)}" maxlength="120" required>
          </div>
          <div class="field">
            <label for="phone">Phone</label>
            <input class="input" type="tel" id="phone" name="phone" value="${fn:escapeXml(param.phone)}" maxlength="15">
          </div>
        </div>

        <div class="row">
          <div class="field">
            <label for="rollNo">Roll number *</label>
            <input class="input" id="rollNo" name="rollNo" value="${fn:escapeXml(param.rollNo)}" maxlength="20" required>
          </div>
          <div class="field">
            <label for="course">Course *</label>
            <input class="input" id="course" name="course" value="${fn:escapeXml(param.course)}" maxlength="60"
                   placeholder="e.g. B.Tech CSE" required>
          </div>
        </div>

        <div class="row">
          <div class="field">
            <label>Gender *</label>
            <div class="segmented">
              <label><input type="radio" name="gender" value="M" ${param.gender == 'M' ? 'checked' : ''} required><i class="ti ti-gender-male"></i>Male</label>
              <label><input type="radio" name="gender" value="F" ${param.gender == 'F' ? 'checked' : ''}><i class="ti ti-gender-female"></i>Female</label>
            </div>
            <div class="hint">Decides which hostel blocks you can apply to.</div>
          </div>
          <div class="field">
            <label for="year">Year of study *</label>
            <select class="input" id="year" name="year" required>
              <option value="">Select</option>
              <c:forEach var="y" begin="1" end="5">
                <option value="${y}" ${param.year == y ? 'selected' : ''}>Year ${y}</option>
              </c:forEach>
            </select>
          </div>
        </div>

        <div class="row">
          <div class="field">
            <label for="password">Password *</label>
            <input class="input" type="password" id="password" name="password" minlength="6" autocomplete="new-password" required>
          </div>
          <div class="field">
            <label for="confirmPassword">Confirm password *</label>
            <input class="input" type="password" id="confirmPassword" name="confirmPassword" minlength="6" autocomplete="new-password" required>
          </div>
        </div>

        <button class="btn btn-block mt-1" type="submit">Create account <i class="ti ti-arrow-right"></i></button>
      </form>

      <p class="mt-2 muted">Already registered? <a href="${ctx}/login">Sign in</a></p>
    </div>
  </section>
</div>
<script src="${ctx}/assets/js/app.js"></script>
</body>
</html>
