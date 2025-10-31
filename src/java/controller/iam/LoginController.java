package controller.iam;

import dal.UserDBContext; 
import model.iam.User;     

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = "/login") 
public class LoginController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // Lấy tham số (đảm bảo khớp với name="username" và name="password" trong login.jsp)
        String username = req.getParameter("username"); 
        String password = req.getParameter("password"); 
        
        // Khởi tạo DBContext
        UserDBContext db = new UserDBContext();
        User user = db.get(username, password); 
        
        if (user != null) {
            // =========================================================
            // CHUYỂN HƯỚNG THÀNH CÔNG (SUCCESS)
            // =========================================================
            HttpSession session = req.getSession();
            session.setAttribute("auth", user); 
            
            // Redirect sang /home
            // Đây là hành động CHUYỂN HƯỚNG BẮT BUỘC để người dùng thấy thanh địa chỉ đổi sang /home
            resp.sendRedirect(req.getContextPath() + "/home"); 

        } else {
            // =========================================================
            // CHUYỂN HƯỚNG THẤT BẠI (FAILED)
            // =========================================================
            
            // 1. Đặt thông báo lỗi vào Request Scope
            req.setAttribute("message", "Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng thử lại.");
            
            // 2. Forward trở lại trang login.jsp
            // Forward giữ lại Request Scope, nên trang login.jsp có thể đọc được ${message}
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Hiển thị form login
        // Đảm bảo không có thông báo lỗi cũ
        req.removeAttribute("message");
        req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
    }
}