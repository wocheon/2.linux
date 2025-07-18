package com.example.board.controller;

import com.example.board.model.Board;
import com.example.board.model.User;
import com.example.board.service.BoardService;

import javax.servlet.*;
import javax.servlet.http.*;
import java.io.IOException;
import java.util.List;

public class BoardController extends HttpServlet {
    private BoardService service = new BoardService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        String path = req.getPathInfo(); // e.g., /list, /view

        try {
            if (path == null || "/".equals(path)) {
                List<Board> boards = service.listBoards();
                req.setAttribute("boards", boards);
                RequestDispatcher dispatcher = req.getRequestDispatcher("/WEB-INF/views/list.jsp");
                dispatcher.forward(req, resp);
            } else if ("/list".equals(path)) {
                List<Board> boards = service.listBoards();
                req.setAttribute("boards", boards);
                RequestDispatcher dispatcher = req.getRequestDispatcher("/WEB-INF/views/list.jsp");
                dispatcher.forward(req, resp);
            } else if ("/form".equals(path)) {
                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isEmpty()) {
                    int id = Integer.parseInt(idParam);
                    Board board = service.getBoard(id);

                    // 권한 체크 (관리자 또는 작성자 본인만)
                    HttpSession session = req.getSession(false);
                    User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;
                    if (loginUser == null || (!loginUser.isAdmin() && !loginUser.getUserId().equals(board.getWriter()))) {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "권한이 없습니다.");
                        return;
                    }

                    req.setAttribute("board", board);
                }
                RequestDispatcher dispatcher = req.getRequestDispatcher("/WEB-INF/views/form.jsp");
                dispatcher.forward(req, resp);
            } else if ("/view".equals(path)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Board board = service.getBoard(id);
                int prevId = service.getPrevId(id);
                int nextId = service.getNextId(id);

                req.setAttribute("board", board);
                req.setAttribute("prevId", prevId);
                req.setAttribute("nextId", nextId);

                RequestDispatcher dispatcher = req.getRequestDispatcher("/WEB-INF/views/view.jsp");
                dispatcher.forward(req, resp);
            } else {
                resp.sendError(HttpServletResponse.SC_NOT_FOUND);
            }
        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setContentType("text/html; charset=UTF-8");

        String action = req.getParameter("action"); // "update", "delete", or null(등록)

        try {
            HttpSession session = req.getSession(false);
            User loginUser = (session != null) ? (User) session.getAttribute("loginUser") : null;

            if ("delete".equals(action)) {
                int id = Integer.parseInt(req.getParameter("id"));
                Board board = service.getBoard(id);

                // 권한 체크 (관리자 또는 작성자 본인만)
                if (loginUser != null && (loginUser.isAdmin() || loginUser.getUserId().equals(board.getWriter()))) {
                    service.deleteBoard(id);
                } else {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "권한이 없습니다.");
                    return;
                }

            } else {
                Board b = new Board();

                String idParam = req.getParameter("id");
                if (idParam != null && !idParam.isEmpty()) {
                    b.setId(Integer.parseInt(idParam));
                }

                b.setTitle(req.getParameter("title"));
                b.setContent(req.getParameter("content"));

                // 등록/수정 시 작성자 정보
                if (loginUser != null) {
                    b.setWriter(loginUser.getUserId());
                } else {
                    resp.sendError(HttpServletResponse.SC_FORBIDDEN, "로그인이 필요합니다.");
                    return;
                }

                if ("update".equals(action)) {
                    Board oldBoard = service.getBoard(b.getId());
                    // 권한 체크 (관리자 또는 작성자 본인만)
                    if (loginUser.isAdmin() || loginUser.getUserId().equals(oldBoard.getWriter())) {
                        service.updateBoard(b);
                    } else {
                        resp.sendError(HttpServletResponse.SC_FORBIDDEN, "권한이 없습니다.");
                        return;
                    }
                } else {
                    service.addBoard(b); // 등록
                }
            }

            resp.sendRedirect(req.getContextPath() + "/board/list");

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }
}
