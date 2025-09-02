# GCP VM instance 기동/중지용 Windows batch

## 개요 
- 윈도우 OS 상에서 GCP 콘솔 접속 없이 gcloud 명령을 통해 VM을 기동/중지 할수 있는 Bat 파일을 생성


## Windows에 Gcloud CLI 설치 

- GCP 메뉴얼 페이지를 참고 하여 Windwos에 google CLI 설치 
    - https://cloud.google.com/sdk/docs/install?hl=ko#windows


- gcloud 자동 완성 등록 
    - 설치 후 Google Cloud SDK for Shell 혹은 Cloud Tools for Powershell을 실행하여 다음 명령을 실행
```
# Gcloud 자동완성 활성화 
gcloud beta interactive 
```



## VM 설정 파일 생성 
- VM 정보를 변수로 지정하는 config용 bat파일 생성 

> gcp_vm_config.bat
```bat
@echo off
set PROVIDER=Google Cloud(GCP)
set PROJECT=[프로젝트 명]
set INSTANCE=[VM 명]
set ZONE=[VM Zone]
```

## VM 기동/중지 용 Bat파일 생성 

- VM 기동 과 VM 중지의 gcloud 명령이 다르므로 두개의 Bat파일을 생성하여 사용 

### VM 기동용 Bat파일 생성 
- VM 기동을 위한 Bat 파일 생성
    - VM설정 파일을 불러와서 해당 VM을 기동
    - 기동 후 VM IP를 출력
    - 완료 후 창을 닫지 않고 대기

```bat
@echo off
call gcp_iac_vm_config.bat
echo ============================================
echo =  [Public Cloud VM Control]               =
echo = * Provider : %PROVIDER%             =
echo = * PROJECT : %PROJECT%                    =
echo = * Instance Name : %INSTANCE%       =
echo = * Instance's ZONE : %ZONE%    =
echo ============================================
echo.
echo # Action : Start VM Instance
echo.
echo # Command Log's
echo.
gcloud compute instances start %INSTANCE% --project=%PROJECT% --zone=%ZONE% && pause 
```


### VM 중지용 Bat파일 생성 
- VM 중지를 위한 Bat 파일 생성
    - VM설정 파일을 불러와서 해당 VM을 중지
    - 완료 후 창을 닫지 않고 대기

```bat
@echo off
call gcp_iac_vm_config.bat
echo ============================================
echo =  [Public Cloud VM Control]               =
echo = * Provider : %PROVIDER%             =
echo = * PROJECT : %PROJECT%                    =
echo = * Instance Name : %INSTANCE%       =
echo = * Instance's ZONE : %ZONE%    =
echo ============================================
echo.
echo # Action : STOP VM Instance
echo.
echo # Command Log's
echo.
gcloud compute instances stop %INSTANCE% --project=%PROJECT% --zone=%ZONE% && pause
```

## VM 기동/중지를 선택하여 실행하는 Batch 
- config bat파일 수정 
```bat
@echo off
set PROVIDER=Google Cloud(GCP)
set PROJECT=gcp-in-ca
set INSTANCE=gcp-an3-a-iac-vm
set ZONE=asia-northeast3-a

for /f "delims=" %%i in ('gcloud compute instances list --filter="name=(%INSTANCE%)" --format="table(name,zone,MACHINE_TYPE,STATUS,INTERNAL_IP,EXTERNAL_IP)"') do (
    set INSTANCE_STATE=%%i
)
```


- 실행 bat 파일
```bat
@echo off
call gcp_iac_vm_config.bat
echo ============================================
echo =  [Public Cloud VM Control]               =
echo = * Provider : %PROVIDER%            =
echo = * PROJECT : %PROJECT%                    =
echo = * Instance Name : %INSTANCE%       =
echo = * Instance's ZONE : %ZONE%    =
echo ============================================
echo.

echo # Instance State
echo NAME              ZONE               MACHINE_TYPE  STATUS      INTERNAL_IP    EXTERNAL_IP
echo %INSTANCE_STATE%

echo.
echo # Select Action : 
echo 1. Start Instance
echo 2. Stop Instance 
echo 3. Exit

:SELECT_COMMAND
set /p choice="Select (1, 2, 3): "
echo.

if "%choice%"=="1" goto START_VM
if "%choice%"=="2" goto STOP_VM
if "%choice%"=="3" goto EXIT_BATCH

echo !잘못된 입력입니다. 다시 선택해주세요.
goto SELECT_COMMAND

:START_VM
echo # Action : START VM Instance
gcloud compute instances start %INSTANCE% --project=%PROJECT% --zone=%ZONE% && pause
goto END_BATCH

:STOP_VM
echo # Action : STOP VM Instance
gcloud compute instances stop %INSTANCE% --project=%PROJECT% --zone=%ZONE% && pause
goto END_BATCH

:EXIT_BATCH
echo # Action : EXIT BATCH SCRIPT
goto END_BATCH

:END_BATCH
echo #BATCH SCRIPT Finished
pause
```