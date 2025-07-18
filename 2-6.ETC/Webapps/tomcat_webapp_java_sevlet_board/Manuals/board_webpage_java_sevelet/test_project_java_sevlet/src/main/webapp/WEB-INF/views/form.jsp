<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html>
<head>
    <title>${board != null ? "게시글 수정" : "게시글 등록"}</title>
</head>
<body>
<div class="container mt-5">
    <div class="card shadow mb-4">
        <div class="card-header py-3">
            <h2 class="m-0 font-weight-bold text-primary">${board != null ? "게시글 수정" : "게시글 등록"}</h2>
        </div>
        <div class="card-body">
            <form method="post" action="${pageContext.request.contextPath}/board/save">
                <c:if test="${board != null}">
                    <input type="hidden" name="id" value="${board.id}" />
                    <input type="hidden" name="action" value="update" />
                </c:if>
                <div class="form-group">
                    <label>제목</label>
                    <input type="text" name="title" value="${board.title}" required class="form-control" />
                </div>
                <div class="form-group">
                    <label>내용</label>
                    <textarea name="content" rows="5" required class="form-control">${board.content}</textarea>
                </div>
                <div class="form-group">
                    <label>작성자</label>
                    <!-- <input type="text" name="writer" value="${board.writer}" required class="form-control" readonly/> -->
                    <input type="text" name="writer" value="${empty board ? loginUser.userId : board.writer}" required class="form-control" readonly/>
                </div>
                <!-- 버튼 영역: 한 줄로 배치 -->
                <div class="mt-3">
                    <button type="submit" class="btn btn-primary">${board != null ? "수정" : "등록"}</button>                    
                    <c:if test="${board != null}">
                        <form method="post" action="${pageContext.request.contextPath}/board/save" onsubmit="return confirm('정말 삭제하시겠습니까?');" style="display:inline;">
                            <input type="hidden" name="id" value="${board.id}" />
                            <input type="hidden" name="action" value="delete" />
                            <button type="submit" class="btn btn-danger">삭제</button>
                        </form>
                    </c:if>
                    <a href="${pageContext.request.contextPath}/board/list" class="btn btn-secondary">목록으로</a>
                </div>
            </form>
        </div>
    </div>
</div>
</body>
</html>