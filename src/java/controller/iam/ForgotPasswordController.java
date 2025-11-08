package controller.iam;

import dal.PasswordResetRequestDBContext;
import dal.UserDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.iam.User;

/**
 * Controller xử lý yêu cầu quên mật khẩu
 * User có thể gửi yêu cầu reset mật khẩu, yêu cầu sẽ hiển thị cho admin
 */
@WebServlet(urlPatterns = "/forgot-password")
public class ForgotPasswordController extends HttpServlet {
    
    private PasswordResetRequestDBContext prrDB = new PasswordResetRequestDBContext();
    private UserDBContext userDB = new UserDBContext();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        // Hiển thị form quên mật khẩu
        req.getRequestDispatcher("/view/auth/forgot_password.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        String username = req.getParameter("username");
        
        // Validate input
        if (username == null || username.trim().isEmpty()) {
            req.setAttribute("errorMessage", "Vui lòng nhập username.");
            req.getRequestDispatcher("/view/auth/forgot_password.jsp").forward(req, resp);
            return;
        }
        
        try {
            // Kiểm tra username có tồn tại không
            // Tìm user ID từ username
            Integer userId = userDB.findUserIdByUsername(username.trim());
            
            if (userId == null) {
                // Không tìm thấy user, nhưng vẫn hiển thị thông báo thành công để bảo mật
                req.setAttribute("successMessage", 
                    "Nếu username tồn tại, yêu cầu reset mật khẩu đã được gửi đến admin. " +
                    "Vui lòng liên hệ admin để được hỗ trợ.");
                req.getRequestDispatcher("/view/auth/forgot_password.jsp").forward(req, resp);
                return;
            }
            
            // Tạo yêu cầu reset mật khẩu
            int prrId = prrDB.createRequest(userId, username.trim());
            
            if (prrId > 0) {
                Logger.getLogger(ForgotPasswordController.class.getName()).log(Level.INFO,
                    "Password reset request created: prr_id=" + prrId + ", username=" + username);
                
                req.setAttribute("successMessage", 
                    "Yêu cầu reset mật khẩu đã được gửi thành công! " +
                    "Admin sẽ xử lý yêu cầu của bạn sớm nhất có thể. " +
                    "Vui lòng liên hệ admin để được hỗ trợ.");
            } else {
                req.setAttribute("errorMessage", 
                    "Không thể tạo yêu cầu reset mật khẩu. Vui lòng thử lại sau.");
            }
            
        } catch (Exception e) {
            Logger.getLogger(ForgotPasswordController.class.getName()).log(Level.SEVERE,
                "Error creating password reset request", e);
            req.setAttribute("errorMessage", 
                "Có lỗi xảy ra khi xử lý yêu cầu. Vui lòng thử lại sau.");
        }
        
        req.getRequestDispatcher("/view/auth/forgot_password.jsp").forward(req, resp);
    }
}

