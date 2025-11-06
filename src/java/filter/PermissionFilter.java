package filter;

import dal.RoleDBContext;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.Set;
import model.iam.Feature;
import model.iam.Role;
import model.iam.User;
import util.PermissionUtil;

/**
 * Filter để load quyền của user vào request attribute
 * @author System
 */
public class PermissionFilter implements Filter {
    
    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Không cần khởi tạo gì
    }
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        
        HttpServletRequest httpRequest = (HttpServletRequest) request;
        HttpSession session = httpRequest.getSession(false);
        
        if (session != null) {
            User user = (User) session.getAttribute("auth");
            
            if (user != null) {
                // Load roles nếu user chưa có roles
                if (user.getRoles() == null || user.getRoles().isEmpty()) {
                    RoleDBContext roleDB = new RoleDBContext();
                    ArrayList<Role> roles = roleDB.getByUserId(user.getId());
                    user.setRoles(roles);
                    session.setAttribute("auth", user); // Update session với roles đã load
                }
                
                // Load quyền vào request attribute
                Set<String> permissions = getUserPermissions(user);
                request.setAttribute("userPermissions", permissions);
                
                // Helper methods để kiểm tra quyền trong JSP
                request.setAttribute("hasPermission", new PermissionChecker(user));
            } else {
                // Nếu không có user, set hasPermission để tránh lỗi trong JSP
                request.setAttribute("hasPermission", new PermissionChecker(null));
            }
        } else {
            // Nếu không có session, set hasPermission để tránh lỗi trong JSP
            request.setAttribute("hasPermission", new PermissionChecker(null));
        }
        
        chain.doFilter(request, response);
    }
    
    @Override
    public void destroy() {
        // Không cần cleanup gì
    }
    
    /**
     * Lấy tất cả các URL mà user có quyền truy cập
     */
    private Set<String> getUserPermissions(User user) {
        Set<String> permissions = new HashSet<>();
        
        if (user != null && user.getRoles() != null) {
            for (Role role : user.getRoles()) {
                if (role.getFeatures() != null) {
                    for (Feature feature : role.getFeatures()) {
                        permissions.add(feature.getUrl());
                    }
                }
            }
        }
        
        return permissions;
    }
    
    /**
     * Helper class để kiểm tra quyền trong JSP
     */
    public static class PermissionChecker {
        private final User user;
        
        public PermissionChecker(User user) {
            this.user = user;
        }
        
        public boolean check(String url) {
            return PermissionUtil.hasPermission(user, url);
        }
    }
}

