-- Script tạo bảng ActivityLog để ghi lại lịch sử hoạt động
-- Database: FALL25_Assignment

CREATE TABLE ActivityLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    employee_id INT,
    activity_type NVARCHAR(50) NOT NULL, -- 'CREATE_REQUEST', 'APPROVE_REQUEST', 'REJECT_REQUEST', 'VIEW_REQUEST', 'LOGIN', 'LOGOUT', etc.
    entity_type NVARCHAR(50), -- 'RequestForLeave', 'User', etc.
    entity_id INT, -- ID của entity liên quan (ví dụ: rid)
    action_description NVARCHAR(500), -- Mô tả chi tiết hành động
    old_value NVARCHAR(MAX), -- Giá trị cũ (JSON hoặc text)
    new_value NVARCHAR(MAX), -- Giá trị mới (JSON hoặc text)
    ip_address NVARCHAR(50),
    user_agent NVARCHAR(500),
    created_at DATETIME2 DEFAULT GETDATE(),
    
    -- Foreign keys
    CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id) REFERENCES [User](uid),
    CONSTRAINT FK_ActivityLog_Employee FOREIGN KEY (employee_id) REFERENCES Employee(eid)
);

-- Tạo index để tăng hiệu suất truy vấn
CREATE INDEX IX_ActivityLog_User ON ActivityLog(user_id);
CREATE INDEX IX_ActivityLog_ActivityType ON ActivityLog(activity_type);
CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
CREATE INDEX IX_ActivityLog_Entity ON ActivityLog(entity_type, entity_id);

-- Tạo view để dễ xem log
CREATE VIEW vw_ActivityLog AS
SELECT 
    al.log_id,
    al.user_id,
    u.username,
    u.displayname,
    al.employee_id,
    e.ename AS employee_name,
    al.activity_type,
    al.entity_type,
    al.entity_id,
    al.action_description,
    al.old_value,
    al.new_value,
    al.ip_address,
    al.user_agent,
    al.created_at
FROM ActivityLog al
LEFT JOIN [User] u ON al.user_id = u.uid
LEFT JOIN Employee e ON al.employee_id = e.eid;

