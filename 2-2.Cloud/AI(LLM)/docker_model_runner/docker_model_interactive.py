import time
import configparser
import tiktoken
import requests
import json
import sys

# 설정 로드
config = configparser.ConfigParser()
config.read('config.ini', encoding='utf-8')

BASE_URL = config['AI_SERVER']['BaseUrl']
MODEL_NAME = config['MODEL']['Name']
# 시스템 프롬프트 (영어 권장)
SYSTEM_PROMPT = config['PROMPT'].get('SystemPrompt', "You are a helpful assistant.").strip('"')

def main():
    try:
        encoder = tiktoken.get_encoding("cl100k_base")
    except:
        encoder = None

    print("=" * 50)
    print(f"🤖 AI Chatbot ({MODEL_NAME}) - Robust Mode (UTF-8 Force)")
    print("   - 종료하려면 'quit' 입력")
    print("=" * 50)

    while True:
        try:
            sys.stdout.write("\n질문(User) > ")
            sys.stdout.flush()
            user_input = sys.stdin.readline().strip()
        except KeyboardInterrupt:
            print("\n\n[강제 종료] 프로그램을 종료합니다.")
            break
            
        if not user_input:
            continue
            
        if user_input.lower() in ["quit", "exit"]:
            print("\n대화를 종료합니다.")
            break

        print("-" * 50)
        print("답변(AI)   > ", end="", flush=True)

        start_time = time.time()
        full_response = ""

        try:
            url = f"{BASE_URL}/chat/completions"
            headers = {"Content-Type": "application/json; charset=utf-8"}
            
            # 1. Payload 구성
            payload = {
                "model": MODEL_NAME,
                "messages": [
                    {"role": "system", "content": SYSTEM_PROMPT},
                    {"role": "user", "content": user_input}
                ],
                "stream": True
            }

            # 2. 핵심 수정: ensure_ascii=False로 한글을 그대로 UTF-8 바이트로 변환
            # 이렇게 하면 서버가 \uXXXX 이스케이프 시퀀스를 파싱하다 깨지는 일을 막을 수 있음
            json_bytes = json.dumps(payload, ensure_ascii=False).encode('utf-8')

            # 3. data 파라미터로 바이트 직접 전송
            with requests.post(url, data=json_bytes, headers=headers, stream=True) as r:
                
                if r.status_code != 200:
                    print(f"\n[Server Error] Status: {r.status_code}")
                    # 에러 메시지도 깨질 수 있으니 안전하게 디코딩
                    print(f"Message: {r.content.decode('utf-8', errors='replace')}")
                    continue

                for line in r.iter_lines():
                    if line:
                        # 응답도 안전하게 디코딩
                        decoded_line = line.decode('utf-8', errors='replace')
                        
                        if decoded_line.startswith("data: "):
                            json_str = decoded_line[6:] 
                            if json_str.strip() == "[DONE]":
                                break
                            
                            try:
                                chunk = json.loads(json_str)
                                if "choices" in chunk and len(chunk["choices"]) > 0:
                                    delta = chunk["choices"][0].get("delta", {})
                                    content = delta.get("content", "")
                                    if content:
                                        full_response += content
                                        print(content, end="", flush=True)
                            except json.JSONDecodeError:
                                continue
            
            print() 

        except Exception as e:
            print(f"\n[Connection Error] : {e}")
            continue

        elapsed = time.time() - start_time
        if encoder:
            p_tokens = len(encoder.encode(user_input))
            c_tokens = len(encoder.encode(full_response))
            tps = c_tokens / elapsed if elapsed > 0 else 0
            stats = f"In: {p_tokens}, Out: {c_tokens}"
        else:
            tps = 0
            stats = "N/A"

        print("-" * 50)
        print(f"⏱️  {elapsed:.2f}s | {tps:.1f} t/s | {stats}")

if __name__ == "__main__":
    main()

