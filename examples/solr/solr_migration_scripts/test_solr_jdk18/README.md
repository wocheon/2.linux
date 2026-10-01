# SolrJ 8 / JDK 1.8 호환성 테스트

`lib/`의 JAR 11개는 `SolrTest.java`를 Maven 없이 직접 컴파일·실행하기 위한 오프라인 의존성입니다. 따라서 이 테스트 구조에서는 **필요하여 유지**합니다. 서버의 Solr 버전과 SolrJ 8.11.2의 호환성은 별도로 확인하세요. 디렉터리 이름의 `jdk18`은 소스의 JDK 1.8 테스트 표기를 가리킵니다.

```bash
javac -cp 'lib/*' SolrTest.java
java -cp '.:lib/*' SolrTest
```

Windows Git Bash에서는 classpath 구분자 `:` 대신 `;`가 필요할 수 있습니다. 연결 주소와 삭제 대상은 실행 전에 소스를 확인하세요.
