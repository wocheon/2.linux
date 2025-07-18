#docker run -d \
#  --name test-mysql \
#  --network boardnet \
#  -e MYSQL_ROOT_PASSWORD=rootpass \
#  -e MYSQL_DATABASE=board \
#  -e MYSQL_USER=testuser \
#  -e MYSQL_PASSWORD=testpass \
#  -p 3306:3306 \
#  mysql:8.0
#
#sleep 2

mysql -h 127.0.0.1 -P 3306 -u testuser -ptestpass << EOF 
select now() from dual;
CREATE DATABASE IF NOT EXISTS board;
USE board;

CREATE TABLE IF NOT EXISTS board (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    writer VARCHAR(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO board (title, content, writer) VALUES ('Test title', 'Test content', 'Tester');

select * from board;

EOF
