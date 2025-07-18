#!/bin/bash

cp ../target/board.war .

docker build -t tomcat-sample .

docker run -d -p 8080:8080 --network boardnet  --name tomcat-sample-container tomcat-sample
