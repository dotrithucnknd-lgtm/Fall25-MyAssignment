# Hướng dẫn sử dụng DAO Service

## 1. UserServiceDAO - Tạo User

### Mục đích
Đơn giản hóa việc tạo user hoàn chỉnh (Employee + User + Enrollment) trong một method duy nhất.

### Cách sử dụng

#### Ví dụ 1: Tạo user với Employee mới
```java
import dal.UserServiceDAO;
import dal.UserServiceDAO.UserResult;

UserServiceDAO userService = new UserServiceDAO();

// Tạo user với Employee mới
UserResult result = userService.createUser(
    "newuser",           // username
    "password123",        // password
    "New User",          // displayname
    true,                // createNewEmployee = true
    null                 // employeeId (không dùng khi createNewEmployee = true)
);

if (result.isSuccess()) {
    System.out.println("User created successfully!");
    System.out.println("User ID: " + result.getUserId());
    System.out.println("Employee ID: " + result.getEmployeeId());
} else {
    System.out.println("Error: " + result.getErrorMessage());
}
```

#### Ví dụ 2: Tạo user với Employee đã có
```java
UserServiceDAO userService = new UserServiceDAO();

// Tạo user với Employee đã có (employeeId = 5)
UserResult result = userService.createUser(
    "newuser2",          // username
    "password123",        // password
    "New User 2",        // displayname
    false,               // createNewEmployee = false
    5                    // employeeId của Employee đã có
);

if (result.isSuccess()) {
    System.out.println("User created successfully!");
} else {
    System.out.println("Error: " + result.getErrorMessage());
}
```

### UserResult Class
- `isSuccess()`: Kiểm tra thành công hay không
- `getErrorMessage()`: Lấy thông báo lỗi (nếu có)
- `getUserId()`: Lấy ID của User vừa tạo
- `getEmployeeId()`: Lấy ID của Employee (mới hoặc đã có)
- `getUser()`: Lấy đối tượng User vừa tạo

---

## 2. AttendanceServiceDAO - Check-in/Check-out

### Mục đích
Đơn giản hóa việc check-in/check-out hàng ngày hoặc cho đơn nghỉ phép.

### Cách sử dụng

#### Ví dụ 1: Check-in hàng ngày
```java
import dal.AttendanceServiceDAO;
import dal.AttendanceServiceDAO.AttendanceResult;
import java.sql.Date;
import java.sql.Time;

AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();

// Check-in hôm nay
Date today = new Date(System.currentTimeMillis());
AttendanceResult result = attendanceService.checkInDaily(
    1,                   // employeeId
    today,                // attendanceDate (null để dùng hôm nay)
    null,                 // checkInTime (null để dùng thời gian hiện tại)
    "Check-in sáng"      // note (optional)
);

if (result.isSuccess()) {
    System.out.println("Check-in thành công!");
    System.out.println("Attendance ID: " + result.getAttendance().getId());
} else {
    System.out.println("Error: " + result.getErrorMessage());
}
```

#### Ví dụ 2: Check-out hàng ngày
```java
AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();

Date today = new Date(System.currentTimeMillis());
AttendanceResult result = attendanceService.checkOutDaily(
    1,                   // employeeId
    today,                // attendanceDate
    null,                 // checkOutTime (null để dùng thời gian hiện tại)
    "Check-out chiều"     // note (optional)
);

if (result.isSuccess()) {
    System.out.println("Check-out thành công!");
} else {
    System.out.println("Error: " + result.getErrorMessage());
}
```

#### Ví dụ 3: Check-in cho đơn nghỉ phép
```java
import java.sql.Date;
import java.sql.Time;

AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();

Date attendanceDate = Date.valueOf("2025-11-07");
Time checkInTime = Time.valueOf("08:00:00");
Time checkOutTime = Time.valueOf("17:00:00");

AttendanceResult result = attendanceService.checkInForLeaveRequest(
    1,                   // employeeId
    10,                  // requestId (ID của đơn nghỉ phép)
    attendanceDate,      // attendanceDate
    checkInTime,         // checkInTime
    checkOutTime,        // checkOutTime (optional)
    "Chấm công ngày nghỉ" // note (optional)
);

if (result.isSuccess()) {
    System.out.println("Check-in cho đơn nghỉ phép thành công!");
} else {
    System.out.println("Error: " + result.getErrorMessage());
}
```

### AttendanceResult Class
- `isSuccess()`: Kiểm tra thành công hay không
- `getErrorMessage()`: Lấy thông báo lỗi (nếu có)
- `getAttendance()`: Lấy đối tượng Attendance vừa tạo/cập nhật
- `isIsNew()`: Kiểm tra xem là record mới hay cập nhật

---

## Lưu ý

1. **UserServiceDAO**:
   - Tự động validate input (username, password, displayname)
   - Tự động kiểm tra username đã tồn tại chưa
   - Tự động rollback nếu enrollment thất bại (xóa User vừa tạo)
   - Password phải có ít nhất 6 ký tự

2. **AttendanceServiceDAO**:
   - Check-in hàng ngày: không cần requestId
   - Check-in cho đơn nghỉ phép: cần requestId
   - Tự động tạo mới hoặc cập nhật nếu đã có record
   - Check-out yêu cầu phải có check-in trước

3. **Error Handling**:
   - Luôn kiểm tra `result.isSuccess()` trước khi sử dụng kết quả
   - Đọc `result.getErrorMessage()` để biết lỗi cụ thể

---

## Ví dụ tích hợp trong Controller

### Sử dụng UserServiceDAO trong CreateUserController
```java
UserServiceDAO userService = new UserServiceDAO();

boolean createNewEmployee = "on".equals(req.getParameter("createNewEmployee"));
Integer employeeId = null;
if (!createNewEmployee) {
    employeeId = Integer.parseInt(req.getParameter("employeeId"));
}

UserResult result = userService.createUser(
    req.getParameter("username"),
    req.getParameter("password"),
    req.getParameter("displayname"),
    createNewEmployee,
    employeeId
);

if (result.isSuccess()) {
    req.getSession().setAttribute("successMessage", "Tạo user thành công!");
} else {
    req.getSession().setAttribute("errorMessage", result.getErrorMessage());
}
```

### Sử dụng AttendanceServiceDAO trong AttendanceController
```java
AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();

String action = req.getParameter("action"); // "checkin" hoặc "checkout"
Date today = new Date(System.currentTimeMillis());

if ("checkin".equals(action)) {
    AttendanceResult result = attendanceService.checkInDaily(
        user.getEmployee().getId(),
        today,
        null,
        null
    );
    
    if (result.isSuccess()) {
        req.getSession().setAttribute("successMessage", "Check-in thành công!");
    } else {
        req.getSession().setAttribute("errorMessage", result.getErrorMessage());
    }
} else if ("checkout".equals(action)) {
    AttendanceResult result = attendanceService.checkOutDaily(
        user.getEmployee().getId(),
        today,
        null,
        null
    );
    
    if (result.isSuccess()) {
        req.getSession().setAttribute("successMessage", "Check-out thành công!");
    } else {
        req.getSession().setAttribute("errorMessage", result.getErrorMessage());
    }
}
```

