<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Hostel fees" />
<c:set var="eyebrow" value="Payments" />
<c:set var="nav" value="fees" />
<c:set var="topActions">
  <c:if test="${not empty payments}">
    <button type="button" class="btn btn-ghost" onclick="window.print()"><i class="ti ti-printer"></i>Print statement</button>
  </c:if>
</c:set>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<c:choose>
  <c:when test="${empty allocation}">
    <div class="card">
      <div class="empty" style="padding:56px 24px">
        <i class="ti ti-receipt-off"></i>
        <strong>No fee due yet</strong>
        Fees are generated once a room is allotted to you.
        <div class="mt-2"><a class="btn" href="${ctx}/student/apply">Go to room application</a></div>
      </div>
    </div>
  </c:when>
  <c:otherwise>
    <div class="print-only mb-2">
      <h2>Fee statement</h2>
      <p><c:out value="${me.fullName}" /> (<c:out value="${me.rollNo}" />) · Room <c:out value="${allocation.roomNo}" />, <c:out value="${allocation.blockName}" /></p>
    </div>

    <div class="stats" style="grid-template-columns:repeat(3,minmax(0,1fr))">
      <div class="stat">
        <div class="icon blue"><i class="ti ti-file-invoice"></i></div>
        <div class="value"><fmt:formatNumber value="${allocation.feeTotal}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
        <div class="label">Semester fee</div>
        <div class="foot">${fn:toLowerCase(allocation.roomType)} room · <c:out value="${allocation.blockName}" /></div>
      </div>
      <div class="stat">
        <div class="icon"><i class="ti ti-circle-check"></i></div>
        <div class="value"><fmt:formatNumber value="${allocation.feePaid}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
        <div class="label">Paid</div>
        <div class="progress mt-1"><span style="width:${allocation.paidPct}%"></span></div>
      </div>
      <div class="stat ${allocation.feeCleared ? '' : 'hero'}">
        <div class="icon ${allocation.feeCleared ? '' : 'red'}"><i class="ti ${allocation.feeCleared ? 'ti-mood-happy' : 'ti-alert-triangle'}"></i></div>
        <div class="value"><fmt:formatNumber value="${allocation.feeDue}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
        <div class="label">Pending</div>
        <div class="foot">${allocation.feeCleared ? 'All clear for this semester' : 'Pay before the semester starts'}</div>
      </div>
    </div>

    <div class="grid grid-main">
      <div class="card">
        <div class="card-head"><div><h2>Payment history</h2><p>Every payment is logged by a database trigger.</p></div></div>
        <c:choose>
          <c:when test="${empty payments}">
            <div class="empty"><i class="ti ti-receipt"></i><strong>No payments yet</strong></div>
          </c:when>
          <c:otherwise>
            <div class="table-wrap">
              <table class="table">
                <thead><tr><th>Reference</th><th>Date</th><th>Mode</th><th class="right">Amount</th></tr></thead>
                <tbody>
                  <c:forEach var="p" items="${payments}">
                    <tr>
                      <td class="mono"><c:out value="${p.txnRef}" /></td>
                      <td class="nowrap"><fmt:formatDate value="${p.paidOn}" pattern="dd MMM yyyy" /></td>
                      <td><span class="badge">${p.payMode}</span></td>
                      <td class="right"><strong><fmt:formatNumber value="${p.amount}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></strong></td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
          </c:otherwise>
        </c:choose>
      </div>

      <c:if test="${not allocation.feeCleared}">
        <form class="card no-print" method="post" action="${ctx}/student/fees" data-confirm="Record this payment?" style="align-self:start">
          <div class="card-head"><div><h2>Make a payment</h2><p>Demo only - no real money is charged.</p></div></div>
          <div class="card-body">
            <div class="field">
              <label for="amount">Amount (₹)</label>
              <input class="input" type="number" id="amount" name="amount" min="1" max="${allocation.feeDue}" step="1"
                     value="${allocation.feeDue}" required>
              <div class="hint">
                Partial payments are allowed.
                <a href="#" data-set-amount="${allocation.feeDue}" onclick="return false">Pay full amount</a>
              </div>
            </div>
            <div class="field">
              <label for="mode">Payment mode</label>
              <select class="input" id="mode" name="mode" required>
                <option value="UPI">UPI</option>
                <option value="CARD">Debit / Credit card</option>
                <option value="NETBANKING">Net banking</option>
                <option value="CASH">Cash at office</option>
              </select>
            </div>
            <button class="btn btn-block" type="submit"><i class="ti ti-lock"></i>Pay now</button>
          </div>
        </form>
      </c:if>
    </div>
  </c:otherwise>
</c:choose>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
