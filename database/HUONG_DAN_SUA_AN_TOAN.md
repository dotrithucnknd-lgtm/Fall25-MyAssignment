# HƯỚNG DẪN SỬA DATABASE AN TOÀN (KHÔNG MẤT DỮ LIỆU VÀ SCHEMA)

## 🛡️ GIẢI PHÁP AN TOÀN

Thay vì xóa bảng, chúng ta sẽ:
1. **BACKUP toàn bộ** (dữ liệu, triggers, stored procedures, views, indexes)
2. **Tạo bảng MỚI** với IDENTITY
3. **Copy dữ liệu** sang bảng mới
4. **Đổi tên** bảng mới
5. **Tạo lại** Foreign Keys và constraints

**→ KHÔNG MẤT bất kỳ thứ gì!**

---

## 📋 CÁC BƯỚC CHI TIẾT

### BƯỚC 1: CHẠY SCRIPT BACKUP

1. Mở file `database/SAFE_FIX_DATABASE.sql`
2. Chạy **PHẦN ĐẦU** (từ đầu đến "ĐÃ BACKUP XONG!")
3. Script sẽ backup:
   - ✅ Dữ liệu các bảng (vào `BACKUP_SCHEMA`)
   - ✅ Stored Procedures (in danh sách)
   - ✅ Views (in danh sách)
   - ✅ Triggers (in danh sách)
   - ✅ Indexes (in danh sách)

---

### BƯỚC 2: KIỂM TRA XEM CẦN SỬA GÌ

Script sẽ tự động kiểm tra:
- Nếu `eid` và `uid` **ĐÃ LÀ IDENTITY** → Không cần sửa
- Nếu **CHƯA LÀ IDENTITY** → Hiển thị hướng dẫn sửa

---

### BƯỚC 3: SỬA BẢNG EMPLOYEE (Nếu cần)

**Chỉ sửa nếu script báo: "Employee.eid CHƯA LÀ IDENTITY"**

1. Tìm phần comment `/*` trong script (BƯỚC 7)
2. **Uncomment** phần code (xóa `/*` và `*/`)
3. Chạy lại phần code đó

**Code sẽ làm:**
```sql
-- 1. Tạo bảng Employee_new với IDENTITY
CREATE TABLE Employee_new (
    eid INT IDENTITY(1,1) PRIMARY KEY,
    ename NVARCHAR(255) NOT NULL,
    did INT NULL,
    supervisorid INT NULL
);

-- 2. Copy dữ liệu (giữ nguyên eid)
SET IDENTITY_INSERT Employee_new ON;
INSERT INTO Employee_new (eid, ename, did, supervisorid)
SELECT eid, ename, did, supervisorid FROM Employee;
SET IDENTITY_INSERT Employee_new OFF;

-- 3. Xóa bảng cũ
DROP TABLE Employee;

-- 4. Đổi tên bảng mới
EXEC sp_rename 'Employee_new', 'Employee';

-- 5. Tạo lại Foreign Keys (đệ quy supervisorid)
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
```

**→ Dữ liệu và Foreign Keys (đệ quy) được GIỮ NGUYÊN!**

---

### BƯỚC 4: SỬA BẢNG USER (Nếu cần)

**Chỉ sửa nếu script báo: "User.uid CHƯA LÀ IDENTITY"**

1. Tìm phần comment `/*` trong script (BƯỚC 8)
2. **Uncomment** phần code (xóa `/*` và `*/`)
3. Chạy lại phần code đó

**Code sẽ làm:**
```sql
-- 1. Tạo bảng User_new với IDENTITY
CREATE TABLE User_new (
    uid INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(100) NOT NULL UNIQUE,
    [password] NVARCHAR(255) NOT NULL,
    displayname NVARCHAR(255) NOT NULL
);

-- 2. Copy dữ liệu (giữ nguyên uid)
SET IDENTITY_INSERT User_new ON;
INSERT INTO User_new (uid, username, [password], displayname)
SELECT uid, username, [password], displayname FROM [User];
SET IDENTITY_INSERT User_new OFF;

-- 3. Xóa bảng cũ
DROP TABLE [User];

-- 4. Đổi tên bảng mới
EXEC sp_rename 'User_new', 'User';
```

**→ Dữ liệu được GIỮ NGUYÊN!**

---

### BƯỚC 5: TẠO LẠI FOREIGN KEYS

Sau khi sửa xong Employee và User, cần tạo lại Foreign Keys cho Enrollment:

```sql
-- Kiểm tra và tạo lại Foreign Keys cho Enrollment
IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Enrollment') 
    AND name = 'FK_Enrollment_User'
)
BEGIN
    ALTER TABLE Enrollment
    ADD CONSTRAINT FK_Enrollment_User 
    FOREIGN KEY (uid) REFERENCES [User](uid) ON DELETE CASCADE;
    PRINT '✓ Đã tạo lại FK_Enrollment_User';
END

IF NOT EXISTS (
    SELECT * FROM sys.foreign_keys 
    WHERE parent_object_id = OBJECT_ID('Enrollment') 
    AND name = 'FK_Enrollment_Employee'
)
BEGIN
    ALTER TABLE Enrollment
    ADD CONSTRAINT FK_Enrollment_Employee 
    FOREIGN KEY (eid) REFERENCES Employee(eid) ON DELETE CASCADE;
    PRINT '✓ Đã tạo lại FK_Enrollment_Employee';
END
```

---

### BƯỚC 6: KIỂM TRA KẾT QUẢ

Chạy các câu SQL này để xác nhận:

```sql
-- Kiểm tra Employee.eid
SELECT is_identity, seed_value, increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('Employee') AND name = 'eid';
-- Phải trả về: is_identity = 1

-- Kiểm tra User.uid
SELECT is_identity, seed_value, increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('User') AND name = 'uid';
-- Phải trả về: is_identity = 1

-- Kiểm tra Foreign Keys
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('Enrollment');
-- Phải có 2 Foreign Keys: FK_Enrollment_User và FK_Enrollment_Employee

-- Kiểm tra Foreign Key đệ quy Employee
SELECT 
    fk.name AS ForeignKeyName
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('Employee')
AND fk.referenced_object_id = OBJECT_ID('Employee');
-- Phải có FK_Employee_Supervisor (đệ quy)
```

---

## 🔄 RESTORE NẾU CÓ VẤN ĐỀ

Nếu sau khi sửa có vấn đề, có thể restore từ backup:

```sql
-- Restore Employee từ backup
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BACKUP_SCHEMA.Employee_backup')
BEGIN
    -- Xóa bảng hiện tại (nếu cần)
    -- DROP TABLE Employee;
    
    -- Copy lại từ backup
    SELECT * INTO Employee FROM BACKUP_SCHEMA.Employee_backup;
    
    -- Tạo lại Primary Key và Foreign Keys
    -- ... (xem script gốc)
END

-- Restore User từ backup
IF EXISTS (SELECT * FROM sys.tables WHERE name = 'BACKUP_SCHEMA.User_backup')
BEGIN
    -- Tương tự...
END
```

---

## ✅ ƯU ĐIỂM CỦA CÁCH NÀY

1. ✅ **KHÔNG MẤT DỮ LIỆU** - Tất cả dữ liệu được giữ nguyên
2. ✅ **KHÔNG MẤT FOREIGN KEYS** - Được tạo lại (bao gồm đệ quy)
3. ✅ **KHÔNG MẤT TRIGGERS** - Triggers vẫn hoạt động (chỉ cần check lại)
4. ✅ **KHÔNG MẤT STORED PROCEDURES** - Vẫn còn nguyên
5. ✅ **KHÔNG MẤT VIEWS** - Vẫn còn nguyên
6. ✅ **CÓ BACKUP** - Có thể restore nếu cần

---

## ⚠️ LƯU Ý

1. **Backup database trước** - Để chắc chắn 100%
2. **Test trên database phụ** - Nếu có thể
3. **Kiểm tra lại Foreign Keys** - Đảm bảo đệ quy vẫn hoạt động
4. **Kiểm tra Triggers** - Chạy test sau khi sửa

---

## 🧪 TEST SAU KHI SỬA

```sql
-- Test INSERT Employee (xem EID tự động tăng)
INSERT INTO Employee(ename) VALUES ('Test Employee');
SELECT SCOPE_IDENTITY() AS NewEID; -- Phải > 0
DELETE FROM Employee WHERE ename = 'Test Employee';

-- Test INSERT User (xem UID tự động tăng)
INSERT INTO [User](username, [password], displayname) 
VALUES ('testuser', 'password123', 'Test User');
SELECT SCOPE_IDENTITY() AS NewUID; -- Phải > 0
DELETE FROM [User] WHERE username = 'testuser';

-- Test đăng ký trên ứng dụng
-- Mở trình duyệt và test đăng ký user mới
```

---

**Chúc bạn thành công và an toàn! 🎉**

