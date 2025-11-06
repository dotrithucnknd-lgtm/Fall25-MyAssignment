<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.util.Calendar"%>
<%@page import="java.sql.Date"%>
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
                    <h1 style="margin-top:0;">Chấm Công Cho Đơn Nghỉ Phép #${requestScope.request.id}</h1>
                    <p>Chấm công cho các ngày trong khoảng thời gian nghỉ từ ${requestScope.request.from} đến ${requestScope.request.to}.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/home-decor-3.jpg" alt="Check In" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
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
            
            <div class="neo-card tight">
                <h2 style="margin-top: 0; margin-bottom: 16px;">Form Chấm Công</h2>
                <form action="${pageContext.request.contextPath}/attendance/check/${requestScope.request.id}" method="POST" class="neo-form">
                    <div class="form-group">
                        <label for="attendanceDate">Ngày chấm công:</label>
                        <input type="date" name="attendanceDate" id="attendanceDate" 
                               min="${requestScope.request.from}" 
                               max="${requestScope.request.to}" 
                               required>
                    </div>
                    
                    <div class="form-group">
                        <label for="checkInTime">Giờ check-in:</label>
                        <input type="time" name="checkInTime" id="checkInTime">
                    </div>
                    
                    <div class="form-group">
                        <label for="checkOutTime">Giờ check-out:</label>
                        <input type="time" name="checkOutTime" id="checkOutTime">
                    </div>
                    
                    <div class="form-group">
                        <label for="note">Ghi chú:</label>
                        <textarea name="note" id="note" rows="3" placeholder="Nhập ghi chú (nếu có)"></textarea>
                    </div>
                    
                    <div class="actions">
                        <button class="neo-btn" type="submit">Lưu chấm công</button>
                        <a class="neo-btn ghost" href="${pageContext.request.contextPath}/attendance/">Danh sách đơn</a>
                        <a class="neo-btn ghost" href="${pageContext.request.contextPath}/attendance/list/${requestScope.request.id}">Xem lịch sử</a>
                    </div>
                </form>
            </div>
            
            <c:if test="${not empty requestScope.attendances}">
                <div class="neo-card tight mb-16" style="margin-top: 24px;">
                    <h2 style="margin-top: 0; margin-bottom: 16px;">Lịch sử chấm công đã thực hiện</h2>
                    <table class="neo-table" style="margin: 0 auto;">
                        <thead>
                            <tr>
                                <th>Ngày</th>
                                <th>Check-in</th>
                                <th>Check-out</th>
                                <th>Ghi chú</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.attendances}" var="attendance">
                                <tr>
                                    <td>${attendance.attendanceDate}</td>
                                    <td>${attendance.checkInTime != null ? attendance.checkInTime : '-'}</td>
                                    <td>${attendance.checkOutTime != null ? attendance.checkOutTime : '-'}</td>
                                    <td>${attendance.note != null ? attendance.note : '-'}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />




