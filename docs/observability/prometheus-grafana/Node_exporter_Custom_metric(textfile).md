# Node Exporter Custom metric 설정
## 개요 
- 특정 커맨드 결과값을 Prometheus 메트릭으로 받아, Grafana에서 사용
- Node Exporter의 기능중 Textfile Collector 사용
- 명령어의 결과 값을 갱신하는 스크립트를 Crontab등을 통해 반복적으로 실행하는 형태
- 텍스트파일의 내용을 읽어서 이를 메트릭으로 활용


## Node Exporter Textfile Collector 설정 
- textfile directory 생성
```
mkdir -p /usr/share/node_exporter/textfile
```

- 서비스 파일 수정 
```
ExecStart=/usr/share/node_exporter/node_exporter --collector.textfile.directory=/usr/share/node_exporter/textfile
```

## Custom 메트릭 작성용 스크립트 
> vim /usr/share/node_exporter/textfile/custom_command_output.sh
```bash
#!/bin/bash
OUTPUT=$(your_command_here)
METRICS_FILE="/usr/share/node_exporter/textfile/custom_command_output.prom"

echo "# HELP custom_command_metric Example metric from custom command" > $METRICS_FILE
echo "# TYPE custom_command_metric gauge" >> $METRICS_FILE
echo "custom_command_metric $OUTPUT" >> $METRICS_FILE
```
- Crontab 설정
  - Crontab으로 스크립트가 실행될때마다 custom_command_output.prom 내의 값이 바뀌고 이를 메트릭으로 활용하는 형태
```
* * * * * /usr/share/node_exporter/textfile/custom_command_output.sh
```
               
## 결과 확인
- Grafana 상에서 해당 메트릭을 확인가능

## Textfile Cutstum 메트릭 예시 

### 여러 메트릭을 한번에 갱신
```bash
#!/bin/bash

# Textfile Collector 메트릭 파일 경로
METRICS_FILE="/path/to/textfile/crawler_process_counts.prom"

# 각 프로세스 개수 측정
CRAWLER_101_COUNT=$(ps -ef | grep -v grep | grep python | grep crawler_101 | wc -l)
CRAWLER_102_COUNT=$(ps -ef | grep -v grep | grep python | grep crawler_102 | wc -l)
CRAWLER_103_COUNT=$(ps -ef | grep -v grep | grep python | grep crawler_103 | wc -l)

# 메트릭 파일 작성
echo "crawler_101_count $CRAWLER_101_COUNT" > $METRICS_FILE
echo "crawler_102_count $CRAWLER_102_COUNT" >> $METRICS_FILE
echo "crawler_103_count $CRAWLER_103_COUNT" >> $METRICS_FILE
```


### 하나의 메트릭만 만들고 라벨을 통한 구분
```bash
#!/bin/bash

METRICS_FILE="/path/to/textfile/crawler_process_counts.prom"
# 매트릭 갱신마다 파일 초기화
> $METRICS_FILE

for num in "101" "102" "103"
do
  CRAWLER_COUNT=$(ps -ef | grep -v grep | grep python | grep crawler_${num} | wc -l)
  echo "crawler_count{crwaler_id=\"${num}\"} $CRAWLER_COUNT" >> $METRICS_FILE

done 
```

  
