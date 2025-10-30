<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    String ctx = request.getContextPath();
    response.sendRedirect(ctx + "/landing");
%>

