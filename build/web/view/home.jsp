<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="main-content container"> 
            <div class="hero mb-16">
                <div>
                    <h1>Quản lý nghỉ phép dễ dàng</h1>
                    <p>Theo dõi, tạo và phê duyệt đơn xin nghỉ chỉ trong vài bước.</p>
                    <div style="margin-top:12px;" class="actions">
                        <c:if test="${hasPermission.check('/request/create')}">
                            <a class="btn" href="${pageContext.request.contextPath}/request/create">Tạo đơn mới</a>
                        </c:if>
                        <c:if test="${hasPermission.check('/request/list')}">
                            <a class="btn-ghost" href="${pageContext.request.contextPath}/request/list">Xem đơn</a>
                        </c:if>
                    </div>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/home-decor-1.jpg" alt="Hero" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
        
        <c:if test="${not empty sessionScope.auth}">
            
            <div class="neo-card">
                <h1 style="margin:0 0 8px 0;">Chào mừng, ${sessionScope.auth.displayname}!</h1>
                <p class="account-info">Đăng nhập với tài khoản <strong>${sessionScope.auth.username}</strong></p>
            </div>
            
            <c:if test="${showWarning == true}">
                <div class="neo-card" style="background: linear-gradient(135deg, var(--accent-red), var(--accent)); border: 2px solid var(--accent-red); box-shadow: var(--shadow-red); margin-bottom: 24px;">
                    <div style="display: flex; align-items: center; gap: 16px;">
                        <div style="flex-shrink: 0;">
                            <svg width="32" height="32" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="color: var(--white);">
                                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                                <path d="M12 16v-4M12 8h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                            </svg>
                        </div>
                        <div style="flex: 1;">
                            <h2 style="margin: 0 0 8px 0; color: var(--white); font-size: 20px; font-weight: 800;">⚠️ Cảnh báo: Đã nghỉ quá 2 buổi/tháng</h2>
                            <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                                Bạn đã nghỉ <strong>${leaveCountThisMonth}</strong> lần trong tháng này (giới hạn: 2 lần/tháng).
                            </p>
                        </div>
                    </div>
                </div>
            </c:if>

            <h2>Chức năng chính:</h2>
            
            <div class="neo-grid">
                <c:if test="${hasPermission.check('/request/create')}">
                    <div class="neo-card col-6">
                        <h3 style="margin-top:0;">Tạo đơn xin nghỉ</h3>
                        <p class="muted">Gửi đơn xin nghỉ phép mới.</p>
                        <div class="actions">
                            <a class="neo-btn" href="${pageContext.request.contextPath}/request/create">Mở</a>
                        </div>
                    </div>
                </c:if>
                <c:if test="${hasPermission.check('/request/list')}">
                    <div class="neo-card col-6">
                        <h3 style="margin-top:0;">Xem đơn xin nghỉ</h3>
                        <p class="muted">Xem đơn xin nghỉ và kết quả duyệt của bạn.</p>
                        <div class="actions">
                            <a class="neo-btn" href="${pageContext.request.contextPath}/request/list">Mở</a>
                        </div>
                    </div>
                </c:if>
            </div>

            <div class="mt-16">
                <a class="neo-btn ghost" href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
            </div>

        </c:if>

        <c:if test="${empty sessionScope.auth}">
            <h1>Truy cập bị từ chối!</h1>
            <p class="message error">Bạn phải đăng nhập để xem trang này.</p>
            <p>
                <a href="${pageContext.request.contextPath}/login">Đi đến trang đăng nhập</a>
            </p>
        </c:if>
        
    </div>
<jsp:include page="/view/layout/neo_footer.jsp" />