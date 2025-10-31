/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.iam;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.iam.User;

/**
 *
 * @author admin
 */
public abstract class BaseRequiredAuthenticationController extends HttpServlet {
     private boolean isAuthenticated(HttpServletRequest req) {
        User u = (User) req.getSession().getAttribute("auth");
        return u != null;
    }

    protected abstract void doPost(HttpServletRequest req, HttpServletResponse resp,User user) throws ServletException, IOException;
    protected abstract void doGet(HttpServletRequest req, HttpServletResponse resp,User user) throws ServletException, IOException;
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (isAuthenticated(req)) {
            User u = (User) req.getSession().getAttribute("auth");
            doPost(req, resp, u);
        } else {
            // Redirect to login required page
            resp.sendRedirect(req.getContextPath() + "/view/public/login_required.jsp");
        }
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (isAuthenticated(req)) {
            //do business
            User u = (User) req.getSession().getAttribute("auth");
            doGet(req, resp, u);
        } else {
            // Redirect to login required page
            resp.sendRedirect(req.getContextPath() + "/view/public/login_required.jsp");
        }
    }
}
