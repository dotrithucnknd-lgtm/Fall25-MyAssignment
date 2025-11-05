<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />
        <div class="container">
            <div class="hero mb-16">
                <div>
                    <h1 style="margin-top:0;">Lịch Sử Chấm Công Hàng Ngày</h1>
                    <p>Xem chi tiết lịch sử chấm công hàng ngày của bạn.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Attendance History" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <c:choose>
                <c:when test="${empty requestScope.attendances}">
                    <div class="neo-card tight mb-16" style="text-align: center; padding: 48px;">
                        <p style="color: var(--muted); font-size: 16px; margin: 0;">
                            Bạn chưa có lịch sử chấm công hàng ngày nào.
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="neo-card tight mb-16" style="text-align: left;">
                        <table class="neo-table" style="margin: 0 auto;">
                            <thead>
                                <tr>
                                    <th>Ngày</th>
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
                <a href="${pageContext.request.contextPath}/attendance/" class="neo-btn">Chấm công hôm nay</a>
                <a href="${pageContext.request.contextPath}/attendance/leave" class="neo-btn ghost">Chấm công theo ngày nghỉ</a>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />


