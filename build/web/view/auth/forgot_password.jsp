<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
<div class="neo-auth">
    <div class="neo-card">
        <h1>Quên mật khẩu</h1>
        
        <p style="color: var(--muted); margin-bottom: 24px;">
            Nhập username của bạn. Yêu cầu reset mật khẩu sẽ được gửi đến admin để xử lý.
        </p>
        
        <%-- Hiển thị thông báo lỗi (nếu có) --%>
        <c:if test="${not empty errorMessage}">
            <div class="message error" style="margin-bottom: 16px;">
                ${errorMessage}
            </div>
        </c:if>
        
        <%-- Hiển thị thông báo thành công (nếu có) --%>
        <c:if test="${not empty successMessage}">
            <div class="message success" style="margin-bottom: 16px; background: #4CAF50; color: white; padding: 12px; border-radius: 8px;">
                ${successMessage}
            </div>
        </c:if>
        
        <form class="neo-form" action="${pageContext.request.contextPath}/forgot-password" method="POST">
            <%-- Ô Username --%>
            <div class="form-group">
                <label for="txtUsername">USERNAME</label>
                <input type="text" 
                       name="username"       
                       id="txtUsername"
                       placeholder="Nhập username của bạn" 
                       required
                       autofocus/> 
            </div>
            
            <%-- Nút Submit --%>
            <div class="actions">
                <button type="submit" class="neo-btn">Gửi yêu cầu</button>
            </div>
        </form>
        
        <p class="muted" style="margin-top: 16px; text-align: center;">
            <a href="${pageContext.request.contextPath}/login" style="color: var(--primary); text-decoration: none;">
                ← Quay lại đăng nhập
            </a>
        </p>
    </div>
</div>
<jsp:include page="/view/layout/neo_footer.jsp" />

