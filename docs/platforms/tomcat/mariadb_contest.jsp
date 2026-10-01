<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DB Connection Test Page</title>
</head>
<body>

<%	
	//mariaDB 준비
	Class.forName("org.mariadb.jdbc.Driver");
	System.out.println("mariadb 사용가능");
	
	// mariaDB 연결
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/tomcat","root","welcome1");
	System.out.println(conn + "<-- conn");
	
	// 쿼리_0
	PreparedStatement stmt_0 = conn.prepareStatement("select version();");
	
	// 쿼리_0 실행
	ResultSet rs_0 = stmt_0.executeQuery();

	// 쿼리_1
	PreparedStatement stmt_1 = conn.prepareStatement("select database();");
	System.out.println(stmt_1 + "<-- stmt_1");
	
	// 쿼리_1 실행
	ResultSet rs_1 = stmt_1.executeQuery();


	// 쿼리_2
	PreparedStatement stmt_2 = conn.prepareStatement("show tables;");
	System.out.println(stmt_2 + "<-- stmt_2");
	// 쿼리_2 실행
	ResultSet rs_2 = stmt_2.executeQuery();


	// 쿼리_3
	PreparedStatement stmt_3 = conn.prepareStatement("select * from test");
	System.out.println(stmt_3 + "<-- stmt_3");
	
	// 쿼리_2 실행
	ResultSet rs_3 = stmt_3.executeQuery();
	
%>
<center>
	<p style="font-size:25px; color:white; background-color:black; font-family:Cominc Sans MS;">
		DB Connection Test Page
	</p>
</center>


<h2>[DB Info] </h2>
<%while(rs_0.next()){%>
<h3>&nbsp;-Database Version : <%=rs_0.getString("version()") %></h3>
<%}%>

<%while(rs_1.next()){%>
<h3>&nbsp;-Database : <%=rs_1.getString("database()") %></h3>
<%}%>

<hr>
<h2>[Table Info] </h2>
<%while(rs_2.next()){%>
<h3>&nbsp;-Tablename : <%=rs_2.getString("Tables_in_tomcat") %></h3>
<%}%>


<p style="color:blue;"><b>&nbsp;-Table Contents </b></p>
<table border="1">
	<tr>
	<td><b>id</b></td>
	<td><b>pw</b></td>
	</tr>
		
	<tr>
	<%while(rs_3.next()){%>
		<td><%=rs_3.getString("id") %></td>
		<td><%=rs_3.getString("pw") %></td>
	<%}%>
	</tr>
				
	</table>
 
</body>
</html>
