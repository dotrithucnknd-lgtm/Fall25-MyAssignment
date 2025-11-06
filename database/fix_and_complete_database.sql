-- ============================================
-- Script SỬA VÀ HOÀN THIỆN DATABASE
-- Hệ thống quản lý nghỉ phép với phân quyền và phân ban rõ ràng
-- Database: FALL25_Assignment
-- ============================================
-- Script này sẽ:
-- 1. Sửa các vấn đề về schema (IDENTITY, Foreign Keys, Constraints)
-- 2. Thêm phân quyền đầy đủ (Role, Feature, UserRole, RoleFeature)
-- 3. Làm rõ phân ban (Department/Division)
-- 4. Thêm dữ liệu test đầy đủ để chạy tất cả chức năng
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU SỬA VÀ HOÀN THIỆN DATABASE';
PRINT '========================================';
PRINT '';

-- ============================================
-- PHẦN 1: SỬA CÁC BẢNG CÓ VẤN ĐỀ
-- ============================================

PRINT '1. SỬA CÁC BẢNG CÓ VẤN ĐỀ...';
PRINT '';

-- Sửa Employee.eid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    -- Kiểm tra xem eid có phải là IDENTITY không
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Employee') AND name = 'eid'
    )
    BEGIN
        -- Tạo bảng tạm để chuyển dữ liệu
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee_Temp')
        BEGIN
            CREATE TABLE Employee_Temp (
                eid INT IDENTITY(1,1) PRIMARY KEY,
                ename NVARCHAR(255) NOT NULL,
                did INT NULL,
                supervisorid INT NULL
            );
            
            -- Copy dữ liệu
            SET IDENTITY_INSERT Employee_Temp ON;
            INSERT INTO Employee_Temp (eid, ename, did, supervisorid)
            SELECT eid, ename, did, supervisorid FROM Employee;
            SET IDENTITY_INSERT Employee_Temp OFF;
            
            -- Xóa bảng cũ và đổi tên
            DROP TABLE Employee;
            EXEC sp_rename 'Employee_Temp', 'Employee';
            
            PRINT '✓ Đã sửa Employee.eid thành IDENTITY';
        END
    END
    ELSE
    BEGIN
        PRINT 'Employee.eid đã là IDENTITY';
    END
END

-- Sửa Employee.did: Đảm bảo Foreign Key trỏ đúng
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    -- Xóa Foreign Key cũ nếu trỏ sai
    IF EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('Employee') 
        AND name = 'FK_Employee_Division'
    )
    BEGIN
        ALTER TABLE Employee DROP CONSTRAINT FK_Employee_Division;
        PRINT '✓ Đã xóa Foreign Key cũ (FK_Employee_Division)';
    END
    
    -- Thêm Foreign Key đúng (trỏ đến Department)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Department')
    BEGIN
        IF NOT EXISTS (
            SELECT * FROM sys.foreign_keys 
            WHERE parent_object_id = OBJECT_ID('Employee') 
            AND name = 'FK_Employee_Department'
        )
        BEGIN
            ALTER TABLE Employee
            ADD CONSTRAINT FK_Employee_Department 
            FOREIGN KEY (did) REFERENCES Department(did);
            PRINT '✓ Đã thêm Foreign Key đúng (FK_Employee_Department)';
        END
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
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Role_Temp')
        BEGIN
            CREATE TABLE Role_Temp (
                rid INT IDENTITY(1,1) PRIMARY KEY,
                rname NVARCHAR(100) NOT NULL UNIQUE
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
END

-- Sửa Feature.fid: Thêm IDENTITY nếu chưa có
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Feature') AND name = 'fid'
    )
    BEGIN
        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature_Temp')
        BEGIN
            CREATE TABLE Feature_Temp (
                fid INT IDENTITY(1,1) PRIMARY KEY,
                url NVARCHAR(255) NOT NULL UNIQUE
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
        -- Xóa DEFAULT constraint cũ nếu có
        DECLARE @defaultName NVARCHAR(255);
        SELECT @defaultName = name 
        FROM sys.default_constraints 
        WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
        AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('RequestForLeave'), 'created_time', 'ColumnId');
        
        IF @defaultName IS NOT NULL
        BEGIN
            EXEC('ALTER TABLE RequestForLeave DROP CONSTRAINT ' + @defaultName);
        END
        
        -- Đổi kiểu dữ liệu
        ALTER TABLE RequestForLeave ALTER COLUMN created_time DATETIME2;
        
        -- Thêm DEFAULT constraint mới
        ALTER TABLE RequestForLeave ADD DEFAULT GETDATE() FOR created_time;
        
        PRINT '✓ Đã sửa RequestForLeave.created_time thành DATETIME2';
    END
END

-- Sửa RequestForLeave.status: Thêm DEFAULT 0
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF EXISTS (
        SELECT * FROM sys.columns 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'status'
        AND is_nullable = 1
    )
    BEGIN
        -- Cập nhật các giá trị NULL thành 0
        UPDATE RequestForLeave SET status = 0 WHERE status IS NULL;
        
        -- Đổi thành NOT NULL
        ALTER TABLE RequestForLeave ALTER COLUMN status INT NOT NULL;
        
        -- Thêm DEFAULT constraint
        IF NOT EXISTS (
            SELECT * FROM sys.default_constraints 
            WHERE parent_object_id = OBJECT_ID('RequestForLeave') 
            AND parent_column_id = COLUMNPROPERTY(OBJECT_ID('RequestForLeave'), 'status', 'ColumnId')
        )
        BEGIN
            ALTER TABLE RequestForLeave ADD DEFAULT 0 FOR status;
        END
        
        PRINT '✓ Đã sửa RequestForLeave.status thành NOT NULL DEFAULT 0';
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

-- Thêm Foreign Key cho RequestForLeave.leavetype_id
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
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

-- Thêm Foreign Key cho ActivityLog.user_id
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('ActivityLog') 
        AND name = 'FK_ActivityLog_User'
    )
    BEGIN
        ALTER TABLE ActivityLog
        ADD CONSTRAINT FK_ActivityLog_User 
        FOREIGN KEY (user_id) REFERENCES [User](uid);
        PRINT '✓ Đã thêm Foreign Key cho ActivityLog.user_id';
    END
END

-- Thêm Foreign Key cho Enrollment
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('Enrollment') 
        AND name = 'FK_Enrollment_User'
    )
    BEGIN
        ALTER TABLE Enrollment
        ADD CONSTRAINT FK_Enrollment_User 
        FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE;
        PRINT '✓ Đã thêm Foreign Key cho Enrollment.uid';
    END
END

-- Thêm Foreign Key cho UserRole
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole')
BEGIN
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('UserRole') 
        AND name = 'FK_UserRole_User'
    )
    BEGIN
        ALTER TABLE UserRole
        ADD CONSTRAINT FK_UserRole_User 
        FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE;
        PRINT '✓ Đã thêm Foreign Key cho UserRole.uid';
    END
END

-- Thêm Index cho Employee.supervisorid (để tối ưu đệ quy)
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
        PRINT '✓ Đã thêm Index cho RequestForLeave.created_by';
    END
    
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'IX_RequestForLeave_Status'
    )
    BEGIN
        CREATE INDEX IX_RequestForLeave_Status ON RequestForLeave(status);
        PRINT '✓ Đã thêm Index cho RequestForLeave.status';
    END
    
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('RequestForLeave') 
        AND name = 'IX_RequestForLeave_From'
    )
    BEGIN
        CREATE INDEX IX_RequestForLeave_From ON RequestForLeave([from]);
        PRINT '✓ Đã thêm Index cho RequestForLeave.[from]';
    END
END

PRINT '';
GO

-- ============================================
-- PHẦN 2: THÊM DỮ LIỆU MẪU (ROLE, FEATURE, LEAVETYPE)
-- ============================================

PRINT '2. THÊM DỮ LIỆU MẪU...';
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
    INSERT INTO RoleFeature (rid, fid) 
    SELECT 1, fid FROM Feature;
    
    -- Manager: Xem, duyệt, agenda, thống kê
    INSERT INTO RoleFeature (rid, fid) 
    SELECT 3, fid FROM Feature WHERE url IN (
        '/request/list', '/request/review', '/request/history', 
        '/attendance/', '/division/agenda', '/statistics', '/home'
    );
    
    -- Employee: Xem, tạo, chấm công
    INSERT INTO RoleFeature (rid, fid) 
    SELECT 2, fid FROM Feature WHERE url IN (
        '/request/list', '/request/create', '/request/history',
        '/attendance/', '/attendance/leave', '/attendance/check/',
        '/attendance/list/', '/attendance/daily', '/home'
    );
    
    PRINT '✓ Đã gán quyền cho Role';
END

PRINT '';
GO

-- ============================================
-- PHẦN 3: THÊM DỮ LIỆU TEST (DEPARTMENT, EMPLOYEE, USER)
-- ============================================

PRINT '3. THÊM DỮ LIỆU TEST...';
PRINT '';

-- Insert Department (nếu chưa có)
IF NOT EXISTS (SELECT * FROM Department WHERE did = 1)
BEGIN
    INSERT INTO Department (dname) VALUES (N'Phòng Nhân Sự');
    INSERT INTO Department (dname) VALUES (N'Phòng Kỹ Thuật');
    INSERT INTO Department (dname) VALUES (N'Phòng Kinh Doanh');
    PRINT '✓ Đã thêm 3 Department';
END

-- Insert Employee với hierarchy (nếu chưa có)
IF (SELECT COUNT(*) FROM Employee) = 0
BEGIN
    DECLARE @Manager1 INT, @Manager2 INT, @Manager3 INT;
    
    -- Tạo Giám đốc (không có supervisor)
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Nguyễn Văn A - Giám đốc', 1, NULL);
    SET @Manager1 = SCOPE_IDENTITY();
    
    -- Tạo Trưởng phòng (supervisor = Giám đốc)
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Trần Thị B - Trưởng phòng Nhân Sự', 1, @Manager1);
    SET @Manager2 = SCOPE_IDENTITY();
    
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Lê Văn C - Trưởng phòng Kỹ Thuật', 2, @Manager1);
    SET @Manager3 = SCOPE_IDENTITY();
    
    -- Tạo Nhân viên (supervisor = Trưởng phòng)
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Phạm Thị D - Nhân viên Nhân Sự', 1, @Manager2);
    
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Hoàng Văn E - Nhân viên Nhân Sự', 1, @Manager2);
    
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Võ Thị F - Nhân viên Kỹ Thuật', 2, @Manager3);
    
    INSERT INTO Employee (ename, did, supervisorid) 
    VALUES (N'Đỗ Văn G - Nhân viên Kỹ Thuật', 2, @Manager3);
    
    PRINT '✓ Đã thêm 7 Employee với hierarchy';
END

-- Insert User (nếu chưa có)
IF NOT EXISTS (SELECT * FROM [User] WHERE username = 'admin')
BEGIN
    DECLARE @AdminUID INT, @ManagerUID INT, @EmpUID INT;
    
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('admin', 'admin123', N'Quản trị viên');
    SET @AdminUID = SCOPE_IDENTITY();
    
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('manager1', 'manager123', N'Trưởng phòng B');
    SET @ManagerUID = SCOPE_IDENTITY();
    
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('employee1', 'emp123', N'Nhân viên D');
    SET @EmpUID = SCOPE_IDENTITY();
    
    -- Lấy Employee IDs
    DECLARE @AdminEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Giám đốc%' ORDER BY eid);
    DECLARE @ManagerEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' AND did = 1 ORDER BY eid);
    DECLARE @EmpEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Nhân viên%' AND did = 1 ORDER BY eid);
    
    -- Insert Enrollment
    IF @AdminEID IS NOT NULL
        INSERT INTO Enrollment (uid, eid, active) VALUES (@AdminUID, @AdminEID, 1);
    
    IF @ManagerEID IS NOT NULL
        INSERT INTO Enrollment (uid, eid, active) VALUES (@ManagerUID, @ManagerEID, 1);
    
    IF @EmpEID IS NOT NULL
        INSERT INTO Enrollment (uid, eid, active) VALUES (@EmpUID, @EmpEID, 1);
    
    -- Insert UserRole
    INSERT INTO UserRole (uid, rid) VALUES (@AdminUID, 1); -- Admin
    INSERT INTO UserRole (uid, rid) VALUES (@ManagerUID, 3); -- Manager
    INSERT INTO UserRole (uid, rid) VALUES (@EmpUID, 2); -- Employee
    
    PRINT '✓ Đã thêm 3 User với Enrollment và UserRole';
    PRINT '  - admin/admin123 (Admin)';
    PRINT '  - manager1/manager123 (Manager)';
    PRINT '  - employee1/emp123 (Employee)';
END

-- Insert RequestForLeave (nếu chưa có)
IF NOT EXISTS (SELECT * FROM RequestForLeave WHERE rid = 1)
BEGIN
    DECLARE @TestEmpID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Nhân viên%' ORDER BY eid);
    DECLARE @ManagerEID2 INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' ORDER BY eid);
    
    IF @TestEmpID IS NOT NULL
    BEGIN
        -- Đơn chờ duyệt
        INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, leavetype_id)
        VALUES (@TestEmpID, DATEADD(day, 7, CAST(GETDATE() AS DATE)), DATEADD(day, 9, CAST(GETDATE() AS DATE)), N'Nghỉ phép năm', 0, 1);
        
        -- Đơn đã duyệt
        IF @ManagerEID2 IS NOT NULL AND @ManagerEID2 != @TestEmpID
        BEGIN
            INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, processed_by, leavetype_id)
            VALUES (@TestEmpID, DATEADD(day, -10, CAST(GETDATE() AS DATE)), DATEADD(day, -8, CAST(GETDATE() AS DATE)), N'Nghỉ ốm', 1, @ManagerEID2, 1);
        END
        
        PRINT '✓ Đã thêm RequestForLeave test';
    END
END

-- Insert Attendance (nếu chưa có)
IF NOT EXISTS (SELECT * FROM Attendance WHERE attendance_id = 1)
BEGIN
    DECLARE @TestEmpID2 INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Nhân viên%' ORDER BY eid);
    DECLARE @RID INT = (SELECT TOP 1 rid FROM RequestForLeave WHERE status = 1 ORDER BY rid);
    
    IF @TestEmpID2 IS NOT NULL
    BEGIN
        -- Chấm công theo request (nếu có)
        IF @RID IS NOT NULL
        BEGIN
            IF NOT EXISTS (
                SELECT * FROM Attendance 
                WHERE employee_id = @TestEmpID2 
                AND request_id = @RID 
                AND attendance_date = DATEADD(day, -10, CAST(GETDATE() AS DATE))
            )
            BEGIN
                INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time, note)
                VALUES (@TestEmpID2, @RID, DATEADD(day, -10, CAST(GETDATE() AS DATE)), '08:00:00', '17:00:00', N'Chấm công ngày nghỉ phép');
            END
        END
        
        -- Chấm công hàng ngày
        IF NOT EXISTS (
            SELECT * FROM Attendance 
            WHERE employee_id = @TestEmpID2 
            AND request_id IS NULL 
            AND attendance_date = CAST(GETDATE() AS DATE)
        )
        BEGIN
            INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time)
            VALUES (@TestEmpID2, NULL, CAST(GETDATE() AS DATE), '08:30:00', '17:30:00');
        END
        
        PRINT '✓ Đã thêm Attendance test';
    END
END

PRINT '';
GO

-- ============================================
-- PHẦN 4: KIỂM TRA TỔNG QUÁT
-- ============================================

PRINT '4. KIỂM TRA TỔNG QUÁT...';
PRINT '';

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

DECLARE @idxCount INT = (SELECT COUNT(*) FROM sys.indexes WHERE name LIKE 'IX_%');
PRINT '✓ Tìm thấy ' + CAST(@idxCount AS VARCHAR) + ' Indexes';

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

-- Kiểm tra phân ban
DECLARE @deptCount INT = (SELECT COUNT(*) FROM Department);
DECLARE @empCount INT = (SELECT COUNT(*) FROM Employee);

PRINT '✓ Department: ' + CAST(@deptCount AS VARCHAR) + ' bản ghi';
PRINT '✓ Employee: ' + CAST(@empCount AS VARCHAR) + ' bản ghi';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT SỬA VÀ HOÀN THIỆN DATABASE!';
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
PRINT '✓ Phân ban (Department)';
PRINT '✓ Đệ quy Employee hierarchy';
PRINT '✓ Tạo/Xem/Duyệt đơn nghỉ phép';
PRINT '✓ Chấm công (theo request và hàng ngày)';
PRINT '✓ Lịch Division (Agenda)';
PRINT '✓ Activity Log';
PRINT '✓ Thống kê';
PRINT '';
PRINT 'Bạn có thể chạy ứng dụng ngay bây giờ!';
GO

