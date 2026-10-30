<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Vacate & change requests" />
<c:set var="eyebrow" value="Allocation" />
<c:set var="nav" value="requests" />
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<nav class="tabs">
  <a href="${ctx}/admin/requests" class="${empty status ? 'active' : ''}">All</a>
  <a href="${ctx}/admin/requests?status=PENDING" class="${status == 'PENDING' ? 'active' : ''}">Pending</a>
  <a href="${ctx}/admin/requests?status=APPROVED" class="${status == 'APPROVED' ? 'active' : ''}">Approved</a>
  <a href="${ctx}/admin/requests?status=REJECTED" class="${status == 'REJECTED' ? 'active' : ''}">Rejected</a>
</nav>

<div class="card">
  <c:choose>
    <c:when test="${empty requests}">
      <div class="empty"><i class="ti ti-inbox"></i><strong>No requests</strong>Nothing to review here.</div>
    </c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table">
          <thead><tr><th>#</th><th>Student</th><th>Request</th><th>Reason</th><th>Status</th><th class="right">Decision</th></tr></thead>
          <tbody>
            <c:forEach var="q" items="${requests}">
              <tr>
                <td class="muted">${q.reqId}</td>
                <td>
                  <div class="person">
                    <span class="avatar">${fn:substring(q.studentName, 0, 1)}</span>
                    <div><strong><c:out value="${q.studentName}" /></strong>
                      <span><c:out value="${empty q.currentRoom ? 'No active room' : q.currentRoom}" /></span></div>
                  </div>
                </td>
                <td class="nowrap">
                  <c:choose>
                    <c:when test="${q.reqType == 'VACATE'}"><strong><i class="ti ti-door-exit"></i> Vacate</strong></c:when>
                    <c:otherwise><strong><i class="ti ti-arrows-exchange"></i> Change</strong>
                      <div class="small muted">to ${fn:toLowerCase(q.newType)} room</div></c:otherwise>
                  </c:choose>
                  <div class="small muted"><fmt:formatDate value="${q.createdAt}" pattern="dd MMM yyyy" /></div>
                </td>
                <td style="max-width:280px"><c:out value="${q.reason}" /></td>
                <td>
                  <span class="badge badge-${fn:toLowerCase(q.status)}">${fn:toLowerCase(q.status)}</span>
                  <c:if test="${not empty q.adminNote}"><div class="small muted mt-1"><c:out value="${q.adminNote}" /></div></c:if>
                </td>
                <td class="right">
                  <c:if test="${q.status == 'PENDING'}">
                    <form method="post" action="${ctx}/admin/requests" class="actions" style="justify-content:flex-end">
                      <input type="hidden" name="reqId" value="${q.reqId}">
                      <input class="input input-sm" name="note" placeholder="Note (optional)" maxlength="200" style="width:150px">
                      <button class="btn btn-soft btn-sm" type="submit" name="decision" value="approve"
                              data-confirm="${q.reqType == 'VACATE' ? 'Approve and vacate this student now?' : 'Approve and move this student to a new room?'}">
                        <i class="ti ti-check"></i>Approve</button>
                      <button class="btn btn-danger btn-sm" type="submit" name="decision" value="reject"><i class="ti ti-x"></i>Reject</button>
                    </form>
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

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
