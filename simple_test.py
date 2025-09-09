#!/usr/bin/env python3
import os
import sys
from pathlib import Path

try:
    from lightrag import LightRAG, QueryParam
    print("✅ LightRAG 임포트 성공")
    
    # 단순 초기화 테스트 (LLM 함수 없이)
    working_dir = "./test_working"
    Path(working_dir).mkdir(exist_ok=True)
    
    # 기본 LightRAG 초기화
    print("📝 LightRAG 초기화 테스트 중...")
    
    # API 키 설정 (더미)
    os.environ["OPENAI_API_KEY"] = "sk-test-dummy-key"
    
    try:
        rag = LightRAG(working_dir=working_dir)
        print("✅ LightRAG 초기화 성공")
        
        # 간단한 텍스트 삽입 테스트
        sample_text = "이것은 LightRAG 테스트용 샘플 텍스트입니다. LightRAG는 훌륭한 RAG 시스템입니다."
        
        print("📝 텍스트 삽입 테스트 중...")
        try:
            rag.insert(sample_text)
            print("✅ 텍스트 삽입 성공")
        except Exception as e:
            print(f"⚠️ 텍스트 삽입 실패 (API 키 필요): {e}")
        
        print("\n🎉 기본 테스트 완료!")
        
    except Exception as e:
        print(f"❌ LightRAG 초기화 실패: {e}")
        
except ImportError as e:
    print(f"❌ LightRAG 임포트 실패: {e}")
    sys.exit(1)
