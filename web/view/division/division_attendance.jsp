<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />
        <div class="container">
            <div class="hero mb-16">
                <div>
                    <h1 style="margin-top:0;">Chấm Công Division</h1>
                    <p>Xem chấm công của tất cả nhân viên dưới quyền quản lý.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Division Attendance" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <!-- Form chọn ngày -->
            <div class="neo-card tight mb-16">
                <form method="GET" action="${pageContext.request.contextPath}/division/attendance" style="display: flex; align-items: center; gap: 16px;">
                    <label for="date" style="font-weight: 600; white-space: nowrap;">Chọn ngày:</label>
                    <input type="date" id="date" name="date" value="${requestScope.selectedDate}" style="padding: 8px 12px; border: 1px solid var(--border); border-radius: 8px; font-size: 14px;" />
                    <button type="submit" class="neo-btn" style="white-space: nowrap;">Xem chấm công</button>
                    <a href="${pageContext.request.contextPath}/division/attendance" class="neo-btn ghost" style="white-space: nowrap;">Hôm nay</a>
                </form>
            </div>
            
            <!-- Hiển thị thông báo lỗi -->
            <c:if test="${not empty requestScope.errorMessage}">
                <div class="neo-card tight mb-16" style="background-color: var(--error-bg); border-color: var(--error);">
                    <p style="color: var(--error); margin: 0;">${requestScope.errorMessage}</p>
                </div>
            </c:if>
            
            <!-- Hiển thị thông báo thành công -->
            <c:if test="${not empty sessionScope.successMessage}">
                <div class="neo-card tight mb-16" style="background-color: var(--success-bg); border-color: var(--success);">
                    <p style="color: var(--success); margin: 0;">${sessionScope.successMessage}</p>
                </div>
                <c:remove var="successMessage" scope="session" />
            </c:if>
            
            <!-- Danh sách chấm công -->
            <c:choose>
                <c:when test="${empty requestScope.attendances}">
                    <div class="neo-card tight mb-16" style="text-align: center; padding: 48px;">
                        <p style="color: var(--muted); font-size: 16px; margin: 0;">
                            Chưa có chấm công nào cho ngày <strong><fmt:formatDate value="${requestScope.selectedDate}" pattern="dd/MM/yyyy" /></strong>.
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="neo-card tight mb-16">
                        <h2 style="margin-top: 0; margin-bottom: 16px;">
                            Chấm công ngày <fmt:formatDate value="${requestScope.selectedDate}" pattern="dd/MM/yyyy" />
                        </h2>
                        <p style="color: var(--muted); margin-bottom: 24px;">
                            Số nhân viên đã chấm công: <strong>${fn:length(attendanceMap)}</strong> / ${fn:length(requestScope.employees)}
                        </p>
                        
                        <table class="neo-table" style="margin: 0 auto;">
                            <thead>
                                <tr>
                                    <th>Nhân viên</th>
                                    <th>Ngày chấm công</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Đơn nghỉ phép</th>
                                    <th>Ghi chú</th>
                                    <th>Thời gian tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${requestScope.employees}" var="emp">
                                    <c:set var="empKey" value="${emp.id}" />
                                    <c:set var="attendance" value="${attendanceMap[empKey]}" />
                                    <tr>
                                        <td>
                                            <strong>${emp.name}</strong>
                                            <c:if test="${emp.id == sessionScope.auth.employee.id}">
                                                <span style="color: var(--muted); font-size: 0.85em;">(Bạn)</span>
                                            </c:if>
                                        </td>
                                        <td><strong><fmt:formatDate value="${requestScope.selectedDate}" pattern="dd/MM/yyyy" /></strong></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${attendance != null && attendance.checkInTime != null}">
                                                    <span style="color: var(--success); font-weight: 600;">
                                                        <fmt:formatDate value="${attendance.checkInTime}" pattern="HH:mm" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--muted);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${attendance != null && attendance.checkOutTime != null}">
                                                    <span style="color: var(--success); font-weight: 600;">
                                                        <fmt:formatDate value="${attendance.checkOutTime}" pattern="HH:mm" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--muted);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${attendance != null && attendance.requestForLeave != null}">
                                                    <a href="${pageContext.request.contextPath}/request/list" style="color: var(--primary); text-decoration: none;">
                                                        Đơn #${attendance.requestForLeave.id}
                                                    </a>
                                                    <br/>
                                                    <small style="color: var(--muted); font-size: 0.85em;">
                                                        <fmt:formatDate value="${attendance.requestForLeave.from}" pattern="dd/MM" /> - 
                                                        <fmt:formatDate value="${attendance.requestForLeave.to}" pattern="dd/MM" />
                                                    </small>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--muted);">
                                                        <c:choose>
                                                            <c:when test="${attendance != null}">Chấm công hàng ngày</c:when>
                                                            <c:otherwise>Chưa chấm công</c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${attendance != null && not empty attendance.note}">
                                                    <span title="${attendance.note}">${fn:substring(attendance.note, 0, 30)}${fn:length(attendance.note) > 30 ? '...' : ''}</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--muted);">-</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size: 0.9em; color: var(--muted);">
                                            <c:choose>
                                                <c:when test="${attendance != null && attendance.createdAt != null}">
                                                    <fmt:formatDate value="${attendance.createdAt}" pattern="dd/MM/yyyy HH:mm" />
                                                </c:when>
                                                <c:otherwise>
                                                    -
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
            
            <!-- Thống kê nhanh -->
            <c:if test="${not empty requestScope.employees}">
                <div class="neo-card tight mb-16">
                    <h3 style="margin-top: 0; margin-bottom: 16px;">Tổng quan Division</h3>
                    <p style="color: var(--muted); margin-bottom: 8px;">
                        Tổng số nhân viên dưới quyền: <strong>${fn:length(requestScope.employees)}</strong>
                    </p>
                    <p style="color: var(--muted); margin-bottom: 8px;">
                        Số nhân viên đã chấm công ngày <fmt:formatDate value="${requestScope.selectedDate}" pattern="dd/MM/yyyy" />: 
                        <strong>${fn:length(attendanceMap)}</strong> / ${fn:length(requestScope.employees)}
                    </p>
                    <p style="color: var(--muted); margin: 0;">
                        Tỷ lệ chấm công: 
                        <strong>
                            <c:choose>
                                <c:when test="${fn:length(requestScope.employees) > 0}">
                                    <fmt:formatNumber value="${fn:length(attendanceMap) * 100.0 / fn:length(requestScope.employees)}" maxFractionDigits="1" />%
                                </c:when>
                                <c:otherwise>0%</c:otherwise>
                            </c:choose>
                        </strong>
                    </p>
                </div>
            </c:if>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />

