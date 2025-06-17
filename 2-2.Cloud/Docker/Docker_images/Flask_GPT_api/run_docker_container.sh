#!/bin/bash

docker_image_name="flask_gpt_api_image"
image_version=$(docker image ls | grep $docker_image_name | gawk '{print $2}')

# docker run config
container_run_option="d" # "d/it"
container_port_mapping="80:5000"
container_name="flask_gpt_api_container"
container_env='-e OPENAI_API_KEY=[OpenAI_Secret_key]'


docker run -${container_run_option} -p ${container_port_mapping} --name ${container_name} $container_env $docker_image_name:$image_version

