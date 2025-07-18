<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
    com.example.board.model.User loginUser = (com.example.board.model.User) session.getAttribute("loginUser");
%>
<head>
    <meta charset="UTF-8" />
    <title>게시판</title>
    <!-- Bootstrap CSS -->
    <!-- <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css" /> -->
    <!-- Bootstrap CSS (local) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/bootstrap.min.css" />
    <!-- SB Admin 2 CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/sb-admin-2.min.css" />
    <!-- DataTables CSS (필요시) -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/dataTables.bootstrap4.min.css" />
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/resources/css/style.css" />
</head>
<body>
<nav class="navbar navbar-expand navbar-light bg-white topbar mb-4 static-top shadow">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/board/list">게시판</a>
        <span class="ml-3 text-muted" style="font-size: 0.9rem;">
            <fmt:formatDate value="<%= new java.util.Date() %>" pattern="yyyy-MM-dd HH:mm:ss" />
        </span>
        <div class="ml-auto d-flex align-items-center">
            <c:choose>
                <c:when test="${not empty loginUser}">
                    <span class="mr-3">
                        안녕하세요, 
                        <c:if test="${loginUser.admin}">
                            <span class="badge badge-danger ml-2">관리자</span>
                        </c:if>
                        <strong>${loginUser.userName}</strong> 님
                    </span>
                    <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-secondary btn-sm">로그아웃</a>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="btn btn-outline-primary btn-sm me-2">로그인</a>
                    <a href="${pageContext.request.contextPath}/register" class="btn btn-outline-primary btn-sm">회원가입</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</nav>
<!-- 이후 본문 내용이 들어감 -->
