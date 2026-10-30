<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Reports" />
<c:set var="eyebrow" value="Occupancy, fees and waitlist" />
<c:set var="nav" value="reports" />
<c:set var="topActions">
  <button type="button" class="btn btn-ghost" onclick="window.print()"><i class="ti ti-printer"></i>Print / Save PDF</button>
</c:set>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<p class="print-only muted">Generated on <fmt:formatDate value="${generatedOn}" pattern="dd MMM yyyy, hh:mm a" /></p>

<div class="stats">
  <div class="stat">
    <div class="icon"><i class="ti ti-bed"></i></div>
    <div class="value">${stats.occupiedBeds}<span class="muted" style="font-size:16px"> / ${stats.totalBeds}</span></div>
    <div class="label">Beds occupied</div>
    <div class="foot">${stats.occupancyPct}% occupancy</div>
  </div>
  <div class="stat">
    <div class="icon blue"><i class="ti ti-users"></i></div>
    <div class="value">${stats.totalStudents}</div>
    <div class="label">Registered students</div>
  </div>
  <div class="stat">
    <div class="icon"><i class="ti ti-currency-rupee"></i></div>
    <div class="value"><fmt:formatNumber value="${stats.feeCollected}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
    <div class="label">Fee collected</div>
  </div>
  <div class="stat">
    <div class="icon red"><i class="ti ti-alert-triangle"></i></div>
    <div class="value"><fmt:formatNumber value="${stats.feeDue}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
    <div class="label">Fee pending</div>
  </div>
</div>

<div class="grid grid-2">
  <div class="card">
    <div class="card-head"><div><h2>Block-wise occupancy</h2><p>From view <span class="mono">v_block_occupancy</span></p></div></div>
    <div class="table-wrap">
      <table class="table">
        <thead><tr><th>Block</th><th>Rooms</th><th>Beds</th><th>Occupied</th><th style="width:30%">Usage</th></tr></thead>
        <tbody>
          <c:forEach var="b" items="${blocks}">
            <tr>
              <td><strong><c:out value="${b.blockName}" /></strong><div class="small muted">${b.genderLabel}</div></td>
              <td>${b.totalRooms}</td>
              <td>${b.totalBeds}</td>
              <td>${b.occupiedBeds}</td>
              <td>
                <div class="progress ${b.occupancyPct >= 100 ? 'full' : (b.occupancyPct >= 80 ? 'warn' : '')}"><span style="width:${b.occupancyPct}%"></span></div>
                <div class="small muted mt-1">${b.occupancyPct}%</div>
              </td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <div class="card">
    <div class="card-head"><div><h2>Room types</h2><p>Fee from <span class="mono">hostel_pkg.calc_fee()</span></p></div></div>
    <div class="table-wrap">
      <table class="table">
        <thead><tr><th>Type</th><th>Rooms</th><th>Beds</th><th>Free</th><th>Fee / sem</th><th style="width:24%">Usage</th></tr></thead>
        <tbody>
          <c:forEach var="t" items="${types}">
            <tr>
              <td><span class="badge badge-${fn:toLowerCase(t.type)}">${fn:toLowerCase(t.type)}</span></td>
              <td>${t.rooms}</td>
              <td>${t.beds}</td>
              <td>${t.free}</td>
              <td class="nowrap"><fmt:formatNumber value="${t.fee}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></td>
              <td><div class="progress ${t.pct >= 100 ? 'full' : (t.pct >= 80 ? 'warn' : '')}"><span style="width:${t.pct}%"></span></div></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <div class="card">
    <div class="card-head"><div><h2>Fee collection by block</h2><p>Current residents only</p></div></div>
    <div class="table-wrap">
      <table class="table">
        <thead><tr><th>Block</th><th>Residents</th><th class="right">Billed</th><th class="right">Collected</th><th class="right">Pending</th></tr></thead>
        <tbody>
          <c:forEach var="f" items="${fees}">
            <tr>
              <td><strong><c:out value="${f.block}" /></strong><div class="small muted">${f.pct}% collected</div></td>
              <td>${f.residents}</td>
              <td class="right nowrap"><fmt:formatNumber value="${f.billed}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></td>
              <td class="right nowrap"><fmt:formatNumber value="${f.collected}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></td>
              <td class="right nowrap"><strong><fmt:formatNumber value="${f.pending}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></strong></td>
            </tr>
          </c:forEach>
        </tbody>
      </table>
    </div>
  </div>

  <div class="card">
    <div class="card-head"><div><h2>Waitlist</h2><p>In allocation priority order (senior year first, then date)</p></div></div>
    <c:choose>
      <c:when test="${empty waitlist}">
        <div class="empty"><i class="ti ti-list-check"></i><strong>Waitlist is empty</strong>Everyone who applied has a bed or a decision.</div>
      </c:when>
      <c:otherwise>
        <div class="table-wrap">
          <table class="table">
            <thead><tr><th>#</th><th>Student</th><th>Wants</th><th>Since</th></tr></thead>
            <tbody>
              <c:forEach var="w" items="${waitlist}" varStatus="st">
                <tr>
                  <td><strong>${st.count}</strong></td>
                  <td><c:out value="${w.studentName}" /><div class="small muted"><c:out value="${w.rollNo}" /> · Year ${w.yearOfStudy}</div></td>
                  <td><span class="badge badge-${fn:toLowerCase(w.preferredType)}">${fn:toLowerCase(w.preferredType)}</span></td>
                  <td class="small nowrap"><fmt:formatDate value="${w.appliedOn}" pattern="dd MMM yyyy" /></td>
                </tr>
              </c:forEach>
            </tbody>
          </table>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
