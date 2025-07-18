<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.lang.management.ManagementFactory, java.lang.management.RuntimeMXBean, java.util.Properties" %>
<html>
<head><title>Tomcat 서버 정보</title></head>
<body>
<h2>Tomcat 서버 정보</h2>

<p><strong>서버 정보:</strong> <%= application.getServerInfo() %></p>

<h3>JVM 정보</h3>
<%
    RuntimeMXBean runtimeMXBean = ManagementFactory.getRuntimeMXBean();
%>
<ul>
    <li>Java 버전: <%= System.getProperty("java.version") %></li>
    <li>Java 공급자: <%= System.getProperty("java.vendor") %></li>
    <li>JVM 이름: <%= runtimeMXBean.getVmName() %></li>
    <li>JVM 버전: <%= runtimeMXBean.getVmVersion() %></li>
    <li>JVM 시작 시간: <%= new java.util.Date(runtimeMXBean.getStartTime()) %></li>
    <li>JVM 실행 시간 (ms): <%= runtimeMXBean.getUptime() %></li>
    <li>JVM 입력 인자: <%= runtimeMXBean.getInputArguments() %></li>
</ul>

<h3>시스템 프로퍼티</h3>
<table border="1" cellpadding="3" cellspacing="0">
    <thead>
        <tr><th>Key</th><th>Value</th></tr>
    </thead>
    <tbody>
<%
    Properties sysProps = System.getProperties();
    for (String key : sysProps.stringPropertyNames()) {
%>
        <tr>
            <td><%= key %></td>
            <td><%= sysProps.getProperty(key) %></td>
        </tr>
<%
    }
%>
    </tbody>
</table>

</body>
</html>

