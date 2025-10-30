/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package controller.request;

import controller.iam.BaseRequiredAuthorizationController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.iam.User;

/**
 *
 * @author admin
 */
@WebServlet(urlPatterns="/request/review")
public class ReviewController extends BaseRequiredAuthorizationController {

    private void handle(HttpServletRequest req, HttpServletResponse resp, User user) throws IOException {
        String ridRaw = req.getParameter("rid");
        String statusRaw = req.getParameter("status");
        if(ridRaw == null || statusRaw == null) {
            resp.sendRedirect(req.getContextPath() + "/request/list");
            return;
        }
        try {
            int rid = Integer.parseInt(ridRaw);
            int status = Integer.parseInt(statusRaw); // 1=approved, 2=rejected
            if(status != 1 && status != 2) {
                resp.sendRedirect(req.getContextPath() + "/request/list");
                return;
            }
            int approverEid = user.getEmployee().getId();
            // Use a short-lived context for each operation because each closes its connection in finally
            dal.RequestForLeaveDBContext getDb = new dal.RequestForLeaveDBContext();
            model.RequestForLeave current = getDb.get(rid);
            int oldStatus = current != null ? current.getStatus() : 0;

            model.RequestForLeave r = new model.RequestForLeave();
            r.setId(rid);
            r.setStatus(status);
            model.Employee approver = new model.Employee();
            approver.setId(approverEid);
            r.setProcessed_by(approver);
            dal.RequestForLeaveDBContext updateDb = new dal.RequestForLeaveDBContext();
            updateDb.update(r);

            dal.RequestForLeaveHistoryDBContext hdb = new dal.RequestForLeaveHistoryDBContext();
            model.RequestForLeaveHistory h = new model.RequestForLeaveHistory();
            h.setRequestId(rid);
            h.setOldStatus(oldStatus);
            h.setNewStatus(status);
            h.setProcessedBy(approver);
            h.setProcessedTime(new java.sql.Timestamp(System.currentTimeMillis()));
            h.setNote("Status changed by approver");
            hdb.insert(h);
        } catch (NumberFormatException ex) {
            // ignore and fallback to redirect
        }
        resp.sendRedirect(req.getContextPath() + "/request/list");
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        handle(req, resp, user);
    }

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        handle(req, resp, user);
    }
    
}
