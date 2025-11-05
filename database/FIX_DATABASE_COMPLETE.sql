-- ============================================================
-- SCRIPT TỔNG HỢP SỬA DATABASE HOÀN CHỈNH
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05
-- 
-- Mô tả: Script này sẽ:
-- 1. Sửa bảng User để có IDENTITY cho uid
-- 2. Tạo user admin mặc định
-- 3. Tạo các nhân viên mẫu
-- 4. Thiết lập quyền Admin cho user admin
-- ============================================================

USE [FALL25_Assignment]
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU SỬA DATABASE';
PRINT '========================================';
PRINT '';

-- ============================================================
-- BƯỚC 1: SỬA BẢNG USER - THÊM IDENTITY CHO UID
-- ============================================================

PRINT 'BƯỚC 1: Kiểm tra và sửa bảng User...';
PRINT '';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User' AND schema_id = SCHEMA_ID('dbo'))
BEGIN
    -- Kiểm tra xem uid có phải là IDENTITY không
    IF NOT EXISTS (
        SELECT * FROM sys.identity_columns 
        WHERE object_id = OBJECT_ID('dbo.User') AND name = 'uid'
    )
    BEGIN
        PRINT '⚠️  Cột uid không phải là IDENTITY!';
        PRINT 'Đang sửa lại bảng User...';
        
        -- Cảnh báo về dữ liệu
        IF EXISTS (SELECT TOP 1 * FROM [User])
        BEGIN
            PRINT '⚠️  CẢNH BÁO: Bảng User đã có dữ liệu!';
            PRINT 'Script này sẽ xóa tất cả dữ liệu trong bảng User và các bảng liên quan!';
            PRINT 'Nhấn Ctrl+C để hủy, hoặc đợi 5 giây để tiếp tục...';
            WAITFOR DELAY '00:00:05';
        END
        
        -- Xóa dữ liệu trong các bảng có foreign key tham chiếu đến User
        PRINT 'Đang xóa dữ liệu trong các bảng liên quan...';
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[ActivityLog];
            PRINT '✓ Đã xóa dữ liệu trong ActivityLog';
        END
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[Enrollment];
            PRINT '✓ Đã xóa dữ liệu trong Enrollment';
        END
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            DELETE FROM [dbo].[UserRole];
            PRINT '✓ Đã xóa dữ liệu trong UserRole';
        END
        
        -- Xóa các foreign key constraints
        PRINT 'Đang xóa foreign key constraints...';
        
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_ActivityLog_User')
        BEGIN
            ALTER TABLE [dbo].[ActivityLog] DROP CONSTRAINT [FK_ActivityLog_User];
            PRINT '✓ Đã xóa FK_ActivityLog_User';
        END
        
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Enrollment_User')
        BEGIN
            ALTER TABLE [dbo].[Enrollment] DROP CONSTRAINT [FK_Enrollment_User];
            PRINT '✓ Đã xóa FK_Enrollment_User';
        END
        
        IF EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_UserRole_User')
        BEGIN
            ALTER TABLE [dbo].[UserRole] DROP CONSTRAINT [FK_UserRole_User];
            PRINT '✓ Đã xóa FK_UserRole_User';
        END
        
        -- Xóa constraints
        IF EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.User') AND name = 'PK_User')
        BEGIN
            ALTER TABLE [dbo].[User] DROP CONSTRAINT [PK_User];
            PRINT '✓ Đã xóa PK_User';
        END
        
        IF EXISTS (SELECT * FROM sys.key_constraints WHERE parent_object_id = OBJECT_ID('dbo.User') AND name = 'UQ_User_Username')
        BEGIN
            ALTER TABLE [dbo].[User] DROP CONSTRAINT [UQ_User_Username];
            PRINT '✓ Đã xóa UQ_User_Username';
        END
        
        -- Xóa bảng User cũ
        DROP TABLE [dbo].[User];
        PRINT '✓ Đã xóa bảng User cũ';
        
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
        PRINT '✓ Đã tạo lại bảng User với uid IDENTITY(1,1)';
        
        -- Tạo lại foreign key constraints
        PRINT 'Đang tạo lại foreign key constraints...';
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'ActivityLog' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[ActivityLog] WITH NOCHECK ADD CONSTRAINT [FK_ActivityLog_User] 
            FOREIGN KEY([user_id]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[ActivityLog] CHECK CONSTRAINT [FK_ActivityLog_User];
            PRINT '✓ Đã tạo lại FK_ActivityLog_User';
        END
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[Enrollment] WITH NOCHECK ADD CONSTRAINT [FK_Enrollment_User] 
            FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[Enrollment] CHECK CONSTRAINT [FK_Enrollment_User];
            PRINT '✓ Đã tạo lại FK_Enrollment_User';
        END
        
        IF EXISTS (SELECT * FROM sys.tables WHERE name = 'UserRole' AND schema_id = SCHEMA_ID('dbo'))
        BEGIN
            ALTER TABLE [dbo].[UserRole] WITH NOCHECK ADD CONSTRAINT [FK_UserRole_User] 
            FOREIGN KEY([uid]) REFERENCES [dbo].[User] ([uid]);
            ALTER TABLE [dbo].[UserRole] CHECK CONSTRAINT [FK_UserRole_User];
            PRINT '✓ Đã tạo lại FK_UserRole_User';
        END
        
        PRINT '✓ Hoàn thành bước 1: Bảng User đã được sửa với uid IDENTITY(1,1)';
    END
    ELSE
    BEGIN
        PRINT '✓ Bảng User đã có uid IDENTITY(1,1) - không cần sửa';
    END
END
ELSE
BEGIN
    PRINT '⚠️  LỖI: Bảng User không tồn tại! Vui lòng tạo bảng User trước.';
END

PRINT '';
PRINT '========================================';
PRINT '';

-- ============================================================
-- BƯỚC 2: TẠO USER ADMIN MẶC ĐỊNH
-- ============================================================

PRINT 'BƯỚC 2: Tạo user admin mặc định...';
PRINT '';

IF NOT EXISTS (SELECT * FROM [User] WHERE username = 'admin')
BEGIN
    PRINT 'Đang tạo user admin...';
    
    -- Tạo Employee cho admin (nếu chưa có)
    DECLARE @eid INT;
    DECLARE @employee_name NVARCHAR(255) = 'Administrator';
    
    SELECT TOP 1 @eid = eid FROM Employee;
    
    IF @eid IS NULL
    BEGIN
        PRINT 'Không có Employee nào, đang tạo Employee mới...';
        
        -- Kiểm tra và tạo Division nếu chưa có
        DECLARE @did INT;
        SELECT TOP 1 @did = did FROM Division;
        
        IF @did IS NULL
        BEGIN
            PRINT 'Đang tạo Division mặc định...';
            IF NOT EXISTS (SELECT * FROM Division WHERE did = 1)
            BEGIN
                INSERT INTO Division (did, dname) VALUES (1, 'Default Division');
            END
            SET @did = 1;
            PRINT '✓ Đã tạo Division mặc định với DID: 1';
        END
        
        -- Tạo Employee mới
        DECLARE @maxEid INT;
        SELECT @maxEid = ISNULL(MAX(eid), 0) FROM Employee;
        INSERT INTO Employee (eid, ename, did, supervisorid)
        VALUES (@maxEid + 1, @employee_name, @did, NULL);
        SET @eid = @maxEid + 1;
        PRINT '✓ Đã tạo Employee với EID: ' + CAST(@eid AS VARCHAR(10));
    END
    ELSE
    BEGIN
        PRINT 'Sử dụng Employee hiện có với EID: ' + CAST(@eid AS VARCHAR(10));
    END
    
    -- Tạo user admin
    DECLARE @uid INT;
    DECLARE @username NVARCHAR(100) = 'admin';
    DECLARE @password NVARCHAR(255) = 'admin123';
    DECLARE @displayname NVARCHAR(255) = 'Administrator';
    
    DECLARE @OutputTable TABLE (uid INT);
    
    INSERT INTO [User] (username, [password], displayname)
    OUTPUT INSERTED.uid INTO @OutputTable
    VALUES (@username, @password, @displayname);
    
    SELECT @uid = uid FROM @OutputTable;
    
    PRINT '✓ Đã tạo user admin với UID: ' + CAST(@uid AS VARCHAR(10));
    
    -- Tạo Enrollment cho user admin
    IF NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @uid)
    BEGIN
        INSERT INTO Enrollment (uid, eid, active)
        VALUES (@uid, @eid, 1);
        PRINT '✓ Đã tạo Enrollment cho user admin với Employee ID: ' + CAST(@eid AS VARCHAR(10));
    END
    ELSE
    BEGIN
        UPDATE Enrollment SET eid = @eid, active = 1 WHERE uid = @uid;
        PRINT '✓ Đã cập nhật Enrollment cho user admin';
    END
    
    PRINT '';
    PRINT '✓ Hoàn thành bước 2: User admin đã được tạo';
    PRINT '  Username: admin';
    PRINT '  Password: admin123';
END
ELSE
BEGIN
    PRINT '✓ User admin đã tồn tại!';
    DECLARE @existing_uid INT;
    SELECT @existing_uid = uid FROM [User] WHERE username = 'admin';
    
    -- Đảm bảo có Enrollment
    IF NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @existing_uid AND active = 1)
    BEGIN
        DECLARE @existing_eid INT;
        SELECT TOP 1 @existing_eid = eid FROM Employee;
        
        IF @existing_eid IS NOT NULL
        BEGIN
            MERGE Enrollment AS target
            USING (SELECT @existing_uid AS uid, @existing_eid AS eid) AS src
            ON target.uid = src.uid
            WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
            WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);
            PRINT '✓ Đã tạo/cập nhật Enrollment cho user admin';
        END
    END
END

PRINT '';
PRINT '========================================';
PRINT '';

-- ============================================================
-- BƯỚC 3: TẠO CÁC NHÂN VIÊN MẪU
-- ============================================================

PRINT 'BƯỚC 3: Tạo các nhân viên mẫu...';
PRINT '';

-- Tạo Division nếu chưa có
IF NOT EXISTS (SELECT * FROM Division WHERE did = 1)
BEGIN
    INSERT INTO Division (did, dname) VALUES (1, 'Phòng Nhân Sự');
    PRINT '✓ Đã tạo Division: Phòng Nhân Sự (DID: 1)';
END

IF NOT EXISTS (SELECT * FROM Division WHERE did = 2)
BEGIN
    INSERT INTO Division (did, dname) VALUES (2, 'Phòng Kỹ Thuật');
    PRINT '✓ Đã tạo Division: Phòng Kỹ Thuật (DID: 2)';
END

IF NOT EXISTS (SELECT * FROM Division WHERE did = 3)
BEGIN
    INSERT INTO Division (did, dname) VALUES (3, 'Phòng Kinh Doanh');
    PRINT '✓ Đã tạo Division: Phòng Kinh Doanh (DID: 3)';
END

IF NOT EXISTS (SELECT * FROM Division WHERE did = 4)
BEGIN
    INSERT INTO Division (did, dname) VALUES (4, 'Phòng Hành Chính');
    PRINT '✓ Đã tạo Division: Phòng Hành Chính (DID: 4)';
END

PRINT '';

-- Lấy EID cao nhất hiện có
DECLARE @maxEidEmployee INT;
SELECT @maxEidEmployee = ISNULL(MAX(eid), 0) FROM Employee;

-- Tạo các nhân viên mẫu
DECLARE @newEid INT;
DECLARE @newEname NVARCHAR(255);
DECLARE @newDid INT;

-- Nhân viên 1: Nguyễn Văn A
SET @newEid = @maxEidEmployee + 1;
SET @newEname = 'Nguyễn Văn A';
SET @newDid = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 2: Trần Thị B
SET @newEid = @maxEidEmployee + 2;
SET @newEname = 'Trần Thị B';
SET @newDid = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 3: Lê Văn C
SET @newEid = @maxEidEmployee + 3;
SET @newEname = 'Lê Văn C';
SET @newDid = 3;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 4: Phạm Thị D
SET @newEid = @maxEidEmployee + 4;
SET @newEname = 'Phạm Thị D';
SET @newDid = 4;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 5: Hoàng Văn E
SET @newEid = @maxEidEmployee + 5;
SET @newEname = 'Hoàng Văn E';
SET @newDid = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 6: Võ Thị F
SET @newEid = @maxEidEmployee + 6;
SET @newEname = 'Võ Thị F';
SET @newDid = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 7: Đặng Văn G
SET @newEid = @maxEidEmployee + 7;
SET @newEname = 'Đặng Văn G';
SET @newDid = 3;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 8: Bùi Thị H
SET @newEid = @maxEidEmployee + 8;
SET @newEname = 'Bùi Thị H';
SET @newDid = 4;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 9: Ngô Văn I
SET @newEid = @maxEidEmployee + 9;
SET @newEname = 'Ngô Văn I';
SET @newDid = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

-- Nhân viên 10: Dương Thị K
SET @newEid = @maxEidEmployee + 10;
SET @newEname = 'Dương Thị K';
SET @newDid = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @newEid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid) VALUES (@newEid, @newEname, @newDid, NULL);
    PRINT '✓ Đã tạo Employee: ' + @newEname + ' (EID: ' + CAST(@newEid AS VARCHAR(10)) + ')';
END

PRINT '';
PRINT '✓ Hoàn thành bước 3: Đã tạo các nhân viên mẫu';
PRINT '';
PRINT '========================================';
PRINT '';

-- ============================================================
-- BƯỚC 4: THIẾT LẬP QUYỀN ADMIN
-- ============================================================

PRINT 'BƯỚC 4: Thiết lập quyền Admin...';
PRINT '';

-- Tạo Feature cho chức năng tạo user
DECLARE @featureId INT;
SELECT @featureId = ISNULL(MAX(fid), 0) + 1 FROM Feature;

IF NOT EXISTS (SELECT * FROM Feature WHERE url = '/admin/create-user')
BEGIN
    INSERT INTO Feature (fid, url) VALUES (@featureId, '/admin/create-user');
    PRINT '✓ Đã tạo Feature: /admin/create-user (FID: ' + CAST(@featureId AS VARCHAR(10)) + ')';
END
ELSE
BEGIN
    SELECT @featureId = fid FROM Feature WHERE url = '/admin/create-user';
    PRINT '✓ Feature /admin/create-user đã tồn tại (FID: ' + CAST(@featureId AS VARCHAR(10)) + ')';
END

PRINT '';

-- Tạo Role Admin
DECLARE @roleId INT;
SELECT @roleId = ISNULL(MAX(rid), 0) + 1 FROM Role;

IF NOT EXISTS (SELECT * FROM Role WHERE rname = 'Admin')
BEGIN
    INSERT INTO Role (rid, rname) VALUES (@roleId, 'Admin');
    PRINT '✓ Đã tạo Role: Admin (RID: ' + CAST(@roleId AS VARCHAR(10)) + ')';
END
ELSE
BEGIN
    SELECT @roleId = rid FROM Role WHERE rname = 'Admin';
    PRINT '✓ Role Admin đã tồn tại (RID: ' + CAST(@roleId AS VARCHAR(10)) + ')';
END

PRINT '';

-- Gán Feature cho Role Admin
IF NOT EXISTS (SELECT * FROM RoleFeature WHERE rid = @roleId AND fid = @featureId)
BEGIN
    INSERT INTO RoleFeature (rid, fid) VALUES (@roleId, @featureId);
    PRINT '✓ Đã gán Feature /admin/create-user cho Role Admin';
END
ELSE
BEGIN
    PRINT '✓ Feature đã được gán cho Role Admin';
END

PRINT '';

-- Gán Role Admin cho user admin
DECLARE @adminUidFinal INT;
SELECT @adminUidFinal = uid FROM [User] WHERE username = 'admin';

IF @adminUidFinal IS NOT NULL
BEGIN
    IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @adminUidFinal AND rid = @roleId)
    BEGIN
        INSERT INTO UserRole (uid, rid) VALUES (@adminUidFinal, @roleId);
        PRINT '✓ Đã gán Role Admin cho user admin (UID: ' + CAST(@adminUidFinal AS VARCHAR(10)) + ')';
    END
    ELSE
    BEGIN
        PRINT '✓ User admin đã có Role Admin';
    END
END
ELSE
BEGIN
    PRINT '⚠️  Cảnh báo: Không tìm thấy user admin!';
END

PRINT '';
PRINT '✓ Hoàn thành bước 4: Quyền Admin đã được thiết lập';
PRINT '';
PRINT '========================================';
PRINT '';

-- ============================================================
-- KẾT THÚC
-- ============================================================

PRINT '========================================';
PRINT '✓ HOÀN TẤT! DATABASE ĐÃ ĐƯỢC SỬA XONG';
PRINT '========================================';
PRINT '';
PRINT 'Thông tin đăng nhập:';
PRINT '  Username: admin';
PRINT '  Password: admin123';
PRINT '';
PRINT '⚠️  QUAN TRỌNG: Vui lòng đăng nhập và đổi mật khẩu ngay!';
PRINT '';
PRINT 'Các chức năng đã sẵn sàng:';
PRINT '  ✓ Đăng nhập/Đăng xuất';
PRINT '  ✓ Tạo đơn xin nghỉ';
PRINT '  ✓ Xem danh sách đơn';
PRINT '  ✓ Duyệt/Từ chối đơn';
PRINT '  ✓ Chấm công';
PRINT '  ✓ Thống kê';
PRINT '  ✓ Tạo user mới (chỉ admin)';
PRINT '';
PRINT '========================================';
GO

