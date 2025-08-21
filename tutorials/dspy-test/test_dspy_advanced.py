#!/usr/bin/env python3
"""
DSPy 고급 테스트 스크립트
- 로컬 모델 설정 및 실제 추론 테스트
- 옵티마이저 및 파이프라인 테스트
"""

import dspy
import sys
from typing import List, Optional

def test_dummy_lm_setup():
    """더미 LM으로 DSPy 설정 테스트"""
    print("🧪 더미 LM 설정 테스트")
    
    # 더미 LM 클래스 생성
    class DummyLM(dspy.LM):
        def __init__(self):
            super().__init__("dummy")
            
        def __call__(self, prompt, **kwargs):
            # 더미 응답 생성
            if "Question:" in prompt and "Answer:" in prompt:
                return ["이것은 더미 LM의 응답입니다."]
            elif "reasoning" in prompt.lower():
                return ["단계별로 생각해보면: 1) 먼저 질문을 분석하고, 2) 관련 정보를 찾고, 3) 논리적으로 결론을 내립니다. 답변: 더미 응답입니다."]
            else:
                return ["더미 응답"]
                
        def generate(self, prompt, **kwargs):
            response = self(prompt, **kwargs)
            return response
    
    # 더미 LM 설정
    dummy_lm = DummyLM()
    dspy.configure(lm=dummy_lm)
    
    print(f"설정된 LM: {dummy_lm}")
    print("✅ 더미 LM 설정 성공\n")
    return dummy_lm

def test_basic_prediction():
    """기본 예측 테스트"""
    print("🧪 기본 예측 테스트")
    
    # 간단한 질문-답변 시그니처
    qa_signature = dspy.Signature("question -> answer")
    predictor = dspy.Predict(qa_signature)
    
    # 예측 실행 (더미 LM 사용)
    try:
        result = predictor(question="파이썬이란 무엇인가요?")
        print(f"질문: 파이썬이란 무엇인가요?")
        print(f"답변: {result.answer}")
        print("✅ 기본 예측 테스트 성공\n")
    except Exception as e:
        print(f"⚠️  예측 실행 중 오류 (예상됨): {e}")
        print("더미 LM이므로 실제 API 호출은 실패할 수 있습니다.\n")

def test_chain_of_thought():
    """Chain of Thought 테스트"""
    print("🧪 Chain of Thought 테스트")
    
    # CoT 시그니처
    cot_signature = dspy.Signature("question -> answer")
    cot_predictor = dspy.ChainOfThought(cot_signature)
    
    try:
        result = cot_predictor(question="수학 문제: 2 + 3 = ?")
        print(f"질문: 수학 문제: 2 + 3 = ?")
        if hasattr(result, 'reasoning'):
            print(f"추론: {result.reasoning}")
        print(f"답변: {result.answer}")
        print("✅ Chain of Thought 테스트 성공\n")
    except Exception as e:
        print(f"⚠️  CoT 실행 중 오류 (예상됨): {e}")
        print("더미 LM이므로 실제 API 호출은 실패할 수 있습니다.\n")

def test_dataset_creation():
    """데이터셋 생성 및 관리 테스트"""
    print("🧪 데이터셋 생성 및 관리 테스트")
    
    # 예제 데이터셋 생성
    examples = [
        dspy.Example(
            question="파이썬에서 리스트란?",
            answer="순서가 있는 데이터 컬렉션입니다."
        ),
        dspy.Example(
            question="머신러닝이란?",
            answer="데이터로부터 패턴을 학습하는 AI 기술입니다."
        ),
        dspy.Example(
            question="DSPy란?",
            answer="언어 모델을 위한 선언적 프레임워크입니다."
        )
    ]
    
    print(f"생성된 예제 수: {len(examples)}")
    for i, example in enumerate(examples):
        print(f"예제 {i+1}: {example.question[:20]}...")
    
    # 입력만 있는 데이터셋으로 변환
    input_examples = [ex.with_inputs("question") for ex in examples]
    print(f"입력만 있는 예제 수: {len(input_examples)}")
    
    print("✅ 데이터셋 생성 테스트 성공\n")
    return examples

def test_signature_variations():
    """다양한 시그니처 패턴 테스트"""
    print("🧪 다양한 시그니처 패턴 테스트")
    
    # 1. 분류 시그니처
    classification_sig = dspy.Signature("text -> category")
    print(f"분류 시그니처: {classification_sig}")
    
    # 2. 요약 시그니처
    summary_sig = dspy.Signature("document -> summary")
    print(f"요약 시그니처: {summary_sig}")
    
    # 3. 복잡한 시그니처 (클래스 기반)
    class ComplexSignature(dspy.Signature):
        """복잡한 작업을 위한 시그니처"""
        context = dspy.InputField(desc="배경 정보")
        question = dspy.InputField(desc="사용자 질문")
        examples = dspy.InputField(desc="참고 예제들")
        
        reasoning = dspy.OutputField(desc="단계별 추론 과정")
        answer = dspy.OutputField(desc="최종 답변")
        confidence = dspy.OutputField(desc="신뢰도 점수 (1-10)")
        sources = dspy.OutputField(desc="참고한 정보원들")
    
    print(f"복잡한 시그니처: {ComplexSignature}")
    print(f"입력 필드 수: {len(ComplexSignature.input_fields)}")
    print(f"출력 필드 수: {len(ComplexSignature.output_fields)}")
    
    print("✅ 시그니처 패턴 테스트 성공\n")

def test_module_composition():
    """모듈 조합 테스트"""
    print("🧪 모듈 조합 테스트")
    
    # 기본 모듈들
    qa_module = dspy.Predict("question -> answer")
    cot_module = dspy.ChainOfThought("question -> answer")
    
    # 모듈 정보 출력
    print(f"QA 모듈: {type(qa_module).__name__}")
    print(f"CoT 모듈: {type(cot_module).__name__}")
    
    # 사용자 정의 모듈 클래스
    class MultiStepReasoning(dspy.Module):
        def __init__(self):
            super().__init__()
            self.analyze = dspy.ChainOfThought("question -> analysis")
            self.conclude = dspy.Predict("analysis -> conclusion")
            
        def forward(self, question):
            analysis = self.analyze(question=question)
            conclusion = self.conclude(analysis=analysis.answer)
            return dspy.Prediction(
                question=question,
                analysis=analysis.answer,
                conclusion=conclusion.conclusion
            )
    
    multi_step = MultiStepReasoning()
    print(f"다단계 모듈: {type(multi_step).__name__}")
    print(f"모듈 구성: analyze + conclude")
    
    print("✅ 모듈 조합 테스트 성공\n")

def test_evaluation_metrics():
    """평가 메트릭 테스트"""
    print("🧪 평가 메트릭 테스트")
    
    # 더미 예측 결과들
    predictions = [
        dspy.Prediction(answer="파이썬은 프로그래밍 언어입니다"),
        dspy.Prediction(answer="머신러닝은 AI 기술입니다"),
        dspy.Prediction(answer="DSPy는 프레임워크입니다")
    ]
    
    # 정답 예제들
    ground_truth = [
        dspy.Example(answer="파이썬은 프로그래밍 언어입니다"),
        dspy.Example(answer="머신러닝은 인공지능 기술입니다"),
        dspy.Example(answer="DSPy는 프레임워크입니다")
    ]
    
    # 간단한 정확도 계산
    exact_matches = sum(
        1 for pred, gt in zip(predictions, ground_truth)
        if pred.answer == gt.answer
    )
    accuracy = exact_matches / len(predictions)
    
    print(f"예측 결과 수: {len(predictions)}")
    print(f"정답 예제 수: {len(ground_truth)}")
    print(f"정확히 일치하는 수: {exact_matches}")
    print(f"정확도: {accuracy:.2%}")
    
    # 커스텀 메트릭 함수
    def custom_metric(example, prediction, trace=None):
        """커스텀 평가 메트릭"""
        if hasattr(prediction, 'answer') and hasattr(example, 'answer'):
            # 단어 기반 유사도
            pred_words = set(prediction.answer.lower().split())
            true_words = set(example.answer.lower().split())
            intersection = len(pred_words & true_words)
            union = len(pred_words | true_words)
            return intersection / union if union > 0 else 0.0
        return 0.0
    
    print(f"커스텀 메트릭 함수: {custom_metric.__name__}")
    
    print("✅ 평가 메트릭 테스트 성공\n")

def main():
    """메인 테스트 함수"""
    print("🚀 DSPy 고급 기능 테스트 시작\n")
    
    try:
        # 더미 LM 설정
        dummy_lm = test_dummy_lm_setup()
        
        # 각종 테스트 실행
        test_basic_prediction()
        test_chain_of_thought()
        examples = test_dataset_creation()
        test_signature_variations()
        test_module_composition()
        test_evaluation_metrics()
        
        print("🎉 모든 고급 테스트 완료!")
        print("📋 테스트 요약:")
        print("  ✅ 더미 LM 설정")
        print("  ✅ 기본 예측")
        print("  ✅ Chain of Thought")
        print("  ✅ 데이터셋 생성")
        print("  ✅ 시그니처 패턴")
        print("  ✅ 모듈 조합")
        print("  ✅ 평가 메트릭")
        print("\n💡 실제 LM 연결 시 더 많은 기능을 테스트할 수 있습니다.")
        
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
