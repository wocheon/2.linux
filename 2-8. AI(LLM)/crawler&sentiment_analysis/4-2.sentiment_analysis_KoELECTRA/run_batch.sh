docker rm sentiment_analysis_batch -f

docker run -d  --network=host --name sentiment_analysis_batch \
	-v ../models/koelectra/KoELECTRA_fine_tunning_emotion/:/models/koelectra \
	-v "$(pwd)":/app  \
       	sentiment_analysis_koelectra:latest

docker logs sentiment_analysis_batch -f
