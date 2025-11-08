-- ============================================
-- Script tạo User mới có thể đăng nhập
-- ============================================
-- Hướng dẫn sử dụng:
-- 1. Thay đổi các giá trị trong phần "THAY ĐỔI CÁC GIÁ TRỊ SAU"
-- 2. Chạy script này trong SQL Server Management Studio
-- ============================================

USE [FALL25_Assignment_SonNT]
GO

-- ============================================
-- THAY ĐỔI CÁC GIÁ TRỊ SAU
-- ============================================

-- Thông tin Employee (nếu tạo Employee mới)
DECLARE @NewEmployeeId INT = 8;  -- ID Employee mới (phải chưa tồn tại, hoặc để NULL để tự động tìm ID tiếp theo)
DECLARE @EmployeeName NVARCHAR(150) = N'Nguyen Van Test';  -- Tên nhân viên
DECLARE @DivisionId INT = 1;  -- ID Division (1 = IT, 2 = QA, 3 = Sale)
DECLARE @SupervisorId INT = 1;  -- ID Supervisor (NULL nếu không có supervisor)

-- Nếu @NewEmployeeId = NULL, sẽ tự động tìm ID tiếp theo
IF @NewEmployeeId IS NULL
BEGIN
    SELECT @NewEmployeeId = ISNULL(MAX([eid]), 0) + 1 FROM [Employee];
END

-- Thông tin User
DECLARE @Username VARCHAR(150) = 'testuser';  -- Username để đăng nhập
DECLARE @Password VARCHAR(150) = '123';  -- Password để đăng nhập
DECLARE @DisplayName VARCHAR(150) = N'Test User';  -- Tên hiển thị

-- Role cho User (chọn một trong các role sau):
-- 1 = IT Head (có tất cả quyền)
-- 2 = IT PM (tạo, review, list, history, home, attendance)
-- 3 = IT Employee (tạo, list, history, home, attendance)
-- 4 = Admin (quản lý user: tạo, xóa, reset password, home)
DECLARE @RoleId INT = 3;  -- Role ID (ví dụ: 3 = IT Employee)

-- Nếu muốn dùng Employee đã tồn tại, set @NewEmployeeId = ID của Employee đó
-- Ví dụ: DECLARE @NewEmployeeId INT = 1;  -- Dùng Employee ID 1 (Nguyen Van A)

-- ============================================
-- BẮT ĐẦU TẠO USER
-- ============================================

BEGIN TRANSACTION;

BEGIN TRY
    -- Bước 1: Tạo Employee mới (nếu chưa tồn tại)
    IF NOT EXISTS (SELECT 1 FROM [Employee] WHERE [eid] = @NewEmployeeId)
    BEGIN
        INSERT INTO [dbo].[Employee] ([eid], [ename], [did], [supervisorid])
        VALUES (@NewEmployeeId, @EmployeeName, @DivisionId, @SupervisorId);
        
        PRINT '✓ Đã tạo Employee mới: ID = ' + CAST(@NewEmployeeId AS VARCHAR) + ', Tên = ' + @EmployeeName;
    END
    ELSE
    BEGIN
        PRINT 'ℹ Employee ID ' + CAST(@NewEmployeeId AS VARCHAR) + ' đã tồn tại, sẽ dùng Employee này.';
    END
    
    -- Bước 2: Tạo User mới (uid sẽ tự động tăng nhờ IDENTITY)
    DECLARE @NewUserId INT;
    
    INSERT INTO [dbo].[User] ([username], [password], [displayname])
    VALUES (@Username, @Password, @DisplayName);
    
    SET @NewUserId = SCOPE_IDENTITY();
    
    PRINT '✓ Đã tạo User mới: ID = ' + CAST(@NewUserId AS VARCHAR) + ', Username = ' + @Username;
    
    -- Bước 3: Tạo Enrollment để link User với Employee
    IF NOT EXISTS (SELECT 1 FROM [Enrollment] WHERE [uid] = @NewUserId AND [eid] = @NewEmployeeId)
    BEGIN
        INSERT INTO [dbo].[Enrollment] ([uid], [eid], [active])
        VALUES (@NewUserId, @NewEmployeeId, 1);
        
        PRINT '✓ Đã tạo Enrollment: User ID = ' + CAST(@NewUserId AS VARCHAR) + ' <-> Employee ID = ' + CAST(@NewEmployeeId AS VARCHAR);
    END
    ELSE
    BEGIN
        PRINT 'ℹ Enrollment đã tồn tại.';
    END
    
    -- Bước 4: Gán Role cho User
    IF NOT EXISTS (SELECT 1 FROM [UserRole] WHERE [uid] = @NewUserId AND [rid] = @RoleId)
    BEGIN
        INSERT INTO [dbo].[UserRole] ([uid], [rid])
        VALUES (@NewUserId, @RoleId);
        
        DECLARE @RoleName VARCHAR(150);
        SELECT @RoleName = [rname] FROM [Role] WHERE [rid] = @RoleId;
        
        PRINT '✓ Đã gán Role: User ID = ' + CAST(@NewUserId AS VARCHAR) + ' -> Role = ' + @RoleName + ' (ID: ' + CAST(@RoleId AS VARCHAR) + ')';
    END
    ELSE
    BEGIN
        PRINT 'ℹ UserRole đã tồn tại.';
    END
    
    -- Commit transaction
    COMMIT TRANSACTION;
    
    PRINT '';
    PRINT '========================================';
    PRINT '✓ HOÀN TẤT! User đã được tạo thành công!';
    PRINT '========================================';
    PRINT 'Thông tin đăng nhập:';
    PRINT '  Username: ' + @Username;
    PRINT '  Password: ' + @Password;
    PRINT '  User ID: ' + CAST(@NewUserId AS VARCHAR);
    PRINT '  Employee ID: ' + CAST(@NewEmployeeId AS VARCHAR);
    PRINT '  Role ID: ' + CAST(@RoleId AS VARCHAR);
    PRINT '========================================';
    
END TRY
BEGIN CATCH
    -- Rollback transaction nếu có lỗi
    ROLLBACK TRANSACTION;
    
    PRINT '';
    PRINT '========================================';
    PRINT '✗ LỖI! Không thể tạo User!';
    PRINT '========================================';
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT '========================================';
END CATCH;
GO

-- ============================================
-- KIỂM TRA USER VỪA TẠO
-- ============================================

-- Xem thông tin User vừa tạo
SELECT 
    u.[uid],
    u.[username],
    u.[password],
    u.[displayname],
    e.[eid] AS [employee_id],
    e.[ename] AS [employee_name],
    r.[rid] AS [role_id],
    r.[rname] AS [role_name]
FROM [User] u
LEFT JOIN [Enrollment] en ON u.[uid] = en.[uid]
LEFT JOIN [Employee] e ON en.[eid] = e.[eid]
LEFT JOIN [UserRole] ur ON u.[uid] = ur.[uid]
LEFT JOIN [Role] r ON ur.[rid] = r.[rid]
WHERE u.[username] = 'testuser'  -- Thay 'testuser' bằng username bạn vừa tạo
ORDER BY u.[uid] DESC;
GO

