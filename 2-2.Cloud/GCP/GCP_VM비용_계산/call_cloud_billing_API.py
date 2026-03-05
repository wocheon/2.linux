# -*- coding: utf-8 -*-
# ==============================
#-  gcloud auth application-default login 명령어로 인증된 계정의 Application Default Credentials(ADC)를 사용하여 
#   Google Cloud Billing API에서 Compute Engine 서비스의 SKU 정보를 수집하는 스크립트
# - csv 파일로 저장하며, 추후 gcp_pricing_test.py 실행시 사용
# ==============================

# ==============================
# 사전 작업 : 
    # 1. gcloud CLI 설치 및 초기화
    # 2. gcloud auth application-default login 명령어로 인증된 계정의 Application Default Credentials(ADC) 설정
# ==============================

import requests
import google.auth
import google.auth.transport.requests
import csv

# ==============================
# 설정값
# ==============================
SERVICE_ID = "6F81-5844-456A"  # Compute Engine
CURRENCY = "KRW"
OUTPUT_FILE = "compute_pricing_all_regions.csv"

# 특정 리전만 필터하려면 값 지정 (예: "asia-northeast3")
# 전체 리전이면 "None"
TARGET_REGION =  "asia-northeast3"

# ==============================
# 인증 처리
# ==============================
credentials, project = google.auth.default()
auth_req = google.auth.transport.requests.Request()
credentials.refresh(auth_req)

headers = {
    "Authorization": f"Bearer {credentials.token}"
}

# ==============================
# 전체 SKU 수집 (Pagination)
# ==============================
all_skus = []
page_token = None

while True:
    url = f"https://cloudbilling.googleapis.com/v1/services/{SERVICE_ID}/skus"
    params = {
        "currencyCode": CURRENCY,
        "pageSize": 5000
    }

    if page_token:
        params["pageToken"] = page_token

    response = requests.get(url, headers=headers, params=params)
    response.raise_for_status()
    data = response.json()

    all_skus.extend(data.get("skus", []))

    page_token = data.get("nextPageToken")
    if not page_token:
        break

print(f"총 SKU 수집 완료: {len(all_skus)}")

# ==============================
# CSV 저장
# ==============================
with open(OUTPUT_FILE, "w", newline="", encoding="utf-8") as csvfile:
    writer = csv.writer(csvfile)
    writer.writerow([
        "skuId",
        "description",
        "region",
        "usageUnit",
        "price"
    ])

    for sku in all_skus:
        regions = sku.get("serviceRegions", [])

        # region 필터 옵션
        if TARGET_REGION and TARGET_REGION not in regions:
            continue

        pricing_info = sku.get("pricingInfo", [])
        if not pricing_info:
            continue

        pricing_expression = pricing_info[0].get("pricingExpression", {})
        usage_unit = pricing_expression.get("usageUnit", "")

        tiered_rates = pricing_expression.get("tieredRates", [])
        if not tiered_rates:
            continue

        unit_price = tiered_rates[0].get("unitPrice", {})
        price = float(unit_price.get("units", 0)) + \
                float(unit_price.get("nanos", 0)) / 1e9

        writer.writerow([
            sku.get("skuId"),
            sku.get("description"),
            ",".join(regions),  # region 컬럼 유지
            usage_unit,
            price
        ])

print(f"완료: {OUTPUT_FILE} 생성됨")
