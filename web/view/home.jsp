<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Home - Leave Management</title>
    <link rel="stylesheet" type="text/css" href="${pageContext.request.contextPath}/css/LocalStyle.css">
</head>
<%-- THÊM class="home-page" VÀO THẺ BODY --%>
<body class="home-page"> 
    
    <div class="main-content"> 
        
        <c:if test="${not empty sessionScope.auth}">
            
            <div class="header-area">
                <h1>MAIN SYSTEM HOME</h1>
                <h2 class="welcome-message">Welcome, ${sessionScope.auth.displayname}!</h2>
                <p class="account-info">You are logged in as: <strong>${sessionScope.auth.username}</strong></p>
                <hr class="main-hr">
            </div>
            

            <h2>Core Functions:</h2>
            
            <nav class="button-menu">
                
                <a href="${pageContext.request.contextPath}/request/create" class="menu-button primary-btn">
                    <span class="icon">📝</span> Create New Leave Request
                </a>

                <a href="${pageContext.request.contextPath}/request/list" class="menu-button primary-btn">
                    <span class="icon">📜</span> View My Leave Requests
                </a>
                
                <hr class="nav-hr">

                <a href="${pageContext.request.contextPath}/logout" class="menu-button logout-btn">
                    <span class="icon">❌</span> Log Out
                </a>
            </nav>

        </c:if>

        <c:if test="${empty sessionScope.auth}">
            <h1>Access Denied!</h1>
            <p class="message error">You must be logged in to view this page.</p>
            <p>
                <a href="${pageContext.request.contextPath}/login">Go to Login Page</a>
            </p>
        </c:if>
        
    </div>
</body>
</html>