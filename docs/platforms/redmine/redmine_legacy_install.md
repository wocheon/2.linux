# Redmine 설치 - legacy

## MariaDB install
```bash
mysql_secure_installation
```

## Create MariaDB Account
```sql
MariaDB [(none)]> CREATE DATABASE redmine CHARACTER SET utf8 COLLATE utf8_general_ci;
MariaDB [(none)]> CREATE USER 'redmine'@'%' IDENTIFIED BY '1111';
MariaDB [(none)]> GRANT ALL PRIVILEGES ON redmine.* TO 'redmine'@'%';
MariaDB [(none)]> flush privileges;
```


## 소스 컴파일을 하기 위해 개발자 도구와 Redmine에 필요한 라이브러리를 설치
```bash
yum -y groupinstall "Development Tools"
yum -y install libxslt-devel libyaml-devel libxml2-devel gdbm-devel libffi-devel zlib-devel openssl-devel libyaml-devel readline-devel curl-devel openssl-devel pcre-devel git memcached-devel valgrind-devel mysql-devel ImageMagick-devel ImageMagick
```

## Ruby  (4.1 버전에서는 2.6버전까지 지원)
```
cd /usr/local/src ; wget  wget https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz
tar xvf ruby-2.6.5.tar.gz
cd ruby-2.6.5
./configure 
make && make install 
ruby -v 
```

## Ruby gem 설치
```
cd /usr/local/src ;wget https://rubygems.org/rubygems/rubygems-3.1.2.tgz ;tar xvf rubygems-3.1.2.tgz 
cd rubygems-3.1.2 
/usr/local/bin/ruby setup.rb
```

## bundler, chef ruby-shadow 등 gem 설치
```
gem install bundler chef ruby-shadow
gem install ruby-openid mysql2
```


## redmine 설치 
```
cd /usr/local/src; wget https://www.redmine.org/releases/redmine-4.1.0.tar.gz ; tar xvfz redmine-4.1.0.tar.gz
```

### redmine config 파일 설정 
```
cd redmine-4.1.0
cp config/configuration.yml.example config/configuration.yml
cp config/database.yml.example config/database.yml
```


> vim config/database.yml
```
production:
  adapter: mysql2
  database: redmine
  host: localhost
  username: redmine
  password: "1111"
  encoding: utf8
```

### redmine 구동에 필요한 패키지 설치
```
bundle install --without development test --path vendor/bundle
```
#### bundler error 발생 시 조치 
- rubygem 버전 업그레이드 진행 
```
gem update --system 3.2.3

gem install bundler rake loofah

gem update
```

###  loofah gem 버그 수정 
```
cd /usr/local/src/redmine-4.1.0
```

> vi Gemfile 
```
# 마지막줄에 다음 라인 추가
gem "loofah", "< 2.21.0"
```

```
gem update
```


### 쿠키 암호화를 위한 시크릿 토큰 생성
```
bundle exec rake generate_secret_token
```

### 데이터베이스 생성
```
RAILS_ENV=production bundle exec rake db:migrate
```

#### 데이터 베이스 생성 - blankslate 에러 발생시 
- Gemfile에 해당 라인 추가 
> vi Gemfile
```
gem "blankslate"
```

```
bundle install
```

### 기본 언어 설정 - ko
```
RAILS_ENV=production bundle exec rake redmine:load_default_data
```

### redmine 실행
```
bundle exec rails server webrick -e production -b 0.0.0.0 &
```
### 브라우저 접속 확인
- http://[ip]:3000


## Apache Passenger를 이용하여 아파치 연동

```
yum -y install httpd libcurl-devel httpd-devel apr-devel apr-util-devel
```

### gem을 통해 passenger를 설치
```
gem install passenger
```

### passenger를 통해 아파치 모듈을 설치
- OOM 주의 (2GB에서는 OOM 발생)
```
passenger-install-apache2-module
```

### /etc/httpd/conf.d/redmine.conf 파일수정
- passenger모듈 추가, vhost를 추가
```
LoadModule passenger_module /usr/local/lib/ruby/gems/2.6.0/gems/passenger-6.0.22/buildout/apache2/mod_passenger.so
<IfModule mod_passenger.c>
  PassengerRoot /usr/local/lib/ruby/gems/2.6.0/gems/passenger-6.0.22
  PassengerDefaultRuby /usr/local/bin/ruby
  PassengerDefaultUser apache
</IfModule>

<VirtualHost *:80>
  ServerName redmine.com
  DocumentRoot /usr/local/src/redmine-4.1.0/public
  ErrorLog logs/redmine_error_log
    <Directory "/usr/local/src/redmine-4.1.0/public">
        Options FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>
  Options Indexes FollowSymLinks MultiViews
  RailsEnv production
  RailsBaseURI /
</VirtualHost>
```