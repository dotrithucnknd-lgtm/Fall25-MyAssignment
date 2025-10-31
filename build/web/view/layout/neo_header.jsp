<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Neo Dashboard</title>
  <link rel="icon" type="image/png" href="${ctx}/assets/img/favicon.png" />
  <link rel="preconnect" href="https://fonts.googleapis.com" />
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet" />
  <link href="${ctx}/assets/css/neo-dashboard.css" rel="stylesheet" />
  <script>
    function toggleUserModal() {
      const modal = document.getElementById('userModal');
      if (modal) {
        modal.classList.toggle('show');
      }
    }
    
    function closeUserModal(event) {
      if (event) {
        event.stopPropagation();
      }
      const modal = document.getElementById('userModal');
      if (modal) {
        modal.classList.remove('show');
      }
    }
    
    // Close modal when pressing Escape key
    document.addEventListener('keydown', function(event) {
      if (event.key === 'Escape') {
        closeUserModal();
      }
    });
  </script>
</head>
<body>
<div class="neo-shell">
  <aside class="neo-sidebar">
    <div class="neo-sidebar-header">
    <div class="neo-brand">Neo Dashboard</div>
      <div class="neo-brand-subtitle">Hệ thống quản lý nghỉ phép</div>
    </div>
    <nav class="neo-nav">
      <a href="${ctx}/landing" class="<c:if test="${pageContext.request.requestURI.contains('/landing')}">active</c:if>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
          <path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <polyline points="9 22 9 12 15 12 15 22" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        Trang chủ
      </a>
      <a href="${ctx}/home" class="<c:if test="${pageContext.request.requestURI.contains('/home')}">active</c:if>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
          <rect x="3" y="3" width="7" height="7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <rect x="14" y="3" width="7" height="7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <rect x="14" y="14" width="7" height="7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <rect x="3" y="14" width="7" height="7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        Dashboard
      </a>
      <a href="${ctx}/request/list" class="<c:if test="${pageContext.request.requestURI.contains('/request')}">active</c:if>">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
          <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <polyline points="14 2 14 8 20 8" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <line x1="16" y1="13" x2="8" y2="13" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          <line x1="16" y1="17" x2="8" y2="17" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
        </svg>
        Đơn xin nghỉ
      </a>
      <c:if test="${sessionScope.auth ne null}">
        <a href="${ctx}/request/create" class="neo-nav-create">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
            <circle cx="12" cy="12" r="10" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <line x1="12" y1="8" x2="12" y2="16" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            <line x1="8" y1="12" x2="16" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
          </svg>
          Tạo đơn mới
        </a>
      </c:if>
      <div class="neo-nav-divider"></div>
      <c:choose>
        <c:when test="${sessionScope.auth ne null}">
          <a href="${ctx}/logout">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <polyline points="16 17 21 12 16 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <line x1="21" y1="12" x2="9" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Đăng xuất
          </a>
        </c:when>
        <c:otherwise>
          <a href="${ctx}/login" class="<c:if test="${pageContext.request.requestURI.contains('/login')}">active</c:if>">
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg" style="margin-right: 8px;">
              <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <polyline points="10 17 15 12 10 7" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
              <line x1="15" y1="12" x2="3" y2="12" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
            Đăng nhập
          </a>
        </c:otherwise>
      </c:choose>
    </nav>
  </aside>
  <main class="neo-main">
    <div class="neo-topbar">
      <div class="neo-topbar-left">
        <h2 class="neo-page-title" style="margin: 0; font-size: 24px; font-weight: 700; color: var(--text);">
          <c:choose>
            <c:when test="${pageContext.request.requestURI.contains('/landing')}">Trang chủ</c:when>
            <c:when test="${pageContext.request.requestURI.contains('/home')}">Dashboard</c:when>
            <c:when test="${pageContext.request.requestURI.contains('/request')}">Quản lý đơn xin nghỉ</c:when>
            <c:when test="${pageContext.request.requestURI.contains('/login')}">Đăng nhập</c:when>
            <c:otherwise>Neo Dashboard</c:otherwise>
          </c:choose>
        </h2>
      </div>
      <div class="neo-topbar-right">
        <c:if test="${sessionScope.auth ne null}">
          <div class="neo-user-info" onclick="toggleUserModal()" style="cursor: pointer;">
            <div class="neo-user-details">
              <div class="neo-user-name">${sessionScope.auth.displayname}</div>
              <div class="neo-user-role">${sessionScope.auth.employee.name}</div>
            </div>
            <div class="neo-avatar-large"></div>
          </div>
          
          <!-- User Info Modal -->
          <div id="userModal" class="user-modal-overlay" onclick="closeUserModal(event)">
            <div class="user-modal-content" onclick="event.stopPropagation()">
              <div class="user-modal-header">
                <h3>Thông tin tài khoản</h3>
                <button class="user-modal-close" onclick="closeUserModal(event)">&times;</button>
              </div>
              <div class="user-modal-body">
                <div class="user-avatar-section">
                  <div class="user-modal-avatar"></div>
                  <h2>${sessionScope.auth.displayname}</h2>
                  <p class="user-modal-subtitle">${sessionScope.auth.employee.name}</p>
                </div>
                <div class="user-info-section">
                  <div class="user-info-item">
                    <div class="user-info-label">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      Tên đăng nhập
                    </div>
                    <div class="user-info-value">${sessionScope.auth.username}</div>
                  </div>
                  <div class="user-info-item">
                    <div class="user-info-label">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <circle cx="12" cy="7" r="4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      Tên hiển thị
                    </div>
                    <div class="user-info-value">${sessionScope.auth.displayname}</div>
                  </div>
                  <div class="user-info-item">
                    <div class="user-info-label">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <circle cx="9" cy="7" r="4" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      Nhân viên
                    </div>
                    <div class="user-info-value">#${sessionScope.auth.employee.id} - ${sessionScope.auth.employee.name}</div>
                  </div>
                  <div class="user-info-item">
                    <div class="user-info-label">
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                        <path d="M12 2L2 7l10 5 10-5-10-5z" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M2 17l10 5 10-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                        <path d="M2 12l10 5 10-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
                      </svg>
                      User ID
                    </div>
                    <div class="user-info-value" style="font-family: 'Courier New', monospace;">#${sessionScope.auth.id}</div>
                  </div>
                </div>
              </div>
              <div class="user-modal-footer">
                <a href="${ctx}/logout" class="neo-btn ghost">Đăng xuất</a>
              </div>
            </div>
          </div>
        </c:if>
        <c:if test="${sessionScope.auth eq null}">
          <a class="neo-btn ghost" href="${ctx}/login">Đăng nhập</a>
        </c:if>
      </div>
    </div>

