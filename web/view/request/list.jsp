<%-- 
    Document   : list
    Created on : Oct 21, 2025, 10:37:00 PM
    Author     : sonnt
--%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <jsp:include page="../util/greeting.jsp"></jsp:include>
            <table border="1px">
                <tr>
                    <td>request id</td>
                    <td>created by</td>
                    <td>reason</td>
                    <td>from</td>
                    <td>to</td>
                    <td>status</td>
                    <td>processed by</td>
                </tr>
            <c:forEach items="${requestScope.rfls}" var="r">
                <tr>
                    <td>${r.id}</td>
                    <td>${r.created_by.name}</td>
                    <td>${r.reason}</td>
                    <td>${r.from}</td>
                    <td>${r.to}</td>
                    <td>
                        ${r.status eq 0?"processing":
                          r.status eq 1?"approved":"rejected"
                        }
                    </td>
                    <td>
                        <c:if test="${r.processed_by ne null}">
                            ${r.processed_by.name}, you can change it to
                            <c:if test="${r.status eq 1}">
                            <a href="review">Rejected</a>
                            </c:if>
                             <c:if test="${r.status eq 2}">
                            <a href="review">Approved</a>
                            </c:if>
                        </c:if>
                        <c:if test="${r.processed_by eq null}">
                            <a href="review">Approve</a>
                            <a href="review">Reject</a>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </table>
    </body>
</html>
