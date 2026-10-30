<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Hostel overview" />
<c:set var="eyebrow" value="Warden dashboard" />
<c:set var="nav" value="dashboard" />
<c:set var="topActions">
  <form method="post" action="${ctx}/admin/applications" class="inline-form"
        data-confirm="Run automatic allocation for all pending and waitlisted applications?">
    <input type="hidden" name="action" value="auto">
    <button class="btn" type="submit"><i class="ti ti-bolt"></i>Run auto-allocation</button>
  </form>
</c:set>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<div class="stats">
  <div class="stat hero">
    <div class="icon"><i class="ti ti-bed"></i></div>
    <div class="value">${stats.occupancyPct}%</div>
    <div class="label">Beds occupied</div>
    <div class="progress"><span style="width:${stats.occupancyPct}%"></span></div>
    <div class="foot">${stats.occupiedBeds} of ${stats.totalBeds} beds · ${stats.freeBeds} free</div>
  </div>
  <div class="stat">
    <div class="icon amber"><i class="ti ti-file-description"></i></div>
    <div class="value">${stats.pendingApplications}</div>
    <div class="label">Pending applications</div>
    <div class="foot"><a href="${ctx}/admin/applications?status=PENDING">Review now →</a></div>
  </div>
  <div class="stat">
    <div class="icon violet"><i class="ti ti-hourglass"></i></div>
    <div class="value">${stats.waitlisted}</div>
    <div class="label">On waitlist</div>
    <div class="foot">${stats.pendingRequests} open vacate / change requests</div>
  </div>
  <div class="stat">
    <div class="icon blue"><i class="ti ti-currency-rupee"></i></div>
    <div class="value"><fmt:formatNumber value="${stats.feeCollected}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
    <div class="label">Fee collected</div>
    <div class="foot"><fmt:formatNumber value="${stats.feeDue}" type="currency" currencySymbol="₹" maxFractionDigits="0" /> still pending</div>
  </div>
</div>

<div class="grid grid-main">
  <div class="grid" style="align-content:start">
    <div class="card">
      <div class="card-head">
        <div><h2>Applications waiting</h2><p>Oldest first</p></div>
        <a class="btn btn-ghost btn-sm" href="${ctx}/admin/applications">View all</a>
      </div>
      <c:choose>
        <c:when test="${empty pending}">
          <div class="empty"><i class="ti ti-mood-check"></i><strong>All caught up</strong>No pending applications.</div>
        </c:when>
        <c:otherwise>
          <div class="table-wrap">
            <table class="table">
              <thead><tr><th>Student</th><th>Wants</th><th>Status</th><th></th></tr></thead>
              <tbody>
                <c:forEach var="a" items="${pending}">
                  <tr>
                    <td>
                      <div class="person">
                        <span class="avatar">${fn:substring(a.studentName, 0, 1)}</span>
                        <div><strong><c:out value="${a.studentName}" /></strong><span><c:out value="${a.rollNo}" /> · Year ${a.yearOfStudy}</span></div>
                      </div>
                    </td>
                    <td>
                      <span class="badge badge-${fn:toLowerCase(a.preferredType)}">${fn:toLowerCase(a.preferredType)}</span>
                      <div class="small muted mt-1"><c:out value="${empty a.preferredBlockName ? 'Any block' : a.preferredBlockName}" /></div>
                    </td>
                    <td><span class="badge badge-${fn:toLowerCase(a.status)}">${fn:toLowerCase(a.status)}</span></td>
                    <td class="right">
                      <form method="post" action="${ctx}/admin/applications" class="inline-form">
                        <input type="hidden" name="action" value="allocate">
                        <input type="hidden" name="appId" value="${a.appId}">
                        <button class="btn btn-soft btn-sm" type="submit"><i class="ti ti-bed"></i>Allocate</button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="card">
      <div class="card-head">
        <div><h2>Block occupancy</h2><p>Active beds only</p></div>
        <a class="btn btn-ghost btn-sm" href="${ctx}/admin/rooms">Manage rooms</a>
      </div>
      <c:forEach var="b" items="${blocks}">
        <div class="block-row">
          <div class="top">
            <div><strong><c:out value="${b.blockName}" /></strong> <span class="small muted">· ${b.genderLabel}</span></div>
            <span class="small"><strong>${b.occupiedBeds}</strong><span class="muted"> / ${b.totalBeds} beds</span></span>
          </div>
          <div class="progress ${b.occupancyPct >= 100 ? 'full' : (b.occupancyPct >= 80 ? 'warn' : '')}"><span style="width:${b.occupancyPct}%"></span></div>
        </div>
      </c:forEach>
      <c:if test="${empty blocks}"><div class="empty">No blocks yet.</div></c:if>
    </div>
  </div>

  <div class="card" style="align-self:start">
    <div class="card-head"><div><h2>Recent activity</h2><p>From the allocation audit log</p></div></div>
    <c:choose>
      <c:when test="${empty activity}">
        <div class="empty"><i class="ti ti-history"></i>Nothing logged yet.</div>
      </c:when>
      <c:otherwise>
        <ul class="list feed">
          <c:forEach var="l" items="${activity}">
            <li>
              <span class="ic ${fn:toLowerCase(l.action)}">
                <i class="ti ${l.action == 'ALLOTTED' ? 'ti-login-2' : (l.action == 'VACATED' ? 'ti-logout-2' : 'ti-currency-rupee')}"></i>
              </span>
              <div class="grow">
                <strong><c:out value="${l.studentName}" /></strong>
                <span class="small muted">${l.action == 'ALLOTTED' ? 'moved into' : (l.action == 'VACATED' ? 'left' : 'paid fee for')} ${fn:escapeXml(l.roomLabel)}</span>
                <div class="small muted"><c:out value="${l.details}" /> · <fmt:formatDate value="${l.logTime}" pattern="dd MMM, hh:mm a" /></div>
              </div>
            </li>
          </c:forEach>
        </ul>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
