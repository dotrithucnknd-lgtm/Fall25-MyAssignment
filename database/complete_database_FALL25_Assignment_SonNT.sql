-- ============================================
-- Script HOÀN CHỈNH Database FALL25_Assignment_SonNT
-- Để chạy TẤT CẢ chức năng website
-- ============================================
-- Script này bao gồm:
-- 1. Tất cả các bảng cơ bản (Division, Employee, User, Enrollment, Role, Feature, etc.)
-- 2. Bảng RequestForLeave
-- 3. Bảng ActivityLog (để ghi log hoạt động)
-- 4. Bảng Attendance (để quản lý chấm công)
-- 5. Bảng RequestForLeaveHistory (nếu cần)
-- 6. Tất cả Foreign Keys và Constraints
-- 7. Dữ liệu mẫu đầy đủ
-- ============================================

USE [FALL25_Assignment_SonNT]
GO

-- ============================================
-- PHẦN 1: TẠO CÁC BẢNG CƠ BẢN
-- ============================================

-- Bảng Division
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Division' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Division](
        [did] [int] NOT NULL,
        [dname] [varchar](150) NOT NULL,
     CONSTRAINT [PK_Division] PRIMARY KEY CLUSTERED ([did] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng Employee
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Employee](
        [eid] [int] NOT NULL,
        [ename] [varchar](150) NOT NULL,
        [did] [int] NOT NULL,
        [supervisorid] [int] NULL,
     CONSTRAINT [PK_Employee] PRIMARY KEY CLUSTERED ([eid] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng User
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[User](
        [uid] [int] IDENTITY(1,1) NOT NULL,
        [username] [varchar](150) NOT NULL,
        [password] [varchar](150) NOT NULL,
        [displayname] [varchar](150) NOT NULL,
     CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([uid] ASC)
    ) ON [PRIMARY]
END
ELSE
BEGIN
    -- Nếu bảng đã tồn tại nhưng uid chưa có IDENTITY, thêm IDENTITY
    -- Lưu ý: Không thể ALTER COLUMN để thêm IDENTITY trực tiếp, cần tạo bảng mới
    -- Nếu bảng đã có dữ liệu, cần migrate dữ liệu
    -- Ở đây chỉ kiểm tra và thông báo nếu cần
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID('dbo.User') 
        AND name = 'uid' 
        AND is_identity = 1
    )
    BEGIN
        PRINT 'WARNING: User.uid does not have IDENTITY. Please manually add IDENTITY or recreate table.'
    END
END
GO

-- Bảng Enrollment
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Enrollment](
        [uid] [int] NOT NULL,
        [eid] [int] NOT NULL,
        [active] [bit] NOT NULL,
     CONSTRAINT [PK_Enrollment] PRIMARY KEY CLUSTERED ([uid] ASC, [eid] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng Role
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Role' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Role](
        [rid] [int] NOT NULL,
        [rname] [varchar](150) NOT NULL,
     CONSTRAINT [PK_Role] PRIMARY KEY CLUSTERED ([rid] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng Feature
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Feature' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Feature](
        [fid] [int] NOT NULL,
        [url] [varchar](max) NOT NULL,
     CONSTRAINT [PK_Feature] PRIMARY KEY CLUSTERED ([fid] ASC)
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

-- Bảng RoleFeature
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RoleFeature' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[RoleFeature](
        [rid] [int] NOT NULL,
        [fid] [int] NOT NULL,
     CONSTRAINT [PK_RoleFeature] PRIMARY KEY CLUSTERED ([rid] ASC, [fid] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng UserRole
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[UserRole](
        [uid] [int] NOT NULL,
        [rid] [int] NOT NULL,
     CONSTRAINT [PK_UserRole] PRIMARY KEY CLUSTERED ([uid] ASC, [rid] ASC)
    ) ON [PRIMARY]
END
GO

-- Bảng RequestForLeave
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeave' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[RequestForLeave](
        [rid] [int] IDENTITY(1,1) NOT NULL,
        [created_by] [int] NOT NULL,
        [created_time] [datetime] NOT NULL,
        [from] [date] NOT NULL,
        [to] [date] NOT NULL,
        [reason] [varchar](max) NOT NULL,
        [status] [int] NOT NULL,
        [processed_by] [int] NULL,
     CONSTRAINT [PK_RequestForLeave] PRIMARY KEY CLUSTERED ([rid] ASC)
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
END
GO

-- ============================================
-- PHẦN 2: TẠO CÁC BẢNG BỔ SUNG
-- ============================================

-- Bảng ActivityLog (để ghi log hoạt động)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[ActivityLog](
        [log_id] [int] IDENTITY(1,1) NOT NULL,
        [user_id] [int] NOT NULL,
        [employee_id] [int] NULL,
        [activity_type] [nvarchar](50) NOT NULL,
        [entity_type] [nvarchar](50) NULL,
        [entity_id] [int] NULL,
        [action_description] [nvarchar](500) NULL,
        [old_value] [nvarchar](max) NULL,
        [new_value] [nvarchar](max) NULL,
        [ip_address] [nvarchar](50) NULL,
        [user_agent] [nvarchar](500) NULL,
        [created_at] [datetime2](7) NOT NULL DEFAULT GETDATE(),
     CONSTRAINT [PK_ActivityLog] PRIMARY KEY CLUSTERED ([log_id] ASC)
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    -- Tạo index để tăng hiệu suất
    CREATE INDEX [IX_ActivityLog_User] ON [dbo].[ActivityLog]([user_id])
    CREATE INDEX [IX_ActivityLog_ActivityType] ON [dbo].[ActivityLog]([activity_type])
    CREATE INDEX [IX_ActivityLog_CreatedAt] ON [dbo].[ActivityLog]([created_at] DESC)
    CREATE INDEX [IX_ActivityLog_Entity] ON [dbo].[ActivityLog]([entity_type], [entity_id])
END
GO

-- Bảng Attendance (để quản lý chấm công)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Attendance' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[Attendance](
        [attendance_id] [int] IDENTITY(1,1) NOT NULL,
        [employee_id] [int] NOT NULL,
        [request_id] [int] NULL,
        [attendance_date] [date] NOT NULL,
        [check_in_time] [time](7) NULL,
        [check_out_time] [time](7) NULL,
        [note] [nvarchar](max) NULL,
        [created_at] [datetime2](7) NOT NULL DEFAULT GETDATE(),
     CONSTRAINT [PK_Attendance] PRIMARY KEY CLUSTERED ([attendance_id] ASC)
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    -- Tạo index
    CREATE INDEX [IX_Attendance_Employee] ON [dbo].[Attendance]([employee_id])
    CREATE INDEX [IX_Attendance_Request] ON [dbo].[Attendance]([request_id])
    CREATE INDEX [IX_Attendance_Date] ON [dbo].[Attendance]([attendance_date] DESC)
END
GO

-- Bảng RequestForLeaveHistory (lịch sử thay đổi đơn nghỉ phép)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'RequestForLeaveHistory' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[RequestForLeaveHistory](
        [id] [int] IDENTITY(1,1) NOT NULL,
        [rid] [int] NOT NULL,
        [old_status] [int] NULL,
        [new_status] [int] NOT NULL,
        [processed_by] [int] NULL,
        [processed_time] [datetime] NOT NULL DEFAULT GETDATE(),
        [note] [nvarchar](max) NULL,
     CONSTRAINT [PK_RequestForLeaveHistory] PRIMARY KEY CLUSTERED ([id] ASC)
    ) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
    
    -- Tạo index
    CREATE INDEX [IX_RequestForLeaveHistory_Request] ON [dbo].[RequestForLeaveHistory]([rid])
    CREATE INDEX [IX_RequestForLeaveHistory_ProcessedBy] ON [dbo].[RequestForLeaveHistory]([processed_by])
    CREATE INDEX [IX_RequestForLeaveHistory_ProcessedTime] ON [dbo].[RequestForLeaveHistory]([processed_time] DESC)
END
GO

-- ============================================
-- PHẦN 3: TẠO FOREIGN KEYS
-- ============================================

-- Foreign Keys cho Employee
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Employee_Division')
BEGIN
    ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_Division] 
    FOREIGN KEY([did]) REFERENCES [dbo].[Division] ([did])
    ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Division]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Employee_Employee')
BEGIN
    ALTER TABLE [dbo].[Employee] WITH CHECK ADD CONSTRAINT [FK_Employee_Employee] 
    FOREIGN KEY([supervisorid]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[Employee] CHECK CONSTRAINT [FK_Employee_Employee]
END
GO

-- Foreign Keys cho Enrollment
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
BEGIN
    ALTER TABLE [dbo].[Enrollment] WITH CHECK ADD CONSTRAINT [FK_Enrollment_User] 
    FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
    ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_User]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_Employee')
BEGIN
    ALTER TABLE [dbo].[Enrollment] WITH CHECK ADD CONSTRAINT [FK_Enrollment_Employee] 
    FOREIGN KEY([eid]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_Employee]
END
GO

-- Foreign Keys cho RoleFeature
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RoleFeature_Role')
BEGIN
    ALTER TABLE [dbo].[RoleFeature] WITH CHECK ADD CONSTRAINT [FK_RoleFeature_Role] 
    FOREIGN KEY([rid]) REFERENCES [dbo].[Role] ([rid])
    ALTER TABLE [dbo].[RoleFeature] CHECK CONSTRAINT [FK_RoleFeature_Role]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RoleFeature_Feature')
BEGIN
    ALTER TABLE [dbo].[RoleFeature] WITH CHECK ADD CONSTRAINT [FK_RoleFeature_Feature] 
    FOREIGN KEY([fid]) REFERENCES [dbo].[Feature] ([fid])
    ALTER TABLE [dbo].[RoleFeature] CHECK CONSTRAINT [FK_RoleFeature_Feature]
END
GO

-- Foreign Keys cho UserRole
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
BEGIN
    ALTER TABLE [dbo].[UserRole] WITH CHECK ADD CONSTRAINT [FK_UserRole_User] 
    FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
    ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_Role')
BEGIN
    ALTER TABLE [dbo].[UserRole] WITH CHECK ADD CONSTRAINT [FK_UserRole_Role] 
    FOREIGN KEY([rid]) REFERENCES [dbo].[Role] ([rid])
    ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_Role]
END
GO

-- Foreign Keys cho RequestForLeave
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RequestForLeave_Employee')
BEGIN
    ALTER TABLE [dbo].[RequestForLeave] WITH CHECK ADD CONSTRAINT [FK_RequestForLeave_Employee] 
    FOREIGN KEY([created_by]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[RequestForLeave] CHECK CONSTRAINT [FK_RequestForLeave_Employee]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RequestForLeave_Employee_Processed')
BEGIN
    ALTER TABLE [dbo].[RequestForLeave] WITH CHECK ADD CONSTRAINT [FK_RequestForLeave_Employee_Processed] 
    FOREIGN KEY([processed_by]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[RequestForLeave] CHECK CONSTRAINT [FK_RequestForLeave_Employee_Processed]
END
GO

-- Foreign Keys cho ActivityLog
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
BEGIN
    ALTER TABLE [dbo].[ActivityLog] WITH CHECK ADD CONSTRAINT [FK_ActivityLog_User] 
    FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
    ALTER TABLE [dbo].[ActivityLog] CHECK CONSTRAINT [FK_ActivityLog_User]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_Employee')
BEGIN
    ALTER TABLE [dbo].[ActivityLog] WITH CHECK ADD CONSTRAINT [FK_ActivityLog_Employee] 
    FOREIGN KEY([employee_id]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[ActivityLog] CHECK CONSTRAINT [FK_ActivityLog_Employee]
END
GO

-- Foreign Keys cho Attendance
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Attendance_Employee')
BEGIN
    ALTER TABLE [dbo].[Attendance] WITH CHECK ADD CONSTRAINT [FK_Attendance_Employee] 
    FOREIGN KEY([employee_id]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_Employee]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Attendance_RequestForLeave')
BEGIN
    ALTER TABLE [dbo].[Attendance] WITH CHECK ADD CONSTRAINT [FK_Attendance_RequestForLeave] 
    FOREIGN KEY([request_id]) REFERENCES [dbo].[RequestForLeave] ([rid])
    ALTER TABLE [dbo].[Attendance] CHECK CONSTRAINT [FK_Attendance_RequestForLeave]
END
GO

-- Foreign Keys cho RequestForLeaveHistory
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RequestForLeaveHistory_RequestForLeave')
BEGIN
    ALTER TABLE [dbo].[RequestForLeaveHistory] WITH CHECK ADD CONSTRAINT [FK_RequestForLeaveHistory_RequestForLeave] 
    FOREIGN KEY([rid]) REFERENCES [dbo].[RequestForLeave] ([rid])
    ALTER TABLE [dbo].[RequestForLeaveHistory] CHECK CONSTRAINT [FK_RequestForLeaveHistory_RequestForLeave]
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_RequestForLeaveHistory_Employee')
BEGIN
    ALTER TABLE [dbo].[RequestForLeaveHistory] WITH CHECK ADD CONSTRAINT [FK_RequestForLeaveHistory_Employee] 
    FOREIGN KEY([processed_by]) REFERENCES [dbo].[Employee] ([eid])
    ALTER TABLE [dbo].[RequestForLeaveHistory] CHECK CONSTRAINT [FK_RequestForLeaveHistory_Employee]
END
GO

-- ============================================
-- PHẦN 4: TẠO VIEWS
-- ============================================

-- View vw_ActivityLog
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActivityLog')
    DROP VIEW [dbo].[vw_ActivityLog]
GO

CREATE VIEW [dbo].[vw_ActivityLog] AS
SELECT 
    al.log_id,
    al.user_id,
    u.username,
    u.displayname,
    al.employee_id,
    e.ename AS employee_name,
    al.activity_type,
    al.entity_type,
    al.entity_id,
    al.action_description,
    al.old_value,
    al.new_value,
    al.ip_address,
    al.user_agent,
    al.created_at
FROM ActivityLog al
LEFT JOIN [User] u ON al.user_id = u.uid
LEFT JOIN Employee e ON al.employee_id = e.eid
GO

-- View vw_Attendance
IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Attendance')
    DROP VIEW [dbo].[vw_Attendance]
GO

CREATE VIEW [dbo].[vw_Attendance] AS
SELECT 
    a.attendance_id,
    a.employee_id,
    e.ename AS employee_name,
    a.request_id,
    r.[from] AS request_from,
    r.[to] AS request_to,
    r.reason AS request_reason,
    a.attendance_date,
    a.check_in_time,
    a.check_out_time,
    a.note,
    a.created_at
FROM Attendance a
INNER JOIN Employee e ON a.employee_id = e.eid
LEFT JOIN RequestForLeave r ON a.request_id = r.rid
GO

-- ============================================
-- PHẦN 5: INSERT DỮ LIỆU MẪU
-- ============================================

-- Xóa dữ liệu cũ (nếu cần)
-- DELETE FROM [RequestForLeaveHistory]
-- DELETE FROM [Attendance]
-- DELETE FROM [ActivityLog]
-- DELETE FROM [RequestForLeave]
-- DELETE FROM [UserRole]
-- DELETE FROM [RoleFeature]
-- DELETE FROM [Enrollment]
-- DELETE FROM [User]
-- DELETE FROM [Employee]
-- DELETE FROM [Division]
-- DELETE FROM [Role]
-- DELETE FROM [Feature]

-- Insert Division
IF NOT EXISTS (SELECT * FROM [dbo].[Division] WHERE [did] = 1)
    INSERT [dbo].[Division] ([did], [dname]) VALUES (1, N'IT')
IF NOT EXISTS (SELECT * FROM [dbo].[Division] WHERE [did] = 2)
    INSERT [dbo].[Division] ([did], [dname]) VALUES (2, N'QA')
IF NOT EXISTS (SELECT * FROM [dbo].[Division] WHERE [did] = 3)
    INSERT [dbo].[Division] ([did], [dname]) VALUES (3, N'Sale')
GO

-- Insert Employee
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 1)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (1, N'Nguyen Van A', 1, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 2)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (2, N'Tran Van B', 1, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 3)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (3, N'CCCCCC', 1, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 4)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (4, N'Mr DDDD', 1, 2)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 5)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (5, N'Mr EEEE', 1, 3)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 6)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (6, N'Mr GGGGG', 1, 2)
IF NOT EXISTS (SELECT * FROM [dbo].[Employee] WHERE [eid] = 7)
    INSERT [dbo].[Employee] ([eid], [ename], [did], [supervisorid]) VALUES (7, N'System Administrator', 1, NULL)
GO

-- Insert User
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 1)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (1, N'mra', N'123', N'Mr A - Division Leader')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 2)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (2, N'mrb', N'123', N'Mr B - Manager')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 3)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (3, N'mrc', N'123', N'Mr C - Manager')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 4)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (4, N'mrd', N'123', N'Employee MrD')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 5)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (5, N'mre', N'123', N'Employee MrE')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 6)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (6, N'mrg', N'123', N'Unassigned Role')
IF NOT EXISTS (SELECT * FROM [dbo].[User] WHERE [uid] = 7)
    INSERT [dbo].[User] ([uid], [username], [password], [displayname]) VALUES (7, N'admin', N'admin123', N'System Administrator')
GO

-- Insert Enrollment
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 1 AND [eid] = 1)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (1, 1, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 2 AND [eid] = 2)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (2, 2, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 3 AND [eid] = 3)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (3, 3, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 4 AND [eid] = 4)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (4, 4, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 5 AND [eid] = 5)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (5, 5, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 6 AND [eid] = 6)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (6, 6, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[Enrollment] WHERE [uid] = 7 AND [eid] = 7)
    INSERT [dbo].[Enrollment] ([uid], [eid], [active]) VALUES (7, 7, 1)
GO

-- Insert Role
IF NOT EXISTS (SELECT * FROM [dbo].[Role] WHERE [rid] = 1)
    INSERT [dbo].[Role] ([rid], [rname]) VALUES (1, N'IT Head')
IF NOT EXISTS (SELECT * FROM [dbo].[Role] WHERE [rid] = 2)
    INSERT [dbo].[Role] ([rid], [rname]) VALUES (2, N'IT PM')
IF NOT EXISTS (SELECT * FROM [dbo].[Role] WHERE [rid] = 3)
    INSERT [dbo].[Role] ([rid], [rname]) VALUES (3, N'IT Employee')
IF NOT EXISTS (SELECT * FROM [dbo].[Role] WHERE [rid] = 4)
    INSERT [dbo].[Role] ([rid], [rname]) VALUES (4, N'Admin')
GO

-- Insert Feature
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 1)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (1, N'/request/create')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 2)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (2, N'/request/review')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 3)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (3, N'/request/list')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 4)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (4, N'/division/agenda')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 5)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (5, N'/request/history')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 6)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (6, N'/home')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 7)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (7, N'/statistics')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 8)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (8, N'/attendance')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 9)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (9, N'/admin/create-user')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 10)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (10, N'/admin/delete-user')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 11)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (11, N'/admin/reset-password')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 12)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (12, N'/forgot-password')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 13)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (13, N'/admin/password-reset-requests')
IF NOT EXISTS (SELECT * FROM [dbo].[Feature] WHERE [fid] = 14)
    INSERT [dbo].[Feature] ([fid], [url]) VALUES (14, N'/division/attendance')
GO

-- Insert RoleFeature
-- IT Head (rid=1) - có tất cả quyền
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 1)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 1) -- /request/create
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 2)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 2) -- /request/review
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 3)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 3) -- /request/list
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 4)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 4) -- /division/agenda
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 5)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 5) -- /request/history
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 6)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 6) -- /home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 7)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 7) -- /statistics
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 8)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 8) -- /attendance
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 9)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 9) -- /admin/create-user
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 1 AND [fid] = 14)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (1, 14) -- /division/attendance

-- IT PM (rid=2) - có quyền tạo, review, list, history, home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 1)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 1) -- /request/create
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 2)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 2) -- /request/review
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 3)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 3) -- /request/list
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 5)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 5) -- /request/history
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 6)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 6) -- /home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 2 AND [fid] = 8)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (2, 8) -- /attendance

-- IT Employee (rid=3) - có quyền tạo, list, history, home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 3 AND [fid] = 1)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (3, 1) -- /request/create
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 3 AND [fid] = 3)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (3, 3) -- /request/list
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 3 AND [fid] = 5)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (3, 5) -- /request/history
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 3 AND [fid] = 6)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (3, 6) -- /home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 3 AND [fid] = 8)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (3, 8) -- /attendance

-- Admin (rid=4) - có quyền quản lý user: tạo, xóa, reset password, home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 4 AND [fid] = 6)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (4, 6) -- /home
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 4 AND [fid] = 9)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (4, 9) -- /admin/create-user
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 4 AND [fid] = 10)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (4, 10) -- /admin/delete-user
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 4 AND [fid] = 11)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (4, 11) -- /admin/reset-password
IF NOT EXISTS (SELECT * FROM [dbo].[RoleFeature] WHERE [rid] = 4 AND [fid] = 13)
    INSERT [dbo].[RoleFeature] ([rid], [fid]) VALUES (4, 13) -- /admin/password-reset-requests
GO

-- Insert UserRole
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 1 AND [rid] = 1)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (1, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 2 AND [rid] = 2)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (2, 2)
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 3 AND [rid] = 2)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (3, 2)
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 4 AND [rid] = 3)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (4, 3)
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 5 AND [rid] = 3)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (5, 3)
IF NOT EXISTS (SELECT * FROM [dbo].[UserRole] WHERE [uid] = 7 AND [rid] = 4)
    INSERT [dbo].[UserRole] ([uid], [rid]) VALUES (7, 4) -- Admin user với role Admin
GO

-- Insert RequestForLeave (sử dụng SET IDENTITY_INSERT)
SET IDENTITY_INSERT [dbo].[RequestForLeave] ON
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 1)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (1, 1, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'Nghi lay vo', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 2)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (2, 2, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'asfasf', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 3)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (3, 2, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'reeeee', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 4)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (4, 3, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'ssssss', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 5)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (5, 3, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'ffff', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 6)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (6, 4, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'aasss', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 7)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (7, 4, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'asfasfasf', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 8)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (8, 4, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'asfasfasfasfasfasf', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 9)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (9, 5, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'asfafasfaf', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 10)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (10, 5, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'asfafafasfasfasfasfasf', 0, NULL)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 11)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (11, 5, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'aaaa', 1, 1)
IF NOT EXISTS (SELECT * FROM [dbo].[RequestForLeave] WHERE [rid] = 12)
    INSERT [dbo].[RequestForLeave] ([rid], [created_by], [created_time], [from], [to], [reason], [status], [processed_by]) 
    VALUES (12, 5, CAST(N'2025-10-21T00:00:00.000' AS DateTime), CAST(N'2025-10-22' AS Date), CAST(N'2025-10-24' AS Date), N'aaaaaaaaaaaa', 2, 1)
SET IDENTITY_INSERT [dbo].[RequestForLeave] OFF
GO

-- Bảng PasswordResetRequest (Yêu cầu reset mật khẩu)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PasswordResetRequest' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    CREATE TABLE [dbo].[PasswordResetRequest](
        [prr_id] [int] IDENTITY(1,1) NOT NULL,
        [user_id] [int] NOT NULL,
        [username] [varchar](150) NOT NULL,
        [request_time] [datetime] NOT NULL DEFAULT GETDATE(),
        [status] [int] NOT NULL DEFAULT 0, -- 0=Pending, 1=Processed, 2=Cancelled
        [processed_by] [int] NULL,
        [processed_time] [datetime] NULL,
        [note] [varchar](500) NULL,
     CONSTRAINT [PK_PasswordResetRequest] PRIMARY KEY CLUSTERED ([prr_id] ASC)
    ) ON [PRIMARY]
END
GO

-- Foreign Key cho PasswordResetRequest
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_User')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
    ADD CONSTRAINT [FK_PasswordResetRequest_User] FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
END
GO

IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_ProcessedBy')
BEGIN
    ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
    ADD CONSTRAINT [FK_PasswordResetRequest_ProcessedBy] FOREIGN KEY([processed_by]) REFERENCES [dbo].[User] ([uid])
END
GO

-- Index cho PasswordResetRequest (Optimized)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequest_Status' AND object_id = OBJECT_ID('dbo.PasswordResetRequest'))
BEGIN
    CREATE INDEX [IX_PasswordResetRequest_Status] ON [dbo].[PasswordResetRequest]([status])
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequest_RequestTime' AND object_id = OBJECT_ID('dbo.PasswordResetRequest'))
BEGIN
    CREATE INDEX [IX_PasswordResetRequest_RequestTime] ON [dbo].[PasswordResetRequest]([request_time] DESC)
END
GO

-- Composite index để tối ưu query getPendingRequests (status = 0 ORDER BY request_time)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequest_Status_RequestTime' AND object_id = OBJECT_ID('dbo.PasswordResetRequest'))
BEGIN
    CREATE INDEX [IX_PasswordResetRequest_Status_RequestTime] ON [dbo].[PasswordResetRequest]([status], [request_time] ASC)
END
GO

-- Index cho user_id để tối ưu JOIN
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_PasswordResetRequest_UserId' AND object_id = OBJECT_ID('dbo.PasswordResetRequest'))
BEGIN
    CREATE INDEX [IX_PasswordResetRequest_UserId] ON [dbo].[PasswordResetRequest]([user_id])
END
GO

-- ============================================
-- PHẦN 5.5: SỬA BẢNG User NẾU CHƯA CÓ IDENTITY
-- ============================================
-- Kiểm tra và thêm IDENTITY cho uid nếu bảng đã tồn tại nhưng chưa có IDENTITY
-- Lưu ý: Nếu bảng đã có dữ liệu, cần chạy script migrate_user_table_add_identity.sql
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID('dbo.User') 
        AND name = 'uid' 
        AND is_identity = 1
    )
    BEGIN
        DECLARE @rowCount INT
        SELECT @rowCount = COUNT(*) FROM [User]
        
        IF @rowCount = 0
        BEGIN
            -- Nếu bảng rỗng, drop và tạo lại với IDENTITY
            PRINT 'Table User is empty. Recreating with IDENTITY...'
            
            -- Drop foreign keys first
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
                ALTER TABLE [dbo].[Enrollment] DROP CONSTRAINT [FK_Enrollment_User]
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
                ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User]
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
                ALTER TABLE [dbo].[ActivityLog] DROP CONSTRAINT [FK_ActivityLog_User]
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_User')
                ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [FK_PasswordResetRequest_User]
            IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_PasswordResetRequest_ProcessedBy')
                ALTER TABLE [dbo].[PasswordResetRequest] DROP CONSTRAINT [FK_PasswordResetRequest_ProcessedBy]
            
            DROP TABLE [dbo].[User]
            
            CREATE TABLE [dbo].[User](
                [uid] [int] IDENTITY(1,1) NOT NULL,
                [username] [varchar](150) NOT NULL,
                [password] [varchar](150) NOT NULL,
                [displayname] [varchar](150) NOT NULL,
             CONSTRAINT [PK_User] PRIMARY KEY CLUSTERED ([uid] ASC)
            ) ON [PRIMARY]
            
            -- Recreate foreign keys
            ALTER TABLE [dbo].[Enrollment] WITH CHECK 
            ADD CONSTRAINT [FK_Enrollment_User] FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
            
            ALTER TABLE [dbo].[UserRole] WITH CHECK 
            ADD CONSTRAINT [FK_UserRole_User] FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid])
            
            ALTER TABLE [dbo].[ActivityLog] WITH CHECK 
            ADD CONSTRAINT [FK_ActivityLog_User] FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
            
            ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
            ADD CONSTRAINT [FK_PasswordResetRequest_User] FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid])
            
            ALTER TABLE [dbo].[PasswordResetRequest] WITH CHECK 
            ADD CONSTRAINT [FK_PasswordResetRequest_ProcessedBy] FOREIGN KEY([processed_by]) REFERENCES [dbo].[User] ([uid])
            
            PRINT 'Table User recreated with IDENTITY successfully.'
        END
        ELSE
        BEGIN
            PRINT 'WARNING: Table User has ' + CAST(@rowCount AS VARCHAR) + ' rows. Cannot auto-migrate.'
            PRINT 'Vui lòng chạy script: database/migrate_user_table_add_identity.sql để migrate dữ liệu.'
            PRINT 'Script này sẽ:'
            PRINT '  1. Backup dữ liệu User'
            PRINT '  2. Drop và recreate bảng User với IDENTITY'
            PRINT '  3. Restore dữ liệu (giữ nguyên uid)'
            PRINT '  4. Recreate foreign key constraints'
        END
    END
END
GO

-- ============================================
-- PHẦN 6: CẤP QUYỀN CHO USER java_admin
-- ============================================

-- Đảm bảo user java_admin có quyền truy cập database
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'java_admin')
BEGIN
    CREATE USER [java_admin] FOR LOGIN [java_admin]
END
GO

-- Cấp quyền db_owner cho user java_admin
ALTER ROLE [db_owner] ADD MEMBER [java_admin]
GO

-- ============================================
-- HOÀN TẤT
-- ============================================

PRINT '========================================'
PRINT 'DATABASE FALL25_Assignment_SonNT ĐÃ ĐƯỢC HOÀN THIỆN!'
PRINT '========================================'
PRINT 'Các bảng đã được tạo:'
PRINT '  - Division, Employee, User, Enrollment'
PRINT '  - Role, Feature, RoleFeature, UserRole'
PRINT '  - RequestForLeave'
PRINT '  - ActivityLog (ghi log hoạt động)'
PRINT '  - Attendance (quản lý chấm công)'
PRINT '  - RequestForLeaveHistory (lịch sử thay đổi)'
PRINT '  - PasswordResetRequest (yêu cầu reset mật khẩu)'
PRINT ''
PRINT 'Các View đã được tạo:'
PRINT '  - vw_ActivityLog'
PRINT '  - vw_Attendance'
PRINT ''
PRINT 'Các Role đã được tạo:'
PRINT '  - IT Head (rid=1) - Tất cả quyền'
PRINT '  - IT PM (rid=2) - Tạo, review, list, history, home, attendance'
PRINT '  - IT Employee (rid=3) - Tạo, list, history, home, attendance'
PRINT '  - Admin (rid=4) - Quản lý user: tạo, xóa, reset password, home'
PRINT ''
PRINT 'Các Feature đã được tạo:'
PRINT '  - /request/create, /request/review, /request/list, /request/history'
PRINT '  - /division/agenda'
PRINT '  - /home, /statistics, /attendance'
PRINT '  - /admin/create-user, /admin/delete-user, /admin/reset-password'
PRINT '  - /forgot-password (yêu cầu reset mật khẩu)'
PRINT '  - /admin/password-reset-requests (quản lý yêu cầu reset mật khẩu)'
PRINT ''
PRINT 'User Admin đã được tạo:'
PRINT '  - Username: admin'
PRINT '  - Password: admin123'
PRINT '  - Role: Admin (có quyền tạo, xóa user và reset password)'
PRINT ''
PRINT 'Dữ liệu mẫu đã được insert thành công!'
PRINT 'User java_admin đã được cấp quyền db_owner!'
PRINT '========================================'
GO

