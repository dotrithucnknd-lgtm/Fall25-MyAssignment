package controller.request;

import controller.iam.BaseRequiredAuthenticationController; 
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
public class CreateController extends BaseRequiredAuthenticationController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        
        // CHỈ HIỂN THỊ FORM - KHÔNG CẦN LẤY DỮ LIỆU LOẠI PHÉP
        req.getRequestDispatcher("/view/request/create.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        
        // 1. Lấy dữ liệu từ form (CHÚ Ý: Đã thêm input cho LoaiPhép là 'leaveTypeID')
        String ltId = req.getParameter("leaveTypeID"); // Đây là ID loại phép (sẽ gán cứng)
        String from = req.getParameter("from");
        String to = req.getParameter("to");
        String reason = req.getParameter("reason");
        
        // 2. Tạo đối tượng RequestForLeave
        RequestForLeave rfl = new RequestForLeave();
        
        // Map LeaveType: GÁN CỨNG (Hoặc lấy từ input nếu bạn muốn người dùng tự nhập ID)
        LeaveType lt = new LeaveType();
        // Map Ngày tháng
        rfl.setFrom(Date.valueOf(from));
        rfl.setTo(Date.valueOf(to));
        rfl.setReason(reason);
        
        // Map người tạo đơn (Lấy từ User đã đăng nhập)
        Employee creator = user.getEmployee();
        rfl.setCreated_by(creator);
        
        // 3. (LOGIC TÌM SẾP BỊ BỎ QUA - Giả định đã có approver_id = 1 trong DBContext)
        
        // 4. Chèn vào database và lấy ID
        RequestForLeaveDBContext rflDB = new RequestForLeaveDBContext();
        int requestId = rflDB.insertAndReturnId(rfl);
        
        // 5. Ghi log vào ActivityLog
        if (requestId > 0) {
            String newValueJson = String.format("{\"rid\":%d,\"from\":\"%s\",\"to\":\"%s\",\"reason\":\"%s\",\"status\":0}", 
                requestId, from, to, reason != null ? reason.replace("\"", "\\\"") : "");
            LogUtil.logActivity(
                user,
                LogUtil.ActivityType.CREATE_REQUEST,
                LogUtil.EntityType.REQUEST_FOR_LEAVE,
                requestId,
                "Tạo đơn xin nghỉ từ " + from + " đến " + to,
                null,
                newValueJson,
                req
            );
        }
        
        // 6. Chuyển hướng về trang danh sách đơn
        resp.sendRedirect(req.getContextPath() + "/request/list");
    }
}