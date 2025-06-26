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
    - google-cloud-cli 상에서 모든 프로젝트에 접근 가능하도록 gcloud config 구성 필요 

- 기존 하나의 bat파일을 기능별로 서브 bat파일로 분할

- 각 프로젝트별로 --filter 구문을 분리하여, 프로젝트별로 컨트롤 가능한 VM 범위를 조정 
    - 해당 구문은 별도 bat 파일로 분리하여 추가/변경이 용이하도록 변경 

- 기존 시작/중지 뿐아니라 재설정, Describe, ssh 연결이 가능하도록 수정 


### 상세 구성 내용
- 디렉토리 구성 
```
gcp_win_bat
├── main.bat
├── config
│   └── gcp_project_list.txt
└── scripts
    ├── gcloud_commands.bat
    └── gcp_vm_control.bat
```


* config/gcp_project_list.txt
```
📌 GCP 프로젝트를 선택하세요 (↑↓ 이동, Enter 선택)
NUM  Name       Filter                 Description
1    ProjectA  terraform_provisioned   Test GCP Project
2    ProjectA  RUNNING_ONLY            Test GCP Project
3    ProjectA  TERMINATED_ONLY         Test GCP Project
4    ProjectB   ALL                    B Production Project
```

* scripts/gcloud_commands.bat
```bat
@echo off

:: ========== 기본 설정  ==========
:: - UTF-8 코드 페이지 사용 ( CMD 내 한글 출력을 위함 )
chcp 65001 >nul

:: - 변수값 실시간 갱신기능 활성화
setlocal enabledelayedexpansion


:: ========== 기본 변수 설정  ==========

:: bat파일 호출시 할당한 인자를 변수로 할당 
:: 1번 인자 : PROJECT_LIST_NUM 변수 
:: 2번 인자 : GCP 프로젝트 리스트 파일 
:: * 참고 - call로 호출된 bat 파일에서는 메인 bat 파일에서 선언된 변수를 그대로 사용가능
set PROJECT_LIST_NUM=%1
set PROJECT_LIST_FILE=%2


:: ========== 목록에서 GCP 프로젝트 및 필터 선택  ==========
:: - 선택된 PROJECT_LIST_NUM 을 기준으로 PROJECT명과 Filter를 추출 
:: - Filter 명으로 등록된 label로 이동하여 gcloud 명령을 실행 
goto SELECT_PROJECT
:SELECT_PROJECT
set "TARGET_LABEL="


for /f "tokens=1-3" %%a in (!PROJECT_LIST_FILE!) do (
    if /I "%%a"=="!PROJECT_LIST_NUM!" (
		set "PROJECT=%%b"
		set "TARGET_LABEL=%%c"
	)
)

if not defined TARGET_LABEL (
    echo [ERROR] Project "!PROJECT!" not found in PROJECT List
    exit /b
)

goto !TARGET_LABEL!
exit /b


:: FOR 문 내에서 2개 이상의 명령을 실행하기위해 Powershell Command로 지정 
:: CMD For 구문 내 Powershell Command 는 한줄로 입력해야만 정상 작동 
:ALL
FOR /F "delims=" %%i IN ('powershell -Command "Write-Output '# GCP VM Instance List (Project: !PROJECT!)'; gcloud compute instances list --project=!PROJECT! --format='table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)'" ^| fzf --layout=reverse-list --header-lines=2') DO (
    echo %%i
)
exit /b

:RUNNING_ONLY
FOR /F "delims=" %%i IN ('powershell -Command "Write-Output '# GCP VM Instance List (Project: !PROJECT!)'; gcloud compute instances list --project=!PROJECT! --format='table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)' --filter='status:RUNNING'" ^| fzf --layout=reverse-list --header-lines=2') DO (
    echo %%i
)
exit /b

:TERMINATED_ONLY
FOR /F "delims=" %%i IN ('powershell -Command "Write-Output '# GCP VM Instance List (Project: !PROJECT!)'; gcloud compute instances list --project=!PROJECT! --format='table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)' --filter='status:TERMINATED'" ^| fzf --layout=reverse-list --header-lines=2') DO (
    echo %%i
)
exit /b


:terraform_provisioned
FOR /F "delims=" %%i IN ('powershell -Command "Write-Output '# GCP VM Instance List (Project: !PROJECT!)'; gcloud compute instances list --project=!PROJECT! --filter='labels.goog-terraform-provisioned:true' --format='table(name,zone,machineType,status,networkInterfaces[0].networkIP,networkInterfaces[0].accessConfigs[0].natIP)'" ^| fzf --layout=reverse-list --header-lines=2') DO (
	echo %%i
)
exit /b
```

* scripts/gcp_vm_control.bat
```bat
@echo off
:: ========== 기본 설정  ==========
:: - UTF-8 코드 페이지 사용 ( CMD 내 한글 출력을 위함 )
chcp 65001 >nul

:: - 변수값 실시간 갱신기능 활성화
setlocal enabledelayedexpansion


:: ========== 선택된 VM 대상 실행 작업 선택  ==========
:: - VM 시작/중지/재시작, Describe, SSH 연결 중 선택하여 실행 
:: - VM 시작/중지/재시작 선택시 하위 선택 메뉴 실행 
:: - 모든 작업은 실행 완료 시, 작업 선택 메뉴로 돌아옴 

:: - 작업 메뉴 표출 
:SELECT_COMMAND
echo.
set choice=""
powershell -command ^
"Write-Host \"# VM 작업 메뉴 선택 : \" -ForegroundColor Blue; ^
Write-Host \"1. VM 시작/중지/재시작\" -ForegroundColor White; ^
Write-Host \"2. VM 상세 정보 조회 (DESCRIBE)\" -ForegroundColor White; ^
Write-Host \"3. SSH 연결 (gcloud)\" -ForegroundColor White; ^
Write-Host \"4. Exit\" -ForegroundColor White"
set /p choice="Select (1, 2, 3, 4): "
echo.

:: - 선택 메뉴에 따라 label로 이동하여 작업 실행 
if "!choice!"=="1" goto SELECT_CONTROL_ACTION	
if "!choice!"=="2" goto DESCRIBE_VM
if "!choice!"=="3" goto CONNECT_VM
if "!choice!"=="4" goto EXIT_BATCH
powershell -command "Write-Host \"!잘못된 입력입니다. 다시 선택해주세요. \" -ForegroundColor Red"
goto SELECT_COMMAND

:: - 1. VM 시작/중지/재시작 선택 시 하위 메뉴 호출 
: SELECT_CONTROL_ACTION
powershell -command "Write-Host \"# 1. VM 시작/중지/재시작 - 실행 작업 선택 : \" -ForegroundColor Magenta"
echo # 1_1. VM 시작
echo # 1_2. VM 중지
echo # 1_3. VM 재시작 (재설정)
echo # 1_4. 이전 메뉴
set /p control_choice="Select (1, 2, 3, 4): "
echo.

if "!control_choice!"=="1" goto START_VM
if "!control_choice!"=="2" goto STOP_VM
if "!control_choice!"=="3" goto RESET_VM
if "!control_choice!"=="4" goto SELECT_COMMAND
powershell -command "Write-Host \"!잘못된 입력입니다. 다시 선택해주세요. \" -ForegroundColor Red"
goto SELECT_CONTROL_ACTION	

:: 1-1. 선택한 VM 기동 명령 실행 
:START_VM
echo # Action : START VM Instance
gcloud compute instances start !INSTANCE! --project=!PROJECT! --zone=!ZONE! | more 
pause
goto SELECT_COMMAND

:: 1-2. 선택한 VM 중지 명령 실행 
:STOP_VM
echo # Action : STOP VM Instance
gcloud compute instances stop !INSTANCE! --project=!PROJECT! --zone=!ZONE! | more 
pause
goto SELECT_COMMAND

:: 1-3. 선택한 VM 재시작 명령 실행 
:RESET_VM
echo # Action : RESET VM Instance
gcloud compute instances reset !INSTANCE! --project=!PROJECT! --zone=!ZONE! | more 
pause
goto SELECT_COMMAND

:: 2. 선택한 VM DESCRIBE 명령 실행 
:: VM label 내 한글이 들어가는 경우 출력이 깨지는 경우가 발생하므로 powershell 커맨드로 실행 
:DESCRIBE_VM
echo # Action : DESCRIBE VM Instance
powershell -Command ^
"$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8; ^
gcloud compute instances describe '!INSTANCE!' --project='!PROJECT!' --zone='!ZONE!'"
pause
goto SELECT_COMMAND

:: 3. 선택한 VM SSH 연결 실행 (gcloud를 통해 연결)
:CONNECT_VM
echo # Action : SSH Connect to Instance
set /p SSH_USER="SSH 연결 계정 입력 : "
gcloud compute ssh !SSH_USER!@!INSTANCE! --project=!PROJECT! --zone=!ZONE! | more 
pause
goto SELECT_COMMAND

:: 4. 작업 종료 선택시, 종료 확인 후 
:EXIT_BATCH
powershell -command "Write-Host \"!종료하시겠습니까? (Y/N) \" -ForegroundColor Yellow"
set /p confirm=">"
if /I "%confirm%"=="Y" goto END_BATCH
if /I "%confirm%"=="N" goto SELECT_COMMAND
powershell -command "Write-Host \"!잘못된 입력입니다. 다시 선택해주세요. \" -ForegroundColor Red"
echo 
goto SELECT_COMMAND

:END_BATCH
pause
```


* Main.bat
```bat
@echo off
:: ========== 기본 설정  ==========
:: - UTF-8 코드 페이지 사용 ( CMD 내 한글 출력을 위함 )
chcp 65001 >nul

:: - 변수값 실시간 갱신기능 활성화
setlocal enabledelayedexpansion

:: ========== 기본 변수 설정  ==========
:: - Provider 변수는 'Google Cloud(GCP)' 로 고정 
:: - gcloud  실행용 bat 파일 및 GCP 프로젝트 리스트 파일 지정 
set PROVIDER=Google Cloud(GCP)

::- 현재 스크립트가 있는 경로를 BASE_DIR 변수로 지정
set "BASE_DIR=%~dp0"

:: - 서브 bat 파일 위치지정 
set gcloud_bat_file=%BASE_DIR%scripts\gcloud_commands.bat
set gcp_vm_control_bat_file=%BASE_DIR%scripts\gcp_vm_control.bat

:: - PROJECT 리스트 파일 위치 지정 
set "gcp_project_list_file=%BASE_DIR%config\gcp_project_list.txt"

:: ========== GCP 프로젝트 선택  ==========
:: - GCP 프로젝트 선택 - gcp_project_list.txt 내 프로젝트 목록을 불러와서 fzf 실행 
:: - 해당 파일의 맨 위 두개 라인을 header로 사용 
FOR /F "delims=" %%i IN ('type !gcp_project_list_file! ^| fzf --layout=reverse-list --header-lines=2') DO (
    set "SELECTED=%%i"
)

:: - fzf 실행 후, 선택된 라인에서 PROJECT_LIST_NUM 추출 (공백 기준 첫 번째 컬럼)
FOR /F "tokens=1" %%i IN ("!SELECTED!") DO (
    set "PROJECT_LIST_NUM=%%i"
)

:: - fzf 실행 후, 선택된 라인에서 프로젝트 ID 추출 (공백 기준 두 번째 컬럼)
FOR /F "tokens=2" %%i IN ("!SELECTED!") DO (
    set "PROJECT=%%i"
)

:: ========== 선택된 프로젝트 내 VM INSTANCE 선택  ==========
:: - 프로젝트 선택용 fzf 실행 후, 선택된 프로젝트에 따라 gcloud command 호출 
:: - gcloud 명령 실행용 bat에 정의된 label(:xxx)을 호출하여 VM INSTANCE 선택용 fzf 실행 
:: - 각 프로젝트 별로 gcloud filter 문을 다르게 설정함 
FOR /F "delims=" %%i IN ('call !gcloud_bat_file! !PROJECT_LIST_NUM! !gcp_project_list_file!') DO (
    set "SELECTED_INSTANCE=%%i"
)
 
:: - VM INSTANCE 선택용 fzf 실행 후, 선택된 라인에서 VM 정보를 추출 
:: - 컬럼 순서 대로 각 변수 값에 할당 하여 사용 
:: - 1번 부터 5번까지 차례로 변수로 지정 ( 첫번째  토큰 변수를 a로 지정시 a,b,c 순으로 자동 지정)
FOR /F "tokens=1-5" %%a IN ("!SELECTED_INSTANCE!") DO (
    set "INSTANCE=%%a"
    set "ZONE=%%b"
    set "MACHINE_TYPE=%%c"
    set "STATUS=%%d"
    set "INTERNAL_IP=%%e"
)

:: ========== 선택된 프로젝트/VM 정보 출력 ==========
:: - 각 단계를 통해 선택된 프로젝트/VM 의 정보를 출력
:: - 글자 색을 지정하기 위해 powershell Command 사용 
:: - powershell command를 여러번 사용시 느려지는 현상이 발생하므로 한번의 powershell command만 호출하도록 설정 
powershell -Command ^
"Write-Host \"──────────────────────────────────────────────\" -ForegroundColor DarkGray; ^
Write-Host \"`t`t[VM INFO]\" -ForegroundColor Green; ^
Write-Host \"* Provider       :\" -NoNewline; Write-Host \" !PROVIDER!\" -ForegroundColor Yellow; ^
Write-Host \"* PROJECT        :\" -NoNewline; Write-Host \" !PROJECT!\" -ForegroundColor Yellow; ^
Write-Host \"* VM Name        :\" -NoNewline; Write-Host \" !INSTANCE!\" -ForegroundColor Yellow; ^
Write-Host \"* MACHINE_TYPE   :\" -NoNewline; Write-Host \" !MACHINE_TYPE!\" -ForegroundColor Yellow; ^
Write-Host \"* Internal_IP    :\" -NoNewline; Write-Host \" !INTERNAL_IP!\" -ForegroundColor Yellow; ^
Write-Host \"* ZONE           :\" -NoNewline; Write-Host \" !ZONE!\" -ForegroundColor Yellow; ^
Write-Host \"* Status         :\" -NoNewline; Write-Host \" !STATUS!\" -ForegroundColor Yellow; ^
Write-Host \"──────────────────────────────────────────────\" -ForegroundColor DarkGray"


call !gcp_vm_control_bat_file!
```


