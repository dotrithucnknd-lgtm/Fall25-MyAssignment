/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.ArrayList;
import model.iam.User;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.Employee;

/**
 *
 * @author admin
 */
public class UserDBContext extends DBContext<User> {
    
    public User get(String username, String password){
        try {
            String sql = """
                                     SELECT
                                     u.uid,
                                     u.username,
                                     u.displayname,
                                     e.eid,
                                     e.ename
                                     FROM [User] u INNER JOIN [Enrollment] en ON u.[uid] = en.[uid]
                                     					   INNER JOIN [Employee] e ON e.eid = en.eid
                                     					   WHERE
                                     					   u.username = ? AND u.[password] = ?
                                     					   AND en.active = 1
                                                      """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            stm.setString(2, password);
            ResultSet rs = stm.executeQuery();
            while(rs.next()){
                User u = new User();
                Employee e = new Employee();
                e.setId(rs.getInt("eid"));
                e.setName(rs.getString("ename"));
                u.setEmployee(e);
                
                u.setUsername(username);
                u.setId(rs.getInt("uid"));
                u.setDisplayname(rs.getString("displayname"));
                
                return u;
                
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        finally{
            closeConnection();
        }
        return null;
    }

    public ArrayList<User> listAll() {
        ArrayList<User> users = new ArrayList<>();
        try {
            String sql = """
                                SELECT u.uid, u.username, u.displayname,
                                       CASE WHEN EXISTS (SELECT 1 FROM Enrollment en WHERE en.uid = u.uid AND en.active = 1) THEN 1 ELSE 0 END as active
                                FROM [User] u
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            ResultSet rs = stm.executeQuery();
            while (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("uid"));
                u.setUsername(rs.getString("username"));
                u.setDisplayname(rs.getString("displayname"));
                // reuse password field to carry active flag if needed? skip; UI will not use it
                users.add(u);
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return users;
    }

    public Integer findUserIdByUsername(String username) {
        try {
            String sql = "SELECT uid FROM [User] WHERE username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) return rs.getInt("uid");
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }

    public void createOrActivateEnrollment(int uid, int eid) {
        try {
            String sql = """
                                MERGE Enrollment AS target
                                USING (SELECT ? AS uid, ? AS eid) AS src
                                ON target.uid = src.uid
                                WHEN MATCHED THEN UPDATE SET target.eid = src.eid, target.active = 1
                                WHEN NOT MATCHED THEN INSERT (uid, eid, active) VALUES (src.uid, src.eid, 1);
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, uid);
            stm.setInt(2, eid);
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }

    public void deleteById(int uid) {
        try {
            connection.setAutoCommit(false);
            PreparedStatement stm1 = connection.prepareStatement("DELETE FROM UserRole WHERE uid = ?");
            stm1.setInt(1, uid);
            stm1.executeUpdate();
            PreparedStatement stm2 = connection.prepareStatement("DELETE FROM Enrollment WHERE uid = ?");
            stm2.setInt(1, uid);
            stm2.executeUpdate();
            PreparedStatement stm3 = connection.prepareStatement("DELETE FROM [User] WHERE uid = ?");
            stm3.setInt(1, uid);
            stm3.executeUpdate();
            connection.commit();
        } catch (SQLException ex) {
            try { connection.rollback(); } catch (SQLException e) {}
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            try { connection.setAutoCommit(true); } catch (SQLException e) {}
            closeConnection();
        }
    }
    
    @Override
    public ArrayList<User> list() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public User get(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public void insert(User model) {
        try {
            String sql = """
                                INSERT INTO [User] (username, [password], displayname)
                                VALUES (?,?,?)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, model.getUsername());
            stm.setString(2, model.getPassword());
            stm.setString(3, model.getDisplayname());
            stm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
    }

    public Integer insertAndReturnId(User model) {
        try {
            String sql = """
                                INSERT INTO [User] (username, [password], displayname)
                                VALUES (?,?,?)
                           """;
            PreparedStatement stm = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            stm.setString(1, model.getUsername());
            stm.setString(2, model.getPassword());
            stm.setString(3, model.getDisplayname());
            stm.executeUpdate();
            ResultSet rs = stm.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
    }

    public boolean existsByUsername(String username) {
        try {
            String sql = "SELECT 1 FROM [User] WHERE username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            return rs.next();
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return false;
    }

    @Override
    public void update(User model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public void delete(User model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
    
}
