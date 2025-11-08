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
            
            // Kiểm tra xem đơn có tồn tại không
            if (current == null) {
                resp.sendRedirect(req.getContextPath() + "/request/list");
                return;
            }
            
            // NGĂN CHẶN: Kiểm tra xem người đang duyệt có phải là người tạo đơn không
            if (current.getCreated_by() != null && current.getCreated_by().getId() == approverEid) {
                // Không cho phép tự duyệt đơn của chính mình
                req.getSession().setAttribute("errorMessage", "Bạn không thể tự duyệt đơn của chính mình!");
                resp.sendRedirect(req.getContextPath() + "/request/list");
                return;
            }
            
            int oldStatus = current.getStatus();

            model.RequestForLeave r = new model.RequestForLeave();
            r.setId(rid);
            r.setStatus(status);
            model.Employee approver = new model.Employee();
            approver.setId(approverEid);
            r.setProcessed_by(approver);
            dal.RequestForLeaveDBContext updateDb = new dal.RequestForLeaveDBContext();
            updateDb.update(r);

            // Ghi log vào RequestForLeaveHistory (giữ để tương thích)
            dal.RequestForLeaveHistoryDBContext hdb = new dal.RequestForLeaveHistoryDBContext();
            model.RequestForLeaveHistory h = new model.RequestForLeaveHistory();
            h.setRequestId(rid);
            h.setOldStatus(oldStatus);
            h.setNewStatus(status);
            h.setProcessedBy(approver);
            h.setProcessedTime(new java.sql.Timestamp(System.currentTimeMillis()));
            h.setNote("Status changed by approver");
            hdb.insert(h);
            
            // Ghi log vào ActivityLog
            String activityType = (status == 1) ? util.LogUtil.ActivityType.APPROVE_REQUEST : util.LogUtil.ActivityType.REJECT_REQUEST;
            String actionDesc = (status == 1) ? "Duyệt đơn xin nghỉ #" + rid : "Từ chối đơn xin nghỉ #" + rid;
            String oldValue = "{\"status\":" + oldStatus + "}";
            String newValue = "{\"status\":" + status + "}";
            
            util.LogUtil.logActivity(
                user,
                activityType,
                util.LogUtil.EntityType.REQUEST_FOR_LEAVE,
                rid,
                actionDesc,
                oldValue,
                newValue,
                req
            );
            
            // Thông báo thành công
            String successMsg = (status == 1) ? "Đã duyệt đơn xin nghỉ #" + rid : "Đã từ chối đơn xin nghỉ #" + rid;
            req.getSession().setAttribute("successMessage", successMsg);
        } catch (NumberFormatException ex) {
            // ignore and fallback to redirect
        }
        
        // Kiểm tra xem user có đang ở trang agenda không (từ referer)
        String referer = req.getHeader("Referer");
        if (referer != null && referer.contains("/division/agenda")) {
            // Nếu đang ở trang agenda, redirect về agenda để refresh
            resp.sendRedirect(req.getContextPath() + "/division/agenda");
        } else {
            // Nếu không, redirect về list
            resp.sendRedirect(req.getContextPath() + "/request/list");
        }
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
