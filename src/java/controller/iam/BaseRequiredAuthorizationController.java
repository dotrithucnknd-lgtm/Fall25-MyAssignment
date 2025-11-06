/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.iam;

import dal.RoleDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.iam.Feature;
import model.iam.Role;
import model.iam.User;

/**
 *
 * @author sonnt
 */
public abstract class BaseRequiredAuthorizationController extends BaseRequiredAuthenticationController {

    private boolean isAuthorized(HttpServletRequest req, User user) {
        String url = req.getServletPath();
        System.out.println("=== DEBUG Authorization ===");
        System.out.println("DEBUG: Checking authorization for URL: " + url);
        System.out.println("DEBUG: User ID: " + user.getId());
        System.out.println("DEBUG: User roles count: " + user.getRoles().size());
        
        if (user.getRoles().isEmpty())//check if not yet fetch roles from db to user
        {
            System.out.println("DEBUG: User roles is empty, fetching from database...");
            RoleDBContext db = new RoleDBContext();
            ArrayList<Role> roles = db.getByUserId(user.getId());
            user.setRoles(roles);
            req.getSession().setAttribute("auth", user);
            System.out.println("DEBUG: Loaded " + roles.size() + " roles from database");
        }
        
        System.out.println("DEBUG: User has " + user.getRoles().size() + " roles:");
        for (Role role : user.getRoles()) {
            System.out.println("  - Role: " + role.getName() + " (ID: " + role.getId() + ")");
            System.out.println("    Features: " + role.getFeatures().size());
            for (Feature feature : role.getFeatures()) {
                System.out.println("      * Feature: " + feature.getUrl() + " (ID: " + feature.getId() + ")");
                if(feature.getUrl().equals(url)) {
                    System.out.println("DEBUG: ✓ AUTHORIZED - Found matching feature: " + feature.getUrl());
                    return true;
                }
            }
        }
        System.out.println("DEBUG: ✗ ACCESS DENIED - No matching feature found for URL: " + url);
        return false;
    }

    protected abstract void processPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException;
    protected abstract void processGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException ;
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        if(isAuthorized(req, user))
            processPost(req, resp, user);
        else
            resp.getWriter().println("access denied!");
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        if(isAuthorized(req, user))
            processGet(req, resp, user);
        else
            resp.getWriter().println("access denied!");
    }

}
