-- ============================================
-- Script HOÀN CHỈNH để chạy TẤT CẢ chức năng website
-- Database: FALL25_Assignment
-- ============================================
-- Script này sẽ:
-- 1. Sửa các vấn đề về schema (IDENTITY, Foreign Keys, Constraints)
-- 2. Thêm các bảng còn thiếu (Department, LeaveType, Attendance, ActivityLog, RequestForLeaveHistory)
-- 3. Thêm các View (vw_ActivityLog, vw_Attendance)
-- 4. Thêm dữ liệu mẫu đầy đủ (Role, Feature, LeaveType)
-- 5. Cập nhật phân quyền đầy đủ
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU HOÀN THIỆN DATABASE';
PRINT '========================================';
PRINT '';

-- ============================================
-- PHẦN 1: SỬA CÁC BẢNG CÓ VẤN ĐỀ
-- ============================================

PRINT '1. SỬA CÁC BẢNG CÓ VẤN ĐỀ...';
PRINT '';

-- Sửa User.uid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('User') AND name = 'uid'
    )
    BEGIN
        -- DROP các FOREIGN KEY constraints liên quan đến User
        DECLARE @sql NVARCHAR(MAX) = '';
        SELECT @sql += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID('User');
        IF @sql <> '' EXEC sp_executesql @sql;
        
        -- DROP bảng tạm nếu đã tồn tại (từ lần chạy trước)
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User_Temp')
            DROP TABLE User_Temp;
        
        -- Tạo bảng tạm
        CREATE TABLE User_Temp (
            uid INT IDENTITY(1,1) PRIMARY KEY,
            username NVARCHAR(150) NOT NULL UNIQUE,
            [password] NVARCHAR(150) NOT NULL,
            displayname NVARCHAR(150) NOT NULL
        );
        
        -- Copy dữ liệu
        SET IDENTITY_INSERT User_Temp ON;
        INSERT INTO User_Temp (uid, username, [password], displayname)
        SELECT uid, username, [password], displayname FROM [User];
        SET IDENTITY_INSERT User_Temp OFF;
        
        -- Xóa bảng cũ và đổi tên
        DROP TABLE [User];
        EXEC sp_rename 'User_Temp', 'User';
        
        PRINT '✓ Đã sửa User.uid thành IDENTITY';
    END
END

-- Sửa Role.rid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Role') AND name = 'rid'
    )
    BEGIN
        -- DROP các FOREIGN KEY constraints liên quan đến Role
        DECLARE @sqlRole NVARCHAR(MAX) = '';
        SELECT @sqlRole += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID('Role');
        IF @sqlRole <> '' EXEC sp_executesql @sqlRole;
        
        -- DROP bảng tạm nếu đã tồn tại (từ lần chạy trước)
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role_Temp')
            DROP TABLE Role_Temp;
        
        CREATE TABLE Role_Temp (
            rid INT IDENTITY(1,1) PRIMARY KEY,
            rname NVARCHAR(150) NOT NULL UNIQUE
        );
        
        SET IDENTITY_INSERT Role_Temp ON;
        INSERT INTO Role_Temp (rid, rname)
        SELECT rid, rname FROM Role;
        SET IDENTITY_INSERT Role_Temp OFF;
        
        DROP TABLE Role;
        EXEC sp_rename 'Role_Temp', 'Role';
        
        PRINT '✓ Đã sửa Role.rid thành IDENTITY';
    END
END

-- Sửa Feature.fid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Feature') AND name = 'fid'
    )
    BEGIN
        -- DROP các FOREIGN KEY constraints liên quan đến Feature
        DECLARE @sqlFeature NVARCHAR(MAX) = '';
        SELECT @sqlFeature += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID('Feature');
        IF @sqlFeature <> '' EXEC sp_executesql @sqlFeature;
        
        -- DROP bảng tạm nếu đã tồn tại (từ lần chạy trước)
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature_Temp')
            DROP TABLE Feature_Temp;
        
        CREATE TABLE Feature_Temp (
            fid INT IDENTITY(1,1) PRIMARY KEY,
            url NVARCHAR(500) NOT NULL UNIQUE
        );
        
        SET IDENTITY_INSERT Feature_Temp ON;
        INSERT INTO Feature_Temp (fid, url)
        SELECT fid, url FROM Feature;
        SET IDENTITY_INSERT Feature_Temp OFF;
        
        DROP TABLE Feature;
        EXEC sp_rename 'Feature_Temp', 'Feature';
        
        PRINT '✓ Đã sửa Feature.fid thành IDENTITY';
    END
END

-- Sửa Employee.eid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Employee') AND name = 'eid'
    )
    BEGIN
        -- DROP các FOREIGN KEY constraints liên quan đến Employee (cả referenced và referencing)
        DECLARE @sqlEmployee NVARCHAR(MAX) = '';
        -- DROP các FK mà Employee là referenced table
        SELECT @sqlEmployee += 'ALTER TABLE ' + QUOTENAME(OBJECT_SCHEMA_NAME(parent_object_id)) + '.' + QUOTENAME(OBJECT_NAME(parent_object_id)) + ' DROP CONSTRAINT ' + QUOTENAME(name) + ';'
        FROM sys.foreign_keys
        WHERE referenced_object_id = OBJECT_ID('Employee');
        -- DROP các FK mà Employee là parent table (self-reference)
        SELECT @sqlEmployee += 'ALTER TABLE Employee DROP CONSTRAINT ' + QUOTENAME(name) + ';'
        FROM sys.foreign_keys
        WHERE parent_object_id = OBJECT_ID('Employee');
        IF @sqlEmployee <> '' EXEC sp_executesql @sqlEmployee;
        
        -- DROP bảng tạm nếu đã tồn tại (từ lần chạy trước)
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee_Temp')
            DROP TABLE Employee_Temp;
        
        CREATE TABLE Employee_Temp (
            eid INT IDENTITY(1,1) PRIMARY KEY,
            ename NVARCHAR(255) NOT NULL,
            did INT NOT NULL,
            supervisorid INT NULL
        );
        
        SET IDENTITY_INSERT Employee_Temp ON;
        INSERT INTO Employee_Temp (eid, ename, did, supervisorid)
        SELECT eid, ename, did, supervisorid FROM Employee;
        SET IDENTITY_INSERT Employee_Temp OFF;
        
        DROP TABLE Employee;
        EXEC sp_rename 'Employee_Temp', 'Employee';
        
        -- Thêm lại Foreign Keys (chỉ nếu chưa tồn tại)
        IF NOT EXISTS (
            SELECT * FROM sys.foreign_keys 
            WHERE parent_object_id = OBJECT_ID('Employee') 
            AND name = 'FK_Employee_Division'
        )
        BEGIN
            ALTER TABLE Employee
            ADD CONSTRAINT FK_Employee_Division 
            FOREIGN KEY (did) REFERENCES Division(did);
        END
        
        IF NOT EXISTS (
            SELECT * FROM sys.foreign_keys 
            WHERE parent_object_id = OBJECT_ID('Employee') 
            AND name = 'FK_Employee_Employee'
        )
        BEGIN
            ALTER TABLE Employee
            ADD CONSTRAINT FK_Employee_Employee 
            FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
        END
        
        PRINT '✓ Đã sửa Employee.eid thành IDENTITY';
    END
END

-- Sửa Employee.ename: Đổi từ VARCHAR sang NVARCHAR
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('Employee') 
        AND name = 'ename' 
        AND system_type_id = 167 -- VARCHAR
    )
    BEGIN
        ALTER TABLE Employee ALTER COLUMN ename NVARCHAR(255) NOT NULL;
        PRINT '✓ Đã sửa Employee.ename thành NVARCHAR';
    END
END

-- Sửa RequestForLeave.reason: Đổi từ VARCHAR(MAX) sang NVARCHAR(500)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'reason'
    )
    BEGIN
        ALTER TABLE RequestForLeave ALTER COLUMN reason NVARCHAR(500) NULL;
        PRINT '✓ Đã sửa RequestForLeave.reason thành NVARCHAR(500)';
    END
END

-- Sửa RequestForLeave.created_time: Đổi từ DATETIME sang DATETIME2
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'created_time'
        AND system_type_id = 61 -- DATETIME
    )
    BEGIN
        DECLARE @defaultName1 NVARCHAR(255);
        SELECT @defaultName1 = name 
        FROM sys.default_constraints 
        WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
        AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('RequestForLeave'), 'created_time', 'ColumnId');
        
        IF @defaultName1 IS NOT NULL
        BEGIN
            EXEC('ALTER TABLE RequestForLeave DROP CONSTRAINT ' + @defaultName1);
        END
        
        ALTER TABLE RequestForLeave ALTER COLUMN created_time DATETIME2;
        ALTER TABLE RequestForLeave ADD DEFAULT GETDATE() FOR created_time;
        
        PRINT '✓ Đã sửa RequestForLeave.created_time thành DATETIME2';
    END
END

-- Thêm leavetype_id vào RequestForLeave nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'leavetype_id'
    )
    BEGIN
        ALTER TABLE RequestForLeave ADD leavetype_id INT NOT NULL DEFAULT 1;
        PRINT '✓ Đã thêm cột leavetype_id vào RequestForLeave';
    END
END

-- Thêm CHECK constraint cho RequestForLeave (to >= from)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.check_constraints 
        WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'CK_RequestForLeave_Dates'
    )
    BEGIN
        ALTER TABLE RequestForLeave
        ADD CONSTRAINT CK_RequestForLeave_Dates 
        CHECK ([to] >= [from]);
        PRINT '✓ Đã thêm CHECK constraint cho RequestForLeave';
    END
END

-- Thêm Foreign Key cho RequestForLeave.processed_by
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'FK_RequestForLeave_ProcessedBy'
    )
    BEGIN
        ALTER TABLE RequestForLeave
        ADD CONSTRAINT FK_RequestForLeave_ProcessedBy 
        FOREIGN KEY (processed_by) REFERENCES Employee(eid);
        PRINT '✓ Đã thêm Foreign Key cho RequestForLeave.processed_by';
    END
END

-- Thêm Index cho Employee.supervisorid
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('Employee') 
        AND name = 'IX_Employee_Supervisor'
    )
    BEGIN
        CREATE INDEX IX_Employee_Supervisor ON Employee(supervisorid);
        PRINT '✓ Đã thêm Index cho Employee.supervisorid';
    END
END

-- Thêm Index cho RequestForLeave
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'IX_RequestForLeave_CreatedBy'
    )
    BEGIN
        CREATE INDEX IX_RequestForLeave_CreatedBy ON RequestForLeave(created_by);
    END
    
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'IX_RequestForLeave_Status'
    )
    BEGIN
        CREATE INDEX IX_RequestForLeave_Status ON RequestForLeave(status);
    END
    
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'IX_RequestForLeave_From'
    )
    BEGIN
        CREATE INDEX IX_RequestForLeave_From ON RequestForLeave([from]);
    END
    
    PRINT '✓ Đã thêm Indexes cho RequestForLeave';
END

PRINT '';
GO

-- ============================================
-- PHẦN 2: TẠO CÁC BẢNG CÒN THIẾU
-- ============================================

PRINT '2. TẠO CÁC BẢNG CÒN THIẾU...';
PRINT '';

-- Tạo bảng Department (nếu chưa có)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
BEGIN
    CREATE TABLE Department (
        did INT IDENTITY(1,1) PRIMARY KEY,
        dname NVARCHAR(255) NOT NULL UNIQUE
    );
    PRINT '✓ Đã tạo bảng Department';
END

-- Tạo bảng LeaveType
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveType')
BEGIN
    CREATE TABLE LeaveType (
        leavetype_id INT IDENTITY(1,1) PRIMARY KEY,
        name NVARCHAR(100) NOT NULL,
        days_allowed INT NOT NULL DEFAULT 12
    );
    PRINT '✓ Đã tạo bảng LeaveType';
END

-- Tạo bảng Attendance
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

-- Tạo bảng ActivityLog
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

-- Tạo bảng RequestForLeaveHistory
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeaveHistory')
BEGIN
    CREATE TABLE RequestForLeaveHistory (
        id INT IDENTITY(1,1) PRIMARY KEY,
        rid INT NOT NULL,
        old_status INT NULL,
        new_status INT NOT NULL,
        processed_by INT NOT NULL,
        processed_time DATETIME2 DEFAULT GETDATE(),
        note NVARCHAR(500),
        CONSTRAINT FK_RequestForLeaveHistory_Request 
            FOREIGN KEY (rid) REFERENCES RequestForLeave(rid) ON DELETE CASCADE,
        CONSTRAINT FK_RequestForLeaveHistory_ProcessedBy 
            FOREIGN KEY (processed_by) REFERENCES Employee(eid)
    );
    
    CREATE INDEX IX_RequestForLeaveHistory_Rid ON RequestForLeaveHistory(rid);
    CREATE INDEX IX_RequestForLeaveHistory_ProcessedTime ON RequestForLeaveHistory(processed_time DESC);
    
    PRINT '✓ Đã tạo bảng RequestForLeaveHistory';
END

-- Thêm Foreign Key cho RequestForLeave.leavetype_id
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'LeaveType')
    BEGIN
        IF NOT EXISTS (
            SELECT * FROM sys.foreign_keys 
            WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
            AND name = 'FK_RequestForLeave_LeaveType'
        )
        BEGIN
            ALTER TABLE RequestForLeave
            ADD CONSTRAINT FK_RequestForLeave_LeaveType 
            FOREIGN KEY (leavetype_id) REFERENCES LeaveType(leavetype_id);
            PRINT '✓ Đã thêm Foreign Key cho RequestForLeave.leavetype_id';
        END
    END
END

PRINT '';
GO

-- ============================================
-- PHẦN 3: TẠO CÁC VIEW
-- ============================================

PRINT '3. TẠO CÁC VIEW...';
PRINT '';

-- View ActivityLog
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

PRINT '✓ Đã tạo view vw_ActivityLog';

-- View Attendance
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

PRINT '✓ Đã tạo view vw_Attendance';
PRINT '';
GO

-- ============================================
-- PHẦN 4: THÊM DỮ LIỆU MẪU
-- ============================================

PRINT '4. THÊM DỮ LIỆU MẪU...';
PRINT '';

-- Insert LeaveType
IF NOT EXISTS (SELECT * FROM LeaveType WHERE leavetype_id = 1)
BEGIN
    INSERT INTO LeaveType (name, days_allowed) VALUES (N'Phép năm', 12);
    PRINT '✓ Đã thêm LeaveType (Phép năm - 12 ngày)';
END

-- Insert Role mới (nếu chưa có Admin, Employee, Manager)
-- Kiểm tra xem rid có phải IDENTITY không
DECLARE @RoleHasIdentity BIT = 0;
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('Role') AND name = 'rid'
)
BEGIN
    SET @RoleHasIdentity = 1;
END

IF NOT EXISTS (SELECT * FROM Role WHERE rname = N'Admin')
BEGIN
    IF @RoleHasIdentity = 1
    BEGIN
        INSERT INTO Role (rname) VALUES (N'Admin');
    END
    ELSE
    BEGIN
        DECLARE @MaxRid INT = (SELECT ISNULL(MAX(rid), 0) FROM Role);
        INSERT INTO Role (rid, rname) VALUES (@MaxRid + 1, N'Admin');
    END
    PRINT '✓ Đã thêm Role Admin';
END

IF NOT EXISTS (SELECT * FROM Role WHERE rname = N'Employee')
BEGIN
    IF @RoleHasIdentity = 1
    BEGIN
        INSERT INTO Role (rname) VALUES (N'Employee');
    END
    ELSE
    BEGIN
        SET @MaxRid = (SELECT ISNULL(MAX(rid), 0) FROM Role);
        INSERT INTO Role (rid, rname) VALUES (@MaxRid + 1, N'Employee');
    END
    PRINT '✓ Đã thêm Role Employee';
END

IF NOT EXISTS (SELECT * FROM Role WHERE rname = N'Manager')
BEGIN
    IF @RoleHasIdentity = 1
    BEGIN
        INSERT INTO Role (rname) VALUES (N'Manager');
    END
    ELSE
    BEGIN
        SET @MaxRid = (SELECT ISNULL(MAX(rid), 0) FROM Role);
        INSERT INTO Role (rid, rname) VALUES (@MaxRid + 1, N'Manager');
    END
    PRINT '✓ Đã thêm Role Manager';
END

-- Insert Feature (tất cả URL patterns cần thiết)
IF NOT EXISTS (SELECT * FROM Feature WHERE url = '/request/list')
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

-- Gán quyền cho Role (cập nhật RoleFeature)
-- Admin: Tất cả quyền
DECLARE @AdminRoleID INT = (SELECT rid FROM Role WHERE rname = N'Admin');
IF @AdminRoleID IS NOT NULL
BEGIN
    DELETE FROM RoleFeature WHERE rid = @AdminRoleID;
    INSERT INTO RoleFeature (rid, fid) 
    SELECT @AdminRoleID, fid FROM Feature;
    PRINT '✓ Đã gán quyền cho Admin';
END

-- Manager: Tất cả quyền của Employee + Duyệt đơn + Agenda + Thống kê
DECLARE @ManagerRoleID INT = (SELECT rid FROM Role WHERE rname = N'Manager');
IF @ManagerRoleID IS NOT NULL
BEGIN
    DELETE FROM RoleFeature WHERE rid = @ManagerRoleID;
    INSERT INTO RoleFeature (rid, fid) 
    SELECT @ManagerRoleID, fid FROM Feature WHERE url IN (
        '/request/list', '/request/create', '/request/review', '/request/history', 
        '/attendance/', '/attendance/leave', '/attendance/check/', 
        '/attendance/list/', '/attendance/daily', '/attendance/history',
        '/division/agenda', '/statistics', '/home'
    );
    PRINT '✓ Đã gán quyền cho Manager (bao gồm tất cả quyền của Employee + Review + Agenda)';
END

-- Employee: Xem, tạo, chấm công
DECLARE @EmployeeRoleID INT = (SELECT rid FROM Role WHERE rname = N'Employee');
IF @EmployeeRoleID IS NOT NULL
BEGIN
    DELETE FROM RoleFeature WHERE rid = @EmployeeRoleID;
    INSERT INTO RoleFeature (rid, fid) 
    SELECT @EmployeeRoleID, fid FROM Feature WHERE url IN (
        '/request/list', '/request/create', '/request/history',
        '/attendance/', '/attendance/leave', '/attendance/check/',
        '/attendance/list/', '/attendance/daily', '/attendance/history', '/home'
    );
    PRINT '✓ Đã gán quyền cho Employee';
END

-- Cập nhật RequestForLeave.leavetype_id cho các bản ghi hiện có
IF EXISTS (SELECT * FROM RequestForLeave WHERE leavetype_id IS NULL OR leavetype_id = 0)
BEGIN
    UPDATE RequestForLeave SET leavetype_id = 1 WHERE leavetype_id IS NULL OR leavetype_id = 0;
    PRINT '✓ Đã cập nhật leavetype_id cho RequestForLeave';
END

PRINT '';
GO

-- ============================================
-- PHẦN 5: KIỂM TRA TỔNG QUÁT
-- ============================================

PRINT '5. KIỂM TRA TỔNG QUÁT...';
PRINT '';

DECLARE @tableCount INT = (SELECT COUNT(*) FROM sys.tables WHERE name IN (
    'Division', 'Department', 'Employee', 'User', 'Enrollment', 
    'Role', 'Feature', 'UserRole', 'RoleFeature',
    'LeaveType', 'RequestForLeave', 'RequestForLeaveHistory',
    'Attendance', 'ActivityLog'
));

IF @tableCount >= 13
    PRINT '✓ Tất cả các bảng cần thiết đã được tạo (' + CAST(@tableCount AS VARCHAR) + ' bảng)';
ELSE
    PRINT '⚠️ Có ' + CAST(@tableCount AS VARCHAR) + ' bảng (cần ít nhất 13)';

DECLARE @fkCount INT = (SELECT COUNT(*) FROM sys.foreign_keys WHERE name LIKE 'FK_%');
PRINT '✓ Tìm thấy ' + CAST(@fkCount AS VARCHAR) + ' Foreign Keys';

DECLARE @idxCount INT = (SELECT COUNT(*) FROM sys.indexes WHERE name LIKE 'IX_%');
PRINT '✓ Tìm thấy ' + CAST(@idxCount AS VARCHAR) + ' Indexes';

DECLARE @viewCount INT = (SELECT COUNT(*) FROM sys.views WHERE name LIKE 'vw_%');
PRINT '✓ Tìm thấy ' + CAST(@viewCount AS VARCHAR) + ' Views';

-- Kiểm tra đệ quy
IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Employee') 
    AND name = 'FK_Employee_Employee'
)
    PRINT '✓ Foreign Key đệ quy Employee.supervisorid đã được tạo';
ELSE
    PRINT '✗ Thiếu Foreign Key đệ quy Employee.supervisorid';

-- Kiểm tra phân quyền
DECLARE @roleCount INT = (SELECT COUNT(*) FROM Role);
DECLARE @featureCount INT = (SELECT COUNT(*) FROM Feature);
DECLARE @roleFeatureCount INT = (SELECT COUNT(*) FROM RoleFeature);

PRINT '✓ Role: ' + CAST(@roleCount AS VARCHAR) + ' bản ghi';
PRINT '✓ Feature: ' + CAST(@featureCount AS VARCHAR) + ' bản ghi';
PRINT '✓ RoleFeature: ' + CAST(@roleFeatureCount AS VARCHAR) + ' bản ghi';

-- Kiểm tra dữ liệu
DECLARE @empCount INT = (SELECT COUNT(*) FROM Employee);
DECLARE @userCount INT = (SELECT COUNT(*) FROM [User]);
DECLARE @requestCount INT = (SELECT COUNT(*) FROM RequestForLeave);
DECLARE @leaveTypeCount INT = (SELECT COUNT(*) FROM LeaveType);

PRINT '✓ Employee: ' + CAST(@empCount AS VARCHAR) + ' bản ghi';
PRINT '✓ User: ' + CAST(@userCount AS VARCHAR) + ' bản ghi';
PRINT '✓ RequestForLeave: ' + CAST(@requestCount AS VARCHAR) + ' bản ghi';
PRINT '✓ LeaveType: ' + CAST(@leaveTypeCount AS VARCHAR) + ' bản ghi';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT HOÀN THIỆN DATABASE!';
PRINT '========================================';
PRINT '';
PRINT 'CÁC CHỨC NĂNG ĐÃ SẴN SÀNG:';
PRINT '✓ Đăng nhập/Đăng xuất';
PRINT '✓ Phân quyền (Role-Based Access Control)';
PRINT '✓ Phân ban (Division)';
PRINT '✓ Đệ quy Employee hierarchy';
PRINT '✓ Tạo/Xem/Duyệt đơn nghỉ phép';
PRINT '✓ Chấm công (theo request và hàng ngày)';
PRINT '✓ Lịch Division (Agenda)';
PRINT '✓ Activity Log';
PRINT '✓ Thống kê';
PRINT '';
PRINT 'Bạn có thể chạy ứng dụng ngay bây giờ!';
GO

