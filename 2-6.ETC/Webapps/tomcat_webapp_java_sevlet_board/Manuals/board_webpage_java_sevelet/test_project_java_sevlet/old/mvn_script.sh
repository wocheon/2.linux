#!/bin/bash

# 1. 클린(clean) — 이전 빌드 결과 삭제
mvn clean

# 2. 컴파일(compile) — 자바 소스 컴파일
mvn compile

# 3. 테스트(test) — 단위 테스트 실행
mvn test

#4. 패키징(package) — WAR 파일 생성
mvn package

# OR 
# 한 번에 빌드부터 테스트, 패키징까지 실행
#mvn clean package
