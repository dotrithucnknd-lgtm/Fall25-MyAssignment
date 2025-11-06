/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dal;

import java.util.ArrayList;
import model.iam.Role;
import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;
import model.iam.Feature;

/**
 *
 * @author sonnt
 */
public class RoleDBContext extends DBContext<Role> {

    public ArrayList<Role> getByUserId(int id) {
        ArrayList<Role> roles = new ArrayList<>();
        System.out.println("=== DEBUG RoleDBContext.getByUserId() ===");
        System.out.println("DEBUG: Getting roles for user ID: " + id);

        try {
            if (connection == null) {
                System.err.println("DEBUG: Connection is NULL in RoleDBContext!");
                return roles;
            }
            
            String sql = """
                                     SELECT r.rid,r.rname,f.fid,f.url
                                     FROM [User] u INNER JOIN [UserRole] ur ON u.uid = ur.uid
                                     \t\t\t\t\t\tINNER JOIN [Role] r ON r.rid = ur.rid
                                     \t\t\t\t\t\tINNER JOIN [RoleFeature] rf ON rf.rid = r.rid
                                     \t\t\t\t\t\tINNER JOIN [Feature] f ON f.fid = rf.fid
                                     \t\t\t\t\t\tWHERE u.uid = ?""";

            System.out.println("DEBUG: Executing query to get roles for user ID: " + id);
            PreparedStatement stm = connection.prepareStatement(sql);
            stm.setInt(1, id);
            ResultSet rs = stm.executeQuery();
            
            Role current = new Role();
            current.setId(-1);
            int rowCount = 0;
            while(rs.next())
            {
                rowCount++;
                int rid = rs.getInt("rid");
                String rname = rs.getString("rname");
                int fid = rs.getInt("fid");
                String furl = rs.getString("url");
                
                System.out.println("DEBUG: Row " + rowCount + " - rid=" + rid + ", rname=" + rname + ", fid=" + fid + ", url=" + furl);
                
                if(rid != current.getId())
                {
                    if (current.getId() != -1) {
                        System.out.println("DEBUG: Completed role: " + current.getName() + " with " + current.getFeatures().size() + " features");
                    }
                    current = new Role();
                    current.setId(rid);
                    current.setName(rname);
                    roles.add(current);
                    System.out.println("DEBUG: Started new role: " + rname + " (ID: " + rid + ")");
                }
                Feature f = new Feature();
                f.setId(fid);
                f.setUrl(furl);
                current.getFeatures().add(f);
                System.out.println("DEBUG: Added feature: " + furl + " to role: " + rname);
            }
            
            if (current.getId() != -1) {
                System.out.println("DEBUG: Completed last role: " + current.getName() + " with " + current.getFeatures().size() + " features");
            }
            
            System.out.println("DEBUG: Total rows: " + rowCount);
            System.out.println("DEBUG: Total roles loaded: " + roles.size());
            for (Role r : roles) {
                System.out.println("  - Role: " + r.getName() + " has " + r.getFeatures().size() + " features");
            }
            
        } catch (SQLException ex) {
            System.err.println("DEBUG: SQLException in getByUserId: " + ex.getMessage());
            ex.printStackTrace();
            Logger.getLogger(RoleDBContext.class.getName()).log(Level.SEVERE, null, ex);
        } finally {
            closeConnection();
        }
        return roles;
    }

    @Override
    public ArrayList<Role> list() {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public Role get(int id) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public void insert(Role model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public void update(Role model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

    @Override
    public void delete(Role model) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }

}
