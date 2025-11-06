/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.ArrayList;
import model.RequestForLeave;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;

/**
 *
 * @author sonnt
 */
public class RequestForLeaveDBContext extends DBContext<RequestForLeave> {

    public ArrayList<RequestForLeave> getByEmployeeAndSubodiaries(int eid) {
        ArrayList<RequestForLeave> rfls = new ArrayList<>();
        try {
            String sql = """
                                     WITH Org AS (
                                     \t-- get current employee - eid = @eid
                                     \tSELECT *, 0 as lvl FROM Employee e WHERE e.eid = ?
                                     \t
                                     \tUNION ALL
                                     \t-- expand to other subodinaries
                                     \tSELECT c.*,o.lvl + 1 as lvl FROM Employee c JOIN Org o ON c.supervisorid = o.eid
                                     )
                                     SELECT
                                     \t\t[rid]
                                     \t  ,[created_by]
                                     \t  ,e.ename as [created_name]
                                           ,[created_time]
                                           ,[from]
                                           ,[to]
                                           ,[reason]
                                           ,[status]
                                           ,[processed_by]
                                     \t  ,p.ename as [processed_name]
                                     FROM Org e INNER JOIN [RequestForLeave] r ON e.eid = r.created_by
                                     \t\t\tLEFT JOIN Employee p ON p.eid = r.processed_by""";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, eid);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                RequestForLeave rfl = new RequestForLeave();
                rfl.setId(rs.getInt("rid"));
                
                rfl.setCreated_time(rs.getTimestamp("created_time"));
                rfl.setFrom(rs.getDate("from"));
                rfl.setTo(rs.getDate("to"));
                rfl.setReason(rs.getString("reason"));
                rfl.setStatus(rs.getInt("status"));
                
                Employee created_by = new Employee();
                created_by.setId(rs.getInt("created_by"));
                created_by.setName(rs.getString("created_name"));
                rfl.setCreated_by(created_by);
                
                int processed_by_id = rs.getInt("processed_by");
                if(processed_by_id!=0)
                {
                    Employee processed_by = new Employee();
                    processed_by.setId(rs.getInt("processed_by"));
                    processed_by.setName(rs.getString("processed_name"));
                    rfl.setProcessed_by(processed_by);
                }
                
                rfls.add(rfl);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        finally
        {
            closeConnection();
        }
        return rfls;
    }

    public ArrayList<RequestForLeave> getByEmployeeAndSubodiariesWithSearch(int eid, String searchTerm) {
        ArrayList<RequestForLeave> rfls = new ArrayList<>();
        try {
            String sql = """
                                     WITH Org AS (
                                     \t-- get current employee - eid = @eid
                                     \tSELECT *, 0 as lvl FROM Employee e WHERE e.eid = ?
                                     \t
                                     \tUNION ALL
                                     \t-- expand to other subodinaries
                                     \tSELECT c.*,o.lvl + 1 as lvl FROM Employee c JOIN Org o ON c.supervisorid = o.eid
                                     )
                                     SELECT
                                     \t\t[rid]
                                     \t  ,[created_by]
                                     \t  ,e.ename as [created_name]
                                           ,[created_time]
                                           ,[from]
                                           ,[to]
                                           ,[reason]
                                           ,[status]
                                           ,[processed_by]
                                     \t  ,p.ename as [processed_name]
                                     FROM Org e INNER JOIN [RequestForLeave] r ON e.eid = r.created_by
                                     \t\t\tLEFT JOIN Employee p ON p.eid = r.processed_by
                                     WHERE e.ename LIKE ? OR r.reason LIKE ?
                                     """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, eid);
            String searchPattern = "%" + searchTerm + "%";
            stm.setString(2, searchPattern);
            stm.setString(3, searchPattern);
            ResultSet rs = stm.executeQuery();
            while(rs.next())
            {
                RequestForLeave rfl = new RequestForLeave();
                rfl.setId(rs.getInt("rid"));
                
                rfl.setCreated_time(rs.getTimestamp("created_time"));
                rfl.setFrom(rs.getDate("from"));
                rfl.setTo(rs.getDate("to"));
                rfl.setReason(rs.getString("reason"));
                rfl.setStatus(rs.getInt("status"));
                
                Employee created_by = new Employee();
                created_by.setId(rs.getInt("created_by"));
                created_by.setName(rs.getString("created_name"));
                rfl.setCreated_by(created_by);
                
                int processed_by_id = rs.getInt("processed_by");
                if(processed_by_id!=0)
                {
                    Employee processed_by = new Employee();
                    processed_by.setId(rs.getInt("processed_by"));
                    processed_by.setName(rs.getString("processed_name"));
                    rfl.setProcessed_by(processed_by);
                }
                
                rfls.add(rfl);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        finally
        {
            closeConnection();
        }
        return rfls;
    }

    @Override
    public ArrayList<RequestForLeave> list() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public RequestForLeave get(int id) {
        try {
            String sql = """
                                SELECT rid, created_by, created_time, [from], [to], reason, status, processed_by
                                FROM RequestForLeave
                                WHERE rid = ?
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                RequestForLeave r = new RequestForLeave();
                r.setId(rs.getInt("rid"));
                r.setCreated_time(rs.getTimestamp("created_time"));
                r.setFrom(rs.getDate("from"));
                r.setTo(rs.getDate("to"));
                r.setReason(rs.getString("reason"));
                r.setStatus(rs.getInt("status"));
                Employee creator = new Employee();
                creator.setId(rs.getInt("created_by"));
                r.setCreated_by(creator);
                int pb = rs.getInt("processed_by");
                if (pb != 0) {
                    Employee approver = new Employee();
                    approver.setId(pb);
                    r.setProcessed_by(approver);
                }
                return r;
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }

    @Override
    public void insert(RequestForLeave model) {
        try {
            String sql = """
                                INSERT INTO [RequestForLeave]
                                    ([created_by],[created_time],[from],[to],[reason],[status],[processed_by])
                                VALUES
                                    (?,?,?,?,?,0,NULL)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setInt(1, model.getCreated_by().getId());
            stm.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stm.setDate(3, model.getFrom());
            stm.setDate(4, model.getTo());
            stm.setString(5, model.getReason());
            stm.executeUpdate();
            
            // Lấy generated ID và set vào model
            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                model.setId(rs.getInt(1));
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }
    
    /**
     * Insert và return ID của request vừa tạo
     */
    public int insertAndReturnId(RequestForLeave model) {
        try {
            String sql = """
                                INSERT INTO [RequestForLeave]
                                    ([created_by],[created_time],[from],[to],[reason],[status],[processed_by])
                                VALUES
                                    (?,?,?,?,?,?,?)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setInt(1, model.getCreated_by().getId());
            stm.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stm.setDate(3, model.getFrom());
            stm.setDate(4, model.getTo());
            stm.setString(5, model.getReason());
            
            // Sử dụng status và processed_by từ model (có thể được set từ controller)
            int status = model.getStatus();
            stm.setInt(6, status);
            
            if (model.getProcessed_by() != null) {
                stm.setInt(7, model.getProcessed_by().getId());
            } else {
                stm.setNull(7, java.sql.Types.INTEGER);
            }
            
            stm.executeUpdate();
            
            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) {
                int id = rs.getInt(1);
                model.setId(id);
                return id;
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return -1;
    }

    @Override
    public void update(RequestForLeave model) {
        try {
            String sql = """
                                UPDATE [RequestForLeave]
                                SET [status] = ?, [processed_by] = ?
                                WHERE [rid] = ?
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, model.getStatus());
            if (model.getProcessed_by() != null) {
                stm.setInt(2, model.getProcessed_by().getId());
            } else {
                stm.setNull(2, java.sql.Types.INTEGER);
            }
            stm.setInt(3, model.getId());
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }

    @Override
    public void delete(RequestForLeave model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    
    /**
     * Đếm số lần nghỉ của một employee trong tháng hiện tại (chỉ đếm các request đã được duyệt - status = 1)
     * @param eid Employee ID
     * @return Số lần nghỉ trong tháng hiện tại
     */
    public int countApprovedLeaveRequestsThisMonth(int eid) {
        try {
            String sql = """
                SELECT COUNT(*) as count
                FROM [RequestForLeave]
                WHERE [created_by] = ?
                  AND [status] = 1
                  AND YEAR([from]) = YEAR(GETDATE())
                  AND MONTH([from]) = MONTH(GETDATE())
            """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, eid);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return 0;
    }
    
    /**
     * DTO để chứa thống kê số lần nghỉ của từng employee
     */
    public static class EmployeeLeaveStatistics {
        private int employeeId;
        private String employeeName;
        private int leaveCount;
        
        public int getEmployeeId() { return employeeId; }
        public void setEmployeeId(int employeeId) { this.employeeId = employeeId; }
        
        public String getEmployeeName() { return employeeName; }
        public void setEmployeeName(String employeeName) { this.employeeName = employeeName; }
        
        public int getLeaveCount() { return leaveCount; }
        public void setLeaveCount(int leaveCount) { this.leaveCount = leaveCount; }
    }
    
    /**
     * Lấy thống kê số lần nghỉ của tất cả employees trong tháng hiện tại
     * @return Danh sách thống kê
     */
    public ArrayList<EmployeeLeaveStatistics> getAllEmployeesLeaveStatisticsThisMonth() {
        ArrayList<EmployeeLeaveStatistics> stats = new ArrayList<>();
        try {
            String sql = """
                SELECT 
                    e.eid,
                    e.ename,
                    COUNT(r.rid) as leave_count
                FROM [Employee] e
                LEFT JOIN [RequestForLeave] r 
                    ON r.[created_by] = e.eid 
                    AND r.[status] = 1
                    AND YEAR(r.[from]) = YEAR(GETDATE())
                    AND MONTH(r.[from]) = MONTH(GETDATE())
                GROUP BY e.eid, e.ename
                ORDER BY leave_count DESC, e.ename ASC
            """;
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                EmployeeLeaveStatistics stat = new EmployeeLeaveStatistics();
                stat.setEmployeeId(rs.getInt("eid"));
                stat.setEmployeeName(rs.getString("ename"));
                stat.setLeaveCount(rs.getInt("leave_count"));
                stats.add(stat);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return stats;
    }
    
    /**
     * Lấy danh sách đơn nghỉ phép của division (employee và subordinates) theo tháng
     * @param eid Employee ID (supervisor)
     * @param year Năm
     * @param month Tháng (1-12)
     * @return Danh sách đơn nghỉ phép
     */
    public ArrayList<RequestForLeave> getDivisionAgendaByMonth(int eid, int year, int month) {
        ArrayList<RequestForLeave> rfls = new ArrayList<>();
        try {
            String sql = """
                WITH Org AS (
                    -- get current employee - eid = @eid
                    SELECT *, 0 as lvl FROM Employee e WHERE e.eid = ?
                    
                    UNION ALL
                    -- expand to other subordinates
                    SELECT c.*,o.lvl + 1 as lvl FROM Employee c JOIN Org o ON c.supervisorid = o.eid
                )
                SELECT
                    r.[rid],
                    r.[created_by],
                    e.ename as [created_name],
                    r.[created_time],
                    r.[from],
                    r.[to],
                    r.[reason],
                    r.[status],
                    r.[processed_by],
                    p.ename as [processed_name]
                FROM Org e 
                INNER JOIN [RequestForLeave] r ON e.eid = r.created_by
                LEFT JOIN Employee p ON p.eid = r.processed_by
                WHERE YEAR(r.[from]) = ? AND MONTH(r.[from]) = ?
                ORDER BY r.[from] ASC, e.ename ASC
            """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, eid);
            stm.setInt(2, year);
            stm.setInt(3, month);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                RequestForLeave rfl = new RequestForLeave();
                rfl.setId(rs.getInt("rid"));
                
                rfl.setCreated_time(rs.getTimestamp("created_time"));
                rfl.setFrom(rs.getDate("from"));
                rfl.setTo(rs.getDate("to"));
                rfl.setReason(rs.getString("reason"));
                rfl.setStatus(rs.getInt("status"));
                
                Employee created_by = new Employee();
                created_by.setId(rs.getInt("created_by"));
                created_by.setName(rs.getString("created_name"));
                rfl.setCreated_by(created_by);
                
                int processed_by_id = rs.getInt("processed_by");
                if (processed_by_id != 0) {
                    Employee processed_by = new Employee();
                    processed_by.setId(rs.getInt("processed_by"));
                    processed_by.setName(rs.getString("processed_name"));
                    rfl.setProcessed_by(processed_by);
                }
                
                rfls.add(rfl);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return rfls;
    }

}
