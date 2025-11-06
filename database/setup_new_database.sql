-- ============================================
-- Script SETUP DATABASE MỚI HOÀN CHỈNH
-- Database: FALL25_Assignment
-- ============================================
-- Script này sẽ:
-- 1. Tạo Login và User cho database
-- 2. Chạy script hoàn thiện database (complete_database_for_website.sql)
-- ============================================

USE [master];
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU SETUP DATABASE MỚI';
PRINT '========================================';
PRINT '';

-- ============================================
-- PHẦN 1: TẠO LOGIN (NẾU CHƯA CÓ)
-- ============================================

PRINT '1. TẠO LOGIN...';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.server_principals WHERE name = 'java_admin')
BEGIN
    CREATE LOGIN [java_admin] WITH PASSWORD = 'P@ssw0rd123', 
        DEFAULT_DATABASE = [FALL25_Assignment],
        CHECK_EXPIRATION = OFF,
        CHECK_POLICY = OFF;
    PRINT '✓ Đã tạo Login: java_admin';
END
ELSE
BEGIN
    PRINT 'Login java_admin đã tồn tại';
    -- Cập nhật password nếu cần
    ALTER LOGIN [java_admin] WITH PASSWORD = 'P@ssw0rd123';
    PRINT '✓ Đã cập nhật password cho java_admin';
END

PRINT '';
GO

-- ============================================
-- PHẦN 2: TẠO USER TRONG DATABASE
-- ============================================

USE [FALL25_Assignment];
GO

PRINT '2. TẠO USER TRONG DATABASE...';
PRINT '';

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'java_admin_user')
BEGIN
    CREATE USER [java_admin_user] FOR LOGIN [java_admin] WITH DEFAULT_SCHEMA=[dbo];
    PRINT '✓ Đã tạo User: java_admin_user';
END
ELSE
BEGIN
    PRINT 'User java_admin_user đã tồn tại';
END

-- Gán quyền db_owner
ALTER ROLE [db_owner] ADD MEMBER [java_admin_user];
PRINT '✓ Đã gán quyền db_owner cho java_admin_user';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT SETUP LOGIN VÀ USER!';
PRINT '========================================';
PRINT '';
PRINT 'Thông tin kết nối:';
PRINT '  Server: localhost:1433';
PRINT '  Database: FALL25_Assignment';
PRINT '  Username: java_admin';
PRINT '  Password: P@ssw0rd123';
PRINT '';
PRINT 'Bây giờ hãy chạy script: complete_database_for_website.sql';
PRINT 'để tạo schema và dữ liệu cho database.';
GO

