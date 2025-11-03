# HƯỚNG DẪN CHỈNH SỬA DATABASE SCHEMA CHO CHỨC NĂNG ĐĂNG KÝ

## 📋 TỔNG QUAN

Để chức năng đăng ký hoạt động, database cần đảm bảo các yêu cầu sau:

1. **Bảng Employee**: Cột `eid` PHẢI là IDENTITY (auto-increment)
2. **Bảng User**: Cột `uid` PHẢI là IDENTITY (auto-increment)  
3. **Bảng Enrollment**: Liên kết User và Employee với Foreign Keys đúng
4. **Các ràng buộc**: UNIQUE cho username, Foreign Keys đầy đủ

---

## 🔧 CÁCH 1: SỬA BẰNG SQL SCRIPT (KHUYẾN NGHỊ)

### Bước 1: Mở SQL Server Management Studio (SSMS)

1. Kết nối đến database `FALL25_Assignment`
2. Mở file `database/create_database_schema.sql`
3. Chạy toàn bộ script

### Bước 2: Kiểm tra kết quả

Script sẽ tự động:
- ✅ Tạo các bảng nếu chưa có
- ✅ Kiểm tra và sửa các vấn đề về IDENTITY
- ✅ Tạo Foreign Keys nếu thiếu
- ✅ Hiển thị báo cáo kiểm tra

---

## 🔧 CÁCH 2: SỬA BẰNG DIAGRAM (Nếu bạn có quyền truy cập)

### **BƯỚC 1: Kiểm tra và sửa bảng Employee**

#### Trong Database Diagram:
1. Tìm bảng `Employee`
2. Xem cột `eid`:

**PHẢI ĐẢM BẢO:**
- ✅ Kiểu dữ liệu: `INT`
- ✅ **IDENTITY**: `Yes` (hoặc check box "Identity")
- ✅ **Identity Seed**: `1`
- ✅ **Identity Increment**: `1`
- ✅ **Primary Key**: `Yes`
- ✅ **Allow Nulls**: `No`

**Cột `ename`:**
- ✅ Kiểu dữ liệu: `NVARCHAR(255)` hoặc `NVARCHAR(MAX)`
- ✅ **Allow Nulls**: `No`

#### Nếu `eid` KHÔNG phải IDENTITY:
**Cách sửa trong SSMS:**
1. Right-click bảng `Employee` → Design
2. Chọn cột `eid`
3. Ở phần Properties, tìm "Identity Specification"
4. Đặt:
   - `Is Identity` = `Yes`
   - `Identity Seed` = `1`
   - `Identity Increment` = `1`

**⚠️ LƯU Ý:** Nếu bảng đã có dữ liệu, cần backup trước!

---

### **BƯỚC 2: Kiểm tra và sửa bảng User**

#### Trong Database Diagram:
1. Tìm bảng `User` (có thể hiển thị là `[User]`)
2. Xem cột `uid`:

**PHẢI ĐẢM BẢO:**
- ✅ Kiểu dữ liệu: `INT`
- ✅ **IDENTITY**: `Yes`
- ✅ **Identity Seed**: `1`
- ✅ **Identity Increment**: `1`
- ✅ **Primary Key**: `Yes`
- ✅ **Allow Nulls**: `No`

#### Các cột khác:

**`username`:**
- ✅ Kiểu dữ liệu: `NVARCHAR(100)` hoặc `NVARCHAR(255)`
- ✅ **Allow Nulls**: `No`
- ✅ **UNIQUE**: Phải có UNIQUE constraint

**`password`:**
- ✅ Kiểu dữ liệu: `NVARCHAR(255)`
- ✅ **Allow Nulls**: `No`

**`displayname`:**
- ✅ Kiểu dữ liệu: `NVARCHAR(255)`
- ✅ **Allow Nulls**: `No`

#### Nếu thiếu UNIQUE cho username:
1. Right-click bảng `User` → Design
2. Right-click vùng trống → Indexes/Keys
3. Click Add
4. Chọn cột `username`
5. Đặt `Is Unique` = `Yes`

---

### **BƯỚC 3: Kiểm tra và sửa bảng Enrollment**

#### Trong Database Diagram:
1. Tìm bảng `Enrollment`
2. Kiểm tra các cột:

**`uid`:**
- ✅ Kiểu dữ liệu: `INT`
- ✅ **Allow Nulls**: `No`
- ✅ **Foreign Key** đến `User(uid)`

**`eid`:**
- ✅ Kiểu dữ liệu: `INT`
- ✅ **Allow Nulls**: `No`
- ✅ **Foreign Key** đến `Employee(eid)`

**`active`:**
- ✅ Kiểu dữ liệu: `BIT` hoặc `INT`
- ✅ **Default Value**: `1`
- ✅ **Allow Nulls**: `No`

#### Kiểm tra Primary Key:
- ✅ Phải có Composite Primary Key: `(uid, eid)`

#### Kiểm tra Foreign Keys:

**Nếu thiếu Foreign Key đến User:**
1. Right-click bảng `Enrollment` → Design
2. Right-click vùng trống → Relationships
3. Click Add
4. Chọn:
   - **Foreign Key Table**: `Enrollment`
   - **Foreign Key Column**: `uid`
   - **Primary Key Table**: `User`
   - **Primary Key Column**: `uid`
5. Đặt tên: `FK_Enrollment_User`
6. Check "Cascade Delete" (tùy chọn)

**Nếu thiếu Foreign Key đến Employee:**
1. Làm tương tự như trên
2. Foreign Key Column: `eid`
3. Primary Key Table: `Employee`
4. Primary Key Column: `eid`
5. Tên: `FK_Enrollment_Employee`

---

### **BƯỚC 4: Kiểm tra bảng ActivityLog (nếu có)**

Nếu bạn có bảng ActivityLog, đảm bảo:
- ✅ Foreign Key đến `User(uid)`
- ✅ Foreign Key đến `Employee(eid)`

---

## 🔍 KIỂM TRA SAU KHI SỬA

### Chạy các câu lệnh SQL sau để kiểm tra:

```sql
-- 1. Kiểm tra Employee.eid có phải IDENTITY không
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS ColumnName,
    is_identity,
    seed_value,
    increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('Employee') AND name = 'eid';

-- Kết quả mong đợi:
-- is_identity = 1 (TRUE)
-- seed_value = 1
-- increment_value = 1

-- 2. Kiểm tra User.uid có phải IDENTITY không
SELECT 
    OBJECT_NAME(object_id) AS TableName,
    name AS ColumnName,
    is_identity,
    seed_value,
    increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('User') AND name = 'uid';

-- Kết quả mong đợi:
-- is_identity = 1 (TRUE)

-- 3. Kiểm tra Foreign Keys của Enrollment
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

-- Kết quả mong đợi:
-- Có 2 Foreign Keys: FK_Enrollment_User và FK_Enrollment_Employee

-- 4. Kiểm tra UNIQUE constraint cho username
SELECT 
    i.name AS IndexName,
    i.is_unique,
    c.name AS ColumnName
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id = OBJECT_ID('User') AND c.name = 'username';

-- Kết quả mong đợi:
-- is_unique = 1 (TRUE)
```

---

## 🧪 TEST CHỨC NĂNG ĐĂNG KÝ

Sau khi sửa xong:

1. **Test INSERT Employee:**
```sql
-- Chạy thử để xem EID có tự động tăng không
INSERT INTO Employee(ename) VALUES ('Test Employee');
SELECT SCOPE_IDENTITY() AS NewEID; -- Phải trả về số > 0

-- Xóa test
DELETE FROM Employee WHERE ename = 'Test Employee';
```

2. **Test INSERT User:**
```sql
-- Chạy thử để xem UID có tự động tăng không
INSERT INTO [User](username, [password], displayname) 
VALUES ('testuser', 'password123', 'Test User');
SELECT SCOPE_IDENTITY() AS NewUID; -- Phải trả về số > 0

-- Xóa test
DELETE FROM [User] WHERE username = 'testuser';
```

3. **Test đăng ký trên ứng dụng:**
   - Mở trình duyệt
   - Truy cập trang đăng ký
   - Điền thông tin và submit
   - Kiểm tra log server xem có lỗi không

---

## ❗ CÁC LỖI THƯỜNG GẶP

### Lỗi 1: "Cannot insert explicit value for identity column"
**Nguyên nhân:** Cột `eid` hoặc `uid` không phải IDENTITY
**Giải pháp:** Sửa như hướng dẫn Bước 1 và Bước 2

### Lỗi 2: "The INSERT statement conflicted with the UNIQUE constraint"
**Nguyên nhân:** Username đã tồn tại (đây là lỗi logic, không phải schema)
**Giải pháp:** OK, đây là validation đúng

### Lỗi 3: "The INSERT statement conflicted with the FOREIGN KEY constraint"
**Nguyên nhân:** Thiếu Foreign Keys hoặc dữ liệu không khớp
**Giải pháp:** Kiểm tra Foreign Keys như Bước 3

### Lỗi 4: Không lấy được EID sau khi INSERT
**Nguyên nhân:** 
- Cột `eid` không phải IDENTITY
- Hoặc code Java không đúng cách lấy IDENTITY
**Giải pháp:** 
- Kiểm tra lại `eid` có phải IDENTITY không
- Code đã được cập nhật dùng `OUTPUT INSERTED.eid`

---

## 📝 TÓM TẮT CÁC BƯỚC

1. ✅ **Employee.eid** → IDENTITY(1,1)
2. ✅ **User.uid** → IDENTITY(1,1)
3. ✅ **User.username** → UNIQUE
4. ✅ **Enrollment.uid** → Foreign Key đến User(uid)
5. ✅ **Enrollment.eid** → Foreign Key đến Employee(eid)
6. ✅ **Enrollment.active** → Default = 1

---

## 🆘 NẾU VẪN GẶP LỖI

1. **Kiểm tra log server** để xem lỗi SQL cụ thể
2. **Chạy script SQL** trong `database/create_database_schema.sql`
3. **Kiểm tra connection string** trong `DBContext.java`
4. **Kiểm tra quyền** của user `java_admin` có đủ quyền INSERT không

---

**Chúc bạn thành công! 🎉**

