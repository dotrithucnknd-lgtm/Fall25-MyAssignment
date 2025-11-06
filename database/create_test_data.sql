-- ============================================
-- Script tạo DỮ LIỆU TEST
-- Để test đầy đủ tất cả các chức năng
-- ============================================
-- Chạy script này SAU KHI chạy create_complete_database_schema.sql
-- ============================================

USE FALL25_Assignment;
GO

PRINT '========================================';
PRINT 'BẮT ĐẦU TẠO DỮ LIỆU TEST';
PRINT '========================================';
PRINT '';

-- ============================================
-- BƯỚC 1: TẠO DEPARTMENT
-- ============================================

IF NOT EXISTS (SELECT * FROM Department WHERE did = 1)
BEGIN
    INSERT INTO Department (dname) VALUES (N'Phòng Nhân Sự');
    INSERT INTO Department (dname) VALUES (N'Phòng Kỹ Thuật');
    INSERT INTO Department (dname) VALUES (N'Phòng Kinh Doanh');
    PRINT '✓ Đã tạo 3 Department';
END
ELSE
    PRINT 'Department đã có dữ liệu';

-- ============================================
-- BƯỚC 2: TẠO EMPLOYEE VỚI HIERARCHY (ĐỆ QUY)
-- ============================================

-- Xóa dữ liệu cũ nếu có (để test lại)
-- DELETE FROM Employee WHERE eid > 0;

-- Tạo cấp quản lý (Manager)
DECLARE @Manager1 INT, @Manager2 INT, @Manager3 INT;

IF NOT EXISTS (SELECT * FROM Employee WHERE eid = 1)
BEGIN
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Nguyễn Văn A - Giám đốc', 1, NULL);
    SET @Manager1 = SCOPE_IDENTITY();
    
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Trần Thị B - Trưởng phòng', 2, @Manager1);
    SET @Manager2 = SCOPE_IDENTITY();
    
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Lê Văn C - Trưởng phòng', 3, @Manager1);
    SET @Manager3 = SCOPE_IDENTITY();
    
    -- Tạo nhân viên (có supervisor)
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Phạm Thị D - Nhân viên', 2, @Manager2);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Hoàng Văn E - Nhân viên', 2, @Manager2);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Võ Thị F - Nhân viên', 3, @Manager3);
    INSERT INTO Employee (ename, did, supervisorid) VALUES (N'Đỗ Văn G - Nhân viên', 3, @Manager3);
    
    PRINT '✓ Đã tạo 7 Employee với hierarchy (1 Giám đốc, 2 Trưởng phòng, 4 Nhân viên)';
END
ELSE
    PRINT 'Employee đã có dữ liệu';

-- ============================================
-- BƯỚC 3: TẠO USER
-- ============================================

IF NOT EXISTS (SELECT * FROM [User] WHERE uid = 1)
BEGIN
    -- Tạo User cho Admin (Giám đốc)
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('admin', 'admin123', N'Quản trị viên');
    DECLARE @AdminUID INT = SCOPE_IDENTITY();
    
    -- Tạo User cho Manager
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('manager1', 'manager123', N'Trưởng phòng B');
    DECLARE @ManagerUID INT = SCOPE_IDENTITY();
    
    -- Tạo User cho Employee
    INSERT INTO [User] (username, [password], displayname) 
    VALUES ('employee1', 'emp123', N'Nhân viên D');
    DECLARE @EmpUID INT = SCOPE_IDENTITY();
    
    PRINT '✓ Đã tạo 3 User (admin, manager1, employee1)';
END
ELSE
    PRINT 'User đã có dữ liệu';

-- ============================================
-- BƯỚC 4: TẠO ENROLLMENT (Link User và Employee)
-- ============================================

-- Lấy Employee IDs
DECLARE @AdminEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Giám đốc%');
DECLARE @ManagerEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Trưởng phòng%' AND eid != @AdminEID);
DECLARE @EmpEID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Nhân viên%' AND did = 2);

-- Lấy User IDs
DECLARE @AdminUID2 INT = (SELECT TOP 1 uid FROM [User] WHERE username = 'admin');
DECLARE @ManagerUID2 INT = (SELECT TOP 1 uid FROM [User] WHERE username = 'manager1');
DECLARE @EmpUID2 INT = (SELECT TOP 1 uid FROM [User] WHERE username = 'employee1');

IF NOT EXISTS (SELECT * FROM Enrollment WHERE uid = @AdminUID2 AND eid = @AdminEID)
BEGIN
    INSERT INTO Enrollment (uid, eid, active) VALUES (@AdminUID2, @AdminEID, 1);
    INSERT INTO Enrollment (uid, eid, active) VALUES (@ManagerUID2, @ManagerEID, 1);
    INSERT INTO Enrollment (uid, eid, active) VALUES (@EmpUID2, @EmpEID, 1);
    
    PRINT '✓ Đã tạo 3 Enrollment (link User và Employee)';
END
ELSE
    PRINT 'Enrollment đã có dữ liệu';

-- ============================================
-- BƯỚC 5: GÁN ROLE CHO USER
-- ============================================

IF NOT EXISTS (SELECT * FROM UserRole WHERE uid = @AdminUID2 AND rid = 1)
BEGIN
    -- Admin có Role Admin (rid = 1)
    INSERT INTO UserRole (uid, rid) VALUES (@AdminUID2, 1);
    
    -- Manager có Role Manager (rid = 3)
    INSERT INTO UserRole (uid, rid) VALUES (@ManagerUID2, 3);
    
    -- Employee có Role Employee (rid = 2)
    INSERT INTO UserRole (uid, rid) VALUES (@EmpUID2, 2);
    
    PRINT '✓ Đã gán Role cho User (Admin, Manager, Employee)';
END
ELSE
    PRINT 'UserRole đã có dữ liệu';

-- ============================================
-- BƯỚC 6: TẠO REQUESTFORLEAVE (Để test)
-- ============================================

IF NOT EXISTS (SELECT * FROM RequestForLeave WHERE rid = 1)
BEGIN
    -- Lấy Employee ID
    DECLARE @TestEmpID INT = (SELECT TOP 1 eid FROM Employee WHERE ename LIKE N'%Nhân viên%');
    
    -- Tạo đơn nghỉ phép
    INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, leavetype_id)
    VALUES (@TestEmpID, '2025-01-15', '2025-01-17', N'Nghỉ phép năm', 0, 1);
    
    INSERT INTO RequestForLeave (created_by, [from], [to], reason, status, processed_by, leavetype_id)
    VALUES (@TestEmpID, '2025-02-10', '2025-02-12', N'Nghỉ ốm', 1, @ManagerEID, 1);
    
    PRINT '✓ Đã tạo 2 RequestForLeave (1 chờ duyệt, 1 đã duyệt)';
END
ELSE
    PRINT 'RequestForLeave đã có dữ liệu';

-- ============================================
-- BƯỚC 7: TẠO ATTENDANCE (Để test)
-- ============================================

IF NOT EXISTS (SELECT * FROM Attendance WHERE attendance_id = 1)
BEGIN
    DECLARE @RID INT = (SELECT TOP 1 rid FROM RequestForLeave WHERE status = 1);
    
    -- Chấm công cho đơn đã duyệt
    INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time, note)
    VALUES (@TestEmpID, @RID, '2025-02-10', '08:00:00', '17:00:00', N'Chấm công ngày nghỉ phép');
    
    -- Chấm công hàng ngày (không có request_id)
    INSERT INTO Attendance (employee_id, request_id, attendance_date, check_in_time, check_out_time)
    VALUES (@TestEmpID, NULL, CAST(GETDATE() AS DATE), '08:30:00', '17:30:00');
    
    PRINT '✓ Đã tạo 2 Attendance (1 theo request, 1 hàng ngày)';
END
ELSE
    PRINT 'Attendance đã có dữ liệu';

-- ============================================
-- BƯỚC 8: TẠO ACTIVITYLOG (Để test)
-- ============================================

IF NOT EXISTS (SELECT * FROM ActivityLog WHERE log_id = 1)
BEGIN
    DECLARE @RID2 INT = (SELECT TOP 1 rid FROM RequestForLeave);
    
    -- Log tạo đơn
    INSERT INTO ActivityLog (user_id, employee_id, activity_type, entity_type, entity_id, action_description)
    VALUES (@EmpUID2, @TestEmpID, 'CREATE_REQUEST', 'RequestForLeave', @RID2, N'Tạo đơn xin nghỉ phép');
    
    -- Log duyệt đơn
    INSERT INTO ActivityLog (user_id, employee_id, activity_type, entity_type, entity_id, action_description)
    VALUES (@ManagerUID2, @ManagerEID, 'APPROVE_REQUEST', 'RequestForLeave', @RID2, N'Duyệt đơn xin nghỉ phép');
    
    PRINT '✓ Đã tạo 2 ActivityLog (CREATE_REQUEST, APPROVE_REQUEST)';
END
ELSE
    PRINT 'ActivityLog đã có dữ liệu';

-- ============================================
-- KIỂM TRA DỮ LIỆU TEST
-- ============================================

PRINT '';
PRINT '========================================';
PRINT 'KIỂM TRA DỮ LIỆU TEST:';
PRINT '========================================';

-- Kiểm tra Employee hierarchy (đệ quy)
DECLARE @HierarchyCount INT;
WITH Org AS (
    SELECT eid, ename, supervisorid, 0 as lvl 
    FROM Employee 
    WHERE eid = @AdminEID
    
    UNION ALL
    
    SELECT c.eid, c.ename, c.supervisorid, o.lvl + 1 as lvl 
    FROM Employee c 
    JOIN Org o ON c.supervisorid = o.eid
)
SELECT @HierarchyCount = COUNT(*) FROM Org;

IF @HierarchyCount >= 3
    PRINT '✓ Đệ quy Employee hierarchy hoạt động (' + CAST(@HierarchyCount AS VARCHAR) + ' nhân viên trong cây)';
ELSE
    PRINT '✗ Đệ quy Employee hierarchy có vấn đề';

-- Kiểm tra phân quyền
DECLARE @AdminFeatureCount INT;
SELECT @AdminFeatureCount = COUNT(*) 
FROM UserRole ur
INNER JOIN RoleFeature rf ON ur.rid = rf.rid
WHERE ur.uid = @AdminUID2;

IF @AdminFeatureCount >= 10
    PRINT '✓ Phân quyền Admin hoạt động (' + CAST(@AdminFeatureCount AS VARCHAR) + ' features)';
ELSE
    PRINT '✗ Phân quyền Admin có vấn đề';

-- Kiểm tra dữ liệu
DECLARE @EmpCount INT = (SELECT COUNT(*) FROM Employee);
DECLARE @UserCount INT = (SELECT COUNT(*) FROM [User]);
DECLARE @RequestCount INT = (SELECT COUNT(*) FROM RequestForLeave);
DECLARE @AttendanceCount INT = (SELECT COUNT(*) FROM Attendance);

PRINT '✓ Employee: ' + CAST(@EmpCount AS VARCHAR);
PRINT '✓ User: ' + CAST(@UserCount AS VARCHAR);
PRINT '✓ RequestForLeave: ' + CAST(@RequestCount AS VARCHAR);
PRINT '✓ Attendance: ' + CAST(@AttendanceCount AS VARCHAR);

PRINT '';
PRINT '========================================';
PRINT 'HOÀN TẤT TẠO DỮ LIỆU TEST!';
PRINT '========================================';
PRINT '';
PRINT 'Thông tin đăng nhập test:';
PRINT '1. Admin: username=admin, password=admin123';
PRINT '2. Manager: username=manager1, password=manager123';
PRINT '3. Employee: username=employee1, password=emp123';
PRINT '';
PRINT 'Các chức năng đã sẵn sàng để test:';
PRINT '✓ Đăng nhập/Đăng xuất';
PRINT '✓ Phân quyền (Role-Based Access Control)';
PRINT '✓ Đệ quy Employee hierarchy';
PRINT '✓ Tạo/Xem/Duyệt đơn nghỉ phép';
PRINT '✓ Chấm công (theo request và hàng ngày)';
PRINT '✓ Lịch Division (Agenda)';
PRINT '✓ Activity Log';
PRINT '✓ Thống kê';
GO


