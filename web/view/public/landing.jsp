<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/header.jsp" />
    <div class="container">
        <div class="hero" style="margin-bottom:16px;">
            <div>
                <h1 style="margin:0 0 8px 0;">Chào mừng đến hệ thống Nghỉ phép</h1>
                <p>Theo dõi thông báo, tin mới và blog nội bộ. Đăng nhập hoặc đăng ký để bắt đầu.</p>
                <div style="margin-top:12px;" class="actions">
                    <a class="btn" href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                    <a class="btn-ghost" href="${pageContext.request.contextPath}/signup">Đăng ký</a>
                </div>
            </div>
            <img src="${pageContext.request.contextPath}/assets/img/home-decor-2.jpg" alt="Welcome" />
        </div>

        <div class="grid grid-2">
            <div class="card">
                <h3 style="margin-top:0;">Thông báo công ty</h3>
                <ul>
                    <li>Cuộc họp toàn công ty thứ 6 tuần này 9:00.</li>
                    <li>Chính sách nghỉ phép 2025 đã cập nhật.</li>
                    <li>Khai trương văn phòng mới tại Đà Nẵng.</li>
                </ul>
            </div>
            <div class="card">
                <h3 style="margin-top:0;">Tin mới & Blog</h3>
                <ul>
                    <li>Cách quản lý work-life balance hiệu quả.</li>
                    <li>Tips tối ưu quy trình phê duyệt nghỉ phép.</li>
                    <li>Văn hoá công ty: Together we grow.</li>
                </ul>
            </div>
        </div>
    </div>
<jsp:include page="/view/layout/footer.jsp" />

