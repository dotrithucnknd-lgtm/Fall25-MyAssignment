<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="main-content container"> 
            <div class="hero mb-16">
                <div>
                    <h1>Quản lý nghỉ phép dễ dàng</h1>
                    <p>Theo dõi, tạo và phê duyệt đơn xin nghỉ chỉ trong vài bước.</p>
                    <div style="margin-top:12px;" class="actions">
                        <a class="btn" href="${pageContext.request.contextPath}/request/create">Tạo đơn mới</a>
                        <a class="btn-ghost" href="${pageContext.request.contextPath}/request/list">Xem đơn</a>
                    </div>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/home-decor-1.jpg" alt="Hero" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
        
        <c:if test="${not empty sessionScope.auth}">
            
            <div class="neo-card">
                <h1 style="margin:0 0 8px 0;">Chào mừng, ${sessionScope.auth.displayname}!</h1>
                <p class="account-info">Đăng nhập với tài khoản <strong>${sessionScope.auth.username}</strong></p>
            </div>
            

            <h2>Chức năng chính:</h2>
            
            <div class="neo-grid">
                <div class="neo-card col-6">
                    <h3 style="margin-top:0;">Tạo đơn xin nghỉ</h3>
                    <p class="muted">Gửi đơn xin nghỉ phép mới.</p>
                    <div class="actions">
                        <a class="neo-btn" href="${pageContext.request.contextPath}/request/create">Mở</a>
                    </div>
                </div>
                <div class="neo-card col-6">
                    <h3 style="margin-top:0;">Xem đơn xin nghỉ</h3>
                    <p class="muted">Xem đơn xin nghỉ và kết quả duyệt của bạn.</p>
                    <div class="actions">
                        <a class="neo-btn" href="${pageContext.request.contextPath}/request/list">Mở</a>
                    </div>
                </div>
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