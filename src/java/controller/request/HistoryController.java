package controller.request;

import controller.iam.BaseRequiredAuthenticationController;
import dal.ActivityLogDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.ActivityLog;
import model.iam.User;
import util.LogUtil;

@WebServlet(urlPatterns="/request/history")
public class HistoryController extends BaseRequiredAuthenticationController {

    private void process(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ridRaw = req.getParameter("rid");
        if (ridRaw == null) {
            resp.sendRedirect(req.getContextPath() + "/request/list");
            return;
        }
        try {
            int rid = Integer.parseInt(ridRaw);
            
            // Lấy logs từ ActivityLog với employee name
            ActivityLogDBContext logDB = new ActivityLogDBContext();
            ArrayList<ActivityLogDBContext.ActivityLogWithEmployee> activityLogs = logDB.getLogsByEntityWithEmployee(
                LogUtil.EntityType.REQUEST_FOR_LEAVE, 
                rid
            );
            
            // Chỉ lấy các logs liên quan đến duyệt/từ chối (loại bỏ CREATE_REQUEST)
            ArrayList<ActivityLogDBContext.ActivityLogWithEmployee> approvalLogs = new ArrayList<>();
            for (ActivityLogDBContext.ActivityLogWithEmployee logWrapper : activityLogs) {
                ActivityLog log = logWrapper.getLog();
                if (LogUtil.ActivityType.APPROVE_REQUEST.equals(log.getActivityType()) ||
                    LogUtil.ActivityType.REJECT_REQUEST.equals(log.getActivityType())) {
                    approvalLogs.add(logWrapper);
                }
            }
            
            // Map ActivityLog sang format tương tự RequestForLeaveHistory để JSP có thể hiển thị
            ArrayList<RequestHistoryDTO> logs = new ArrayList<>();
            
            for (ActivityLogDBContext.ActivityLogWithEmployee logWrapper : approvalLogs) {
                ActivityLog log = logWrapper.getLog();
                RequestHistoryDTO dto = new RequestHistoryDTO();
                dto.setProcessedTime(log.getCreatedAt());
                
                // Parse old_status và new_status từ old_value và new_value (JSON format)
                int oldStatus = parseStatusFromJson(log.getOldValue());
                int newStatus = parseStatusFromJson(log.getNewValue());
                dto.setOldStatus(oldStatus);
                dto.setNewStatus(newStatus);
                
                // Lấy tên người duyệt từ DTO
                dto.setProcessedByName(logWrapper.getEmployeeName());
                
                // Sử dụng action_description làm note
                dto.setNote(log.getActionDescription());
                
                logs.add(dto);
            }
            
            req.setAttribute("logs", logs);
            req.setAttribute("rid", rid);
            req.getRequestDispatcher("/view/request/history.jsp").forward(req, resp);
            
        } catch (NumberFormatException e) {
            resp.sendRedirect(req.getContextPath() + "/request/list");
        }
    }
    
    /**
     * Parse status từ JSON string như "{\"status\":1}"
     */
    private int parseStatusFromJson(String jsonValue) {
        if (jsonValue == null || jsonValue.trim().isEmpty()) {
            return 0; // default pending
        }
        try {
            // Simple JSON parsing - tìm "status":số
            String json = jsonValue.trim();
            int statusIndex = json.indexOf("\"status\":");
            if (statusIndex != -1) {
                int start = statusIndex + 9; // sau "status":
                int end = json.indexOf(",", start);
                if (end == -1) {
                    end = json.indexOf("}", start);
                }
                if (end != -1) {
                    String statusStr = json.substring(start, end).trim();
                    return Integer.parseInt(statusStr);
                }
            }
        } catch (Exception e) {
            // Nếu parse lỗi, return 0
        }
        return 0;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        process(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        process(req, resp);
    }
    
    /**
     * DTO class để map ActivityLog sang format tương tự RequestForLeaveHistory
     */
    public static class RequestHistoryDTO {
        private java.sql.Timestamp processedTime;
        private String processedByName;
        private int oldStatus;
        private int newStatus;
        private String note;
        
        // Getters and Setters
        public java.sql.Timestamp getProcessedTime() {
            return processedTime;
        }
        
        public void setProcessedTime(java.sql.Timestamp processedTime) {
            this.processedTime = processedTime;
        }
        
        public String getProcessedByName() {
            return processedByName;
        }
        
        public void setProcessedByName(String processedByName) {
            this.processedByName = processedByName;
        }
        
        public int getOldStatus() {
            return oldStatus;
        }
        
        public void setOldStatus(int oldStatus) {
            this.oldStatus = oldStatus;
        }
        
        public int getNewStatus() {
            return newStatus;
        }
        
        public void setNewStatus(int newStatus) {
            this.newStatus = newStatus;
        }
        
        public String getNote() {
            return note;
        }
        
        public void setNote(String note) {
            this.note = note;
        }
    }
}

