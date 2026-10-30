<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Applications" />
<c:set var="eyebrow" value="Allocation" />
<c:set var="nav" value="applications" />
<c:set var="topActions">
  <form method="post" action="${ctx}/admin/applications" class="inline-form"
        data-confirm="Run automatic allocation for all pending and waitlisted applications?">
    <input type="hidden" name="action" value="auto">
    <input type="hidden" name="back" value="${status}">
    <button class="btn" type="submit"><i class="ti ti-bolt"></i>Auto-allocate all</button>
  </form>
</c:set>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<c:set var="total" value="0" />
<c:forEach var="e" items="${counts}"><c:set var="total" value="${total + e.value}" /></c:forEach>

<div class="toolbar mb-2">
  <nav class="tabs" style="margin:0">
    <a href="${ctx}/admin/applications" class="${empty status ? 'active' : ''}">All <span class="n">${total}</span></a>
    <c:forEach var="e" items="${counts}">
      <a href="${ctx}/admin/applications?status=${e.key}" class="${status == e.key ? 'active' : ''}">
        ${fn:substring(e.key, 0, 1)}${fn:toLowerCase(fn:substring(e.key, 1, 20))} <span class="n">${e.value}</span>
      </a>
    </c:forEach>
  </nav>
  <div class="search">
    <i class="ti ti-search"></i>
    <input class="input" type="search" placeholder="Search student, roll no..." data-filter="#appTable">
  </div>
</div>

<div class="card">
  <c:choose>
    <c:when test="${empty applications}">
      <div class="empty"><i class="ti ti-folder-open"></i><strong>No applications here</strong>Try another filter.</div>
    </c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table" id="appTable">
          <thead>
            <tr><th>#</th><th>Student</th><th>Room type</th><th>Preferred block</th><th>Applied</th><th>Status</th><th>Remarks</th><th class="right">Actions</th></tr>
          </thead>
          <tbody>
            <c:forEach var="a" items="${applications}">
              <tr>
                <td class="muted">${a.appId}</td>
                <td>
                  <div class="person">
                    <span class="avatar">${fn:substring(a.studentName, 0, 1)}</span>
                    <div><strong><c:out value="${a.studentName}" /></strong>
                      <span><c:out value="${a.rollNo}" /> · Yr ${a.yearOfStudy} · ${a.gender == 'F' ? 'F' : 'M'}</span></div>
                  </div>
                </td>
                <td><span class="badge badge-${fn:toLowerCase(a.preferredType)}">${fn:toLowerCase(a.preferredType)}</span></td>
                <td><c:out value="${empty a.preferredBlockName ? 'Any' : a.preferredBlockName}" /></td>
                <td class="nowrap small"><fmt:formatDate value="${a.appliedOn}" pattern="dd MMM yyyy" /></td>
                <td><span class="badge badge-${fn:toLowerCase(a.status)}">${fn:toLowerCase(a.status)}</span></td>
                <td class="small muted" style="max-width:220px"><c:out value="${a.remarks}" /></td>
                <td class="right">
                  <c:if test="${a.open}">
                    <div class="actions" style="justify-content:flex-end">
                      <form method="post" action="${ctx}/admin/applications" class="inline-form">
                        <input type="hidden" name="action" value="allocate">
                        <input type="hidden" name="appId" value="${a.appId}">
                        <input type="hidden" name="back" value="${status}">
                        <button class="btn btn-soft btn-sm" type="submit"><i class="ti ti-bed"></i>Allocate</button>
                      </form>
                      <button type="button" class="btn btn-danger btn-sm" data-open="rejectDialog"
                              data-fill-app-id="${a.appId}" data-fill-student="${fn:escapeXml(a.studentName)}">
                        <i class="ti ti-x"></i>Reject
                      </button>
                    </div>
                  </c:if>
                </td>
              </tr>
            </c:forEach>
          </tbody>
        </table>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<dialog class="modal" id="rejectDialog">
  <form method="post" action="${ctx}/admin/applications">
    <div class="modal-head"><h2>Reject application</h2><button type="button" data-close aria-label="Close"><i class="ti ti-x"></i></button></div>
    <div class="modal-body">
      <p>Rejecting the application of <strong data-label="student"></strong>.</p>
      <input type="hidden" name="action" value="reject">
      <input type="hidden" name="appId">
      <input type="hidden" name="back" value="${status}">
      <div class="field">
        <label for="remarks">Reason (shown to the student)</label>
        <textarea class="input" id="remarks" name="remarks" maxlength="200" placeholder="e.g. Local resident - not eligible"></textarea>
      </div>
    </div>
    <div class="modal-foot">
      <button type="button" class="btn btn-ghost" data-close>Cancel</button>
      <button type="submit" class="btn btn-danger">Reject</button>
    </div>
  </form>
</dialog>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
