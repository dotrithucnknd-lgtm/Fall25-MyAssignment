-- ============================================
-- Script tạo Database Schema cho FALL25_Assignment
-- Chức năng: Đăng ký User với Employee tự động
-- ============================================

USE FALL25_Assignment;
GO

-- ============================================
-- BƯỚC 1: Kiểm tra và xóa các bảng cũ (nếu cần)
-- Chạy các lệnh này nếu muốn tạo lại từ đầu (CẨN THẬN - SẼ MẤT DỮ LIỆU!)
-- ============================================

-- Xóa Foreign Keys trước (nếu tồn tại)
/*
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
    ALTER TABLE ActivityLog DROP CONSTRAINT FK_ActivityLog_User;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_Employee')
    ALTER TABLE ActivityLog DROP CONSTRAINT FK_ActivityLog_Employee;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
    ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_User;

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_Employee')
    ALTER TABLE Enrollment DROP CONSTRAINT FK_Enrollment_Employee;

-- Xóa các bảng (nếu cần)
-- DROP TABLE IF EXISTS ActivityLog;
-- DROP TABLE IF EXISTS Enrollment;
-- DROP TABLE IF EXISTS [User];
-- DROP TABLE IF EXISTS Employee;
*/

-- ============================================
-- BƯỚC 2: Tạo bảng Employee
-- QUAN TRỌNG: eid PHẢI là IDENTITY(1,1) để tự động tăng
-- ============================================

-- Kiểm tra xem bảng Employee đã tồn tại chưa
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    CREATE TABLE Employee (
        eid INT IDENTITY(1,1) PRIMARY KEY,  -- IDENTITY tự động tăng, bắt đầu từ 1
        ename NVARCHAR(255) NOT NULL       -- Tên nhân viên
    );
    PRINT 'Bảng Employee đã được tạo thành công!';
END
ELSE
BEGIN
    -- Kiểm tra xem eid có phải là IDENTITY không
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('Employee') AND name = 'eid'
    )
    BEGIN
        PRINT 'LỖI: Bảng Employee đã tồn tại nhưng eid không phải là IDENTITY!';
        PRINT 'Cần xóa bảng Employee và tạo lại, HOẶC thêm IDENTITY cho cột eid.';
        -- Nếu muốn sửa, có thể chạy:
        -- ALTER TABLE Employee DROP CONSTRAINT PK__Employee__...; -- (tên constraint thực tế)
        -- ALTER TABLE Employee ALTER COLUMN eid INT IDENTITY(1,1);
        -- ALTER TABLE Employee ADD PRIMARY KEY (eid);
    END
    ELSE
    BEGIN
        PRINT 'Bảng Employee đã tồn tại và eid là IDENTITY - OK!';
    END
END
GO

-- ============================================
-- BƯỚC 3: Tạo bảng User
-- QUAN TRỌNG: uid PHẢI là IDENTITY(1,1) để tự động tăng
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    CREATE TABLE [User] (
        uid INT IDENTITY(1,1) PRIMARY KEY,           -- IDENTITY tự động tăng
        username NVARCHAR(100) NOT NULL UNIQUE,      -- Tên đăng nhập (unique)
        [password] NVARCHAR(255) NOT NULL,           -- Mật khẩu (keyword nên đặt trong [])
        displayname NVARCHAR(255) NOT NULL          -- Tên hiển thị
    );
    PRINT 'Bảng User đã được tạo thành công!';
END
ELSE
BEGIN
    -- Kiểm tra xem uid có phải là IDENTITY không
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('User') AND name = 'uid'
    )
    BEGIN
        PRINT 'LỖI: Bảng User đã tồn tại nhưng uid không phải là IDENTITY!';
    END
    ELSE
    BEGIN
        PRINT 'Bảng User đã tồn tại và uid là IDENTITY - OK!';
    END
    
    -- Đảm bảo username là UNIQUE
    IF NOT EXISTS (
        SELECT * FROM sys.indexes 
        WHERE object_id = OBJECT_ID('User') 
        AND name LIKE '%username%' 
        AND is_unique = 1
    )
    BEGIN
        -- Tạo unique constraint cho username
        ALTER TABLE [User] ADD CONSTRAINT UQ_User_Username UNIQUE (username);
        PRINT 'Đã thêm UNIQUE constraint cho username!';
    END
END
GO

-- ============================================
-- BƯỚC 4: Tạo bảng Enrollment
-- Liên kết User và Employee
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    CREATE TABLE Enrollment (
        uid INT NOT NULL,
        eid INT NOT NULL,
        active BIT NOT NULL DEFAULT 1,  -- 1 = active, 0 = inactive
        
        PRIMARY KEY (uid, eid),  -- Composite primary key
        
        -- Foreign Keys
        CONSTRAINT FK_Enrollment_User 
            FOREIGN KEY (uid) REFERENCES [User](uid) 
            ON DELETE CASCADE,
        
        CONSTRAINT FK_Enrollment_Employee 
            FOREIGN KEY (eid) REFERENCES Employee(eid) 
            ON DELETE CASCADE
    );
    PRINT 'Bảng Enrollment đã được tạo thành công!';
END
ELSE
BEGIN
    -- Kiểm tra Foreign Keys
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('Enrollment') 
        AND name = 'FK_Enrollment_User'
    )
    BEGIN
        ALTER TABLE Enrollment 
        ADD CONSTRAINT FK_Enrollment_User 
        FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE;
        PRINT 'Đã thêm Foreign Key FK_Enrollment_User!';
    END
    
    IF NOT EXISTS (
        SELECT * FROM sys.foreign_keys 
        WHERE parent_object_id = OBJECT_ID('Enrollment') 
        AND name = 'FK_Enrollment_Employee'
    )
    BEGIN
        ALTER TABLE Enrollment 
        ADD CONSTRAINT FK_Enrollment_Employee 
        FOREIGN KEY (eid) REFERENCES Employee(eid) ON DELETE CASCADE;
        PRINT 'Đã thêm Foreign Key FK_Enrollment_Employee!';
    END
    
    PRINT 'Bảng Enrollment đã tồn tại - OK!';
END
GO

-- ============================================
-- BƯỚC 5: Tạo bảng ActivityLog (nếu chưa có)
-- ============================================

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog')
BEGIN
    CREATE TABLE ActivityLog (
        log_id INT IDENTITY(1,1) PRIMARY KEY,
        user_id INT NOT NULL,
        employee_id INT,
        activity_type NVARCHAR(50) NOT NULL,
        entity_type NVARCHAR(50),
        entity_id INT,
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
    
    -- Tạo indexes
    CREATE INDEX IX_ActivityLog_User ON ActivityLog(user_id);
    CREATE INDEX IX_ActivityLog_ActivityType ON ActivityLog(activity_type);
    CREATE INDEX IX_ActivityLog_CreatedAt ON ActivityLog(created_at DESC);
    CREATE INDEX IX_ActivityLog_Entity ON ActivityLog(entity_type, entity_id);
    
    PRINT 'Bảng ActivityLog đã được tạo thành công!';
END
ELSE
BEGIN
    PRINT 'Bảng ActivityLog đã tồn tại - OK!';
END
GO

-- ============================================
-- BƯỚC 6: Kiểm tra tổng quát
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'KIỂM TRA TỔNG QUÁT:';
PRINT '========================================';

-- Kiểm tra Employee
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('Employee') AND name = 'eid')
    PRINT '✓ Employee.eid là IDENTITY - OK';
ELSE
    PRINT '✗ Employee.eid KHÔNG phải là IDENTITY - CẦN SỬA!';

-- Kiểm tra User
IF EXISTS (SELECT * FROM sys.identity_columns WHERE object_id = OBJECT_ID('User') AND name = 'uid')
    PRINT '✓ User.uid là IDENTITY - OK';
ELSE
    PRINT '✗ User.uid KHÔNG phải là IDENTITY - CẦN SỬA!';

-- Kiểm tra Enrollment
IF EXISTS (SELECT * FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('Enrollment') AND name = 'FK_Enrollment_User')
    PRINT '✓ Enrollment có Foreign Key đến User - OK';
ELSE
    PRINT '✗ Enrollment thiếu Foreign Key đến User - CẦN SỬA!';

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE parent_object_id = OBJECT_ID('Enrollment') AND name = 'FK_Enrollment_Employee')
    PRINT '✓ Enrollment có Foreign Key đến Employee - OK';
ELSE
    PRINT '✗ Enrollment thiếu Foreign Key đến Employee - CẦN SỬA!';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT!';
PRINT '========================================';
GO



