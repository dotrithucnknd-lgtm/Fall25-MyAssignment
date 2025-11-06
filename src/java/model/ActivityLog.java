package model;

import java.sql.Timestamp;

/**
 * Model cho bảng ActivityLog - Lưu lịch sử hoạt động của người dùng
 * @author System
 */
public class ActivityLog extends BaseModel {
    private int logId;
    private int userId;
    private Integer employeeId;
    private String activityType; // 'CREATE_REQUEST', 'APPROVE_REQUEST', 'REJECT_REQUEST', etc.
    private String entityType; // 'RequestForLeave', 'User', etc.
    private Integer entityId; // ID của entity liên quan
    private String actionDescription;
    private String oldValue;
    private String newValue;
    private String ipAddress;
    private String userAgent;
    private Timestamp createdAt;

    // Constructors
    public ActivityLog() {
    }

    public ActivityLog(int userId, String activityType, String entityType, Integer entityId, String actionDescription) {
        this.userId = userId;
        this.activityType = activityType;
        this.entityType = entityType;
        this.entityId = entityId;
        this.actionDescription = actionDescription;
    }

    // Getters and Setters
    @Override
    public int getId() {
        return logId;
    }

    @Override
    public void setId(int id) {
        this.logId = id;
    }

    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public Integer getEmployeeId() {
        return employeeId;
    }

    public void setEmployeeId(Integer employeeId) {
        this.employeeId = employeeId;
    }

    public String getActivityType() {
        return activityType;
    }

    public void setActivityType(String activityType) {
        this.activityType = activityType;
    }

    public String getEntityType() {
        return entityType;
    }

    public void setEntityType(String entityType) {
        this.entityType = entityType;
    }

    public Integer getEntityId() {
        return entityId;
    }

    public void setEntityId(Integer entityId) {
        this.entityId = entityId;
    }

    public String getActionDescription() {
        return actionDescription;
    }

    public void setActionDescription(String actionDescription) {
        this.actionDescription = actionDescription;
    }

    public String getOldValue() {
        return oldValue;
    }

    public void setOldValue(String oldValue) {
        this.oldValue = oldValue;
    }

    public String getNewValue() {
        return newValue;
    }

    public void setNewValue(String newValue) {
        this.newValue = newValue;
    }

    public String getIpAddress() {
        return ipAddress;
    }

    public void setIpAddress(String ipAddress) {
        this.ipAddress = ipAddress;
    }

    public String getUserAgent() {
        return userAgent;
    }

    public void setUserAgent(String userAgent) {
        this.userAgent = userAgent;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}







