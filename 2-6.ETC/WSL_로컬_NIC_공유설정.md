# WSL(Ubuntu) 로컬 NIC 공유 설정

## 개요 
- Windows 11 22H2 이상 버전부터 지원하는 기능입니다. WSL과 윈도우가 네트워크 인터페이스를 공유하게 만듭니다.

### .wslconfig 파일 생성/수정
- 윈도우 탐색기 주소창에 %UserProfile%을 입력해 이동합니다.
- .wslconfig 파일 생성 or 수정 

```text
[wsl2]
networkingMode=mirrored
dnsTunneling=true
firewall=true
autoProxy=true
```

### WSL 재시작

- PowerShell(또는 CMD)을 열고 다음 명령어로 WSL을 완전히 끕니다.

```powershell
wsl --shutdown
```


### 적용 확인 
- 다시 터미널을 열어 ipconfig 등으로 확인 