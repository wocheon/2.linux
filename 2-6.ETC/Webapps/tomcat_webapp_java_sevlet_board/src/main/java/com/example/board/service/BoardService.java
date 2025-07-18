package com.example.board.service;

import com.example.board.dao.BoardDAO;
import com.example.board.model.Board;
import java.sql.SQLException;
import java.util.*;

public class BoardService {
    private BoardDAO dao = new BoardDAO();

    public List<Board> listBoards() throws Exception {
        return dao.findAll();
    }

    public void addBoard(Board b) throws Exception {
        dao.insert(b);
    }

    public Board getBoard(int id) throws SQLException {
        return dao.findById(id);
    }
    
    public int getPrevId(int id) throws SQLException {
        return dao.findPrevId(id);
    }
    
    public int getNextId(int id) throws SQLException {
        return dao.findNextId(id);
    }

    public void deleteBoard(int id) throws SQLException {
        dao.delete(id);
    }    

    public void updateBoard(Board b) throws SQLException {
        BoardDAO dao = new BoardDAO();
        dao.update(b);
    }
}
