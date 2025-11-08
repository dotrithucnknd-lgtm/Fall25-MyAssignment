package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.PasswordResetRequest;
import model.iam.User;

/**
 * DAO cho bảng PasswordResetRequest - Optimized version
 * @author System
 */
public class PasswordResetRequestDBContext extends DBContext<PasswordResetRequest> {
    
    private static final Logger logger = Logger.getLogger(PasswordResetRequestDBContext.class.getName());
    
    /**
     * Helper method: Map ResultSet to PasswordResetRequest object
     */
    private PasswordResetRequest mapResultSetToRequest(ResultSet rs) throws SQLException {
        PasswordResetRequest prr = new PasswordResetRequest();
        prr.setId(rs.getInt("prr_id"));
        prr.setUser_id(rs.getInt("user_id"));
        prr.setUsername(rs.getString("username"));
        prr.setRequest_time(rs.getTimestamp("request_time"));
        prr.setStatus(rs.getInt("status"));
        
        int processedBy = rs.getInt("processed_by");
        if (processedBy != 0) {
            prr.setProcessed_by(processedBy);
            prr.setProcessed_time(rs.getTimestamp("processed_time"));
        }
        
        prr.setNote(rs.getString("note"));
        
        // Set User object
        String userDisplayname = rs.getString("user_displayname");
        if (userDisplayname != null) {
            User user = new User();
            user.setId(prr.getUser_id());
            user.setUsername(prr.getUsername());
            user.setDisplayname(userDisplayname);
            prr.setUser(user);
        }
        
        // Set ProcessedBy User object
        String processedByDisplayname = rs.getString("processed_by_displayname");
        if (processedByDisplayname != null) {
            User processedByUser = new User();
            processedByUser.setId(processedBy);
            processedByUser.setDisplayname(processedByDisplayname);
            prr.setProcessedByUser(processedByUser);
        }
        
        return prr;
    }
    
    /**
     * Helper method: Check and validate connection
     */
    private boolean validateConnection() {
        try {
            if (connection == null || connection.isClosed()) {
                logger.log(Level.SEVERE, "Connection is null or closed");
                return false;
            }
            return true;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error checking connection", ex);
            return false;
        }
    }
    
    /**
     * Helper method: Close resources safely
     */
    private void closeResources(ResultSet rs, PreparedStatement stm) {
        try {
            if (rs != null) rs.close();
        } catch (SQLException ex) {
            logger.log(Level.WARNING, "Error closing ResultSet", ex);
        }
        try {
            if (stm != null) stm.close();
        } catch (SQLException ex) {
            logger.log(Level.WARNING, "Error closing PreparedStatement", ex);
        }
    }
    
    /**
     * Tạo yêu cầu reset mật khẩu mới
     */
    public int createRequest(int userId, String username) {
        PreparedStatement stm = null;
        ResultSet rs = null;
        try {
            if (!validateConnection()) return -1;
            
            String sql = """
                INSERT INTO PasswordResetRequest (user_id, username, request_time, status)
                VALUES (?, ?, GETDATE(), 0)
                """;
            
            stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setInt(1, userId);
            stm.setString(2, username);
            
            if (stm.executeUpdate() > 0) {
                rs = stm.getGeneratedKeys();
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error creating password reset request", ex);
        } finally {
            closeResources(rs, stm);
            closeConnection();
        }
        return -1;
    }
    
    /**
     * Lấy danh sách yêu cầu với điều kiện tùy chọn
     */
    private ArrayList<PasswordResetRequest> getRequests(String whereClause, String orderBy) {
        ArrayList<PasswordResetRequest> requests = new ArrayList<>();
        PreparedStatement stm = null;
        ResultSet rs = null;
        try {
            if (!validateConnection()) return requests;
            
            String sql = String.format("""
                SELECT 
                    prr.prr_id,
                    prr.user_id,
                    prr.username,
                    prr.request_time,
                    prr.status,
                    prr.processed_by,
                    prr.processed_time,
                    prr.note,
                    u1.displayname as user_displayname,
                    u2.displayname as processed_by_displayname
                FROM PasswordResetRequest prr
                LEFT JOIN [User] u1 ON u1.uid = prr.user_id
                LEFT JOIN [User] u2 ON u2.uid = prr.processed_by
                %s
                ORDER BY %s
                """, whereClause, orderBy);
            
            stm = connection.prepareStatement(sql);
            rs = stm.executeQuery();
            
            while (rs.next()) {
                requests.add(mapResultSetToRequest(rs));
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting password reset requests", ex);
        } finally {
            closeResources(rs, stm);
            closeConnection();
        }
        return requests;
    }
    
    /**
     * Lấy danh sách tất cả yêu cầu reset mật khẩu (cho admin)
     */
    public ArrayList<PasswordResetRequest> getAllRequests() {
        return getRequests("", "prr.request_time DESC");
    }
    
    /**
     * Lấy danh sách yêu cầu đang chờ xử lý (status = 0)
     */
    public ArrayList<PasswordResetRequest> getPendingRequests() {
        return getRequests("WHERE prr.status = 0", "prr.request_time ASC");
    }
    
    /**
     * Cập nhật trạng thái yêu cầu (đã xử lý hoặc hủy)
     */
    public boolean updateRequestStatus(int prrId, int status, int processedBy, String note) {
        PreparedStatement stm = null;
        try {
            if (!validateConnection()) return false;
            
            String sql = """
                UPDATE PasswordResetRequest
                SET status = ?,
                    processed_by = ?,
                    processed_time = GETDATE(),
                    note = ?
                WHERE prr_id = ?
                """;
            
            stm = connection.prepareStatement(sql);
            stm.setInt(1, status);
            stm.setInt(2, processedBy);
            stm.setString(3, note);
            stm.setInt(4, prrId);
            
            return stm.executeUpdate() > 0;
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error updating password reset request status", ex);
        } finally {
            closeResources(null, stm);
            closeConnection();
        }
        return false;
    }
    
    /**
     * Lấy yêu cầu theo ID
     */
    public PasswordResetRequest getRequest(int prrId) {
        PreparedStatement stm = null;
        ResultSet rs = null;
        try {
            if (!validateConnection()) return null;
            
            String sql = """
                SELECT 
                    prr.prr_id,
                    prr.user_id,
                    prr.username,
                    prr.request_time,
                    prr.status,
                    prr.processed_by,
                    prr.processed_time,
                    prr.note,
                    u1.displayname as user_displayname,
                    u2.displayname as processed_by_displayname
                FROM PasswordResetRequest prr
                LEFT JOIN [User] u1 ON u1.uid = prr.user_id
                LEFT JOIN [User] u2 ON u2.uid = prr.processed_by
                WHERE prr.prr_id = ?
                """;
            
            stm = connection.prepareStatement(sql);
            stm.setInt(1, prrId);
            rs = stm.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToRequest(rs);
            }
        } catch (SQLException ex) {
            logger.log(Level.SEVERE, "Error getting password reset request by ID", ex);
        } finally {
            closeResources(rs, stm);
            closeConnection();
        }
        return null;
    }
    
    @Override
    public ArrayList<PasswordResetRequest> list() {
        return getAllRequests();
    }
    
    @Override
    public PasswordResetRequest get(int id) {
        return getRequest(id);
    }
    
    @Override
    public void insert(PasswordResetRequest model) {
        if (model != null) {
            createRequest(model.getUser_id(), model.getUsername());
        }
    }
    
    @Override
    public void update(PasswordResetRequest model) {
        if (model != null && model.getProcessed_by() != null) {
            updateRequestStatus(
                model.getId(),
                model.getStatus(),
                model.getProcessed_by(),
                model.getNote()
            );
        }
    }
    
    @Override
    public void delete(PasswordResetRequest model) {
        // Không xóa, chỉ cập nhật status = 2 (Cancelled)
        if (model != null) {
            updateRequestStatus(model.getId(), 2, 
                model.getProcessed_by() != null ? model.getProcessed_by() : 0, "Đã hủy");
        }
    }
}
