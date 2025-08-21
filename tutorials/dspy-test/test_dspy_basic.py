#!/usr/bin/env python3
"""
DSPy 기본 테스트 스크립트
- 환경 설정 및 기본 구조 이해
- Signature, Module, ChainOfThought 테스트
"""

import dspy
import sys

def test_dspy_import():
    """DSPy 가져오기 테스트"""
    print("🧪 DSPy 가져오기 테스트")
    print(f"DSPy 버전: {dspy.__version__}")
    print("✅ DSPy 가져오기 성공\n")

def test_signature_basic():
    """DSPy Signature 기본 테스트"""
    print("🧪 DSPy Signature 기본 테스트")
    
    # 기본 시그니처 생성
    signature = dspy.Signature("question -> answer")
    print(f"기본 시그니처: {signature}")
    
    # 필드가 있는 시그니처 생성
    signature_with_fields = dspy.Signature("context, question -> answer")
    print(f"필드가 있는 시그니처: {signature_with_fields}")
    print("✅ Signature 테스트 성공\n")

def test_signature_detailed():
    """DSPy Signature 상세 테스트"""
    print("🧪 DSPy Signature 상세 테스트")
    
    # InputField와 OutputField를 사용한 상세 시그니처
    class DetailedSignature(dspy.Signature):
        """상세한 시그니처 예제"""
        context = dspy.InputField(desc="관련 컨텍스트 정보")
        question = dspy.InputField(desc="사용자 질문")
        answer = dspy.OutputField(desc="질문에 대한 답변")
        confidence = dspy.OutputField(desc="답변에 대한 신뢰도 (1-10)")
    
    print(f"상세 시그니처 클래스: {DetailedSignature}")
    print(f"입력 필드들: {[field for field in DetailedSignature.input_fields]}")
    print(f"출력 필드들: {[field for field in DetailedSignature.output_fields]}")
    print("✅ 상세 Signature 테스트 성공\n")

def test_module_structure():
    """DSPy Module 구조 테스트 (LM 없이)"""
    print("🧪 DSPy Module 구조 테스트")
    
    # ChainOfThought 모듈 생성 (LM 설정 없이)
    signature = dspy.Signature("question -> answer")
    cot_module = dspy.ChainOfThought(signature)
    
    print(f"ChainOfThought 모듈: {cot_module}")
    print(f"모듈 타입: {type(cot_module)}")
    print(f"모듈 속성들: {dir(cot_module)}")
    
    # Predict 모듈도 테스트
    predict_module = dspy.Predict(signature)
    print(f"Predict 모듈: {predict_module}")
    print(f"Predict 타입: {type(predict_module)}")
    print("✅ Module 구조 테스트 성공\n")

def test_prediction_structure():
    """DSPy Prediction 구조 테스트"""
    print("🧪 DSPy Prediction 구조 테스트")
    
    # 예측 객체 생성
    prediction = dspy.Prediction(
        answer="이것은 테스트 답변입니다.",
        confidence=8,
        reasoning="논리적 추론 과정입니다."
    )
    
    print(f"Prediction 객체: {prediction}")
    print(f"답변: {prediction.answer}")
    print(f"신뢰도: {prediction.confidence}")
    print(f"추론: {prediction.reasoning}")
    print("✅ Prediction 구조 테스트 성공\n")

def test_example_structure():
    """DSPy Example 구조 테스트"""
    print("🧪 DSPy Example 구조 테스트")
    
    # Example 객체 생성
    example = dspy.Example(
        question="파이썬에서 리스트란 무엇인가요?",
        answer="파이썬의 리스트는 여러 항목을 순서대로 저장할 수 있는 데이터 구조입니다.",
        context="파이썬 프로그래밍 언어에서 사용되는 기본 데이터 타입"
    )
    
    print(f"Example 객체: {example}")
    print(f"질문: {example.question}")
    print(f"답변: {example.answer}")
    print(f"컨텍스트: {example.context}")
    
    # 입력만 있는 예제로 변환
    input_only = example.with_inputs("question", "context")
    print(f"입력만 있는 예제: {input_only}")
    print("✅ Example 구조 테스트 성공\n")

def main():
    """메인 테스트 함수"""
    print("🚀 DSPy 기본 기능 테스트 시작\n")
    
    try:
        test_dspy_import()
        test_signature_basic()
        test_signature_detailed()
        test_module_structure()
        test_prediction_structure()
        test_example_structure()
        
        print("🎉 모든 기본 테스트 완료!")
        print("📋 테스트 요약:")
        print("  ✅ DSPy 가져오기")
        print("  ✅ Signature 기본/상세")
        print("  ✅ Module 구조")
        print("  ✅ Prediction 구조")
        print("  ✅ Example 구조")
        
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
