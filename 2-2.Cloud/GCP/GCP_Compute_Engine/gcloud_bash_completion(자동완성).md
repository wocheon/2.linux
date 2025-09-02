# `gcloud` bash-completion 활성화

1. **Bash-completion 패키지 설치**  
   먼저, `bash-completion` 패키지가 설치되어 있는지 확인합니다. 설치되지 않았다면 아래 명령어로 설치할 수 있습니다.

   ```bash
   sudo apt-get install bash-completion  # Ubuntu/Debian 계열
   sudo yum install bash-completion      # RHEL/CentOS 계열
   ```

2. **`gcloud` 자동완성 활성화**  
   `gcloud` 명령어의 자동완성을 활성화하려면, `gcloud`의 `bash-completion` 스크립트를 로드해야 합니다. 이를 위해 `gcloud` 설치 후 자동완성 스크립트를 실행합니다.
   (에러나면 패스)

   ```bash
   gcloud components install bash-completion
   ```

4. **Bash 설정 파일 수정**  
   자동완성 스크립트를 Bash 설정 파일(`~/.bashrc` 또는 `~/.bash_profile`)에 추가하여 Bash 세션마다 자동완성이 활성화되도록 합니다. 파일을 열고 아래와 같은 라인을 추가합니다.

   ```bash
   if which gcloud > /dev/null; then
     source $(gcloud info --format='value(installation.sdk_root)')/completion.bash.inc
   fi
   ```

5. **Bash 설정 파일 적용**  
   파일을 수정한 후에는 변경 사항을 적용해야 합니다. 아래 명령어를 실행하여 적용합니다.

   ```bash
   source ~/.bashrc  # 또는 ~/.bash_profile
   ```

6. **자동완성 확인**  
   이제 `gcloud` 명령어를 입력할 때, 자동완성이 정상적으로 작동하는지 확인할 수 있습니다. 예를 들어, `gcloud compute`를 입력한 후 `Tab` 키를 눌러보면, 가능한 옵션들이 자동으로 완성됩니다.



if which gcloud > /dev/null; then
  source $(gcloud info --format='value(installation.sdk_root)')/completion.bash.inc
fi
