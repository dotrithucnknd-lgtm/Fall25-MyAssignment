<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/header.jsp" />
    <div class="main-content container"> 
            <div class="hero" style="margin-bottom:16px;">
                <div>
                    <h1>Quản lý nghỉ phép dễ dàng</h1>
                    <p>Theo dõi, tạo và phê duyệt đơn xin nghỉ chỉ trong vài bước.</p>
                    <div style="margin-top:12px;" class="actions">
                        <a class="btn" href="${pageContext.request.contextPath}/request/create">Tạo đơn mới</a>
                        <a class="btn-ghost" href="${pageContext.request.contextPath}/request/list">Xem đơn</a>
                    </div>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/home-decor-1.jpg" alt="Hero" />
            </div>
        
        <c:if test="${not empty sessionScope.auth}">
            
            <div class="card">
                <h1 style="margin:0 0 8px 0;">Welcome, ${sessionScope.auth.displayname}!</h1>
                <p class="account-info">Signed in as <strong>${sessionScope.auth.username}</strong></p>
            </div>
            

            <h2>Core Functions:</h2>
            
            <div class="grid grid-2">
                <div class="card">
                    <h3 style="margin-top:0;">Create leave request</h3>
                    <p class="muted">Submit a new time-off request.</p>
                    <div class="actions">
                        <a class="btn" href="${pageContext.request.contextPath}/request/create">Open</a>
                    </div>
                </div>
                <div class="card">
                    <h3 style="margin-top:0;">View requests</h3>
                    <p class="muted">See your requests and approvals.</p>
                    <div class="actions">
                        <a class="btn" href="${pageContext.request.contextPath}/request/list">Open</a>
                    </div>
                </div>
            </div>

            <div style="margin-top:16px;">
                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/logout">Log out</a>
            </div>

        </c:if>

        <c:if test="${empty sessionScope.auth}">
            <h1>Access Denied!</h1>
            <p class="message error">You must be logged in to view this page.</p>
            <p>
                <a href="${pageContext.request.contextPath}/login">Go to Login Page</a>
            </p>
        </c:if>
        
    </div>
<jsp:include page="/view/layout/footer.jsp" />