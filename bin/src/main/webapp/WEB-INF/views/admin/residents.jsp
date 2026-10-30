<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Residents" />
<c:set var="eyebrow" value="${fn:length(residents)} students currently living in the hostel" />
<c:set var="nav" value="residents" />
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<div class="card">
  <div class="card-head">
    <div><h2>Active allocations</h2><p>Vacating frees the bed and gives it to the next waitlisted student.</p></div>
    <div class="search">
      <i class="ti ti-search"></i>
      <input class="input" type="search" placeholder="Search name, room, block..." data-filter="#resTable">
    </div>
  </div>
  <c:choose>
    <c:when test="${empty residents}">
      <div class="empty"><i class="ti ti-users"></i><strong>No residents yet</strong>Allocate rooms from the Applications page.</div>
    </c:when>
    <c:otherwise>
      <div class="table-wrap">
        <table class="table" id="resTable">
          <thead><tr><th>Student</th><th>Room</th><th>Course</th><th>Allotted</th><th>Fee</th><th class="right"></th></tr></thead>
          <tbody>
            <c:forEach var="r" items="${residents}">
              <tr>
                <td>
                  <div class="person">
                    <span class="avatar">${fn:substring(r.studentName, 0, 1)}</span>
                    <div><strong><c:out value="${r.studentName}" /></strong><span><c:out value="${r.rollNo}" /> · <c:out value="${r.phone}" /></span></div>
                  </div>
                </td>
                <td class="nowrap">
                  <strong><c:out value="${r.roomNo}" /></strong> <span class="muted">· <c:out value="${r.blockName}" /></span>
                  <div><span class="badge badge-${fn:toLowerCase(r.roomType)}">${fn:toLowerCase(r.roomType)}</span></div>
                </td>
                <td class="small"><c:out value="${r.course}" /><div class="muted">Year ${r.yearOfStudy}</div></td>
                <td class="small nowrap"><fmt:formatDate value="${r.allocDate}" pattern="dd MMM yyyy" /></td>
                <td class="nowrap">
                  <c:choose>
                    <c:when test="${r.feeCleared}"><span class="badge badge-paid">paid</span></c:when>
                    <c:otherwise>
                      <span class="badge badge-due">due</span>
                      <div class="small muted mt-1"><fmt:formatNumber value="${r.feeDue}" type="currency" currencySymbol="₹" maxFractionDigits="0" /> pending</div>
                    </c:otherwise>
                  </c:choose>
                </td>
                <td class="right">
                  <form method="post" action="${ctx}/admin/residents" class="inline-form"
                        data-confirm="Vacate ${fn:escapeXml(r.studentName)} from room ${r.roomNo}? This cannot be undone.">
                    <input type="hidden" name="action" value="vacate">
                    <input type="hidden" name="studentId" value="${r.studentId}">
                    <button class="btn btn-danger btn-sm" type="submit"><i class="ti ti-door-exit"></i>Vacate</button>
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

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
