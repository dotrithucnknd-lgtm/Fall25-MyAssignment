<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/header.jsp" />
        <div class="container">
            <div class="grid grid-2" style="align-items:center;">
                <div>
                    <img src="${pageContext.request.contextPath}/assets/img/illustrations/rocket-white.png" onerror="this.src='${pageContext.request.contextPath}/assets/img/home-decor-2.jpg'" alt="Welcome" style="width:100%;border-radius:12px;border:1px solid var(--border);"/>
                </div>
                <div class="card" style="max-width:480px;">
                    <h1 style="margin-top:0;">Đăng nhập</h1>

                <%-- Hiển thị thông báo lỗi (nếu có) --%>
                <c:if test="${not empty message}">
                    <p class="message error">${message}</p>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="POST">

                    <%-- Ô Username --%>
                    <div class="form-group">
                        <label for="txtUsername">USERNAME</label>
                        <input type="text" 
                               name="username"       
                               id="txtUsername"
                               placeholder="Enter your username" 
                               required/> 
                    </div>

                    <%-- Ô Password --%>
                    <div class="form-group">
                        <label for="txtPassword">PASSWORD</label>
                        <input type="password" 
                               name="password"       
                               id="txtPassword"
                               placeholder="Enter your password"
                               required/> 
                    </div>

                    <%-- Nút Submit --%>
                    <button type="submit" class="btn">Log in</button>
                </form>

                <p style="margin-top: 20px; font-size: 0.85em; color: var(--muted);">
                    <a href="#" style="color: var(--primary); text-decoration: none;">Quên mật khẩu?</a>
                </p>
                </div>
            </div>
        </div>
<jsp:include page="/view/layout/footer.jsp" />