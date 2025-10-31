package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.ActivityLog;

/**
 * DBContext cho bảng ActivityLog - Quản lý lịch sử hoạt động
 * @author System
 */
public class ActivityLogDBContext extends DBContext<ActivityLog> {

    /**
     * Ghi log một hoạt động
     */
    public void logActivity(ActivityLog log) {
        try {
            String sql = """
                INSERT INTO ActivityLog 
                    (user_id, employee_id, activity_type, entity_type, entity_id, 
                     action_description, old_value, new_value, ip_address, user_agent, created_at)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, log.getUserId());
            
            if (log.getEmployeeId() != null) {
                stm.setInt(2, log.getEmployeeId());
            } else {
                stm.setNull(2, Types.INTEGER);
            }
            
            stm.setString(3, log.getActivityType());
            
            if (log.getEntityType() != null) {
                stm.setString(4, log.getEntityType());
            } else {
                stm.setNull(4, Types.VARCHAR);
            }
            
            if (log.getEntityId() != null) {
                stm.setInt(5, log.getEntityId());
            } else {
                stm.setNull(5, Types.INTEGER);
            }
            
            stm.setString(6, log.getActionDescription());
            
            if (log.getOldValue() != null) {
                stm.setString(7, log.getOldValue());
            } else {
                stm.setNull(7, Types.NVARCHAR);
            }
            
            if (log.getNewValue() != null) {
                stm.setString(8, log.getNewValue());
            } else {
                stm.setNull(8, Types.NVARCHAR);
            }
            
            if (log.getIpAddress() != null) {
                stm.setString(9, log.getIpAddress());
            } else {
                stm.setNull(9, Types.VARCHAR);
            }
            
            if (log.getUserAgent() != null) {
                stm.setString(10, log.getUserAgent());
            } else {
                stm.setNull(10, Types.VARCHAR);
            }
            
            stm.executeUpdate();
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }

    /**
     * Lấy log theo user_id
     */
    public ArrayList<ActivityLog> getLogsByUserId(int userId) {
        ArrayList<ActivityLog> logs = new ArrayList<>();
        try {
            String sql = """
                SELECT log_id, user_id, employee_id, activity_type, entity_type, entity_id,
                       action_description, old_value, new_value, ip_address, user_agent, created_at
                FROM ActivityLog
                WHERE user_id = ?
                ORDER BY created_at DESC
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, userId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                ActivityLog log = mapResultSetToLog(rs);
                logs.add(log);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }

    /**
     * Lấy log theo activity_type
     */
    public ArrayList<ActivityLog> getLogsByActivityType(String activityType) {
        ArrayList<ActivityLog> logs = new ArrayList<>();
        try {
            String sql = """
                SELECT log_id, user_id, employee_id, activity_type, entity_type, entity_id,
                       action_description, old_value, new_value, ip_address, user_agent, created_at
                FROM ActivityLog
                WHERE activity_type = ?
                ORDER BY created_at DESC
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, activityType);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                ActivityLog log = mapResultSetToLog(rs);
                logs.add(log);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }

    /**
     * Lấy log theo entity (ví dụ: theo request_id)
     */
    public ArrayList<ActivityLog> getLogsByEntity(String entityType, int entityId) {
        ArrayList<ActivityLog> logs = new ArrayList<>();
        try {
            String sql = """
                SELECT al.log_id, al.user_id, al.employee_id, al.activity_type, al.entity_type, al.entity_id,
                       al.action_description, al.old_value, al.new_value, al.ip_address, al.user_agent, al.created_at,
                       e.ename as employee_name
                FROM ActivityLog al
                LEFT JOIN Employee e ON e.eid = al.employee_id
                WHERE al.entity_type = ? AND al.entity_id = ?
                ORDER BY al.created_at DESC
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, entityType);
            stm.setInt(2, entityId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                ActivityLog log = mapResultSetToLog(rs);
                // Store employee name in a way we can access it later
                // We'll add a temporary field or use a DTO
                logs.add(log);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }
    
    /**
     * Lấy log theo entity kèm thông tin employee name (DTO)
     */
    public ArrayList<ActivityLogWithEmployee> getLogsByEntityWithEmployee(String entityType, int entityId) {
        ArrayList<ActivityLogWithEmployee> logs = new ArrayList<>();
        try {
            String sql = """
                SELECT al.log_id, al.user_id, al.employee_id, al.activity_type, al.entity_type, al.entity_id,
                       al.action_description, al.old_value, al.new_value, al.ip_address, al.user_agent, al.created_at,
                       e.ename as employee_name
                FROM ActivityLog al
                LEFT JOIN Employee e ON e.eid = al.employee_id
                WHERE al.entity_type = ? AND al.entity_id = ?
                ORDER BY al.created_at DESC
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, entityType);
            stm.setInt(2, entityId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                ActivityLogWithEmployee dto = new ActivityLogWithEmployee();
                dto.setLog(mapResultSetToLog(rs));
                String empName = rs.getString("employee_name");
                if (empName != null) {
                    dto.setEmployeeName(empName);
                }
                logs.add(dto);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }
    
    /**
     * DTO để chứa ActivityLog kèm employee name
     */
    public static class ActivityLogWithEmployee {
        private ActivityLog log;
        private String employeeName;
        
        public ActivityLog getLog() {
            return log;
        }
        
        public void setLog(ActivityLog log) {
            this.log = log;
        }
        
        public String getEmployeeName() {
            return employeeName;
        }
        
        public void setEmployeeName(String employeeName) {
            this.employeeName = employeeName;
        }
    }

    /**
     * Lấy tất cả logs (có phân trang)
     */
    public ArrayList<ActivityLog> getAllLogs(int page, int pageSize) {
        ArrayList<ActivityLog> logs = new ArrayList<>();
        try {
            String sql = """
                SELECT log_id, user_id, employee_id, activity_type, entity_type, entity_id,
                       action_description, old_value, new_value, ip_address, user_agent, created_at
                FROM ActivityLog
                ORDER BY created_at DESC
                OFFSET ? ROWS FETCH NEXT ? ROWS ONLY
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, (page - 1) * pageSize);
            stm.setInt(2, pageSize);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                ActivityLog log = mapResultSetToLog(rs);
                logs.add(log);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }

    /**
     * Map ResultSet thành ActivityLog object
     */
    private ActivityLog mapResultSetToLog(ResultSet rs) throws SQLException {
        ActivityLog log = new ActivityLog();
        log.setLogId(rs.getInt("log_id"));
        log.setUserId(rs.getInt("user_id"));
        
        int employeeId = rs.getInt("employee_id");
        if (!rs.wasNull()) {
            log.setEmployeeId(employeeId);
        }
        
        log.setActivityType(rs.getString("activity_type"));
        log.setEntityType(rs.getString("entity_type"));
        
        int entityId = rs.getInt("entity_id");
        if (!rs.wasNull()) {
            log.setEntityId(entityId);
        }
        
        log.setActionDescription(rs.getString("action_description"));
        log.setOldValue(rs.getString("old_value"));
        log.setNewValue(rs.getString("new_value"));
        log.setIpAddress(rs.getString("ip_address"));
        log.setUserAgent(rs.getString("user_agent"));
        log.setCreatedAt(rs.getTimestamp("created_at"));
        
        return log;
    }

    // Implement các abstract methods từ DBContext
    @Override
    public ArrayList<ActivityLog> list() {
        return getAllLogs(1, 100);
    }

    @Override
    public ActivityLog get(int id) {
        try {
            String sql = """
                SELECT log_id, user_id, employee_id, activity_type, entity_type, entity_id,
                       action_description, old_value, new_value, ip_address, user_agent, created_at
                FROM ActivityLog
                WHERE log_id = ?
                """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToLog(rs);
            }
            
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }

    @Override
    public void insert(ActivityLog model) {
        logActivity(model);
    }

    @Override
    public void update(ActivityLog model) {
        // ActivityLog thường không được update, chỉ insert
        throw new UnsupportedOperationException("ActivityLog cannot be updated");
    }

    @Override
    public void delete(ActivityLog model) {
        try {
            String sql = "DELETE FROM ActivityLog WHERE log_id = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, model.getLogId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(ActivityLogDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }
}

