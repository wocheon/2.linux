#!/bin/bash
array=(1 "A" 2 "B" 3 "C")

# 인덱스 미지정 - 첫번째 값이 출력
echo $array

# 배열중 첫번째 값을 출력
echo ${array[0]}

# 배열중 두번째 값을 출력
echo ${array[1]}

# 배열중 세번째 값을 출력
echo ${array[2]}

# 배열에 할당된 모든 값을 출력
echo ${array[@]}
