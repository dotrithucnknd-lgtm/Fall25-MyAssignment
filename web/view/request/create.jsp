<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Tạo Đơn Xin Nghỉ Phép</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/LocalStyle.css">
</head>
<body>
    <div class="main-content">
        <h1>Tạo Đơn Xin Nghỉ Phép Mới</h1>
        <hr>

        <form action="${pageContext.request.contextPath}/request/create" method="POST" class="login-form">
            
            <%-- THAY ĐỔI: Nhập ID Loại phép (Sử dụng ID 1 làm mặc định nếu cần) --%>
            <div class="form-group">
                <label for="leaveTypeID">ID Loại nghỉ phép:</label>
                <input type="text" name="leaveTypeID" id="leaveTypeID" value="1" required>
            </div>
            
            <%-- 2. Ngày Bắt đầu --%>
            <div class="form-group">
                <label for="from">Từ ngày:</label>
                <input type="date" name="from" id="from" required>
            </div>
            
            <%-- 3. Ngày Kết thúc --%>
            <div class="form-group">
                <label for="to">Đến ngày:</label>
                <input type="date" name="to" id="to" required>
            </div>
            
            <%-- 4. Lý do (Textarea) --%>
            <div class="form-group">
                <label for="reason">Lý do:</label>
                <textarea name="reason" id="reason" rows="5" required></textarea>
            </div>
            
            <input type="submit" value="GỬI ĐƠN XIN NGHỈ">
        </form>
    </div>
</body>
</html>