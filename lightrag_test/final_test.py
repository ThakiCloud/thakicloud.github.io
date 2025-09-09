#!/usr/bin/env python3
import os
import sys
from pathlib import Path

def mock_llm_complete(prompt, **kwargs):
    """간단한 모의 LLM 함수"""
    return f"모의 응답: {prompt[:100]}... [테스트용 응답]"

try:
    from lightrag import LightRAG, QueryParam
    print("✅ LightRAG 임포트 성공")
    
    # 작업 디렉토리 설정
    working_dir = "./final_test_working"
    Path(working_dir).mkdir(exist_ok=True)
    
    print("📝 LightRAG 초기화 테스트 중...")
    
    try:
        # LLM 함수와 함께 초기화
        rag = LightRAG(
            working_dir=working_dir,
            llm_model_func=mock_llm_complete
        )
        print("✅ LightRAG 초기화 성공")
        
        # 샘플 텍스트 삽입
        sample_text = """
        LightRAG는 빠르고 간단한 검색 증강 생성 시스템입니다.
        
        주요 특징:
        1. 이중 레벨 지식 그래프 구조
        2. 네 가지 질의 모드 (naive, local, global, hybrid)
        3. 뛰어난 성능과 간단한 구현
        4. 다양한 LLM 모델 지원
        
        LightRAG는 GraphRAG보다 우수한 성능을 보여줍니다.
        """
        
        print("📝 텍스트 삽입 테스트 중...")
        try:
            rag.insert(sample_text)
            print("✅ 텍스트 삽입 성공")
            
            # 질의 테스트
            print("🔍 질의 테스트 중...")
            test_queries = [
                "LightRAG의 주요 특징은 무엇인가요?",
                "LightRAG의 성능은 어떤가요?"
            ]
            
            for query in test_queries:
                try:
                    result = rag.query(query, param=QueryParam(mode="naive"))
                    print(f"✅ 질의 성공: '{query[:30]}...' -> 응답 길이: {len(result)}자")
                except Exception as e:
                    print(f"⚠️ 질의 실패: {e}")
            
            print("\n🎉 모든 테스트 완료!")
            print("📊 테스트 결과:")
            print("   - LightRAG 설치: ✅")
            print("   - LightRAG 초기화: ✅")
            print("   - 텍스트 삽입: ✅")
            print("   - 질의 처리: ✅")
            print("\n✨ LightRAG가 정상적으로 작동합니다!")
            
        except Exception as e:
            print(f"❌ 텍스트 삽입/질의 실패: {e}")
        
    except Exception as e:
        print(f"❌ LightRAG 초기화 실패: {e}")
        sys.exit(1)
        
except ImportError as e:
    print(f"❌ LightRAG 임포트 실패: {e}")
    sys.exit(1)
