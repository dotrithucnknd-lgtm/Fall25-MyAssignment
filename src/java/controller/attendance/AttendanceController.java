package controller.attendance;

import controller.iam.BaseRequiredAuthenticationController;
import dal.AttendanceDBContext;
import dal.AttendanceServiceDAO;
import dal.AttendanceServiceDAO.AttendanceResult;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import java.sql.SQLException;
import java.sql.Time;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import model.Attendance;
import model.Employee;
import model.RequestForLeave;
import model.iam.User;
import util.LogUtil;

/**
 * Controller để xử lý chấm công theo ngày nghỉ
 * @author System
 */
@WebServlet(urlPatterns = "/attendance/*")
public class AttendanceController extends BaseRequiredAuthenticationController {
    
    private AttendanceDBContext attendanceDB = new AttendanceDBContext();
    private RequestForLeaveDBContext requestDB = new RequestForLeaveDBContext();
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        
        if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("")) {
            // Hiển thị trang chấm công hàng ngày
            showDailyAttendance(req, resp, user);
        } else if (pathInfo.equals("/leave")) {
            // Hiển thị danh sách các đơn nghỉ phép đã được phê duyệt
            showLeaveRequests(req, resp, user);
        } else if (pathInfo.startsWith("/check/")) {
            // Hiển thị form chấm công cho một đơn nghỉ phép cụ thể
            showCheckInForm(req, resp, user);
        } else if (pathInfo.startsWith("/list/")) {
            // Hiển thị danh sách chấm công của một đơn nghỉ phép
            showAttendanceList(req, resp, user);
        } else if (pathInfo.equals("/history")) {
            // Hiển thị lịch sử chấm công hàng ngày
            showDailyAttendanceHistory(req, resp, user);
        } else {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND);
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        
        if (pathInfo != null && pathInfo.startsWith("/check/")) {
            // Xử lý chấm công cho đơn nghỉ phép
            processCheckIn(req, resp, user);
        } else if (pathInfo != null && pathInfo.equals("/daily")) {
            // Xử lý chấm công hàng ngày
            processDailyCheckIn(req, resp, user);
        } else {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        }
    }
    
    /**
     * Hiển thị danh sách các đơn nghỉ phép đã được phê duyệt
     */
    private void showLeaveRequests(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        ArrayList<RequestForLeave> approvedRequests = attendanceDB.getApprovedLeaveRequestsForAttendance(
            user.getEmployee().getId()
        );
        
        req.setAttribute("approvedRequests", approvedRequests);
        req.getRequestDispatcher("/view/attendance/list.jsp").forward(req, resp);
    }
    
    /**
     * Hiển thị form chấm công cho một đơn nghỉ phép
     */
    private void showCheckInForm(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String requestIdStr = req.getPathInfo().substring(7); // Bỏ qua "/check/"
        try {
            int requestId = Integer.parseInt(requestIdStr);
            RequestForLeave request = requestDB.get(requestId);
            
            if (request == null) {
                req.getSession().setAttribute("errorMessage", "Không tìm thấy đơn nghỉ phép.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Kiểm tra xem đơn có thuộc về nhân viên hiện tại không
            if (request.getCreated_by().getId() != user.getEmployee().getId()) {
                req.getSession().setAttribute("errorMessage", "Bạn không có quyền chấm công cho đơn này.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Kiểm tra xem đơn đã được phê duyệt chưa
            if (request.getStatus() != 1) {
                req.getSession().setAttribute("errorMessage", "Chỉ có thể chấm công cho các đơn đã được phê duyệt.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Lấy danh sách chấm công đã có cho đơn này
            ArrayList<Attendance> attendances = attendanceDB.getByRequestId(requestId);
            
            req.setAttribute("request", request);
            req.setAttribute("attendances", attendances);
            req.getRequestDispatcher("/view/attendance/check.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "ID đơn nghỉ phép không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/attendance/");
        }
    }
    
    /**
     * Hiển thị danh sách chấm công của một đơn nghỉ phép
     */
    private void showAttendanceList(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String requestIdStr = req.getPathInfo().substring(6); // Bỏ qua "/list/"
        try {
            int requestId = Integer.parseInt(requestIdStr);
            RequestForLeave request = requestDB.get(requestId);
            
            if (request == null) {
                req.getSession().setAttribute("errorMessage", "Không tìm thấy đơn nghỉ phép.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Kiểm tra quyền
            if (request.getCreated_by().getId() != user.getEmployee().getId()) {
                req.getSession().setAttribute("errorMessage", "Bạn không có quyền xem chấm công của đơn này.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            ArrayList<Attendance> attendances = attendanceDB.getByRequestId(requestId);
            
            req.setAttribute("request", request);
            req.setAttribute("attendances", attendances);
            req.getRequestDispatcher("/view/attendance/attendance_list.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "ID đơn nghỉ phép không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/attendance/");
        }
    }
    
    /**
     * Xử lý chấm công
     */
    private void processCheckIn(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String pathInfo = req.getPathInfo();
        if (pathInfo == null || pathInfo.length() <= 7) {
            req.getSession().setAttribute("errorMessage", "ID đơn nghỉ phép không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/attendance/");
            return;
        }
        String requestIdStr = pathInfo.substring(7); // Bỏ qua "/check/"
        int requestId = 0;
        try {
            requestId = Integer.parseInt(requestIdStr);
            RequestForLeave request = requestDB.get(requestId);
            
            if (request == null) {
                req.getSession().setAttribute("errorMessage", "Không tìm thấy đơn nghỉ phép.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Kiểm tra quyền
            if (request.getCreated_by().getId() != user.getEmployee().getId()) {
                req.getSession().setAttribute("errorMessage", "Bạn không có quyền chấm công cho đơn này.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Kiểm tra đơn đã được phê duyệt
            if (request.getStatus() != 1) {
                req.getSession().setAttribute("errorMessage", "Chỉ có thể chấm công cho các đơn đã được phê duyệt.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
                return;
            }
            
            // Lấy dữ liệu từ form
            String attendanceDateStr = req.getParameter("attendanceDate");
            String checkInTimeStr = req.getParameter("checkInTime");
            String checkOutTimeStr = req.getParameter("checkOutTime");
            String note = req.getParameter("note");
            
            if (attendanceDateStr == null || attendanceDateStr.trim().isEmpty()) {
                req.getSession().setAttribute("errorMessage", "Vui lòng chọn ngày chấm công.");
                resp.sendRedirect(req.getContextPath() + "/attendance/check/" + requestId);
                return;
            }
            
            Date attendanceDate = Date.valueOf(attendanceDateStr);
            
            // Kiểm tra ngày chấm công có nằm trong khoảng thời gian nghỉ không
            if (attendanceDate.before(request.getFrom()) || attendanceDate.after(request.getTo())) {
                req.getSession().setAttribute("errorMessage", 
                    "Ngày chấm công phải nằm trong khoảng thời gian nghỉ từ " + request.getFrom() + " đến " + request.getTo());
                resp.sendRedirect(req.getContextPath() + "/attendance/check/" + requestId);
                return;
            }
            
            // Sử dụng AttendanceServiceDAO để check-in cho đơn nghỉ phép
            AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();
            
            Time checkInTime = null;
            Time checkOutTime = null;
            
            if (checkInTimeStr != null && !checkInTimeStr.trim().isEmpty()) {
                checkInTime = Time.valueOf(checkInTimeStr + ":00");
            }
            
            if (checkOutTimeStr != null && !checkOutTimeStr.trim().isEmpty()) {
                checkOutTime = Time.valueOf(checkOutTimeStr + ":00");
            }
            
            AttendanceResult result = attendanceService.checkInForLeaveRequest(
                user.getEmployee().getId(),
                requestId,
                attendanceDate,
                checkInTime,
                checkOutTime,
                note
            );
            
            if (!result.isSuccess()) {
                req.getSession().setAttribute("errorMessage", result.getErrorMessage());
                resp.sendRedirect(req.getContextPath() + "/attendance/check/" + requestId);
                return;
            }
            
            // Ghi log
            LogUtil.logActivity(
                user,
                result.isIsNew() ? LogUtil.ActivityType.CHECK_IN_ATTENDANCE : LogUtil.ActivityType.UPDATE_ATTENDANCE,
                LogUtil.EntityType.REQUEST_FOR_LEAVE,
                requestId,
                (result.isIsNew() ? "Chấm công" : "Cập nhật chấm công") + " cho ngày nghỉ " + attendanceDate,
                null,
                String.format("{\"attendance_date\":\"%s\",\"check_in\":\"%s\",\"check_out\":\"%s\"}", 
                    attendanceDate, checkInTimeStr, checkOutTimeStr),
                req
            );
            
            req.getSession().setAttribute("successMessage", 
                result.isIsNew() ? "Chấm công thành công!" : "Cập nhật chấm công thành công!");
            resp.sendRedirect(req.getContextPath() + "/attendance/check/" + requestId);
            
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("errorMessage", "ID đơn nghỉ phép không hợp lệ.");
            resp.sendRedirect(req.getContextPath() + "/attendance/");
        } catch (IllegalArgumentException e) {
            // requestId đã được parse ở đầu try block, sử dụng nó
            if (requestId > 0) {
                req.getSession().setAttribute("errorMessage", "Định dạng ngày hoặc giờ không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/attendance/check/" + requestId); 
            } else {
                req.getSession().setAttribute("errorMessage", "Định dạng ngày hoặc giờ không hợp lệ.");
                resp.sendRedirect(req.getContextPath() + "/attendance/");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("errorMessage", "Có lỗi xảy ra: " + e.getMessage());
            resp.sendRedirect(req.getContextPath() + "/attendance/");
        }
    }
    
    /**
     * Hiển thị trang chấm công hàng ngày
     */
    private void showDailyAttendance(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Lấy chấm công hàng ngày hôm nay (chỉ lấy request_id IS NULL)
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        Attendance todayAttendance = attendanceDB.getDailyAttendanceByEmployeeIdAndDate(
            user.getEmployee().getId(), 
            today
        );
        
        req.setAttribute("todayAttendance", todayAttendance);
        req.setAttribute("today", today);
        req.getRequestDispatcher("/view/attendance/daily.jsp").forward(req, resp);
    }
    
    /**
     * Xử lý chấm công hàng ngày
     */
    private void processDailyCheckIn(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        String action = req.getParameter("action"); // "checkin" hoặc "checkout"
        java.sql.Date today = new java.sql.Date(System.currentTimeMillis());
        
        try {
            // Sử dụng AttendanceServiceDAO
            AttendanceServiceDAO attendanceService = new AttendanceServiceDAO();
            AttendanceResult result = null;
            
            if ("checkin".equals(action)) {
                // Check-in hàng ngày
                result = attendanceService.checkInDaily(
                    user.getEmployee().getId(),
                    today,
                    null, // Dùng thời gian hiện tại
                    null  // Không có note
                );
                
                if (result.isSuccess()) {
                    // Ghi log
                    LogUtil.logActivity(
                        user,
                        LogUtil.ActivityType.CHECK_IN_ATTENDANCE,
                        null,
                        null,
                        "Check-in hàng ngày " + today,
                        null,
                        String.format("{\"date\":\"%s\",\"check_in\":\"%s\"}", 
                            today, result.getAttendance().getCheckInTime()),
                        req
                    );
                    
                    req.getSession().setAttribute("successMessage", "Check-in thành công!");
                } else {
                    req.getSession().setAttribute("errorMessage", result.getErrorMessage());
                }
            } else if ("checkout".equals(action)) {
                // Check-out hàng ngày
                result = attendanceService.checkOutDaily(
                    user.getEmployee().getId(),
                    today,
                    null, // Dùng thời gian hiện tại
                    null  // Không có note
                );
                
                if (result.isSuccess()) {
                    // Ghi log
                    LogUtil.logActivity(
                        user,
                        LogUtil.ActivityType.UPDATE_ATTENDANCE,
                        null,
                        null,
                        "Check-out hàng ngày " + today,
                        null,
                        String.format("{\"date\":\"%s\",\"check_out\":\"%s\"}", 
                            today, result.getAttendance().getCheckOutTime()),
                        req
                    );
                    
                    req.getSession().setAttribute("successMessage", "Check-out thành công!");
                } else {
                    req.getSession().setAttribute("errorMessage", result.getErrorMessage());
                }
            } else {
                req.getSession().setAttribute("errorMessage", "Hành động không hợp lệ.");
            }
            
            resp.sendRedirect(req.getContextPath() + "/attendance/");
            
        } catch (Exception e) {
            // Log chi tiết lỗi
            java.util.logging.Logger.getLogger(AttendanceController.class.getName())
                .log(java.util.logging.Level.SEVERE, "Error in processDailyCheckIn", e);
            
            String errorMessage = "Có lỗi xảy ra: " + e.getMessage();
            if (e.getCause() instanceof SQLException) {
                errorMessage = "Lỗi database: " + e.getMessage() + ". Vui lòng kiểm tra log server hoặc liên hệ quản trị viên.";
            }
            
            req.getSession().setAttribute("errorMessage", errorMessage);
            resp.sendRedirect(req.getContextPath() + "/attendance/");
        }
    }
    
    /**
     * Hiển thị lịch sử chấm công hàng ngày
     */
    private void showDailyAttendanceHistory(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Lấy lịch sử chấm công hàng ngày (không có request_id)
        ArrayList<Attendance> attendances = attendanceDB.getDailyAttendanceByEmployeeId(
            user.getEmployee().getId()
        );
        
        req.setAttribute("attendances", attendances);
        req.getRequestDispatcher("/view/attendance/daily_history.jsp").forward(req, resp);
    }
}

