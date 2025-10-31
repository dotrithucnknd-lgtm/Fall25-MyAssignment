<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />
        <%-- Chèn greeting.jsp (Cần đảm bảo file này đã được sửa lỗi) --%>
        <jsp:include page="../util/greeting.jsp"></jsp:include>
        
        <%-- 2. SỬ DỤNG CLASS CONTAINER --%>
        <div class="container">
            <div class="hero mb-16">
                <div>
                    <h1 style="margin-top:0;">Danh sách Đơn Xin Nghỉ Phép</h1>
                    <p>Xem và theo dõi trạng thái các đơn xin nghỉ của bạn.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Requests" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            <%-- Search form --%>
            <div class="neo-card mb-16 search-container">
                <form method="GET" action="${pageContext.request.contextPath}/request/list" class="search-form">
                    <div class="search-input-wrapper">
                        <svg class="search-icon" width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                            <path d="M21 21l-4.35-4.35" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                            <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2"/>
                        </svg>
                        <input 
                            type="text" 
                            name="search" 
                            placeholder="Tìm kiếm theo tên người tạo, lý do nghỉ phép..." 
                            value="${param.search}" 
                            autocomplete="off" 
                            class="search-input"
                        />
                        <c:if test="${not empty param.search}">
                            <button type="button" class="search-clear" onclick="document.querySelector('.search-input').value=''; document.querySelector('.search-form').submit();">
                                <svg width="16" height="16" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2"/>
                                    <path d="M15 9l-6 6M9 9l6 6" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                                </svg>
                            </button>
                        </c:if>
                    </div>
                    <button type="submit" class="search-button">
                        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 6px;">
                            <path d="M21 21l-4.35-4.35" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
                            <circle cx="11" cy="11" r="7" stroke="currentColor" stroke-width="2"/>
                        </svg>
                        Tìm kiếm
                    </button>
                </form>
            </div>
            
            <div class="neo-card tight mb-16" style="text-align: left;">
            <table class="neo-table" style="margin: 0 auto;">
                <thead>
                    <tr>
                        <th style="width: 80px;">ID</th>
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
                            <td><span style="font-weight: 600; color: var(--primary); font-family: 'Courier New', monospace;">#${r.id}</span></td>
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
                                        <div style="display: flex; gap: 8px; align-items: center; margin-top: 4px;">
                                            <span style="font-size: 0.85em; color: var(--muted);">Đổi sang:</span>
                                            <c:if test="${r.status eq 1}">
                                                <%-- Approved -> Change to Rejected (status=2) --%>
                                                <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=2" class="btn btn-ghost" style="padding: 4px 10px; font-size: 12px;">Từ chối</a>
                                            </c:if>
                                            <c:if test="${r.status eq 2}">
                                                <%-- Rejected -> Change to Approved (status=1) --%>
                                                <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=1" class="btn" style="padding: 4px 10px; font-size: 12px;">Duyệt</a>
                                            </c:if>
                                        </div>
                                    </c:when>
                                    <c:otherwise>
                                        <%-- Nếu chưa xử lý, hiển thị cả 2 nút hành động trên cùng một hàng --%>
                                        <div style="display: flex; gap: 8px; align-items: center;">
                                            <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=1" class="btn" style="padding: 6px 12px; font-size: 13px;">Duyệt</a>
                                            <a href="${pageContext.request.contextPath}/request/review?rid=${r.id}&status=2" class="btn btn-ghost" style="padding: 6px 12px; font-size: 13px;">Từ chối</a>
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />