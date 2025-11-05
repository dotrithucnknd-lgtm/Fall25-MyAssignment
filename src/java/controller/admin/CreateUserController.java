package controller.admin;

import controller.iam.BaseRequiredAuthorizationController;
import dal.EmployeeDBContext;
import dal.UserDBContext;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.Employee;
import model.iam.User;
import util.LogUtil;

/**
 * Controller để tạo User và Password mới (chỉ dành cho admin)
 * @author System
 */
@WebServlet(urlPatterns = "/admin/create-user")
public class CreateUserController extends BaseRequiredAuthorizationController {
    
    private UserDBContext userDB = new UserDBContext();
    private EmployeeDBContext employeeDB = new EmployeeDBContext();
    
    @Override
    protected void processGet(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        // Lấy danh sách employees để hiển thị trong dropdown
        ArrayList<Employee> employees = employeeDB.getAllEmployees();
        req.setAttribute("employees", employees);
        
        // Hiển thị form tạo user
        req.getRequestDispatcher("/view/admin/create_user.jsp").forward(req, resp);
    }
    
    @Override
    protected void processPost(HttpServletRequest req, HttpServletResponse resp, User user)
            throws ServletException, IOException {
        java.util.logging.Logger logger = java.util.logging.Logger.getLogger(CreateUserController.class.getName());
        logger.info("=== Starting user creation process ===");
        
        // Lấy dữ liệu từ form
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        String displayname = req.getParameter("displayname");
        String employeeIdStr = req.getParameter("employeeId");
        String createNewEmployee = req.getParameter("createNewEmployee"); // "on" nếu chọn tạo Employee mới
        
        logger.info("Form data received - username: " + username + ", displayname: " + displayname + 
                   ", createNewEmployee: " + createNewEmployee + ", employeeId: " + employeeIdStr);
        
        // Validate dữ liệu
        if (username == null || username.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            displayname == null || displayname.trim().isEmpty()) {
            logger.warning("Validation failed: missing required fields");
            req.getSession().setAttribute("errorMessage", "Vui lòng nhập đầy đủ thông tin.");
            resp.sendRedirect(req.getContextPath() + "/admin/create-user");
            return;
        }
        
        // Kiểm tra độ dài password
        if (password.length() < 6) {
            logger.warning("Validation failed: password too short");
            req.getSession().setAttribute("errorMessage", "Mật khẩu phải có ít nhất 6 ký tự.");
            resp.sendRedirect(req.getContextPath() + "/admin/create-user");
            return;
        }
        
        // Kiểm tra username đã tồn tại chưa
        logger.info("Checking if username exists: " + username);
        if (userDB.existsByUsername(username)) {
            logger.warning("Username already exists: " + username);
            req.getSession().setAttribute("errorMessage", "Username đã tồn tại. Vui lòng chọn username khác.");
            resp.sendRedirect(req.getContextPath() + "/admin/create-user");
            return;
        }
        logger.info("Username is available: " + username);
        
        try {
            int employeeId = 0;
            
            // Xử lý Employee
            if ("on".equals(createNewEmployee)) {
                // Tạo Employee mới
                logger.info("Creating new employee with name: " + displayname);
                Employee newEmployee = new Employee();
                newEmployee.setName(displayname);
                employeeId = employeeDB.insertAndReturnId(newEmployee);
                
                logger.info("Employee created with ID: " + employeeId);
                
                if (employeeId <= 0) {
                    logger.severe("Failed to create employee");
                    req.getSession().setAttribute("errorMessage", "Không thể tạo Employee. Vui lòng thử lại.");
                    resp.sendRedirect(req.getContextPath() + "/admin/create-user");
                    return;
                }
            } else {
                // Sử dụng Employee đã có
                logger.info("Using existing employee");
                if (employeeIdStr == null || employeeIdStr.trim().isEmpty()) {
                    logger.warning("No employee selected");
                    req.getSession().setAttribute("errorMessage", "Vui lòng chọn Employee hoặc tạo Employee mới.");
                    resp.sendRedirect(req.getContextPath() + "/admin/create-user");
                    return;
                }
                
                try {
                    employeeId = Integer.parseInt(employeeIdStr);
                    logger.info("Using existing employee ID: " + employeeId);
                } catch (NumberFormatException e) {
                    logger.warning("Invalid employee ID format: " + employeeIdStr);
                    req.getSession().setAttribute("errorMessage", "Employee ID không hợp lệ.");
                    resp.sendRedirect(req.getContextPath() + "/admin/create-user");
                    return;
                }
            }
            
            // Tạo User mới
            logger.info("Creating new user with username: " + username);
            User newUser = new User();
            newUser.setUsername(username);
            newUser.setPassword(password);
            newUser.setDisplayname(displayname);
            
            Integer userId = userDB.insertAndReturnId(newUser);
            
            logger.info("User created with ID: " + userId);
            
            if (userId == null || userId <= 0) {
                logger.severe("Failed to create user - userId is null or <= 0");
                req.getSession().setAttribute("errorMessage", "Không thể tạo User. Vui lòng thử lại.");
                resp.sendRedirect(req.getContextPath() + "/admin/create-user");
                return;
            }
            
            // Liên kết User với Employee qua Enrollment
            logger.info("Creating enrollment for userId: " + userId + ", employeeId: " + employeeId);
            boolean enrollmentCreated = userDB.createOrActivateEnrollment(userId, employeeId);
            
            logger.info("Enrollment created: " + enrollmentCreated);
            
            if (!enrollmentCreated) {
                // Xóa User vừa tạo nếu enrollment thất bại
                logger.warning("Enrollment failed, deleting user with ID: " + userId);
                userDB.deleteById(userId);
                req.getSession().setAttribute("errorMessage", "Không thể liên kết User với Employee. Vui lòng thử lại.");
                resp.sendRedirect(req.getContextPath() + "/admin/create-user");
                return;
            }
            
            // Ghi log
            LogUtil.logActivity(
                user,
                LogUtil.ActivityType.CREATE_USER,
                LogUtil.EntityType.USER,
                userId,
                "Tạo user mới: " + username,
                null,
                String.format("{\"username\":\"%s\",\"displayname\":\"%s\",\"employee_id\":%d}", 
                    username, displayname, employeeId),
                req
            );
            
            logger.info("=== User creation completed successfully ===");
            req.getSession().setAttribute("successMessage", 
                "Tạo user thành công! Username: " + username + ", Password: " + password);
            resp.sendRedirect(req.getContextPath() + "/admin/create-user");
            
        } catch (Exception e) {
            logger.severe("=== User creation failed ===");
            // Log chi tiết lỗi để debug
            logger.log(java.util.logging.Level.SEVERE, "Error creating user", e);
            
            // Log stack trace
            java.io.StringWriter sw = new java.io.StringWriter();
            java.io.PrintWriter pw = new java.io.PrintWriter(sw);
            e.printStackTrace(pw);
            logger.severe("Stack trace: " + sw.toString());
            
            String errorMsg = "Có lỗi xảy ra: " + e.getMessage();
            if (e.getCause() != null) {
                errorMsg += " (Nguyên nhân: " + e.getCause().getMessage() + ")";
            }
            req.getSession().setAttribute("errorMessage", errorMsg);
            resp.sendRedirect(req.getContextPath() + "/admin/create-user");
        }
    }
}

