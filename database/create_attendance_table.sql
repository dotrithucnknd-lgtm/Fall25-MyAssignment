-- Script tạo bảng Attendance để quản lý chấm công theo ngày nghỉ
-- Database: FALL25_Assignment

CREATE TABLE Attendance (
    attendance_id INT IDENTITY(1,1) PRIMARY KEY,
    employee_id INT NOT NULL,
    request_id INT, -- ID của đơn nghỉ phép (có thể NULL nếu chấm công độc lập)
    attendance_date DATE NOT NULL, -- Ngày chấm công
    check_in_time TIME, -- Thời gian check-in
    check_out_time TIME, -- Thời gian check-out
    note NVARCHAR(500), -- Ghi chú
    created_at DATETIME2 DEFAULT GETDATE(), -- Thời gian tạo bản ghi
    
    -- Foreign keys
    CONSTRAINT FK_Attendance_Employee FOREIGN KEY (employee_id) REFERENCES Employee(eid),
    CONSTRAINT FK_Attendance_RequestForLeave FOREIGN KEY (request_id) REFERENCES RequestForLeave(rid)
);

-- Tạo index để tăng hiệu suất truy vấn
CREATE INDEX IX_Attendance_Employee ON Attendance(employee_id);
CREATE INDEX IX_Attendance_Request ON Attendance(request_id);
CREATE INDEX IX_Attendance_Date ON Attendance(attendance_date DESC);
CREATE INDEX IX_Attendance_Employee_Date ON Attendance(employee_id, attendance_date DESC);

GO

-- Tạo view để dễ xem chấm công
CREATE VIEW vw_Attendance AS
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
LEFT JOIN RequestForLeave r ON a.request_id = r.rid;

-- Tạo unique constraint để đảm bảo mỗi employee chỉ chấm công một lần cho một ngày trong một đơn nghỉ phép
-- (Cho phép chấm công nhiều lần cho cùng một ngày nếu không có request_id)
-- Lưu ý: SQL Server không hỗ trợ filtered unique index với WHERE clause, nên sử dụng unique constraint
-- Tuy nhiên, để cho phép chấm công nhiều lần cho cùng một ngày nếu không có request_id, 
-- chúng ta sẽ không tạo unique constraint ở đây và xử lý logic ở application layer

