<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
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
                    <h1 style="margin-top:0;">Tạo User và Password Mới</h1>
                    <p>Tạo tài khoản người dùng mới cho hệ thống.</p>
                </div>
                <img src="${pageContext.request.contextPath}/assets/img/home-decor-3.jpg" alt="Create User" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
            </div>
            
            <div class="neo-card tight">
                <form action="${pageContext.request.contextPath}/admin/create-user" method="POST" class="neo-form">
                    <div class="form-group">
                        <label for="username">Username:</label>
                        <input type="text" name="username" id="username" required 
                               placeholder="Nhập username" autocomplete="off">
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password:</label>
                        <input type="password" name="password" id="password" required 
                               placeholder="Nhập password (tối thiểu 6 ký tự)" minlength="6">
                        <small style="color: var(--muted); font-size: 0.85em;">Password phải có ít nhất 6 ký tự</small>
                    </div>
                    
                    <div class="form-group">
                        <label for="displayname">Tên hiển thị:</label>
                        <input type="text" name="displayname" id="displayname" required 
                               placeholder="Nhập tên hiển thị">
                    </div>
                    
                    <div class="form-group">
                        <label style="margin-bottom: 12px;">Chọn Employee:</label>
                        <div style="margin-bottom: 12px;">
                            <label style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                                <input type="checkbox" name="createNewEmployee" id="createNewEmployee" 
                                       onchange="toggleEmployeeSelect()" style="width: auto;">
                                <span>Tạo Employee mới (tên sẽ dùng displayname ở trên)</span>
                            </label>
                        </div>
                        
                        <div id="employeeSelectDiv" style="display: block !important; visibility: visible !important; opacity: 1 !important;">
                            <label for="employeeId">Chọn Employee đã có: <span style="color: red;">*</span></label>
                            <select name="employeeId" id="employeeId" class="neo-select" required style="width: 100%; pointer-events: auto !important; cursor: pointer !important;">
                                <option value="">-- Chọn Employee --</option>
                                <c:choose>
                                    <c:when test="${not empty requestScope.employees}">
                                        <c:forEach items="${requestScope.employees}" var="emp">
                                            <option value="${emp.id}">#${emp.id} - ${emp.name}</option>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="" disabled>Không có Employee nào</option>
                                    </c:otherwise>
                                </c:choose>
                            </select>
                            <c:if test="${empty requestScope.employees}">
                                <small style="color: var(--muted); font-size: 0.85em; display: block; margin-top: 4px;">
                                    Không có Employee nào trong hệ thống. Vui lòng chọn "Tạo Employee mới".
                                </small>
                            </c:if>
                        </div>
                    </div>
                    
                    <div class="actions">
                        <button type="submit" class="neo-btn">Tạo User</button>
                        <a href="${pageContext.request.contextPath}/home" class="neo-btn ghost">Quay lại</a>
                    </div>
                </form>
            </div>
        </div>
        
        <script>
            function toggleEmployeeSelect() {
                const checkbox = document.getElementById('createNewEmployee');
                const selectDiv = document.getElementById('employeeSelectDiv');
                const select = document.getElementById('employeeId');
                
                if (!checkbox || !selectDiv || !select) {
                    console.error('Elements not found');
                    return;
                }
                
                if (checkbox.checked) {
                    // Ẩn select khi checkbox được chọn
                    selectDiv.style.display = 'none';
                    select.value = '';
                    select.removeAttribute('required');
                    select.disabled = true;
                } else {
                    // Hiển thị select khi checkbox không được chọn
                    selectDiv.style.display = 'block';
                    selectDiv.style.visibility = 'visible';
                    selectDiv.style.opacity = '1';
                    select.setAttribute('required', 'required');
                    select.disabled = false;
                    select.style.pointerEvents = 'auto';
                    select.style.cursor = 'pointer';
                }
                
                console.log('Toggle - checkbox checked:', checkbox.checked, 
                           'select display:', selectDiv.style.display,
                           'select disabled:', select.disabled);
            }
            
            // Đợi DOM load xong hoặc chạy ngay nếu DOM đã sẵn sàng
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', function() {
                    initEmployeeSelect();
                });
            } else {
                // DOM đã sẵn sàng, chạy ngay
                initEmployeeSelect();
            }
            
            function initEmployeeSelect() {
                // Đảm bảo select luôn hiển thị mặc định (không gọi toggleEmployeeSelect)
                const checkbox = document.getElementById('createNewEmployee');
                const selectDiv = document.getElementById('employeeSelectDiv');
                const select = document.getElementById('employeeId');
                
                if (!checkbox || !selectDiv || !select) {
                    console.error('Elements not found');
                    return;
                }
                
                // Đảm bảo checkbox mặc định là unchecked
                if (!checkbox.checked) {
                    // Đảm bảo select hiển thị và enabled
                    selectDiv.style.display = 'block';
                    selectDiv.style.visibility = 'visible';
                    selectDiv.style.opacity = '1';
                    select.disabled = false;
                    select.style.pointerEvents = 'auto';
                    select.style.cursor = 'pointer';
                    select.setAttribute('required', 'required');
                } else {
                    // Nếu checkbox được check, ẩn select
                    selectDiv.style.display = 'none';
                    select.value = '';
                    select.removeAttribute('required');
                    select.disabled = true;
                }
                
                // Debug: kiểm tra số lượng employees
                if (select) {
                    const optionCount = select.options.length;
                    console.log('Number of employee options:', optionCount);
                    if (optionCount <= 1) {
                        console.warn('No employees found in dropdown');
                    }
                }
                
                // Validation trước khi submit
                const form = document.querySelector('form');
                if (form) {
                    form.addEventListener('submit', function(e) {
                        const checkbox = document.getElementById('createNewEmployee');
                        const select = document.getElementById('employeeId');
                        
                        if (!checkbox.checked) {
                            if (!select.value || select.value.trim() === '') {
                                e.preventDefault();
                                alert('Vui lòng chọn Employee hoặc chọn "Tạo Employee mới"');
                                select.focus();
                                return false;
                            }
                        }
                    });
                }
            }
        </script>
<jsp:include page="/view/layout/neo_footer.jsp" />

