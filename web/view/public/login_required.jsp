<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<jsp:include page="/view/layout/neo_header.jsp" />
<div class="container" style="display: flex; justify-content: center; align-items: center; min-height: calc(100vh - 200px);">
    <div class="neo-card" style="max-width: 500px; width: 100%; text-align: center; padding: 48px 40px;">
        <div style="margin-bottom: 32px;">
            <svg width="80" height="80" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin: 0 auto 24px; color: var(--primary);">
                <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                <path d="M12 16v-4M12 8h.01" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            <h1 style="margin: 0 0 16px 0; font-size: 32px; color: var(--primary); font-weight: 800;">Bạn cần đăng nhập trước</h1>
            <p style="margin: 0; color: var(--muted); font-size: 16px; line-height: 1.6;">
                Bạn cần đăng nhập trước để truy cập chức năng này.
            </p>
        </div>
        <div class="actions" style="display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;">
            <a href="${ctx}/login" class="neo-btn" style="padding: 12px 28px; font-size: 16px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px; display: inline-block; vertical-align: middle;">
                    <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <polyline points="10 17 15 12 10 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <line x1="15" y1="12" x2="3" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Đăng nhập
            </a>
            <a href="${ctx}/landing" class="neo-btn ghost" style="padding: 12px 28px; font-size: 16px;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px; display: inline-block; vertical-align: middle;">
                    <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                    <polyline points="9 22 9 12 15 12 15 22" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                </svg>
                Về trang chủ
            </a>
        </div>
    </div>
</div>
<jsp:include page="/view/layout/neo_footer.jsp" />

