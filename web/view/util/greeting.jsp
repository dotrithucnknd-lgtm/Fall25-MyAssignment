<%-- 
    Document   : greeting
    Created on : Oct 19, 2025, 6:40:54 PM
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
    <c:if test="$(sessionScope.auth ne null)">
        Session of: $(sessionScope.auth.displayname)
        <br/><!-- comment -->
        employee: $(sessionScope.auth.employee.id)-$(sessionScope.auth.employee.name)
    </c:if>
    <c:if test="$(sessionScope.auth eq null)">
        You are not logged in yet!
    </c:if>
</body>

</html>
