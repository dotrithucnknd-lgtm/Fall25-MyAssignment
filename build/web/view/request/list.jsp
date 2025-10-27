<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Danh sách Đơn Xin Nghỉ Phép</title>
        
        <%-- 1. THÊM LINK CSS HALLOWEEN --%>
        <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/style.css">
        
        <%-- CSS bổ sung cho bảng và trạng thái --%>
        <style>
            .request-table {
                width: 100%;
                border-collapse: collapse; /* Bỏ viền đôi */
                margin-top: 20px;
                box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            }
            .request-table th, .request-table td {
                padding: 12px 15px;
                border: 1px solid var(--border-color); /* Sử dụng border color từ theme */
                text-align: left;
                vertical-align: middle;
            }
            .request-table th {
                background-color: var(--secondary-color); /* Màu tím làm nền tiêu đề */
                color: var(--white-color);
                font-weight: 600;
                text-transform: uppercase;
                letter-spacing: 1px;
            }
            .request-table tr:nth-child(even) {
                background-color: #fcfcfc; /* Xen kẽ màu hàng */
            }
            .request-table tr:hover {
                background-color: #fff9f0; /* Hiệu ứng hover nhẹ */
            }
            
            /* Styling cho cột Trạng thái */
            .status-tag {
                display: inline-block;
                padding: 4px 8px;
                border-radius: 4px;
                font-size: 0.9em;
                font-weight: 700;
                text-transform: uppercase;
            }
            .status-0 { /* Processing */
                background-color: #fff3cd; /* Vàng nhạt */
                color: #856404;
                border: 1px solid #ffeeba;
            }
            .status-1 { /* Approved */
                background-color: var(--success-bg); /* Xanh pastel */
                color: var(--success-text);
                border: 1px solid var(--success-border);
            }
            .status-2 { /* Rejected */
                background-color: var(--error-bg); /* Hồng/Đỏ pastel */
                color: var(--error-text);
                border: 1px solid var(--error-border);
            }
            
            /* Styling cho các nút hành động */
            .action-link {
                padding: 3px 6px;
                border-radius: 3px;
                margin: 0 2px;
                font-size: 0.9em;
                font-weight: 600;
                text-decoration: none;
                transition: background-color 0.2s;
            }
            .approve-link {
                color: var(--success-text);
                border: 1px solid var(--success-text);
            }
            .approve-link:hover {
                background-color: var(--success-bg);
            }
            .reject-link {
                color: var(--error-text);
                border: 1px solid var(--error-text);
            }
            .reject-link:hover {
                background-color: var(--error-bg);
            }
        </style>
    </head>
    <body>
        <%-- Chèn greeting.jsp (Cần đảm bảo file này đã được sửa lỗi) --%>
        <jsp:include page="../util/greeting.jsp"></jsp:include>
        
        <%-- 2. SỬ DỤNG CLASS CONTAINER --%>
        <div class="container">
            <h1>Danh sách Đơn Xin Nghỉ Phép</h1>
            
            <%-- Dùng lớp CSS mới cho bảng --%>
            <table class="request-table">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Người tạo</th>
                        <th>Lý do</th>
                        <th>Từ ngày</th>
                        <th>Đến ngày</th>
                        <th>Trạng thái</th>
                        <th>Người xử lý</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach items="${requestScope.rfls}" var="r">
                        <tr>
                            <td>${r.id}</td>
                            <td>${r.created_by.name}</td>
                            <td>${r.reason}</td>
                            <td>${r.from}</td>
                            <td>${r.to}</td>
                            
                            <%-- Tinh chỉnh cột Trạng thái --%>
                            <td>
                                <c:choose>
                                    <c:when test="${r.status eq 0}">
                                        <span class="status-tag status-0">Đang chờ</span>
                                    </c:when>
                                    <c:when test="${r.status eq 1}">
                                        <span class="status-tag status-1">Đã duyệt</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-tag status-2">Đã từ chối</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            
                            <%-- Tinh chỉnh cột Người xử lý và Hành động (FIX LỖI URL) --%>
                            <td>
                                <c:choose>
                                    <c:when test="${r.processed_by ne null}">
                                        <span style="font-weight: 600; color: var(--secondary-color);">
                                            ${r.processed_by.name}
                                        </span>
                                        <br>
                                        <span style="font-size: 0.85em;">
                                        (Đổi sang:
                                        <c:if test="${r.status eq 1}">
                                            <%-- Approved -> Change to Rejected (status=2) --%>
                                            <a href="review?rid=${r.id}&status=2" class="action-link reject-link">Từ chối</a>
                                        </c:if>
                                        <c:if test="${r.status eq 2}">
                                            <%-- Rejected -> Change to Approved (status=1) --%>
                                            <a href="review?rid=${r.id}&status=1" class="action-link approve-link">Duyệt</a>
                                        </c:if>
                                        )
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- Nếu chưa xử lý, hiển thị cả 2 nút hành động --%>
                                        <a href="review?rid=${r.id}&status=1" class="action-link approve-link">Duyệt</a>
                                        |
                                        <a href="review?rid=${r.id}&status=2" class="action-link reject-link">Từ chối</a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
    </body>
</html>