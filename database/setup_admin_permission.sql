-- Script thiết lập quyền Admin cho user admin
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05

USE [FALL25_Assignment]
GO

PRINT '========================================';
PRINT 'Đang thiết lập quyền Admin...';
PRINT '========================================';
PRINT '';

-- Bước 1: Tạo Feature cho chức năng tạo user
DECLARE @featureId INT;
SELECT @featureId = ISNULL(MAX(fid), 0) + 1 FROM Feature;

IF NOT EXISTS (SELECT * FROM Feature WHERE url = '/admin/create-user')
BEGIN
    INSERT INTO Feature (fid, url)
    VALUES (@featureId, '/admin/create-user');
    PRINT '✓ Đã tạo Feature: /admin/create-user (FID: ' + CAST(@featureId AS VARCHAR(10)) + ')';
END
ELSE
BEGIN
    SELECT @featureId = fid FROM Feature WHERE url = '/admin/create-user';
    PRINT 'Feature /admin/create-user đã tồn tại (FID: ' + CAST(@featureId AS VARCHAR(10)) + ')';
END

PRINT '';

-- Bước 2: Tạo Role Admin (nếu chưa có)
DECLARE @roleId INT;
SELECT @roleId = ISNULL(MAX(rid), 0) + 1 FROM Role;

IF NOT EXISTS (SELECT * FROM Role WHERE rname = 'Admin')
BEGIN
    INSERT INTO Role (rid, rname)
    VALUES (@roleId, 'Admin');
    PRINT '✓ Đã tạo Role: Admin (RID: ' + CAST(@roleId AS VARCHAR(10)) + ')';
END
ELSE
BEGIN
    SELECT @roleId = rid FROM Role WHERE rname = 'Admin';
    PRINT 'Role Admin đã tồn tại (RID: ' + CAST(@roleId AS VARCHAR(10)) + ')';
END

PRINT '';

-- Bước 3: Gán Feature cho Role Admin
IF NOT EXISTS (SELECT * FROM RoleFeature WHERE rid = @roleId AND fid = @featureId)
BEGIN
    INSERT INTO RoleFeature (rid, fid)
    VALUES (@roleId, @featureId);
    PRINT '✓ Đã gán Feature /admin/create-user cho Role Admin';
END
ELSE
BEGIN
    PRINT 'Feature đã được gán cho Role Admin';
END

PRINT '';

-- Bước 4: Gán Role Admin cho user admin
DECLARE @adminUid INT;
SELECT @adminUid = uid FROM [User] WHERE username = 'admin';

IF @adminUid IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @adminUid AND rid = @roleId)
    BEGIN
        INSERT INTO UserRole (uid, rid)
        VALUES (@adminUid, @roleId);
        PRINT '✓ Đã gán Role Admin cho user admin (UID: ' + CAST(@adminUid AS VARCHAR(10)) + ')';
    END
    ELSE
    BEGIN
        PRINT 'User admin đã có Role Admin';
    END
END
ELSE
BEGIN
    PRINT '⚠️  Cảnh báo: Không tìm thấy user admin!';
    PRINT 'Vui lòng chạy script create_admin_user.sql trước.';
END

PRINT '';
PRINT '========================================';
PRINT '✓ Hoàn thành! Quyền Admin đã được thiết lập';
PRINT '========================================';
PRINT '';
PRINT 'User admin hiện có quyền:';
PRINT '  - Tạo tài khoản mới (/admin/create-user)';
PRINT '';
GO

