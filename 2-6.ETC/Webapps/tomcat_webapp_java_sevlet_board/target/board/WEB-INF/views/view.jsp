<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<div class="container mt-5">
    <div class="card shadow mb-4">
        <div class="card-header py-3 d-flex justify-content-between align-items-center">
            <h3 class="m-0 font-weight-bold text-primary">게시글 상세</h3>
            <a href="${pageContext.request.contextPath}/board/list" class="btn btn-secondary btn-sm">목록으로</a>
        </div>
        <div class="card-body">
            <dl class="row">
                <dt class="col-sm-2">제목</dt>
                <dd class="col-sm-10">${board.title}</dd>

                <dt class="col-sm-2">작성자</dt>
                <dd class="col-sm-10">${board.writer}</dd>

                <dt class="col-sm-2">내용</dt>
                <dd class="col-sm-10" style="white-space: pre-wrap;">${board.content}</dd>
            </dl>
            <div class="d-flex justify-content-between mt-4">
                <div>
                    <c:if test="${prevId > 0}">
                        <a href="${pageContext.request.contextPath}/board/view?id=${prevId}" class="btn btn-outline-info btn-sm mr-2">이전글</a>
                    </c:if>
                    <c:if test="${nextId > 0}">
                        <a href="${pageContext.request.contextPath}/board/view?id=${nextId}" class="btn btn-outline-info btn-sm">다음글</a>
                    </c:if>
                </div>
                <a href="${pageContext.request.contextPath}/board/list" class="btn btn-secondary btn-sm">목록으로</a>
            </div>
        </div>
    </div>
</div>
