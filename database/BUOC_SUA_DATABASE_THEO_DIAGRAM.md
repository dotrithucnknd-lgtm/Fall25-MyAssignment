# HƯỚNG DẪN CHỈNH SỬA DATABASE THEO DIAGRAM

Dựa trên diagram bạn cung cấp, đây là **các bước cụ thể** cần thực hiện:

---

## 🎯 MỤC TIÊU

Đảm bảo các cột Primary Key là **IDENTITY (auto-increment)** để hệ thống tự động tạo EID và UID khi đăng ký.

---

## 📋 CÁC BƯỚC CHỈNH SỬA

### **BƯỚC 1: SỬA BẢNG Employee**

#### Trong SQL Server Management Studio (SSMS):

1. **Mở Object Explorer** → Database `FALL25_Assignment` → Tables
2. **Right-click** bảng `Employee` → **Design**

3. **Kiểm tra cột `eid`:**
   - ✅ Kiểu dữ liệu: `int`
   - ✅ **Allow Nulls**: ❌ (BỎ CHECK)
   - ✅ **Primary Key**: ✓ (Có dấu chìa khóa màu vàng)

4. **QUAN TRỌNG - Thiết lập IDENTITY:**
   - Click vào cột `eid`
   - Ở phần **Column Properties** (phía dưới), tìm mục **Identity Specification**
   - Expand mục này
   - Đặt các giá trị:
     - **Is Identity**: `Yes` ← **QUAN TRỌNG NHẤT**
     - **Identity Seed**: `1`
     - **Identity Increment**: `1`

5. **Kiểm tra cột `ename`:**
   - Kiểu dữ liệu: `nvarchar` hoặc `nvarchar(max)`
   - **Allow Nulls**: ❌ (Bỏ check)

6. **Lưu lại** (Ctrl + S hoặc Save button)

---

### **BƯỚC 2: SỬA BẢNG User**

1. **Right-click** bảng `User` → **Design**

2. **Kiểm tra cột `uid`:**
   - ✅ Kiểu dữ liệu: `int`
   - ✅ **Allow Nulls**: ❌
   - ✅ **Primary Key**: ✓

3. **Thiết lập IDENTITY cho `uid`:**
   - Click vào cột `uid`
   - Trong **Column Properties** → **Identity Specification**:
     - **Is Identity**: `Yes` ← **QUAN TRỌNG**
     - **Identity Seed**: `1`
     - **Identity Increment**: `1`

4. **Kiểm tra các cột khác:**
   - `username`: `nvarchar(100)` hoặc `nvarchar(255)`, Allow Nulls: ❌
   - `password`: `nvarchar(255)`, Allow Nulls: ❌
   - `displayname`: `nvarchar(255)`, Allow Nulls: ❌

5. **Thiết lập UNIQUE cho `username`:**
   - Right-click vào vùng trống trong Design view → **Indexes/Keys**
   - Click **Add**
   - Chọn cột `username` trong danh sách
   - Đặt **Is Unique**: `Yes`
   - Tên Index: `UQ_User_Username` (hoặc để mặc định)
   - Click **Close**

6. **Lưu lại**

---

### **BƯỚC 3: KIỂM TRA BẢNG Enrollment**

1. **Right-click** bảng `Enrollment` → **Design**

2. **Kiểm tra các cột:**
   - `uid`: `int`, Allow Nulls: ❌, Foreign Key đến `User(uid)`
   - `eid`: `int`, Allow Nulls: ❌, Foreign Key đến `Employee(eid)`
   - `active`: `bit` hoặc `int`, Default Value: `1`, Allow Nulls: ❌

3. **Kiểm tra Primary Key:**
   - Phải có Composite Primary Key gồm `(uid, eid)`
   - Nếu chưa có:
     - Chọn cả 2 cột `uid` và `eid` (giữ Ctrl khi click)
     - Right-click → **Set Primary Key**

4. **Kiểm tra Foreign Keys:**

   **Foreign Key đến User:**
   - Right-click vùng trống → **Relationships**
   - Tìm relationship có tên `FK_Enrollment_User` hoặc tương tự
   - Nếu chưa có, click **Add**:
     - **Foreign Key Table**: `Enrollment`
     - **Foreign Key Column**: `uid`
     - **Primary Key Table**: `User`
     - **Primary Key Column**: `uid`
     - Đặt tên: `FK_Enrollment_User`
     - Click **Close**

   **Foreign Key đến Employee:**
   - Tương tự như trên
   - Foreign Key Column: `eid`
   - Primary Key Table: `Employee`
   - Primary Key Column: `eid`
   - Tên: `FK_Enrollment_Employee`

5. **Lưu lại**

---

### **BƯỚC 4: KIỂM TRA BẢNG ActivityLog** (Nếu có)

1. **Right-click** bảng `ActivityLog` → **Design**

2. **Kiểm tra Foreign Keys:**
   - `user_id` → Foreign Key đến `User(uid)`
   - `employee_id` → Foreign Key đến `Employee(eid)` (có thể NULL)

3. **Lưu lại** nếu có thay đổi

---

## ✅ XÁC MINH SAU KHI SỬA

Chạy các câu lệnh SQL sau trong SSMS để kiểm tra:

### Kiểm tra 1: Employee.eid có phải IDENTITY không?

```sql
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS ColumnName,
    is_identity,
    seed_value,
    increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('Employee') AND name = 'eid';
```

**Kết quả mong đợi:**
```
TableName  ColumnName  is_identity  seed_value  increment_value
Employee   eid         1            1           1
```

✅ Nếu `is_identity = 1` → **THÀNH CÔNG**

❌ Nếu `is_identity = 0` hoặc không có kết quả → **CẦN SỬA LẠI**

---

### Kiểm tra 2: User.uid có phải IDENTITY không?

```sql
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS ColumnName,
    is_identity,
    seed_value,
    increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('User') AND name = 'uid';
```

**Kết quả mong đợi:**
```
TableName  ColumnName  is_identity  seed_value  increment_value
User       uid         1            1           1
```

✅ Nếu `is_identity = 1` → **THÀNH CÔNG**

---

### Kiểm tra 3: User.username có UNIQUE không?

```sql
SELECT 
    i.name AS IndexName,
    i.is_unique,
    c.name AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('User') AND c.name = 'username';
```

**Kết quả mong đợi:**
```
IndexName          is_unique  ColumnName
UQ_User_Username   1          username
```

✅ Nếu `is_unique = 1` → **THÀNH CÔNG**

---

### Kiểm tra 4: Enrollment có Foreign Keys đúng không?

```sql
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    cp.name AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    cr.name AS ReferencedColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
INNER JOIN sys.columns cp ON fkc.parent_object_id = cp.object_id AND fkc.parent_column_id = cp.column_id
INNER JOIN sys.columns cr ON fkc.referenced_object_id = cr.object_id AND fkc.referenced_column_id = cr.column_id
WHERE fk.parent_object_id = OBJECT_ID('Enrollment');
```

**Kết quả mong đợi:**
```
ForeignKeyName           TableName   ColumnName  ReferencedTable  ReferencedColumn
FK_Enrollment_User       Enrollment  uid         User             uid
FK_Enrollment_Employee   Enrollment  eid         Employee         eid
```

✅ Nếu có 2 Foreign Keys như trên → **THÀNH CÔNG**

---

## 🧪 TEST CHỨC NĂNG

Sau khi sửa xong, test thử:

### Test 1: INSERT Employee (xem EID có tự động tăng không)

```sql
-- Lưu ý: KHÔNG chỉ định eid trong INSERT
INSERT INTO Employee(ename) VALUES ('Test Employee 1');

-- Lấy EID vừa tạo
DECLARE @NewEID INT = SCOPE_IDENTITY();
SELECT @NewEID AS NewEID;

-- Kết quả mong đợi: NewEID > 0 (ví dụ: 1, 2, 3...)

-- Test lại lần 2
INSERT INTO Employee(ename) VALUES ('Test Employee 2');
SELECT SCOPE_IDENTITY() AS NewEID2;
-- Kết quả: NewEID2 > NewEID (đã tự động tăng)

-- Xóa test data
DELETE FROM Employee WHERE ename LIKE 'Test Employee%';
```

✅ Nếu EID tự động tăng → **THÀNH CÔNG**

---

### Test 2: INSERT User (xem UID có tự động tăng không)

```sql
-- KHÔNG chỉ định uid trong INSERT
INSERT INTO [User](username, [password], displayname) 
VALUES ('testuser1', 'password123', 'Test User 1');

DECLARE @NewUID INT = SCOPE_IDENTITY();
SELECT @NewUID AS NewUID;

-- Test lại
INSERT INTO [User](username, [password], displayname) 
VALUES ('testuser2', 'password123', 'Test User 2');
SELECT SCOPE_IDENTITY() AS NewUID2;

-- Xóa test
DELETE FROM [User] WHERE username LIKE 'testuser%';
```

✅ Nếu UID tự động tăng → **THÀNH CÔNG**

---

### Test 3: Test đăng ký trên ứng dụng

1. Mở trình duyệt
2. Truy cập: `http://localhost:8080/Fall25Assm/signup`
3. Điền thông tin:
   - Họ và tên: `Nguyễn Văn A`
   - Tên đăng nhập: `testuser`
   - Mật khẩu: `123456`
4. Click **Đăng ký**
5. Kiểm tra:
   - ✅ Nếu đăng ký thành công và tự động đăng nhập → **HOÀN TẤT**
   - ❌ Nếu có lỗi, xem log server để biết chi tiết

---

## ⚠️ LƯU Ý QUAN TRỌNG

### Nếu bảng Employee đã có dữ liệu:

1. **BACKUP database trước khi sửa**
2. Có thể cần:
   - Xóa dữ liệu cũ
   - Hoặc tạo bảng mới với IDENTITY
   - Copy dữ liệu sang

### Nếu không thể sửa trực tiếp:

Có thể phải:
1. Tạo bảng Employee_new với IDENTITY
2. Copy dữ liệu sang
3. Xóa bảng cũ
4. Đổi tên bảng mới

**Script SQL để làm việc này:**

```sql
-- Chỉ chạy nếu thật sự cần thiết và đã backup!
-- Tạo bảng mới với IDENTITY
CREATE TABLE Employee_new (
    eid INT IDENTITY(1,1) PRIMARY KEY,
    ename NVARCHAR(255) NOT NULL
);

-- Copy dữ liệu (nếu có)
-- INSERT INTO Employee_new(ename) SELECT ename FROM Employee;

-- Xóa bảng cũ
-- DROP TABLE Employee;

-- Đổi tên
-- EXEC sp_rename 'Employee_new', 'Employee';
```

---

## 📝 CHECKLIST HOÀN THÀNH

Trước khi test đăng ký, đảm bảo:

- [ ] Employee.eid là IDENTITY(1,1)
- [ ] Employee.eid là Primary Key
- [ ] User.uid là IDENTITY(1,1)
- [ ] User.uid là Primary Key
- [ ] User.username có UNIQUE constraint
- [ ] Enrollment.uid là Foreign Key đến User(uid)
- [ ] Enrollment.eid là Foreign Key đến Employee(eid)
- [ ] Enrollment có Composite Primary Key (uid, eid)
- [ ] Đã test INSERT thử Employee và User
- [ ] Đã backup database (nếu có dữ liệu quan trọng)

---

## 🆘 NẾU VẪN GẶP LỖI

1. **Kiểm tra log server** (xem lỗi SQL cụ thể)
2. **Chạy script SQL** trong `database/create_database_schema.sql` (tự động kiểm tra và sửa)
3. **Kiểm tra connection string** trong `src/java/dal/DBContext.java`
4. **Kiểm tra quyền user** `java_admin` có đủ quyền INSERT không

---

**Chúc bạn thành công! 🎉**



