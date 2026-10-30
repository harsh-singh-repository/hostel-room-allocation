<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Hi ${sessionScope.user.firstName}, here's your hostel" />
<c:set var="eyebrow" value="My Hostel" />
<c:set var="nav" value="dashboard" />
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<%-- progress steps --%>
<c:set var="s2" value="${not empty application}" />
<c:set var="s3" value="${not empty allocation}" />
<c:set var="s4" value="${not empty allocation and allocation.feeCleared}" />

<div class="card mb-2">
  <div class="card-body">
    <div class="timeline">
      <div class="step done"><span class="dot"><i class="ti ti-check"></i></span>Registered</div>
      <div class="step ${s2 ? 'done' : 'now'}"><span class="dot"><i class="ti ${s2 ? 'ti-check' : 'ti-file-plus'}"></i></span>Applied</div>
      <div class="step ${s3 ? 'done' : (s2 ? 'now' : '')}"><span class="dot"><i class="ti ${s3 ? 'ti-check' : 'ti-bed'}"></i></span>Room allotted</div>
      <div class="step ${s4 ? 'done' : (s3 ? 'now' : '')}"><span class="dot"><i class="ti ${s4 ? 'ti-check' : 'ti-currency-rupee'}"></i></span>Fee cleared</div>
    </div>
  </div>
</div>

<div class="grid grid-main">
  <div class="grid">

    <c:choose>
      <%-- ===== has a room ===== --%>
      <c:when test="${not empty allocation}">
        <div class="room-hero">
          <div class="label">Your room</div>
          <div class="room-no"><c:out value="${allocation.roomNo}" /><small><c:out value="${allocation.blockName}" /></small></div>
          <div class="meta">
            <div><span>Type</span><strong>${fn:toLowerCase(allocation.roomType)} sharing</strong></div>
            <div><span>Floor</span><strong>${allocation.floorNo}</strong></div>
            <div><span>Allotted on</span><strong><fmt:formatDate value="${allocation.allocDate}" pattern="dd MMM yyyy" /></strong></div>
            <div><span>Allocation ID</span><strong>#${allocation.allocId}</strong></div>
          </div>
        </div>

        <div class="card">
          <div class="card-head">
            <div><h2>Roommates</h2><p>Students sharing room ${allocation.roomNo}</p></div>
          </div>
          <c:choose>
            <c:when test="${empty roommates}">
              <div class="empty">
                <i class="ti ti-user-question"></i>
                <strong>${allocation.roomType == 'SINGLE' ? 'Single room - all yours' : 'No roommates yet'}</strong>
                ${allocation.roomType == 'SINGLE' ? 'Enjoy the quiet.' : 'New residents will appear here when they are allotted.'}
              </div>
            </c:when>
            <c:otherwise>
              <ul class="list">
                <c:forEach var="r" items="${roommates}">
                  <li>
                    <span class="avatar"><c:out value="${r.initials}" /></span>
                    <div class="grow">
                      <strong><c:out value="${r.fullName}" /></strong>
                      <div class="small muted"><c:out value="${r.course}" /> · Year ${r.yearOfStudy}</div>
                    </div>
                    <span class="small muted"><c:out value="${r.rollNo}" /></span>
                  </li>
                </c:forEach>
              </ul>
            </c:otherwise>
          </c:choose>
        </div>
      </c:when>

      <%-- ===== open application ===== --%>
      <c:when test="${not empty application and application.open}">
        <div class="card">
          <div class="card-head">
            <div><h2>Application #${application.appId}</h2><p>Submitted <fmt:formatDate value="${application.appliedOn}" pattern="dd MMM yyyy" /></p></div>
            <span class="badge badge-${fn:toLowerCase(application.status)}">${fn:toLowerCase(application.status)}</span>
          </div>
          <div class="card-body">
            <dl class="kv">
              <dt>Room type</dt><dd>${fn:toLowerCase(application.preferredType)}</dd>
              <dt>Preferred block</dt><dd><c:out value="${empty application.preferredBlockName ? 'Any block' : application.preferredBlockName}" /></dd>
              <c:if test="${not empty application.remarks}"><dt>Remarks</dt><dd><c:out value="${application.remarks}" /></dd></c:if>
            </dl>
            <div class="alert ${application.status == 'WAITLISTED' ? 'alert-warn' : 'alert-info'} mt-2" style="margin-bottom:0">
              <i class="ti ${application.status == 'WAITLISTED' ? 'ti-hourglass' : 'ti-clock'}"></i>
              <span>
                <c:choose>
                  <c:when test="${application.status == 'WAITLISTED'}">No matching bed is free right now. You'll get the next one that opens up.</c:when>
                  <c:otherwise>The warden is reviewing your application. Check back soon.</c:otherwise>
                </c:choose>
              </span>
            </div>
          </div>
        </div>
      </c:when>

      <%-- ===== nothing yet / closed application ===== --%>
      <c:otherwise>
        <div class="card">
          <div class="empty" style="padding:56px 24px">
            <i class="ti ti-bed"></i>
            <strong>You don't have a room yet</strong>
            <p>
              <c:if test="${not empty application}">
                Your last application was <b>${fn:toLowerCase(application.status)}</b><c:if test="${not empty application.remarks}"> - <c:out value="${application.remarks}" /></c:if>.
              </c:if>
              Apply now and the system will allot the best available bed.
            </p>
            <a class="btn mt-1" href="${ctx}/student/apply"><i class="ti ti-file-plus"></i>Apply for a room</a>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>

  <div class="grid" style="align-content:start">
    <c:if test="${not empty allocation}">
      <div class="card">
        <div class="card-head">
          <div><h2>Hostel fee</h2><p>Per semester</p></div>
          <span class="badge ${allocation.feeCleared ? 'badge-paid' : 'badge-due'}">${allocation.feeCleared ? 'paid' : 'due'}</span>
        </div>
        <div class="card-body">
          <div class="small muted">Paid <fmt:formatNumber value="${allocation.feePaid}" type="currency" currencySymbol="₹" maxFractionDigits="0" />
            of <fmt:formatNumber value="${allocation.feeTotal}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></div>
          <div class="progress mt-1"><span style="width:${allocation.paidPct}%"></span></div>
          <c:if test="${not allocation.feeCleared}">
            <p class="mt-2" style="margin-bottom:12px">Pending: <strong><fmt:formatNumber value="${allocation.feeDue}" type="currency" currencySymbol="₹" maxFractionDigits="0" /></strong></p>
            <a class="btn btn-block" href="${ctx}/student/fees"><i class="ti ti-credit-card"></i>Pay fee</a>
          </c:if>
        </div>
      </div>
    </c:if>

    <div class="card">
      <div class="card-head"><h2>Profile</h2></div>
      <div class="card-body">
        <div class="person mb-2">
          <span class="avatar lg"><c:out value="${me.initials}" /></span>
          <div><strong><c:out value="${me.fullName}" /></strong><span><c:out value="${me.email}" /></span></div>
        </div>
        <dl class="kv">
          <dt>Roll no.</dt><dd><c:out value="${me.rollNo}" /></dd>
          <dt>Course</dt><dd><c:out value="${me.course}" /></dd>
          <dt>Year</dt><dd>${me.yearOfStudy}</dd>
          <dt>Gender</dt><dd>${me.genderLabel}</dd>
          <dt>Phone</dt><dd><c:out value="${empty me.phone ? '-' : me.phone}" /></dd>
        </dl>
      </div>
    </div>

    <c:if test="${not empty requests}">
      <c:set var="lr" value="${requests[0]}" />
      <div class="card">
        <div class="card-head">
          <div><h2>Latest request</h2><p>#${lr.reqId} · <fmt:formatDate value="${lr.createdAt}" pattern="dd MMM" /></p></div>
          <span class="badge badge-${fn:toLowerCase(lr.status)}">${fn:toLowerCase(lr.status)}</span>
        </div>
        <div class="card-body">
          <strong>${lr.reqType == 'VACATE' ? 'Vacate room' : 'Change to ' += fn:toLowerCase(lr.newType) += ' room'}</strong>
          <p class="small muted mt-1"><c:out value="${lr.reason}" /></p>
          <a class="small" href="${ctx}/student/requests">View all requests →</a>
        </div>
      </div>
    </c:if>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
