package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Attendance;
import model.Employee;
import model.RequestForLeave;

/**
 * DBContext cho bảng Attendance - Quản lý chấm công theo ngày nghỉ
 * @author System
 */
public class AttendanceDBContext extends DBContext<Attendance> {
    
    /**
     * Lấy danh sách chấm công của một employee
     */
    public ArrayList<Attendance> getByEmployeeId(int employeeId) {
        ArrayList<Attendance> attendances = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.employee_id = ?
                ORDER BY a.attendance_date DESC, a.created_at DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, employeeId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Attendance att = mapResultSetToAttendance(rs);
                attendances.add(att);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return attendances;
    }
    
    /**
     * Lấy danh sách chấm công theo request_id (đơn nghỉ phép)
     */
    public ArrayList<Attendance> getByRequestId(int requestId) {
        ArrayList<Attendance> attendances = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.request_id = ?
                ORDER BY a.attendance_date DESC, a.created_at DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, requestId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Attendance att = mapResultSetToAttendance(rs);
                attendances.add(att);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return attendances;
    }
    
    /**
     * Kiểm tra xem đã chấm công cho ngày và request cụ thể chưa
     */
    public Attendance getByRequestIdAndDate(int requestId, Date attendanceDate) {
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.request_id = ? AND a.attendance_date = ?
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, requestId);
            stm.setDate(2, attendanceDate);
            ResultSet rs = stm.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAttendance(rs);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }
    
    /**
     * Map ResultSet sang Attendance object
     */
    private Attendance mapResultSetToAttendance(ResultSet rs) throws SQLException {
        Attendance att = new Attendance();
        att.setId(rs.getInt("attendance_id"));
        
        Employee emp = new Employee();
        emp.setId(rs.getInt("employee_id"));
        emp.setName(rs.getString("ename"));
        att.setEmployee(emp);
        
        int requestId = rs.getInt("request_id");
        if (requestId > 0 && !rs.wasNull()) {
            RequestForLeave rfl = new RequestForLeave();
            rfl.setId(requestId);
            rfl.setFrom(rs.getDate("rfrom"));
            rfl.setTo(rs.getDate("rto"));
            rfl.setReason(rs.getString("reason"));
            att.setRequestForLeave(rfl);
        }
        
        att.setAttendanceDate(rs.getDate("attendance_date"));
        att.setCheckInTime(rs.getTime("check_in_time"));
        att.setCheckOutTime(rs.getTime("check_out_time"));
        att.setNote(rs.getString("note"));
        att.setCreatedAt(rs.getTimestamp("created_at"));
        
        return att;
    }
    
    @Override
    public ArrayList<Attendance> list() {
        ArrayList<Attendance> attendances = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                ORDER BY a.attendance_date DESC, a.created_at DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Attendance att = mapResultSetToAttendance(rs);
                attendances.add(att);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return attendances;
    }
    
    @Override
    public Attendance get(int id) {
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.attendance_id = ?
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAttendance(rs);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }
    
    @Override
    public void insert(Attendance model) {
        // Note: Method signature cannot be changed due to interface, so we handle SQLException internally
        try {
            String sql = """
                INSERT INTO Attendance 
                    (employee_id, request_id, attendance_date, check_in_time, check_out_time, note, created_at)
                VALUES (?, ?, ?, ?, ?, ?, GETDATE())
                """;
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setInt(1, model.getEmployee().getId());
            
            if (model.getRequestForLeave() != null) {
                stm.setInt(2, model.getRequestForLeave().getId());
            } else {
                stm.setNull(2, Types.INTEGER);
            }
            
            stm.setDate(3, model.getAttendanceDate());
            
            if (model.getCheckInTime() != null) {
                stm.setTime(4, model.getCheckInTime());
            } else {
                stm.setNull(4, Types.TIME);
            }
            
            if (model.getCheckOutTime() != null) {
                stm.setTime(5, model.getCheckOutTime());
            } else {
                stm.setNull(5, Types.TIME);
            }
            
            if (model.getNote() != null && !model.getNote().trim().isEmpty()) {
                stm.setString(6, model.getNote());
            } else {
                stm.setNull(6, Types.NVARCHAR);
            }
            
            int rowsAffected = stm.executeUpdate();
            
            if (rowsAffected > 0) {
                // Lấy generated ID
                ResultSet rs = stm.getGeneratedKeys();
                if (rs.next()) {
                    model.setId(rs.getInt(1));
                    Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.INFO, 
                        "Successfully inserted attendance with ID: " + model.getId());
                }
            } else {
                Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.WARNING, 
                    "No rows affected when inserting attendance");
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, 
                "Error inserting attendance: " + ex.getMessage(), ex);
            // Cannot throw SQLException due to interface constraint, but log it
        } finally {
            closeConnection();
        }
    }
    
    @Override
    public void update(Attendance model) {
        try {
            String sql = """
                UPDATE Attendance 
                SET check_in_time = ?, check_out_time = ?, note = ?
                WHERE attendance_id = ?
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            
            if (model.getCheckInTime() != null) {
                stm.setTime(1, model.getCheckInTime());
            } else {
                stm.setNull(1, Types.TIME);
            }
            
            if (model.getCheckOutTime() != null) {
                stm.setTime(2, model.getCheckOutTime());
            } else {
                stm.setNull(2, Types.TIME);
            }
            
            if (model.getNote() != null && !model.getNote().trim().isEmpty()) {
                stm.setString(3, model.getNote());
            } else {
                stm.setNull(3, Types.NVARCHAR);
            }
            
            stm.setInt(4, model.getId());
            int rowsAffected = stm.executeUpdate();
            
            if (rowsAffected > 0) {
                Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.INFO, 
                    "Successfully updated attendance with ID: " + model.getId());
            } else {
                Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.WARNING, 
                    "No rows affected when updating attendance ID: " + model.getId());
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, 
                "Error updating attendance: " + ex.getMessage(), ex);
            // Cannot throw SQLException due to interface constraint, but log it
        } finally {
            closeConnection();
        }
    }
    
    @Override
    public void delete(Attendance model) {
        try {
            String sql = "DELETE FROM Attendance WHERE attendance_id = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, model.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }
    
    /**
     * Lấy danh sách các đơn nghỉ phép đã được phê duyệt mà employee có thể chấm công
     */
    public ArrayList<RequestForLeave> getApprovedLeaveRequestsForAttendance(int employeeId) {
        ArrayList<RequestForLeave> requests = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    r.rid,
                    r.created_by,
                    r.created_time,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason,
                    r.status,
                    r.processed_by,
                    e.eid,
                    e.ename
                FROM RequestForLeave r
                INNER JOIN Employee e ON r.created_by = e.eid
                WHERE r.created_by = ? 
                  AND r.status = 1
                  AND r.[from] <= CAST(GETDATE() AS DATE)
                ORDER BY r.[from] DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, employeeId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                RequestForLeave rfl = new RequestForLeave();
                rfl.setId(rs.getInt("rid"));
                rfl.setCreated_time(rs.getTimestamp("created_time"));
                rfl.setFrom(rs.getDate("rfrom"));
                rfl.setTo(rs.getDate("rto"));
                rfl.setReason(rs.getString("reason"));
                rfl.setStatus(rs.getInt("status"));
                
                Employee emp = new Employee();
                emp.setId(rs.getInt("eid"));
                emp.setName(rs.getString("ename"));
                rfl.setCreated_by(emp);
                
                requests.add(rfl);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return requests;
    }
    
    /**
     * Lấy chấm công của một employee cho một ngày cụ thể (không cần request_id)
     */
    public Attendance getByEmployeeIdAndDate(int employeeId, Date attendanceDate) {
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.employee_id = ? AND a.attendance_date = ?
                ORDER BY a.created_at DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, employeeId);
            stm.setDate(2, attendanceDate);
            ResultSet rs = stm.executeQuery();
            
            if (rs.next()) {
                return mapResultSetToAttendance(rs);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }
    
    /**
     * Lấy danh sách chấm công hàng ngày của một employee (không có request_id)
     */
    public ArrayList<Attendance> getDailyAttendanceByEmployeeId(int employeeId) {
        ArrayList<Attendance> attendances = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    a.attendance_id,
                    a.employee_id,
                    a.request_id,
                    a.attendance_date,
                    a.check_in_time,
                    a.check_out_time,
                    a.note,
                    a.created_at,
                    e.eid,
                    e.ename,
                    r.rid,
                    r.[from] as rfrom,
                    r.[to] as rto,
                    r.reason
                FROM Attendance a
                INNER JOIN Employee e ON a.employee_id = e.eid
                LEFT JOIN RequestForLeave r ON a.request_id = r.rid
                WHERE a.employee_id = ? AND a.request_id IS NULL
                ORDER BY a.attendance_date DESC, a.created_at DESC
                """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, employeeId);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Attendance att = mapResultSetToAttendance(rs);
                attendances.add(att);
            }
        } catch (SQLException ex) {
            Logger.getLogger(AttendanceDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return attendances;
    }
}

