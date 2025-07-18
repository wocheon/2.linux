<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<html>
<head>
    <title>BoardController 테스트</title>
</head>
<body>
    <h2>BoardController 동작 테스트</h2>
    <ul>
        <li>            
            <a href="<%= contextPath %>/board/list">/board/list로 이동</a>
        </li>
        <li>
            <a href="form">/form으로 이동 (글쓰기 폼 테스트)</a>
        </li>
        <li>
            <a href="view?id=1">/view?id=1로 이동 (상세보기 테스트)</a>
        </li>
    </ul>
    <p>아래 버튼을 누르면 컨트롤러가 호출되는지 콘솔/로그를 확인하세요.</p>
    <form action="list" method="get">
        <button type="submit">GET /list 테스트</button>
    </form>
</body>
</html>
