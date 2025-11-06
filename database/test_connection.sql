-- ============================================
-- Script TEST KẾT NỐI DATABASE
-- Kiểm tra xem database đã sẵn sàng chưa
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'KIỂM TRA KẾT NỐI DATABASE';
PRINT '========================================';
PRINT '';

-- Kiểm tra database có tồn tại không
IF DB_NAME() = 'FALL25_Assignment'
    PRINT '✓ Database FALL25_Assignment đã được chọn';
ELSE
    PRINT '✗ Database không đúng!';

-- Kiểm tra Login
IF EXISTS (SELECT * FROM sys.server_principals WHERE name = 'java_admin')
    PRINT '✓ Login java_admin đã tồn tại';
ELSE
    PRINT '✗ Login java_admin chưa tồn tại (cần chạy setup_new_database.sql)';

-- Kiểm tra User trong database
IF EXISTS (SELECT * FROM sys.database_principals WHERE name = 'java_admin_user')
    PRINT '✓ User java_admin_user đã tồn tại trong database';
ELSE
    PRINT '✗ User java_admin_user chưa tồn tại (cần chạy setup_new_database.sql)';

-- Kiểm tra quyền
IF EXISTS (
    SELECT * FROM sys.database_role_members 
    WHERE member_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'java_admin_user')
    AND role_principal_id = (SELECT principal_id FROM sys.database_principals WHERE name = 'db_owner')
)
    PRINT '✓ User java_admin_user đã có quyền db_owner';
ELSE
    PRINT '✗ User java_admin_user chưa có quyền db_owner';

-- Kiểm tra các bảng cơ bản
DECLARE @tableCount INT = 0;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User') SET @tableCount = @tableCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee') SET @tableCount = @tableCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment') SET @tableCount = @tableCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Role') SET @tableCount = @tableCount + 1;
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature') SET @tableCount = @tableCount + 1;

IF @tableCount >= 5
    PRINT '✓ Các bảng cơ bản đã được tạo (' + CAST(@tableCount AS VARCHAR) + ' bảng)';
ELSE
    PRINT '✗ Thiếu các bảng cơ bản (chỉ có ' + CAST(@tableCount AS VARCHAR) + ' bảng, cần chạy complete_database_for_website.sql)';

-- Kiểm tra dữ liệu User
DECLARE @userCount INT = (SELECT COUNT(*) FROM [User]);
IF @userCount > 0
    PRINT '✓ Có ' + CAST(@userCount AS VARCHAR) + ' User trong database';
ELSE
    PRINT '⚠️ Chưa có User nào (cần tạo User để đăng nhập)';

PRINT '';
PRINT '========================================';
PRINT 'KẾT QUẢ KIỂM TRA';
PRINT '========================================';
PRINT '';
PRINT 'Nếu có lỗi (✗), hãy:';
PRINT '1. Chạy setup_new_database.sql để tạo Login và User';
PRINT '2. Chạy complete_database_for_website.sql để tạo schema';
PRINT '3. Chạy lại script này để kiểm tra';
GO


