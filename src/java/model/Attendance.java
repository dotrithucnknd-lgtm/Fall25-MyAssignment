package model;

import java.sql.Date;
import java.sql.Time;

/**
 * Model cho bảng Attendance - Quản lý chấm công theo ngày nghỉ
 * @author System
 */
public class Attendance extends BaseModel {
    private Employee employee;
    private RequestForLeave requestForLeave; // Liên kết với đơn nghỉ phép
    private Date attendanceDate; // Ngày chấm công
    private Time checkInTime; // Thời gian check-in
    private Time checkOutTime; // Thời gian check-out
    private String note; // Ghi chú
    private java.sql.Timestamp createdAt; // Thời gian tạo bản ghi
    
    public Attendance() {
    }
    
    public Employee getEmployee() {
        return employee;
    }
    
    public void setEmployee(Employee employee) {
        this.employee = employee;
    }
    
    public RequestForLeave getRequestForLeave() {
        return requestForLeave;
    }
    
    public void setRequestForLeave(RequestForLeave requestForLeave) {
        this.requestForLeave = requestForLeave;
    }
    
    public Date getAttendanceDate() {
        return attendanceDate;
    }
    
    public void setAttendanceDate(Date attendanceDate) {
        this.attendanceDate = attendanceDate;
    }
    
    public Time getCheckInTime() {
        return checkInTime;
    }
    
    public void setCheckInTime(Time checkInTime) {
        this.checkInTime = checkInTime;
    }
    
    public Time getCheckOutTime() {
        return checkOutTime;
    }
    
    public void setCheckOutTime(Time checkOutTime) {
        this.checkOutTime = checkOutTime;
    }
    
    public String getNote() {
        return note;
    }
    
    public void setNote(String note) {
        this.note = note;
    }
    
    public java.sql.Timestamp getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(java.sql.Timestamp createdAt) {
        this.createdAt = createdAt;
    }
}


