-- Script sửa bảng User để thêm IDENTITY cho uid
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05

USE [FALL25_Assignment]
GO

-- Kiểm tra xem bảng User có tồn tại không
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    PRINT 'Đang kiểm tra cấu trúc bảng User...';
    
    -- Kiểm tra xem uid có phải là IDENTITY không
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('dbo.User') AND name = 'uid'
    )
    BEGIN
        PRINT 'LỖI: Cột uid không phải là IDENTITY!';
        PRINT 'Đang sửa lại bảng User...';
        
        -- Lưu dữ liệu hiện có (nếu có)
        IF EXISTS (SELECT TOP 1 * FROM [User])
        BEGIN
            PRINT 'Cảnh báo: Bảng User đã có dữ liệu. Vui lòng backup trước khi chạy script này!';
            PRINT 'Script này sẽ xóa tất cả dữ liệu trong bảng User và các bảng liên quan!';
            PRINT 'Nhấn Ctrl+C để hủy, hoặc đợi 5 giây để tiếp tục...';
            WAITFOR DELAY '00:00:05';
        END
        
        -- Xóa dữ liệu trong các bảng có foreign key tham chiếu đến User
        PRINT 'Đang xóa dữ liệu trong các bảng liên quan...';
        
        -- Xóa dữ liệu trong ActivityLog
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[ActivityLog];
            PRINT 'Đã xóa dữ liệu trong ActivityLog';
        END
        
        -- Xóa dữ liệu trong Enrollment
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[Enrollment];
            PRINT 'Đã xóa dữ liệu trong Enrollment';
        END
        
        -- Xóa dữ liệu trong UserRole
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[UserRole];
            PRINT 'Đã xóa dữ liệu trong UserRole';
        END
        
        -- Xóa các foreign key constraints liên quan đến User
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE referenced_object_id = OBJECT_ID('dbo.User'))
        BEGIN
            PRINT 'Đang xóa foreign key constraints...';
            
            -- Xóa FK từ ActivityLog
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
            BEGIN
                ALTER TABLE [dbo].[ActivityLog] DROP CONSTRAINT [FK_ActivityLog_User];
                PRINT 'Đã xóa FK_ActivityLog_User';
            END
            
            -- Xóa FK từ Enrollment
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
            BEGIN
                ALTER TABLE [dbo].[Enrollment] DROP CONSTRAINT [FK_Enrollment_User];
                PRINT 'Đã xóa FK_Enrollment_User';
            END
            
            -- Xóa FK từ UserRole
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
            BEGIN
                ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User];
                PRINT 'Đã xóa FK_UserRole_User';
            END
        END
        
        -- Xóa primary key constraint
        IF EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.User') AND name = 'PK_User')
        BEGIN
            ALTER TABLE [dbo].[User] DROP CONSTRAINT [PK_User];
            PRINT 'Đã xóa PK_User';
        END
        
        -- Xóa unique constraint
        IF EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.User') AND name = 'UQ_User_Username')
        BEGIN
            ALTER TABLE [dbo].[User] DROP CONSTRAINT [UQ_User_Username];
            PRINT 'Đã xóa UQ_User_Username';
        END
        
        -- Xóa bảng User cũ
        DROP TABLE [dbo].[User];
        PRINT 'Đã xóa bảng User cũ';
        
        -- Tạo lại bảng User với IDENTITY
        CREATE TABLE [dbo].[User](
            [uid] [int] IDENTITY(1,1) NOT NULL,
            [username] [varchar](150) NOT NULL,
            [password] [varchar](150) NOT NULL,
            [displayname] [varchar](150) NOT NULL,
            CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED 
            (
                [uid] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
            CONSTRAINT [UQ_User_Username] UNIQUE NONCLUSTERED 
            (
                [username] ASC
            )WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
        ) ON [PRIMARY];
        PRINT 'Đã tạo lại bảng User với uid IDENTITY(1,1)';
        
        -- Tạo lại foreign key constraints
        PRINT 'Đang tạo lại foreign key constraints...';
        
        -- FK từ ActivityLog
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[ActivityLog] WITH NOCHECK ADD CONSTRAINT [FK_ActivityLog_User] 
            FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[ActivityLog] CHECK CONSTRAINT [FK_ActivityLog_User];
            PRINT 'Đã tạo lại FK_ActivityLog_User';
        END
        
        -- FK từ Enrollment
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[Enrollment] WITH NOCHECK ADD CONSTRAINT [FK_Enrollment_User] 
            FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_User];
            PRINT 'Đã tạo lại FK_Enrollment_User';
        END
        
        -- FK từ UserRole
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[UserRole] WITH NOCHECK ADD CONSTRAINT [FK_UserRole_User] 
            FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User];
            PRINT 'Đã tạo lại FK_UserRole_User';
        END
        
        PRINT '';
        PRINT '✓ Hoàn thành! Bảng User đã được sửa với uid IDENTITY(1,1)';
        PRINT '✓ Tất cả foreign key constraints đã được tạo lại';
    END
    ELSE
    BEGIN
        PRINT 'Bảng User đã có uid IDENTITY(1,1) - không cần sửa';
    END
END
ELSE
BEGIN
    PRINT 'LỖI: Bảng User không tồn tại!';
END
GO

