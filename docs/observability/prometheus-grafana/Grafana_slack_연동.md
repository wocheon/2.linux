# Grafana - Slack 연동 설정

## Slack을 Grafana 알림채널로 등록
- Alert Rule을 통해 발생되는 알림을 Slack Webhook 메세지로 받을수 있도록 설정
- 여러 채널을 등록 후 Alert rule 별로 알림채널을 다르게 설정 하여 발송하도록 설정

### 알림 채널 #1 등록  
- Home > Alerting > Contact Points 
    - Add contact Points
        - Name : `Slack_alert_channel_1`
        - integration : Slack
        - Webhook URL : Slack Webhook 주소를 입력 (Channel #1)
            - https://api.slack.com/apps > 연결할 APP 선택  > Incomming Webhooks > Webhook URL 복사
- `Test` 버튼으로 알림 발송 테스트 진행 후 Save Contact Point로 저장

### 알림 채널 #2 등록  
- Home > Alerting > Contact Points 
    - Add contact Points
        - Name : `Slack_alert_channel_2`
        - integration : Slack
        - Webhook URL : Slack Webhook 주소를 입력 (Channel #2)

## Custom Notification Template 설정
- Home > Alerting > Contact Points > Notifiaction Templates > add notification template
- Slack 알림 발송 시 원하는 형태의 Template으로 알림을 수신 가능 

### Notification Template 추가  
- Alert Rule 별로 Summary 설정 하여 해당 정보만 알림으로 볼수 있도록 설정
- name : firing_and_resolved_alerts

```
{{ define "firing_and_resolved_alerts" -}}
{{ len .Alert.Resolved }} resolved alert(s), {{ len .Alerts.Firing }} firing alert(s)
{{ range .Alert.Resolved -}}
    {{ template "summary_and_description" . -}}
{{ end }}
{{ range .Alert.Firing -}}
    {{ template "summary_and_description" . -}}
{{ end -}}
{{ end -}}
{{ define "summary_and_description" }}
    - status : {{ .Status }}
    {{ .Annotations.summary }}
{{ end -}}
```


## Mute Timing 설정 
- Notification Policy 별로 Alert Rule 위반하여도 알림을 발송하지 않는 시점을 지정가능 
- Home > Alerting > Notification Policy > Add mute timing

### channel_2_mute_timing 설정 
- Name : channel_2_mute_timing
- Time Interval 
    - Time Range  
        - 00:00 ~ 14:02 
        - 19:00 ~ 23:59 
        > 14:02 ~ 19:00 까지의 알림만 받음
    - Location : Asia/Seoul
    - Days of the week 
        - 월 ~ 금 

## Notification Policy 설정 
- Alert Rule 별로 알림 발송할 채널을 결정할수 있는 key-Valeus 값을 설정 
-  Home > Alerting > Notification Policy > New Nested policy로 신규 생성

### Channel #1 Policy 설정 
- label : slack_channel
- Operator : `=`
- Value : channel_1
- Contact Point : Slack_alert_channel_1

### Channel #2 Policy 설정 
- label : slack_channel
- Operator : `=`
- Value : channel_2
- Contact Point : Slack_alert_channel_2
- Mute Timings : channel_2_mute_timing


## Alert Rule 생성 
- 테스트용 Alert Rule 생성하여 테스트 진행
    - Load average (1m) 값이 VM의 코어수 보다 높아지는 경우 알림 발생
    - Home > Alerting > Alert Rules > New alert rule    


### 테스트용 Alert Rule #1 (Load Average 체크)

1. Enter alert rule name 
    - Name : vm_load_1m_alert

2. Define Query and alert condition
    - Datasource : Prometheus
    - Query : 
    ```
    sum by (instance) node_load1{job="GCE_vm"} / count by (instance) (node_cpu_seconds_total{mode="system"})
    ```
    - Expression
        - Reduce
            - Input : A
            - Function : Last
            - mode : Strict 
        - Threshold
            - Input : B 
            - 조건 : IS ABOVE `1`
            - Custom recovery threshold : Active 
            - Stop alerting when below : 1

3. Set evaluation behavior 
    - Folder : test_folder
    - Evaluation Group 
        - Evaluation Group name : test_1m_check 
        - Evaluation interval : 1m
    - Pending Period : 1m

4. Add annotations
    - Summary 
    ```
    - 항목 : Load Average (1m)
    - 대상 : {{ $labels.instance }}
    - Value : *{{ $values.A.Value }}* (( 기준값 : 1 ))
    - 내용 : Load Average(1m) 기준값 초과
    * 알림 발생 기준 : Load Average (1m) / VM Core 수 > 1 
    ```

5. Label and Notifications 
    - Labels 
        - slack_channel = channel_1

### 테스트용 Alert Rule #2 (Node_exporter 연결 상태 확인)

1. Enter alert rule name 
    - Name : node_exporter_connection_check

2. Define Query and alert condition
    - Datasource : Prometheus
    - Query : 
    ```
    up{job="GCE_vm"}
    ```
    - Expression
        - Reduce
            - Input : A
            - Function : Last
            - mode : Strict 
        - Threshold
            - Input : B 
            - 조건 : IS BELOW `0`
            - Custom recovery threshold : False

3. Set evaluation behavior 
    - Folder : test_folder
    - Evaluation Group 
        - Evaluation Group name : test_1m_check 
        - Evaluation interval : 1m
    - Pending Period : 1m

4. Add annotations
    - Summary 
    ```
    - 항목 : Node_exporter 연결 확인
    - 대상 : {{ $labels.instance }}
    - Value : *{{ $values.A.Value }}* (( 기준값 : 0 ))
    - 내용 : {{ $labels.instance }} VM Node_exporter 연결 불가
    * 알림 발생 기준 : 대상 VM Node_exporter 연결 불가 시
    ```

5. Label and Notifications 
    - Labels 
        - slack_channel = channel_2


## 알림 채널에 Custom Template 할당 
- home > Alerting > Contact points > 기존 채널 편집

- Optional Slack Settings > Text Body 부분에 다음 내용 등록
```
{{ template "firing_and_resolved_alerts" .}}
```