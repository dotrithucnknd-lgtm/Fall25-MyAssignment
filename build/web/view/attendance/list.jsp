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
                    <h1 style="margin-top:0;">Chấm Công Theo Ngày Nghỉ</h1>
                    <p>Chọn đơn nghỉ phép đã được phê duyệt để chấm công.</p>
                    <div style="margin-top: 16px;">
                        <a href="${pageContext.request.contextPath}/attendance/" class="neo-btn ghost" style="padding: 8px 16px; font-size: 14px;">
                            ← Quay lại chấm công hàng ngày
                        </a>
                    </div>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Attendance" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <c:choose>
                <c:when test="${empty requestScope.approvedRequests}">
                    <div class="neo-card tight mb-16" style="text-align: center; padding: 48px;">
                        <p style="color: var(--muted); font-size: 16px; margin: 0;">
                            Bạn chưa có đơn nghỉ phép nào đã được phê duyệt để chấm công.
                        </p>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="neo-card tight mb-16" style="text-align: left;">
                        <table class="neo-table" style="margin: 0 auto;">
                            <thead>
                                <tr>
                                    <th style="width: 80px;">ID</th>
                                    <th>Lý do</th>
                                    <th>Từ ngày</th>
                                    <th>Đến ngày</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach items="${requestScope.approvedRequests}" var="request">
                                    <tr>
                                        <td><span style="font-weight: 600; color: var(--primary); font-family: 'Courier New', monospace;">#${request.id}</span></td>
                                        <td>${request.reason}</td>
                                        <td>${request.from}</td>
                                        <td>${request.to}</td>
                                        <td>
                                            <div style="display: flex; gap: 8px; align-items: center;">
                                                <a href="${pageContext.request.contextPath}/attendance/check/${request.id}" class="btn" style="padding: 6px 12px; font-size: 13px;">
                                                    Chấm công
                                                </a>
                                                <a href="${pageContext.request.contextPath}/attendance/list/${request.id}" class="btn btn-ghost" style="padding: 6px 12px; font-size: 13px;">
                                                    Xem lịch sử
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />

