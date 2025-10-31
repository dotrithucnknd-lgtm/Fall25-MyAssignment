<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
        <div class="neo-auth">
            <div class="neo-card">
                <h1>Đăng ký</h1>

                <%-- Hiển thị thông báo lỗi (nếu có) --%>
                <c:if test="${not empty message}">
                    <div class="neo-card" style="background: linear-gradient(135deg, var(--accent-red), var(--accent)); border: 2px solid var(--accent-red); box-shadow: var(--shadow-red); margin-bottom: 16px;">
                        <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                            ⚠️ ${message}
                        </p>
                    </div>
                </c:if>

                <p class="muted">Tạo tài khoản để sử dụng hệ thống.</p>

                <form class="neo-form" action="${pageContext.request.contextPath}/signup" method="POST">
                    <%-- Ô Họ và tên --%>
                    <div class="form-group">
                        <label for="displayname">Họ và tên</label>
                        <input type="text" 
                               id="displayname" 
                               name="displayname" 
                               placeholder="Nhập họ và tên của bạn" 
                               value="${param.displayname}"
                               required/>
                    </div>

                    <%-- Ô Tên đăng nhập --%>
                    <div class="form-group">
                        <label for="username">Tên đăng nhập</label>
                        <input type="text" 
                               id="username" 
                               name="username" 
                               placeholder="Nhập tên đăng nhập" 
                               value="${param.username}"
                               required/>
                    </div>

                    <%-- Ô Mật khẩu --%>
                    <div class="form-group">
                        <label for="password">Mật khẩu</label>
                        <input type="password" 
                               id="password" 
                               name="password" 
                               placeholder="Nhập mật khẩu"
                               required/>
                    </div>

                    <%-- Ô Mã nhân viên (EID) --%>
                    <div class="form-group">
                        <label for="eid">Mã nhân viên (EID)</label>
                        <input type="number" 
                               id="eid" 
                               name="eid" 
                               placeholder="Ví dụ: 1001" 
                               value="${param.eid}"
                               required/>
                        <p class="muted" style="margin-top: 4px; font-size: 0.85em;">Nhập mã nhân viên của bạn trong hệ thống</p>
                    </div>

                    <%-- Nút Submit --%>
                    <div class="actions">
                        <button type="submit" class="neo-btn">Đăng ký</button>
                        <a class="neo-btn ghost" href="${pageContext.request.contextPath}/login">Đã có tài khoản? Đăng nhập</a>
                    </div>
                </form>
            </div>
        </div>
<jsp:include page="/view/layout/neo_footer.jsp" />
