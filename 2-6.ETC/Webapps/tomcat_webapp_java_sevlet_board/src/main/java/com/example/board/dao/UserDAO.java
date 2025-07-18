package com.example.board.dao;

import com.example.board.model.User;
import java.sql.*;
import java.util.Properties;
import java.io.InputStream;

public class UserDAO {

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

    public User findByUsername(String userId) throws SQLException {
        String sql = "SELECT * FROM user WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User u = new User();
                    u.setId(rs.getInt("id"));
                    u.setUserId(rs.getString("user_id"));
                    u.setUserPass(rs.getString("password_hash"));
                    u.setUserName(rs.getString("user_name"));
                    u.setIsAdmin(rs.getInt("is_admin") == 1); // 또는 rs.getBoolean("is_admin)"
                    return u;
                }
            }
        }
        return null;
    }

    public boolean insertUser(User user) {
        String sql = "INSERT INTO user (user_id, password_hash, user_name, user_email) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, user.getUserId());
            pstmt.setString(2, user.getUserPass()); // 반드시 해시된 비밀번호 사용
            pstmt.setString(3, user.getUserName());
            pstmt.setString(4, user.getUserEmail());
            int affected = pstmt.executeUpdate();
            return affected == 1;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }    

    public boolean isUsernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM user WHERE user_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
