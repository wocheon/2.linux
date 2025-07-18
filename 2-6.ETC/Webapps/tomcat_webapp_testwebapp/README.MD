# Tomcat Test용 Webapp 

## 용도 
- 기본 webapp에 DB연결 및 내용출력을 가능하도록 구성한 Webapp
- mariadb-java-client.jar 혹은 mysql-connector-java.jar 필요 
    - packages에 포함

- 동일 기능의 Bootstrap 적용 페이지 포함

## 사용 방법 

- DB 내 test용 Database, Table 생성 
```sql
CREATE DATABASE IF NOT EXISTS tomcat;

CREATE TABLE IF NOT EXISTS  `db_con_test` (
  `col1` int NOT NULL AUTO_INCREMENT,
  `col2` varchar(10) DEFAULT NULL,
  `col3` datetime DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`col1`));

INSERT INTO db_con_test (col2) values ('testdata');
```

- src/main/resources/db.properties 파일 내 DB 연결 주소를 변경
    - DBMS 별로 다른 드라이버를 사용하므로 주의
```
# MariaDB Setting
#db.driver=org.mariadb.jdbc.Driver
#db.url=jdbc:mariadb://127.0.0.1:3306/tomcat

# MySQL Setting
db.driver=com.mysql.cj.jdbc.Driver
db.url=jdbc:mysql://mysqldb:3306/tomcat?useSSL=false&serverTimezone=Asia/Seoul&allowPublicKeyRetrieval=true

db.username=root
db.password=rootpass
```


- WAR 파일로 패키징 
```
mvn clean package
```

- testwebapp.war를 Tomcat Webapp에 배포
```
cp ./target/testwebapp.war $CATALINA_HOME/webapps
systemctl restart tomcat
```

