<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />
        <div class="container">
            <div class="hero mb-16">
                <div>
                    <h1 style="margin-top:0;">Lịch Sử Chấm Công - Đơn #${requestScope.request.id}</h1>
                    <p>Xem chi tiết lịch sử chấm công cho đơn nghỉ phép từ ${requestScope.request.from} đến ${requestScope.request.to}.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Attendance List" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <div class="neo-card tight mb-16">
                <h2 style="margin-top: 0; margin-bottom: 16px;">Thông tin đơn nghỉ phép</h2>
                <table class="neo-table" style="margin-bottom: 24px;">
                    <tr>
                        <td style="font-weight: 600; width: 150px;">ID đơn:</td>
                        <td>#${requestScope.request.id}</td>
                    </tr>
                    <tr>
                        <td style="font-weight: 600;">Lý do:</td>
                        <td>${requestScope.request.reason}</td>
                    </tr>
                    <tr>
                        <td style="font-weight: 600;">Từ ngày:</td>
                        <td>${requestScope.request.from}</td>
                    </tr>
                    <tr>
                        <td style="font-weight: 600;">Đến ngày:</td>
                        <td>${requestScope.request.to}</td>
                    </tr>
                </table>
            </div>
            
            <c:choose>
                <c:when test="${empty requestScope.attendances}">
                    <div class="neo-card tight mb-16" style="text-align: center; padding: 48px;">
                        <p style="color: var(--muted); font-size: 16px; margin: 0;">
                            Chưa có lịch sử chấm công cho đơn này.
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="neo-card tight mb-16" style="text-align: left;">
                        <table class="neo-table" style="margin: 0 auto;">
                            <thead>
                                <tr>
                                    <th>Ngày chấm công</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Ghi chú</th>
                                    <th>Thời gian tạo</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${requestScope.attendances}" var="attendance">
                                    <tr>
                                        <td><strong>${attendance.attendanceDate}</strong></td>
                                        <td>${attendance.checkInTime != null ? attendance.checkInTime : '-'}</td>
                                        <td>${attendance.checkOutTime != null ? attendance.checkOutTime : '-'}</td>
                                        <td>${attendance.note != null ? attendance.note : '-'}</td>
                                        <td style="font-size: 0.9em; color: var(--muted);">
                                            ${attendance.createdAt != null ? attendance.createdAt : '-'}
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
            
            <div class="actions" style="text-align: center; margin-top: 24px;">
                <a class="neo-btn" href="${pageContext.request.contextPath}/attendance/check/${requestScope.request.id}">Chấm công mới</a>
                <a class="neo-btn ghost" href="${pageContext.request.contextPath}/attendance/">Danh sách đơn</a>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />




