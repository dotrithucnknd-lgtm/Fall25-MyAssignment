package controller.home; // Make sure package name matches your structure

import controller.iam.BaseRequiredAuthenticationController; // Ensure this import is correct
import dal.RequestForLeaveDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import model.iam.User; // Ensure this import is correct

/**
 * Handles requests for the home page after successful login.
 */
@WebServlet(urlPatterns = "/home") // Maps requests to /home
public class HomeController extends BaseRequiredAuthenticationController {

    /**
     * Handles POST requests (e.g., from forms on the home page).
     * For now, just forwards to doGet.
     */
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // You might add logic here later if the home page has forms submitting via POST.
        // For now, just show the same home page.
        doGet(req, resp, user);
    }

    /**
     * Handles GET requests to display the home page.
     */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Kiểm tra số lần nghỉ trong tháng hiện tại
        RequestForLeaveDBContext db = new RequestForLeaveDBContext();
        int leaveCountThisMonth = db.countApprovedLeaveRequestsThisMonth(user.getEmployee().getId());
        
        // Truyền thông tin cảnh báo nếu đã nghỉ > 2 lần/tháng
        boolean showWarning = leaveCountThisMonth > 2;
        req.setAttribute("leaveCountThisMonth", leaveCountThisMonth);
        req.setAttribute("showWarning", showWarning);
        
        // The user object is already available because BaseRequiredAuthenticationController provides it.
        // We just need to show the home view.
        // Make sure the path to home.jsp is correct (starts with / and is outside WEB-INF)
        req.getRequestDispatcher("/view/home.jsp").forward(req, resp);
    }
}