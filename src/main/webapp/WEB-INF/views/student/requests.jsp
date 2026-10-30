<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Vacate or change room" />
<c:set var="eyebrow" value="Requests" />
<c:set var="nav" value="requests" />
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<div class="grid grid-main">
  <div class="card">
    <div class="card-head"><div><h2>My requests</h2><p>The warden approves or rejects each request.</p></div></div>
    <c:choose>
      <c:when test="${empty requests}">
        <div class="empty"><i class="ti ti-inbox"></i><strong>No requests yet</strong>Requests you raise will show up here.</div>
      </c:when>
      <c:otherwise>
        <div class="table-wrap">
          <table class="table">
            <thead><tr><th>#</th><th>Request</th><th>Reason</th><th>Status</th><th>Warden note</th></tr></thead>
            <tbody>
              <c:forEach var="r" items="${requests}">
                <tr>
                  <td class="muted">${r.reqId}</td>
                  <td class="nowrap">
                    <strong>${r.reqType == 'VACATE' ? 'Vacate' : 'Change room'}</strong>
                    <c:if test="${r.reqType == 'CHANGE'}"><div class="small muted">to ${fn:toLowerCase(r.newType)}</div></c:if>
                    <div class="small muted"><fmt:formatDate value="${r.createdAt}" pattern="dd MMM yyyy" /></div>
                  </td>
                  <td><c:out value="${r.reason}" /></td>
                  <td><span class="badge badge-${fn:toLowerCase(r.status)}">${fn:toLowerCase(r.status)}</span></td>
                  <td class="small"><c:out value="${empty r.adminNote ? '-' : r.adminNote}" /></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <c:choose>
    <c:when test="${empty allocation}">
      <div class="card" style="align-self:start">
        <div class="empty"><i class="ti ti-door-off"></i><strong>No room allotted</strong>You can raise requests once you have a room.</div>
      </div>
    </c:when>
    <c:otherwise>
      <form class="card" method="post" action="${ctx}/student/requests" style="align-self:start">
        <div class="card-head">
          <div><h2>New request</h2><p>Current room: <c:out value="${allocation.roomNo}" />, <c:out value="${allocation.blockName}" /> (${fn:toLowerCase(allocation.roomType)})</p></div>
        </div>
        <div class="card-body">
          <div class="field">
            <label for="reqType">I want to</label>
            <select class="input" id="reqType" name="reqType" data-toggle-target="#newTypeField" data-toggle-value="CHANGE" required>
              <option value="CHANGE">Change my room</option>
              <option value="VACATE">Vacate the hostel</option>
            </select>
          </div>
          <div class="field" id="newTypeField">
            <label for="newType">New room type</label>
            <select class="input" id="newType" name="newType">
              <option value="">Select</option>
              <option value="SINGLE">Single</option>
              <option value="DOUBLE">Double</option>
              <option value="TRIPLE">Triple</option>
            </select>
            <div class="hint">You will stay in the same block if a bed is free there.</div>
          </div>
          <div class="field">
            <label for="reason">Reason</label>
            <textarea class="input" id="reason" name="reason" maxlength="300" required
                      placeholder="A short note for the warden"></textarea>
          </div>
          <button class="btn btn-block" type="submit"><i class="ti ti-send"></i>Send request</button>
        </div>
      </form>
    </c:otherwise>
  </c:choose>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
