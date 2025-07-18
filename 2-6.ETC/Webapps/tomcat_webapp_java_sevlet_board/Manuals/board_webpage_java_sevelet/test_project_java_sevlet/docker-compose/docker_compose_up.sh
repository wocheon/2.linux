#!/bin/bash

cd /root/board_webpage/maven/test_project_java_sevlet

mvn clean package -DskipTests

if [ $? -ne 0 ]; then
	echo "mvn error"
	exit 0
fi

cd /root/board_webpage/maven/test_project_java_sevlet/docker-compose 
rm -rf board.war

cp ../target/board.war .

docker-compose down 

sleep 0.5

docker-compose up -d 
