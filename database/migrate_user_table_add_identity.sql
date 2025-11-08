-- ============================================
-- Script Migration: Thêm IDENTITY cho bảng User
-- Database: FALL25_Assignment_SonNT
-- ============================================
-- Script này sẽ:
-- 1. Backup dữ liệu User hiện tại
-- 2. Drop các foreign key constraints liên quan
-- 3. Drop và recreate bảng User với IDENTITY
-- 4. Restore dữ liệu (giữ nguyên uid nếu có thể)
-- 5. Recreate foreign key constraints
-- ============================================

USE [FALL25_Assignment_SonNT]
GO

PRINT '========================================'
PRINT 'BẮT ĐẦU MIGRATION: Thêm IDENTITY cho User.uid'
PRINT '========================================'
GO

-- Bước 1: Backup dữ liệu User hiện tại vào bảng tạm
IF OBJECT_ID('tempdb..#UserBackup') IS NOT NULL
    DROP TABLE #UserBackup
GO

SELECT * INTO #UserBackup FROM [User]
GO

DECLARE @backupCount INT
SELECT @backupCount = COUNT(*) FROM #UserBackup
PRINT 'Đã backup ' + CAST(@backupCount AS VARCHAR) + ' records từ bảng User'
GO

-- Bước 2: Tìm max uid hiện tại để set IDENTITY seed
DECLARE @maxUid INT
SELECT @maxUid = ISNULL(MAX(uid), 0) FROM #UserBackup
PRINT 'Max uid hiện tại: ' + CAST(@maxUid AS VARCHAR)
GO

-- Bước 3: Drop các foreign key constraints liên quan đến User
PRINT 'Đang drop foreign key constraints...'
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
BEGIN
    ALTER TABLE [dbo].[Enrollment] DROP CONSTRAINT [FK_Enrollment_User]
    PRINT 'Dropped FK_Enrollment_User'
END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
BEGIN
    ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User]
    PRINT 'Dropped FK_UserRole_User'
END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
BEGIN
    ALTER TABLE [dbo].[ActivityLog] DROP CONSTRAINT [FK_ActivityLog_User]
    PRINT 'Dropped FK_ActivityLog_User'
END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_User')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [FK_PasswordResetRequest_User]
    PRINT 'Dropped FK_PasswordResetRequest_User'
END
GO

IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_ProcessedBy')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [FK_PasswordResetRequest_ProcessedBy]
    PRINT 'Dropped FK_PasswordResetRequest_ProcessedBy'
END
GO

-- Bước 4: Drop bảng User
PRINT 'Đang drop bảng User...'
GO

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    DROP TABLE [dbo].[User]
    PRINT 'Dropped table User'
END
GO

-- Bước 5: Tạo lại bảng User với IDENTITY
-- Set IDENTITY seed = max uid + 1 để tránh conflict
PRINT 'Đang tạo lại bảng User với IDENTITY...'
GO

CREATE TABLE [dbo].[User](
    [uid] [int] IDENTITY(1,1) NOT NULL,
    [username] [varchar](150) NOT NULL,
    [password] [varchar](150) NOT NULL,
    [displayname] [varchar](150) NOT NULL,
 CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([uid] ASC)
) ON [PRIMARY]
GO

PRINT 'Created table User with IDENTITY'
GO

-- Bước 6: Tắt IDENTITY_INSERT để insert dữ liệu với uid cũ
PRINT 'Đang restore dữ liệu...'
GO

SET IDENTITY_INSERT [dbo].[User] ON
GO

-- Insert dữ liệu từ backup, giữ nguyên uid
INSERT INTO [dbo].[User] ([uid], [username], [password], [displayname])
SELECT [uid], [username], [password], [displayname] FROM #UserBackup
ORDER BY [uid]
GO

SET IDENTITY_INSERT [dbo].[User] OFF
GO

DECLARE @restoredCount INT
SELECT @restoredCount = COUNT(*) FROM [User]
PRINT 'Đã restore ' + CAST(@restoredCount AS VARCHAR) + ' records vào bảng User'
GO

-- Bước 7: Set IDENTITY seed = max uid + 1 để các record mới không conflict
DECLARE @newMaxUid INT
SELECT @newMaxUid = ISNULL(MAX(uid), 0) FROM [User]
DBCC CHECKIDENT ('[User]', RESEED, @newMaxUid)
PRINT 'Set IDENTITY seed to ' + CAST(@newMaxUid AS VARCHAR)
GO

-- Bước 8: Recreate foreign key constraints
PRINT 'Đang recreate foreign key constraints...'
GO

-- FK_Enrollment_User
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
BEGIN
    ALTER TABLE [dbo].[Enrollment] WITH CHECK 
    ADD CONSTRAINT [FK_Enrollment_User] FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
    PRINT 'Recreated FK_Enrollment_User'
END
GO

-- FK_UserRole_User
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
BEGIN
    ALTER TABLE [dbo].[UserRole] WITH CHECK 
    ADD CONSTRAINT [FK_UserRole_User] FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
    PRINT 'Recreated FK_UserRole_User'
END
GO

-- FK_ActivityLog_User
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
BEGIN
    ALTER TABLE [dbo].[ActivityLog] WITH CHECK 
    ADD CONSTRAINT [FK_ActivityLog_User] FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
    PRINT 'Recreated FK_ActivityLog_User'
END
GO

-- FK_PasswordResetRequest_User
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_User')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
    ADD CONSTRAINT [FK_PasswordResetRequest_User] FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
    PRINT 'Recreated FK_PasswordResetRequest_User'
END
GO

-- FK_PasswordResetRequest_ProcessedBy
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_ProcessedBy')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
    ADD CONSTRAINT [FK_PasswordResetRequest_ProcessedBy] FOREIGN KEY([processed_by]) REFERENCES [dbo].[User] ([uid])
    PRINT 'Recreated FK_PasswordResetRequest_ProcessedBy'
END
GO

-- Bước 9: Cleanup
DROP TABLE #UserBackup
GO

PRINT '========================================'
PRINT 'MIGRATION HOÀN TẤT!'
PRINT '========================================'
PRINT 'Bảng User đã được migrate thành công với IDENTITY.'
PRINT 'Tất cả dữ liệu đã được giữ nguyên.'
PRINT '========================================'
GO

