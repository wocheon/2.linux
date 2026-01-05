from openai import OpenAI
client = OpenAI(
    base_url="http://35.216.26.195:11434/v1",  # Ollama 기본 포트
    api_key="ollama"  # Ollama는 API Key로 'ollama'를 관례적으로 사용
)
response = client.chat.completions.create(
    model="qwen3:4b",  # ollama create로 만든 이름
    messages=[
        {"role": "user", "content": "Why is the sky blue?"}
    ],
    max_tokens=1024,
    temperature=0.7
)
print(response.choices[0].message.content)
