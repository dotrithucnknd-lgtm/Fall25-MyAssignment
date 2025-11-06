# HƯỚNG DẪN REBUILD VÀ KHẮC PHỤC LỖI KẾT NỐI DATABASE

## Vấn đề hiện tại:
- Lỗi: `NullPointerException: Cannot invoke "java.sql.Connection.prepareStatement(String)" because "this.connection" is null`
- Không thấy log từ DBContext constructor → Code chưa được compile lại

## Các bước khắc phục:

### Bước 1: Clean và Rebuild Project

**Trong NetBeans:**
1. Right-click vào project `Fall25Assm`
2. Chọn `Clean and Build`
3. Đợi quá trình build hoàn tất
4. Kiểm tra xem có lỗi compile không

**Hoặc dùng command line:**
```bash
# Nếu có Ant
ant clean
ant compile

# Hoặc xóa thư mục build và rebuild
rm -rf build
# Sau đó rebuild trong NetBeans
```

### Bước 2: Restart Tomcat

1. **Stop Tomcat** hoàn toàn
2. **Start lại Tomcat**
3. Xem log trong Tomcat console

### Bước 3: Kiểm tra Log

Sau khi restart, xem log trong Tomcat console. Bạn sẽ thấy:

**Nếu kết nối thành công:**
```
INFO: Database connection established successfully to FALL25_Assignment
```

**Nếu kết nối thất bại:**
```
SEVERE: Failed to connect to database FALL25_Assignment...
SQLException in DBContext constructor:
SQL Error: [chi tiết lỗi]
```

### Bước 4: Setup Database (nếu cần)

Nếu log báo lỗi kết nối, chạy các script SQL theo thứ tự:

1. **Chạy `setup_new_database.sql`** để tạo Login và User:
   ```sql
   -- File: database/setup_new_database.sql
   -- Tạo Login: java_admin
   -- Tạo User: java_admin_user
   -- Gán quyền: db_owner
   ```

2. **Chạy `complete_database_for_website.sql`** để tạo schema:
   ```sql
   -- File: database/complete_database_for_website.sql
   -- Tạo tất cả bảng, view, indexes
   -- Thêm dữ liệu mẫu
   ```

3. **Chạy `test_connection.sql`** để kiểm tra:
   ```sql
   -- File: database/test_connection.sql
   -- Kiểm tra database, login, user, quyền, bảng
   ```

### Bước 5: Test lại

1. Mở trình duyệt
2. Truy cập: `http://localhost:8080/Fall25Assm/login`
3. Thử đăng nhập
4. Xem log trong Tomcat console

## Thông tin kết nối:

- **Server**: `localhost:1433`
- **Database**: `FALL25_Assignment`
- **Username**: `java_admin`
- **Password**: `P@ssw0rd123`

## Lưu ý quan trọng:

1. **Code đã được cập nhật** nhưng cần **rebuild** để có hiệu lực
2. **Log sẽ hiển thị chi tiết** lỗi nếu có
3. Nếu vẫn lỗi, **gửi log từ Tomcat console** để xác định nguyên nhân

## Kiểm tra nhanh:

Sau khi rebuild và restart, nếu vẫn không thấy log từ DBContext constructor:
- Code chưa được compile lại → Cần rebuild lại
- Có lỗi compile → Kiểm tra lỗi compile và sửa
- Class không được load → Kiểm tra classpath


