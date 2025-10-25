<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Trang chủ - Quản lý nghỉ phép</title>
    <style>
        body { font-family: sans-serif; }
        nav ul { list-style: none; padding: 0; }
        nav li { margin-bottom: 10px; }
        nav a { text-decoration: none; color: blue; }
        nav a:hover { text-decoration: underline; }
    </style>
</head>
<body>

    <c:if test="${not empty sessionScope.auth}">
        <h1>Chào mừng, ${sessionScope.auth.displayname}!</h1>
        <p>Bạn đã đăng nhập với tài khoản: <strong>${sessionScope.auth.username}</strong></p>
        <hr>

        <h2>Chức năng chính:</h2>
        <nav>
            <ul>
                <%-- Link cho tất cả nhân viên --%>
                <li>
                    <a href="${pageContext.request.contextPath}/request/create">Tạo đơn xin nghỉ phép mới</a>
                </li>
                <li>
                    <a href="${pageContext.request.contextPath}/request/list">Xem danh sách đơn nghỉ phép của bạn</a>
                </li>

                <%--
                TODO: Thêm kiểm tra vai trò ở đây (ví dụ: chỉ hiển thị cho Manager)
                Sử dụng <c:if test="${sessionScope.auth.hasRole('Manager')}"> ... </c:if>
                (Bạn cần thêm phương thức hasRole vào model User hoặc kiểm tra theo cách khác)
                --%>
                <%-- <li> --%>
                <%--    <a href="${pageContext.request.contextPath}/request/review">Duyệt đơn nghỉ phép của cấp dưới</a> --%>
                <%-- </li> --%>
                <%-- <li> --%>
                <%--    <a href="${pageContext.request.contextPath}/division/agenda">Xem lịch làm việc/nghỉ phép (Agenda)</a> --%>
                <%-- </li> --%>

                <%-- Link Đăng xuất --%>
                <li>
                    <a href="${pageContext.request.contextPath}/logout">Đăng xuất</a>
                </li>
            </ul>
        </nav>

    </c:if>

    <c:if test="${empty sessionScope.auth}">
        <h1>Truy cập bị từ chối!</h1>
        <p style="color:red;">Bạn phải đăng nhập để xem trang này.</p>
        <p>
            <a href="${pageContext.request.contextPath}/login">Đi đến Trang đăng nhập</a>
        </p>
    </c:if>

</body>
</html>