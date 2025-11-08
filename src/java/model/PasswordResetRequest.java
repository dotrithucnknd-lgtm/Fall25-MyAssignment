package model;

import java.sql.Timestamp;

/**
 * Model cho bảng PasswordResetRequest
 * @author System
 */
public class PasswordResetRequest extends BaseModel {
    private int user_id;
    private String username;
    private Timestamp request_time;
    private int status; // 0=Pending, 1=Processed, 2=Cancelled
    private Integer processed_by;
    private Timestamp processed_time;
    private String note;
    
    // User object (optional, for display)
    private model.iam.User user;
    private model.iam.User processedByUser;
    
    public int getUser_id() {
        return user_id;
    }
    
    public void setUser_id(int user_id) {
        this.user_id = user_id;
    }
    
    public String getUsername() {
        return username;
    }
    
    public void setUsername(String username) {
        this.username = username;
    }
    
    public Timestamp getRequest_time() {
        return request_time;
    }
    
    public void setRequest_time(Timestamp request_time) {
        this.request_time = request_time;
    }
    
    public int getStatus() {
        return status;
    }
    
    public void setStatus(int status) {
        this.status = status;
    }
    
    public String getStatusText() {
        switch (status) {
            case 0: return "Đang chờ";
            case 1: return "Đã xử lý";
            case 2: return "Đã hủy";
            default: return "Không xác định";
        }
    }
    
    public Integer getProcessed_by() {
        return processed_by;
    }
    
    public void setProcessed_by(Integer processed_by) {
        this.processed_by = processed_by;
    }
    
    public Timestamp getProcessed_time() {
        return processed_time;
    }
    
    public void setProcessed_time(Timestamp processed_time) {
        this.processed_time = processed_time;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public model.iam.User getUser() {
        return user;
    }
    
    public void setUser(model.iam.User user) {
        this.user = user;
    }
    
    public model.iam.User getProcessedByUser() {
        return processedByUser;
    }
    
    public void setProcessedByUser(model.iam.User processedByUser) {
        this.processedByUser = processedByUser;
    }
}

