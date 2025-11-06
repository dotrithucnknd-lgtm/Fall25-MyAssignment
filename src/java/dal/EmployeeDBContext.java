package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;

public class EmployeeDBContext extends DBContext<Employee> {

    public int insertAndReturnId(Employee e) {
        try {
            if (connection == null) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, "Database connection is null");
                return -1;
            }
            try {
                if (connection.isClosed()) {
                    Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, "Database connection is closed");
                    return -1;
                }
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, "Error checking connection status", ex);
                return -1;
            }
            
            if (e == null || e.getName() == null || e.getName().isBlank()) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, "Employee or employee name is null or blank");
                return -1;
            }
            
            // Sử dụng OUTPUT INSERTED để lấy EID vừa tạo (cách này đáng tin cậy hơn với SQL Server)
            String sql = "INSERT INTO Employee(ename) OUTPUT INSERTED.eid VALUES (?)";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, e.getName());
            
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                "Executing INSERT for employee: " + e.getName());
            
            ResultSet rs = stm.executeQuery();
            
            if (rs != null && rs.next()) {
                int eid = rs.getInt(1);
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                    "Got EID from OUTPUT: " + eid);
                
                if (eid > 0) {
                    Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                        "Successfully created employee with EID: " + eid + ", name: " + e.getName());
                    return eid;
                } else {
                    Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                        "Got EID but it's <= 0 for employee: " + e.getName());
                }
            } else {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                    "Failed to get EID from OUTPUT clause for employee: " + e.getName() + 
                    " - ResultSet is null or empty");
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, "Error inserting employee: " + (e != null ? e.getName() : "null"), ex);
        } finally {
            closeConnection();
        }
        return -1;
    }

    @Override
    public ArrayList<Employee> list() { 
        return getAllEmployees();
    }
    
    /**
     * Lấy danh sách tất cả employees
     */
    public ArrayList<Employee> getAllEmployees() {
        ArrayList<Employee> employees = new ArrayList<>();
        try {
            String sql = "SELECT eid, ename FROM Employee ORDER BY ename ASC";
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setId(rs.getInt("eid"));
                emp.setName(rs.getString("ename"));
                employees.add(emp);
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return employees;
    }
    
    @Override
    public Employee get(int id) {
        try {
            String sql = "SELECT eid, ename FROM Employee WHERE eid = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                Employee emp = new Employee();
                emp.setId(rs.getInt("eid"));
                emp.setName(rs.getString("ename"));
                return emp;
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }
    
    /**
     * Lấy danh sách nhân viên trong division (bao gồm supervisor và subordinates)
     */
    public ArrayList<Employee> getDivisionEmployees(int eid) {
        ArrayList<Employee> employees = new ArrayList<>();
        try {
            String sql = """
                WITH Org AS (
                    -- get current employee - eid = @eid
                    SELECT *, 0 as lvl FROM Employee e WHERE e.eid = ?
                    
                    UNION ALL
                    -- expand to other subordinates
                    SELECT c.*,o.lvl + 1 as lvl FROM Employee c JOIN Org o ON c.supervisorid = o.eid
                )
                SELECT DISTINCT e.eid, e.ename
                FROM Org e
                ORDER BY e.ename ASC
            """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, eid);
            ResultSet rs = stm.executeQuery();
            
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setId(rs.getInt("eid"));
                emp.setName(rs.getString("ename"));
                employees.add(emp);
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return employees;
    }
    
    @Override
    public void insert(Employee model) {}
    @Override
    public void update(Employee model) {}
    @Override
    public void delete(Employee model) {}
}



