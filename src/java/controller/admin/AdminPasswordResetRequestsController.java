package controller.admin;

import controller.iam.BaseRequiredAuthorizationController;
import dal.PasswordResetRequestDBContext;
import dal.UserDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.iam.User;
import model.PasswordResetRequest;
import util.LogUtil;

/**
 * Controller để admin xem và xử lý các yêu cầu reset mật khẩu
 * @author System
 */
@WebServlet(urlPatterns = "/admin/password-reset-requests")
public class AdminPasswordResetRequestsController extends BaseRequiredAuthorizationController {
    
    private PasswordResetRequestDBContext prrDB = new PasswordResetRequestDBContext();
    private UserDBContext userDB = new UserDBContext();
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        try {
            // Lấy danh sách tất cả yêu cầu reset mật khẩu
            ArrayList<PasswordResetRequest> requests = prrDB.getAllRequests();
            req.setAttribute("requests", requests);
            
            // Lấy danh sách yêu cầu đang chờ xử lý (chỉ load khi cần)
            ArrayList<PasswordResetRequest> pendingRequests = prrDB.getPendingRequests();
            req.setAttribute("pendingRequests", pendingRequests);
        } catch (Exception e) {
            Logger.getLogger(AdminPasswordResetRequestsController.class.getName()).log(Level.SEVERE,
                "Error loading password reset requests", e);
            req.setAttribute("requests", new ArrayList<>());
            req.setAttribute("pendingRequests", new ArrayList<>());
        }
        
        // Hiển thị trang quản lý yêu cầu reset mật khẩu
        req.getRequestDispatcher("/view/admin/password_reset_requests.jsp").forward(req, resp);
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        
        String action = req.getParameter("action");
        String prrIdStr = req.getParameter("prrId");
        String note = req.getParameter("note");
        
        if (prrIdStr == null || prrIdStr.trim().isEmpty()) {
            req.getSession().setAttribute("errorMessage", "Không tìm thấy yêu cầu reset mật khẩu.");
            resp.sendRedirect(req.getContextPath() + "/admin/password-reset-requests");
            return;
        }
        
        try {
            int prrId = Integer.parseInt(prrIdStr);
            PasswordResetRequest prr = prrDB.getRequest(prrId);
            
            if (prr == null) {
                req.getSession().setAttribute("errorMessage", "Không tìm thấy yêu cầu reset mật khẩu.");
                resp.sendRedirect(req.getContextPath() + "/admin/password-reset-requests");
                return;
            }
            
            if ("approve".equals(action)) {
                // Xử lý yêu cầu: Reset password về "123"
                String defaultPassword = "123";
                
                // Reset password về mật khẩu mặc định
                boolean success = userDB.resetPassword(prr.getUser_id(), defaultPassword);
                
                if (success) {
                    // Cập nhật trạng thái yêu cầu: Đã xử lý (status = 1)
                    String noteText = note != null && !note.trim().isEmpty() 
                        ? note 
                        : "Đã reset mật khẩu về mặc định (123)";
                    prrDB.updateRequestStatus(prrId, 1, user.getId(), noteText);
                    
                    // Log activity
                    LogUtil.logActivity(
                        user,
                        LogUtil.ActivityType.RESET_PASSWORD,
                        LogUtil.EntityType.USER,
                        prr.getUser_id(),
                        "Reset password cho user: " + prr.getUsername() + " về mặc định (123) - từ yêu cầu reset mật khẩu",
                        null,
                        String.format("{\"username\":\"%s\",\"password_reset\":true,\"from_request\":true,\"default_password\":true}", prr.getUsername()),
                        req
                    );
                    
                    Logger.getLogger(AdminPasswordResetRequestsController.class.getName()).log(Level.INFO,
                        "Password reset completed for user: " + prr.getUsername() + " to default password by admin: " + user.getUsername());
                    
                    req.getSession().setAttribute("successMessage", 
                        "Đã reset mật khẩu thành công cho user: " + prr.getUsername() + ". Mật khẩu mới: 123");
                } else {
                    req.getSession().setAttribute("errorMessage", 
                        "Không thể reset mật khẩu. Vui lòng thử lại.");
                }
                
            } else if ("cancel".equals(action)) {
                // Hủy yêu cầu (status = 2)
                prrDB.updateRequestStatus(prrId, 2, user.getId(), 
                    note != null && !note.trim().isEmpty() ? note : "Đã hủy yêu cầu");
                
                Logger.getLogger(AdminPasswordResetRequestsController.class.getName()).log(Level.INFO,
                    "Password reset request cancelled: prr_id=" + prrId + " by admin: " + user.getUsername());
                
                req.getSession().setAttribute("successMessage", 
                    "Đã hủy yêu cầu reset mật khẩu cho user: " + prr.getUsername());
            }
            
        } catch (NumberFormatException e) {
            Logger.getLogger(AdminPasswordResetRequestsController.class.getName()).log(Level.WARNING,
                "Invalid prrId format: " + prrIdStr);
            req.getSession().setAttribute("errorMessage", "ID yêu cầu không hợp lệ.");
        } catch (Exception e) {
            Logger.getLogger(AdminPasswordResetRequestsController.class.getName()).log(Level.SEVERE,
                "Error processing password reset request", e);
            req.getSession().setAttribute("errorMessage", 
                "Có lỗi xảy ra khi xử lý yêu cầu. Vui lòng thử lại sau.");
        }
        
        resp.sendRedirect(req.getContextPath() + "/admin/password-reset-requests");
    }
}

