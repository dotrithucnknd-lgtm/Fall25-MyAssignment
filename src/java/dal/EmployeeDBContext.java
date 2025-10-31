package dal;

import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;

public class EmployeeDBContext extends DBContext<Employee> {

    public int insertAndReturnId(Employee e) {
        try {
            String sql = "INSERT INTO Employee(ename) VALUES (?)";
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setString(1, e.getName());
            stm.executeUpdate();
            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException ex) {
            Logger.getLogger(EmployeeDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return -1;
    }

    @Override
    public ArrayList<Employee> list() { return new ArrayList<>(); }
    
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
    
    @Override
    public void insert(Employee model) {}
    @Override
    public void update(Employee model) {}
    @Override
    public void delete(Employee model) {}
}



