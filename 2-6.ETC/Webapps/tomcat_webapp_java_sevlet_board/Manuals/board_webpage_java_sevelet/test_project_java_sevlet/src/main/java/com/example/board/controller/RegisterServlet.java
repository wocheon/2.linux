// RegisterServlet.java
package com.example.board.controller;

import com.example.board.dao.UserDAO;
import com.example.board.model.User;
import com.example.board.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    private UserDAO UserDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 회원가입 폼 페이지로 포워딩
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html; charset=UTF-8");

        // 폼 데이터 받기
        String user_id = request.getParameter("username");
        String user_pass = request.getParameter("password");
        String user_name = request.getParameter("name");
        String user_email = request.getParameter("email");

        // 간단한 유효성 검사(필수)
        if (user_id == null || user_pass == null || user_name == null ||
        user_id.isEmpty() || user_pass.isEmpty() || user_name.isEmpty() || user_email.isEmpty()) {
            request.setAttribute("error", "모든 필드를 입력해 주세요.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // 중복 아이디 체크
        if (UserDAO.isUsernameExists(user_id)) {
            request.setAttribute("error", "이미 존재하는 아이디입니다.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }


        // 패스워드 규칙 안내 - 예시: 8자 이상, 영문/숫자/특수문자 포함
        if (!isValidPassword(user_pass)) {
            request.setAttribute("error", "비밀번호는 8자 이상, 영문/숫자/특수문자를 모두 포함해야 합니다.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        // 비밀번호 해시 처리
        String hashedPassword = PasswordUtil.hashPassword(user_pass);

        // User 객체 생성 및 저장
        User user = new User();
        user.setUserId(user_id);
        user.setUserPass(hashedPassword);
        user.setUserName(user_name);
        user.setUserEmail(user_email);

        boolean success = UserDAO.insertUser(user);

        if (success) {
            // 회원가입 성공 후 로그인 페이지로 리다이렉트
            request.getSession().setAttribute("registerSuccess", "회원가입이 완료되었습니다. 로그인 해주세요!");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("error", "회원가입 중 오류가 발생했습니다.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }

    // 패스워드 규칙 설정 매서드 
    // 패스워드 규칙 : 8자 이상, 영문/숫자/특수문자 포함
    private boolean isValidPassword(String password) {
        if (password == null) return false;
        boolean length = password.length() >= 8;
        boolean letter = password.matches(".*[a-zA-Z].*");
        boolean digit = password.matches(".*\\d.*");
        boolean special = password.matches(".*[!@#$%^&*()_+\\-=`~\\[\\]{};':\",.<>/?].*");
        return length && letter && digit && special;
    }
}
