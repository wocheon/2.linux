package com.example.board.dao;

import com.example.board.model.Board;
import com.example.board.model.User;

import java.sql.*;
import java.time.Instant;
import java.util.*;
import java.io.InputStream;

public class BoardDAO {

    private Connection getConnection() throws SQLException {
        Properties props = new Properties();
        try (InputStream input = getClass().getClassLoader().getResourceAsStream("db.properties")) {
            if (input == null) {
                throw new RuntimeException("db.properties 파일을 찾을 수 없습니다.");
            }
            props.load(input);
        } catch (Exception e) {
            throw new RuntimeException("DB 설정 로딩 실패", e);
        }

        String url = props.getProperty("db.url");
        String username = props.getProperty("db.username");
        String password = props.getProperty("db.password");

        return DriverManager.getConnection(url, username, password);
    }

    public List<Board> findAll() throws SQLException {
        String sql = "SELECT * FROM board ORDER BY id DESC";
        List<Board> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Board b = new Board();
                b.setId(rs.getInt("id"));
                b.setTitle(rs.getString("title"));
                b.setContent(rs.getString("content"));
                b.setWriter(rs.getString("writer"));
		b.setCreatedAt(rs.getTimestamp("created_at"));
                list.add(b);
            }
        }
        return list;
    }

    public void insert(Board b) throws SQLException {
        String sql = "INSERT INTO board (title, content, writer, created_at) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getContent());
            ps.setString(3, b.getWriter());
            ps.setTimestamp(4, Timestamp.from(Instant.now())); // JVM 기본 시간대 기준 현재 시간
            ps.executeUpdate();
        }
    }

    public Board findById(int id) throws SQLException {
        String sql = "SELECT * FROM board WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Board b = new Board();
                    b.setId(rs.getInt("id"));
                    b.setTitle(rs.getString("title"));
                    b.setContent(rs.getString("content"));
                    b.setWriter(rs.getString("writer"));
                    return b;
                }
            }
        }
        return null;
    }

    public int findPrevId(int id) throws SQLException {
        String sql = "SELECT id FROM board WHERE id < ? ORDER BY id DESC LIMIT 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        return 0;
    }

    public int findNextId(int id) throws SQLException {
        String sql = "SELECT id FROM board WHERE id > ? ORDER BY id ASC LIMIT 1";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        }
        return 0;
    }
    public void delete(int id) throws SQLException {
        String sql = "DELETE FROM board WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            pstmt.executeUpdate();
        }
    }    

    public void update(Board b) throws SQLException {
        String sql = "UPDATE board SET title = ?, content = ?, writer = ? WHERE id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, b.getTitle());
            ps.setString(2, b.getContent());
            ps.setString(3, b.getWriter());
            ps.setInt(4, b.getId());
            ps.executeUpdate();
        }
    }
}