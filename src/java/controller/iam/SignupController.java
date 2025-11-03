package controller.iam;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebServlet(urlPatterns = "/signup")
public class SignupController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String displayname = req.getParameter("displayname");
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        if (displayname == null || username == null || password == null
                || displayname.isBlank() || username.isBlank() || password.isBlank()) {
            req.setAttribute("message", "Vui lòng nhập đầy đủ thông tin.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }

        dal.UserDBContext dbCheck = new dal.UserDBContext();
        if (dbCheck.existsByUsername(username)) {
            req.setAttribute("message", "Tên đăng nhập đã tồn tại. Vui lòng chọn tên khác.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }
        
        // Kiểm tra độ dài mật khẩu
        if (password.length() < 6) {
            req.setAttribute("message", "Mật khẩu phải có ít nhất 6 ký tự.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }

        // 1) Tạo Employee mới với EID tự động (không trùng lặp)
        dal.EmployeeDBContext empDb = new dal.EmployeeDBContext();
        model.Employee newEmp = new model.Employee();
        newEmp.setName(displayname);
        int eid = empDb.insertAndReturnId(newEmp);
        
        if (eid <= 0) {
            java.util.logging.Logger.getLogger(SignupController.class.getName()).log(java.util.logging.Level.SEVERE, 
                "Failed to create employee. Displayname: " + displayname);
            req.setAttribute("message", "Không thể tạo mã nhân viên. Vui lòng kiểm tra log server hoặc liên hệ quản trị viên.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }

        // 2) Tạo user và lấy uid
        model.iam.User u = new model.iam.User();
        u.setDisplayname(displayname);
        u.setUsername(username);
        u.setPassword(password);
        
        dal.UserDBContext dbInsert = new dal.UserDBContext();
        Integer uid = dbInsert.insertAndReturnId(u);
        if (uid == null) {
            req.setAttribute("message", "Không thể tạo tài khoản. Vui lòng thử lại.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }
        
        // 3) Liên kết Enrollment active=1 với EID vừa tạo
        dal.UserDBContext dbEnroll = new dal.UserDBContext();
        boolean enrollmentCreated = dbEnroll.createOrActivateEnrollment(uid, eid);
        if (!enrollmentCreated) {
            // Nếu enrollment thất bại, xóa user và employee vừa tạo
            dbInsert.deleteById(uid);
            req.setAttribute("message", "Không thể liên kết mã nhân viên. Vui lòng thử lại hoặc liên hệ quản trị viên.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }

        // 4) Đăng nhập ngay
        dal.UserDBContext dbLogin = new dal.UserDBContext();
        model.iam.User logged = dbLogin.get(username, password);
        if (logged != null) {
            jakarta.servlet.http.HttpSession session = req.getSession();
            session.setAttribute("auth", logged);
            resp.sendRedirect(req.getContextPath() + "/home");
            return;
        }

        req.setAttribute("message", "Đăng ký thành công nhưng không thể đăng nhập tự động. Hãy thử đăng nhập.");
        req.getRequestDispatcher("/view/auth/login.jsp").forward(req, resp);
    }
}


