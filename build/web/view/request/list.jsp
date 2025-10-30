<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/header.jsp" />
        <%-- Chèn greeting.jsp (Cần đảm bảo file này đã được sửa lỗi) --%>
        <jsp:include page="../util/greeting.jsp"></jsp:include>
        
        <%-- 2. SỬ DỤNG CLASS CONTAINER --%>
        <div class="container">
            <div class="hero" style="margin-bottom:16px;">
                <div>
                    <h1 style="margin-top:0;">Danh sách Đơn Xin Nghỉ Phép</h1>
                    <p>Xem và theo dõi trạng thái các đơn xin nghỉ của bạn.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Requests" />
            </div>
            <table class="table" style="margin-top:12px;">
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Người tạo</th>
                        <th>Lý do</th>
                        <th>Từ ngày</th>
                        <th>Đến ngày</th>
                        <th>Trạng thái</th>
                        <th>Người xử lý</th>
                        <th>Lịch sử</th>
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
                                    <c:when test="${r.status eq 0}"><span class="status pending">Đang chờ</span></c:when>
                                    <c:when test="${r.status eq 1}"><span class="status approved">Đã duyệt</span></c:when>
                                    <c:otherwise><span class="status rejected">Đã từ chối</span></c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <a class="btn btn-ghost" href="${pageContext.request.contextPath}/request/history?rid=${r.id}">Xem</a>
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
                                            <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=2" class="action-link reject-link">Từ chối</a>
                                        </c:if>
                                        <c:if test="${r.status eq 2}">
                                            <%-- Rejected -> Change to Approved (status=1) --%>
                                            <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=1" class="action-link approve-link">Duyệt</a>
                                        </c:if>
                                        )
                                        </span>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- Nếu chưa xử lý, hiển thị cả 2 nút hành động --%>
                                        <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=1" class="btn">Duyệt</a>
                                        |
                                        <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=2" class="btn btn-ghost">Từ chối</a>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>
<jsp:include page="/view/layout/footer.jsp" />