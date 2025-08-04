#!/usr/bin/env python3
"""
LangExtract API 테스트 스크립트
실제 API 키를 설정한 후 실행하세요.
"""

import os
import langextract as lx

def test_with_api():
    """실제 API를 사용한 테스트"""
    
    # API 키 확인
    api_key = os.getenv('LANGEXTRACT_API_KEY')
    if not api_key:
        print("❌ LANGEXTRACT_API_KEY 환경변수를 설정하세요")
        return
    
    # 테스트 텍스트
    text = """
    김철수는 30세의 데이터 사이언티스트입니다.
    서울에 거주하며 Python, R, SQL을 다룹니다.
    현재 핀테크 회사에서 ML 엔지니어로 근무 중입니다.
    """
    
    # 추출 예시
    examples = [
        {
            "name": "박영희",
            "age": 28,
            "profession": "소프트웨어 엔지니어",
            "location": "부산",
            "skills": ["Java", "Spring", "React"]
        }
    ]
    
    # 추출 실행
    try:
        result = lx.extract(
            text_or_documents=text,
            prompt_description="인물 정보를 추출하세요",
            examples=examples,
            model_id="gemini-2.5-flash"
        )
        
        print("✅ 추출 성공!")
        print("결과:", result)
        
        # 결과 저장
        lx.io.save_annotated_documents(
            [result], 
            output_name="test_results.jsonl", 
            output_dir="."
        )
        
        # 시각화 생성
        html_content = lx.visualize("test_results.jsonl")
        with open("test_visualization.html", "w", encoding="utf-8") as f:
            f.write(html_content)
        
        print("✅ 시각화 파일 생성: test_visualization.html")
        
    except Exception as e:
        print(f"❌ 추출 실패: {e}")

if __name__ == "__main__":
    test_with_api()
