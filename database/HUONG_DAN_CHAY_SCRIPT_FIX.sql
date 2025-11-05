# HƯỚNG DẪN CHẠY SCRIPT FIX DATABASE

## ⚠️ CẢNH BÁO QUAN TRỌNG

Script này sẽ **XÓA VÀ TẠO LẠI** các bảng:
- Employee
- User
- Enrollment
- ActivityLog
- UserRole
- RequestForLeave

**→ SẼ MẤT TẤT CẢ DỮ LIỆU trong các bảng này!**

---

## 📋 CÁC BƯỚC THỰC HIỆN

### BƯỚC 1: BACKUP DATABASE (QUAN TRỌNG!)

1. Mở **SQL Server Management Studio (SSMS)**
2. Right-click database `FALL25_Assignment`
3. Chọn **Tasks** → **Back Up...**
4. Chọn:
   - Backup type: **Full**
   - Destination: Chọn file backup (ví dụ: `FALL25_Assignment_backup.bak`)
5. Click **OK** để backup

**HOẶC** chạy lệnh SQL:
```sql
BACKUP DATABASE FALL25_Assignment
TO DISK = 'C:\Backup\FALL25_Assignment_backup.bak'
WITH FORMAT, COMPRESSION;
```

---

### BƯỚC 2: KIỂM TRA QUYỀN

Đảm bảo user của bạn có quyền:
- CREATE TABLE
- DROP TABLE
- ALTER TABLE

Nếu không có quyền, yêu cầu DBA/giảng viên chạy script.

---

### BƯỚC 3: CHẠY SCRIPT

1. Mở file `database/FIX_DATABASE_IDENTITY.sql`
2. Đọc kỹ script (đặc biệt là phần backup)
3. Nếu đồng ý, chạy toàn bộ script (F5)
4. Xem kết quả ở tab **Messages**

---

### BƯỚC 4: KIỂM TRA

Sau khi chạy xong, chạy các câu SQL sau để xác nhận:

```sql
-- Kiểm tra Employee.eid
SELECT is_identity, seed_value, increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('Employee') AND name = 'eid';
-- Kết quả: is_identity = 1

-- Kiểm tra User.uid
SELECT is_identity, seed_value, increment_value
FROM sys.identity_columns
WHERE object_id = OBJECT_ID('User') AND name = 'uid';
-- Kết quả: is_identity = 1
```

---

## 🧪 TEST SAU KHI FIX

### Test 1: INSERT Employee

```sql
INSERT INTO Employee(ename) VALUES ('Test Employee');
SELECT SCOPE_IDENTITY() AS NewEID;
-- Phải trả về số > 0 (ví dụ: 1, 2, 3...)
DELETE FROM Employee WHERE ename = 'Test Employee';
```

### Test 2: INSERT User

```sql
INSERT INTO [User](username, [password], displayname) 
VALUES ('testuser', 'password123', 'Test User');
SELECT SCOPE_IDENTITY() AS NewUID;
-- Phải trả về số > 0
DELETE FROM [User] WHERE username = 'testuser';
```

### Test 3: Đăng ký trên ứng dụng

1. Mở trình duyệt
2. Truy cập: `http://localhost:8080/Fall25Assm/signup`
3. Đăng ký user mới
4. Nếu thành công → **HOÀN TẤT!**

---

## 🔄 RESTORE DỮ LIỆU (Nếu cần)

Nếu bạn đã có dữ liệu cũ và muốn restore:

**Cách 1: Restore từ backup**
```sql
RESTORE DATABASE FALL25_Assignment
FROM DISK = 'C:\Backup\FALL25_Assignment_backup.bak'
WITH REPLACE;
```

**Cách 2: Restore từ bảng backup (nếu script đã tạo)**
- Script đã tự động backup vào `Employee_backup` và `User_backup`
- Tuy nhiên, sau khi restore cần cập nhật lại Enrollment vì uid/eid đã thay đổi
- Cần script riêng để map lại

---

## ❗ NẾU GẶP LỖI

### Lỗi: "Cannot drop table because it is being referenced by a foreign key constraint"

**Giải pháp:** Script đã tự động xóa Foreign Keys trước, nhưng nếu vẫn lỗi:
- Kiểm tra xem có Foreign Keys nào khác không
- Xóa thủ công trước khi chạy script

### Lỗi: "User does not have permission to perform this action"

**Giải pháp:** 
- Yêu cầu DBA/giảng viên chạy script
- Hoặc cấp quyền ALTER, CREATE, DROP cho user

### Lỗi: "Database is in use"

**Giải pháp:**
- Đóng tất cả kết nối đến database
- Hoặc set database ở chế độ SINGLE_USER trước:
```sql
ALTER DATABASE FALL25_Assignment SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
-- Chạy script fix
ALTER DATABASE FALL25_Assignment SET MULTI_USER;
```

---

## 📞 CẦN HỖ TRỢ?

Nếu vẫn gặp vấn đề:
1. Gửi error message cụ thể
2. Gửi kết quả của các câu SQL kiểm tra
3. Kiểm tra log server khi test đăng ký

---

**Chúc bạn thành công! 🎉**



