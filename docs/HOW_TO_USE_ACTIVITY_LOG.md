# Hướng dẫn sử dụng Activity Log

## 1. Tạo bảng trong Database

Chạy file SQL: `database/create_activity_log_table.sql` trong SQL Server Management Studio hoặc Azure Data Studio.

```sql
-- Chạy script này trong database FALL25_Assignment
```

## 2. Cấu trúc bảng ActivityLog

Bảng gồm các cột:
- `log_id`: ID tự tăng
- `user_id`: ID người dùng thực hiện action (NOT NULL)
- `employee_id`: ID nhân viên (có thể NULL)
- `activity_type`: Loại hoạt động (CREATE_REQUEST, APPROVE_REQUEST, etc.)
- `entity_type`: Loại entity (RequestForLeave, User, etc.)
- `entity_id`: ID của entity liên quan
- `action_description`: Mô tả chi tiết
- `old_value`: Giá trị cũ (JSON format)
- `new_value`: Giá trị mới (JSON format)
- `ip_address`: IP của người dùng
- `user_agent`: Browser/device info
- `created_at`: Thời gian tạo log

## 3. Cách sử dụng trong Controller

### Ví dụ 1: Log khi tạo đơn xin nghỉ

Trong `CreateController.java`:

```java
import util.LogUtil;

@Override
protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user) {
    // ... code tạo đơn ...
    
    // Sau khi insert thành công
    LogUtil.logActivity(
        user,
        LogUtil.ActivityType.CREATE_REQUEST,
        LogUtil.EntityType.REQUEST_FOR_LEAVE,
        rfl.getId(), // ID của đơn vừa tạo
        "Tạo đơn xin nghỉ từ " + from + " đến " + to,
        null,
        "{\"from\":\"" + from + "\",\"to\":\"" + to + "\",\"reason\":\"" + reason + "\"}",
        req
    );
}
```

### Ví dụ 2: Log khi duyệt/từ chối đơn

Trong `ReviewController.java`:

```java
// Khi duyệt đơn
LogUtil.logActivity(
    user,
    LogUtil.ActivityType.APPROVE_REQUEST,
    LogUtil.EntityType.REQUEST_FOR_LEAVE,
    requestId,
    "Duyệt đơn xin nghỉ #" + requestId,
    "{\"status\":0}", // status cũ: pending
    "{\"status\":1}", // status mới: approved
    req
);

// Khi từ chối đơn
LogUtil.logActivity(
    user,
    LogUtil.ActivityType.REJECT_REQUEST,
    LogUtil.EntityType.REQUEST_FOR_LEAVE,
    requestId,
    "Từ chối đơn xin nghỉ #" + requestId,
    "{\"status\":0}",
    "{\"status\":2}",
    req
);
```

### Ví dụ 3: Log khi đăng nhập

Trong `LoginController.java`:

```java
// Sau khi login thành công
LogUtil.logSimpleActivity(
    user,
    LogUtil.ActivityType.LOGIN,
    "Đăng nhập vào hệ thống",
    req
);
```

### Ví dụ 4: Log khi xem danh sách

Trong `ListController.java`:

```java
@Override
protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user) {
    // ... code lấy danh sách ...
    
    LogUtil.logSimpleActivity(
        user,
        LogUtil.ActivityType.VIEW_REQUEST_LIST,
        "Xem danh sách đơn xin nghỉ",
        req
    );
}
```

## 4. Xem log history

### Lấy log theo user:

```java
ActivityLogDBContext logDB = new ActivityLogDBContext();
ArrayList<ActivityLog> logs = logDB.getLogsByUserId(userId);
```

### Lấy log theo activity type:

```java
ArrayList<ActivityLog> logs = logDB.getLogsByActivityType(LogUtil.ActivityType.APPROVE_REQUEST);
```

### Lấy log theo entity (ví dụ: theo đơn xin nghỉ):

```java
ArrayList<ActivityLog> logs = logDB.getLogsByEntity(
    LogUtil.EntityType.REQUEST_FOR_LEAVE, 
    requestId
);
```

### Xem tất cả logs (có phân trang):

```java
ArrayList<ActivityLog> logs = logDB.getAllLogs(page, pageSize);
```

## 5. Activity Types có sẵn

- `CREATE_REQUEST`: Tạo đơn xin nghỉ
- `APPROVE_REQUEST`: Duyệt đơn
- `REJECT_REQUEST`: Từ chối đơn
- `VIEW_REQUEST`: Xem chi tiết đơn
- `VIEW_REQUEST_LIST`: Xem danh sách đơn
- `LOGIN`: Đăng nhập
- `LOGOUT`: Đăng xuất
- `UPDATE_PROFILE`: Cập nhật profile

## 6. Entity Types có sẵn

- `RequestForLeave`: Đơn xin nghỉ
- `User`: Người dùng
- `Employee`: Nhân viên

## 7. Query log bằng SQL

Sử dụng view `vw_ActivityLog` để xem log dễ dàng:

```sql
-- Xem tất cả logs
SELECT * FROM vw_ActivityLog ORDER BY created_at DESC;

-- Xem log của user cụ thể
SELECT * FROM vw_ActivityLog WHERE user_id = 1 ORDER BY created_at DESC;

-- Xem log theo activity type
SELECT * FROM vw_ActivityLog WHERE activity_type = 'CREATE_REQUEST' ORDER BY created_at DESC;

-- Xem log của một đơn xin nghỉ cụ thể
SELECT * FROM vw_ActivityLog 
WHERE entity_type = 'RequestForLeave' AND entity_id = 123
ORDER BY created_at DESC;
```







