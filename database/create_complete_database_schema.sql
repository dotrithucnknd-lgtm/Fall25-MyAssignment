-- ============================================
-- Script tạo Database Schema HOÀN CHỈNH
-- Hệ thống quản lý nghỉ phép với phân quyền đầy đủ
-- Database: FALL25_Assignment
-- ============================================
-- Bao gồm:
-- 1. Tất cả các bảng cần thiết
-- 2. Phân quyền đầy đủ (Role, Feature, UserRole, RoleFeature)
-- 3. Đệ quy SQL (Employee supervisor hierarchy)
-- 4. Tất cả các chức năng: RequestForLeave, Attendance, ActivityLog
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU TẠO DATABASE SCHEMA HOÀN CHỈNH';
PRINT '========================================';
PRINT '';

-- ============================================
-- BƯỚC 1: XÓA CÁC BẢNG CŨ (NẾU CẦN)
-- ============================================
-- ⚠️ CẢNH BÁO: Uncomment phần này nếu muốn xóa và tạo lại từ đầu
/*
PRINT 'Đang xóa các bảng cũ...';

-- Xóa theo thứ tự phụ thuộc
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog') DROP TABLE ActivityLog;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance') DROP TABLE Attendance;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeaveHistory') DROP TABLE RequestForLeaveHistory;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave') DROP TABLE RequestForLeave;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveType') DROP TABLE LeaveType;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RoleFeature') DROP TABLE RoleFeature;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole') DROP TABLE UserRole;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature') DROP TABLE Feature;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role') DROP TABLE Role;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment') DROP TABLE Enrollment;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee') DROP TABLE Employee;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department') DROP TABLE Department;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User') DROP TABLE [User];

PRINT '✓ Đã xóa tất cả các bảng cũ';
PRINT '';
*/

-- ============================================
-- BƯỚC 2: TẠO BẢNG Department (Nếu chưa có)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
BEGIN
    CREATE TABLE Department (
        did INT IDENTITY(1,1) PRIMARY KEY,
        dname NVARCHAR(255) NOT NULL
    );
    PRINT '✓ Đã tạo bảng Department';
END
ELSE
BEGIN
    PRINT 'Bảng Department đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 3: TẠO BẢNG Employee VỚI ĐỆ QUY
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE Employee (
        eid INT IDENTITY(1,1) PRIMARY KEY,
        ename NVARCHAR(255) NOT NULL,
        did INT NULL,                      -- Foreign Key đến Department
        supervisorid INT NULL              -- Foreign Key tự tham chiếu (ĐỆ QUY)
    );
    
    -- Foreign Key đến Department
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
    BEGIN
        ALTER TABLE Employee
        ADD CONSTRAINT FK_Employee_Department 
        FOREIGN KEY (did) REFERENCES Department(did);
    END
    
    -- Foreign Key tự tham chiếu (ĐỆ QUY) - Supervisor hierarchy
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Supervisor 
    FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
    
    -- Index cho supervisorid để tối ưu đệ quy
    CREATE INDEX IX_Employee_Supervisor ON Employee(supervisorid);
    
    PRINT '✓ Đã tạo bảng Employee với đệ quy supervisorid';
END
ELSE
BEGIN
    -- Kiểm tra và thêm supervisorid nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'supervisorid')
    BEGIN
        ALTER TABLE Employee ADD supervisorid INT NULL;
        ALTER TABLE Employee
        ADD CONSTRAINT FK_Employee_Supervisor 
        FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
        CREATE INDEX IX_Employee_Supervisor ON Employee(supervisorid);
        PRINT '✓ Đã thêm cột supervisorid với Foreign Key đệ quy';
    END
    
    -- Kiểm tra và thêm did nếu chưa có
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'did')
    BEGIN
        ALTER TABLE Employee ADD did INT NULL;
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
        BEGIN
            ALTER TABLE Employee
            ADD CONSTRAINT FK_Employee_Department 
            FOREIGN KEY (did) REFERENCES Department(did);
        END
        PRINT '✓ Đã thêm cột did (Department)';
    END
    
    PRINT 'Bảng Employee đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 4: TẠO BẢNG User
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    CREATE TABLE [User] (
        uid INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        [password] NVARCHAR(255) NOT NULL,
        displayname NVARCHAR(255) NOT NULL
    );
    PRINT '✓ Đã tạo bảng User';
END
ELSE
BEGIN
    PRINT 'Bảng User đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 5: TẠO BẢNG Enrollment (User <-> Employee)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    CREATE TABLE Enrollment (
        uid INT NOT NULL,
        eid INT NOT NULL,
        active BIT NOT NULL DEFAULT 1,
        
        PRIMARY KEY (uid, eid),
        
        CONSTRAINT FK_Enrollment_User 
            FOREIGN KEY (uid) REFERENCES [User](uid) 
            ON DELETE CASCADE,
        
        CONSTRAINT FK_Enrollment_Employee 
            FOREIGN KEY (eid) REFERENCES Employee(eid) 
            ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng Enrollment';
END
ELSE
BEGIN
    PRINT 'Bảng Enrollment đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 6: TẠO BẢNG Role (Phân quyền)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    CREATE TABLE Role (
        rid INT IDENTITY(1,1) PRIMARY KEY,
        rname NVARCHAR(100) NOT NULL UNIQUE
    );
    PRINT '✓ Đã tạo bảng Role';
END
ELSE
BEGIN
    PRINT 'Bảng Role đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 7: TẠO BẢNG Feature (Phân quyền)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature')
BEGIN
    CREATE TABLE Feature (
        fid INT IDENTITY(1,1) PRIMARY KEY,
        url NVARCHAR(255) NOT NULL UNIQUE  -- URL pattern để kiểm tra quyền truy cập
    );
    PRINT '✓ Đã tạo bảng Feature';
END
ELSE
BEGIN
    PRINT 'Bảng Feature đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 8: TẠO BẢNG UserRole (User <-> Role)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole')
BEGIN
    CREATE TABLE UserRole (
        uid INT NOT NULL,
        rid INT NOT NULL,
        
        PRIMARY KEY (uid, rid),
        
        CONSTRAINT FK_UserRole_User 
            FOREIGN KEY (uid) REFERENCES [User](uid) 
            ON DELETE CASCADE,
        
        CONSTRAINT FK_UserRole_Role 
            FOREIGN KEY (rid) REFERENCES Role(rid) 
            ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng UserRole';
END
ELSE
BEGIN
    PRINT 'Bảng UserRole đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 9: TẠO BẢNG RoleFeature (Role <-> Feature)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RoleFeature')
BEGIN
    CREATE TABLE RoleFeature (
        rid INT NOT NULL,
        fid INT NOT NULL,
        
        PRIMARY KEY (rid, fid),
        
        CONSTRAINT FK_RoleFeature_Role 
            FOREIGN KEY (rid) REFERENCES Role(rid) 
            ON DELETE CASCADE,
        
        CONSTRAINT FK_RoleFeature_Feature 
            FOREIGN KEY (fid) REFERENCES Feature(fid) 
            ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng RoleFeature';
END
ELSE
BEGIN
    PRINT 'Bảng RoleFeature đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 10: TẠO BẢNG LeaveType
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveType')
BEGIN
    CREATE TABLE LeaveType (
        leavetype_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        days_allowed INT NOT NULL DEFAULT 12  -- Số ngày cho phép (mặc định 12 ngày phép năm)
    );
    PRINT '✓ Đã tạo bảng LeaveType';
END
ELSE
BEGIN
    PRINT 'Bảng LeaveType đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 11: TẠO BẢNG RequestForLeave
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    CREATE TABLE RequestForLeave (
        rid INT IDENTITY(1,1) PRIMARY KEY,
        created_by INT NOT NULL,           -- Employee ID
        created_time DATETIME2 DEFAULT GETDATE(),
        [from] DATE NOT NULL,
        [to] DATE NOT NULL,
        reason NVARCHAR(500),
        status INT NOT NULL DEFAULT 0,     -- 0: Chờ duyệt, 1: Đã duyệt, 2: Đã từ chối
        processed_by INT NULL,            -- Employee ID (người duyệt)
        leavetype_id INT NOT NULL DEFAULT 1,
        
        CONSTRAINT FK_RequestForLeave_CreatedBy 
            FOREIGN KEY (created_by) REFERENCES Employee(eid),
        
        CONSTRAINT FK_RequestForLeave_ProcessedBy 
            FOREIGN KEY (processed_by) REFERENCES Employee(eid),
        
        CONSTRAINT FK_RequestForLeave_LeaveType 
            FOREIGN KEY (leavetype_id) REFERENCES LeaveType(leavetype_id),
        
        CONSTRAINT CK_RequestForLeave_Dates 
            CHECK ([to] >= [from])
    );
    
    -- Indexes
    CREATE INDEX IX_RequestForLeave_CreatedBy ON RequestForLeave(created_by);
    CREATE INDEX IX_RequestForLeave_Status ON RequestForLeave(status);
    CREATE INDEX IX_RequestForLeave_From ON RequestForLeave([from]);
    CREATE INDEX IX_RequestForLeave_To ON RequestForLeave([to]);
    
    PRINT '✓ Đã tạo bảng RequestForLeave';
END
ELSE
BEGIN
    PRINT 'Bảng RequestForLeave đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 12: TẠO BẢNG RequestForLeaveHistory
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeaveHistory')
BEGIN
    CREATE TABLE RequestForLeaveHistory (
        id INT IDENTITY(1,1) PRIMARY KEY,
        rid INT NOT NULL,                  -- RequestForLeave ID
        old_status INT NULL,
        new_status INT NOT NULL,
        processed_by INT NOT NULL,        -- Employee ID
        processed_time DATETIME2 DEFAULT GETDATE(),
        note NVARCHAR(500)
        -- Note: processed_name không cần lưu trong bảng, sẽ JOIN với Employee để lấy
    );
    
    -- Foreign Keys
    ALTER TABLE RequestForLeaveHistory
    ADD CONSTRAINT FK_RequestForLeaveHistory_Request 
        FOREIGN KEY (rid) REFERENCES RequestForLeave(rid) 
        ON DELETE CASCADE;
    
    ALTER TABLE RequestForLeaveHistory
    ADD CONSTRAINT FK_RequestForLeaveHistory_ProcessedBy 
        FOREIGN KEY (processed_by) REFERENCES Employee(eid);
    
    -- Indexes
    CREATE INDEX IX_RequestForLeaveHistory_Rid ON RequestForLeaveHistory(rid);
    CREATE INDEX IX_RequestForLeaveHistory_ProcessedTime ON RequestForLeaveHistory(processed_time DESC);
    
    PRINT '✓ Đã tạo bảng RequestForLeaveHistory';
END
ELSE
BEGIN
    PRINT 'Bảng RequestForLeaveHistory đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 13: TẠO BẢNG Attendance
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance')
BEGIN
    CREATE TABLE Attendance (
        attendance_id INT IDENTITY(1,1) PRIMARY KEY,
        employee_id INT NOT NULL,
        request_id INT NULL,              -- ID của đơn nghỉ phép (có thể NULL nếu chấm công độc lập)
        attendance_date DATE NOT NULL,
        check_in_time TIME NULL,
        check_out_time TIME NULL,
        note NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_Attendance_Employee 
            FOREIGN KEY (employee_id) REFERENCES Employee(eid),
        
        CONSTRAINT FK_Attendance_RequestForLeave 
            FOREIGN KEY (request_id) REFERENCES RequestForLeave(rid)
    );
    
    -- Indexes
    CREATE INDEX IX_Attendance_Employee ON Attendance(employee_id);
    CREATE INDEX IX_Attendance_Request ON Attendance(request_id);
    CREATE INDEX IX_Attendance_Date ON Attendance(attendance_date DESC);
    CREATE INDEX IX_Attendance_Employee_Date ON Attendance(employee_id, attendance_date DESC);
    
    PRINT '✓ Đã tạo bảng Attendance';
END
ELSE
BEGIN
    PRINT 'Bảng Attendance đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 14: TẠO BẢNG ActivityLog
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    CREATE TABLE ActivityLog (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        employee_id INT NULL,
        activity_type NVARCHAR(50) NOT NULL,  -- 'CREATE_REQUEST', 'APPROVE_REQUEST', etc.
        entity_type NVARCHAR(50) NULL,       -- 'RequestForLeave', 'User', etc.
        entity_id INT NULL,                   -- ID của entity liên quan
        action_description NVARCHAR(500),
        old_value NVARCHAR(MAX),
        new_value NVARCHAR(MAX),
        ip_address NVARCHAR(50),
        user_agent NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        
        CONSTRAINT FK_ActivityLog_User 
            FOREIGN KEY (user_id) REFERENCES [User](uid),
        
        CONSTRAINT FK_ActivityLog_Employee 
            FOREIGN KEY (employee_id) REFERENCES Employee(eid)
    );
    
    -- Indexes
    CREATE INDEX IX_ActivityLog_User ON ActivityLog(user_id);
    CREATE INDEX IX_ActivityLog_ActivityType ON ActivityLog(activity_type);
    CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
    CREATE INDEX IX_ActivityLog_Entity ON ActivityLog(entity_type, entity_id);
    
    PRINT '✓ Đã tạo bảng ActivityLog';
END
ELSE
BEGIN
    PRINT 'Bảng ActivityLog đã tồn tại';
END
GO

-- ============================================
-- BƯỚC 15: TẠO CÁC VIEW HỮU ÍCH
-- ============================================

-- View ActivityLog
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActivityLog')
    DROP VIEW vw_ActivityLog;
GO

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
GO
PRINT '✓ Đã tạo view vw_ActivityLog';

-- View Attendance
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Attendance')
    DROP VIEW vw_Attendance;
GO

CREATE VIEW vw_Attendance AS
SELECT 
    a.attendance_id,
    a.employee_id,
    e.ename AS employee_name,
    a.request_id,
    r.[from] AS request_from,
    r.[to] AS request_to,
    r.reason AS request_reason,
    a.attendance_date,
    a.check_in_time,
    a.check_out_time,
    a.note,
    a.created_at
FROM Attendance a
INNER JOIN Employee e ON a.employee_id = e.eid
LEFT JOIN RequestForLeave r ON a.request_id = r.rid;
GO
PRINT '✓ Đã tạo view vw_Attendance';

-- ============================================
-- BƯỚC 16: INSERT DỮ LIỆU MẪU
-- ============================================

-- Insert LeaveType mặc định
IF NOT EXISTS (SELECT * FROM LeaveType WHERE leavetype_id = 1)
BEGIN
    INSERT INTO LeaveType (name, days_allowed) VALUES (N'Phép năm', 12);
    PRINT '✓ Đã thêm LeaveType mặc định (Phép năm - 12 ngày)';
END

-- Insert Role mặc định
IF NOT EXISTS (SELECT * FROM Role WHERE rid = 1)
BEGIN
    INSERT INTO Role (rname) VALUES (N'Admin');
    INSERT INTO Role (rname) VALUES (N'Employee');
    INSERT INTO Role (rname) VALUES (N'Manager');
    PRINT '✓ Đã thêm Role mặc định (Admin, Employee, Manager)';
END

-- Insert Feature mặc định (tất cả các URL pattern trong ứng dụng)
IF NOT EXISTS (SELECT * FROM Feature WHERE fid = 1)
BEGIN
    INSERT INTO Feature (url) VALUES ('/request/list');
    INSERT INTO Feature (url) VALUES ('/request/create');
    INSERT INTO Feature (url) VALUES ('/request/review');
    INSERT INTO Feature (url) VALUES ('/request/history');
    INSERT INTO Feature (url) VALUES ('/attendance/');
    INSERT INTO Feature (url) VALUES ('/attendance/leave');
    INSERT INTO Feature (url) VALUES ('/attendance/check/');
    INSERT INTO Feature (url) VALUES ('/attendance/list/');
    INSERT INTO Feature (url) VALUES ('/attendance/history');
    INSERT INTO Feature (url) VALUES ('/attendance/daily');
    INSERT INTO Feature (url) VALUES ('/division/agenda');
    INSERT INTO Feature (url) VALUES ('/admin/create-user');
    INSERT INTO Feature (url) VALUES ('/statistics');
    INSERT INTO Feature (url) VALUES ('/home');
    PRINT '✓ Đã thêm Feature mặc định (14 URL patterns)';
END

-- Gán quyền cho các Role (Admin có tất cả quyền, Manager có một số quyền, Employee có quyền cơ bản)
IF NOT EXISTS (SELECT * FROM RoleFeature WHERE rid = 1)
BEGIN
    -- Admin: Tất cả quyền
    INSERT INTO RoleFeature (rid, fid) SELECT 1, fid FROM Feature;
    
    -- Manager: Xem danh sách, duyệt đơn, xem agenda, thống kê
    INSERT INTO RoleFeature (rid, fid) SELECT 3, fid FROM Feature WHERE url IN (
        '/request/list', '/request/history', '/attendance/', 
        '/division/agenda', '/statistics', '/home'
    );
    
    -- Employee: Xem danh sách, tạo đơn, chấm công, xem lịch sử
    INSERT INTO RoleFeature (rid, fid) SELECT 2, fid FROM Feature WHERE url IN (
        '/request/list', '/request/create', '/request/history',
        '/attendance/', '/attendance/leave', '/attendance/check/',
        '/attendance/list/', '/attendance/daily', '/home'
    );
    
    PRINT '✓ Đã gán quyền cho các Role (Admin, Manager, Employee)';
END

PRINT '';
PRINT 'Lưu ý: Để test đầy đủ, bạn cần:';
PRINT '1. Tạo Department (nếu chưa có)';
PRINT '2. Tạo Employee với supervisorid (để test đệ quy)';
PRINT '3. Tạo User và Enrollment (link User với Employee)';
PRINT '4. Gán UserRole (gán Role cho User)';
PRINT '5. Tạo RequestForLeave để test các chức năng';
PRINT '';

-- ============================================
-- BƯỚC 17: KIỂM TRA TỔNG QUÁT
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'KIỂM TRA TỔNG QUÁT:';
PRINT '========================================';

-- Kiểm tra các bảng
DECLARE @tableCount INT = 0;
SELECT @tableCount = COUNT(*) FROM sys.tables WHERE name IN (
    'Department', 'Employee', 'User', 'Enrollment', 
    'Role', 'Feature', 'UserRole', 'RoleFeature',
    'LeaveType', 'RequestForLeave', 'RequestForLeaveHistory',
    'Attendance', 'ActivityLog'
);

IF @tableCount = 13
    PRINT '✓ Tất cả 13 bảng đã được tạo thành công';
ELSE
    PRINT '⚠️ Có ' + CAST(@tableCount AS VARCHAR) + '/13 bảng được tìm thấy';

-- Kiểm tra Foreign Keys
DECLARE @fkCount INT = 0;
SELECT @fkCount = COUNT(*) FROM sys.foreign_keys WHERE name LIKE 'FK_%';
PRINT '✓ Tìm thấy ' + CAST(@fkCount AS VARCHAR) + ' Foreign Keys';

-- Kiểm tra Indexes
DECLARE @idxCount INT = 0;
SELECT @idxCount = COUNT(*) FROM sys.indexes WHERE name LIKE 'IX_%';
PRINT '✓ Tìm thấy ' + CAST(@idxCount AS VARCHAR) + ' Indexes';

-- Kiểm tra Views
DECLARE @viewCount INT = 0;
SELECT @viewCount = COUNT(*) FROM sys.views WHERE name LIKE 'vw_%';
PRINT '✓ Tìm thấy ' + CAST(@viewCount AS VARCHAR) + ' Views';

-- Kiểm tra đệ quy Employee
IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Employee') 
    AND name = 'FK_Employee_Supervisor'
)
    PRINT '✓ Foreign Key đệ quy Employee.supervisorid đã được tạo';
ELSE
    PRINT '✗ Thiếu Foreign Key đệ quy Employee.supervisorid';

-- Kiểm tra các Foreign Keys quan trọng
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
    PRINT '✓ FK_Enrollment_User - OK';
ELSE
    PRINT '✗ Thiếu FK_Enrollment_User';

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RequestForLeave_CreatedBy')
    PRINT '✓ FK_RequestForLeave_CreatedBy - OK';
ELSE
    PRINT '✗ Thiếu FK_RequestForLeave_CreatedBy';

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Attendance_Employee')
    PRINT '✓ FK_Attendance_Employee - OK';
ELSE
    PRINT '✗ Thiếu FK_Attendance_Employee';

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
    PRINT '✓ FK_ActivityLog_User - OK';
ELSE
    PRINT '✗ Thiếu FK_ActivityLog_User';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT TẠO DATABASE SCHEMA!';
PRINT '========================================';
PRINT '';
PRINT 'Các bảng đã được tạo:';
PRINT '1. Department - Phòng ban';
PRINT '2. Employee - Nhân viên (có đệ quy supervisorid)';
PRINT '3. User - Người dùng';
PRINT '4. Enrollment - Liên kết User và Employee';
PRINT '5. Role - Vai trò';
PRINT '6. Feature - Tính năng';
PRINT '7. UserRole - Phân quyền User';
PRINT '8. RoleFeature - Phân quyền Role';
PRINT '9. LeaveType - Loại nghỉ phép';
PRINT '10. RequestForLeave - Đơn xin nghỉ phép';
PRINT '11. RequestForLeaveHistory - Lịch sử đơn nghỉ phép';
PRINT '12. Attendance - Chấm công';
PRINT '13. ActivityLog - Lịch sử hoạt động';
PRINT '';
PRINT 'Các View đã được tạo:';
PRINT '1. vw_ActivityLog - View ActivityLog với thông tin User và Employee';
PRINT '2. vw_Attendance - View Attendance với thông tin đầy đủ';
PRINT '';
PRINT 'Các tính năng hỗ trợ:';
PRINT '✓ Đệ quy SQL (Employee supervisor hierarchy)';
PRINT '✓ Phân quyền đầy đủ (Role-Based Access Control)';
PRINT '✓ Lịch sử hoạt động (ActivityLog)';
PRINT '✓ Chấm công theo ngày nghỉ';
PRINT '✓ Lịch sử đơn nghỉ phép';
GO

