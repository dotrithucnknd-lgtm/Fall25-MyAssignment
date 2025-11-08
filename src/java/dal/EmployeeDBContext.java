package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;
import model.Department;

public class EmployeeDBContext extends DBContext<Employee> {

    public int insertAndReturnId(Employee e) {
        PreparedStatement stm = null;
        ResultSet rs = null;
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
            // Kiểm tra xem có Division và Supervisor không
            if (e.getDept() != null && e.getDept().getId() > 0) {
                // Có Division, có thể có Supervisor
                String sql = "INSERT INTO Employee(ename, did, supervisorid) OUTPUT INSERTED.eid VALUES (?, ?, ?)";
                stm = connection.prepareStatement(sql);
                stm.setString(1, e.getName().trim());
                stm.setInt(2, e.getDept().getId());
                if (e.getSupervisor() != null && e.getSupervisor().getId() > 0) {
                    stm.setInt(3, e.getSupervisor().getId());
                } else {
                    stm.setNull(3, Types.INTEGER);
                }
            } else {
                // Không có Division, chỉ insert tên
                String sql = "INSERT INTO Employee(ename) OUTPUT INSERTED.eid VALUES (?)";
                stm = connection.prepareStatement(sql);
                stm.setString(1, e.getName().trim());
            }
            
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                "Executing INSERT for employee: " + e.getName());
            
            rs = stm.executeQuery();
            
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
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                "Error inserting employee: " + (e != null ? e.getName() : "null"), ex);
            ex.printStackTrace();
        } finally {
            // Đóng ResultSet và PreparedStatement trước
            try {
                if (rs != null) rs.close();
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, "Error closing ResultSet", ex);
            }
            try {
                if (stm != null) stm.close();
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, "Error closing PreparedStatement", ex);
            }
            // KHÔNG close connection ở đây vì có thể còn dùng cho enrollment và role assignment
            // closeConnection();
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
        PreparedStatement stm = null;
        ResultSet rs = null;
        try {
            // Đảm bảo connection được mở
            if (connection == null || connection.isClosed()) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                    "Connection is null or closed in getAllEmployees, attempting to reconnect");
                // Tạo connection mới
                try {
                    String user = "sa";
                    String pass = "123";
                    String url = "jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment_SonNT;encrypt=true;trustServerCertificate=true;";
                    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                    connection = DriverManager.getConnection(url, user, pass);
                } catch (Exception ex) {
                    Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                        "Failed to reconnect: " + ex.getMessage(), ex);
                    return employees;
                }
            }
            
            if (connection == null || connection.isClosed()) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                    "Connection is still null or closed after reconnect attempt");
                return employees;
            }
            
            String sql = "SELECT eid, ename FROM Employee ORDER BY ename ASC";
            stm = connection.prepareStatement(sql);
            rs = stm.executeQuery();
            
            while (rs.next()) {
                Employee emp = new Employee();
                emp.setId(rs.getInt("eid"));
                emp.setName(rs.getString("ename"));
                employees.add(emp);
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                "Error getting all employees: " + ex.getMessage(), ex);
            ex.printStackTrace();
        } finally {
            // Đóng ResultSet và PreparedStatement trước
            try {
                if (rs != null) rs.close();
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, "Error closing ResultSet", ex);
            }
            try {
                if (stm != null) stm.close();
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, "Error closing PreparedStatement", ex);
            }
            // KHÔNG close connection ở đây vì có thể còn dùng cho các method khác
            // closeConnection();
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
     * Lấy danh sách tất cả các Division
     */
    public ArrayList<Department> getAllDivisions() {
        ArrayList<Department> divisions = new ArrayList<>();
        PreparedStatement stm = null;
        ResultSet rs = null;
        try {
            // Đảm bảo connection được mở
            if (connection == null || connection.isClosed()) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                    "Connection is null or closed in getAllDivisions");
                // Tạo connection mới
                try {
                    String user = "sa";
                    String pass = "123";
                    String url = "jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment_SonNT;encrypt=true;trustServerCertificate=true;";
                    Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                    connection = DriverManager.getConnection(url, user, pass);
                } catch (Exception ex) {
                    Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                        "Failed to reconnect: " + ex.getMessage(), ex);
                    return divisions;
                }
            }
            
            if (connection == null || connection.isClosed()) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                    "Connection is still null or closed after reconnect attempt");
                return divisions;
            }
            
            String sql = "SELECT did, dname FROM [Division] ORDER BY did ASC";
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                "Executing query: " + sql);
            stm = connection.prepareStatement(sql);
            rs = stm.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                count++;
                Department dept = new Department();
                dept.setId(rs.getInt("did"));
                dept.setName(rs.getString("dname"));
                divisions.add(dept);
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                    "Found division: ID=" + dept.getId() + ", Name=" + dept.getName());
            }
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.INFO, 
                "Total divisions found: " + count);
            
            // Nếu không tìm thấy division nào, log warning
            if (count == 0) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, 
                    "WARNING: No divisions found in database! Please check if Division table has data.");
            }
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, 
                "Error in getAllDivisions: " + ex.getMessage(), ex);
            ex.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (stm != null) stm.close();
            } catch (SQLException ex) {
                Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.WARNING, "Error closing resources", ex);
            }
            // KHÔNG close connection ở đây vì có thể còn dùng cho các method khác
            // closeConnection();
        }
        return divisions;
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



