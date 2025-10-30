package controller.iam;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Xử lý việc đăng xuất của người dùng.
 * Hủy bỏ session và chuyển hướng về trang đăng nhập.
 *
 * @author admin
 */
@WebServlet(urlPatterns = "/logout")
public class LogoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // 1. Lấy Session hiện tại
        HttpSession session = req.getSession(false); // Lấy session hiện tại (false: không tạo session mới nếu chưa có)
        
        // 2. Kiểm tra và Hủy bỏ Session
        if (session != null) {
            // Hủy toàn bộ session, bao gồm cả đối tượng "auth"
            session.invalidate(); 
        }
        
        // 3. Chuyển hướng người dùng về trang đăng nhập
        // Dùng sendRedirect để đổi URL trên trình duyệt và buộc trình duyệt refresh
        resp.sendRedirect(req.getContextPath() + "/login"); 
    }
    
    // Đăng xuất thường chỉ cần xử lý bằng GET, nhưng ta vẫn giữ doPost để đảm bảo
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        doGet(req, resp);
    }
}