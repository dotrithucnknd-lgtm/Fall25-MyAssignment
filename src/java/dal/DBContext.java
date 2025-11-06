/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import model.BaseModel;
import java.sql.*;
import java.util.ArrayList;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author admin
 * @param <T>
 */
public abstract class DBContext<T extends BaseModel> {
    protected Connection connection = null;
    public DBContext()
    {
        try {
            String user = "sa";
            String pass = "123";
            String url = "jdbc:sqlserver://localhost:1433;databaseName=FALL25_Assignment_SonNT;encrypt=true;trustServerCertificate=true;";
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            connection = DriverManager.getConnection(url, user, pass);
            
            if (connection != null && !connection.isClosed()) {
                Logger.getLogger(DBContext.class.getName()).log(Level.INFO, 
                    "Database connection established successfully to FALL25_Assignment_SonNT");
            }
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, 
                "JDBC Driver not found: " + ex.getMessage(), ex);
            System.err.println("ERROR: JDBC Driver not found - " + ex.getMessage());
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, 
                "Database connection error: " + ex.getMessage(), ex);
            System.err.println("ERROR: Database connection failed - " + ex.getMessage());
            System.err.println("Check: 1) Database exists 2) SQL Server running 3) Credentials correct");
        }
    }
    public void closeConnection()
    {
        try {
            if(connection != null && !connection.isClosed())
            {
                connection.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public abstract ArrayList<T> list();
    public abstract T get(int id);
    public abstract void insert(T model);
    public abstract void update(T model);
    public abstract void delete(T model);
    
    /**
     * Test database connection
     * @param args command line arguments
     */
    public static void main(String[] args) {
        System.out.println("=== KIỂM TRA KẾT NỐI DATABASE ===");
        System.out.println("Server: localhost:1433");
        System.out.println("Database: FALL25_Assignment_SonNT");
        System.out.println("User: java_admin");
        System.out.println("-----------------------------------");
        
        // Create a simple test class to test connection
        DBContext<BaseModel> test = new DBContext<BaseModel>() {
            @Override
            public ArrayList<BaseModel> list() {
                return new ArrayList<>();
            }
            
            @Override
            public BaseModel get(int id) {
                return null;
            }
            
            @Override
            public void insert(BaseModel model) {
            }
            
            @Override
            public void update(BaseModel model) {
            }
            
            @Override
            public void delete(BaseModel model) {
            }
        };
        
        // Test connection
        try {
            if (test.connection != null && !test.connection.isClosed()) {
                System.out.println("\n✓ Kết nối database thành công!");
                
                // Test a simple query
                Statement stmt = test.connection.createStatement();
                ResultSet rs = stmt.executeQuery("SELECT @@VERSION AS 'SQL Server Version'");
                if (rs.next()) {
                    System.out.println("SQL Server Version: " + rs.getString(1));
                }
                rs.close();
                
                // Test database name
                rs = stmt.executeQuery("SELECT DB_NAME() AS 'Current Database'");
                if (rs.next()) {
                    System.out.println("Current Database: " + rs.getString(1));
                }
                rs.close();
                stmt.close();
                
            } else {
                System.out.println("\n✗ Kết nối database thất bại!");
                System.out.println("Connection is null or closed.");
            }
        } catch (SQLException ex) {
            System.out.println("\n✗ Lỗi khi kiểm tra kết nối: " + ex.getMessage());
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            test.closeConnection();
            System.out.println("\n=== HOÀN TẤT KIỂM TRA ===");
        }
    }
}
