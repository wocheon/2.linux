package com.example.board.filter;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;

public class LoginCheckFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        boolean isLoginPage = uri.endsWith("/login") || uri.endsWith("/login.jsp");
        boolean isLogoutPage = uri.endsWith("/logout");
        boolean isSignupPage = uri.endsWith("/signup") || uri.endsWith("/register") || uri.endsWith("/register.jsp");
        boolean isStatic = uri.contains("/resources/"); // CSS/JS/이미지 등
        boolean isIndex = uri.endsWith("/index.jsp") || uri.equals(req.getContextPath() + "/");

        // 회원가입, 로그인, 로그아웃, 정적 리소스, 인덱스는 예외로 허용
        if (isLoginPage || isLogoutPage || isSignupPage || isStatic || isIndex) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        Object loginUser = (session == null) ? null : session.getAttribute("loginUser");
        if (loginUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        chain.doFilter(request, response);
    }
}