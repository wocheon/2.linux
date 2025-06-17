#!/bin/bash

#1. ${BASH_SOURCE[0]}를 이용한 방법 (권장)
#${BASH_SOURCE[0]}: 현재 실행 중인 스크립트 파일의 경로를 반환
#dirname: 경로에서 디렉터리 부분만 추출
#cd ... && pwd: 해당 디렉터리로 이동한 후 절대 경로를 학인
#이 방법은 스크립트가 심볼릭 링크로 실행될 때도 정상적으로 동작

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "현재 스크립트 위치: $SCRIPT_DIR"



#2. $0을 이용한 방법 (심볼릭 링크 고려 X)
#이 방법은 심볼릭 링크로 실행된 경우 원본 경로가 아니라 링크된 위치를 반환 가능
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
echo "현재 스크립트 위치: $SCRIPT_DIR"


# 3. 심볼릭 링크까지 해석하는 방법 (가장 정확)
# realpath를 사용하면 심볼릭 링크를 따라가 원본 경로를 정확히 확인가능
3. 심볼릭 링크까지 해석하는 방법 (가장 정확)
SCRIPT_PATH="$(realpath "${BASH_SOURCE[0]}")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"
echo "현재 스크립트 위치: $SCRIPT_DIR"
