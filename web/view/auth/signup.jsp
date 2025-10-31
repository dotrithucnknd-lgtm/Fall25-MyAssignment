<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/header.jsp" />
    <div class="container">
        <div class="card" style="max-width:560px;margin:20px auto;">
            <h1 style="margin-top:0;">Đăng ký</h1>
            <c:if test="${not empty message}">
                <p style="color:#b91c1c;font-weight:600;">${message}</p>
            </c:if>
            <p class="muted">Tạo tài khoản để sử dụng hệ thống.</p>
            <form action="${pageContext.request.contextPath}/signup" method="POST">
                <div class="form-group">
                    <label for="displayname">Họ và tên</label>
                    <input type="text" id="displayname" name="displayname" required />
                </div>
                <div class="form-group">
                    <label for="username">Tên đăng nhập</label>
                    <input type="text" id="username" name="username" required />
                </div>
                <div class="form-group">
                    <label for="password">Mật khẩu</label>
                    <input type="password" id="password" name="password" required />
                </div>
                <div class="form-group">
                    <label for="eid">Mã nhân viên (EID)</label>
                    <input type="text" id="eid" name="eid" placeholder="Ví dụ: 1001" required />
                </div>
                <div class="actions">
                    <button type="submit" class="btn">Đăng ký</button>
                    <a class="btn btn-ghost" href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
                </div>
            </form>
        </div>
    </div>
<jsp:include page="/view/layout/footer.jsp" />

