<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />
        <%-- Hiển thị thông báo lỗi nếu có --%>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="container">
                <div class="neo-card" style="background: linear-gradient(135deg, var(--accent-red), var(--accent)); border: 2px solid var(--accent-red); box-shadow: var(--shadow-red); margin-bottom: 24px;">
                    <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                        ⚠️ ${sessionScope.errorMessage}
                    </p>
                </div>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        
        <%-- Hiển thị thông báo thành công nếu có --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="container">
                <div class="neo-card" style="background: linear-gradient(135deg, #4CAF50, var(--accent)); border: 2px solid #4CAF50; box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3); margin-bottom: 24px;">
                    <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                        ✓ ${sessionScope.successMessage}
                    </p>
                </div>
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        
        <div class="container">
            <div class="hero mb-16">
                <div>
                    <h1 style="margin-top:0;">Chấm Công Hàng Ngày</h1>
                    <p>Check-in và check-out cho ngày làm việc hôm nay.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Daily Attendance" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <div class="neo-card tight mb-16">
                <div style="text-align: center; padding: 24px;">
                    <h2 style="margin-top: 0; margin-bottom: 16px;">Ngày: ${requestScope.today}</h2>
                    
                    <c:choose>
                        <c:when test="${empty requestScope.todayAttendance}">
                            <p style="color: var(--muted); margin-bottom: 24px;">Bạn chưa check-in hôm nay.</p>
                            <form action="${pageContext.request.contextPath}/attendance/daily" method="POST" style="display: inline-block;">
                                <input type="hidden" name="action" value="checkin">
                                <button type="submit" class="neo-btn" style="padding: 12px 32px; font-size: 16px;">
                                    ⏰ Check-in
                                </button>
                            </form>
                        </c:when>
                        <c:otherwise>
                            <div style="margin-bottom: 24px;">
                                <div style="display: flex; justify-content: center; gap: 32px; margin-bottom: 16px;">
                                    <div style="text-align: center;">
                                        <div style="font-size: 14px; color: var(--muted); margin-bottom: 8px;">Check-in</div>
                                        <div style="font-size: 24px; font-weight: 600; color: var(--primary);">
                                            ${requestScope.todayAttendance.checkInTime != null ? requestScope.todayAttendance.checkInTime : 'Chưa check-in'}
                                        </div>
                                    </div>
                                    <div style="text-align: center;">
                                        <div style="font-size: 14px; color: var(--muted); margin-bottom: 8px;">Check-out</div>
                                        <div style="font-size: 24px; font-weight: 600; color: var(--primary);">
                                            ${requestScope.todayAttendance.checkOutTime != null ? requestScope.todayAttendance.checkOutTime : 'Chưa check-out'}
                                        </div>
                                    </div>
                                </div>
                                
                                <c:if test="${requestScope.todayAttendance.note != null && !empty requestScope.todayAttendance.note}">
                                    <div style="margin-top: 16px; padding: 12px; background: var(--bg-secondary); border-radius: 8px;">
                                        <strong>Ghi chú:</strong> ${requestScope.todayAttendance.note}
                                    </div>
                                </c:if>
                            </div>
                            
                            <div style="display: flex; gap: 12px; justify-content: center;">
                                <c:if test="${requestScope.todayAttendance.checkInTime == null}">
                                    <form action="${pageContext.request.contextPath}/attendance/daily" method="POST" style="display: inline-block;">
                                        <input type="hidden" name="action" value="checkin">
                                        <button type="submit" class="neo-btn" style="padding: 12px 32px; font-size: 16px;">
                                            ⏰ Check-in
                                        </button>
                                    </form>
                                </c:if>
                                
                                <c:if test="${requestScope.todayAttendance.checkOutTime == null && requestScope.todayAttendance.checkInTime != null}">
                                    <form action="${pageContext.request.contextPath}/attendance/daily" method="POST" style="display: inline-block;">
                                        <input type="hidden" name="action" value="checkout">
                                        <button type="submit" class="neo-btn" style="padding: 12px 32px; font-size: 16px; background: linear-gradient(135deg, #FF6B6B, var(--accent));">
                                            🏁 Check-out
                                        </button>
                                    </form>
                                </c:if>
                                
                                <c:if test="${requestScope.todayAttendance.checkInTime != null && requestScope.todayAttendance.checkOutTime != null}">
                                    <div style="padding: 12px 32px; font-size: 16px; background: var(--bg-secondary); border-radius: 8px; display: inline-block;">
                                        ✓ Đã hoàn thành chấm công hôm nay
                                    </div>
                                </c:if>
                            </div>
                        </c:otherwise>
                    </c:choose>
                </div>
            </div>
            
            <div class="actions" style="text-align: center; margin-top: 24px;">
                <a href="${pageContext.request.contextPath}/attendance/history" class="neo-btn ghost">Xem lịch sử chấm công</a>
                <a href="${pageContext.request.contextPath}/attendance/leave" class="neo-btn ghost">Chấm công theo ngày nghỉ</a>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />




