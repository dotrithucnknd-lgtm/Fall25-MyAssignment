<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Đăng nhập hệ thống - Fall25Assm</title>

        <%-- Link CSS (Đảm bảo file LocalStyle.css đã được cập nhật) --%>
        <link rel="stylesheet" type="text/css" 
              href="${pageContext.request.contextPath}/css/LocalStyle.css">
    </head>
    <body>
        <div class="login-wrapper">
            <%-- Container chính để căn giữa form --%>
            <div class="container">
                <h1>LOGIN</h1>

                <%-- Hiển thị thông báo lỗi (nếu có) --%>
                <c:if test="${not empty message}">
                    <p class="message error">${message}</p>
                </c:if>

                <form action="${pageContext.request.contextPath}/login" method="POST" class="login-form">

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
                    <input type="submit" id="btnLogin" value="LOG IN"/>
                </form>

                <p style="margin-top: 20px; font-size: 0.85em; color: #999;">
                    <a href="#" style="color: var(--primary-color); text-decoration: none;">Forgot Password?</a>
                </p>
            </div>
        </div>
    </body>
</html>