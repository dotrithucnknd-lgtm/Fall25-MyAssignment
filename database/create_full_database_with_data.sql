-- ============================================
-- Script tạo Database HOÀN CHỈNH + DỮ LIỆU TEST
-- Hệ thống quản lý nghỉ phép - CHẠY XONG DÙNG NGAY
-- Database: FALL25_Assignment
-- ============================================
-- Script này bao gồm:
-- 1. Tạo tất cả các bảng (13 bảng)
-- 2. Tạo Foreign Keys, Indexes, Views
-- 3. Insert dữ liệu mẫu (Role, Feature, LeaveType)
-- 4. Insert dữ liệu test (Department, Employee, User, Enrollment, UserRole)
-- 5. Insert dữ liệu test (RequestForLeave, Attendance, ActivityLog)
-- ============================================
-- ⚠️ CẢNH BÁO: Script này sẽ XÓA và TẠO LẠI database nếu chạy lần đầu
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU TẠO DATABASE HOÀN CHỈNH';
PRINT '========================================';
PRINT '';

-- ============================================
-- PHẦN 1: XÓA CÁC BẢNG CŨ (NẾU CẦN)
-- ============================================
-- Uncomment nếu muốn xóa và tạo lại từ đầu
/*
PRINT 'Đang xóa các bảng cũ...';

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
-- PHẦN 2: TẠO BẢNG Department
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
-- PHẦN 3: TẠO BẢNG Employee VỚI ĐỆ QUY
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE Employee (
        eid INT IDENTITY(1,1) PRIMARY KEY,
        ename NVARCHAR(255) NOT NULL,
        did INT NULL,
        supervisorid INT NULL
    );
    
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
    BEGIN
        ALTER TABLE Employee
        ADD CONSTRAINT FK_Employee_Department 
        FOREIGN KEY (did) REFERENCES Department(did);
    END
    
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Supervisor 
    FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
    
    CREATE INDEX IX_Employee_Supervisor ON Employee(supervisorid);
    
    PRINT '✓ Đã tạo bảng Employee với đệ quy supervisorid';
END
ELSE
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'supervisorid')
    BEGIN
        ALTER TABLE Employee ADD supervisorid INT NULL;
        ALTER TABLE Employee
        ADD CONSTRAINT FK_Employee_Supervisor 
        FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
        CREATE INDEX IX_Employee_Supervisor ON Employee(supervisorid);
        PRINT '✓ Đã thêm cột supervisorid';
    END
    
    IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'did')
    BEGIN
        ALTER TABLE Employee ADD did INT NULL;
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
        BEGIN
            ALTER TABLE Employee
            ADD CONSTRAINT FK_Employee_Department 
            FOREIGN KEY (did) REFERENCES Department(did);
        END
        PRINT '✓ Đã thêm cột did';
    END
    
    PRINT 'Bảng Employee đã tồn tại';
END
GO

-- ============================================
-- PHẦN 4: TẠO BẢNG User
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
-- PHẦN 5: TẠO BẢNG Enrollment
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    CREATE TABLE Enrollment (
        uid INT NOT NULL,
        eid INT NOT NULL,
        active BIT NOT NULL DEFAULT 1,
        PRIMARY KEY (uid, eid),
        CONSTRAINT FK_Enrollment_User FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE,
        CONSTRAINT FK_Enrollment_Employee FOREIGN KEY (eid) REFERENCES Employee(eid) ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng Enrollment';
END
ELSE
BEGIN
    PRINT 'Bảng Enrollment đã tồn tại';
END
GO

-- ============================================
-- PHẦN 6: TẠO BẢNG Role
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
-- PHẦN 7: TẠO BẢNG Feature
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature')
BEGIN
    CREATE TABLE Feature (
        fid INT IDENTITY(1,1) PRIMARY KEY,
        url NVARCHAR(255) NOT NULL UNIQUE
    );
    PRINT '✓ Đã tạo bảng Feature';
END
ELSE
BEGIN
    PRINT 'Bảng Feature đã tồn tại';
END
GO

-- ============================================
-- PHẦN 8: TẠO BẢNG UserRole
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole')
BEGIN
    CREATE TABLE UserRole (
        uid INT NOT NULL,
        rid INT NOT NULL,
        PRIMARY KEY (uid, rid),
        CONSTRAINT FK_UserRole_User FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE,
        CONSTRAINT FK_UserRole_Role FOREIGN KEY (rid) REFERENCES Role(rid) ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng UserRole';
END
ELSE
BEGIN
    PRINT 'Bảng UserRole đã tồn tại';
END
GO

-- ============================================
-- PHẦN 9: TẠO BẢNG RoleFeature
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RoleFeature')
BEGIN
    CREATE TABLE RoleFeature (
        rid INT NOT NULL,
        fid INT NOT NULL,
        PRIMARY KEY (rid, fid),
        CONSTRAINT FK_RoleFeature_Role FOREIGN KEY (rid) REFERENCES Role(rid) ON DELETE CASCADE,
        CONSTRAINT FK_RoleFeature_Feature FOREIGN KEY (fid) REFERENCES Feature(fid) ON DELETE CASCADE
    );
    PRINT '✓ Đã tạo bảng RoleFeature';
END
ELSE
BEGIN
    PRINT 'Bảng RoleFeature đã tồn tại';
END
GO

-- ============================================
-- PHẦN 10: TẠO BẢNG LeaveType
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveType')
BEGIN
    CREATE TABLE LeaveType (
        leavetype_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        days_allowed INT NOT NULL DEFAULT 12
    );
    PRINT '✓ Đã tạo bảng LeaveType';
END
ELSE
BEGIN
    PRINT 'Bảng LeaveType đã tồn tại';
END
GO

-- ============================================
-- PHẦN 11: TẠO BẢNG RequestForLeave
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    CREATE TABLE RequestForLeave (
        rid INT IDENTITY(1,1) PRIMARY KEY,
        created_by INT NOT NULL,
        created_time DATETIME2 DEFAULT GETDATE(),
        [from] DATE NOT NULL,
        [to] DATE NOT NULL,
        reason NVARCHAR(500),
        status INT NOT NULL DEFAULT 0,
        processed_by INT NULL,
        leavetype_id INT NOT NULL DEFAULT 1,
        CONSTRAINT FK_RequestForLeave_CreatedBy FOREIGN KEY (created_by) REFERENCES Employee(eid),
        CONSTRAINT FK_RequestForLeave_ProcessedBy FOREIGN KEY (processed_by) REFERENCES Employee(eid),
        CONSTRAINT FK_RequestForLeave_LeaveType FOREIGN KEY (leavetype_id) REFERENCES LeaveType(leavetype_id),
        CONSTRAINT CK_RequestForLeave_Dates CHECK ([to] >= [from])
    );
    
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
-- PHẦN 12: TẠO BẢNG RequestForLeaveHistory
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeaveHistory')
BEGIN
    CREATE TABLE RequestForLeaveHistory (
        id INT IDENTITY(1,1) PRIMARY KEY,
        rid INT NOT NULL,
        old_status INT NULL,
        new_status INT NOT NULL,
        processed_by INT NOT NULL,
        processed_time DATETIME2 DEFAULT GETDATE(),
        note NVARCHAR(500)
    );
    
    ALTER TABLE RequestForLeaveHistory
    ADD CONSTRAINT FK_RequestForLeaveHistory_Request 
        FOREIGN KEY (rid) REFERENCES RequestForLeave(rid) ON DELETE CASCADE;
    
    ALTER TABLE RequestForLeaveHistory
    ADD CONSTRAINT FK_RequestForLeaveHistory_ProcessedBy 
        FOREIGN KEY (processed_by) REFERENCES Employee(eid);
    
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
-- PHẦN 13: TẠO BẢNG Attendance
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance')
BEGIN
    CREATE TABLE Attendance (
        attendance_id INT IDENTITY(1,1) PRIMARY KEY,
        employee_id INT NOT NULL,
        request_id INT NULL,
        attendance_date DATE NOT NULL,
        check_in_time TIME NULL,
        check_out_time TIME NULL,
        note NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(eid),
        CONSTRAINT FK_Attendance_RequestForLeave FOREIGN KEY (request_id) REFERENCES RequestForLeave(rid)
    );
    
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
-- PHẦN 14: TẠO BẢNG ActivityLog
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    CREATE TABLE ActivityLog (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        employee_id INT NULL,
        activity_type NVARCHAR(50) NOT NULL,
        entity_type NVARCHAR(50) NULL,
        entity_id INT NULL,
        action_description NVARCHAR(500),
        old_value NVARCHAR(MAX),
        new_value NVARCHAR(MAX),
        ip_address NVARCHAR(50),
        user_agent NVARCHAR(500),
        created_at DATETIME2 DEFAULT GETDATE(),
        CONSTRAINT FK_ActivityLog_User FOREIGN KEY (user_id) REFERENCES [User](uid),
        CONSTRAINT FK_ActivityLog_Employee FOREIGN KEY (employee_id) REFERENCES Employee(eid)
    );
    
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
-- PHẦN 15: TẠO VIEWS
-- ============================================

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActivityLog')
    DROP VIEW vw_ActivityLog;
GO

CREATE VIEW vw_ActivityLog AS
SELECT 
    al.log_id, al.user_id, u.username, u.displayname,
    al.employee_id, e.ename AS employee_name,
    al.activity_type, al.entity_type, al.entity_id,
    al.action_description, al.old_value, al.new_value,
    al.ip_address, al.user_agent, al.created_at
FROM ActivityLog al
LEFT JOIN [User] u ON al.user_id = u.uid
LEFT JOIN Employee e ON al.employee_id = e.eid;
GO

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Attendance')
    DROP VIEW vw_Attendance;
GO

CREATE VIEW vw_Attendance AS
SELECT 
    a.attendance_id, a.employee_id, e.ename AS employee_name,
    a.request_id, r.[from] AS request_from, r.[to] AS request_to, r.reason AS request_reason,
    a.attendance_date, a.check_in_time, a.check_out_time, a.note, a.created_at
FROM Attendance a
INNER JOIN Employee e ON a.employee_id = e.eid
LEFT JOIN RequestForLeave r ON a.request_id = r.rid;
GO

PRINT '✓ Đã tạo Views (vw_ActivityLog, vw_Attendance)';
GO

-- ============================================
-- PHẦN 16: INSERT DỮ LIỆU MẪU
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'BẮT ĐẦU INSERT DỮ LIỆU';
PRINT '========================================';
PRINT '';

-- Insert LeaveType
IF NOT EXISTS (SELECT * FROM LeaveType WHERE leavetype_id = 1)
BEGIN
    INSERT INTO LeaveType (name, days_allowed) VALUES (N'Phép năm', 12);
    PRINT '✓ Đã thêm LeaveType (Phép năm - 12 ngày)';
END

-- Insert Role
IF NOT EXISTS (SELECT * FROM Role WHERE rid = 1)
BEGIN
    INSERT INTO Role (rname) VALUES (N'Admin');
    INSERT INTO Role (rname) VALUES (N'Employee');
    INSERT INTO Role (rname) VALUES (N'Manager');
    PRINT '✓ Đã thêm Role (Admin, Employee, Manager)';
END

-- Insert Feature (tất cả URL patterns)
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
    PRINT '✓ Đã thêm Feature (14 URL patterns)';
END

-- Gán quyền cho Role
IF NOT EXISTS (SELECT * FROM RoleFeature WHERE rid = 1)
BEGIN
    -- Admin: Tất cả quyền
    INSERT INTO RoleFeature (rid, fid) SELECT 1, fid FROM Feature;
    
    -- Manager: Xem, duyệt, agenda, thống kê
    INSERT INTO RoleFeature (rid, fid) SELECT 3, fid FROM Feature WHERE url IN (
        '/request/list', '/request/review', '/request/history', '/attendance/', 
        '/division/agenda', '/statistics', '/home'
    );
    
    -- Employee: Xem, tạo, chấm công
    INSERT INTO RoleFeature (rid, fid) SELECT 2, fid FROM Feature WHERE url IN (
        '/request/list', '/request/create', '/request/history',
        '/attendance/', '/attendance/leave', '/attendance/check/',
        '/attendance/list/', '/attendance/daily', '/home'
    );
    
    PRINT '✓ Đã gán quyền cho Role';
END

-- ============================================
-- PHẦN 17: INSERT DỮ LIỆU TEST
-- ============================================

PRINT '';
PRINT 'Đang tạo dữ liệu test...';

-- Insert Department
IF NOT EXISTS (SELECT * FROM Department WHERE did = 1)
BEGIN
    INSERT INTO Department (dname) VALUES (N'Phòng Nhân Sự');
    INSERT INTO Department (dname) VALUES (N'Phòng Kỹ Thuật');
    INSERT INTO Department (dname) VALUES (N'Phòng Kinh Doanh');
    PRINT '✓ Đã tạo 3 Department';
END

-- Insert Employee với hierarchy (ĐỆ QUY)
-- Chỉ insert nếu chưa có Employee nào (tránh trùng lặp)
IF (SELECT COUNT(*) FROM Employee) = 0
BEGIN
    -- Tạo Giám đốc (không có supervisor)
    DECLARE @Manager1 INT;
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Nguyễn Văn A - Giám đốc', 1, NULL);
    SET @Manager1 = SCOPE_IDENTITY();
    
    -- Tạo Trưởng phòng (supervisor = Giám đốc)
    DECLARE @Manager2 INT, @Manager3 INT;
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Trần Thị B - Trưởng phòng Nhân Sự', 1, @Manager1);
    SET @Manager2 = SCOPE_IDENTITY();
    
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Lê Văn C - Trưởng phòng Kỹ Thuật', 2, @Manager1);
    SET @Manager3 = SCOPE_IDENTITY();
    
    -- Tạo Nhân viên (supervisor = Trưởng phòng)
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Phạm Thị D - Nhân viên Nhân Sự', 1, @Manager2);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Hoàng Văn E - Nhân viên Nhân Sự', 1, @Manager2);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Võ Thị F - Nhân viên Kỹ Thuật', 2, @Manager3);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Đỗ Văn G - Nhân viên Kỹ Thuật', 2, @Manager3);
    
    PRINT '✓ Đã tạo 7 Employee với hierarchy (1 Giám đốc, 2 Trưởng phòng, 4 Nhân viên)';
END
ELSE
BEGIN
    PRINT 'Employee đã có dữ liệu (' + CAST((SELECT COUNT(*) FROM Employee) AS VARCHAR) + ' nhân viên)';
END

-- Insert User
IF NOT EXISTS (SELECT * FROM [User] WHERE username = 'admin')
BEGIN
    DECLARE @AdminUID INT, @ManagerUID INT, @EmpUID INT;
    
    INSERT INTO [User] (username, [password], displayname) VALUES ('admin', 'admin123', N'Quản trị viên');
    SET @AdminUID = SCOPE_IDENTITY();
    
    INSERT INTO [User] (username, [password], displayname) VALUES ('manager1', 'manager123', N'Trưởng phòng B');
    SET @ManagerUID = SCOPE_IDENTITY();
    
    INSERT INTO [User] (username, [password], displayname) VALUES ('employee1', 'emp123', N'Nhân viên D');
    SET @EmpUID = SCOPE_IDENTITY();
    
    -- Lấy Employee IDs (ưu tiên tìm theo pattern, nếu không có thì lấy bất kỳ)
    DECLARE @AdminEID INT;
    SELECT TOP 1 @AdminEID = eid FROM Employee WHERE ename LIKE N'%Giám đốc%' ORDER BY eid;
    IF @AdminEID IS NULL
        SELECT TOP 1 @AdminEID = eid FROM Employee WHERE supervisorid IS NULL ORDER BY eid;
    
    DECLARE @ManagerEID INT;
    SELECT TOP 1 @ManagerEID = eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' AND did = 1 ORDER BY eid;
    IF @ManagerEID IS NULL
        SELECT TOP 1 @ManagerEID = eid FROM Employee WHERE did = 1 AND supervisorid IS NOT NULL ORDER BY eid;
    IF @ManagerEID IS NULL
        SELECT TOP 1 @ManagerEID = eid FROM Employee WHERE supervisorid IS NOT NULL ORDER BY eid;
    
    DECLARE @EmpEID INT;
    SELECT TOP 1 @EmpEID = eid FROM Employee WHERE ename LIKE N'%Nhân viên%' AND did = 1 ORDER BY eid;
    IF @EmpEID IS NULL
        SELECT TOP 1 @EmpEID = eid FROM Employee WHERE did = 1 ORDER BY eid;
    IF @EmpEID IS NULL
        SELECT TOP 1 @EmpEID = eid FROM Employee ORDER BY eid;
    
    -- Insert Enrollment (chỉ nếu có Employee)
    IF @AdminEID IS NOT NULL AND NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @AdminUID AND eid = @AdminEID)
        INSERT INTO Enrollment (uid, eid, active) VALUES (@AdminUID, @AdminEID, 1);
    
    IF @ManagerEID IS NOT NULL AND NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @ManagerUID AND eid = @ManagerEID)
        INSERT INTO Enrollment (uid, eid, active) VALUES (@ManagerUID, @ManagerEID, 1);
    
    IF @EmpEID IS NOT NULL AND NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @EmpUID AND eid = @EmpEID)
        INSERT INTO Enrollment (uid, eid, active) VALUES (@EmpUID, @EmpEID, 1);
    
    -- Insert UserRole
    IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @AdminUID AND rid = 1)
        INSERT INTO UserRole (uid, rid) VALUES (@AdminUID, 1); -- Admin role
    
    IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @ManagerUID AND rid = 3)
        INSERT INTO UserRole (uid, rid) VALUES (@ManagerUID, 3); -- Manager role
    
    IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @EmpUID AND rid = 2)
        INSERT INTO UserRole (uid, rid) VALUES (@EmpUID, 2); -- Employee role
    
    PRINT '✓ Đã tạo 3 User với Enrollment và UserRole';
    PRINT '  - admin/admin123 (Admin)';
    PRINT '  - manager1/manager123 (Manager)';
    PRINT '  - employee1/emp123 (Employee)';
END
ELSE
BEGIN
    PRINT 'User đã có dữ liệu (' + CAST((SELECT COUNT(*) FROM [User]) AS VARCHAR) + ' user)';
END

-- Insert RequestForLeave (để test)
IF NOT EXISTS (SELECT * FROM RequestForLeave WHERE rid = 1)
BEGIN
    -- Lấy Employee ID (ưu tiên nhân viên, nếu không có thì lấy bất kỳ)
    DECLARE @TestEmpID INT;
    SELECT TOP 1 @TestEmpID = eid FROM Employee WHERE ename LIKE N'%Nhân viên%' ORDER BY eid;
    
    -- Nếu không tìm thấy nhân viên, lấy Employee đầu tiên
    IF @TestEmpID IS NULL
    BEGIN
        SELECT TOP 1 @TestEmpID = eid FROM Employee ORDER BY eid;
    END
    
    -- Lấy Manager ID (ưu tiên trưởng phòng, nếu không có thì lấy Employee có supervisorid IS NULL)
    DECLARE @ManagerEID2 INT;
    SELECT TOP 1 @ManagerEID2 = eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' ORDER BY eid;
    
    IF @ManagerEID2 IS NULL
    BEGIN
        SELECT TOP 1 @ManagerEID2 = eid FROM Employee WHERE supervisorid IS NULL ORDER BY eid;
    END
    
    -- Chỉ insert nếu có Employee
    IF @TestEmpID IS NOT NULL
    BEGIN
        -- Tạo đơn chờ duyệt
        INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, leavetype_id)
        VALUES (@TestEmpID, DATEADD(day, 7, CAST(GETDATE() AS DATE)), DATEADD(day, 9, CAST(GETDATE() AS DATE)), N'Nghỉ phép năm', 0, 1);
        
        -- Tạo đơn đã duyệt (nếu có Manager và Manager khác Employee)
        IF @ManagerEID2 IS NOT NULL AND @ManagerEID2 != @TestEmpID
        BEGIN
            INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, processed_by, leavetype_id)
            VALUES (@TestEmpID, DATEADD(day, -10, CAST(GETDATE() AS DATE)), DATEADD(day, -8, CAST(GETDATE() AS DATE)), N'Nghỉ ốm', 1, @ManagerEID2, 1);
        END
        
        PRINT '✓ Đã tạo RequestForLeave (1 chờ duyệt' + CASE WHEN @ManagerEID2 IS NOT NULL AND @ManagerEID2 != @TestEmpID THEN ', 1 đã duyệt' ELSE '' END + ')';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Không tìm thấy Employee để tạo RequestForLeave';
    END
END

-- Insert Attendance (để test)
IF NOT EXISTS (SELECT * FROM Attendance WHERE attendance_id = 1)
BEGIN
    -- Lấy Employee ID (ưu tiên nhân viên, nếu không có thì lấy bất kỳ)
    DECLARE @TestEmpID2 INT;
    SELECT TOP 1 @TestEmpID2 = eid FROM Employee WHERE ename LIKE N'%Nhân viên%' ORDER BY eid;
    
    -- Nếu không tìm thấy nhân viên, lấy Employee đầu tiên
    IF @TestEmpID2 IS NULL
    BEGIN
        SELECT TOP 1 @TestEmpID2 = eid FROM Employee ORDER BY eid;
    END
    
    -- Chỉ insert nếu có Employee
    IF @TestEmpID2 IS NOT NULL
    BEGIN
        -- Lấy RequestForLeave đã duyệt (nếu có)
        DECLARE @RID INT;
        SELECT TOP 1 @RID = rid FROM RequestForLeave WHERE status = 1 ORDER BY rid;
        
        -- Chấm công cho đơn đã duyệt (nếu có)
        IF @RID IS NOT NULL
        BEGIN
            -- Kiểm tra xem đã có Attendance cho request này chưa
            IF NOT EXISTS (SELECT * FROM Attendance WHERE employee_id = @TestEmpID2 AND request_id = @RID AND attendance_date = DATEADD(day, -10, CAST(GETDATE() AS DATE)))
            BEGIN
                INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time, note)
                VALUES (@TestEmpID2, @RID, DATEADD(day, -10, CAST(GETDATE() AS DATE)), '08:00:00', '17:00:00', N'Chấm công ngày nghỉ phép');
            END
        END
        
        -- Chấm công hàng ngày (không có request_id) - chỉ insert nếu chưa có cho ngày hôm nay
        IF NOT EXISTS (SELECT * FROM Attendance WHERE employee_id = @TestEmpID2 AND request_id IS NULL AND attendance_date = CAST(GETDATE() AS DATE))
        BEGIN
            INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time)
            VALUES (@TestEmpID2, NULL, CAST(GETDATE() AS DATE), '08:30:00', '17:30:00');
        END
        
        PRINT '✓ Đã tạo Attendance (1 hàng ngày' + CASE WHEN @RID IS NOT NULL THEN ', 1 theo request' ELSE '' END + ')';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Không tìm thấy Employee để tạo Attendance';
    END
END

-- Insert ActivityLog (để test)
IF NOT EXISTS (SELECT * FROM ActivityLog WHERE log_id = 1)
BEGIN
    DECLARE @EmpUID2 INT;
    SELECT TOP 1 @EmpUID2 = uid FROM [User] WHERE username = 'employee1';
    
    DECLARE @ManagerUID2 INT;
    SELECT TOP 1 @ManagerUID2 = uid FROM [User] WHERE username = 'manager1';
    
    DECLARE @TestEmpID3 INT;
    SELECT TOP 1 @TestEmpID3 = eid FROM Employee WHERE ename LIKE N'%Nhân viên%' ORDER BY eid;
    
    DECLARE @ManagerEID3 INT;
    SELECT TOP 1 @ManagerEID3 = eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' ORDER BY eid;
    
    DECLARE @RID2 INT;
    SELECT TOP 1 @RID2 = rid FROM RequestForLeave ORDER BY rid;
    
    -- Chỉ insert nếu có đủ dữ liệu
    IF @EmpUID2 IS NOT NULL AND @TestEmpID3 IS NOT NULL AND @RID2 IS NOT NULL
    BEGIN
        INSERT INTO ActivityLog (user_id, employee_id, activity_type, entity_type, entity_id, action_description)
        VALUES (@EmpUID2, @TestEmpID3, 'CREATE_REQUEST', 'RequestForLeave', @RID2, N'Tạo đơn xin nghỉ phép');
        
        IF @ManagerUID2 IS NOT NULL AND @ManagerEID3 IS NOT NULL
        BEGIN
            INSERT INTO ActivityLog (user_id, employee_id, activity_type, entity_type, entity_id, action_description)
            VALUES (@ManagerUID2, @ManagerEID3, 'APPROVE_REQUEST', 'RequestForLeave', @RID2, N'Duyệt đơn xin nghỉ phép');
        END
        
        PRINT '✓ Đã tạo ActivityLog (CREATE_REQUEST' + CASE WHEN @ManagerUID2 IS NOT NULL THEN ', APPROVE_REQUEST' ELSE '' END + ')';
    END
    ELSE
    BEGIN
        PRINT '⚠️ Không đủ dữ liệu để tạo ActivityLog';
    END
END

-- ============================================
-- PHẦN 18: KIỂM TRA TỔNG QUÁT
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'KIỂM TRA TỔNG QUÁT';
PRINT '========================================';

DECLARE @tableCount INT = (SELECT COUNT(*) FROM sys.tables WHERE name IN (
    'Department', 'Employee', 'User', 'Enrollment', 
    'Role', 'Feature', 'UserRole', 'RoleFeature',
    'LeaveType', 'RequestForLeave', 'RequestForLeaveHistory',
    'Attendance', 'ActivityLog'
));

IF @tableCount = 13
    PRINT '✓ Tất cả 13 bảng đã được tạo';
ELSE
    PRINT '⚠️ Có ' + CAST(@tableCount AS VARCHAR) + '/13 bảng';

DECLARE @fkCount INT = (SELECT COUNT(*) FROM sys.foreign_keys WHERE name LIKE 'FK_%');
PRINT '✓ Tìm thấy ' + CAST(@fkCount AS VARCHAR) + ' Foreign Keys';

DECLARE @empCount INT = (SELECT COUNT(*) FROM Employee);
DECLARE @userCount INT = (SELECT COUNT(*) FROM [User]);
DECLARE @requestCount INT = (SELECT COUNT(*) FROM RequestForLeave);

PRINT '✓ Employee: ' + CAST(@empCount AS VARCHAR);
PRINT '✓ User: ' + CAST(@userCount AS VARCHAR);
PRINT '✓ RequestForLeave: ' + CAST(@requestCount AS VARCHAR);

-- Test đệ quy
BEGIN TRY
    DECLARE @TestEmpID4 INT = (SELECT TOP 1 eid FROM Employee WHERE supervisorid IS NULL);
    IF @TestEmpID4 IS NOT NULL
    BEGIN
        DECLARE @recursiveCount INT;
        WITH Org AS (
            SELECT eid, 0 as lvl FROM Employee WHERE eid = @TestEmpID4
            UNION ALL
            SELECT c.eid, o.lvl + 1 FROM Employee c JOIN Org o ON c.supervisorid = o.eid
        )
        SELECT @recursiveCount = COUNT(*) FROM Org;
        
        IF @recursiveCount >= 3
            PRINT '✓ Đệ quy SQL hoạt động (' + CAST(@recursiveCount AS VARCHAR) + ' nhân viên trong cây)';
    END
END TRY
BEGIN CATCH
    PRINT '⚠️ Lỗi test đệ quy: ' + ERROR_MESSAGE();
END CATCH

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT! DATABASE ĐÃ SẴN SÀNG';
PRINT '========================================';
PRINT '';
PRINT 'THÔNG TIN ĐĂNG NHẬP:';
PRINT '1. Admin:      username=admin,      password=admin123';
PRINT '2. Manager:    username=manager1,   password=manager123';
PRINT '3. Employee:   username=employee1,  password=emp123';
PRINT '';
PRINT 'CÁC CHỨC NĂNG ĐÃ SẴN SÀNG:';
PRINT '✓ Đăng nhập/Đăng xuất';
PRINT '✓ Phân quyền (Role-Based Access Control)';
PRINT '✓ Đệ quy Employee hierarchy';
PRINT '✓ Tạo/Xem/Duyệt đơn nghỉ phép';
PRINT '✓ Chấm công (theo request và hàng ngày)';
PRINT '✓ Lịch Division (Agenda)';
PRINT '✓ Activity Log';
PRINT '✓ Thống kê';
PRINT '';
PRINT 'Bạn có thể chạy ứng dụng ngay bây giờ!';
GO

