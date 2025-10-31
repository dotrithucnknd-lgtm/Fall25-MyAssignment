package util;

import dal.ActivityLogDBContext;
import jakarta.servlet.http.HttpServletRequest;
import model.ActivityLog;
import model.iam.User;

/**
 * Utility class để ghi log activity dễ dàng hơn
 * @author System
 */
public class LogUtil {
    
    /**
     * Ghi log một activity
     */
    public static void logActivity(User user, String activityType, String entityType, 
                                   Integer entityId, String description, 
                                   String oldValue, String newValue, HttpServletRequest request) {
        try {
            ActivityLog log = new ActivityLog();
            log.setUserId(user.getId());
            
            if (user.getEmployee() != null) {
                log.setEmployeeId(user.getEmployee().getId());
            }
            
            log.setActivityType(activityType);
            log.setEntityType(entityType);
            log.setEntityId(entityId);
            log.setActionDescription(description);
            log.setOldValue(oldValue);
            log.setNewValue(newValue);
            
            // Lấy IP address
            if (request != null) {
                String ipAddress = getClientIpAddress(request);
                log.setIpAddress(ipAddress);
                
                String userAgent = request.getHeader("User-Agent");
                log.setUserAgent(userAgent);
            }
            
            ActivityLogDBContext logDB = new ActivityLogDBContext();
            logDB.logActivity(log);
            
        } catch (Exception e) {
            // Không throw exception để không ảnh hưởng đến flow chính
            System.err.println("Error logging activity: " + e.getMessage());
        }
    }
    
    /**
     * Ghi log đơn giản (không có entity)
     */
    public static void logSimpleActivity(User user, String activityType, String description, 
                                         HttpServletRequest request) {
        logActivity(user, activityType, null, null, description, null, null, request);
    }
    
    /**
     * Lấy IP address thực của client
     */
    private static String getClientIpAddress(HttpServletRequest request) {
        String xForwardedFor = request.getHeader("X-Forwarded-For");
        if (xForwardedFor != null && !xForwardedFor.isEmpty()) {
            return xForwardedFor.split(",")[0].trim();
        }
        
        String xRealIp = request.getHeader("X-Real-IP");
        if (xRealIp != null && !xRealIp.isEmpty()) {
            return xRealIp;
        }
        
        return request.getRemoteAddr();
    }
    
    // Các constants cho activity types
    public static class ActivityType {
        public static final String CREATE_REQUEST = "CREATE_REQUEST";
        public static final String APPROVE_REQUEST = "APPROVE_REQUEST";
        public static final String REJECT_REQUEST = "REJECT_REQUEST";
        public static final String VIEW_REQUEST = "VIEW_REQUEST";
        public static final String VIEW_REQUEST_LIST = "VIEW_REQUEST_LIST";
        public static final String LOGIN = "LOGIN";
        public static final String LOGOUT = "LOGOUT";
        public static final String UPDATE_PROFILE = "UPDATE_PROFILE";
    }
    
    // Các constants cho entity types
    public static class EntityType {
        public static final String REQUEST_FOR_LEAVE = "RequestForLeave";
        public static final String USER = "User";
        public static final String EMPLOYEE = "Employee";
    }
}

