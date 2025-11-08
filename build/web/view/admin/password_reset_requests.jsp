<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<jsp:include page="/view/layout/neo_header.jsp" />

<div class="neo-container">
    <div class="neo-card">
        <h1 style="margin-top: 0;">Quản lý yêu cầu reset mật khẩu</h1>
        
        <%-- Hiển thị thông báo lỗi (nếu có) --%>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="message error" style="margin-bottom: 16px;">
                ${sessionScope.errorMessage}
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        
        <%-- Hiển thị thông báo thành công (nếu có) --%>
        <c:if test="${not empty sessionScope.successMessage}">
            <div class="message success" style="margin-bottom: 16px; background: #4CAF50; color: white; padding: 12px; border-radius: 8px;">
                ${sessionScope.successMessage}
            </div>
            <c:remove var="successMessage" scope="session"/>
        </c:if>
        
        <%-- Thống kê --%>
        <div style="display: flex; gap: 16px; margin-bottom: 24px; flex-wrap: wrap;">
            <div style="flex: 1; min-width: 200px; padding: 16px; background: var(--bg-secondary); border-radius: 8px;">
                <div style="font-size: 24px; font-weight: bold; color: var(--primary);">
                    ${requestScope.pendingRequests != null ? requestScope.pendingRequests.size() : 0}
                </div>
                <div style="color: var(--muted); font-size: 14px;">Đang chờ xử lý</div>
            </div>
            <div style="flex: 1; min-width: 200px; padding: 16px; background: var(--bg-secondary); border-radius: 8px;">
                <div style="font-size: 24px; font-weight: bold; color: var(--primary);">
                    ${requestScope.requests != null ? requestScope.requests.size() : 0}
                </div>
                <div style="color: var(--muted); font-size: 14px;">Tổng số yêu cầu</div>
            </div>
        </div>
        
        <%-- Danh sách yêu cầu --%>
        <c:choose>
            <c:when test="${empty requestScope.requests}">
                <div style="text-align: center; padding: 40px; color: var(--muted);">
                    <p>Chưa có yêu cầu reset mật khẩu nào.</p>
                </div>
            </c:when>
            <c:otherwise>
                <div style="overflow-x: auto;">
                    <table style="width: 100%; border-collapse: collapse; margin-top: 16px;">
                        <thead>
                            <tr style="background: var(--bg-secondary); border-bottom: 2px solid var(--border);">
                                <th style="padding: 12px; text-align: left; font-weight: 600;">ID</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Username</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Tên hiển thị</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Thời gian yêu cầu</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Trạng thái</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Xử lý bởi</th>
                                <th style="padding: 12px; text-align: left; font-weight: 600;">Ghi chú</th>
                                <th style="padding: 12px; text-align: center; font-weight: 600;">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach items="${requestScope.requests}" var="req">
                                <tr style="border-bottom: 1px solid var(--border);">
                                    <td style="padding: 12px;">#${req.id}</td>
                                    <td style="padding: 12px;">
                                        <strong>${req.username}</strong>
                                    </td>
                                    <td style="padding: 12px;">
                                        ${req.user != null ? req.user.displayname : 'N/A'}
                                    </td>
                                    <td style="padding: 12px;">
                                        <fmt:formatDate value="${req.request_time}" pattern="dd/MM/yyyy HH:mm" />
                                    </td>
                                    <td style="padding: 12px;">
                                        <c:choose>
                                            <c:when test="${req.status == 0}">
                                                <span style="padding: 4px 12px; background: #ff9800; color: white; border-radius: 4px; font-size: 12px;">
                                                    Đang chờ
                                                </span>
                                            </c:when>
                                            <c:when test="${req.status == 1}">
                                                <span style="padding: 4px 12px; background: #4CAF50; color: white; border-radius: 4px; font-size: 12px;">
                                                    Đã xử lý
                                                </span>
                                            </c:when>
                                            <c:when test="${req.status == 2}">
                                                <span style="padding: 4px 12px; background: #f44336; color: white; border-radius: 4px; font-size: 12px;">
                                                    Đã hủy
                                                </span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td style="padding: 12px;">
                                        <c:if test="${req.processedByUser != null}">
                                            ${req.processedByUser.displayname}
                                            <br>
                                            <small style="color: var(--muted);">
                                                <fmt:formatDate value="${req.processed_time}" pattern="dd/MM/yyyy HH:mm" />
                                            </small>
                                        </c:if>
                                        <c:if test="${req.processedByUser == null}">
                                            <span style="color: var(--muted);">-</span>
                                        </c:if>
                                    </td>
                                    <td style="padding: 12px;">
                                        <c:if test="${not empty req.note}">
                                            ${req.note}
                                        </c:if>
                                        <c:if test="${empty req.note}">
                                            <span style="color: var(--muted);">-</span>
                                        </c:if>
                                    </td>
                                    <td style="padding: 12px; text-align: center;">
                                        <c:if test="${req.status == 0}">
                                            <%-- Form để reset password --%>
                                            <button type="button" 
                                                    onclick="confirmReset(${req.id}, '${req.username}')" 
                                                    style="padding: 6px 12px; background: var(--primary); color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px; margin-right: 4px;">
                                                Reset
                                            </button>
                                            <button type="button" 
                                                    onclick="showCancelForm(${req.id}, '${req.username}')" 
                                                    style="padding: 6px 12px; background: #f44336; color: white; border: none; border-radius: 4px; cursor: pointer; font-size: 12px;">
                                                Hủy
                                            </button>
                                        </c:if>
                                        <c:if test="${req.status != 0}">
                                            <span style="color: var(--muted); font-size: 12px;">-</span>
                                        </c:if>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</div>

<%-- Modal form để reset password (đơn giản hóa - chỉ confirm) --%>
<div id="resetModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
    <div style="background: white; padding: 24px; border-radius: 8px; max-width: 500px; width: 90%;">
        <h2 style="margin-top: 0;">Reset mật khẩu</h2>
        <p style="color: var(--muted); margin-bottom: 16px;">
            Bạn có chắc chắn muốn reset mật khẩu cho user: <strong id="resetUsername"></strong>?
        </p>
        <p style="background: #fff3cd; padding: 12px; border-radius: 4px; margin-bottom: 16px; color: #856404;">
            <strong>Lưu ý:</strong> Mật khẩu sẽ được reset về <strong>"123"</strong>
        </p>
        
        <form action="${pageContext.request.contextPath}/admin/password-reset-requests" method="POST" id="resetForm">
            <input type="hidden" name="action" value="approve">
            <input type="hidden" name="prrId" id="resetPrrId">
            
            <div style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 600;">Ghi chú (tùy chọn):</label>
                <textarea name="note" rows="3" 
                          style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: 4px;"
                          placeholder="Ghi chú về việc reset mật khẩu"></textarea>
            </div>
            
            <div style="display: flex; gap: 8px; justify-content: flex-end;">
                <button type="button" onclick="closeResetModal()" 
                        style="padding: 8px 16px; background: var(--bg-secondary); border: none; border-radius: 4px; cursor: pointer;">
                    Hủy
                </button>
                <button type="submit" 
                        style="padding: 8px 16px; background: var(--primary); color: white; border: none; border-radius: 4px; cursor: pointer;">
                    Xác nhận Reset
                </button>
            </div>
        </form>
    </div>
</div>

<%-- Modal form để hủy yêu cầu --%>
<div id="cancelModal" style="display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); z-index: 1000; align-items: center; justify-content: center;">
    <div style="background: white; padding: 24px; border-radius: 8px; max-width: 500px; width: 90%;">
        <h2 style="margin-top: 0;">Hủy yêu cầu reset mật khẩu</h2>
        <p style="color: var(--muted); margin-bottom: 16px;">
            Bạn có chắc chắn muốn hủy yêu cầu reset mật khẩu cho user: <strong id="cancelUsername"></strong>?
        </p>
        
        <form action="${pageContext.request.contextPath}/admin/password-reset-requests" method="POST">
            <input type="hidden" name="action" value="cancel">
            <input type="hidden" name="prrId" id="cancelPrrId">
            
            <div style="margin-bottom: 16px;">
                <label style="display: block; margin-bottom: 8px; font-weight: 600;">Lý do hủy (tùy chọn):</label>
                <textarea name="note" rows="3" 
                          style="width: 100%; padding: 8px; border: 1px solid var(--border); border-radius: 4px;"
                          placeholder="Lý do hủy yêu cầu"></textarea>
            </div>
            
            <div style="display: flex; gap: 8px; justify-content: flex-end;">
                <button type="button" onclick="closeCancelModal()" 
                        style="padding: 8px 16px; background: var(--bg-secondary); border: none; border-radius: 4px; cursor: pointer;">
                    Không
                </button>
                <button type="submit" 
                        style="padding: 8px 16px; background: #f44336; color: white; border: none; border-radius: 4px; cursor: pointer;">
                    Hủy yêu cầu
                </button>
            </div>
        </form>
    </div>
</div>

<script>
function confirmReset(prrId, username) {
    document.getElementById('resetPrrId').value = prrId;
    document.getElementById('resetUsername').textContent = username;
    document.getElementById('resetModal').style.display = 'flex';
}

function closeResetModal() {
    document.getElementById('resetModal').style.display = 'none';
    const form = document.getElementById('resetForm');
    if (form) {
        form.reset();
    }
}

function showCancelForm(prrId, username) {
    document.getElementById('cancelPrrId').value = prrId;
    document.getElementById('cancelUsername').textContent = username;
    document.getElementById('cancelModal').style.display = 'flex';
}

function closeCancelModal() {
    document.getElementById('cancelModal').style.display = 'none';
    document.getElementById('cancelModal').querySelector('form').reset();
}

// Đóng modal khi click bên ngoài
window.onclick = function(event) {
    const resetModal = document.getElementById('resetModal');
    const cancelModal = document.getElementById('cancelModal');
    if (event.target == resetModal) {
        closeResetModal();
    }
    if (event.target == cancelModal) {
        closeCancelModal();
    }
}
</script>

<jsp:include page="/view/layout/neo_footer.jsp" />

