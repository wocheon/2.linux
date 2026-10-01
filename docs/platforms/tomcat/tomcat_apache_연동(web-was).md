# Apache-Tomcat 연동 (web-was)

## 기본세팅
- 기본 OS: Ubuntu 24.04 LTS / 대안: Rocky Linux 9
- WAS: Eclipse Temurin JDK 25 LTS + Tomcat 11.0.26
- 예시 IP: WEB `192.168.1.100`, WAS `192.168.2.200`
- WEB 80/443, WEB→WAS 8080만 허용합니다. 방화벽과 SELinux는 끄지 않습니다.
- Tomcat 11은 Jakarta API를 사용합니다. `javax.*` 기반 WAR는 마이그레이션이 필요합니다.

## WAS (Tomcat) 세팅
JDK 25는 [Adoptium 공식 DEB 저장소](https://adoptium.net/installation/linux/)에서 설치합니다.

```bash
sudo apt update
sudo apt install -y curl gpg
curl -fsSL https://packages.adoptium.net/artifactory/api/gpg/key/public \
  | gpg --dearmor | sudo tee /usr/share/keyrings/adoptium.gpg > /dev/null
echo 'deb [signed-by=/usr/share/keyrings/adoptium.gpg] https://packages.adoptium.net/artifactory/deb noble main' \
  | sudo tee /etc/apt/sources.list.d/adoptium.list
sudo apt update
sudo apt install -y temurin-25-jdk
sudo useradd --system --home /opt/tomcat --shell /usr/sbin/nologin tomcat
curl -fLO https://dlcdn.apache.org/tomcat/tomcat-11/v11.0.26/bin/apache-tomcat-11.0.26.tar.gz
sudo mkdir -p /opt/tomcat
sudo tar -xzf apache-tomcat-11.0.26.tar.gz -C /opt/tomcat --strip-components=1
sudo chown -R tomcat:tomcat /opt/tomcat
```

다운로드 전 [Tomcat 공식 페이지](https://tomcat.apache.org/download-11)에서 현재 버전·체크섬을 확인합니다. Rocky Linux 9은 동일 JDK/Tomcat 절차에서 `apt` 대신 `dnf`를 사용합니다.

`/etc/systemd/system/tomcat.service`:
```ini
[Unit]
Description=Apache Tomcat 11
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat
Environment=CATALINA_HOME=/opt/tomcat
ExecStart=/opt/tomcat/bin/catalina.sh run
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Tomcat은 시스템 기본 `java`를 사용합니다. `java -version`으로 JDK 25 적용 여부를 확인합니다.

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now tomcat
curl -I http://127.0.0.1:8080/
```

## WEB (Apache) 세팅
```bash
sudo apt install -y apache2
sudo a2enmod proxy proxy_http
```

Rocky Linux 9에서는 `sudo dnf install -y httpd`를 사용하고 `mod_proxy`/`mod_proxy_http` 모듈을 확인합니다. 다음 VirtualHost를 Ubuntu의 `/etc/apache2/sites-available/tomcat.conf`에 저장합니다.

```apache
<VirtualHost *:80>
    ServerName web.example.com
    ProxyPreserveHost On
    ProxyPass / http://192.168.2.200:8080/
    ProxyPassReverse / http://192.168.2.200:8080/
</VirtualHost>
```

```bash
sudo a2ensite tomcat.conf
sudo apache2ctl configtest
sudo systemctl reload apache2
```

운영 환경은 HTTPS를 적용하고 WAS 8080을 외부에 직접 공개하지 않습니다.
