<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Room application" />
<c:set var="eyebrow" value="Apply for hostel accommodation" />
<c:set var="nav" value="apply" />
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<div class="grid grid-main">
  <div>
    <c:choose>
      <c:when test="${not empty allocation}">
        <div class="card">
          <div class="empty" style="padding:48px 24px">
            <i class="ti ti-circle-check" style="color:var(--brand)"></i>
            <strong>You already have room <c:out value="${allocation.roomNo}" />, <c:out value="${allocation.blockName}" /></strong>
            Want a different room? Raise a room-change request instead.
            <div class="mt-2"><a class="btn btn-ghost" href="${ctx}/student/requests"><i class="ti ti-arrows-exchange"></i>Request a change</a></div>
          </div>
        </div>
      </c:when>

      <c:when test="${not empty latest and latest.open}">
        <div class="card">
          <div class="card-head">
            <div><h2>Application #${latest.appId} is ${fn:toLowerCase(latest.status)}</h2>
              <p>You can have one open application at a time.</p></div>
            <span class="badge badge-${fn:toLowerCase(latest.status)}">${fn:toLowerCase(latest.status)}</span>
          </div>
          <div class="card-body">
            <dl class="kv">
              <dt>Room type</dt><dd>${fn:toLowerCase(latest.preferredType)}</dd>
              <dt>Preferred block</dt><dd><c:out value="${empty latest.preferredBlockName ? 'Any block' : latest.preferredBlockName}" /></dd>
              <dt>Submitted</dt><dd><fmt:formatDate value="${latest.appliedOn}" pattern="dd MMM yyyy, hh:mm a" /></dd>
              <c:if test="${not empty latest.remarks}"><dt>Remarks</dt><dd><c:out value="${latest.remarks}" /></dd></c:if>
            </dl>
            <form method="post" action="${ctx}/student/apply" class="mt-2" data-confirm="Cancel this application?">
              <input type="hidden" name="action" value="cancel">
              <input type="hidden" name="appId" value="${latest.appId}">
              <button class="btn btn-danger" type="submit"><i class="ti ti-x"></i>Cancel application</button>
            </form>
          </div>
        </div>
      </c:when>

      <c:otherwise>
        <form class="card" method="post" action="${ctx}/student/apply">
          <div class="card-head">
            <div><h2>New application</h2><p>Pick a room type and, optionally, a block you prefer.</p></div>
          </div>
          <div class="card-body">
            <div class="field">
              <label>Room type *</label>
              <div class="type-cards">
                <label class="type-card">
                  <input type="radio" name="roomType" value="SINGLE" required>
                  <div class="tc">
                    <div class="tc-beds"><span></span></div>
                    <strong>Single</strong>
                    <div class="small muted">Private room, 1 bed</div>
                    <div class="price">₹45,000 <small>/ sem</small></div>
                  </div>
                </label>
                <label class="type-card">
                  <input type="radio" name="roomType" value="DOUBLE" checked>
                  <div class="tc">
                    <div class="tc-beds"><span></span><span></span></div>
                    <strong>Double</strong>
                    <div class="small muted">Shared by 2 students</div>
                    <div class="price">₹35,000 <small>/ sem</small></div>
                  </div>
                </label>
                <label class="type-card">
                  <input type="radio" name="roomType" value="TRIPLE">
                  <div class="tc">
                    <div class="tc-beds"><span></span><span></span><span></span></div>
                    <strong>Triple</strong>
                    <div class="small muted">Shared by 3 students</div>
                    <div class="price">₹28,000 <small>/ sem</small></div>
                  </div>
                </label>
              </div>
            </div>

            <div class="field">
              <label for="blockId">Preferred block</label>
              <select class="input" id="blockId" name="blockId">
                <option value="">Any ${me.gender == 'F' ? 'girls' : 'boys'} block (fastest)</option>
                <c:forEach var="b" items="${blocks}">
                  <option value="${b.blockId}"><c:out value="${b.blockName}" /> - ${b.freeBeds} beds free</option>
                </c:forEach>
              </select>
              <div class="hint">If your preferred block is full, the system will look in other ${me.gender == 'F' ? 'girls' : 'boys'} blocks.</div>
            </div>

            <button class="btn" type="submit"><i class="ti ti-send"></i>Submit application</button>
          </div>
        </form>
      </c:otherwise>
    </c:choose>
  </div>

  <div class="grid" style="align-content:start">
    <div class="card">
      <div class="card-head"><h2>How allocation works</h2></div>
      <ul class="list">
        <li><span class="feed"><span class="ic"><i class="ti ti-number-1"></i></span></span><div class="grow small">You apply with a room type and block preference.</div></li>
        <li><span class="feed"><span class="ic"><i class="ti ti-number-2"></i></span></span><div class="grow small">The warden runs the allocation. Senior years go first, then first-come-first-served.</div></li>
        <li><span class="feed"><span class="ic"><i class="ti ti-number-3"></i></span></span><div class="grow small">A free bed is allotted, or you join the waitlist.</div></li>
        <li><span class="feed"><span class="ic"><i class="ti ti-number-4"></i></span></span><div class="grow small">When someone vacates, the first waitlisted student gets the bed automatically.</div></li>
      </ul>
    </div>

    <div class="card">
      <div class="card-head"><h2>Application history</h2></div>
      <c:choose>
        <c:when test="${empty applications}">
          <div class="empty"><i class="ti ti-file-off"></i>No applications yet</div>
        </c:when>
        <c:otherwise>
          <ul class="list">
            <c:forEach var="a" items="${applications}">
              <li>
                <div class="grow">
                  <strong>#${a.appId} · ${fn:toLowerCase(a.preferredType)}</strong>
                  <div class="small muted"><fmt:formatDate value="${a.appliedOn}" pattern="dd MMM yyyy" /></div>
                </div>
                <span class="badge badge-${fn:toLowerCase(a.status)}">${fn:toLowerCase(a.status)}</span>
              </li>
            </c:forEach>
          </ul>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
