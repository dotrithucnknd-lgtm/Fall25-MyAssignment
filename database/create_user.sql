-- Script tạo User và Password mới
-- Database: FALL25_Assignment
-- 
-- Hướng dẫn sử dụng:
-- 1. Thay đổi các giá trị: @username, @password, @displayname, @employee_id
-- 2. Chạy script này trong SQL Server Management Studio

USE FALL25_Assignment;
GO

-- ============================================
-- CÁCH 1: Tạo User mới với Employee mới
-- ============================================

DECLARE @username NVARCHAR(100) = 'admin';        -- Thay đổi username ở đây
DECLARE @password NVARCHAR(255) = 'admin123';     -- Thay đổi password ở đây
DECLARE @displayname NVARCHAR(255) = 'Administrator';  -- Thay đổi tên hiển thị ở đây

-- Bước 1: Tạo Employee mới
DECLARE @eid INT;
INSERT INTO Employee (ename) VALUES (@displayname);
SET @eid = SCOPE_IDENTITY();  -- Lấy EID vừa tạo

PRINT 'Employee đã được tạo với EID: ' + CAST(@eid AS VARCHAR);

-- Bước 2: Tạo User mới
DECLARE @uid INT;
INSERT INTO [User] (username, [password], displayname)
VALUES (@username, @password, @displayname);
SET @uid = SCOPE_IDENTITY();  -- Lấy UID vừa tạo

PRINT 'User đã được tạo với UID: ' + CAST(@uid AS VARCHAR);

-- Bước 3: Liên kết User với Employee qua Enrollment
MERGE Enrollment AS target
USING (SELECT @uid AS uid, @eid AS eid) AS src
ON target.uid = src.uid
WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);

PRINT 'Enrollment đã được tạo/updated thành công!';
PRINT '========================================';
PRINT 'Thông tin tài khoản:';
PRINT 'Username: ' + @username;
PRINT 'Password: ' + @password;
PRINT 'Display Name: ' + @displayname;
PRINT 'Employee ID: ' + CAST(@eid AS VARCHAR);
PRINT 'User ID: ' + CAST(@uid AS VARCHAR);
PRINT '========================================';

GO

-- ============================================
-- CÁCH 2: Tạo User mới liên kết với Employee đã có
-- ============================================

/*
-- Uncomment và thay đổi các giá trị sau:

DECLARE @username NVARCHAR(100) = 'user1';
DECLARE @password NVARCHAR(255) = 'password123';
DECLARE @displayname NVARCHAR(255) = 'Nguyễn Văn A';
DECLARE @employee_id INT = 1;  -- ID của Employee đã có sẵn

-- Kiểm tra Employee có tồn tại không
IF NOT EXISTS (SELECT 1 FROM Employee WHERE eid = @employee_id)
BEGIN
    PRINT 'LỖI: Employee ID ' + CAST(@employee_id AS VARCHAR) + ' không tồn tại!';
    RETURN;
END

-- Tạo User mới
DECLARE @uid INT;
INSERT INTO [User] (username, [password], displayname)
VALUES (@username, @password, @displayname);
SET @uid = SCOPE_IDENTITY();

PRINT 'User đã được tạo với UID: ' + CAST(@uid AS VARCHAR);

-- Liên kết User với Employee
MERGE Enrollment AS target
USING (SELECT @uid AS uid, @employee_id AS eid) AS src
ON target.uid = src.uid
WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);

PRINT 'Enrollment đã được tạo/updated thành công!';
*/

GO

-- ============================================
-- CÁCH 3: Đổi password cho User đã có
-- ============================================

/*
-- Uncomment và thay đổi các giá trị sau:

DECLARE @username NVARCHAR(100) = 'admin';  -- Username cần đổi password
DECLARE @new_password NVARCHAR(255) = 'newpassword123';  -- Password mới

-- Kiểm tra User có tồn tại không
IF NOT EXISTS (SELECT 1 FROM [User] WHERE username = @username)
BEGIN
    PRINT 'LỖI: Username ''' + @username + ''' không tồn tại!';
    RETURN;
END

-- Cập nhật password
UPDATE [User]
SET [password] = @new_password
WHERE username = @username;

IF @@ROWCOUNT > 0
BEGIN
    PRINT 'Password đã được đổi thành công cho user: ' + @username;
END
ELSE
BEGIN
    PRINT 'Không thể đổi password cho user: ' + @username;
END
*/

GO

