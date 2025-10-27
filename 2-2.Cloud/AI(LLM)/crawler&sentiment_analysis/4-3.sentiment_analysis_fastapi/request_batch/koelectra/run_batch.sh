docker rm koelectra_request_batch -f

docker run -d --network=mariadb-network --name koelectra_request_batch \
        -v "$(pwd)":/app  \
        koelectra_request_batch:latest

docker logs koelectra_request_batch -f

