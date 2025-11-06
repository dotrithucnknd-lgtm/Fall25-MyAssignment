package util;

import jakarta.servlet.http.HttpServletRequest;
import model.iam.Feature;
import model.iam.Role;
import model.iam.User;

/**
 * Utility class để kiểm tra quyền của user
 * @author System
 */
public class PermissionUtil {
    
    /**
     * Kiểm tra xem user có quyền truy cập URL không
     * @param user User cần kiểm tra
     * @param url URL cần kiểm tra (ví dụ: /request/create)
     * @return true nếu user có quyền, false nếu không
     */
    public static boolean hasPermission(User user, String url) {
        if (user == null || url == null || url.trim().isEmpty()) {
            return false;
        }
        
        // Nếu user chưa có roles, return false
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            return false;
        }
        
        // Kiểm tra xem có role nào có feature với URL này không
        for (Role role : user.getRoles()) {
            if (role.getFeatures() != null) {
                for (Feature feature : role.getFeatures()) {
                    if (url.equals(feature.getUrl())) {
                        return true;
                    }
                }
            }
        }
        
        return false;
    }
    
    /**
     * Kiểm tra quyền từ request (lấy user từ session)
     * @param request HttpServletRequest
     * @param url URL cần kiểm tra
     * @return true nếu user có quyền, false nếu không
     */
    public static boolean hasPermission(HttpServletRequest request, String url) {
        User user = (User) request.getSession().getAttribute("auth");
        return hasPermission(user, url);
    }
}

