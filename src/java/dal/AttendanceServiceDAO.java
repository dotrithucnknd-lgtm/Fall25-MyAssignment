package dal;

import java.sql.Date;
import java.sql.Time;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Attendance;
import model.Employee;
import model.RequestForLeave;

/**
 * Service DAO để đơn giản hóa việc check-in/check-out
 * 
 * @author System
 */
public class AttendanceServiceDAO {
    
    private static final Logger logger = Logger.getLogger(AttendanceServiceDAO.class.getName());
    private AttendanceDBContext attendanceDB;
    
    public AttendanceServiceDAO() {
        this.attendanceDB = new AttendanceDBContext();
    }
    
    /**
     * Check-in hàng ngày (không liên kết với đơn nghỉ phép)
     * 
     * @param employeeId ID của nhân viên
     * @param attendanceDate Ngày chấm công
     * @param checkInTime Thời gian check-in (null để dùng thời gian hiện tại)
     * @param note Ghi chú (optional)
     * @return AttendanceResult chứa thông tin kết quả
     */
    public AttendanceResult checkInDaily(int employeeId, Date attendanceDate, Time checkInTime, String note) {
        AttendanceResult result = new AttendanceResult();
        
        try {
            // Validate input
            if (employeeId <= 0) {
                result.setSuccess(false);
                result.setErrorMessage("Employee ID không hợp lệ.");
                logger.warning("Validation failed: invalid employee ID");
                return result;
            }
            
            if (attendanceDate == null) {
                attendanceDate = new Date(System.currentTimeMillis());
            }
            
            // Lấy chấm công hàng ngày hôm nay (chỉ lấy request_id IS NULL)
            Attendance attendance = attendanceDB.getDailyAttendanceByEmployeeIdAndDate(employeeId, attendanceDate);
            boolean isNew = (attendance == null);
            
            if (attendance == null) {
                // Tạo mới
                attendance = new Attendance();
                Employee emp = new Employee();
                emp.setId(employeeId);
                attendance.setEmployee(emp);
                attendance.setAttendanceDate(attendanceDate);
                attendance.setRequestForLeave(null); // Không liên kết với đơn nghỉ phép
            }
            
            // Set thời gian check-in
            if (checkInTime == null) {
                checkInTime = new Time(System.currentTimeMillis());
            }
            attendance.setCheckInTime(checkInTime);
            
            if (note != null && !note.trim().isEmpty()) {
                attendance.setNote(note.trim());
            }
            
            // Lưu vào database
            if (isNew) {
                logger.info("Inserting new attendance for employee " + employeeId + " on " + attendanceDate);
                attendanceDB.insert(attendance);
                logger.info("Check-in created successfully for employee " + employeeId + " on " + attendanceDate + 
                    " with ID: " + attendance.getId());
            } else {
                logger.info("Updating existing attendance ID: " + attendance.getId() + 
                    " for employee " + employeeId + " on " + attendanceDate);
                attendanceDB.update(attendance);
                logger.info("Check-in updated successfully for employee " + employeeId + " on " + attendanceDate);
            }
            
            result.setSuccess(true);
            result.setAttendance(attendance);
            result.setIsNew(isNew);
            
        } catch (Exception e) {
            logger.severe("=== Check-in failed ===");
            logger.log(Level.SEVERE, "Error in check-in", e);
            e.printStackTrace();
            result.setSuccess(false);
            String errorMsg = "Có lỗi xảy ra: " + e.getMessage();
            if (e.getCause() != null) {
                errorMsg += " (Nguyên nhân: " + e.getCause().getMessage() + ")";
            }
            result.setErrorMessage(errorMsg);
        }
        
        return result;
    }
    
    /**
     * Check-out hàng ngày
     * 
     * @param employeeId ID của nhân viên
     * @param attendanceDate Ngày chấm công
     * @param checkOutTime Thời gian check-out (null để dùng thời gian hiện tại)
     * @param note Ghi chú (optional)
     * @return AttendanceResult chứa thông tin kết quả
     */
    public AttendanceResult checkOutDaily(int employeeId, Date attendanceDate, Time checkOutTime, String note) {
        AttendanceResult result = new AttendanceResult();
        
        try {
            // Validate input
            if (employeeId <= 0) {
                result.setSuccess(false);
                result.setErrorMessage("Employee ID không hợp lệ.");
                logger.warning("Validation failed: invalid employee ID");
                return result;
            }
            
            if (attendanceDate == null) {
                attendanceDate = new Date(System.currentTimeMillis());
            }
            
            // Lấy chấm công hàng ngày hôm nay (chỉ lấy request_id IS NULL)
            Attendance attendance = attendanceDB.getDailyAttendanceByEmployeeIdAndDate(employeeId, attendanceDate);
            
            if (attendance == null) {
                result.setSuccess(false);
                result.setErrorMessage("Bạn phải check-in trước khi check-out.");
                logger.warning("Check-out failed: no check-in found");
                return result;
            }
            
            if (attendance.getCheckInTime() == null) {
                result.setSuccess(false);
                result.setErrorMessage("Bạn phải check-in trước khi check-out.");
                logger.warning("Check-out failed: no check-in time");
                return result;
            }
            
            // Set thời gian check-out
            if (checkOutTime == null) {
                checkOutTime = new Time(System.currentTimeMillis());
            }
            attendance.setCheckOutTime(checkOutTime);
            
            if (note != null && !note.trim().isEmpty()) {
                attendance.setNote(note.trim());
            }
            
            // Cập nhật vào database
            logger.info("Updating attendance ID: " + attendance.getId() + 
                " for employee " + employeeId + " on " + attendanceDate);
            attendanceDB.update(attendance);
            logger.info("Check-out updated successfully for employee " + employeeId + " on " + attendanceDate);
            
            result.setSuccess(true);
            result.setAttendance(attendance);
            result.setIsNew(false);
            
        } catch (Exception e) {
            logger.severe("=== Check-out failed ===");
            logger.log(Level.SEVERE, "Error in check-out", e);
            e.printStackTrace();
            result.setSuccess(false);
            String errorMsg = "Có lỗi xảy ra: " + e.getMessage();
            if (e.getCause() != null) {
                errorMsg += " (Nguyên nhân: " + e.getCause().getMessage() + ")";
            }
            result.setErrorMessage(errorMsg);
        }
        
        return result;
    }
    
    /**
     * Check-in cho đơn nghỉ phép
     * 
     * @param employeeId ID của nhân viên
     * @param requestId ID của đơn nghỉ phép
     * @param attendanceDate Ngày chấm công
     * @param checkInTime Thời gian check-in (null để dùng thời gian hiện tại)
     * @param checkOutTime Thời gian check-out (optional)
     * @param note Ghi chú (optional)
     * @return AttendanceResult chứa thông tin kết quả
     */
    public AttendanceResult checkInForLeaveRequest(int employeeId, int requestId, Date attendanceDate, 
                                                   Time checkInTime, Time checkOutTime, String note) {
        AttendanceResult result = new AttendanceResult();
        
        try {
            // Validate input
            if (employeeId <= 0 || requestId <= 0) {
                result.setSuccess(false);
                result.setErrorMessage("Employee ID hoặc Request ID không hợp lệ.");
                logger.warning("Validation failed: invalid employee ID or request ID");
                return result;
            }
            
            if (attendanceDate == null) {
                result.setSuccess(false);
                result.setErrorMessage("Vui lòng chọn ngày chấm công.");
                logger.warning("Validation failed: attendance date is null");
                return result;
            }
            
            // Kiểm tra xem đã chấm công cho ngày này chưa
            Attendance existingAttendance = attendanceDB.getByRequestIdAndDate(requestId, attendanceDate);
            
            Attendance attendance;
            boolean isNew = false;
            
            if (existingAttendance != null) {
                // Cập nhật chấm công đã có
                attendance = existingAttendance;
                isNew = false;
            } else {
                // Tạo chấm công mới
                attendance = new Attendance();
                Employee emp = new Employee();
                emp.setId(employeeId);
                attendance.setEmployee(emp);
                
                RequestForLeave rfl = new RequestForLeave();
                rfl.setId(requestId);
                attendance.setRequestForLeave(rfl);
                
                attendance.setAttendanceDate(attendanceDate);
                isNew = true;
            }
            
            // Set thời gian check-in/check-out
            if (checkInTime != null) {
                attendance.setCheckInTime(checkInTime);
            }
            
            if (checkOutTime != null) {
                attendance.setCheckOutTime(checkOutTime);
            }
            
            if (note != null && !note.trim().isEmpty()) {
                attendance.setNote(note.trim());
            }
            
            // Lưu vào database
            if (isNew) {
                attendanceDB.insert(attendance);
                logger.info("Check-in created successfully for request " + requestId + " on " + attendanceDate);
            } else {
                attendanceDB.update(attendance);
                logger.info("Check-in updated successfully for request " + requestId + " on " + attendanceDate);
            }
            
            result.setSuccess(true);
            result.setAttendance(attendance);
            result.setIsNew(isNew);
            
        } catch (Exception e) {
            logger.severe("=== Check-in for leave request failed ===");
            logger.log(Level.SEVERE, "Error in check-in for leave request", e);
            result.setSuccess(false);
            result.setErrorMessage("Có lỗi xảy ra: " + e.getMessage());
        }
        
        return result;
    }
    
    /**
     * Class để chứa kết quả check-in/check-out
     */
    public static class AttendanceResult {
        private boolean success;
        private String errorMessage;
        private Attendance attendance;
        private boolean isNew;
        
        public boolean isSuccess() {
            return success;
        }
        
        public void setSuccess(boolean success) {
            this.success = success;
        }
        
        public String getErrorMessage() {
            return errorMessage;
        }
        
        public void setErrorMessage(String errorMessage) {
            this.errorMessage = errorMessage;
        }
        
        public Attendance getAttendance() {
            return attendance;
        }
        
        public void setAttendance(Attendance attendance) {
            this.attendance = attendance;
        }
        
        public boolean isIsNew() {
            return isNew;
        }
        
        public void setIsNew(boolean isNew) {
            this.isNew = isNew;
        }
    }
}

