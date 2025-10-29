# GCP External IP 자동 변경

## 개요 
- GCP 에서 vm 생성 시 자동으로 외부IP(External IP)가 생성
    - 옵션 조정하여 외부IP 없이 생성도 가능
- 현재 붙어있는 외부IP를 GCP 콘솔에 접속 없이 변경하고자 하는 요구사항이 있어 해당 스크립트를 작성함

## 동작 방식 
- 기존 VM 내에 할당된 외부 IP는 access-config 를 통해서 할당됨 
- 기존 access-config를 제거 > 신규 access-config를 생성하여 할당 > 기존 외부IP는 제거하는 방식으로 진행
- 외부 IP 명명 규칙은 [VM명]-001 ...  [VM명]-999 와 같이 생성되며 999가 넘어가면 001부터 다시 시작하도록 설정함
- 외부 IP가 임시인경우 혹은 해당 규칙과 다른 경우 [VM명]-001부터 생성되고 기존 IP는 삭제 처리



```sh
#!/bin/bash
project="test-project"

timestamp=$(date '+%y%m%d%H%M')

#vm_name=$(hostname)
vm_name=$1

log_file="log/${vm_name}_${timestamp}.log"

# parameter Check
if [ -z $vm_name ]; then
        echo "Plz Insert VM_name!"
        exit
fi

date | tee -a $log_file
echo "### VM Info ###" | tee -a $log_file
gcloud compute instances list  --filter="name:(${vm_name})" | tee -a $log_file
echo "" | tee -a $log_file
read -p "Change External IP Address? (Y/N, Default=N) : " ans 

if [ -z $ans ] || [ $ans = 'n' ] || [ $ans = 'N' ]; then 
        echo "Job Canceled."
        rm -rf $log_file
        exit 
fi        

# Variables list
vm_info=$(gcloud compute instances list --format="(NAME,zone,EXTERNAL_IP,networkInterfaces.accessConfigs.name)" --filter="name:(${vm_name})" | grep -v NAME)
vm_zone=$(echo $vm_info | gawk '{print $2}')
vm_ext_ip=$(echo $vm_info | gawk '{print $3}')
vm_ac_name=$(echo $vm_info | gawk -F"'" '{print $2}' )
ext_ip_check=$(gcloud compute addresses list --filter="name:(${vm_name}*)" | grep -v NAME | wc -l)

# Variables check
#echo "### vm_info ###"
#echo "vm_Name : $name zone : $vm_zone"
#echo "ext_ip : $vm_ext_ip vm_ac_name: $vm_ac_name"
#echo "ext_ip_check : $ext_ip_check"
        
# New External IP Create
echo "" | tee -a $log_file
echo "#### Create New External IP ###" | tee -a $log_file
echo "" | tee -a $log_file

if [ $ext_ip_check -eq 0 ];then
        ext_ip_cal=1
        ext_ip_num=$(seq -f "%03g" $ext_ip_cal $ext_ip_cal)
        new_ext_ip_name="$vm_name-$ext_ip_num"
        old_ip_exists="False"
        echo "New External IP Name : $new_ext_ip_name" | tee -a $log_file
        gcloud compute addresses create $new_ext_ip_name --project=$project --network-tier=STANDARD --region=asia-northeast3  | tee -a $log_file     
else
	ext_ip_name=$(gcloud compute addresses list --filter="name:(${vm_name}*)" | grep -v NAME | gawk '{print $1}')
        ext_ip_old_num=$(echo $ext_ip_name | rev | cut -c -3 | rev)
        ext_ip_cal=$(expr $ext_ip_old_num + 1)
        if [ $ext_ip_cal -eq 999 ]; then
                ext_ip_cal=1
        fi
        ext_ip_num=$(seq -f "%03g" $ext_ip_cal $ext_ip_cal)
        new_ext_ip_name="$vm_name-$ext_ip_num"
        old_ip_exists="True"
        echo "New External IP Name : $new_ext_ip_name" | tee -a $log_file
        gcloud compute addresses create $new_ext_ip_name --project=$project --network-tier=STANDARD --region=asia-northeast3 | tee -a $log_file
fi
echo "" | tee -a $log_file

gcloud compute addresses list --filter="name:(${new_ext_ip_name})" | tee -a $log_file

### Change Ext IP
echo "" | tee -a $log_file
echo "#### Change to New External IP ###" | tee -a $log_file
echo "" | tee -a $log_file

new_ext_ip_info=$(gcloud compute addresses list --filter="name:(${new_ext_ip_name})" | grep -v NAME )
new_ext_ip_address=$(echo $new_ext_ip_info | gawk '{print $2}')

gcloud compute instances delete-access-config ${vm_name} --access-config-name="${vm_ac_name}" --zone=${vm_zone} | tee -a $log_file
gcloud compute instances add-access-config ${vm_name} --zone=${vm_zone} --access-config-name="External NAT" --address=$new_ext_ip_address --network-tier=STANDARD | tee -a $log_file

### Delete Old Ext IP 
echo "" | tee -a $log_file
echo "#### Delete Old External IP ###" | tee -a $log_file
echo "" | tee -a $log_file
if [ $old_ip_exists == 'True' ]; then 
        gcloud compute addresses delete $ext_ip_name --region=asia-northeast3 --quiet | tee -a $log_file
fi
echo "" | tee -a $log_file

echo "New External IP Address : $new_ext_ip_address" | tee -a $log_file
echo "" | tee -a $log_file
gcloud compute instances list --filter="name:(${vm_name})" | tee -a $log_file

echo "" | tee -a $log_file
echo "#### Job Finished ###" | tee -a $log_file
```
