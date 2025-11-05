-- Script tạo các nhân viên mẫu
-- Database: FALL25_Assignment
-- Ngày: 2025-11-05

USE [FALL25_Assignment]
GO

PRINT '========================================';
PRINT 'Đang tạo các nhân viên mẫu...';
PRINT '========================================';
PRINT '';

-- Kiểm tra và tạo Division nếu chưa có
IF NOT EXISTS (SELECT * FROM Division WHERE did = 1)
BEGIN
    INSERT INTO Division (did, dname) VALUES (1, 'Phòng Nhân Sự');
    PRINT '✓ Đã tạo Division: Phòng Nhân Sự (DID: 1)';
END
ELSE
BEGIN
    PRINT 'Division ID 1 đã tồn tại';
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
DECLARE @maxEid INT;
SELECT @maxEid = ISNULL(MAX(eid), 0) FROM Employee;

-- Tạo các nhân viên mẫu
DECLARE @eid INT;
DECLARE @did INT;

-- Nhân viên 1: Nguyễn Văn A (Phòng Nhân Sự)
SET @eid = @maxEid + 1;
SET @did = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Nguyễn Văn A', @did, NULL);
    PRINT '✓ Đã tạo Employee: Nguyễn Văn A (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 2: Trần Thị B (Phòng Kỹ Thuật)
SET @eid = @maxEid + 2;
SET @did = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Trần Thị B', @did, NULL);
    PRINT '✓ Đã tạo Employee: Trần Thị B (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 3: Lê Văn C (Phòng Kinh Doanh)
SET @eid = @maxEid + 3;
SET @did = 3;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Lê Văn C', @did, NULL);
    PRINT '✓ Đã tạo Employee: Lê Văn C (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 4: Phạm Thị D (Phòng Hành Chính)
SET @eid = @maxEid + 4;
SET @did = 4;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Phạm Thị D', @did, NULL);
    PRINT '✓ Đã tạo Employee: Phạm Thị D (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 5: Hoàng Văn E (Phòng Kỹ Thuật)
SET @eid = @maxEid + 5;
SET @did = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Hoàng Văn E', @did, NULL);
    PRINT '✓ Đã tạo Employee: Hoàng Văn E (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 6: Võ Thị F (Phòng Nhân Sự)
SET @eid = @maxEid + 6;
SET @did = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Võ Thị F', @did, NULL);
    PRINT '✓ Đã tạo Employee: Võ Thị F (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 7: Đặng Văn G (Phòng Kinh Doanh)
SET @eid = @maxEid + 7;
SET @did = 3;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Đặng Văn G', @did, NULL);
    PRINT '✓ Đã tạo Employee: Đặng Văn G (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 8: Bùi Thị H (Phòng Hành Chính)
SET @eid = @maxEid + 8;
SET @did = 4;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Bùi Thị H', @did, NULL);
    PRINT '✓ Đã tạo Employee: Bùi Thị H (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 9: Ngô Văn I (Phòng Kỹ Thuật)
SET @eid = @maxEid + 9;
SET @did = 2;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Ngô Văn I', @did, NULL);
    PRINT '✓ Đã tạo Employee: Ngô Văn I (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

-- Nhân viên 10: Dương Thị K (Phòng Nhân Sự)
SET @eid = @maxEid + 10;
SET @did = 1;
IF NOT EXISTS (SELECT * FROM Employee WHERE eid = @eid)
BEGIN
    INSERT INTO Employee (eid, ename, did, supervisorid)
    VALUES (@eid, 'Dương Thị K', @did, NULL);
    PRINT '✓ Đã tạo Employee: Dương Thị K (EID: ' + CAST(@eid AS VARCHAR(10)) + ', DID: ' + CAST(@did AS VARCHAR(10)) + ')';
END

PRINT '';
PRINT '========================================';
PRINT '✓ Hoàn thành! Đã tạo các nhân viên mẫu';
PRINT '========================================';
GO

