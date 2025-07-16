#!/usr/bin/env python3
"""
Meetily 한국어 회의록 테스트 스크립트
"""

import subprocess
import os
import tempfile
import time
from pathlib import Path

def test_ollama_connection():
    """Ollama 서버 연결 테스트"""
    try:
        result = subprocess.run(['ollama', 'list'], capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("✅ Ollama 연결 성공")
            print("사용 가능한 모델:")
            print(result.stdout)
            return True
        else:
            print("❌ Ollama 연결 실패")
            return False
    except Exception as e:
        print(f"❌ Ollama 테스트 중 오류: {e}")
        return False

def test_qwen_model():
    """Qwen2.5 모델 테스트"""
    test_prompt = "안녕하세요. 회의록 작성을 도와주세요."
    
    try:
        print("🧪 Qwen2.5:7b 모델 테스트 중...")
        result = subprocess.run([
            'ollama', 'run', 'qwen2.5:7b', test_prompt
        ], capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ Qwen2.5:7b 모델 응답 성공")
            print(f"응답: {result.stdout[:200]}...")
            return True
        else:
            print("❌ Qwen2.5:7b 모델 응답 실패")
            print(f"오류: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Qwen 모델 테스트 중 오류: {e}")
        return False

def create_test_korean_text():
    """테스트용 한국어 회의 내용 생성"""
    meeting_text = """
    안녕하세요. 오늘 프로젝트 진행 상황에 대해 논의하겠습니다.
    
    김철수: 지난주 개발한 AI 기능이 잘 작동하고 있습니다. 정확도가 95% 이상 나오고 있어요.
    
    이영희: 좋은 소식이네요. 사용자 인터페이스 개선도 필요할 것 같은데, 어떻게 생각하시나요?
    
    박민수: UI 개선은 중요합니다. 특히 모바일 환경에서의 사용성을 더 개선해야 할 것 같습니다.
    
    김철수: 네, 다음 주까지 모바일 최적화 작업을 완료하겠습니다.
    
    이영희: 그럼 이번 주 금요일에 다시 모여서 진행 상황을 확인하도록 하죠.
    
    회의 종료.
    """
    return meeting_text.strip()

def test_korean_summarization():
    """한국어 회의 요약 테스트"""
    meeting_text = create_test_korean_text()
    
    summarization_prompt = f"""
다음은 한국어 회의 내용입니다. 이를 요약해주세요:

회의 내용:
{meeting_text}

다음 형식으로 요약해주세요:
1. 주요 논의사항
2. 결정사항
3. 액션 아이템
4. 다음 회의 일정
"""

    try:
        print("🧪 한국어 회의록 요약 테스트 중...")
        result = subprocess.run([
            'ollama', 'run', 'qwen2.5:7b', summarization_prompt
        ], capture_output=True, text=True, timeout=60)
        
        if result.returncode == 0:
            print("✅ 한국어 회의록 요약 성공")
            print("=" * 50)
            print("회의록 요약 결과:")
            print("=" * 50)
            print(result.stdout)
            print("=" * 50)
            return True
        else:
            print("❌ 한국어 회의록 요약 실패")
            print(f"오류: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ 한국어 요약 테스트 중 오류: {e}")
        return False

def test_whisper_availability():
    """Whisper 모델 사용 가능성 테스트"""
    whisper_path = Path("whisper.cpp/build/bin/whisper-server")
    
    if whisper_path.exists():
        print("✅ Whisper.cpp 서버 빌드 완료")
        return True
    else:
        print("❌ Whisper.cpp 서버를 찾을 수 없습니다")
        return False

def main():
    """메인 테스트 함수"""
    print("🎯 Meetily 한국어 회의록 테스트 시작")
    print("=" * 60)
    
    # 테스트 순서
    tests = [
        ("Ollama 연결", test_ollama_connection),
        ("Qwen2.5 모델", test_qwen_model),
        ("Whisper 가용성", test_whisper_availability),
        ("한국어 회의록 요약", test_korean_summarization),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        print(f"\n📋 {test_name} 테스트:")
        print("-" * 40)
        
        try:
            success = test_func()
            results.append((test_name, success))
        except Exception as e:
            print(f"❌ {test_name} 테스트 중 예외 발생: {e}")
            results.append((test_name, False))
        
        time.sleep(1)  # 테스트 간격
    
    # 결과 요약
    print("\n" + "=" * 60)
    print("🏁 테스트 결과 요약")
    print("=" * 60)
    
    for test_name, success in results:
        status = "✅ 성공" if success else "❌ 실패"
        print(f"{test_name}: {status}")
    
    successful_tests = sum(1 for _, success in results if success)
    total_tests = len(results)
    
    print(f"\n총 {total_tests}개 테스트 중 {successful_tests}개 성공")
    
    if successful_tests == total_tests:
        print("🎉 모든 테스트가 성공했습니다!")
    else:
        print("⚠️  일부 테스트가 실패했습니다.")

if __name__ == "__main__":
    main() 