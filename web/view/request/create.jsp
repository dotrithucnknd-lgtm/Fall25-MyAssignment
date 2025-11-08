<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<jsp:include page="/view/layout/neo_header.jsp" />
    <div class="main-content container">
        <%-- Hiển thị thông báo lỗi nếu có --%>
        <c:if test="${not empty sessionScope.errorMessage}">
            <div class="neo-card" style="background: linear-gradient(135deg, var(--accent-red), var(--accent)); border: 2px solid var(--accent-red); box-shadow: var(--shadow-red); margin-bottom: 24px;">
                <p style="margin: 0; color: var(--white); font-size: 14px; line-height: 1.6;">
                    ⚠️ ${sessionScope.errorMessage}
                </p>
            </div>
            <c:remove var="errorMessage" scope="session"/>
        </c:if>
        
        <div class="hero mb-16">
            <div>
                <h1 style="margin-top:0;">Tạo Đơn Xin Nghỉ Phép</h1>
                <p>Điền thông tin thời gian và lý do nghỉ. Đơn của bạn sẽ được gửi tới quản lý.</p>
            </div>
            <img src="${pageContext.request.contextPath}/assets/img/home-decor-3.jpg" alt="Create" style="max-width: 400px; max-height: 280px; object-fit: cover;" />
        </div>
        <div class="neo-card tight">

        <form action="${pageContext.request.contextPath}/request/create" method="POST" class="neo-form">
            
            <%-- THAY ĐỔI: Nhập ID Loại phép (Sử dụng ID 1 làm mặc định nếu cần) --%>
            <div class="form-group">
                <label for="leaveTypeID">ID Loại nghỉ phép:</label>
                <input type="text" name="leaveTypeID" id="leaveTypeID" value="1" required>
            </div>
            
            <%-- 2. Ngày Bắt đầu --%>
            <div class="form-group">
                <label for="from">Từ ngày:</label>
                <input type="date" name="from" id="from" required min="">
            </div>
            
            <%-- 3. Ngày Kết thúc --%>
            <div class="form-group">
                <label for="to">Đến ngày:</label>
                <input type="date" name="to" id="to" required min="">
            </div>
            
            <script>
                // Set min date to today (không cho chọn ngày trong quá khứ)
                const today = new Date().toISOString().split('T')[0];
                document.getElementById('from').setAttribute('min', today);
                document.getElementById('to').setAttribute('min', today);
                
                // Validate: Đến ngày phải >= Từ ngày
                document.getElementById('from').addEventListener('change', function() {
                    const fromDate = this.value;
                    const toInput = document.getElementById('to');
                    if (fromDate) {
                        toInput.setAttribute('min', fromDate);
                        if (toInput.value && toInput.value < fromDate) {
                            toInput.value = fromDate;
                        }
                    }
                });
                
                // Validate form before submit
                document.querySelector('form').addEventListener('submit', function(e) {
                    const fromDate = document.getElementById('from').value;
                    const toDate = document.getElementById('to').value;
                    const today = new Date().toISOString().split('T')[0];
                    
                    if (fromDate < today) {
                        e.preventDefault();
                        alert('Không thể xin nghỉ trong quá khứ! Vui lòng chọn ngày từ hôm nay trở đi.');
                        return false;
                    }
                    
                    if (toDate < today) {
                        e.preventDefault();
                        alert('Không thể xin nghỉ trong quá khứ! Vui lòng chọn ngày từ hôm nay trở đi.');
                        return false;
                    }
                    
                    if (toDate < fromDate) {
                        e.preventDefault();
                        alert('Ngày kết thúc phải lớn hơn hoặc bằng ngày bắt đầu!');
                        return false;
                    }
                });
            </script>
            
            <%-- 4. Lý do (Textarea) --%>
            <div class="form-group">
                <label for="reason">Lý do:</label>
                <textarea name="reason" id="reason" rows="5" required></textarea>
            </div>
            
            <div class="actions">
                <button class="neo-btn" type="submit">Gửi đơn</button>
                <a class="neo-btn ghost" href="${pageContext.request.contextPath}/request/list">Danh sách</a>
            </div>
        </form>
        </div>
    </div>
<jsp:include page="/view/layout/neo_footer.jsp" />