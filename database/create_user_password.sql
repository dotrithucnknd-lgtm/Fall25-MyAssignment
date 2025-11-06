-- ============================================================
-- SCRIPT TẠO USER VÀ PASSWORD MỚI
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05
-- 
-- Hướng dẫn sử dụng:
-- 1. Thay đổi các giá trị: @username, @password, @displayname, @employee_id
-- 2. Chạy script này trong SQL Server Management Studio
-- ============================================================

USE [FALL25_Assignment]
GO

-- ============================================================
-- THAY ĐỔI CÁC GIÁ TRỊ SAU ĐÂY:
-- ============================================================

DECLARE @username NVARCHAR(100) = 'user1';        -- Thay đổi username ở đây
DECLARE @password NVARCHAR(255) = 'password123';  -- Thay đổi password ở đây
DECLARE @displayname NVARCHAR(255) = 'Nguyễn Văn A';  -- Thay đổi tên hiển thị ở đây
DECLARE @employee_id INT = 1;                     -- Thay đổi Employee ID ở đây (hoặc để NULL để tạo Employee mới)

-- ============================================================
-- KHÔNG CẦN SỬA PHẦN DƯỚI ĐÂY
-- ============================================================

PRINT '========================================';
PRINT 'BẮT ĐẦU TẠO USER VÀ PASSWORD';
PRINT '========================================';
PRINT '';

-- Kiểm tra username đã tồn tại chưa
IF EXISTS (SELECT * FROM [User] WHERE username = @username)
BEGIN
    PRINT '⚠️  LỖI: Username "' + @username + '" đã tồn tại!';
    PRINT 'Vui lòng chọn username khác.';
    RETURN;
END

-- Kiểm tra password
IF LEN(@password) < 6
BEGIN
    PRINT '⚠️  LỖI: Password phải có ít nhất 6 ký tự!';
    RETURN;
END

-- Xử lý Employee
DECLARE @eid INT;
DECLARE @did INT;

IF @employee_id IS NULL OR @employee_id <= 0
BEGIN
    -- Tạo Employee mới
    PRINT 'Đang tạo Employee mới...';
    
    -- Kiểm tra và tạo Division nếu chưa có
    SELECT TOP 1 @did = did FROM Division;
    IF @did IS NULL
    BEGIN
        -- Tạo Division mặc định
        IF NOT EXISTS (SELECT * FROM Division WHERE did = 1)
        BEGIN
            INSERT INTO Division (did, dname) VALUES (1, 'Default Division');
        END
        SET @did = 1;
        PRINT '✓ Đã tạo Division mặc định (DID: 1)';
    END
    
    -- Tạo Employee mới
    DECLARE @maxEid INT;
    SELECT @maxEid = ISNULL(MAX(eid), 0) FROM Employee;
    SET @eid = @maxEid + 1;
    
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, @displayname, @did, NULL);
    
    PRINT '✓ Đã tạo Employee mới: ' + @displayname + ' (EID: ' + CAST(@eid AS VARCHAR(10)) + ')';
END
ELSE
BEGIN
    -- Sử dụng Employee đã có
    IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @employee_id)
    BEGIN
        PRINT '⚠️  LỖI: Employee ID ' + CAST(@employee_id AS VARCHAR(10)) + ' không tồn tại!';
        RETURN;
    END
    
    SET @eid = @employee_id;
    PRINT '✓ Sử dụng Employee hiện có (EID: ' + CAST(@eid AS VARCHAR(10)) + ')';
END

PRINT '';

-- Tạo User mới
PRINT 'Đang tạo User mới...';

DECLARE @OutputTable TABLE (uid INT);
DECLARE @uid INT;

INSERT INTO [User] (username, [password], displayname)
OUTPUT INSERTED.uid INTO @OutputTable
VALUES (@username, @password, @displayname);

SELECT @uid = uid FROM @OutputTable;

PRINT '✓ Đã tạo User mới: ' + @username + ' (UID: ' + CAST(@uid AS VARCHAR(10)) + ')';

-- Tạo Enrollment (liên kết User với Employee)
PRINT 'Đang tạo Enrollment...';

MERGE Enrollment AS target
USING (SELECT @uid AS uid, @eid AS eid) AS src
ON target.uid = src.uid
WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);

PRINT '✓ Đã tạo Enrollment (UID: ' + CAST(@uid AS VARCHAR(10)) + ', EID: ' + CAST(@eid AS VARCHAR(10)) + ')';

PRINT '';
PRINT '========================================';
PRINT '✓ HOÀN TẤT! USER ĐÃ ĐƯỢC TẠO THÀNH CÔNG';
PRINT '========================================';
PRINT '';
PRINT 'Thông tin tài khoản:';
PRINT '  Username: ' + @username;
PRINT '  Password: ' + @password;
PRINT '  Display Name: ' + @displayname;
PRINT '  User ID: ' + CAST(@uid AS VARCHAR(10));
PRINT '  Employee ID: ' + CAST(@eid AS VARCHAR(10));
PRINT '';
PRINT '⚠️  QUAN TRỌNG: Vui lòng đăng nhập và đổi mật khẩu ngay!';
PRINT '';
PRINT '========================================';
GO



