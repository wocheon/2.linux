# ANACONDA 설치 

## 개요
- Anaconda 설치 방법에 대한 문서

## Anaconda ?
-  개발자들이 필요한 모든 파이썬 도구와 환경 관리 기능을 한데 모아둔 종합 개발 플랫폼

### 주요 장점 
- 초기 환경 설정 간소화
	- 데이터 과학 및 머신러닝에 필수적인 1,500개 이상의 패키지와 파이썬 인터프리터를 한 번에 설치하여 번거로운 개별 설치 과정을 생략 가능 
- 효율적인 환경 관리
	- conda 명령어를 통해 프로젝트별로 독립적인 가상 환경을 구축하고 관리하여 패키지 간의 버전 충돌을 방지

### Anaconda 주요 기능 

- conda (패키지 및 환경 관리자)
	- 파이썬 및 비(非)파이썬 라이브러리 설치/업데이트를 관리하며, 필요에 따라 격리된 가상 환경을 생성하고 전환하는 핵심 도구

- Anaconda Navigator (GUI)
	- 명령줄 사용에 익숙하지 않은 사용자를 위해 Jupyter Notebook, Spyder 등 주요 개발 도구를 쉽게 실행할 수 있는 그래픽 사용자 인터페이스를 제공


## WSL에서 Anaconda(miniconda) 설치 

- Windows 11의 WSL(Windows Subsystem for Linux) 환경은 본질적으로 Linux(주로 Ubuntu) 환경이므로 **Linux용 쉘 스크립트(`.sh`)**를 사용하여 설치

### 1. Anaconda 설치 파일 다운로드
- `wget`을 사용하여 최신 Linux용 Anaconda 설치 스크립트를 다운로드

> **참고:** 버전별 아카이브 - [Anaconda Archive](https://repo.anaconda.com/archive/)

```bash
# 필수 패키지 설치 (wget이 없는 경우)
sudo apt update && sudo apt install -y wget

# Anaconda 설치 스크립트 다운로드 (Linux x86_64 버전)
wget https://repo.anaconda.com/archive/Anaconda3-2024.10-1-Linux-x86_64.sh
```
- 참고 - 가벼운 환경이 필요하다면 `Miniconda` 설치를 권장
	- 설치 방식은 위와 동일하며 파일만 `Miniconda3-latest-Linux-x86_64.sh`로 변경

### 2. 설치 스크립트 실행

```bash
bash Anaconda3-2024.10-1-Linux-x86_64.sh
```

- 스크립트가 실행되면 다음과 같은 절차를 진행

1.  **Welcome 메시지**: `Enter`를 눌러 설치 시작

2.  **라이선스 동의**: 스페이스바를 눌러 약관을 끝까지 읽은 후, `yes`를 입력하여 동의

3.  **설치 경로 확인**: 기본 경로(`~/anaconda3` 또는 `~/anaconda`)를 확인하고 `Enter`로 승인

4.  **Conda Init**: 설치 완료 후 쉘 초기화 여부를 묻는 질문.  이 단계가 `.bashrc`에 환경 변수를 자동으로 등록

### 3. 환경 변수 적용 및 확인
설치가 완료되면 변경된 환경 변수(`.bashrc`)를 현재 쉘에 적용하고 설치를 확인

```bash
# 변경된 .bashrc 즉시 적용
source ~/.bashrc

# 설치 확인
$ conda --version
conda 25.9.1
```

### 4. (선택 사항) 최신 버전 업데이트 및 가상환경 설정
- 설치된 버전이 최신이 아닐 수 있으므로, 초기 설치 직후 패키지를 업데이트 권장 

```bash
# conda 코어 업데이트
conda update -n base -c defaults conda

# (옵션) 전체 패키지 업데이트 - 시간이 오래 걸릴 수 있음
conda update --all
```

### 💡 Tip
-  WSL와 Windows 간 연동
	- ** WSL에 설치된 Anaconda는 기본적으로 WSL 내부에서만 동작
	- VS Code에서 WSL 확장을 사용(`code .`)하면, VS Code가 WSL 내부의 Python 인터프리터를 자동으로 인식
		-  Windows 상의 IDE에서도 WSL 내부의 Conda 환경을 사용 가능
