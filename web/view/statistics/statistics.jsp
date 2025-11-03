<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<jsp:include page="/view/layout/neo_header.jsp" />

<div class="container">
    <div class="neo-card tight mb-12">
        <h1>Thống kê nghỉ phép theo nhân viên</h1>
        <p class="muted">Tháng <fmt:formatDate value="<%=new java.util.Date()%>" pattern="MM/yyyy"/></p>
    </div>
    
    <div class="neo-card tight">
        <table class="neo-table">
            <thead>
                <tr>
                    <th style="width: 60px;">STT</th>
                    <th>Mã nhân viên</th>
                    <th>Tên nhân viên</th>
                    <th style="text-align: center;">Số lần nghỉ</th>
                </tr>
            </thead>
            <tbody>
                <c:forEach items="${statistics}" var="stat" varStatus="loop">
                    <tr>
                        <td>${loop.index + 1}</td>
                        <td><span style="font-weight: 600; color: var(--primary); font-family: 'Courier New', monospace;">#${stat.employeeId}</span></td>
                        <td><c:out value="${stat.employeeName}"/></td>
                        <td style="text-align: center;">
                            <c:choose>
                                <c:when test="${stat.leaveCount > 2}">
                                    <span class="status rejected" style="font-weight: 800; font-size: 16px;">${stat.leaveCount}</span>
                                </c:when>
                                <c:when test="${stat.leaveCount > 0}">
                                    <span class="status approved" style="font-weight: 800; font-size: 16px;">${stat.leaveCount}</span>
                                </c:when>
                                <c:otherwise>
                                    <span style="color: var(--muted);">0</span>
                                </c:otherwise>
                            </c:choose>
                        </td>
                    </tr>
                </c:forEach>
                <c:if test="${empty statistics}">
                    <tr>
                        <td colspan="4" style="text-align: center; padding: 24px; color: var(--muted);">
                            Chưa có dữ liệu thống kê.
                        </td>
                    </tr>
                </c:if>
            </tbody>
        </table>
    </div>
    
    <div class="mt-12">
        <a class="neo-btn ghost" href="${ctx}/home">Về trang chủ</a>
    </div>
</div>

<jsp:include page="/view/layout/neo_footer.jsp" />



