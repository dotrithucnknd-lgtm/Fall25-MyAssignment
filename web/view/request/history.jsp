<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/header.jsp" />
    <div class="container">
        <div class="card" style="margin-bottom:12px;">
            <h1 style="margin:0;">Lịch sử duyệt đơn #<c:out value="${rid}"/></h1>
        </div>
        <table class="table">
            <thead>
                <tr>
                    <th>Thời gian</th>
                    <th>Người duyệt</th>
                    <th>Trạng thái cũ</th>
                    <th>Trạng thái mới</th>
                    <th>Ghi chú</th>
                </tr>
            </thead>
            <tbody>
            <c:forEach items="${logs}" var="h">
                <tr>
                    <td><c:out value="${h.processedTime}"/></td>
                    <td><c:out value="${h.processedBy != null ? h.processedBy.name : 'N/A'}"/></td>
                    <td>
                        <c:choose>
                            <c:when test="${h.oldStatus eq 0}"><span class="status pending">Chờ duyệt</span></c:when>
                            <c:when test="${h.oldStatus eq 1}"><span class="status approved">Đã duyệt</span></c:when>
                            <c:otherwise><span class="status rejected">Đã từ chối</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${h.newStatus eq 0}"><span class="status pending">Chờ duyệt</span></c:when>
                            <c:when test="${h.newStatus eq 1}"><span class="status approved">Đã duyệt</span></c:when>
                            <c:otherwise><span class="status rejected">Đã từ chối</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td><c:out value="${h.note}"/></td>
                </tr>
            </c:forEach>
            </tbody>
        </table>
        <div style="margin-top:12px;">
            <a class="btn btn-ghost" href="${pageContext.request.contextPath}/request/list">Quay lại danh sách</a>
        </div>
    </div>
<jsp:include page="/view/layout/footer.jsp" />

