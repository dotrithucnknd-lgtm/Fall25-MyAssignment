/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.division;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import dal.EmployeeDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;
import java.sql.Date;
import model.RequestForLeave;
import model.Employee;
import model.iam.User;

/**
 * Controller để hiển thị lịch nghỉ phép của division
 * @author System
 */
@WebServlet(urlPatterns="/division/agenda")
public class ViewAgendaController extends BaseRequiredAuthorizationController {

    private RequestForLeaveDBContext db = new RequestForLeaveDBContext();

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        // Forward to GET for now
        processGet(req, resp, user);
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        // Lấy tháng và năm từ request (mặc định là tháng hiện tại)
        Calendar cal = Calendar.getInstance();
        int currentYear = cal.get(Calendar.YEAR);
        int currentMonth = cal.get(Calendar.MONTH) + 1; // Calendar.MONTH is 0-based
        
        String yearParam = req.getParameter("year");
        String monthParam = req.getParameter("month");
        
        int year = currentYear;
        int month = currentMonth;
        
        try {
            if (yearParam != null && !yearParam.trim().isEmpty()) {
                year = Integer.parseInt(yearParam);
            }
            if (monthParam != null && !monthParam.trim().isEmpty()) {
                month = Integer.parseInt(monthParam);
                // Validate month range
                if (month < 1 || month > 12) {
                    month = currentMonth;
                }
            }
        } catch (NumberFormatException e) {
            // Use default values if parsing fails
            year = currentYear;
            month = currentMonth;
        }
        
        // Kiểm tra user có employee không
        if (user.getEmployee() == null) {
            req.setAttribute("errorMessage", "Người dùng chưa được gán với nhân viên.");
            req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
            return;
        }
        
        // Lấy danh sách nhân viên trong division (cần lấy trước để dùng trong debug)
        ArrayList<Employee> employees = new ArrayList<>();
        try {
            EmployeeDBContext employeeDB = new EmployeeDBContext();
            employees = employeeDB.getDivisionEmployees(user.getEmployee().getId());
            if (employees == null) {
                employees = new ArrayList<>();
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, để danh sách rỗng
            employees = new ArrayList<>();
        }
        
        // Lấy danh sách đơn nghỉ phép của division (employee và subordinates) theo tháng
        ArrayList<RequestForLeave> agenda = new ArrayList<>();
        try {
            agenda = db.getDivisionAgendaByMonth(
                user.getEmployee().getId(), 
                year, 
                month
            );
            // Debug: Log số lượng đơn nghỉ phép
            System.out.println("DEBUG: Agenda loaded - Total requests: " + agenda.size());
            System.out.println("DEBUG: Year: " + year + ", Month: " + month);
            for (RequestForLeave r : agenda) {
                System.out.println("DEBUG: Request #" + r.getId() + 
                    " - Status: " + r.getStatus() + 
                    " - Employee ID: " + (r.getCreated_by() != null ? r.getCreated_by().getId() : "null") +
                    " - Employee Name: " + (r.getCreated_by() != null ? r.getCreated_by().getName() : "null") +
                    " - From: " + r.getFrom() + " - To: " + r.getTo());
            }
            System.out.println("DEBUG: Total employees in division: " + employees.size());
            for (Employee emp : employees) {
                System.out.println("DEBUG: Employee ID: " + emp.getId() + ", Name: " + emp.getName());
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, để danh sách rỗng
        }
        
        // Tính toán số ngày trong tháng
        Calendar monthCal = Calendar.getInstance();
        monthCal.set(year, month - 1, 1);
        int daysInMonth = monthCal.getActualMaximum(Calendar.DAY_OF_MONTH);
        
        // Tạo Map để đánh dấu các ngày nghỉ: key = "employeeId_date", value = true
        Map<String, Boolean> leaveDaysMap = new HashMap<>();
        for (RequestForLeave r : agenda) {
            if (r != null && r.getCreated_by() != null && r.getFrom() != null && r.getTo() != null) {
                int employeeId = r.getCreated_by().getId();
                Date fromDate = r.getFrom();
                Date toDate = r.getTo();
                
                // Tạo Calendar để iterate qua tất cả các ngày trong khoảng [fromDate, toDate]
                Calendar dateCal = Calendar.getInstance();
                dateCal.setTime(fromDate);
                
                Calendar endCal = Calendar.getInstance();
                endCal.setTime(toDate);
                
                // Thêm tất cả các ngày trong khoảng vào Map
                while (!dateCal.after(endCal)) {
                    int checkYear = dateCal.get(Calendar.YEAR);
                    int checkMonth = dateCal.get(Calendar.MONTH) + 1;
                    int checkDay = dateCal.get(Calendar.DAY_OF_MONTH);
                    
                    // Chỉ thêm nếu ngày này nằm trong tháng đang xem
                    if (checkYear == year && checkMonth == month) {
                        String key = employeeId + "_" + checkDay;
                        leaveDaysMap.put(key, true);
                    }
                    
                    // Tăng ngày lên 1
                    dateCal.add(Calendar.DAY_OF_MONTH, 1);
                }
            }
        }
        
        // Debug: Log Map
        System.out.println("DEBUG: Leave days map size: " + leaveDaysMap.size());
        for (Map.Entry<String, Boolean> entry : leaveDaysMap.entrySet()) {
            System.out.println("DEBUG: Leave day key: " + entry.getKey() + " = " + entry.getValue());
        }
        
        // Tính toán tháng trước và tháng sau để navigation
        Calendar prevCal = Calendar.getInstance();
        prevCal.set(year, month - 2, 1); // month - 2 because Calendar.MONTH is 0-based
        int prevYear = prevCal.get(Calendar.YEAR);
        int prevMonth = prevCal.get(Calendar.MONTH) + 1;
        
        Calendar nextCal = Calendar.getInstance();
        nextCal.set(year, month, 1); // month (0-based) means next month
        int nextYear = nextCal.get(Calendar.YEAR);
        int nextMonth = nextCal.get(Calendar.MONTH) + 1;
        
        // Set attributes for JSP
        req.setAttribute("agenda", agenda);
        req.setAttribute("employees", employees);
        req.setAttribute("daysInMonth", daysInMonth);
        req.setAttribute("year", year);
        req.setAttribute("month", month);
        req.setAttribute("prevYear", prevYear);
        req.setAttribute("prevMonth", prevMonth);
        req.setAttribute("nextYear", nextYear);
        req.setAttribute("nextMonth", nextMonth);
        req.setAttribute("leaveDaysMap", leaveDaysMap);
        
        // Forward to JSP
        req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
    }
    
}
