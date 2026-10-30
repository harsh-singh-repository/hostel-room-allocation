<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<!DOCTYPE html>
<html lang="en">
<head>
<%@ include file="/WEB-INF/views/common/head.jspf" %>
<title>Page not found · Hostel Room Allocation</title>
</head>
<body>
<div class="center-page">
  <div>
    <div class="code">404</div>
    <h2 class="mt-1">This room doesn't exist</h2>
    <p class="muted mt-1">The page you were looking for isn't here.</p>
    <a class="btn mt-2" href="${ctx}/login"><i class="ti ti-home"></i>Back to home</a>
  </div>
</div>
</body>
</html>
