#!/bin/bash

image_name="flask_gpt_api_image"


image_exist_check=$(docker image ls | grep $image_name | wc -l)

if [ $image_exist_check -eq 0 ];then
	next_version=1
else
	last_version=$(docker image ls  | grep $image_name | gawk '{print $2}' | gawk -F'.' '{print $1}' | sort -r | head -1)
	next_version=`expr $last_version + 1`
fi

docker build -t $image_name:$next_version.0 .

if [ $image_exist_check -ne 0 ];then
	docker image rm $image_name:$last_version.0
fi

docker image ls 
