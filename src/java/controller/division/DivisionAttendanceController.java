/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.division;

import controller.iam.BaseRequiredAuthorizationController;
import dal.AttendanceDBContext;
import dal.EmployeeDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import model.Attendance;
import model.Employee;
import model.iam.User;

/**
 * Controller để IT Head xem chấm công của division (người dưới quyền)
 * @author System
 */
@WebServlet(urlPatterns="/division/attendance")
public class DivisionAttendanceController extends BaseRequiredAuthorizationController {

    private AttendanceDBContext attendanceDB = new AttendanceDBContext();
    private EmployeeDBContext employeeDB = new EmployeeDBContext();

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        // Forward to GET for now
        processGet(req, resp, user);
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        // Kiểm tra user có employee không
        if (user.getEmployee() == null) {
            req.setAttribute("errorMessage", "Người dùng chưa được gán với nhân viên.");
            req.getRequestDispatcher("/view/division/division_attendance.jsp").forward(req, resp);
            return;
        }
        
        // Lấy ngày từ request (mặc định là hôm nay)
        String dateParam = req.getParameter("date");
        Date attendanceDate = null;
        
        if (dateParam != null && !dateParam.trim().isEmpty()) {
            try {
                attendanceDate = Date.valueOf(dateParam);
            } catch (IllegalArgumentException e) {
                // Invalid date format, use today
                attendanceDate = new Date(System.currentTimeMillis());
            }
        } else {
            // Default to today
            attendanceDate = new Date(System.currentTimeMillis());
        }
        
        // Lấy danh sách chấm công của division
        ArrayList<Attendance> attendances = new ArrayList<>();
        try {
            attendances = attendanceDB.getDivisionAttendanceByDate(
                user.getEmployee().getId(), 
                attendanceDate
            );
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, để danh sách rỗng
        }
        
        // Lấy danh sách nhân viên trong division để hiển thị
        ArrayList<Employee> employees = new ArrayList<>();
        try {
            employees = employeeDB.getDivisionEmployees(user.getEmployee().getId());
            if (employees == null) {
                employees = new ArrayList<>();
            }
        } catch (Exception e) {
            e.printStackTrace();
            employees = new ArrayList<>();
        }
        
        // Tạo Map để đánh dấu chấm công: key = "employeeId", value = Attendance object
        // Chỉ đếm những nhân viên thực sự đã chấm công (có check-in hoặc check-out)
        Map<String, Attendance> attendanceMap = new HashMap<>();
        for (Attendance att : attendances) {
            if (att != null && att.getEmployee() != null) {
                // Chỉ thêm vào map nếu có check-in hoặc check-out
                if (att.getCheckInTime() != null || att.getCheckOutTime() != null) {
                    String key = String.valueOf(att.getEmployee().getId());
                    // Nếu chưa có attendance cho employee này, thêm vào
                    if (!attendanceMap.containsKey(key)) {
                        attendanceMap.put(key, att);
                    } else {
                        // Nếu đã có, ưu tiên bản ghi có cả check-in và check-out
                        Attendance existing = attendanceMap.get(key);
                        boolean existingHasBoth = existing.getCheckInTime() != null && existing.getCheckOutTime() != null;
                        boolean newHasBoth = att.getCheckInTime() != null && att.getCheckOutTime() != null;
                        
                        // Ưu tiên bản ghi có cả check-in và check-out
                        if (newHasBoth && !existingHasBoth) {
                            attendanceMap.put(key, att);
                        }
                        // Nếu cả hai đều có cả check-in và check-out, giữ bản ghi mới hơn (dựa trên created_at)
                        else if (newHasBoth && existingHasBoth) {
                            if (att.getCreatedAt() != null && existing.getCreatedAt() != null &&
                                att.getCreatedAt().after(existing.getCreatedAt())) {
                                attendanceMap.put(key, att);
                            }
                        }
                    }
                }
            }
        }
        
        // Debug: Log Map
        System.out.println("DEBUG: Attendance map size: " + attendanceMap.size());
        for (Map.Entry<String, Attendance> entry : attendanceMap.entrySet()) {
            System.out.println("DEBUG: Attendance key: " + entry.getKey() + 
                " - Employee: " + (entry.getValue().getEmployee() != null ? entry.getValue().getEmployee().getName() : "null") +
                " - Check-in: " + entry.getValue().getCheckInTime() +
                " - Check-out: " + entry.getValue().getCheckOutTime());
        }
        
        // Set attributes for JSP
        req.setAttribute("attendances", attendances);
        req.setAttribute("employees", employees);
        req.setAttribute("selectedDate", attendanceDate);
        req.setAttribute("attendanceMap", attendanceMap);
        
        // Forward to JSP
        req.getRequestDispatcher("/view/division/division_attendance.jsp").forward(req, resp);
    }
}

