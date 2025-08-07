#!/bin/bash
docker rm selenium_crawler_test -f

docker run -d --network=host  \
	-v ./log:/app/log \
	--name selenium_crawler_test selenium_crawler_test:latest

docker logs selenium_crawler_test -f
