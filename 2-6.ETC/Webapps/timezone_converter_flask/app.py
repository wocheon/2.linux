from flask import Flask, render_template, request, jsonify
from datetime import datetime
import pytz

app = Flask(__name__)

TIMEZONES = [
    'Asia/Seoul',
    'UTC',
    'America/New_York',
    'Europe/London',
    'Asia/Tokyo',
    'Australia/Sydney'
]

@app.route('/')
def index():
    # 서버 현재 시간 (UTC 기준)
    now_utc = datetime.utcnow().replace(tzinfo=pytz.utc)
    # ISO 8601 형식 문자열로 전달
    now_iso = now_utc.isoformat()
    return render_template('index.html', timezones=TIMEZONES, now_iso=now_iso)

@app.route('/convert', methods=['POST'])
def convert():
    from_tz = request.json.get('from_tz')
    to_tz = request.json.get('to_tz')
    dt_str = request.json.get('datetime')

    try:
        from_zone = pytz.timezone(from_tz)
        to_zone = pytz.timezone(to_tz)

        if dt_str:
            if dt_str.endswith('Z'):
                dt_str = dt_str[:-1] + '+00:00'
            dt = datetime.fromisoformat(dt_str)
            # tzinfo 없으면 localize
            if dt.tzinfo is None:
                dt = from_zone.localize(dt)
            else:
                dt = dt.astimezone(from_zone)
        else:
            # 입력 없으면 현재시간 사용
            dt = datetime.utcnow().replace(tzinfo=pytz.utc).astimezone(from_zone)

        # 변환된 시간
        target_dt = dt.astimezone(to_zone)

        # 모든 시간대별 시간 계산 (입력된 기준 시간 dt를 기준으로)
        times = {}
        for tz in TIMEZONES:
            tz_obj = pytz.timezone(tz)
            times[tz] = dt.astimezone(tz_obj).strftime('%Y-%m-%d %H:%M:%S %Z')

        return jsonify({
            'converted': target_dt.isoformat(),
            'times': times
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)