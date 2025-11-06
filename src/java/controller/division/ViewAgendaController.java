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
        
        // Lấy danh sách đơn nghỉ phép của division (employee và subordinates) theo tháng
        ArrayList<RequestForLeave> agenda = new ArrayList<>();
        try {
            agenda = db.getDivisionAgendaByMonth(
                user.getEmployee().getId(), 
                year, 
                month
            );
        } catch (Exception e) {
            e.printStackTrace();
            // Nếu có lỗi, để danh sách rỗng
        }
        
        // Lấy danh sách nhân viên trong division
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
        
        // Tính toán số ngày trong tháng
        Calendar monthCal = Calendar.getInstance();
        monthCal.set(year, month - 1, 1);
        int daysInMonth = monthCal.getActualMaximum(Calendar.DAY_OF_MONTH);
        
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
        
        // Forward to JSP
        req.getRequestDispatcher("/view/division/agenda.jsp").forward(req, resp);
    }
    
}
