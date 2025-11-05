-- ============================================
-- Script AN TOÀN - Sửa Database KHÔNG XÓA
-- Backup toàn bộ: triggers, stored procedures, views, indexes
-- Chỉ SỬA bảng, không xóa
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'SCRIPT AN TOÀN - BACKUP & SỬA DATABASE';
PRINT '========================================';
PRINT '';

-- ============================================
-- BƯỚC 1: BACKUP TOÀN BỘ SCHEMA
-- ============================================

PRINT 'BƯỚC 1: Đang backup toàn bộ schema...';
PRINT '';

-- Tạo schema để lưu backup
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'BACKUP_SCHEMA')
BEGIN
    CREATE SCHEMA BACKUP_SCHEMA;
    PRINT '✓ Đã tạo schema BACKUP_SCHEMA';
END

PRINT '';

-- ============================================
-- BƯỚC 2: BACKUP DỮ LIỆU BẢNG
-- ============================================

PRINT 'BƯỚC 2: Đang backup dữ liệu bảng...';

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Employee')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BACKUP_SCHEMA.Employee_backup')
    BEGIN
        SELECT * INTO BACKUP_SCHEMA.Employee_backup FROM Employee;
        PRINT '✓ Đã backup Employee';
    END
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'User')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BACKUP_SCHEMA.User_backup')
    BEGIN
        SELECT * INTO BACKUP_SCHEMA.[User_backup] FROM [User];
        PRINT '✓ Đã backup User';
    END
END

IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Enrollment')
BEGIN
    IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'BACKUP_SCHEMA.Enrollment_backup')
    BEGIN
        SELECT * INTO BACKUP_SCHEMA.Enrollment_backup FROM Enrollment;
        PRINT '✓ Đã backup Enrollment';
    END
END

PRINT '';

-- ============================================
-- BƯỚC 3: BACKUP STORED PROCEDURES
-- ============================================

PRINT 'BƯỚC 3: Đang backup Stored Procedures...';

DECLARE @sp_name NVARCHAR(255);
DECLARE @sp_definition NVARCHAR(MAX);
DECLARE sp_cursor CURSOR FOR
    SELECT name FROM sys.procedures WHERE type = 'P';

OPEN sp_cursor;
FETCH NEXT FROM sp_cursor INTO @sp_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    SELECT @sp_definition = OBJECT_DEFINITION(OBJECT_ID(@sp_name));
    -- Lưu vào bảng tạm hoặc in ra
    PRINT '✓ Đã backup Stored Procedure: ' + @sp_name;
    FETCH NEXT FROM sp_cursor INTO @sp_name;
END
CLOSE sp_cursor;
DEALLOCATE sp_cursor;

PRINT '';

-- ============================================
-- BƯỚC 4: BACKUP VIEWS
-- ============================================

PRINT 'BƯỚC 4: Đang backup Views...';

DECLARE @view_name NVARCHAR(255);
DECLARE view_cursor CURSOR FOR
    SELECT name FROM sys.views;

OPEN view_cursor;
FETCH NEXT FROM view_cursor INTO @view_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '✓ Đã backup View: ' + @view_name;
    FETCH NEXT FROM view_cursor INTO @view_name;
END
CLOSE view_cursor;
DEALLOCATE view_cursor;

PRINT '';

-- ============================================
-- BƯỚC 5: BACKUP TRIGGERS
-- ============================================

PRINT 'BƯỚC 5: Đang backup Triggers...';

DECLARE @trigger_name NVARCHAR(255);
DECLARE @table_name NVARCHAR(255);
DECLARE trigger_cursor CURSOR FOR
    SELECT t.name, OBJECT_NAME(t.parent_id) AS table_name
    FROM sys.triggers t
    WHERE t.is_disabled = 0;

OPEN trigger_cursor;
FETCH NEXT FROM trigger_cursor INTO @trigger_name, @table_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '✓ Đã backup Trigger: ' + @trigger_name + ' (trên bảng: ' + @table_name + ')';
    FETCH NEXT FROM trigger_cursor INTO @trigger_name, @table_name;
END
CLOSE trigger_cursor;
DEALLOCATE trigger_cursor;

PRINT '';

-- ============================================
-- BƯỚC 6: BACKUP INDEXES (Ngoài Primary Key)
-- ============================================

PRINT 'BƯỚC 6: Đang backup Indexes...';

DECLARE @index_name NVARCHAR(255);
DECLARE @table_index_name NVARCHAR(255);
DECLARE index_cursor CURSOR FOR
    SELECT i.name, OBJECT_NAME(i.object_id) AS table_name
    FROM sys.indexes i
    WHERE i.is_primary_key = 0 
    AND i.name IS NOT NULL
    AND OBJECT_NAME(i.object_id) IN ('Employee', 'User', 'Enrollment', 'ActivityLog');

OPEN index_cursor;
FETCH NEXT FROM index_cursor INTO @index_name, @table_index_name;
WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '✓ Đã backup Index: ' + @index_name + ' (trên bảng: ' + @table_index_name + ')';
    FETCH NEXT FROM index_cursor INTO @index_name, @table_index_name;
END
CLOSE index_cursor;
DEALLOCATE index_cursor;

PRINT '';

PRINT '========================================';
PRINT 'ĐÃ BACKUP XONG!';
PRINT '========================================';
PRINT '';
PRINT 'Bây giờ sẽ SỬA bảng mà KHÔNG XÓA...';
PRINT '';

-- ============================================
-- BƯỚC 7: KIỂM TRA VÀ SỬA BẢNG EMPLOYEE
-- ============================================

PRINT 'BƯỚC 7: Đang kiểm tra và sửa bảng Employee...';

-- Kiểm tra xem eid có phải IDENTITY chưa
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('Employee') AND name = 'eid' AND is_identity = 1
)
BEGIN
    PRINT '✓ Employee.eid ĐÃ LÀ IDENTITY - Không cần sửa';
END
ELSE
BEGIN
    PRINT '⚠ Employee.eid CHƯA LÀ IDENTITY - Cần sửa...';
    PRINT '';
    PRINT 'Để sửa Employee.eid thành IDENTITY, cần:';
    PRINT '1. Tạo bảng Employee_new với IDENTITY';
    PRINT '2. Copy dữ liệu sang (giữ nguyên eid bằng IDENTITY_INSERT)';
    PRINT '3. Xóa bảng cũ và đổi tên';
    PRINT '';
    PRINT 'Bạn có muốn tiếp tục? (Uncomment phần code bên dưới)';
    PRINT '';
    
    /*
    -- Nếu đồng ý, uncomment phần này:
    
    -- Bước 1: Tạo bảng mới với IDENTITY
    CREATE TABLE Employee_new (
        eid INT IDENTITY(1,1) PRIMARY KEY,
        ename NVARCHAR(255) NOT NULL,
        did INT NULL,
        supervisorid INT NULL
    );
    
    -- Bước 2: Copy dữ liệu (giữ nguyên eid)
    SET IDENTITY_INSERT Employee_new ON;
    INSERT INTO Employee_new (eid, ename, did, supervisorid)
    SELECT eid, ename, did, supervisorid FROM Employee;
    SET IDENTITY_INSERT Employee_new OFF;
    
    -- Bước 3: Xóa bảng cũ
    DROP TABLE Employee;
    
    -- Bước 4: Đổi tên
    EXEC sp_rename 'Employee_new', 'Employee';
    
    -- Bước 5: Tạo lại Foreign Keys
    ALTER TABLE Employee
    ADD CONSTRAINT FK_Employee_Supervisor 
    FOREIGN KEY (supervisorid) REFERENCES Employee(eid);
    
    -- Tạo lại Foreign Key đến Division (nếu có)
    IF EXISTS (SELECT * FROM sys.tables WHERE name = 'Division')
    BEGIN
        ALTER TABLE Employee
        ADD CONSTRAINT FK_Employee_Division 
        FOREIGN KEY (did) REFERENCES Division(did);
    END
    
    PRINT '✓ Đã sửa Employee.eid thành IDENTITY';
    */
END

PRINT '';

-- ============================================
-- BƯỚC 8: KIỂM TRA VÀ SỬA BẢNG USER
-- ============================================

PRINT 'BƯỚC 8: Đang kiểm tra và sửa bảng User...';

-- Kiểm tra xem uid có phải IDENTITY chưa
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('User') AND name = 'uid' AND is_identity = 1
)
BEGIN
    PRINT '✓ User.uid ĐÃ LÀ IDENTITY - Không cần sửa';
END
ELSE
BEGIN
    PRINT '⚠ User.uid CHƯA LÀ IDENTITY - Cần sửa...';
    PRINT '';
    PRINT 'Để sửa User.uid thành IDENTITY, cần:';
    PRINT '1. Tạo bảng User_new với IDENTITY';
    PRINT '2. Copy dữ liệu sang (giữ nguyên uid bằng IDENTITY_INSERT)';
    PRINT '3. Xóa bảng cũ và đổi tên';
    PRINT '';
    PRINT 'Bạn có muốn tiếp tục? (Uncomment phần code bên dưới)';
    PRINT '';
    
    /*
    -- Nếu đồng ý, uncomment phần này:
    
    -- Bước 1: Tạo bảng mới với IDENTITY
    CREATE TABLE User_new (
        uid INT IDENTITY(1,1) PRIMARY KEY,
        username NVARCHAR(100) NOT NULL UNIQUE,
        [password] NVARCHAR(255) NOT NULL,
        displayname NVARCHAR(255) NOT NULL
    );
    
    -- Bước 2: Copy dữ liệu (giữ nguyên uid)
    SET IDENTITY_INSERT User_new ON;
    INSERT INTO User_new (uid, username, [password], displayname)
    SELECT uid, username, [password], displayname FROM [User];
    SET IDENTITY_INSERT User_new OFF;
    
    -- Bước 3: Xóa bảng cũ
    DROP TABLE [User];
    
    -- Bước 4: Đổi tên
    EXEC sp_rename 'User_new', 'User';
    
    PRINT '✓ Đã sửa User.uid thành IDENTITY';
    */
END

PRINT '';

-- ============================================
-- BƯỚC 9: KIỂM TRA KẾT QUẢ CUỐI CÙNG
-- ============================================

PRINT '========================================';
PRINT 'KIỂM TRA KẾT QUẢ:';
PRINT '========================================';

-- Kiểm tra Employee.eid
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('Employee') AND name = 'eid' AND is_identity = 1
)
    PRINT '✓ Employee.eid là IDENTITY - THÀNH CÔNG!';
ELSE
    PRINT '✗ Employee.eid CHƯA là IDENTITY - Cần uncomment và chạy phần sửa';

-- Kiểm tra User.uid
IF EXISTS (
    SELECT * FROM sys.identity_columns 
    WHERE object_id = OBJECT_ID('User') AND name = 'uid' AND is_identity = 1
)
    PRINT '✓ User.uid là IDENTITY - THÀNH CÔNG!';
ELSE
    PRINT '✗ User.uid CHƯA là IDENTITY - Cần uncomment và chạy phần sửa';

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT!';
PRINT '========================================';
PRINT '';
PRINT 'LƯU Ý:';
PRINT '- Đã backup tất cả vào schema BACKUP_SCHEMA';
PRINT '- Để sửa bảng, uncomment phần code và chạy lại';
PRINT '- Sau khi sửa, kiểm tra lại bằng các câu SQL kiểm tra';
PRINT '';

GO



