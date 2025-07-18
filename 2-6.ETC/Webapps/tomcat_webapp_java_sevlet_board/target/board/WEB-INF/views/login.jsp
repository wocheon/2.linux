<%@ include file="/WEB-INF/views/common/header.jsp" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<div class="container" style="max-width: 380px; margin: 80px auto;">
    <div class="card shadow-sm">
        <div class="card-body">
            <h3 class="mb-4 text-center font-weight-bold">로그인</h3>
            
            <% if (request.getAttribute("registerSuccess") != null) { %>
                <div class="alert alert-success">
                    <%= request.getAttribute("registerSuccess") %>
                </div>
            <% } %>

            <c:if test="${not empty error}">
                <div class="alert alert-danger" role="alert">
                    ${error}
                </div>
            </c:if>
            <form method="post" action="${pageContext.request.contextPath}/login">
                <div class="form-group">
                    <label for="username">아이디</label>
                    <input type="text" class="form-control" id="username" name="username" placeholder="아이디를 입력하세요" required autofocus>
                </div>
                <div class="form-group">
                    <label for="password">비밀번호</label>
                    <input type="password" class="form-control" id="password" name="password" placeholder="비밀번호를 입력하세요" required>
                </div>
                <button type="submit" class="btn btn-primary btn-block">로그인</button>
            </form>
        </div>
    </div>
</div>
