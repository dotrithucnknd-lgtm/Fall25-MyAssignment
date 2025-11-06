package controller.iam;

import dal.UserDBContext; 
import model.iam.User;     
import java.util.logging.Level;
import java.util.logging.Logger;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = "/login") 
public class LoginController extends HttpServlet {
    
    private static final Logger logger = Logger.getLogger(LoginController.class.getName());

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        
        // DEBUG: Log bắt đầu login process
        System.out.println("=== DEBUG LOGIN START ===");
        
        // Lấy tham số từ form (đảm bảo khớp với name="username" và name="password" trong login.jsp)
        String username = req.getParameter("username"); 
        String password = req.getParameter("password"); 
        
        // DEBUG: Log input nhận được
        System.out.println("DEBUG: Username received: [" + username + "]");
        System.out.println("DEBUG: Password received: [" + (password != null ? "***" : "null") + "]");
        logger.log(Level.INFO, "Login attempt for username: " + username);
        
        // Validate input
        if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
            System.out.println("DEBUG: Validation failed - empty username or password");
            req.setAttribute("message", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
            return;
        }
        
        try {
            // DEBUG: Log trước khi gọi DAO
            System.out.println("DEBUG: Creating UserDBContext...");
            
            // Sử dụng DAO để lấy account từ database
            UserDBContext userDB = new UserDBContext();
            
            System.out.println("DEBUG: Calling userDB.get(username, password)...");
            System.out.println("DEBUG: Username: [" + username.trim() + "], Password length: " + password.length());
            
            User user = userDB.get(username, password); 
            
            System.out.println("DEBUG: userDB.get() returned: " + (user != null ? "NOT NULL" : "NULL"));
            
            if (user != null) {
                // =========================================================
                // ĐĂNG NHẬP THÀNH CÔNG (SUCCESS)
                // =========================================================
                System.out.println("DEBUG: Login SUCCESS for user: " + username);
                System.out.println("DEBUG: User ID: " + user.getId());
                System.out.println("DEBUG: User Display Name: " + user.getDisplayname());
                logger.log(Level.INFO, "User logged in successfully: " + username);
                
                // Lưu thông tin user vào session
                HttpSession session = req.getSession();
                session.setAttribute("auth", user); 
                
                System.out.println("DEBUG: User saved to session, redirecting to /home");
                
                // Redirect sang /home sau khi đăng nhập thành công
                resp.sendRedirect(req.getContextPath() + "/home"); 

            } else {
                // =========================================================
                // ĐĂNG NHẬP THẤT BẠI (FAILED)
                // =========================================================
                System.out.println("DEBUG: Login FAILED - user is NULL");
                logger.log(Level.WARNING, "Login failed for username: " + username);
                
                // Đặt thông báo lỗi vào Request Scope
                req.setAttribute("message", "Tên đăng nhập hoặc mật khẩu không đúng. Vui lòng thử lại.");
                
                // Forward trở lại trang login.jsp
                // Forward giữ lại Request Scope, nên trang login.jsp có thể đọc được ${message}
                req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
            }
        } catch (Exception ex) {
            // Xử lý lỗi không mong đợi
            System.out.println("DEBUG: EXCEPTION during login: " + ex.getMessage());
            ex.printStackTrace();
            logger.log(Level.SEVERE, "Error during login process: " + ex.getMessage(), ex);
            req.setAttribute("message", "Đã xảy ra lỗi trong quá trình đăng nhập. Vui lòng thử lại sau.");
            req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
        }
        
        System.out.println("=== DEBUG LOGIN END ===");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Hiển thị form login
        // Đảm bảo không có thông báo lỗi cũ
        req.removeAttribute("message");
        req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
    }
}