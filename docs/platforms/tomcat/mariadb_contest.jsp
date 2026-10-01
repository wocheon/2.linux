<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DB Connection Test Page</title>
</head>
<body>
<h2>DB Connection Test</h2>
<%
String dbUrl = System.getenv("DB_URL");
String dbUser = System.getenv("DB_USER");
String dbPassword = System.getenv("DB_PASSWORD");

if (dbUrl == null || dbUser == null || dbPassword == null) {
    out.println("DB_URL, DB_USER, DB_PASSWORD 환경변수를 설정하세요.");
} else {
    Class.forName("org.mariadb.jdbc.Driver");
    try (
        Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
        PreparedStatement stmt = conn.prepareStatement("SELECT id FROM test");
        ResultSet rs = stmt.executeQuery()
    ) {
%>
<table border="1">
<tr><th>id</th></tr>
<% while (rs.next()) { %>
<tr><td><%= rs.getString("id") %></td></tr>
<% } %>
</table>
<%
    }
}
%>
</body>
</html>
