#!/usr/bin/env python3
"""
NVIDIA Nemotron Nano 2 9B Thinking Budget 클라이언트
macOS 환경에서 Thinking Budget 기능을 테스트하는 클라이언트 구현
"""

from typing import Any, Dict, List
import openai
import time
import sys

try:
    from transformers import AutoTokenizer
except ImportError:
    print("❌ transformers 패키지가 설치되지 않았습니다.")
    print("설치 명령어: pip install transformers")
    sys.exit(1)

class ThinkingBudgetClient:
    def __init__(self, base_url: str, api_key: str, tokenizer_name_or_path: str):
        self.base_url = base_url
        self.api_key = api_key
        self.tokenizer = AutoTokenizer.from_pretrained(tokenizer_name_or_path)
        self.client = openai.OpenAI(base_url=self.base_url, api_key=self.api_key)

    def chat_completion(
        self,
        model: str,
        messages: List[Dict[str, Any]],
        max_thinking_budget: int = 512,
        max_tokens: int = 1024,
        **kwargs,
    ) -> Dict[str, Any]:
        assert (
            max_tokens > max_thinking_budget
        ), f"thinking budget은 최대 토큰 수보다 작아야 합니다. 주어진 값: {max_tokens=}, {max_thinking_budget=}"

        # 1단계: 추론 콘텐츠 생성을 위한 첫 번째 호출
        try:
            response = self.client.chat.completions.create(
                model=model, 
                messages=messages, 
                max_tokens=max_thinking_budget, 
                **kwargs
            )
            content = response.choices[0].message.content
        except Exception as e:
            return {"error": f"첫 번째 API 호출 실패: {str(e)}"}

        reasoning_content = content
        if not "</think>" in reasoning_content:
            # 추론 콘텐츠가 너무 길면 마침표로 종료
            reasoning_content = f"{reasoning_content}.\n</think>\n\n"
        
        reasoning_tokens_len = len(
            self.tokenizer.encode(reasoning_content, add_special_tokens=False)
        )
        remaining_tokens = max_tokens - reasoning_tokens_len
        
        assert (
            remaining_tokens > 0
        ), f"남은 토큰이 양수여야 합니다. 현재 값: {remaining_tokens=}. max_tokens를 늘리거나 max_thinking_budget을 낮추세요."

        # 2단계: 추론 콘텐츠를 메시지에 추가하고 완성 호출
        messages.append({"role": "assistant", "content": reasoning_content})
        prompt = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            continue_final_message=True,
        )
        
        try:
            response = self.client.completions.create(
                model=model, 
                prompt=prompt, 
                max_tokens=remaining_tokens, 
                **kwargs
            )
        except Exception as e:
            return {"error": f"두 번째 API 호출 실패: {str(e)}"}

        response_data = {
            "reasoning_content": reasoning_content.strip().strip("</think>").strip(),
            "content": response.choices[0].text,
            "finish_reason": response.choices[0].finish_reason,
            "thinking_tokens": reasoning_tokens_len,
            "response_tokens": len(self.tokenizer.encode(response.choices[0].text, add_special_tokens=False))
        }
        return response_data

def test_thinking_budget():
    """Thinking Budget 기능 테스트"""
    print("🧠 NVIDIA Nemotron Nano 2 9B Thinking Budget 테스트 시작...")
    
    tokenizer_name_or_path = "nvidia/NVIDIA-Nemotron-Nano-9B-v2"
    
    try:
        client = ThinkingBudgetClient(
            base_url="http://localhost:8000/v1",
            api_key="EMPTY",
            tokenizer_name_or_path=tokenizer_name_or_path,
        )
        print("✅ 클라이언트 초기화 완료")
    except Exception as e:
        print(f"❌ 클라이언트 초기화 실패: {str(e)}")
        print("💡 해결 방법:")
        print("1. vLLM 서버가 실행 중인지 확인: http://localhost:8000")
        print("2. 필요한 패키지 설치: pip install vllm openai transformers")
        return

    # 테스트 케이스들
    test_cases = [
        {
            "name": "간단한 수학 문제",
            "messages": [
                {"role": "system", "content": "당신은 도움이 되는 AI 어시스턴트입니다. /think"},
                {"role": "user", "content": "2 + 2 = ?"}
            ],
            "thinking_budget": 128
        },
        {
            "name": "복잡한 수학 문제", 
            "messages": [
                {"role": "system", "content": "당신은 도움이 되는 AI 어시스턴트입니다. /think"},
                {"role": "user", "content": "복잡한 수학 문제: 2^10 + 3^5 - 4^3 = ?"}
            ],
            "thinking_budget": 512
        },
        {
            "name": "코딩 문제",
            "messages": [
                {"role": "system", "content": "당신은 도움이 되는 AI 어시스턴트입니다. /think"},
                {"role": "user", "content": "Python으로 피보나치 수열을 구하는 함수를 작성해주세요."}
            ],
            "thinking_budget": 1024
        }
    ]

    for i, test_case in enumerate(test_cases, 1):
        print(f"\n📋 테스트 {i}: {test_case['name']}")
        print(f"💭 Thinking Budget: {test_case['thinking_budget']} 토큰")
        
        start_time = time.time()
        result = client.chat_completion(
            model="nvidia/NVIDIA-Nemotron-Nano-9B-v2",
            messages=test_case["messages"],
            max_thinking_budget=test_case["thinking_budget"],
            max_tokens=2048,
            temperature=0.6,
            top_p=0.95,
        )
        end_time = time.time()
        
        if "error" in result:
            print(f"❌ 오류 발생: {result['error']}")
            continue
        
        print(f"⏱️  응답 시간: {end_time - start_time:.2f}초")
        print(f"🧠 사고 토큰: {result.get('thinking_tokens', 0)}개")
        print(f"💬 응답 토큰: {result.get('response_tokens', 0)}개")
        print("🤔 추론 과정:")
        print(f"   {result['reasoning_content'][:200]}...")
        print("✅ 최종 답변:")
        print(f"   {result['content'][:200]}...")

def test_budget_comparison():
    """다양한 Thinking Budget 비교 테스트"""
    print("\n📊 Thinking Budget 비교 분석 시작...")
    
    tokenizer_name_or_path = "nvidia/NVIDIA-Nemotron-Nano-9B-v2"
    
    try:
        client = ThinkingBudgetClient(
            base_url="http://localhost:8000/v1",
            api_key="EMPTY",
            tokenizer_name_or_path=tokenizer_name_or_path,
        )
    except Exception as e:
        print(f"❌ 클라이언트 초기화 실패: {str(e)}")
        return

    question = "복잡한 논리 문제: 만약 모든 고양이가 동물이고, 모든 동물이 생명체라면, 모든 고양이는 생명체인가?"
    budgets = [64, 128, 256, 512, 1024]
    
    print(f"🎯 테스트 질문: {question}")
    print("\n┌─────────────┬─────────────┬─────────────┬─────────────┐")
    print("│ Budget      │ 응답시간    │ 사고토큰    │ 응답토큰    │")
    print("├─────────────┼─────────────┼─────────────┼─────────────┤")
    
    for budget in budgets:
        start_time = time.time()
        result = client.chat_completion(
            model="nvidia/NVIDIA-Nemotron-Nano-9B-v2",
            messages=[
                {"role": "system", "content": "당신은 논리적 사고를 하는 AI입니다. /think"},
                {"role": "user", "content": question}
            ],
            max_thinking_budget=budget,
            max_tokens=2048,
            temperature=0.6,
            top_p=0.95,
        )
        end_time = time.time()
        
        if "error" in result:
            print(f"│ {budget:11d} │ ERROR       │ ERROR       │ ERROR       │")
            continue
            
        response_time = end_time - start_time
        thinking_tokens = result.get('thinking_tokens', 0)
        response_tokens = result.get('response_tokens', 0)
        
        print(f"│ {budget:11d} │ {response_time:9.2f}s │ {thinking_tokens:9d} │ {response_tokens:9d} │")
    
    print("└─────────────┴─────────────┴─────────────┴─────────────┘")

if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Nemotron Nano 2 Thinking Budget 테스트")
    parser.add_argument("--test", choices=["basic", "comparison", "all"], 
                       default="basic", help="실행할 테스트 유형")
    
    args = parser.parse_args()
    
    if args.test in ["basic", "all"]:
        test_thinking_budget()
    
    if args.test in ["comparison", "all"]:
        test_budget_comparison()
    
    print("\n🎉 테스트 완료!")
    print("💡 더 많은 정보: https://huggingface.co/nvidia/NVIDIA-Nemotron-Nano-9B-v2")
