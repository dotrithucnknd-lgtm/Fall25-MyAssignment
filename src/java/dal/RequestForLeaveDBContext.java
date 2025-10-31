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
                                    (?,?,?,?,?,0,NULL)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setInt(1, model.getCreated_by().getId());
            stm.setTimestamp(2, new Timestamp(System.currentTimeMillis()));
            stm.setDate(3, model.getFrom());
            stm.setDate(4, model.getTo());
            stm.setString(5, model.getReason());
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

}
