package controller.request;

import controller.iam.BaseRequiredAuthenticationController;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import model.RequestForLeaveHistory;
import model.iam.User;

@WebServlet(urlPatterns="/request/history")
public class HistoryController extends BaseRequiredAuthenticationController {

    private void process(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ridRaw = req.getParameter("rid");
        if (ridRaw == null) {
            resp.sendRedirect(req.getContextPath() + "/request/list");
            return;
        }
        int rid = Integer.parseInt(ridRaw);
        dal.RequestForLeaveHistoryDBContext db = new dal.RequestForLeaveHistoryDBContext();
        ArrayList<RequestForLeaveHistory> logs = db.listByRequestId(rid);
        req.setAttribute("logs", logs);
        req.setAttribute("rid", rid);
        req.getRequestDispatcher("/view/request/history.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        process(req, resp);
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp, User user) throws ServletException, IOException {
        process(req, resp);
    }
}

