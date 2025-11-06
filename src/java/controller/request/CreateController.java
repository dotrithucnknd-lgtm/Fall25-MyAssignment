package controller.request;

import controller.iam.BaseRequiredAuthorizationController; 
import dal.RequestForLeaveDBContext;
import model.Employee;
import model.LeaveType;
import model.iam.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Date;
import model.RequestForLeave;
import util.LogUtil;

@WebServlet(urlPatterns = "/request/create")
public class CreateController extends BaseRequiredAuthorizationController {

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        
        // CHỈ HIỂN THỊ FORM - KHÔNG CẦN LẤY DỮ LIỆU LOẠI PHÉP
        req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form (CHÚ Ý: Đã thêm input cho LoaiPhép là 'leaveTypeID')
        String ltId = req.getParameter("leaveTypeID"); // Đây là ID loại phép (sẽ gán cứng)
        String from = req.getParameter("from");
        String to = req.getParameter("to");
        String reason = req.getParameter("reason");
        
        // 2. Tạo đối tượng RequestForLeave
        RequestForLeave rfl = new RequestForLeave();
        
        // Map LeaveType: GÁN CỨNG (mặc định leavetype_id = 1)
        LeaveType lt = new LeaveType();
        if (ltId != null && !ltId.trim().isEmpty()) {
            try {
                lt.setId(Integer.parseInt(ltId));
            } catch (NumberFormatException e) {
                lt.setId(1); // Default to 1 if invalid
            }
        } else {
            lt.setId(1); // Default to 1
        }
        rfl.setLeaveType(lt);
        
        // Map Ngày tháng
        rfl.setFrom(Date.valueOf(from));
        rfl.setTo(Date.valueOf(to));
        rfl.setReason(reason);
        
        // Map người tạo đơn (Lấy từ User đã đăng nhập)
        Employee creator = user.getEmployee();
        rfl.setCreated_by(creator);
        
        // 3. Kiểm tra xem user có quyền IT Head (rid=1) không
        // Nếu có, tự động duyệt đơn (status=1) và set processed_by = chính người tạo
        // Đảm bảo roles được load nếu chưa có
        if (user.getRoles() == null || user.getRoles().isEmpty()) {
            dal.RoleDBContext roleDB = new dal.RoleDBContext();
            user.setRoles(roleDB.getByUserId(user.getId()));
            req.getSession().setAttribute("auth", user); // Update session
        }
        
        boolean isITHead = false;
        if (user.getRoles() != null && !user.getRoles().isEmpty()) {
            for (model.iam.Role role : user.getRoles()) {
                if (role.getId() == 1) { // IT Head có rid=1
                    isITHead = true;
                    break;
                }
            }
        }
        
        if (isITHead) {
            // Tự động duyệt đơn cho IT Head
            rfl.setStatus(1); // status=1: Approved
            rfl.setProcessed_by(creator); // processed_by = chính người tạo
        } else {
            // Đơn thường: status=0 (Pending), processed_by=NULL
            rfl.setStatus(0); // status=0: Pending
            rfl.setProcessed_by(null);
        }
        
        // 4. Chèn vào database và lấy ID
        RequestForLeaveDBContext rflDB = new RequestForLeaveDBContext();
        int requestId = rflDB.insertAndReturnId(rfl);
        
        // 5. Ghi log vào ActivityLog
        if (requestId > 0) {
            int finalStatus = isITHead ? 1 : 0;
            String newValueJson = String.format("{\"rid\":%d,\"from\":\"%s\",\"to\":\"%s\",\"reason\":\"%s\",\"status\":%d}", 
                requestId, from, to, reason != null ? reason.replace("\"", "\\\"") : "", finalStatus);
            LogUtil.logActivity(
                user,
                LogUtil.ActivityType.CREATE_REQUEST,
                LogUtil.EntityType.REQUEST_FOR_LEAVE,
                requestId,
                "Tạo đơn xin nghỉ từ " + from + " đến " + to + (isITHead ? " (Tự động duyệt)" : ""),
                null,
                newValueJson,
                req
            );
            
            // Nếu là IT Head và đơn đã được tự động duyệt, ghi log duyệt
            if (isITHead) {
                String approveJson = String.format("{\"rid\":%d,\"status\":1}", requestId);
                LogUtil.logActivity(
                    user,
                    LogUtil.ActivityType.APPROVE_REQUEST,
                    LogUtil.EntityType.REQUEST_FOR_LEAVE,
                    requestId,
                    "Tự động duyệt đơn xin nghỉ (IT Head)",
                    String.format("{\"rid\":%d,\"status\":0}", requestId),
                    approveJson,
                    req
                );
            }
        }
        
        // 6. Chuyển hướng về trang danh sách đơn
        resp.sendRedirect(req.getContextPath() + "/request/list");
    }
}