<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ page import="com.example.board.model.User" %>

<!DOCTYPE html>
<html>
<head>
    <title>게시판 목록</title>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex justify-content-between align-items-center">
            <h2 class="m-0 font-weight-bold text-primary">게시판 목록</h2>
            <a href="${pageContext.request.contextPath}/board/form" class="btn btn-primary btn-sm">새 글 작성</a>
        </div>
        <div class="card-body">
            <div class="table-responsive">
                <table class="table table-bordered table-hover">
                    <thead class="thead-light">
                        <tr>
                            <th>ID</th>
                            <th>제목</th>
                            <th>작성자</th>
                            <th>등록시간</th>
                            <th>수정</th>
                            <th>삭제</th>
                        </tr>
                    </thead>
                    <tbody>
                    <c:forEach var="b" items="${boards}">
                        <tr>
                            <td>${b.id}</td>
                            <td>
                                <a href="${pageContext.request.contextPath}/board/view?id=${b.id}" class="text-decoration-none">
                                    ${b.title}
                                </a>
                            </td>
                            <td>${b.writer}</td>
                            <td>
                                <fmt:formatDate value="${b.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                            </td>
                            <td>
                                <c:if test="${loginUser != null && (loginUser.admin || loginUser.userId == b.writer)}">
                                    <a href="${pageContext.request.contextPath}/board/form?id=${b.id}" class="btn btn-warning btn-sm">수정</a>
                                </c:if>
                            </td>
                            <td>
                                <c:if test="${loginUser != null && (loginUser.admin || loginUser.userId == b.writer)}">
                                    <form method="post" action="${pageContext.request.contextPath}/board/save" onsubmit="return confirm('정말 삭제하시겠습니까?');" style="display:inline;">
                                        <input type="hidden" name="id" value="${b.id}" />
                                        <input type="hidden" name="action" value="delete" />
                                        <button type="submit" class="btn btn-danger btn-sm">삭제</button>
                                    </form>
                                </c:if>
                            </td>                            
                        </tr>
                    </c:forEach>
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>
</body>
</html>
