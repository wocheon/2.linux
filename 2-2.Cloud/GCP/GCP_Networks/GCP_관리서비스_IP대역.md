# **GCP 관리 서비스 IP 대역**

## **1. 개요**

Google Cloud Platform(GCP)은 다양한 관리형 서비스를 제공하며, 이들 서비스는 Google이 운영하는 특정 IP 대역을 통해 통신합니다.
이 문서는 네트워크 보안 정책, 방화벽, VPC 피어링, 온프레미스 연결 구성 시 참고할 수 있도록 **GCP 관리 서비스에서 사용하는 주요 IP 대역**을 정리합니다.

---

## **2. 주요 관리 서비스 IP 대역**

---

# **2.1 Google API 및 서비스 (Google Front End – GFE)**

### **개요**

대부분의 Google Cloud API 호출(GCS, BigQuery, Compute API, IAM API 등)은
**GFE(Google Front End)**를 통해 처리됩니다.
GFE는 Google 전체의 공용 엔드포인트 앞단에 위치한 전역 로드 밸런싱 및 보안 계층입니다.

### **특징**

* IP 대역은 *정적으로 고정되어 있지 않음*
* Google 내부에서 자동 확장되기 때문에 공식 고정 CIDR을 제공하지 않음
* 방화벽 화이트리스트 구성 시 특정 IP 대신 **DNS 기반** 방식 사용을 권장

### **IP 대역 확인 방법**

Google은 다음 DNS TXT 레코드에 GCP 서비스에서 사용하는 공식 IP 범위를 제공합니다:

```
dig txt _cloud-netblocks.googleusercontent.com
```

해당 TXT 레코드는 여러 `include:` 레코드를 포함하며,
각 레코드는 다시 CIDR 목록을 제공하는 구조입니다.

예시:

```
"v=spf1 include:_cloud-netblocks1.googleusercontent.com include:_cloud-netblocks2.googleusercontent.com ~all"
```

이를 통해
Google Cloud API 엔드포인트(GFE 포함)에 사용 가능한 IP 범위를 동적으로 가져올 수 있습니다.

- 참고 - Egress All Deny 상태에서 GFE 연결 설정 방법
    - 연결 불가시 대부분의 Google Cloud API 호출 및 다른 서비스 연동 불가

|VM 종류|GFE 연결 방법|필수 구성|
|:-:|:-:|:-:|
|외부 IP 있음|GFE VIP로만 Egress Allow|199.36.153.4/30 TCP 443|
|외부 IP 없음|(A) Private Google Access|PGA ON + 199.36.153.4/30 Allow|
|외부 IP 없음|(B) Cloud NAT|NAT + 199.36.153.4/30 Allow|
|외부 IP 없음|(C) Private Service Connect|PSC Endpoint IP Allow|
        

---

# **2.2 Private Google Access / Private Service Connect**

### **개요**

VPC 내부에서 공용 인터넷 없이 Google API를 호출할 경우 사용되는 서비스.

### **사용 IP 대역**

| 서비스                                  | IP 대역               |
| ------------------------------------ | ------------------- |
| Private Google Access                | **199.36.153.4/30** |
| Private Service Connect → Google API | **199.36.153.8/30** |

### 특징

* VM이 외부 IP 없이 Google API 호출 가능
* 온프레미스 VPN/인터커넥트 경로에는 적용되지 않음
* PSC 엔드포인트는 GFE 대신 내부 IP 경로 기반으로 라우팅됨

---

# **2.3 Identity-Aware Proxy(IAP)**

### **IAP TCP Forwarding**

* Cloud IAP는 Google이 공식적으로 **고정된 IP**를 제공합니다.

| 서비스         | IP 대역               |
| ----------- | ------------------- |
| IAP TCP 포워딩 | **35.235.240.0/20** |

방화벽에서 SSH 또는 RDP 보안용으로 자주 사용됩니다.

---

# **2.4 Google Cloud Load Balancing (GCLB)**

### **HTTP(S) Load Balancer → Health Check**

헬스체커는 고정된 IP 대역을 사용:

| 서비스                | IP 대역                                 |
| ------------------ | ------------------------------------- |
| GCLB Health Checks | **130.211.0.0/22**, **35.191.0.0/16** |

### 특징

* Google 글로벌 헬스체커는 위 IP 대역에서만 요청을 보냄
* 방화벽에 예외 추가 필요

---

# **2.5 Cloud Armor**

Cloud Armor도 GFE 및 L7 LB 레이어에서 동작하므로 별도 IP 대역 없음.
GFE가 제공하는 `_cloud-netblocks.googleusercontent.com` 레코드를 참조해야 함.

---

# **2.6 Cloud Run / Cloud Functions / App Engine**

### 특징

* 모든 인바운드 요청은 기본적으로 **GFE → 서비스** 구조
* 별도의 고정 IP 범위 없음
* 동일하게 `_cloud-netblocks.googleusercontent.com` 기반

---

# **2.7 Cloud Storage (GCS)**

* GCS 자체도 GFE 앞단에서 제공됨
* VPC-SC 또는 PSA(Private Service Connect) 사용 시 Private Access IP 대역(199.36.153.8/30) 경유
* 퍼블릭 IP 대역은 GFE 공용 IP 리스트에 포함됨

---

# **2.8 Cloud SQL 관리 IP**

Cloud SQL Admin API는 GFE 기반이지만
**Cloud SQL 인스턴스의 private IP는 VPC 내부 CIDR**에서 할당됩니다.

Cloud SQL 내부 관리 트래픽(IP 인증용 인터페이스)은 Google이 운영하는 다음 대역 사용:

| 서비스                        | IP 대역                       |
| -------------------------- | --------------------------- |
| Cloud SQL Admin / Metadata | **34.68.0.0/15** (미국 리전 중심) |

(단, 이는 문서에서 종종 언급되지만 방화벽에서 직접 사용하는 경우는 거의 없음)

---

# **2.9 GKE (Google Kubernetes Engine)**

### **노드 → Control Plane 통신 IP**

| 유형                        | IP                                                       |
| ------------------------- | -------------------------------------------------------- |
| GKE Private Control Plane | **172.16.0.0/28** (기본값, 리전별 상이 가능)                       |
| GKE Health Checks         | GCLB Health Check IP와 동일 (130.211.0.0/22, 35.191.0.0/16) |

### **특징**

* Private 클러스터의 control plane endpoint는 Google에서 운영하는 내부 전용 네트워크
* 방화벽에 별도 허용 규칙이 필요할 수 있음

---

# **2.10 Metadata Server / Internal Google Services**

Google 내부 관리 서비스는 다음의 **특정 고정 주소**를 사용:

| 서비스                      | IP                                   |
| ------------------------ | ------------------------------------ |
| Metadata server          | **169.254.169.254**                  |
| DNS (Cloud DNS resolver) | **169.254.169.254** or VPC DNS range |
| Google managed VPC 라우터   | 각 VPC에 맞는 내부 IP                      |

---

# **3. 참고: 전체 Google Cloud IP 목록 조회**

Google API로 전체 Google 서비스 IP 대역을 JSON으로 받을 수 있음:

```
https://www.gstatic.com/ipranges/cloud.json
```

또는 Google Workspace 포함 전체 리스트:

```
https://www.gstatic.com/ipranges/goog.json
```

---

# **4. 요약**

| 서비스                         | 주요 IP 대역                                      |
| --------------------------- | --------------------------------------------- |
| Google API(GFE)             | SPF: `_cloud-netblocks.googleusercontent.com` |
| Private Google Access       | **199.36.153.4/30**                           |
| Private Service Connect API | **199.36.153.8/30**                           |
| IAP TCP                     | **35.235.240.0/20**                           |
| GCLB Health Check           | **130.211.0.0/22**, **35.191.0.0/16**         |
| Metadata server             | **169.254.169.254**                           |
| GKE Control Plane           | 리전별 프라이빗 CIDR (기본 172.16.0.0/28)              |


# 참고 1. - 방화벽 규칙 생성용 Gcloud 명령

```bash
# 1. Google API(GFE) 접근 허용 규칙 (443 Egress 0.0.0.0/0)
# 일반 VM → Google API 아웃바운드 허용 (기본 템플릿)
gcloud compute firewall-rules create allow-google-apis \
  --direction=EGRESS \
  --network=default \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:443 \
  --destination-ranges=0.0.0.0/0 \
  --description="Allow VM to access Google APIs over HTTPS"


# 2. Private Google Access (199.36.153.4/30)
gcloud compute firewall-rules create allow-private-google-access \
  --network=default \
  --direction=EGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:443 \
  --destination-ranges=199.36.153.4/30 \
  --description="Allow access to Google APIs via Private Google Access"

# 3. Private Service Connect → Google API (199.36.153.8/30)
gcloud compute firewall-rules create allow-psc-googleapis \
  --network=default \
  --direction=EGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:443 \
  --destination-ranges=199.36.153.8/30 \
  --description="Allow access to Google APIs via Private Service Connect"

# 4. IAP TCP 포워딩 (35.235.240.0/20) - 콘솔 내 SSH/RDP 접근시 필요
gcloud compute firewall-rules create allow-iap-tcp \
  --network=default \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:22,tcp:3389 \
  --source-ranges=35.235.240.0/20 \
  --target-tags=allow-iap \
  --description="Allow IAP TCP forwarding"

# 5. Google Load Balancer (GLB) Health Checks (130.211.0.0/22, 35.191.0.0/16)
gcloud compute firewall-rules create allow-lb-health-checks \
  --network=default \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:80,tcp:8080,tcp:443 \
  --source-ranges=130.211.0.0/22,35.191.0.0/16 \
  --target-tags=web \
  --description="Allow Google Load Balancer health checks"

# 6. GKE → Control Plane 통신 (172.16.0.0/28)
gcloud compute firewall-rules create allow-gke-control-plane \
  --network=gke-vpc \
  --direction=INGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:443 \
  --source-ranges=172.16.0.0/28 \
  --target-tags=gke-nodes \
  --description="Allow GKE nodes to communicate with control plane"

# 7. Metadata Server (169.254.169.254) - 생략가능 (Egress 제한이 심한 경우에만 사용)
gcloud compute firewall-rules create allow-metadata \
  --network=default \
  --direction=EGRESS \
  --priority=1000 \
  --action=ALLOW \
  --rules=tcp:80,tcp:443 \
  --destination-ranges=169.254.169.254/32 \
  --description="Allow access to metadata server"

```




# 참고 2. - 방화벽 규칙 생성용 Terrafrom 템플릿

```tf
# 1. Google API(GFE) 접근 허용 규칙 (443 Egress 0.0.0.0/0)
resource "google_compute_firewall" "allow_google_apis" {
  name    = "allow-google-apis"
  network = "default"

  direction = "EGRESS"
  priority  = 1000

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["0.0.0.0/0"]
  description        = "Allow VM to access Google APIs over HTTPS"
}

# 2. Private Google Access (199.36.153.4/30)
resource "google_compute_firewall" "allow_pga" {
  name    = "allow-private-google-access"
  network = "default"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.4/30"]
  description        = "Allow access to Google APIs via Private Google Access"
}

# 3. Private Service Connect → Google API (199.36.153.8/30)
resource "google_compute_firewall" "allow_psc_googleapis" {
  name    = "allow-psc-googleapis"
  network = "default"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  destination_ranges = ["199.36.153.8/30"]
  description        = "Allow access to Google APIs via Private Service Connect"
}

# 4. IAP TCP 포워딩 (35.235.240.0/20) - 콘솔 내 SSH/RDP 접근시 필요
resource "google_compute_firewall" "allow_iap" {
  name    = "allow-iap-tcp"
  network = "default"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["22", "3389"]
  }

  source_ranges = ["35.235.240.0/20"]
  target_tags   = ["allow-iap"]

  description = "Allow IAP TCP forwarding"
}

# 5. Google Load Balancer (GLB) Health Checks (130.211.0.0/22, 35.191.0.0/16)
resource "google_compute_firewall" "allow_lb_healthcheck" {
  name    = "allow-lb-health-checks"
  network = "default"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]

  target_tags = ["web"]
  description = "Allow Google Load Balancer health checks"
}

# 6. GKE → Control Plane 통신 (172.16.0.0/28)
resource "google_compute_firewall" "allow_gke_controlplane" {
  name    = "allow-gke-control-plane"
  network = "gke-vpc"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["172.16.0.0/28"]
  target_tags   = ["gke-nodes"]

  description = "Allow GKE nodes to access control plane"
}

# 7. Metadata Server (169.254.169.254) - 생략가능 (Egress 제한이 심한 경우에만 사용)
resource "google_compute_firewall" "allow_metadata" {
  name    = "allow-metadata-server"
  network = "default"

  direction = "EGRESS"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  destination_ranges = ["169.254.169.254/32"]
  description        = "Allow access to metadata server"
}
```