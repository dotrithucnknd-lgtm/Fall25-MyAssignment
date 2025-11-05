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

    public boolean createOrActivateEnrollment(int uid, int eid) {
        try {
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Database connection is null");
                return false;
            }
            try {
                if (connection.isClosed()) {
                    Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Database connection is closed");
                    return false;
                }
            } catch (SQLException ex) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Error checking connection status", ex);
                return false;
            }
            
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
            int rowsAffected = stm.executeUpdate();
            
            Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                "MERGE Enrollment executed for uid=" + uid + ", eid=" + eid + ", rowsAffected=" + rowsAffected);
            
            // Verify enrollment was created/updated correctly
            if (rowsAffected > 0) {
                String verifySql = "SELECT 1 FROM Enrollment WHERE uid = ? AND eid = ? AND active = 1";
                PreparedStatement verifyStm = connection.prepareStatement(verifySql);
                verifyStm.setInt(1, uid);
                verifyStm.setInt(2, eid);
                ResultSet rs = verifyStm.executeQuery();
                boolean exists = rs.next();
                Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                    "Enrollment verification for uid=" + uid + ", eid=" + eid + ": " + exists);
                return exists;
            } else {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, 
                    "MERGE Enrollment returned 0 rows affected for uid=" + uid + ", eid=" + eid);
            }
            return false;
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error creating/activating enrollment for uid=" + uid + ", eid=" + eid + ": " + ex.getMessage(), ex);
        } finally {
            closeConnection();
        }
        return false;
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
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Database connection is null");
                return null;
            }
            
            try {
                if (connection.isClosed()) {
                    Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Database connection is closed");
                    return null;
                }
            } catch (SQLException ex) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Error checking connection status", ex);
                return null;
            }
            
            if (model == null || model.getUsername() == null || model.getUsername().isBlank() ||
                model.getPassword() == null || model.getPassword().isBlank() ||
                model.getDisplayname() == null || model.getDisplayname().isBlank()) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                    "User model or required fields are null or blank");
                return null;
            }
            
            // Sử dụng OUTPUT INSERTED.uid để lấy UID vừa tạo (cách này đáng tin cậy hơn với SQL Server)
            String sql = "INSERT INTO [User] (username, [password], displayname) OUTPUT INSERTED.uid VALUES (?,?,?)";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, model.getUsername());
            stm.setString(2, model.getPassword());
            stm.setString(3, model.getDisplayname());
            
            Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                "Executing INSERT for user: " + model.getUsername());
            
            ResultSet rs = stm.executeQuery();
            
            try {
                if (rs != null && rs.next()) {
                    int uid = rs.getInt(1);
                    Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                        "Got UID from OUTPUT: " + uid);
                    
                    if (uid > 0) {
                        Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                            "Successfully created user with UID: " + uid + ", username: " + model.getUsername());
                        return uid;
                    } else {
                        Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                            "Got UID but it's <= 0 for user: " + model.getUsername());
                    }
                } else {
                    Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                        "Failed to get UID from OUTPUT clause for user: " + model.getUsername() + 
                        " - ResultSet is null or empty");
                }
            } finally {
                if (rs != null) {
                    try {
                        rs.close();
                    } catch (SQLException ex) {
                        Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, 
                            "Error closing ResultSet", ex);
                    }
                }
                if (stm != null) {
                    try {
                        stm.close();
                    } catch (SQLException ex) {
                        Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, 
                            "Error closing PreparedStatement", ex);
                    }
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error inserting user: " + (model != null ? model.getUsername() : "null") + 
                " - " + ex.getMessage(), ex);
        } finally {
            closeConnection();
        }
        return null;
    }

    public boolean existsByUsername(String username) {
        try {
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Database connection is null in existsByUsername");
                return false;
            }
            
            String sql = "SELECT 1 FROM [User] WHERE username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            boolean exists = rs.next();
            Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                "Username '" + username + "' exists: " + exists);
            return exists;
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error checking username existence: " + username, ex);
        } finally {
            closeConnection();
        }
        return false;
    }
    
    /**
     * Kiểm tra xem user có tồn tại và có Enrollment active không
     * @param username
     * @return true nếu user tồn tại và có enrollment active, false nếu không
     */
    public boolean hasActiveEnrollment(String username) {
        try {
            String sql = """
                SELECT 1 
                FROM [User] u 
                INNER JOIN [Enrollment] en ON u.[uid] = en.[uid]
                WHERE u.username = ? AND en.active = 1
            """;
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
    
    /**
     * Lấy thông tin user chỉ với username (không kiểm tra password)
     * Dùng để debug
     */
    public User getByUsernameOnly(String username) {
        try {
            String sql = """
                SELECT u.uid, u.username, u.displayname, u.[password],
                       en.eid, en.active,
                       e.ename
                FROM [User] u 
                LEFT JOIN [Enrollment] en ON u.[uid] = en.[uid]
                LEFT JOIN [Employee] e ON e.eid = en.eid
                WHERE u.username = ?
            """;
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, username);
            ResultSet rs = stm.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("uid"));
                u.setUsername(rs.getString("username"));
                u.setDisplayname(rs.getString("displayname"));
                u.setPassword(rs.getString("password"));
                
                int eid = rs.getInt("eid");
                if (!rs.wasNull() && eid > 0) {
                    Employee e = new Employee();
                    e.setId(eid);
                    e.setName(rs.getString("ename"));
                    u.setEmployee(e);
                }
                
                return u;
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return null;
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
