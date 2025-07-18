<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<html>
<head>
    <title>게시글 수정</title>
</head>
<body>
<h2>게시글 수정</h2>
<form method="post" action="${pageContext.request.contextPath}/board/edit?id=${board.id}">
    제목: <input type="text" name="title" value="${board.title}" /><br/>
    작성자: <input type="text" name="writer" value="${board.writer}" /><br/>
    내용: <textarea name="content">${board.content}</textarea><br/>
    <input type="submit" value="수정" />
</form>
<a href="${pageContext.request.contextPath}/board/list">목록으로 돌아가기</a>
</body>
</html>