docker rm result_page_flask -f

#	--network=host  \
docker run -d  \
	-p 80:5000  \
	-v .:/app  \
	--name result_page_flask result_page_flask:latest
