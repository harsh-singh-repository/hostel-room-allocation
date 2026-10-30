<%@ page isErrorPage="true" %>
<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/common/head.jspf" %>
<title>Something went wrong · Hostel Room Allocation</title>
</head>
<body>
<div class="center-page">
  <div class="card" style="max-width:520px;width:100%">
    <div class="card-body" style="padding:36px">
      <div class="stat" style="border:0;box-shadow:none;padding:0">
        <div class="icon red" style="margin:0 auto 16px"><i class="ti ti-database-x"></i></div>
      </div>
      <h2>Something went wrong</h2>
      <p class="muted mt-1">
        <c:out value="${empty errorMessage ? 'An unexpected error occurred while loading this page.' : errorMessage}" />
      </p>
      <div class="actions mt-2" style="justify-content:center">
        <a class="btn btn-ghost" href="javascript:history.back()"><i class="ti ti-arrow-left"></i>Go back</a>
        <a class="btn" href="${ctx}/login"><i class="ti ti-home"></i>Home</a>
      </div>
    </div>
  </div>
</div>
</body>
</html>
