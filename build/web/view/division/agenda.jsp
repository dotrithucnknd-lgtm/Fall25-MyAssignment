<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<jsp:include page="/view/layout/neo_header.jsp" />

<%-- Hiển thị thông báo lỗi nếu có --%>
<c:if test="${not empty sessionScope.errorMessage}">
    <div class="container">
        <div class="neo-card" style="background: linear-gradient(135deg, var(--accent-red), var(--accent)); border: 2px solid var(--accent-red); box-shadow: var(--shadow-red); margin-bottom: 24px;">
            <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                ⚠️ ${sessionScope.errorMessage}
            </p>
        </div>
    </div>
    <c:remove var="errorMessage" scope="session"/>
</c:if>

<%-- Hiển thị thông báo thành công nếu có --%>
<c:if test="${not empty sessionScope.successMessage}">
    <div class="container">
        <div class="neo-card" style="background: linear-gradient(135deg, #4CAF50, var(--accent)); border: 2px solid #4CAF50; box-shadow: 0 4px 12px rgba(76, 175, 80, 0.3); margin-bottom: 24px;">
            <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                ✓ ${sessionScope.successMessage}
            </p>
        </div>
    </div>
    <c:remove var="successMessage" scope="session"/>
</c:if>

<div class="container">
    <div class="hero mb-16">
        <div>
            <h1 style="margin-top:0;">Lịch Nghỉ Phép Division</h1>
            <p>Xem lịch nghỉ phép của division (bạn và các nhân viên dưới quyền).</p>
            <div style="margin-top: 16px;">
                <a href="${pageContext.request.contextPath}/home" class="neo-btn ghost" style="padding: 8px 16px; font-size: 14px;">
                    ← Về trang chủ
                </a>
            </div>
        </div>
        <img src="${pageContext.request.contextPath}/assets/img/vr-bg.jpg" alt="Division Agenda" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
    </div>
    
    <%-- Navigation tháng --%>
    <div class="neo-card mb-16">
        <div style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
            <a href="${pageContext.request.contextPath}/division/agenda?year=${prevYear}&month=${prevMonth}" 
               class="neo-btn ghost" style="padding: 8px 16px;">
                ← Tháng trước
            </a>
            
            <div style="text-align: center;">
                <h2 style="margin: 0; font-size: 24px; font-weight: 700;">
                    Tháng ${month}/${year}
                </h2>
                <p style="margin: 8px 0 0 0; color: var(--muted); font-size: 14px;">
                    Lịch nghỉ phép của division
                </p>
            </div>
            
            <a href="${pageContext.request.contextPath}/division/agenda?year=${nextYear}&month=${nextMonth}" 
               class="neo-btn ghost" style="padding: 8px 16px;">
                Tháng sau →
            </a>
        </div>
    </div>
    
    <%-- Bảng Agenda --%>
    <c:choose>
        <c:when test="${empty requestScope.employees || empty requestScope.daysInMonth}">
            <div class="neo-card tight mb-16" style="text-align: center; padding: 48px;">
                <p style="color: var(--muted); font-size: 16px; margin: 0;">
                    Không có dữ liệu để hiển thị.
                </p>
            </div>
        </c:when>
        <c:otherwise>
            <div class="neo-card mb-16">
                <style>
                    .agenda-table {
                        width: 100%;
                        border-collapse: collapse;
                        font-size: 13px;
                    }
                    .agenda-table th {
                        background: var(--surface-light);
                        padding: 12px 8px;
                        text-align: center;
                        font-weight: 600;
                        border: 1px solid var(--border);
                        position: sticky;
                        top: 0;
                        z-index: 10;
                    }
                    .agenda-table th:first-child {
                        text-align: left;
                        min-width: 150px;
                    }
                    .agenda-table td {
                        padding: 8px;
                        text-align: center;
                        border: 1px solid var(--border);
                    }
                    .agenda-table td:first-child {
                        text-align: left;
                        font-weight: 600;
                        background: var(--surface-light);
                        position: sticky;
                        left: 0;
                        z-index: 5;
                    }
                    .agenda-cell {
                        width: 40px;
                        height: 40px;
                        display: inline-block;
                        border-radius: 4px;
                    }
                    .agenda-cell.working {
                        background: #4CAF50;
                    }
                    .agenda-cell.on-leave {
                        background: #f44336;
                    }
                </style>
                
                <h2 style="margin-top: 0; margin-bottom: 16px;">Lịch nghỉ phép - Tháng ${month}/${year}</h2>
                <p style="color: var(--muted); font-size: 14px; margin-bottom: 16px;">
                    <span style="display: inline-block; width: 20px; height: 20px; background: #4CAF50; border-radius: 4px; vertical-align: middle; margin-right: 8px;"></span>
                    Có đi làm
                    <span style="display: inline-block; width: 20px; height: 20px; background: #f44336; border-radius: 4px; vertical-align: middle; margin-left: 16px; margin-right: 8px;"></span>
                    Nghỉ phép
                </p>
                
                <div style="overflow-x: auto;">
                    <table class="agenda-table">
                        <thead>
                            <tr>
                                <th>Nhân sự</th>
                                <c:forEach var="day" begin="1" end="${daysInMonth}">
                                    <th>${day}/${month}</th>
                                </c:forEach>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.employees}" var="emp">
                                <tr>
                                    <td>${emp.name}</td>
                                    <c:forEach var="day" begin="1" end="${daysInMonth}">
                                        <c:set var="currentDay" value="${day}" />
                                        <%
                                            try {
                                                // Kiểm tra xem nhân viên có nghỉ phép trong ngày này không
                                                model.Employee employee = (model.Employee) pageContext.getAttribute("emp");
                                                Integer currentDay = (Integer) pageContext.getAttribute("currentDay");
                                                Integer currentYear = (Integer) pageContext.getAttribute("year");
                                                Integer currentMonth = (Integer) pageContext.getAttribute("month");
                                                
                                                if (employee != null && currentDay != null && currentYear != null && currentMonth != null) {
                                                    java.util.Calendar dayCal = java.util.Calendar.getInstance();
                                                    dayCal.set(currentYear, currentMonth - 1, currentDay);
                                                    dayCal.set(java.util.Calendar.HOUR_OF_DAY, 0);
                                                    dayCal.set(java.util.Calendar.MINUTE, 0);
                                                    dayCal.set(java.util.Calendar.SECOND, 0);
                                                    dayCal.set(java.util.Calendar.MILLISECOND, 0);
                                                    
                                                    boolean isOnLeave = false;
                                                    java.util.List<model.RequestForLeave> agendaList = 
                                                        (java.util.List<model.RequestForLeave>) pageContext.getAttribute("agenda");
                                                    
                                                    if (agendaList != null) {
                                                        for (model.RequestForLeave r : agendaList) {
                                                            // Chỉ hiển thị đơn đã được duyệt (status = 1)
                                                            if (r != null && r.getStatus() == 1 && r.getCreated_by() != null && 
                                                                r.getCreated_by().getId() == employee.getId()) {
                                                                java.util.Calendar fromCal = java.util.Calendar.getInstance();
                                                                fromCal.setTime(r.getFrom());
                                                                fromCal.set(java.util.Calendar.HOUR_OF_DAY, 0);
                                                                fromCal.set(java.util.Calendar.MINUTE, 0);
                                                                fromCal.set(java.util.Calendar.SECOND, 0);
                                                                fromCal.set(java.util.Calendar.MILLISECOND, 0);
                                                                
                                                                java.util.Calendar toCal = java.util.Calendar.getInstance();
                                                                toCal.setTime(r.getTo());
                                                                toCal.set(java.util.Calendar.HOUR_OF_DAY, 23);
                                                                toCal.set(java.util.Calendar.MINUTE, 59);
                                                                toCal.set(java.util.Calendar.SECOND, 59);
                                                                toCal.set(java.util.Calendar.MILLISECOND, 999);
                                                                
                                                                // Kiểm tra xem ngày hiện tại có nằm trong khoảng từ r.from đến r.to không
                                                                if (dayCal.getTimeInMillis() >= fromCal.getTimeInMillis() && 
                                                                    dayCal.getTimeInMillis() <= toCal.getTimeInMillis()) {
                                                                    isOnLeave = true;
                                                                    break;
                                                                }
                                                            }
                                                        }
                                                    }
                                                    
                                                    pageContext.setAttribute("isOnLeave", isOnLeave);
                                                } else {
                                                    pageContext.setAttribute("isOnLeave", false);
                                                }
                                            } catch (Exception e) {
                                                pageContext.setAttribute("isOnLeave", false);
                                            }
                                        %>
                                        <td>
                                            <div class="agenda-cell ${isOnLeave ? 'on-leave' : 'working'}"></div>
                                        </td>
                                    </c:forEach>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/view/layout/neo_footer.jsp" />

