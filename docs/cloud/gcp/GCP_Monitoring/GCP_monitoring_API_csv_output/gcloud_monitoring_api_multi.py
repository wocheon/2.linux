import json
from google.cloud import monitoring_v3
import pandas as pd
import datetime
import pytz

# ==========================================
# 🔹 전역 제어 변수 (Global Control Variables)
# 아래 두 변수값을 수정하여 추출 데이터를 제어합니다.
# ==========================================

# 1. 집계 간격 지정 (단위: 분)
# 예: 1 (1분), 5 (5분), 10 (10분), 60 (1시간)
AGGREGATION_MINUTES = 10

# 2. 집계 함수 지정 
# 선택 가능 값: "MEAN" (평균), "MAX" (최대), "MIN" (최소), "SUM" (합계)
ALIGNER_TYPE = "MAX"

# ==========================================

def fetch_metrics(config_file):
    # 🔹 설정 파일 읽기
    with open(config_file, "r") as file:
        config = json.load(file)

    project_id = config["project_id"]
    metrics = config["metrics"]
    output_prefix = config.get("output_prefix", "metrics")

    # GCP API는 UTC 기준이므로 KST → UTC 변환
    kst = pytz.timezone("Asia/Seoul")
    utc = pytz.utc

    # 🔹 정렬기(Aligner) 매핑 딕셔너리
    aligner_map = {
        "MEAN": monitoring_v3.Aggregation.Aligner.ALIGN_MEAN,
        "MAX": monitoring_v3.Aggregation.Aligner.ALIGN_MAX,
        "MIN": monitoring_v3.Aggregation.Aligner.ALIGN_MIN,
        "SUM": monitoring_v3.Aggregation.Aligner.ALIGN_SUM,
    }
    
    # 입력된 텍스트를 대문자로 변환하여 매핑 (오타 발생 시 기본값 MEAN 할당)
    selected_aligner = aligner_map.get(ALIGNER_TYPE.upper(), monitoring_v3.Aggregation.Aligner.ALIGN_MEAN)

    # 🔹 KST -> offset-aware datetime 객체로 변환 및 기준점 정규화
    start_time_raw = datetime.datetime.fromisoformat(config["start_time_kst"])
    end_time_raw = datetime.datetime.fromisoformat(config["end_time_kst"])

    # 전역 변수(AGGREGATION_MINUTES)에 맞춰 분(Minute) 단위 정규화
    normalized_end_minute = (end_time_raw.minute // AGGREGATION_MINUTES) * AGGREGATION_MINUTES
    truncated_end_time = end_time_raw.replace(minute=normalized_end_minute, second=0, microsecond=0)

    start_time_kst = kst.localize(start_time_raw)
    end_time_kst = kst.localize(truncated_end_time)

    # 🔹 Time offset 적용 (분 단위)
    start_time_offset = config.get("start_time_offset", 0)
    end_time_offset = config.get("end_time_offset", 0)

    adjusted_start_time_kst = start_time_kst - datetime.timedelta(minutes=start_time_offset)
    adjusted_end_time_kst = end_time_kst - datetime.timedelta(minutes=end_time_offset)

    # KST → UTC 변환
    start_time_utc = adjusted_start_time_kst.astimezone(utc)
    end_time_utc = adjusted_end_time_kst.astimezone(utc)

    # 클라이언트 생성
    client = monitoring_v3.MetricServiceClient()

    # 데이터를 저장할 딕셔너리
    data_dict = {}

    # Config 파일에서 데이터 로드
    for metric in metrics:
        metric_type = metric["metric_type"]
        filter_template = metric["filter_template"]
        label_key = metric["label_key"]
        alias = metric["alias"]

        # 시간 범위 설정
        interval = monitoring_v3.TimeInterval({
            "end_time": end_time_utc,
            "start_time": start_time_utc,
        })

        # Cloud Monitoring API에 보낼 요청 설정
        request = {
            "name": f"projects/{project_id}",
            "filter": filter_template,
            "interval": interval,
            "view": monitoring_v3.ListTimeSeriesRequest.TimeSeriesView.FULL,
            "aggregation": {
                # 전역 변수 기반 초(Second) 단위 변환
                "alignment_period": {"seconds": AGGREGATION_MINUTES * 60},
                "per_series_aligner": selected_aligner,
            },
        }

        # 데이터 조회
        print(f"▶ Metric 데이터 가져오는 중 : {alias} ({metric_type}) | 기준: {AGGREGATION_MINUTES}분 단위 {ALIGNER_TYPE.upper()}")
        response = client.list_time_series(request=request)

        # 응답 데이터 처리 (UTC → KST 변환)
        for time_series in response:
            for point in time_series.points:
                timestamp_utc = point.interval.end_time
                timestamp_kst = timestamp_utc.astimezone(kst)
                
                if not (adjusted_start_time_kst <= timestamp_kst <= adjusted_end_time_kst):
                    continue

                timestamp_str = timestamp_kst.strftime("%Y-%m-%d %H:%M:%S")
                label_value = time_series.resource.labels.get(label_key, "unknown")

                # 🔹 Value Type 동적 확인 및 추출 (Type Checking)
                value_obj = point.value
                value_field = value_obj._pb.WhichOneof("value")
                
                if value_field == "int64_value":
                    metric_val = float(value_obj.int64_value)
                elif value_field == "double_value":
                    metric_val = value_obj.double_value
                else:
                    metric_val = 0.0

                key = (timestamp_str, label_value)
                if key not in data_dict:
                    data_dict[key] = {
                        "timestamp": timestamp_str,
                        "date": timestamp_kst.strftime("%Y-%m-%d"),
                        "time": timestamp_kst.strftime("%H:%M:%S"),
                        "weekday": timestamp_kst.strftime("%A"),
                        "label": label_value,
                    }
                
                data_dict[key][alias] = round(metric_val, 2)

    df = pd.DataFrame(list(data_dict.values()))

    # 데이터가 비어있지 않은 경우에만 처리
    if not df.empty:
        # Output file에 timestamp컬럼이 출력되지않도록 DROP
        df = df.drop(columns=["timestamp"], errors="ignore")

        # 정렬
        df = df.sort_values(by=["date", "time", "weekday", "label"])

        # Output 파일명을 옵션이 포함된 형태로 변경 (예: metrics_250101_250102_10MIN_MAX.csv)
        start_str = start_time_kst.strftime("%y%m%d")
        end_str = end_time_kst.strftime("%y%m%d")
        output_file = f"{output_prefix}_{start_str}_{end_str}_{AGGREGATION_MINUTES}MIN_{ALIGNER_TYPE.upper()}.csv"

        df.to_csv(output_file, index=False)
        print(f"\n✅ 완료! 결과 파일 저장됨: {output_file}")
    else:
        print("\n❌ 조회된 데이터가 없습니다. 설정 파일의 조건 또는 시간 범위를 확인하십시오.")

if __name__ == "__main__":
    fetch_metrics("config.json")
