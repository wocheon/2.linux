#!/bin/bash

# Values - PATH & Workdir Setting
export PATH='/root/google-cloud-sdk/bin:/root/install/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin::/usr/local/maven/bin:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.402.b06-1.el7_9.x86_64/bin:/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.402.b06-1.el7_9.x86_64/jre/bin:/usr/local/lib/tomcat/bin:/root/bin'
work_dir="/root/workspaces/mig_schedule_holiday_change"
mig_schedule_state_file="${work_dir}/mig_schedule_state"

# Values - MIG INFO
MIG_NAME="instance-group-1"
MIG_REGION="asia-northeast3"
MIG_ZONE="asia-northeast3-a"

# TEST VALUE
#today="241105"
today=$1

# Values - Date Values
#today=$(date '+%y%m%d')
tommorow_day_num=$(date -d "$today +1day" '+%w')
yesterday_md=$(date -d "${today} -1day" "+%y%m%d")
tommorow_md=$(date -d "${today} +1day" "+%y%m%d")

# Values - Load public_holidays_list
source $work_dir/public_holidays_list.txt


# log Setting
#log_file="${work_dir}/log/mig_schedule_holiday_change_$(date "+%Y%m").log"
#exec >> $log_file 2>&1


# Function1 - create mig_schedule_list
function mig_scaling_schedule_list() {
gcloud compute instance-groups managed describe ${MIG_NAME} --zone=${MIG_ZONE} \
   --format="json" | jq -r '.autoscaler.autoscalingPolicy.scalingSchedules
   | to_entries[]
   | [.key, .value.disabled, .value.minRequiredReplicas]
   | @tsv' | (echo -e "SCHEDULE_NAME\tDISABLED\tMIN_REQUIRED_REPLICAS" && cat) | column -t -s$'\t'
}

# Function2 - isPublicHolidayTomorrow
function  isPublicHolidayTomorrow() {
for e in ${public_holidays[*]}
do
        if [[ "$e" == $1 ]]; then
                return 0
        fi
done

return 1
}


# WORK 1 - Create mig_schedule_list file
date > ${mig_schedule_state_file}
mig_scaling_schedule_list >>  ${mig_schedule_state_file}


# Check - Tommorw is Public holiday?

if isPublicHolidayTomorrow $tommorow_md; then
        tommorow_holiday_check="holiday"
#elif ! isPublicHolidayTomorrow $tommorow_md && ( [ $tommorow_day_num -eq 0 ] || [ $tommorow_day_num -eq 6 ] ); then
elif ! isPublicHolidayTomorrow $tommorow_md && [ $tommorow_day_num -eq 0 ]; then
        tommorow_holiday_check="weekday"
else
        tommorow_holiday_check="workday"
fi

echo "[$(date '+%Y-%m-%d %H:%m')] Tommorow(${tommorow_md}) is ${tommorow_holiday_check} ($(date -d "${tommorow_md}" +"%A"))"


# Check - MIG_Schedule Need to Change ?
# 파일을 읽어 첫 번째 줄(헤더)을 제외하고 나머지 줄을 순차적으로 처리합니다.# tail -n +2를 사용하여 첫 번째 줄(헤더)을 제외한 내용을 읽습니다.
tail -n +3 "$mig_schedule_state_file" | while read -r schedule_name disabled min_required_replicas; do
        # 공백 제거
        schedule_name=$(echo "$schedule_name" | xargs)
        schedule_disabled=$(echo "$disabled" | xargs)

        # SCHEDULE_NAME이 "SCHEDULE_NAME"인 경우 패스
        if [[ "$schedule_name" == "SCHEDULE_NAME" ]]; then
                continue
        fi

        # WORK 2 - Change MIG Scaling Schedules
        # 1. tommorow = Holiday, Schedule = enabled
        if [ $tommorow_holiday_check = "holiday" ] && [ $schedule_disabled == 'false' ]; then
                echo "[$(date '+%Y-%m-%d %H:%m')] SCHEDULE_NAME: $schedule_name, DISABLED: $schedule_disabled - Need to disable Schedule - (enabled > disabled)"
                gcloud compute instance-groups managed update-autoscaling ${MIG_NAME} --zone=${MIG_ZONE} --disable-schedule=${schedule_name} >> /dev/null

        # 2. tommorow = Workday, Schedule = disabled
        elif [ $tommorow_holiday_check != "holiday" ] && [ $schedule_disabled == 'true' ]; then
                echo "[$(date '+%Y-%m-%d %H:%m')] SCHEDULE_NAME: $schedule_name, DISABLED: $schedule_disabled - Need to enable Schedule - (disabled > enabled)"
                gcloud compute instance-groups managed update-autoscaling ${MIG_NAME} --zone=${MIG_ZONE} --enable-schedule=${schedule_name} >> /dev/null

        else
                echo "[$(date '+%Y-%m-%d %H:%m')] SCHEDULE_NAME: $schedule_name, DISABLED: $schedule_disabled - Keep Schedule State"
        fi

done


# WORK 3 - show Now State
#date > ${mig_schedule_state_file}
#mig_scaling_schedule_list >>  ${mig_schedule_state_file}
#cat ${mig_schedule_state_file}


echo ""
