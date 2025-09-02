import json
from google.cloud import monitoring_v3
import pandas as pd
import datetime
import pytz

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

        # 🔹 KST -> offset-aware datetime 객체로 변환
#    start_time_kst = datetime.datetime.fromisoformat(config["start_time_kst"])
#    end_time_kst = datetime.datetime.fromisoformat(config["end_time_kst"])
    start_time_kst = kst.localize(datetime.datetime.fromisoformat(config["start_time_kst"]))
    end_time_kst = kst.localize(datetime.datetime.fromisoformat(config["end_time_kst"]))

        # 🔹 Time offset 적용
    start_time_offset = config.get("start_time_offset", 0)  # 시작 시간 조정 (분 단위)
    end_time_offset = config.get("end_time_offset", 0)      # 종료 시간 조정 (분 단위)

    # 🔹 시작 시간과 종료 시간에 각각 오프셋 적용
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

        #  Cloud Monitoring API에 보낼 요청 설정
        request = {
            "name": f"projects/{project_id}",
            "filter": filter_template,
            "interval": interval,
            "view": monitoring_v3.ListTimeSeriesRequest.TimeSeriesView.FULL,
            "aggregation": {
                "alignment_period": {"seconds": 60},  # 1분 단위 정렬
                "per_series_aligner": monitoring_v3.Aggregation.Aligner.ALIGN_MEAN,
            },
        }

        # 데이터 조회
        print(f"▶ Metric 데이터 가져오는 중 : {alias} ({metric_type})")
        response = client.list_time_series(request=request)

        # 응답 데이터 처리 (UTC → KST 변환)
        for time_series in response:
            for point in time_series.points:
                timestamp_utc = point.interval.end_time
                timestamp_kst = timestamp_utc.astimezone(kst)  # KST 변환
                if not (adjusted_start_time_kst <= timestamp_kst <= adjusted_end_time_kst):
                    continue

                timestamp_str = timestamp_kst.strftime("%Y-%m-%d %H:%M:%S")
                label_value = time_series.resource.labels.get(label_key, "unknown")

                key = (timestamp_str, label_value)
                if key not in data_dict:
                    data_dict[key] = {
                                                "timestamp": timestamp_str,
                        "date": timestamp_kst.strftime("%Y-%m-%d"),
                                                "time": timestamp_kst.strftime("%H:%M:%S"),
                                                "weekday": timestamp_kst.strftime("%A"),
                                                "label": label_value,
                                        }
                    data_dict[key][alias] = round(point.value.double_value, 2)

    df = pd.DataFrame(list(data_dict.values()))

        # Output file에 timestamp컬럼이 출력되지않도록 DROP
    df = df.drop(columns=["timestamp"])

        # 정렬
    df = df.sort_values(by=["date", "time", "weekday", "label"])

        # Output 파일명을 [파일명]_[시작시간]_[종료시간].csv 형태로 변경
    start_str = start_time_kst.strftime("%y%m%d")
    end_str = end_time_kst.strftime("%y%m%d")
    output_file = f"{output_prefix}_{start_str}_{end_str}.csv"

    df.to_csv(output_file, index=False)
    print(f"\n✅ 완료! 결과 파일 저장됨: {output_file}")

if __name__ == "__main__":
                fetch_metrics("config.json")