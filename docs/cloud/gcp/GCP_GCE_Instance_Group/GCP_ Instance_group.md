# GCP Instance Group

## 1. 인스턴스 그룹 유형별 구분
- 관리형과 비관리형으로 구분

### 비관리형 인스턴스 그룹
- 다수의 인스턴스를 논리적으로 그룹화 한 것
- 로드밸런서로 연결가능해짐

### 관리형 인스턴스 그룹 (MIG)
- 고가용성
    - 실패한 VM 자동 복구 ( VM 중지/충돌/선점/삭제 시 재생성 )
    - 애플리케이션 기반 자동 복구 ( Application 체크 및 미응답시 VM 재생성)
    - 리전(멀티 영역) 노출 범위 (앱 부하 분산 가능)
    - 부하 분산 ( 트래픽 분산 )

- 확장성
    - 인스턴스 오토스케일링 지원

- 자동 업데이트
    - 새로운 버전의 소프트웨어를 MIG에 배포가능 
        - 순차적,카나리아 등의 업데이트 옵션 지원

- 스테이트풀(Stateful) 워크로드 지원
	- Stateful 구성을 사용하는 Application의 배포 빌드 및 작업  자동화 가능

## Auto Scaling 

### 자동 확장

- 관리형 인스턴스 그룹 (MIG)의 기능 
	- 비관리형 인스턴스 그룹은 지원하지 않음

- 특정 신호를 바탕으로 인스턴스 그룹의 VM을 증설하여 MIG의 부하를 조절하는 기능

- 주요 측정 항목
	- 평균 CPU 사용률
	- HTTP 부하 분산 처리 용량
	- Cloud Monitoring 측정항목

- 설정한 사용률 측정항목을 기준으로 사용량 정보를 지속적으로 수집
- 실제 사용률과 비교 후 인스턴스 그룹에서 VM을 삭제 혹은 추가 결정

### 수평 축소 제어
- 한번에 줄어들수있는 VM 대수를 설정하는 기능 

- 인스턴스가 줄어드는 속도를 제한하여 워크로드에 부담을 최소화 하는 기능

- 축소기간을 설정해도 축소시에는 안정화기간을 따름



### 초기화 기간
- 애플리케이션이 VM 인스턴스에서 초기화하는 데 걸리는 시간

- 인스턴스가 초기화되는 데 걸리는 시간보다 긴 시간을 초기화 기간 값으로 설정 시  수평 확장에 지연을 초래
  - 자동 확장 처리에서 적합한 사용률 데이터를 무시하고 그룹에 필요한 크기를 낮게 잡으므로

### 안정화 기간
- MIG내의 부하 증가 및 감소에 따라 지속적인 VM 삭제 및 생성을 방지하기 위해 신호를 안정화하기 위해 설정된 기간

	- CPU 사용률 등의 자동 확장 신호는 매우 안정적이지 않으며 빠르게 변동가능

	- 안정화 기간 중 관찰된 최대 부하를 처리하기 위해 충분한 VM 용량을 유지하여 신호를 안정화

	- 부하 증가시에는 안정화 기간을 거치지않고  VM 즉시 생성

- 자동 확장 처리가 VM을 삭제해야 할 때의 수평 축소 결정에만 사용

- 수평 축소시 발생하는 지연 시간이 아닌 자동 확장에 기본 제공되는 기능

- 안정화 기간 설정
	- 기본 설정 : 10분 
	- 초기화 시간이 더 10분 이상인경우 초기화 기간과 동일하게 설정

- 작동 방식
1. MIG의 부하가 감소 
2. 자동 확장 처리가 VM을 즉시 삭제하지 않고 안정화 기간 돌입
3. 안정화 기간 중 필요한 모니터링 용량을 유지 
4. 최대 부하를 충족하기에 용량이 충분한 경우 VM 삭제를 진행




### 확장 일정 관리
- MIG에서 제공하는 일정 기반 자동확장 기능
	
- 특정 기간 동안 유지할 최소 인스턴스 수를 설정하여 MIG내의 부하를 관리
	- 특정 기간 유지할 최소 VM개수를 예약하는 형태

- 기간 지정의 경우 Cron형태 혹은 시작시간/지속시간 형태로 설정가능

- 1회/매일/매주/매월 반복 가능


- MIG의 최대 VM 인스턴스 수를 초과하거나 최소 VM 인스턴스 수보다 적게 생성하지 않음

	-  일정에 사용할 최소인스턴스 수가 MIG의 최대 인스턴스 수보다 크지 않은지 확인 필요

- 지정된 시작 시간에 VM 인스턴스가 즉시 준비되지는 않음

	- 시작 시간 설정시 VM이 사전에 애플리케이션을 부팅하고 시작할 수 있도록 고려


- 자동 확장 처리는 확장 일정을 지속적으로 모니터링하므로 모든 구성 변경사항이 즉시 적용
	
>예시	
```
- 현재 시간 03:00 PM 
- 일정 생성
	- 시작시간 : 매일 오후 2시 
	- 지속시간 : 3시간 ( 오후 5시 까지 유지)
- 일정 생성시 바로 활성화 되며 오후 5시 까지 유지됨		
```

- 확장일정 종료 후 
	- 확장일정이 종료되어도 유지중이던 인스턴스가 바로 삭제되지않음
	- 유지중이던 인스턴스는 안정화기간(기본 10분)을 거쳐 점차적으로 감소됨


## 공휴일 확장일정 변경 스크립트 
- 공휴일의 경우 확장일정을 통해 관리가 불가능 
- 따로 스크립트를 작성하여 gcloud 명령어를 사용하도록 설정 

### 공휴일 일자 목록 
>vi restday_list.txt
```
rest_date=(
"240209"
"240210"
"240211"
"240212"
"240301"
"240410"
)
```

### 테스트용 스크립트
>vi day_check.sh
```bash
#!/bin/bash

# Function And Load Array
source ./restday_list.txt

function in_array {
        for e in ${rest_date[*]}
        do
                if [[ "$e" == $1 ]]
                then
                        return 0
                fi
        done

        return 1
}

function load_vm_schedule {
        gcloud compute instance-groups managed describe scheduled-vm --zone=asia-northeast3-a | sed -n '/scalingScheduleStatus/,/selfLink/p' |  grep -v -e scalingScheduleStatus -e lastStartTime -e nextStartTime -e selfLink > gcloud_schedule_state
}


# Load GCP VM Schedule State

load_vm_schedule

schedule_monday=$(sed -n '2p' gcloud_schedule_state | gawk -F": " '{print $2}')
schedule_tuesfri=$(sed -n '4p' gcloud_schedule_state | gawk -F": " '{print $2}')
schedule_weekday=$(sed -n '6p' gcloud_schedule_state | gawk -F": " '{print $2}')

echo "###GCP VM Schedule States###"
echo "schedule-monday : $schedule_monday"
echo "schedule-tues-fri : $schedule_tuesfri"
echo "schedule-weekday : $schedule_weekday"
echo ""

if ( [ $schedule_monday = "ACTIVE" ] || [ $schedule_monday = "READY" ] ) \
   && ( [ $schedule_tuesfri = "ACTIVE" ] || [ $schedule_tuesfri = "READY" ] ) \
   && ( [ $schedule_weekday = "ACTIVE" ] || [ $schedule_weekday = "READY" ] ); then
        state="enabled"
elif [ $schedule_monday = "DISABLED" ] && [ $schedule_tuesfri = "DISABLED" ] && [ $schedule_weekday = "DISABLED" ]; then
        state="disabled"
else
        echo "!ERROR : Check Schedule State!!"
        exit 0
fi




# define Date vars

today=$(date '+%y%m%d')
#today="240301"

today_md=$(echo $today | cut -c 3-6)
yesterday_md=$(date -d "${today} -1day" '+%y%m%d' | cut -c 3-6)
tommorow_md=$(date -d "${today} +1day" '+%y%m%d' | cut -c 3-6)

#Tommorow Restday check
if in_array $tommorow_md; then
        tommorow_wr="Restday"
else
        tommorow_wr="Workday"
fi


# Change State
if [ $state = "enabled" ]; then
        change_state="disabled"
else
        change_state="enabled"
fi


# Today Restday Check
echo "###Today Restday Check###"

if [ $state = 'enabled' ] && [ $tommorow_wr = "Restday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"

elif [ $state = 'disabled' ] && [ $tommorow_wr = "Workday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"
else
        echo "Keep Present State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        change="x"
fi
```


### 실제 확장일정 변경 스크립트
>vi restday_schedule_change.sh

```bash
#!/bin/bash

today=$(date '+%y%m%d')
log_file="/root/gcp_schedule_change/logs/change_schedule_${today}.log"

#exec >> $log_file

# Function And Load Array
source /root/gcp_schedule_change/restday_list.txt

function in_array {
        for e in ${rest_date[*]}
        do
                if [[ "$e" == $1 ]]
                then
                        return 0
                fi
        done

        return 1
}


function load_vm_schedule {
gcloud compute instance-groups managed describe scheduled-vm --zone=asia-northeast3-a | sed -n '/scalingSchedules/,+21 p' | grep -v -e minRequiredReplicas -e durationSec -e 'description' -e timeZone -e 'schedule: ' > gcloud_schedule_state
}

# Load GCP VM Schedule State

load_vm_schedule

schedule_monday=$(sed -n '3p' gcloud_schedule_state | gawk -F': ' '{print $2}')
schedule_tuesfri=$(sed -n '5p' gcloud_schedule_state | gawk -F': ' '{print $2}')
schedule_weekday=$(sed -n '7p' gcloud_schedule_state | gawk -F': ' '{print $2}')


if [ $schedule_monday = 'false' ] && [ $schedule_tuesfri = 'false' ] && [ $schedule_weekday = 'false' ]; then
        schedule_monday_state="enabled"
        schedule_tuesfri_state="enabled"
        schedule_weekday_state="enabled"
        state="enabled"
elif  [ $schedule_monday = 'true' ] && [ $schedule_tuesfri = 'true' ] && [ $schedule_weekday = 'true' ]; then
        schedule_monday_state="disabled"
        schedule_tuesfri_state="disabled"
        schedule_weekday_state="disabled"
        state="disabled"
else
        echo "!ERROR : Check Schedule State!!"
        echo $schedule_monday
        echo $schedule_tuesfri
        echo $schedule_weekday
        exit 0
fi

echo "###GCP VM Schedule States###"
echo "schedule-monday : $schedule_monday_state"
echo "schedule-tues-fri : $schedule_tuesfri_state"
echo "schedule-weekday : $schedule_weekday_state"
echo ""


# define Date vars

#today=$(date '+%y%m%d')
today="240303"

tommorow_day_num=$(date -d "$today +1 day" '+%w')
# Sun : 0,  Mon : 1 , Tue : 2 , Wen : 3, Thu : 4,  Fri : 5, Sat : 6

yesterday_md=$(date -d "${today} -1day" '+%y%m%d')
tommorow_md=$(date -d "${today} +1day" '+%y%m%d')

#Tommorow Restday check
if in_array $tommorow_md; then
        tommorow_wr="Holiday"
elif ! in_array $tommorow_md && ( [ $tommorow_day_num -eq  0 ] || [ $tommorow_day_num -eq 6 ] ); then
        tommorow_wr="Weekday"
else
        tommorow_wr="Workday"
fi


# Change State
if [ $state = "enabled" ]; then
        change_state="disabled"
else
        change_state="enabled"
fi


# Today Restday Check
echo "###Today Restday Check###"

if [ $state = 'enabled' ] && [ $tommorow_wr = "Holiday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"

elif [ $state = 'disabled' ] && [ $tommorow_wr = "Workday" ] && [ $tommorow_wr != "Weekday" ]; then
        echo "! Need to Change State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        echo " Change Schedule to $change_state !"
        change="o"
else
        echo "Keep Present State"
        echo "Tommorow : $tommorow_wr ($tommorow_md)"
        echo "Present Schedule State : '$state'"
        change="x"
fi


# Change State
if [ $change = "o" ]; then
#        read -p "Change Schedule State ? (y/n) " ans
#       if [ $ans = "y" ]; then

                if [ $change_state = 'disabled' ]; then
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-monday
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-tues-fri
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --disable-schedule=schedule-weekday
                elif [ $change_state = 'enabled' ]; then
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-monday
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-tues-fri
                        gcloud compute instance-groups managed update-autoscaling scheduled-vm --zone=asia-northeast3-a --enable-schedule=schedule-weekday
                fi

                echo "State Changed : $change_state"
                echo "* Please Check few Minuate Later (Udate Schedule Spend Few Minuate)"

                #load_vm_schedule
                #cat gcloud_schedule_state
        #else
        #       echo "state not changed"
        #fi
fi

```