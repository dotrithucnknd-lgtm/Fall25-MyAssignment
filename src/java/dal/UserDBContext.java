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
        PreparedStatement stm = null;
        ResultSet rs = null;
        System.out.println("=== DEBUG UserDBContext.get() START ===");
        System.out.println("DEBUG: Input username: [" + username + "], password length: " + (password != null ? password.length() : 0));
        
        try {
            // Kiểm tra connection trước khi sử dụng
            System.out.println("DEBUG: Checking connection...");
            if (connection == null) {
                System.err.println("DEBUG: Connection is NULL!");
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                    "Connection is NULL! Database connection failed. Check:\n"
                    + "1. Database FALL25_Assignment_SonNT exists\n"
                    + "2. Login 'java_admin' exists with password 'P@ssw0rd123'\n"
                    + "3. SQL Server is running on localhost:1433\n"
                    + "4. Check Tomcat logs for SQLException from DBContext constructor");
                System.err.println("ERROR: Database connection is NULL in UserDBContext.get()");
                return null;
            }
            System.out.println("DEBUG: Connection is NOT NULL");
            
            try {
                if (connection.isClosed()) {
                    System.err.println("DEBUG: Connection is CLOSED!");
                    Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Connection is closed! Cannot execute query.");
                    return null;
                }
                System.out.println("DEBUG: Connection is OPEN");
            } catch (SQLException ex) {
                System.err.println("DEBUG: Error checking connection: " + ex.getMessage());
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, "Error checking if connection is closed", ex);
                return null;
            }
            
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
            // Validate input
            if (username == null || username.trim().isEmpty() || password == null || password.trim().isEmpty()) {
                System.out.println("DEBUG: Validation failed - empty input");
                Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, "Username or password is empty");
                return null;
            }
            
            System.out.println("DEBUG: Preparing statement with username: [" + username.trim() + "]");
            stm = connection.prepareStatement(sql);
            stm.setString(1, username.trim());
            stm.setString(2, password);
            
            System.out.println("DEBUG: Executing query...");
            
            // DEBUG: Test query đơn giản trước - lấy tất cả users
            System.out.println("DEBUG: Testing simple query - SELECT all from User table...");
            try {
                Statement testStmt = connection.createStatement();
                ResultSet testRs = testStmt.executeQuery("SELECT TOP 5 uid, username, [password], displayname FROM [User]");
                System.out.println("DEBUG: Simple query result:");
                int count = 0;
                while (testRs.next()) {
                    count++;
                    System.out.println("  User " + count + ": uid=" + testRs.getInt("uid") + 
                                     ", username=[" + testRs.getString("username") + "]" +
                                     ", password=[" + testRs.getString("password") + "]" +
                                     ", displayname=[" + testRs.getString("displayname") + "]");
                }
                testRs.close();
                testStmt.close();
                System.out.println("DEBUG: Found " + count + " users in User table");
            } catch (SQLException testEx) {
                System.err.println("DEBUG: Error in simple query test: " + testEx.getMessage());
                testEx.printStackTrace();
            }
            
            // DEBUG: Test query với username cụ thể
            System.out.println("DEBUG: Testing query with username=[" + username.trim() + "]...");
            try {
                PreparedStatement testStmt2 = connection.prepareStatement("SELECT uid, username, [password], displayname FROM [User] WHERE username = ?");
                testStmt2.setString(1, username.trim());
                ResultSet testRs2 = testStmt2.executeQuery();
                if (testRs2.next()) {
                    System.out.println("DEBUG: Found user by username: uid=" + testRs2.getInt("uid") + 
                                     ", username=[" + testRs2.getString("username") + "]" +
                                     ", password=[" + testRs2.getString("password") + "]" +
                                     ", displayname=[" + testRs2.getString("displayname") + "]");
                    System.out.println("DEBUG: Input password=[" + password + "], DB password=[" + testRs2.getString("password") + "]");
                    System.out.println("DEBUG: Password match: " + password.equals(testRs2.getString("password")));
                } else {
                    System.out.println("DEBUG: No user found with username=[" + username.trim() + "]");
                }
                testRs2.close();
                testStmt2.close();
            } catch (SQLException testEx2) {
                System.err.println("DEBUG: Error in username query test: " + testEx2.getMessage());
                testEx2.printStackTrace();
            }
            
            rs = stm.executeQuery();
            System.out.println("DEBUG: Query executed, checking results...");
            
            if (rs.next()) {
                System.out.println("DEBUG: Found user in database!");
                User u = new User();
                Employee e = new Employee();
                e.setId(rs.getInt("eid"));
                e.setName(rs.getString("ename"));
                u.setEmployee(e);
                
                u.setUsername(rs.getString("username"));
                u.setId(rs.getInt("uid"));
                u.setDisplayname(rs.getString("displayname"));
                
                System.out.println("DEBUG: User created - ID: " + u.getId() + ", Username: " + u.getUsername() + ", DisplayName: " + u.getDisplayname());
                Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                    "Login successful for user: " + username);
                return u;
            } else {
                System.out.println("DEBUG: No user found in database with username=[" + username.trim() + "] and password");
                Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                    "Login failed: No user found with username=" + username);
            }
        } catch (SQLException ex) {
            System.err.println("DEBUG: SQLException occurred: " + ex.getMessage());
            ex.printStackTrace();
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "SQL Error in get(username, password): " + ex.getMessage(), ex);
            System.err.println("SQL Error: " + ex.getMessage());
        } finally {
            // Đóng ResultSet và PreparedStatement
            try {
                if (rs != null) rs.close();
                if (stm != null) stm.close();
            } catch (SQLException ex) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, "Error closing resources", ex);
            }
            // Đóng connection
            closeConnection();
        }
        System.out.println("=== DEBUG UserDBContext.get() END - returning NULL ===");
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
    
    /**
     * Reset password cho user
     * @param uid User ID
     * @param newPassword Mật khẩu mới
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean resetPassword(int uid, String newPassword) {
        try {
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                    "Database connection is null in resetPassword");
                return false;
            }
            
            if (newPassword == null || newPassword.trim().isEmpty()) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, 
                    "New password is null or empty");
                return false;
            }
            
            String sql = "UPDATE [User] SET [password] = ? WHERE uid = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, newPassword);
            stm.setInt(2, uid);
            int rowsAffected = stm.executeUpdate();
            
            Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                "Password reset for uid=" + uid + ", rowsAffected=" + rowsAffected);
            
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error resetting password for uid=" + uid + ": " + ex.getMessage(), ex);
        } finally {
            closeConnection();
        }
        return false;
    }
    
    /**
     * Reset password cho user bằng username
     * @param username Username
     * @param newPassword Mật khẩu mới
     * @return true nếu thành công, false nếu thất bại
     */
    public boolean resetPasswordByUsername(String username, String newPassword) {
        try {
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                    "Database connection is null in resetPasswordByUsername");
                return false;
            }
            
            if (username == null || username.trim().isEmpty() || 
                newPassword == null || newPassword.trim().isEmpty()) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.WARNING, 
                    "Username or new password is null or empty");
                return false;
            }
            
            String sql = "UPDATE [User] SET [password] = ? WHERE username = ?";
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setString(1, newPassword);
            stm.setString(2, username.trim());
            int rowsAffected = stm.executeUpdate();
            
            Logger.getLogger(UserDBContext.class.getName()).log(Level.INFO, 
                "Password reset for username=" + username + ", rowsAffected=" + rowsAffected);
            
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error resetting password for username=" + username + ": " + ex.getMessage(), ex);
        } finally {
            closeConnection();
        }
        return false;
    }
    
    @Override
    public ArrayList<User> list() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public User get(int id) {
        try {
            if (connection == null) {
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                    "Database connection is null in get(int id)");
                return null;
            }
            
            String sql = """
                                SELECT
                                u.uid,
                                u.username,
                                u.displayname,
                                e.eid,
                                e.ename
                                FROM [User] u 
                                LEFT JOIN [Enrollment] en ON u.[uid] = en.[uid] AND en.active = 1
                                LEFT JOIN [Employee] e ON e.eid = en.eid
                                WHERE u.uid = ?
                         """;
            
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("uid"));
                u.setUsername(rs.getString("username"));
                u.setDisplayname(rs.getString("displayname"));
                
                // Nếu có employee, set employee
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
            Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, 
                "Error getting user by id=" + id + ": " + ex.getMessage(), ex);
        } finally {
            closeConnection();
        }
        return null;
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
    
    /**
     * Test get account function - DEBUG MODE
     * @param args command line arguments
     */
    public static void main(String[] args) {
        System.out.println("=== DEBUG: KIỂM TRA GET ACCOUNT ===");
        System.out.println("=====================================");
        
        // Create UserDBContext instance
        System.out.println("\n1. Creating UserDBContext...");
        UserDBContext userDB = new UserDBContext();
        System.out.println("   UserDBContext created.");
        
        // Test với các tài khoản thực tế từ database
        String[][] testAccounts = {
            {"mra", "123"},
            {"mrb", "123"},
            {"mrc", "123"},
            {"mrd", "123"},
            {"mre", "123"},
            {"mrg", "123"}
        };
        
        System.out.println("\n2. Testing login with real accounts from database:");
        System.out.println("===================================================");
        
        for (int i = 0; i < testAccounts.length; i++) {
            String testUsername = testAccounts[i][0];
            String testPassword = testAccounts[i][1];
            
            System.out.println("\n--- Test " + (i + 1) + ": " + testUsername + " / " + testPassword + " ---");
            
            try {
                User user = userDB.get(testUsername, testPassword);
                
                if (user != null) {
                    System.out.println("✓ SUCCESS - Tìm thấy account!");
                    System.out.println("  User ID: " + user.getId());
                    System.out.println("  Username: " + user.getUsername());
                    System.out.println("  Display Name: " + user.getDisplayname());
                    
                    if (user.getEmployee() != null) {
                        System.out.println("  Employee ID: " + user.getEmployee().getId());
                        System.out.println("  Employee Name: " + user.getEmployee().getName());
                    } else {
                        System.out.println("  Employee: null");
                    }
                } else {
                    System.out.println("✗ FAILED - Không tìm thấy account!");
                    System.out.println("  Nguyên nhân có thể:");
                    System.out.println("  1. Username hoặc password không đúng");
                    System.out.println("  2. User không có Enrollment active");
                    System.out.println("  3. User không tồn tại trong database");
                }
            } catch (Exception ex) {
                System.out.println("✗ EXCEPTION: " + ex.getMessage());
                ex.printStackTrace();
                Logger.getLogger(UserDBContext.class.getName()).log(Level.SEVERE, null, ex);
            }
        }
        
        // Test case với thông tin sai
        System.out.println("\n\n--- Test với thông tin sai ---");
        System.out.println("Username: wrong_user");
        System.out.println("Password: wrong_pass");
        
        try {
            UserDBContext userDB2 = new UserDBContext();
            User user2 = userDB2.get("wrong_user", "wrong_pass");
            if (user2 == null) {
                System.out.println("✓ Đúng như mong đợi: Không tìm thấy account với thông tin sai");
            } else {
                System.out.println("✗ Lỗi: Tìm thấy account với thông tin sai!");
            }
        } catch (Exception ex) {
            System.out.println("✗ Lỗi: " + ex.getMessage());
            ex.printStackTrace();
        }
        
        System.out.println("\n=== HOÀN TẤT DEBUG KIỂM TRA ===");
    }
    
}
