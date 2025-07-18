<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*, java.util.*, java.io.*" %>
<%
    Connection conn = null;
    PreparedStatement stmt_0 = null, stmt_1 = null, stmt_2 = null, stmt_3 = null;
    PreparedStatement stmt_user = null, stmt_desc = null;
    ResultSet rs_0 = null, rs_1 = null, rs_2 = null, rs_3 = null;
    ResultSet rs_user = null, rs_desc = null;

    try {
        // ==== DB 연결정보 읽기 (WEB-INF/classes/db.properties) ====
        InputStream input = application.getResourceAsStream("/WEB-INF/classes/db.properties");
        Properties props = new Properties();
        props.load(input);

        String driver = props.getProperty("db.driver");
        String url = props.getProperty("db.url");
        String user = props.getProperty("db.username");
        String pass = props.getProperty("db.password");

        Class.forName(driver);
        conn = DriverManager.getConnection(url, user, pass);

        // ==== 파라미터로 테이블명 선택 ====
        String tableName = request.getParameter("table");
        if (tableName == null || tableName.trim().isEmpty()) {
            tableName = "db_con_test"; // 기본 테이블명
        }

        // [선택사항] 화이트리스트로 허용 테이블 제한 (보안용)
        Set<String> allowedTables = new HashSet<>(Arrays.asList("test", "user", "sample", "db_con_test"));
        if (!allowedTables.contains(tableName)) {
            out.println("<h3 style='color:red'>허용되지 않은 테이블명입니다: " + tableName + "</h3>");
            return;
        }

        // ==== 기본 정보 쿼리 실행 ====
        stmt_0 = conn.prepareStatement("select version();");
        rs_0 = stmt_0.executeQuery();

        stmt_1 = conn.prepareStatement("select database();");
        rs_1 = stmt_1.executeQuery();

        stmt_2 = conn.prepareStatement("show tables;");
        rs_2 = stmt_2.executeQuery();

        // 현재 접속 사용자 정보 조회
        stmt_user = conn.prepareStatement("select current_user();");
        rs_user = stmt_user.executeQuery();

        // 선택된 테이블의 구조 조회
        stmt_desc = conn.prepareStatement("describe " + tableName);
        rs_desc = stmt_desc.executeQuery();

        // 동적 테이블 조회
        stmt_3 = conn.prepareStatement("select * from " + tableName);
        rs_3 = stmt_3.executeQuery();
        ResultSetMetaData meta = rs_3.getMetaData();
        int colCount = meta.getColumnCount();
%>
<html>
<head>
    <meta charset="UTF-8">
    <title>DB 테스트</title>
</head>
<body>
<h2>DB 연결 테스트</h2>

<h3>DB Version</h3>
<%
    while (rs_0.next()) {
        out.println(rs_0.getString(1) + "<br>");
    }
%>

<h3>현재 Database</h3>
<%
    while (rs_1.next()) {
        out.println(rs_1.getString(1) + "<br>");
    }
%>

<h3>테이블 목록</h3>
<ul>
<%
    while (rs_2.next()) {
        out.println("<li>" + rs_2.getString(1) + "</li>");
    }
%>
</ul>

<h3>현재 접속 사용자</h3>
<%
    if (rs_user.next()) {
        out.println(rs_user.getString(1) + "<br>");
    }
%>

<h3>선택된 테이블: <%= tableName %></h3>

<h4>테이블 구조 (describe)</h4>
<table border="1" cellpadding="5" cellspacing="0">
    <thead>
        <tr>
            <th>Field</th><th>Type</th><th>Null</th><th>Key</th><th>Default</th><th>Extra</th>
        </tr>
    </thead>
    <tbody>
<%
    while (rs_desc.next()) {
        out.println("<tr>");
        for (int i=1; i<=6; i++) {
            out.println("<td>" + rs_desc.getString(i) + "</td>");
        }
        out.println("</tr>");
    }
%>
    </tbody>
</table>

<h4>테이블 데이터</h4>
<table border="1" cellpadding="5" cellspacing="0">
    <thead>
        <tr>
        <%
            for (int i = 1; i <= colCount; i++) {
                out.print("<th>" + meta.getColumnName(i) + "</th>");
            }
        %>
        </tr>
    </thead>
    <tbody>
        <%
            while (rs_3.next()) {
                out.print("<tr>");
                for (int i = 1; i <= colCount; i++) {
                    out.print("<td>" + rs_3.getString(i) + "</td>");
                }
                out.print("</tr>");
            }
        %>
    </tbody>
</table>

</body>
</html>
<%
    } catch(Exception e) {
        out.println("<h3 style='color:red'>오류 발생: " + e.getMessage() + "</h3>");
        e.printStackTrace(System.err);
    } finally {
        // ==== 리소스 정리 ====
        if (rs_0 != null) try { rs_0.close(); } catch(Exception e) {}
        if (stmt_0 != null) try { stmt_0.close(); } catch(Exception e) {}
        if (rs_1 != null) try { rs_1.close(); } catch(Exception e) {}
        if (stmt_1 != null) try { stmt_1.close(); } catch(Exception e) {}
        if (rs_2 != null) try { rs_2.close(); } catch(Exception e) {}
        if (stmt_2 != null) try { stmt_2.close(); } catch(Exception e) {}
        if (rs_3 != null) try { rs_3.close(); } catch(Exception e) {}
        if (stmt_3 != null) try { stmt_3.close(); } catch(Exception e) {}
        if (rs_user != null) try { rs_user.close(); } catch(Exception e) {}
        if (stmt_user != null) try { stmt_user.close(); } catch(Exception e) {}
        if (rs_desc != null) try { rs_desc.close(); } catch(Exception e) {}
        if (stmt_desc != null) try { stmt_desc.close(); } catch(Exception e) {}
        if (conn != null) try { conn.close(); } catch(Exception e) {}
    }
%>

