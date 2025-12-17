docker rm sentiment_analysis_kobert_batch -f

docker run -d  --network=host --name sentiment_analysis_kobert_batch \
	-v ../models/kobert/koBERT-Senti5/:/models/kobert \
	-v "$(pwd)":/app  \
       	sentiment_analysis_kobert:latest

docker logs sentiment_analysis_kobert_batch -f
