-- ============================================
-- Script KIỂM TRA Database đã tạo đúng chưa
-- Chạy script này sau khi chạy create_complete_database_schema.sql
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'KIỂM TRA DATABASE SCHEMA';
PRINT '========================================';
PRINT '';

-- ============================================
-- KIỂM TRA CÁC BẢNG
-- ============================================

PRINT '1. KIỂM TRA CÁC BẢNG:';
PRINT '';

DECLARE @missingTables TABLE (table_name NVARCHAR(255));
DECLARE @requiredTables TABLE (table_name NVARCHAR(255));
INSERT INTO @requiredTables VALUES 
('Department'), ('Employee'), ('User'), ('Enrollment'),
('Role'), ('Feature'), ('UserRole'), ('RoleFeature'),
('LeaveType'), ('RequestForLeave'), ('RequestForLeaveHistory'),
('Attendance'), ('ActivityLog');

INSERT INTO @missingTables
SELECT rt.table_name 
FROM @requiredTables rt
WHERE NOT EXISTS (
    SELECT 1 FROM sys.tables t 
    WHERE t.name = rt.table_name
);

IF EXISTS (SELECT * FROM @missingTables)
BEGIN
    PRINT '✗ THIẾU CÁC BẢNG SAU:';
    SELECT '   - ' + table_name AS 'Missing Table' FROM @missingTables;
END
ELSE
BEGIN
    PRINT '✓ Tất cả 13 bảng đã được tạo';
END

-- ============================================
-- KIỂM TRA CÁC CỘT QUAN TRỌNG
-- ============================================

PRINT '';
PRINT '2. KIỂM TRA CÁC CỘT QUAN TRỌNG:';
PRINT '';

-- Kiểm tra Employee có supervisorid
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'supervisorid')
    PRINT '✓ Employee.supervisorid - OK';
ELSE
    PRINT '✗ Employee thiếu cột supervisorid (đệ quy)';

-- Kiểm tra Employee có did
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'did')
    PRINT '✓ Employee.did - OK';
ELSE
    PRINT '✗ Employee thiếu cột did (Department)';

-- Kiểm tra RequestForLeave có leavetype_id
IF EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('RequestForLeave') AND name = 'leavetype_id')
    PRINT '✓ RequestForLeave.leavetype_id - OK';
ELSE
    PRINT '✗ RequestForLeave thiếu cột leavetype_id';

-- ============================================
-- KIỂM TRA FOREIGN KEYS
-- ============================================

PRINT '';
PRINT '3. KIỂM TRA FOREIGN KEYS:';
PRINT '';

DECLARE @missingFKs TABLE (fk_name NVARCHAR(255));
DECLARE @requiredFKs TABLE (fk_name NVARCHAR(255));
INSERT INTO @requiredFKs VALUES 
('FK_Employee_Supervisor'),
('FK_Employee_Department'),
('FK_Enrollment_User'),
('FK_Enrollment_Employee'),
('FK_UserRole_User'),
('FK_UserRole_Role'),
('FK_RoleFeature_Role'),
('FK_RoleFeature_Feature'),
('FK_RequestForLeave_CreatedBy'),
('FK_RequestForLeave_ProcessedBy'),
('FK_RequestForLeave_LeaveType'),
('FK_RequestForLeaveHistory_Request'),
('FK_RequestForLeaveHistory_ProcessedBy'),
('FK_Attendance_Employee'),
('FK_Attendance_RequestForLeave'),
('FK_ActivityLog_User'),
('FK_ActivityLog_Employee');

INSERT INTO @missingFKs
SELECT rf.fk_name 
FROM @requiredFKs rf
WHERE NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys fk 
    WHERE fk.name = rf.fk_name
);

IF EXISTS (SELECT * FROM @missingFKs)
BEGIN
    PRINT '✗ THIẾU CÁC FOREIGN KEYS SAU:';
    SELECT '   - ' + fk_name AS 'Missing FK' FROM @missingFKs;
END
ELSE
BEGIN
    PRINT '✓ Tất cả Foreign Keys đã được tạo';
END

-- ============================================
-- KIỂM TRA INDEXES
-- ============================================

PRINT '';
PRINT '4. KIỂM TRA INDEXES:';
PRINT '';

DECLARE @idxCount INT = 0;
SELECT @idxCount = COUNT(*) 
FROM sys.indexes 
WHERE name LIKE 'IX_%' 
AND is_primary_key = 0 
AND is_unique_constraint = 0;

PRINT '✓ Tìm thấy ' + CAST(@idxCount AS VARCHAR) + ' Indexes';

-- Kiểm tra index quan trọng cho đệ quy
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Employee_Supervisor')
    PRINT '✓ IX_Employee_Supervisor (đệ quy) - OK';
ELSE
    PRINT '⚠️ Thiếu IX_Employee_Supervisor (ảnh hưởng hiệu suất đệ quy)';

-- ============================================
-- KIỂM TRA VIEWS
-- ============================================

PRINT '';
PRINT '5. KIỂM TRA VIEWS:';
PRINT '';

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_ActivityLog')
    PRINT '✓ vw_ActivityLog - OK';
ELSE
    PRINT '✗ Thiếu view vw_ActivityLog';

IF EXISTS (SELECT * FROM sys.views WHERE name = 'vw_Attendance')
    PRINT '✓ vw_Attendance - OK';
ELSE
    PRINT '✗ Thiếu view vw_Attendance';

-- ============================================
-- KIỂM TRA DỮ LIỆU MẪU
-- ============================================

PRINT '';
PRINT '6. KIỂM TRA DỮ LIỆU MẪU:';
PRINT '';

DECLARE @leaveTypeCount INT = (SELECT COUNT(*) FROM LeaveType);
IF @leaveTypeCount > 0
    PRINT '✓ LeaveType có ' + CAST(@leaveTypeCount AS VARCHAR) + ' bản ghi';
ELSE
    PRINT '⚠️ LeaveType chưa có dữ liệu (cần chạy lại phần INSERT)';

DECLARE @roleCount INT = (SELECT COUNT(*) FROM Role);
IF @roleCount >= 3
    PRINT '✓ Role có ' + CAST(@roleCount AS VARCHAR) + ' bản ghi (Admin, Employee, Manager)';
ELSE
    PRINT '⚠️ Role chưa đủ dữ liệu (cần ít nhất 3: Admin, Employee, Manager)';

DECLARE @featureCount INT = (SELECT COUNT(*) FROM Feature);
IF @featureCount >= 14
    PRINT '✓ Feature có ' + CAST(@featureCount AS VARCHAR) + ' bản ghi (URL patterns)';
ELSE
    PRINT '⚠️ Feature chưa đủ dữ liệu (cần ít nhất 14 URL patterns)';

DECLARE @roleFeatureCount INT = (SELECT COUNT(*) FROM RoleFeature);
IF @roleFeatureCount > 0
    PRINT '✓ RoleFeature có ' + CAST(@roleFeatureCount AS VARCHAR) + ' bản ghi (quyền đã gán)';
ELSE
    PRINT '⚠️ RoleFeature chưa có dữ liệu (chưa gán quyền cho Role)';

-- ============================================
-- KIỂM TRA ĐỆ QUY (TEST QUERY)
-- ============================================

PRINT '';
PRINT '7. KIỂM TRA ĐỆ QUY SQL:';
PRINT '';

DECLARE @testEmpID INT;
SELECT TOP 1 @testEmpID = eid FROM Employee WHERE supervisorid IS NULL;

IF @testEmpID IS NOT NULL
BEGIN
    BEGIN TRY
        DECLARE @recursiveCount INT;
        WITH Org AS (
            SELECT eid, ename, supervisorid, 0 as lvl 
            FROM Employee 
            WHERE eid = @testEmpID
            
            UNION ALL
            
            SELECT c.eid, c.ename, c.supervisorid, o.lvl + 1 as lvl 
            FROM Employee c 
            JOIN Org o ON c.supervisorid = o.eid
        )
        SELECT @recursiveCount = COUNT(*) FROM Org;
        
        IF @recursiveCount > 0
            PRINT '✓ Đệ quy SQL hoạt động đúng (' + CAST(@recursiveCount AS VARCHAR) + ' nhân viên trong cây)';
        ELSE
            PRINT '⚠️ Đệ quy SQL hoạt động nhưng không có nhân viên con';
    END TRY
    BEGIN CATCH
        PRINT '✗ LỖI khi test đệ quy SQL: ' + ERROR_MESSAGE();
    END CATCH
END
ELSE
    PRINT '⚠️ Không có Employee để test đệ quy (cần tạo Employee với supervisorid)';

-- ============================================
-- KIỂM TRA PHÂN QUYỀN
-- ============================================

PRINT '';
PRINT '8. KIỂM TRA PHÂN QUYỀN:';
PRINT '';

DECLARE @adminRoleID INT = (SELECT rid FROM Role WHERE rname = N'Admin');
IF @adminRoleID IS NOT NULL
BEGIN
    DECLARE @adminFeatureCount INT = (SELECT COUNT(*) FROM RoleFeature WHERE rid = @adminRoleID);
    IF @adminFeatureCount >= 10
        PRINT '✓ Admin có ' + CAST(@adminFeatureCount AS VARCHAR) + ' quyền (đủ)';
    ELSE
        PRINT '⚠️ Admin chỉ có ' + CAST(@adminFeatureCount AS VARCHAR) + ' quyền (cần ít nhất 10)';
END
ELSE
    PRINT '✗ Không tìm thấy Role Admin';

DECLARE @employeeRoleID INT = (SELECT rid FROM Role WHERE rname = N'Employee');
IF @employeeRoleID IS NOT NULL
BEGIN
    DECLARE @empFeatureCount INT = (SELECT COUNT(*) FROM RoleFeature WHERE rid = @employeeRoleID);
    IF @empFeatureCount >= 5
        PRINT '✓ Employee có ' + CAST(@empFeatureCount AS VARCHAR) + ' quyền (đủ)';
    ELSE
        PRINT '⚠️ Employee chỉ có ' + CAST(@empFeatureCount AS VARCHAR) + ' quyền (cần ít nhất 5)';
END
ELSE
    PRINT '✗ Không tìm thấy Role Employee';

-- ============================================
-- TỔNG KẾT
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'TỔNG KẾT:';
PRINT '========================================';

DECLARE @errorCount INT = 0;
IF EXISTS (SELECT * FROM @missingTables) SET @errorCount = @errorCount + 1;
IF EXISTS (SELECT * FROM @missingFKs) SET @errorCount = @errorCount + 1;
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID('Employee') AND name = 'supervisorid')
    SET @errorCount = @errorCount + 1;

IF @errorCount = 0
BEGIN
    PRINT '✓ DATABASE ĐÃ ĐƯỢC TẠO THÀNH CÔNG!';
    PRINT '';
    PRINT 'Bạn có thể:';
    PRINT '1. Chạy create_test_data.sql để thêm dữ liệu test';
    PRINT '2. Bắt đầu sử dụng ứng dụng';
END
ELSE
BEGIN
    PRINT '⚠️ CÓ ' + CAST(@errorCount AS VARCHAR) + ' VẤN ĐỀ CẦN SỬA';
    PRINT '';
    PRINT 'Vui lòng:';
    PRINT '1. Kiểm tra lại các lỗi phía trên';
    PRINT '2. Chạy lại create_complete_database_schema.sql';
END

PRINT '';
GO


