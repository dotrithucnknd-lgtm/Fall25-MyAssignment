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
        String eidRaw = req.getParameter("eid");

        if (displayname == null || username == null || password == null || eidRaw == null
                || displayname.isBlank() || username.isBlank() || password.isBlank() || eidRaw.isBlank()) {
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

        int eid;
        try { eid = Integer.parseInt(eidRaw); }
        catch (NumberFormatException ex) {
            req.setAttribute("message", "EID không hợp lệ.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }

        model.iam.User u = new model.iam.User();
        u.setDisplayname(displayname);
        u.setUsername(username);
        u.setPassword(password);

        // 1) Tạo user và lấy uid
        dal.UserDBContext dbInsert = new dal.UserDBContext();
        Integer uid = dbInsert.insertAndReturnId(u);
        if (uid == null) {
            req.setAttribute("message", "Không thể tạo tài khoản. Vui lòng thử lại.");
            req.getRequestDispatcher("/view/auth/signup.jsp").forward(req, resp);
            return;
        }
        // 2) Liên kết Enrollment active=1 theo EID được nhập
        dal.UserDBContext dbEnroll = new dal.UserDBContext();
        dbEnroll.createOrActivateEnrollment(uid, eid);

        // 3) Đăng nhập ngay
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


