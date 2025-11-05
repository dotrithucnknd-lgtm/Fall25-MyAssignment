<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="neo-grid">
        <div class="neo-card col-3">
            <h3 style="margin:0;">Đơn chờ duyệt</h3>
            <p class="muted">Số lượng</p>
            <h1 style="margin:8px 0;">12</h1>
            <span class="tag amber">Pending</span>
        </div>
        <div class="neo-card col-3">
            <h3 style="margin:0;">Đã duyệt</h3>
            <h1 style="margin:8px 0;">34</h1>
            <span class="tag green">Approved</span>
        </div>
        <div class="neo-card col-3">
            <h3 style="margin:0;">Đã từ chối</h3>
            <h1 style="margin:8px 0;">5</h1>
            <span class="tag red">Rejected</span>
        </div>
        <div class="neo-card col-3">
            <h3 style="margin:0;">Kỳ nghỉ còn lại</h3>
            <h1 style="margin:8px 0;">8</h1>
        </div>

        <div class="neo-card col-8">
            <h3 style="margin:0 0 8px 0;">Đơn gần đây</h3>
            <table class="neo-table">
                <thead>
                    <tr><th>ID</th><th>Người tạo</th><th>Từ</th><th>Đến</th><th>Trạng thái</th></tr>
                </thead>
                <tbody>
                    <tr><td>#135</td><td>Nguyễn A</td><td>2025-10-01</td><td>2025-10-05</td><td><span class="tag green">Approved</span></td></tr>
                    <tr><td>#136</td><td>Trần B</td><td>2025-10-12</td><td>2025-10-14</td><td><span class="tag amber">Pending</span></td></tr>
                    <tr><td>#137</td><td>Lê C</td><td>2025-10-20</td><td>2025-10-22</td><td><span class="tag red">Rejected</span></td></tr>
                </tbody>
            </table>
        </div>
        <div class="neo-card col-4">
            <h3 style="margin:0 0 8px 0;">Thông báo</h3>
            <ul>
                <li>Họp công ty thứ 6, 9:00.</li>
                <li>Update chính sách nghỉ phép 2025.</li>
                <li>Chúc mừng nhân sự mới tháng 11.</li>
            </ul>
        </div>
    </div>
<jsp:include page="/view/layout/neo_footer.jsp" />






