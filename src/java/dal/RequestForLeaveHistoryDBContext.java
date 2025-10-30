/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;
import model.RequestForLeaveHistory;

public class RequestForLeaveHistoryDBContext extends DBContext<RequestForLeaveHistory> {

    public ArrayList<RequestForLeaveHistory> listByRequestId(int rid) {
        ArrayList<RequestForLeaveHistory> logs = new ArrayList<>();
        try {
            String sql = """
                                SELECT id, rid, old_status, new_status, processed_by, processed_time, note,
                                       e.ename as processed_name
                                FROM RequestForLeaveHistory h
                                LEFT JOIN Employee e ON e.eid = h.processed_by
                                WHERE rid = ?
                                ORDER BY processed_time DESC, id DESC
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, rid);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                RequestForLeaveHistory h = new RequestForLeaveHistory();
                h.setId(rs.getInt("id"));
                h.setRequestId(rs.getInt("rid"));
                h.setOldStatus(rs.getInt("old_status"));
                h.setNewStatus(rs.getInt("new_status"));
                h.setProcessedTime(rs.getTimestamp("processed_time"));
                h.setNote(rs.getString("note"));
                int approverId = rs.getInt("processed_by");
                if (approverId != 0) {
                    Employee e = new Employee();
                    e.setId(approverId);
                    e.setName(rs.getString("processed_name"));
                    h.setProcessedBy(e);
                }
                logs.add(h);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveHistoryDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return logs;
    }

    private void insertLog(RequestForLeaveHistory h) {
        try {
            String sql = """
                                INSERT INTO RequestForLeaveHistory
                                    (rid, old_status, new_status, processed_by, processed_time, note)
                                VALUES
                                    (?,?,?,?,?,?)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, h.getRequestId());
            stm.setInt(2, h.getOldStatus());
            stm.setInt(3, h.getNewStatus());
            stm.setInt(4, h.getProcessedBy() != null ? h.getProcessedBy().getId() : 0);
            stm.setTimestamp(5, h.getProcessedTime());
            stm.setString(6, h.getNote());
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(RequestForLeaveHistoryDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }

    @Override
    public ArrayList<RequestForLeaveHistory> list() { return new ArrayList<>(); }
    @Override
    public RequestForLeaveHistory get(int id) { return null; }
    @Override
    public void insert(RequestForLeaveHistory model) { insertLog(model); }
    @Override
    public void update(RequestForLeaveHistory model) {}
    @Override
    public void delete(RequestForLeaveHistory model) {}
}

