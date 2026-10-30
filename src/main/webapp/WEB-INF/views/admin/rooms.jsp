<%@ include file="/WEB-INF/views/common/taglibs.jspf" %>
<c:set var="pageTitle" value="Blocks & rooms" />
<c:set var="eyebrow" value="Hostel" />
<c:set var="nav" value="rooms" />
<c:set var="topActions">
  <button type="button" class="btn btn-ghost" data-open="blockDialog"><i class="ti ti-building-plus"></i>Add block</button>
  <c:if test="${not empty selected}">
    <button type="button" class="btn" data-open="roomDialog"><i class="ti ti-plus"></i>Add room</button>
  </c:if>
</c:set>
<%@ include file="/WEB-INF/views/common/header.jspf" %>

<c:choose>
  <c:when test="${empty blocks}">
    <div class="card"><div class="empty" style="padding:56px"><i class="ti ti-building"></i><strong>No hostel blocks yet</strong>Add your first block to start creating rooms.</div></div>
  </c:when>
  <c:otherwise>
    <div class="block-tabs">
      <c:forEach var="b" items="${blocks}">
        <a class="block-tab ${selected.blockId == b.blockId ? 'active' : ''}" href="${ctx}/admin/rooms?block=${b.blockId}">
          <div class="t">
            <strong><c:out value="${b.blockName}" /></strong>
            <span class="badge">${b.genderLabel}</span>
          </div>
          <div class="progress ${b.occupancyPct >= 100 ? 'full' : (b.occupancyPct >= 80 ? 'warn' : '')}"><span style="width:${b.occupancyPct}%"></span></div>
          <div class="s">${b.totalRooms} rooms · ${b.occupiedBeds}/${b.totalBeds} beds used</div>
        </a>
      </c:forEach>
    </div>

    <c:if test="${not empty selected}">
      <div class="card">
        <div class="card-head">
          <div>
            <h2><c:out value="${selected.blockName}" /></h2>
            <p>Warden: <c:out value="${empty selected.wardenName ? '-' : selected.wardenName}" /><c:if test="${not empty selected.description}"> · <c:out value="${selected.description}" /></c:if></p>
          </div>
          <div class="legend">
            <span><span class="sw on"></span>Occupied bed</span>
            <span><span class="sw"></span>Free bed</span>
            <span><span class="sw mt"></span>Maintenance</span>
          </div>
        </div>
        <div class="card-body">
          <c:choose>
            <c:when test="${empty rooms}">
              <div class="empty"><i class="ti ti-door"></i><strong>No rooms in this block</strong>Use "Add room" to create one.</div>
            </c:when>
            <c:otherwise>
              <c:set var="lastFloor" value="-1" />
              <c:forEach var="r" items="${rooms}" varStatus="st">
                <c:if test="${r.floorNo != lastFloor}">
                  <c:if test="${!st.first}"></div></div></c:if>
                  <div class="floor"><h3><c:choose><c:when test="${r.floorNo == 0}">Ground floor</c:when><c:otherwise>Floor ${r.floorNo}</c:otherwise></c:choose></h3><div class="room-grid">
                  <c:set var="lastFloor" value="${r.floorNo}" />
                </c:if>

                <div class="room-tile ${r.maintenance ? 'maint' : (r.full ? 'full' : '')}">
                  <form method="post" action="${ctx}/admin/rooms" class="inline-form"
                        data-confirm="${r.maintenance ? 'Mark room ' += r.roomNo += ' active again?' : 'Send room ' += r.roomNo += ' for maintenance?'}">
                    <input type="hidden" name="action" value="status">
                    <input type="hidden" name="blockId" value="${selected.blockId}">
                    <input type="hidden" name="roomId" value="${r.roomId}">
                    <input type="hidden" name="status" value="${r.maintenance ? 'ACTIVE' : 'MAINTENANCE'}">
                    <button class="tile-btn" type="submit" title="${r.maintenance ? 'Mark active' : 'Mark for maintenance'}">
                      <i class="ti ${r.maintenance ? 'ti-tool' : 'ti-settings'}"></i>
                    </button>
                  </form>
                  <div class="no"><c:out value="${r.roomNo}" /></div>
                  <div class="ty">${fn:toLowerCase(r.roomType)}</div>
                  <div class="beds">
                    <c:forEach var="on" items="${r.beds}"><span class="bed ${on ? 'on' : ''}"></span></c:forEach>
                  </div>
                  <div class="ft">
                    <span>${r.occupied}/${r.capacity}</span>
                    <c:choose>
                      <c:when test="${r.maintenance}"><span class="badge badge-maintenance">maint.</span></c:when>
                      <c:when test="${r.full}"><span class="badge badge-rejected">full</span></c:when>
                      <c:otherwise><span class="badge badge-active">${r.freeBeds} free</span></c:otherwise>
                    </c:choose>
                  </div>
                </div>

                <c:if test="${st.last}"></div></div></c:if>
              </c:forEach>
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </c:if>
  </c:otherwise>
</c:choose>

<%-- Add block --%>
<dialog class="modal" id="blockDialog">
  <form method="post" action="${ctx}/admin/rooms">
    <div class="modal-head"><h2>Add hostel block</h2><button type="button" data-close aria-label="Close"><i class="ti ti-x"></i></button></div>
    <div class="modal-body">
      <input type="hidden" name="action" value="addBlock">
      <div class="field">
        <label for="blockName">Block name *</label>
        <input class="input" id="blockName" name="blockName" maxlength="50" required placeholder="e.g. Ramanujan Block">
      </div>
      <div class="field">
        <label>For *</label>
        <div class="segmented">
          <label><input type="radio" name="gender" value="M" required><i class="ti ti-gender-male"></i>Boys</label>
          <label><input type="radio" name="gender" value="F"><i class="ti ti-gender-female"></i>Girls</label>
        </div>
      </div>
      <div class="field">
        <label for="wardenName">Warden name</label>
        <input class="input" id="wardenName" name="wardenName" maxlength="100">
      </div>
      <div class="field">
        <label for="description">Description</label>
        <input class="input" id="description" name="description" maxlength="200">
      </div>
    </div>
    <div class="modal-foot">
      <button type="button" class="btn btn-ghost" data-close>Cancel</button>
      <button type="submit" class="btn">Add block</button>
    </div>
  </form>
</dialog>

<%-- Add room --%>
<c:if test="${not empty selected}">
<dialog class="modal" id="roomDialog">
  <form method="post" action="${ctx}/admin/rooms">
    <div class="modal-head"><h2>Add room to <c:out value="${selected.blockName}" /></h2><button type="button" data-close aria-label="Close"><i class="ti ti-x"></i></button></div>
    <div class="modal-body">
      <input type="hidden" name="action" value="addRoom">
      <input type="hidden" name="blockId" value="${selected.blockId}">
      <div class="row">
        <div class="field">
          <label for="roomNo">Room number *</label>
          <input class="input" id="roomNo" name="roomNo" maxlength="10" required placeholder="e.g. 301">
        </div>
        <div class="field">
          <label for="floorNo">Floor</label>
          <input class="input" type="number" id="floorNo" name="floorNo" min="0" max="20" value="1">
        </div>
      </div>
      <div class="field">
        <label for="roomType">Room type *</label>
        <select class="input" id="roomType" name="roomType" required>
          <option value="SINGLE">Single (1 bed)</option>
          <option value="DOUBLE" selected>Double (2 beds)</option>
          <option value="TRIPLE">Triple (3 beds)</option>
        </select>
      </div>
    </div>
    <div class="modal-foot">
      <button type="button" class="btn btn-ghost" data-close>Cancel</button>
      <button type="submit" class="btn">Add room</button>
    </div>
  </form>
</dialog>
</c:if>

<%@ include file="/WEB-INF/views/common/footer.jspf" %>
