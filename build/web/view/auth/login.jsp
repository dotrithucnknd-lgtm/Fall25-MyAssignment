<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
        <div class="neo-auth">
            <div class="neo-card">
                <h1>Đăng nhập</h1>

                <%-- Hiển thị thông báo lỗi (nếu có) --%>
                <c:if test="${not empty message}">
                    <p class="message error">${message}</p>
                </c:if>

                <form class="neo-form" action="${pageContext.request.contextPath}/login" method="POST">

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
                    <div class="actions">
                        <button type="submit" class="neo-btn">Log in</button>
                        <%-- Link đăng ký đã bị vô hiệu hóa --%>
                    </div>
                </form>
                <p class="muted" style="margin-top: 16px;">
                    <a href="#" style="color: var(--primary); text-decoration: none;">Quên mật khẩu?</a>
                </p>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />