<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.io.*,java.util.*, javax.servlet.*" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="EUC-KR">
<title>Index Page </title>
</head>
<table border="0">
<tr>
<td>
<img src="./images/tomcat.gif">
</td>
<td>
<h1>Sample "Hello, World" Application</h1>
<p> Tomcat 및DB 연결 테스트 페이지
</td>
</tr>
</table>
<%
	Date date = new Date();
	out.print("<h2>" +date.toString()+"</h2>");
%>
<body>
<h2>Request Information</h2>

Client IP: <%= request.getRemoteAddr() %> <br>
HTTP Method: <%= request.getMethod() %> <br>

<h2>Response Information</h2>
Session ID: <%= session.getId() %> <br>
Session timeout: <%= session.getMaxInactiveInterval() %> <br>

<h2>Server Information</h2>
Server Info: <%=application.getServerInfo() %> <br>

<h3>Link1 : <a href="tomcat_info.jsp"> Tomcat Information Page </a> </h3>
<h3>Link2 : <a href="db_contest.jsp"> DB Connection Test Page </a> </h3>
<h3>Link3 : <a href="Pipelines.jsp"> Jenkins Pipeline Scripts (Markdown) </a> </h3>

</body>
</html>
