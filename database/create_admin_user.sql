-- Script tạo user admin mặc định
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05

USE [FALL25_Assignment]
GO

-- Kiểm tra xem user admin đã tồn tại chưa
IF NOT EXISTS (SELECT * FROM [User] WHERE username = 'admin')
BEGIN
    PRINT 'Đang tạo user admin mặc định...';
    
    -- Tạo Employee cho admin (nếu chưa có)
    DECLARE @eid INT;
    DECLARE @employee_name NVARCHAR(255) = 'Administrator';
    
    -- Kiểm tra xem có Employee nào không
    SELECT TOP 1 @eid = eid FROM Employee;
    
    IF @eid IS NULL
    BEGIN
        PRINT 'Không có Employee nào, đang tạo Employee mới...';
        
        -- Kiểm tra xem có Division nào không
        DECLARE @did INT;
        SELECT TOP 1 @did = did FROM Division;
        
        IF @did IS NULL
        BEGIN
            PRINT 'Cảnh báo: Không có Division nào! Đang tạo Division mặc định...';
            INSERT INTO Division (did, dname) VALUES (1, 'Default Division');
            SET @did = 1;
            PRINT 'Đã tạo Division mặc định với DID: 1';
        END
        
        -- Tạo Employee mới
        INSERT INTO Employee (eid, ename, did, supervisorid)
        VALUES ((SELECT ISNULL(MAX(eid), 0) + 1 FROM Employee), @employee_name, @did, NULL);
        SET @eid = (SELECT MAX(eid) FROM Employee);
        PRINT 'Đã tạo Employee với EID: ' + CAST(@eid AS VARCHAR(10));
    END
    ELSE
    BEGIN
        PRINT 'Sử dụng Employee hiện có với EID: ' + CAST(@eid AS VARCHAR(10));
    END
    
    -- Tạo user admin với OUTPUT INSERTED.uid (vì uid là IDENTITY)
    DECLARE @uid INT;
    DECLARE @username NVARCHAR(100) = 'admin';
    DECLARE @password NVARCHAR(255) = 'admin123';
    DECLARE @displayname NVARCHAR(255) = 'Administrator';
    
    -- Tạo table variable để lưu OUTPUT
    DECLARE @OutputTable TABLE (uid INT);
    
    INSERT INTO [User] (username, [password], displayname)
    OUTPUT INSERTED.uid INTO @OutputTable
    VALUES (@username, @password, @displayname);
    
    -- Lấy UID từ OUTPUT
    SELECT @uid = uid FROM @OutputTable;
    
    PRINT 'Đã tạo user admin với UID: ' + CAST(@uid AS VARCHAR(10));
    
    -- Tạo Enrollment cho user admin
    IF NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @uid)
    BEGIN
        INSERT INTO Enrollment (uid, eid, active)
        VALUES (@uid, @eid, 1);
        PRINT 'Đã tạo Enrollment cho user admin với Employee ID: ' + CAST(@eid AS VARCHAR(10));
    END
    ELSE
    BEGIN
        -- Cập nhật Enrollment nếu đã tồn tại
        UPDATE Enrollment SET eid = @eid, active = 1 WHERE uid = @uid;
        PRINT 'Đã cập nhật Enrollment cho user admin';
    END
    
    PRINT '';
    PRINT '========================================';
    PRINT '✓ Hoàn thành! User admin đã được tạo:';
    PRINT '  Username: ' + @username;
    PRINT '  Password: ' + @password;
    PRINT '  Display Name: ' + @displayname;
    PRINT '  User ID: ' + CAST(@uid AS VARCHAR(10));
    PRINT '  Employee ID: ' + CAST(@eid AS VARCHAR(10));
    PRINT '========================================';
    PRINT '';
    PRINT '⚠️  QUAN TRỌNG: Vui lòng đăng nhập và đổi mật khẩu ngay!';
END
ELSE
BEGIN
    PRINT 'User admin đã tồn tại!';
    DECLARE @existing_uid INT;
    SELECT @existing_uid = uid FROM [User] WHERE username = 'admin';
    PRINT 'Username: admin';
    PRINT 'User ID: ' + CAST(@existing_uid AS VARCHAR(10));
    
    -- Kiểm tra xem có Enrollment không
    IF NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @existing_uid AND active = 1)
    BEGIN
        PRINT 'Cảnh báo: User admin không có Enrollment active!';
        PRINT 'Đang tạo Enrollment...';
        
        DECLARE @existing_eid INT;
        SELECT TOP 1 @existing_eid = eid FROM Employee;
        
        IF @existing_eid IS NOT NULL
        BEGIN
            MERGE Enrollment AS target
            USING (SELECT @existing_uid AS uid, @existing_eid AS eid) AS src
            ON target.uid = src.uid
            WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
            WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);
            PRINT 'Đã tạo/cập nhật Enrollment cho user admin';
        END
        ELSE
        BEGIN
            PRINT 'LỖI: Không có Employee nào trong hệ thống!';
        END
    END
END
GO

