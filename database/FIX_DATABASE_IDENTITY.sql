-- ============================================
-- Script FIX CỨNG Database - Tạo lại với IDENTITY
-- Dùng khi không thể sửa trực tiếp
-- ============================================
-- ⚠️ CẢNH BÁO: Script này sẽ XÓA và TẠO LẠI các bảng!
-- ⚠️ BACKUP DATABASE TRƯỚC KHI CHẠY!
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU FIX DATABASE SCHEMA';
PRINT '========================================';
PRINT '';

-- ============================================
-- BƯỚC 1: LƯU DỮ LIỆU (BACKUP) - Nếu có dữ liệu quan trọng
-- ============================================

-- Tạo bảng tạm để backup dữ liệu Employee (nếu có)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee' AND (SELECT COUNT(*) FROM Employee) > 0)
BEGIN
    PRINT 'Đang backup dữ liệu Employee...';
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee_backup')
    BEGIN
        SELECT * INTO Employee_backup FROM Employee;
        PRINT '✓ Đã backup Employee vào Employee_backup';
    END
END

-- Tạo bảng tạm để backup dữ liệu User (nếu có)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND (SELECT COUNT(*) FROM [User]) > 0)
BEGIN
    PRINT 'Đang backup dữ liệu User...';
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User_backup')
    BEGIN
        SELECT * INTO [User_backup] FROM [User];
        PRINT '✓ Đã backup User vào User_backup';
    END
END

PRINT '';

-- ============================================
-- BƯỚC 2: XÓA TẤT CẢ FOREIGN KEYS và CONSTRAINTS
-- ============================================

PRINT 'Đang xóa Foreign Keys...';

-- Xóa Foreign Keys từ ActivityLog
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
BEGIN
    ALTER TABLE ActivityLog DROP CONSTRAINT FK_ActivityLog_User;
    PRINT '✓ Đã xóa FK_ActivityLog_User';
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_Employee')
BEGIN
    ALTER TABLE ActivityLog DROP CONSTRAINT FK_ActivityLog_Employee;
    PRINT '✓ Đã xóa FK_ActivityLog_Employee';
END

-- Xóa Foreign Keys từ Enrollment
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
BEGIN
    ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_User;
    PRINT '✓ Đã xóa FK_Enrollment_User';
END

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_Employee')
BEGIN
    ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Employee;
    PRINT '✓ Đã xóa FK_Enrollment_Employee';
END

-- Xóa Foreign Keys từ Employee (nếu có FK đến Division)
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('Employee'))
BEGIN
    DECLARE @fk_name VARCHAR(255);
    DECLARE fk_cursor CURSOR FOR
        SELECT name FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('Employee');
    
    OPEN fk_cursor;
    FETCH NEXT FROM fk_cursor INTO @fk_name;
    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC('ALTER TABLE Employee DROP CONSTRAINT ' + @fk_name);
        PRINT '✓ Đã xóa ' + @fk_name;
        FETCH NEXT FROM fk_cursor INTO @fk_name;
    END
    CLOSE fk_cursor;
    DEALLOCATE fk_cursor;
END

-- Xóa Foreign Keys từ RequestForLeave (nếu có)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    IF EXISTS (SELECT * FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('RequestForLeave'))
    BEGIN
        DECLARE @fk_name2 VARCHAR(255);
        DECLARE fk_cursor2 CURSOR FOR
            SELECT name FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('RequestForLeave');
        
        OPEN fk_cursor2;
        FETCH NEXT FROM fk_cursor2 INTO @fk_name2;
        WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC('ALTER TABLE RequestForLeave DROP CONSTRAINT ' + @fk_name2);
            FETCH NEXT FROM fk_cursor2 INTO @fk_name2;
        END
        CLOSE fk_cursor2;
        DEALLOCATE fk_cursor2;
    END
END

PRINT '';

-- ============================================
-- BƯỚC 3: XÓA CÁC BẢNG THEO THỨ TỰ ĐÚNG
-- ============================================

PRINT 'Đang xóa các bảng...';

-- Xóa bảng phụ thuộc trước
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    DROP TABLE ActivityLog;
    PRINT '✓ Đã xóa bảng ActivityLog';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    DROP TABLE Enrollment;
    PRINT '✓ Đã xóa bảng Enrollment';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole')
BEGIN
    DROP TABLE UserRole;
    PRINT '✓ Đã xóa bảng UserRole';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave')
BEGIN
    DROP TABLE RequestForLeave;
    PRINT '✓ Đã xóa bảng RequestForLeave';
END

-- Xóa bảng chính
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    DROP TABLE Employee;
    PRINT '✓ Đã xóa bảng Employee';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    DROP TABLE [User];
    PRINT '✓ Đã xóa bảng User';
END

PRINT '';

-- ============================================
-- BƯỚC 4: TẠO LẠI BẢNG Employee VỚI IDENTITY
-- ============================================

PRINT 'Đang tạo lại bảng Employee với IDENTITY...';

CREATE TABLE Employee (
    eid INT IDENTITY(1,1) PRIMARY KEY,  -- IDENTITY tự động tăng
    ename NVARCHAR(255) NOT NULL,      -- Tên nhân viên
    did INT NULL,                      -- Foreign Key đến Division (sẽ tạo sau)
    supervisorid INT NULL              -- Foreign Key tự tham chiếu
);

PRINT '✓ Đã tạo bảng Employee với eid IDENTITY(1,1)';

-- Tạo Foreign Key tự tham chiếu (supervisorid)
ALTER TABLE Employee
ADD CONSTRAINT FK_Employee_Supervisor 
FOREIGN KEY (supervisorid) REFERENCES Employee(eid);

PRINT '✓ Đã tạo Foreign Key tự tham chiếu cho Employee';

-- Tạo Foreign Key đến Division (nếu bảng Division tồn tại)
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Division')
BEGIN
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Division 
    FOREIGN KEY (did) REFERENCES Division(did);
    PRINT '✓ Đã tạo Foreign Key đến Division';
END

PRINT '';

-- ============================================
-- BƯỚC 5: TẠO LẠI BẢNG User VỚI IDENTITY
-- ============================================

PRINT 'Đang tạo lại bảng User với IDENTITY...';

CREATE TABLE [User] (
    uid INT IDENTITY(1,1) PRIMARY KEY,           -- IDENTITY tự động tăng
    username NVARCHAR(100) NOT NULL UNIQUE,      -- Tên đăng nhập (UNIQUE)
    [password] NVARCHAR(255) NOT NULL,          -- Mật khẩu
    displayname NVARCHAR(255) NOT NULL          -- Tên hiển thị
);

PRINT '✓ Đã tạo bảng User với uid IDENTITY(1,1)';
PRINT '✓ Đã tạo UNIQUE constraint cho username';

PRINT '';

-- ============================================
-- BƯỚC 6: TẠO LẠI BẢNG Enrollment
-- ============================================

PRINT 'Đang tạo lại bảng Enrollment...';

CREATE TABLE Enrollment (
    uid INT NOT NULL,
    eid INT NOT NULL,
    active BIT NOT NULL DEFAULT 1,  -- 1 = active, 0 = inactive
    
    PRIMARY KEY (uid, eid),  -- Composite primary key
    
    CONSTRAINT FK_Enrollment_User 
        FOREIGN KEY (uid) REFERENCES [User](uid) 
        ON DELETE CASCADE,
    
    CONSTRAINT FK_Enrollment_Employee 
        FOREIGN KEY (eid) REFERENCES Employee(eid) 
        ON DELETE CASCADE
);

PRINT '✓ Đã tạo bảng Enrollment với Foreign Keys';

PRINT '';

-- ============================================
-- BƯỚC 7: TẠO LẠI BẢNG UserRole (nếu cần)
-- ============================================

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role')
BEGIN
    PRINT 'Đang tạo lại bảng UserRole...';
    
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
    PRINT '';
END

-- ============================================
-- BƯỚC 8: TẠO LẠI BẢNG ActivityLog
-- ============================================

PRINT 'Đang tạo lại bảng ActivityLog...';

CREATE TABLE ActivityLog (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    employee_id INT NULL,
    activity_type NVARCHAR(50) NOT NULL,
    entity_type NVARCHAR(50) NULL,
    entity_id INT NULL,
    action_description NVARCHAR(500) NULL,
    old_value NVARCHAR(MAX) NULL,
    new_value NVARCHAR(MAX) NULL,
    ip_address NVARCHAR(50) NULL,
    user_agent NVARCHAR(500) NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    
    CONSTRAINT FK_ActivityLog_User 
        FOREIGN KEY (user_id) REFERENCES [User](uid),
    
    CONSTRAINT FK_ActivityLog_Employee 
        FOREIGN KEY (employee_id) REFERENCES Employee(eid)
);

-- Tạo indexes
CREATE INDEX IX_ActivityLog_User ON ActivityLog(user_id);
CREATE INDEX IX_ActivityLog_ActivityType ON ActivityLog(activity_type);
CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
CREATE INDEX IX_ActivityLog_Entity ON ActivityLog(entity_type, entity_id);

PRINT '✓ Đã tạo bảng ActivityLog với indexes';

PRINT '';

-- ============================================
-- BƯỚC 9: RESTORE DỮ LIỆU (Nếu đã backup)
-- ============================================

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee_backup')
BEGIN
    PRINT 'Đang restore dữ liệu Employee...';
    PRINT '⚠️ LƯU Ý: Chỉ restore ename, không restore eid (vì eid sẽ tự động tạo mới)';
    
    SET IDENTITY_INSERT Employee ON;
    
    INSERT INTO Employee (eid, ename, did, supervisorid)
    SELECT eid, ename, did, supervisorid 
    FROM Employee_backup;
    
    SET IDENTITY_INSERT Employee OFF;
    
    PRINT '✓ Đã restore dữ liệu Employee';
    
    -- Xóa bảng backup
    -- DROP TABLE Employee_backup;
    -- PRINT '✓ Đã xóa bảng backup Employee_backup';
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User_backup')
BEGIN
    PRINT 'Đang restore dữ liệu User...';
    PRINT '⚠️ LƯU Ý: Chỉ restore username, password, displayname. uid sẽ tự động tạo mới';
    
    SET IDENTITY_INSERT [User] ON;
    
    INSERT INTO [User] (uid, username, [password], displayname)
    SELECT uid, username, [password], displayname 
    FROM [User_backup];
    
    SET IDENTITY_INSERT [User] OFF;
    
    PRINT '✓ Đã restore dữ liệu User';
    
    -- LƯU Ý: Sau khi restore User và Employee, cần update lại Enrollment
    -- vì uid và eid đã thay đổi. Cần script riêng để map lại.
    
    -- Xóa bảng backup
    -- DROP TABLE [User_backup];
    -- PRINT '✓ Đã xóa bảng backup User_backup';
END

PRINT '';

-- ============================================
-- BƯỚC 10: KIỂM TRA KẾT QUẢ
-- ============================================

PRINT '========================================';
PRINT 'KIỂM TRA KẾT QUẢ:';
PRINT '========================================';

-- Kiểm tra Employee.eid
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('Employee') AND name = 'eid' AND is_identity = 1
)
    PRINT '✓ Employee.eid là IDENTITY - THÀNH CÔNG!';
ELSE
    PRINT '✗ Employee.eid KHÔNG phải IDENTITY - THẤT BẠI!';

-- Kiểm tra User.uid
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('User') AND name = 'uid' AND is_identity = 1
)
    PRINT '✓ User.uid là IDENTITY - THÀNH CÔNG!';
ELSE
    PRINT '✗ User.uid KHÔNG phải IDENTITY - THẤT BẠI!';

-- Kiểm tra Foreign Keys
IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Enrollment') AND name = 'FK_Enrollment_User'
)
    PRINT '✓ Enrollment có Foreign Key đến User - THÀNH CÔNG!';
ELSE
    PRINT '✗ Enrollment thiếu Foreign Key đến User - THẤT BẠI!';

IF EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Enrollment') AND name = 'FK_Enrollment_Employee'
)
    PRINT '✓ Enrollment có Foreign Key đến Employee - THÀNH CÔNG!';
ELSE
    PRINT '✗ Enrollment thiếu Foreign Key đến Employee - THẤT BẠI!';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT!';
PRINT '========================================';
PRINT '';
PRINT 'Bây giờ hãy test đăng ký trên ứng dụng!';
PRINT '';
GO





