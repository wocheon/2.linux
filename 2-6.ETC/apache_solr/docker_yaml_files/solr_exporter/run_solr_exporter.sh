docker rm -f solr_exporter

# VM 1 (ZooKeeper VM)에서 실행
docker run -d \
  --name solr_exporter \
  --network zookeeper_default \
  --restart always \
  -p 9854:9854 \
  solr:9.8 \
  /opt/solr/prometheus-exporter/bin/solr-exporter \
  -p 9854 \
  -z "zoo1:2181,zoo2:2182,zoo3:2183" \
  -f /opt/solr/prometheus-exporter/conf/solr-exporter-config.xml
