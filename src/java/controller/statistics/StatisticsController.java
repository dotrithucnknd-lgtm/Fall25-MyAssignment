package controller.statistics;

import controller.iam.BaseRequiredAuthorizationController;
import dal.RequestForLeaveDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.iam.User;

/**
 * Controller để hiển thị trang thống kê số lần nghỉ của từng employee
 * Chỉ Manager và Admin mới có quyền xem trang này
 */
@WebServlet(urlPatterns = "/statistics")
public class StatisticsController extends BaseRequiredAuthorizationController {

    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        ArrayList<RequestForLeaveDBContext.EmployeeLeaveStatistics> stats = 
            db.getAllEmployeesLeaveStatisticsThisMonth();
        
        req.setAttribute("statistics", stats);
        req.getRequestDispatcher("/view/statistics/statistics.jsp").forward(req, resp);
    }

    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        processGet(req, resp, user);
    }
}

