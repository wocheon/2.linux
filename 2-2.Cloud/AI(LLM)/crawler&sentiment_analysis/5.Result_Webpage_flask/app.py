from flask import Flask, render_template
import pymysql
import configparser
from collections import OrderedDict

app = Flask(__name__)

# config.ini 경로는 실제 위치에 맞게 조정하세요.
config = configparser.ConfigParser()
config.read('config.ini')  # 기본 경로가 app.py 위치 기준

db_config = {
    'host': config.get('database', 'host'),
    'user': config.get('database', 'user'),
    'password': config.get('database', 'password'),
    'db': config.get('database', 'db'),
    'charset': config.get('database', 'charset')
}

kobert_query = config.get('queries', 'kobert_query')
koelectra_query = config.get('queries', 'koelectra_query')
model_comparison_query = config.get('queries', 'model_comparison_query')


def get_data_kobert():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute(kobert_query)
    rows = cursor.fetchall()
    conn.close()
    return rows

def get_data_koelectra():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()
    cursor.execute(koelectra_query)
    rows = cursor.fetchall()
    conn.close()
    return rows


def get_combined_model_data():
    conn = pymysql.connect(**db_config)
    cursor = conn.cursor()

    query = """
    SELECT
        id, keyword_id, keyword, title, content, url,
        'KoELECTRA' AS model,
        sentiment, score, published_at, collected_at
    FROM koelectra_sentiment_result_view

    UNION ALL

    SELECT
        id, keyword_id, keyword, title, content, url,
        'KoBERT' AS model,
        sentiment, score, published_at, collected_at
    FROM kobert_sentiment_result_view
    ORDER BY id, model;
    """

    cursor.execute(query)
    rows = cursor.fetchall()
    conn.close()

    combined_data = OrderedDict()
    model_set = set()
    keyword_set = set()
    sentiment_map = {}  # 모델별 감정 집합

    for row in rows:
        article_id = row[0]
        base_info = row[0:6] + row[9:11]  # id~url + published_at, collected_at
        model_name = row[6]
        sentiment = row[7]
        score = row[8]

        model_set.add(model_name)
        keyword_set.add(row[2] or '')

        # 모델별 sentiment 분리
        if model_name not in sentiment_map:
            sentiment_map[model_name] = set()
        if sentiment:
            sentiment_map[model_name].add(sentiment.lower())

        if article_id not in combined_data:
            combined_data[article_id] = {
                'meta': base_info,
                'models': {}
            }

        combined_data[article_id]['models'][model_name] = {
            'sentiment': sentiment,
            'score': score
        }

    model_list = sorted(model_set)
    keyword_list = sorted(keyword_set)
    # 모델별 감정 목록 sorted
    sentiment_map = {k: sorted(v) for k, v in sentiment_map.items()}

    return combined_data, model_list, keyword_list, sentiment_map


@app.route('/')
def main():
    return render_template('main.html')

@app.route('/kobert')
def kobert():
    data = get_data_kobert()
    # 감정 필터 옵션 리스트 (소문자 일관성 유지)
    sentiment_list = ['angry', 'fear', 'happy', 'tender', 'sad']
    return render_template('kobert_table.html', data=data, sentiment_list=sentiment_list, active_tab='kobert')

@app.route('/koelectra')
def koelectra():
    data = get_data_koelectra()
    sentiment_list = ['angry', 'happy', 'anxious', 'embarrassed', 'sad', 'heartache']
    return render_template('koelectra_table.html', data=data, sentiment_list=sentiment_list, active_tab='koelectra')

@app.route('/comparison')
def comparison():
    combined_data, model_list, keyword_list, sentiment_map = get_combined_model_data()

    emoji_map = {
        'KoBERT': {
            'angry': '😠',
            'fear': '😳',
            'happy': '😊',
            'tender': '😐',
            'sad': '😢'
        },
        'KoELECTRA': {
            'angry': '😠',
            'happy': '😊',
            'anxious': '😰',
            'embarrassed': '😳',
            'sad': '😢',
            'heartache': '💔'
        }
        # 새 모델이 생기면 여기 추가
    }

    return render_template('comparison.html',
                           combined_data=combined_data,
                           model_list=model_list,
                           keyword_set=keyword_list,
                           sentiment_map=sentiment_map,
                           emoji_map=emoji_map,
                           active_tab='comparison')

if __name__ == "__main__":
    app.run(debug=True)
