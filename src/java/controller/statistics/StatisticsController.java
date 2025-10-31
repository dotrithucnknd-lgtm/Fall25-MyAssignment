package controller.statistics;

import controller.iam.BaseRequiredAuthenticationController;
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
 * Tất cả user đã đăng nhập đều có thể xem trang này
 */
@WebServlet(urlPatterns = "/statistics")
public class StatisticsController extends BaseRequiredAuthenticationController {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        ArrayList<RequestForLeaveDBContext.EmployeeLeaveStatistics> stats = 
            db.getAllEmployeesLeaveStatisticsThisMonth();
        
        req.setAttribute("statistics", stats);
        req.getRequestDispatcher("/view/statistics/statistics.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user) 
            throws ServletException, IOException {
        doGet(req, resp, user);
    }
}

