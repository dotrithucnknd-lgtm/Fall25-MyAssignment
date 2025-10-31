<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="main-content container">
        <div class="hero mb-16">
            <div>
                <h1 style="margin-top:0;">Tạo Đơn Xin Nghỉ Phép</h1>
                <p>Điền thông tin thời gian và lý do nghỉ. Đơn của bạn sẽ được gửi tới quản lý.</p>
            </div>
            <img src="${pageContext.request.contextPath}/assets/img/home-decor-3.jpg" alt="Create" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
        </div>
        <div class="neo-card tight">

        <form action="${pageContext.request.contextPath}/request/create" method="POST" class="neo-form">
            
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
            
            <div class="actions">
                <button class="neo-btn" type="submit">Gửi đơn</button>
                <a class="neo-btn ghost" href="${pageContext.request.contextPath}/request/list">Danh sách</a>
            </div>
        </form>
        </div>
    </div>
<jsp:include page="/view/layout/neo_footer.jsp" />