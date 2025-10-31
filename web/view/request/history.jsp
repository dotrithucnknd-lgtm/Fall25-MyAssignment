<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="container">
        <div class="neo-card tight mb-12">
            <h1>Lịch sử duyệt đơn <span style="font-weight: 800; color: var(--primary); font-family: 'Courier New', monospace;">#<c:out value="${rid}"/></span></h1>
        </div>
        <div class="neo-card tight">
        <table class="neo-table">
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
                    <td>
                        <c:if test="${h.processedTime != null}">
                            <fmt:formatDate value="${h.processedTime}" pattern="dd/MM/yyyy HH:mm:ss"/>
                        </c:if>
                    </td>
                    <td><c:out value="${h.processedByName != null ? h.processedByName : 'N/A'}"/></td>
                    <td>
                        <c:choose>
                            <c:when test="${h.oldStatus eq 0}"><span class="status pending">Chờ duyệt</span></c:when>
                            <c:when test="${h.oldStatus eq 1}"><span class="status approved">Đã duyệt</span></c:when>
                            <c:when test="${h.oldStatus eq 2}"><span class="status rejected">Đã từ chối</span></c:when>
                            <c:otherwise><span class="status pending">-</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${h.newStatus eq 0}"><span class="status pending">Chờ duyệt</span></c:when>
                            <c:when test="${h.newStatus eq 1}"><span class="status approved">Đã duyệt</span></c:when>
                            <c:when test="${h.newStatus eq 2}"><span class="status rejected">Đã từ chối</span></c:when>
                            <c:otherwise><span class="status pending">-</span></c:otherwise>
                        </c:choose>
                    </td>
                    <td><c:out value="${h.note != null ? h.note : '-'}"/></td>
                </tr>
            </c:forEach>
            <c:if test="${empty logs}">
                <tr>
                    <td colspan="5" style="text-align: center; padding: 24px; color: var(--muted);">
                        Chưa có lịch sử duyệt đơn cho đơn này.
                    </td>
                </tr>
            </c:if>
            </tbody>
        </table>
        </div>
        <div class="mt-12">
            <a class="neo-btn ghost" href="${pageContext.request.contextPath}/request/list">Quay lại danh sách</a>
        </div>
    </div>
<jsp:include page="/view/layout/neo_footer.jsp" />

