package controller.admin;

import controller.iam.BaseRequiredAuthorizationController;
import dal.UserDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.iam.User;
import util.LogUtil;

/**
 * Controller để reset password cho user (chỉ dành cho admin)
 * @author System
 */
@WebServlet(urlPatterns = "/admin/reset-password")
public class ResetPasswordController extends BaseRequiredAuthorizationController {
    
    private UserDBContext userDB = new UserDBContext();
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Lấy danh sách users để hiển thị trong dropdown
        ArrayList<User> users = userDB.listAll();
        req.setAttribute("users", users);
        
        // Hiển thị form reset password
        req.getRequestDispatcher("/view/admin/reset_password.jsp").forward(req, resp);
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        java.util.logging.Logger logger = java.util.logging.Logger.getLogger(ResetPasswordController.class.getName());
        logger.info("=== Starting password reset process ===");
        
        // Lấy dữ liệu từ form
        String userIdStr = req.getParameter("userId");
        String username = req.getParameter("username");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");
        
        logger.info("Form data received - userId: " + userIdStr + ", username: " + username);
        
        // Validate dữ liệu
        if (newPassword == null || newPassword.trim().isEmpty()) {
            logger.warning("Validation failed: new password is empty");
            req.getSession().setAttribute("errorMessage", "Vui lòng nhập mật khẩu mới.");
            resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
            return;
        }
        
        // Kiểm tra độ dài password
        if (newPassword.length() < 6) {
            logger.warning("Validation failed: password too short");
            req.getSession().setAttribute("errorMessage", "Mật khẩu phải có ít nhất 6 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
            return;
        }
        
        // Kiểm tra confirm password
        if (!newPassword.equals(confirmPassword)) {
            logger.warning("Validation failed: passwords do not match");
            req.getSession().setAttribute("errorMessage", "Mật khẩu xác nhận không khớp.");
            resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
            return;
        }
        
        try {
            boolean success = false;
            String targetUsername = null;
            
            // Xử lý reset password
            if (userIdStr != null && !userIdStr.trim().isEmpty()) {
                // Reset bằng User ID
                try {
                    int userId = Integer.parseInt(userIdStr);
                    logger.info("Resetting password for user ID: " + userId);
                    success = userDB.resetPassword(userId, newPassword);
                    
                    // Lấy username để log
                    User targetUser = userDB.get(userId);
                    if (targetUser != null) {
                        targetUsername = targetUser.getUsername();
                    }
                } catch (NumberFormatException e) {
                    logger.warning("Invalid user ID format: " + userIdStr);
                    req.getSession().setAttribute("errorMessage", "User ID không hợp lệ.");
                    resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
                    return;
                }
            } else if (username != null && !username.trim().isEmpty()) {
                // Reset bằng Username
                targetUsername = username.trim();
                logger.info("Resetting password for username: " + targetUsername);
                success = userDB.resetPasswordByUsername(targetUsername, newPassword);
            } else {
                logger.warning("No user ID or username provided");
                req.getSession().setAttribute("errorMessage", "Vui lòng chọn user hoặc nhập username.");
                resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
                return;
            }
            
            if (success) {
                // Ghi log
                LogUtil.logActivity(
                    user,
                    LogUtil.ActivityType.RESET_PASSWORD,
                    LogUtil.EntityType.USER,
                    userIdStr != null && !userIdStr.trim().isEmpty() ? 
                        Integer.parseInt(userIdStr) : userDB.findUserIdByUsername(targetUsername),
                    "Reset password cho user: " + targetUsername,
                    null,
                    String.format("{\"username\":\"%s\",\"password_reset\":true}", targetUsername),
                    req
                );
                
                logger.info("=== Password reset completed successfully ===");
                req.getSession().setAttribute("successMessage", 
                    "Reset password thành công cho user: " + targetUsername);
                resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
            } else {
                logger.warning("Password reset failed");
                req.getSession().setAttribute("errorMessage", 
                    "Không thể reset password. Vui lòng kiểm tra lại thông tin user.");
                resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
            }
            
        } catch (Exception e) {
            logger.severe("=== Password reset failed ===");
            // Log chi tiết lỗi để debug
            logger.log(java.util.logging.Level.SEVERE, "Error resetting password", e);
            
            // Log stack trace
            java.io.StringWriter sw = new java.io.StringWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(sw);
            e.printStackTrace(pw);
            logger.severe("Stack trace: " + sw.toString());
            
            String errorMsg = "Có lỗi xảy ra: " + e.getMessage();
            if (e.getCause() != null) {
                errorMsg += " (Nguyên nhân: " + e.getCause().getMessage() + ")";
            }
            req.getSession().setAttribute("errorMessage", errorMsg);
            resp.sendRedirect(req.getContextPath() + "/admin/reset-password");
        }
    }
}

