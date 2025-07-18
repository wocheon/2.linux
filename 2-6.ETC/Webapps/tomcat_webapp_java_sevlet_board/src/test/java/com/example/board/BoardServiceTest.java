package com.example.board;

import com.example.board.model.Board;
import com.example.board.service.BoardService;
import org.junit.Test;
import java.util.List;

import static org.junit.Assert.*;

public class BoardServiceTest {
    @Test
    public void testListBoards() throws Exception {
        BoardService service = new BoardService();
        List<Board> boards = service.listBoards();
        assertNotNull(boards);
    }
}
