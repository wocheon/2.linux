package com.example.board.controller;

import com.example.board.dao.UserDAO;
import com.example.board.model.User;
import com.example.board.util.PasswordUtil; // 해시 유틸리티 import

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class LoginController extends HttpServlet {
    private UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. 세션에서 회원가입 성공 메시지 꺼내기
        HttpSession session = req.getSession(false);
        if (session != null) {
            String registerSuccess = (String) session.getAttribute("registerSuccess");
            if (registerSuccess != null) {
                req.setAttribute("registerSuccess", registerSuccess); // Request로 전달
                session.removeAttribute("registerSuccess"); // 세션에서는 삭제 (1회 표시)
            }
        }
    
        // 2. 로그인 JSP로 포워드
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = req.getParameter("username");
        String password = req.getParameter("password");

        try {
            User user = userDao.findByUsername(username);
            if (user != null) {
                // 입력받은 비밀번호를 해시로 변환
                String hashedInput = PasswordUtil.hashPassword(password);
                // DB의 해시값과 비교
                if (user.getUserPass().equals(hashedInput)) {
                    // 로그인 성공
                    HttpSession session = req.getSession();
                    session.setAttribute("loginUser", user);
                    resp.sendRedirect(req.getContextPath() + "/board/list");
                    return;
                }
            }
            // 로그인 실패
            req.setAttribute("error", "아이디 또는 비밀번호가 올바르지 않습니다.");
            req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
