# Board Webpage 용 MySQL Docker Container 세팅 
- 구성 과정에서 테스트를 위해 MySQL 서버를 별도로 두지않고 docker Container를 활용

## MySQL docker Container 실행

- docker 컨테이너용 Network 생성

```sh
docker network create boardnet
```

- MySQL docker Container 생성

```sh
docker run -d \
  --name test-mysql \
  --network boardnet \
  -e MYSQL_ROOT_PASSWORD=rootpass \
  -e MYSQL_DATABASE=board \
  -e MYSQL_USER=testuser \
  -e MYSQL_PASSWORD=testpass \
  -p 3306:3306 \
  mysql:8.0
```


## Java_Sevelet 앱을 위한 MySQL 테이블 세팅

- MySQL 컨테이너 접근 
```
mysql -h 127.0.0.1 -P 3306 -u testuser -ptestpass 
```

- board 데이터베이스 생성

```
CREATE DATABASE IF NOT EXISTS board;
USE board;
```

- board.board 테이블 생성
```sql
CREATE TABLE IF NOT EXISTS board (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    writer VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

- board.user 테이블 생성 

```sql
CREATE TABLE IF NOT EXISTS `user` (
  `id` int NOT NULL AUTO_INCREMENT,
  `user_id` varchar(50) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `user_name` varchar(50) DEFAULT NULL,
  `user_email` varchar(100) DEFAULT NULL,
  `is_admin` tinyint(1) NOT NULL DEFAULT '0',
  `last_login` datetime DEFAULT NULL,
  `created_at` datetime DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `username` (`user_id`)

```


- 테스트용 초기 데이터 Insert 
    - 사용자는 회원가입 페이지에서 생성 하여 사용

```sql
-- 테스트용 게시물 insert 
INSERT INTO board.board (title, content, writer) VALUES ('Test title', 'Test content', 'tester');
```

