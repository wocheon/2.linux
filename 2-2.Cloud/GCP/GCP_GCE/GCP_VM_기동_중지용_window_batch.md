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


## 추가 - 여러 GCP 프로젝트 내 Instance를 관리 + 프로젝트별 Filter 지정


### 주요 변경 사항 
- 여러 GCP 프로젝트내의 VM을 컨트롤 가능하도록 별도 프로젝트 목록을 구성 후 로드 
    - google-cloud-cli 상에서 모든프로젝트에 접근 가능하도록 gcloud config 구성 필요 

- 각 프로젝트별로 --filter 구문을 분리하여, 프로젝트별로 컨트롤 가능한 VM 범위를 조정 
    - 해당 구문은 별도 bat 파일로 분리하여 추가/변경이 용이하도록 변경 



### 상세 구성 내용

* gcp_project_list.txt
```
projectA
projectB
```

* Main.bat
```bat
@echo off
:: Gcloud 명령어 bat 파일 불러오기
:: call gcloud_commands.bat

:: 변수값 실시간 갱신기능 활성화
setlocal enabledelayedexpansion

set PROVIDER=Google Cloud(GCP)

:: GCP 프로젝트 선택
FOR /F "delims=" %%i IN ('type gcp_project_list.txt ^| fzf --layout=reverse --header-lines=1') DO (
    set "SELECTED=%%i"
)

:: 선택된 라인에서 프로젝트 ID 추출 (공백 기준 첫 번째 컬럼)
FOR /F "tokens=1" %%a IN ("!SELECTED!") DO (
    set "PROJECT=%%a"
)

:: 선택된 프로젝트에 따라 gcloud command 호출 
:: gcloud_commands.bat을 호출하고 출력 결과를 SELECTED에 저장
FOR /F "delims=" %%i IN ('call gcloud_commands.bat !PROJECT!') DO (
    set "SELECTED_INSTANCE=%%i"
)
:: gcloud_commands.bat 실행 후 VM 리스트 중 선택된 줄이 다시 !SELECTED! 에 저장됨



:: 선택된 라인에서 인스턴스 이름 추출
FOR /F "tokens=1" %%a IN ("!SELECTED_INSTANCE!") DO (
    set "INSTANCE=%%a"
)

:: 선택된 라인에서 ZONE 추출 (두 번째 컬럼)
FOR /F "tokens=2" %%b IN ("!SELECTED_INSTANCE!") DO (
    set "ZONE=%%b"
)

:: 선택된 라인에서 STATUS 추출 (네 번째 컬럼)
FOR /F "tokens=4" %%c IN ("!SELECTED_INSTANCE!") DO (
    set "STATUS=%%c"
)

echo ============================================
echo =  [Public Cloud VM Control]
echo = * Provider          : !PROVIDER!
echo = * PROJECT           : !PROJECT!
echo = * Instance Name     : !INSTANCE!
echo = * Instance's ZONE   : !ZONE!
echo = * Instance's Status : !STATUS!
echo ============================================
echo.

echo.
echo # Select Action : 
echo 1. Start Instance
echo 2. Stop Instance 
echo 3. Exit

:SELECT_COMMAND
set /p choice="Select (1, 2, 3): "
echo.

if "!choice!"=="1" goto START_VM
if "!choice!"=="2" goto STOP_VM
if "!choice!"=="3" goto EXIT_BATCH

echo !잘못된 입력입니다. 다시 선택해주세요.
goto SELECT_COMMAND

:START_VM
echo # Action : START VM Instance
gcloud compute instances start !INSTANCE! --project=!PROJECT! --zone=!ZONE! && pause
goto END_BATCH

:STOP_VM
echo # Action : STOP VM Instance
gcloud compute instances stop !INSTANCE! --project=!PROJECT! --zone=!ZONE! && pause
goto END_BATCH

:EXIT_BATCH
echo # Action : EXIT BATCH SCRIPT
goto END_BATCH

:END_BATCH
pause
```

* gcloud_commands.bat 
```bat
@echo off
setlocal enabledelayedexpansion
goto SELECT_PROJECT

:SELECT_PROJECT
if /I "!PROJECT!"=="projectA" goto terraform_provisioned
if /I "!PROJECT!"=="projectB" goto NOFILTER
echo Invalid project
exit /b

:NOFILTER
FOR /F "delims=" %%i IN ('gcloud compute instances list --project=!PROJECT! ^
    --format="table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)" ^
    ^| fzf --layout=reverse --header="# Instance List (Project : !PROJECT!)" --header-lines=1
') DO (
    ::set "SELECTED_INSTANCE=%%i"
	echo %%i
)
exit /b

:terraform_provisioned
FOR /F "delims=" %%i IN ('gcloud compute instances list --project=!PROJECT! --filter="labels.goog-terraform-provisioned:true" ^
    --format="table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)" ^
    ^| fzf --layout=reverse --header="# Instance List (Project : !PROJECT!)" --header-lines=1
') DO (
    ::set "SELECTED_INSTANCE=%%i"
	echo %%i
)
exit /b
```


