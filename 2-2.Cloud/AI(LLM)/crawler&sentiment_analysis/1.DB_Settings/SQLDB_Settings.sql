CREATE DATABASE IF NOT EXISTS crawler_sentiment_analysis;
USE crawler_sentiment_analysis;

# 유저 생성 
CREATE user IF NOT EXISTS 'appuser'@'%' IDENTIFIED BY 'appuserpass';

-- 모든 권한을 부여 
GRANT ALL PRIVILEGES ON crawler_sentiment_analysis.* TO 'appuser'@'%';

-- 변경된 사항 적용 
FLUSH PRIVILEGES;

-- 키워드 테이블
CREATE TABLE IF NOT EXISTS crawler_keyword_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keyword VARCHAR(100) UNIQUE NOT NULL,
    `desc` VARCHAR(255)
);

-- 기사 테이블
CREATE TABLE IF NOT EXISTS crawler_article_list (
    id INT AUTO_INCREMENT PRIMARY KEY,
    keyword_id INT,
    title VARCHAR(1024),
    content TEXT,
    url VARCHAR(2048) UNIQUE,
    published_at DATETIME,
    collected_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- 감성분석 결과 테이블
CREATE TABLE IF NOT EXISTS kobert_sentiment_analysis_result (
    id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT,
    sentiment VARCHAR(20),
    score FLOAT,
    analyzed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS koelectra_sentiment_analysis_result (
    id INT AUTO_INCREMENT PRIMARY KEY,
    article_id INT,
    sentiment VARCHAR(20),
    score FLOAT,
    analyzed_at DATETIME DEFAULT CURRENT_TIMESTAMP
);


-- 결과 페이지 확인용 View 생성 - KoBERT

create view kobert_sentiment_result_view 
as
select 
A.id
,A.keyword_id
,B.keyword
,A.title
,A.content
,A.url
,C.sentiment as kobert_sentiment
,C.score as kobert_score
,A.published_at
,A.collected_at
from 
	crawler_article_list A,
	crawler_keyword_list B,
	kobert_sentiment_analysis_result C
where 
	A.keyword_id = B.id
	AND A.id = C.article_id;


-- 결과 페이지 확인용 View 생성 -  KoELECTRA

create view koelectra_sentiment_result_view 
as
select 
A.id
,A.keyword_id
,B.keyword
,A.title
,A.content
,A.url
,C.sentiment as koelectra_sentiment
,C.score as koelectra_score
,A.published_at
,A.collected_at
from 
	crawler_article_list A,
	crawler_keyword_list B,
	koelectra_sentiment_analysis_result C
where 
	A.keyword_id = B.id
	AND A.id = C.article_id;    

-- 결과 페이지 확인용 View 생성 - 모델 비교

create view model_comparison_result_view 
as
SELECT 
id, keyword_id, keyword, title, content, url,
'KoELECTRA' AS model,
koelectra_sentiment as sentiment, koelectra_score as score, published_at, collected_at
FROM koelectra_sentiment_result_view
UNION ALL
SELECT 
id, keyword_id, keyword, title, content, url,
'KoBERT' AS model,
kobert_sentiment as sentiment, kobert_score as score, published_at, collected_at
FROM kobert_sentiment_result_view
ORDER BY id, model;