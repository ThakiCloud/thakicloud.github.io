#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Context Engineering 실습 스크립트
=================================

Andrej Karpathy가 정의한 "Context Engineering" 개념을 실습해보는 스크립트입니다.
- Atoms (단일 프롬프트) → Molecules (Few-shot) → Cells (메모리) → Organs (멀티에이전트) → Cognitive Tools

사용법:
    python scripts/test_context_engineering.py

요구사항:
    pip install matplotlib numpy tiktoken
"""

import os
import time
import json
from typing import Dict, List, Any, Tuple, Optional
try:
    import matplotlib.pyplot as plt
    import numpy as np
    MATPLOTLIB_AVAILABLE = True
except ImportError:
    MATPLOTLIB_AVAILABLE = False
    print("matplotlib을 설치하면 시각화가 가능합니다: pip install matplotlib numpy")

try:
    import tiktoken
    TIKTOKEN_AVAILABLE = True
except ImportError:
    TIKTOKEN_AVAILABLE = False
    print("tiktoken을 설치하면 더 정확한 토큰 계산이 가능합니다: pip install tiktoken")

class ContextEngineeringLab:
    """Context Engineering 실습을 위한 클래스"""
    
    def __init__(self):
        """초기화"""
        self.experiments = []
        self.token_counts = []
        self.quality_scores = []
        
        if TIKTOKEN_AVAILABLE:
            try:
                self.tokenizer = tiktoken.get_encoding("cl100k_base")
            except:
                self.tokenizer = None
        else:
            self.tokenizer = None
    
    def count_tokens(self, text: str) -> int:
        """토큰 수 계산"""
        if self.tokenizer:
            return len(self.tokenizer.encode(text))
        else:
            # 간단한 근사치 (실제 토큰과 차이 있음)
            return len(text.split()) * 1.3
    
    def simulate_llm_response(self, prompt: str, quality_multiplier: float = 1.0) -> Dict[str, Any]:
        """LLM 응답 시뮬레이션 (실제 API 호출 없이 분석만)"""
        tokens = self.count_tokens(prompt)
        
        # 품질 점수 계산 (프롬프트 복잡도 기반)
        base_quality = min(10, max(1, (tokens / 10) * quality_multiplier))
        
        return {
            "prompt": prompt,
            "tokens": int(tokens),
            "estimated_quality": round(base_quality, 1),
            "prompt_type": self._classify_prompt(prompt)
        }
    
    def _classify_prompt(self, prompt: str) -> str:
        """프롬프트 타입 분류"""
        if "예시:" in prompt or "Example:" in prompt:
            return "Few-shot (Molecules)"
        elif "기억해" in prompt or "remember" in prompt.lower():
            return "Memory (Cells)"
        elif "step" in prompt.lower() or "단계" in prompt:
            return "Multi-step (Organs)"
        elif len(prompt) > 200:
            return "Complex (Cognitive Tools)"
        else:
            return "Atomic (Atoms)"
    
    def experiment_1_atoms(self):
        """실험 1: Atoms - 기본 단일 프롬프트"""
        print("\n" + "="*60)
        print("실험 1: ATOMS - 단일 프롬프트의 한계")
        print("="*60)
        
        atomic_prompts = [
            "시를 써줘",
            "프로그래밍에 대한 시를 써줘",
            "프로그래밍에 대한 4줄 시를 써줘",
            "프로그래밍에 대한 4줄 하이쿠를 간단한 단어로 써줘"
        ]
        
        results = []
        for i, prompt in enumerate(atomic_prompts):
            result = self.simulate_llm_response(prompt)
            results.append(result)
            
            print(f"\n프롬프트 {i+1}: {prompt}")
            print(f"토큰 수: {result['tokens']}")
            print(f"예상 품질: {result['estimated_quality']}/10")
            print(f"타입: {result['prompt_type']}")
        
        self.experiments.extend(results)
        return results
    
    def experiment_2_molecules(self):
        """실험 2: Molecules - Few-shot 학습"""
        print("\n" + "="*60)
        print("실험 2: MOLECULES - Few-shot 학습의 힘")
        print("="*60)
        
        # Few-shot 예제
        few_shot_prompt = """감정을 색깔로 표현해줘. 다음과 같은 형식으로:

예시:
행복 → 노란색 (따뜻하고 밝은 에너지)
슬픔 → 파란색 (차갑고 깊은 바다 같은 느낌)
분노 → 빨간색 (뜨겁고 강렬한 불꽃)

이제 다음 감정들을 표현해줘:
희망, 질투, 평온"""
        
        result = self.simulate_llm_response(few_shot_prompt, quality_multiplier=1.5)
        
        print(f"\nFew-shot 프롬프트 토큰 수: {result['tokens']}")
        print(f"예상 품질: {result['estimated_quality']}/10")
        print(f"타입: {result['prompt_type']}")
        
        self.experiments.append(result)
        return result
    
    def experiment_3_cells(self):
        """실험 3: Cells - 메모리와 상태 관리"""
        print("\n" + "="*60)
        print("실험 3: CELLS - 메모리와 상태 관리")
        print("="*60)
        
        memory_prompt = """기억해: 나는 AI 개발자이고, 한국어를 선호하며, 실용적인 예제를 좋아한다.

이 정보를 바탕으로 Context Engineering을 설명해줘. 내 선호도에 맞춰서."""
        
        result = self.simulate_llm_response(memory_prompt, quality_multiplier=1.3)
        
        print(f"\n메모리 기반 프롬프트 토큰 수: {result['tokens']}")
        print(f"예상 품질: {result['estimated_quality']}/10")
        print(f"타입: {result['prompt_type']}")
        
        self.experiments.append(result)
        return result
    
    def experiment_4_organs(self):
        """실험 4: Organs - 멀티스텝 워크플로우"""
        print("\n" + "="*60)
        print("실험 4: ORGANS - 멀티스텝 워크플로우")
        print("="*60)
        
        multi_step_prompt = """다음 단계별로 AI 프로젝트를 분석해줘:

1단계: 문제 정의
2단계: 데이터 요구사항 분석  
3단계: 모델 선택 기준
4단계: 평가 메트릭 설계
5단계: 배포 전략

주제: "고객 리뷰 감정 분석 시스템"

각 단계마다 구체적인 예시와 고려사항을 포함해줘."""
        
        result = self.simulate_llm_response(multi_step_prompt, quality_multiplier=1.8)
        
        print(f"\n멀티스텝 프롬프트 토큰 수: {result['tokens']}")
        print(f"예상 품질: {result['estimated_quality']}/10")
        print(f"타입: {result['prompt_type']}")
        
        self.experiments.append(result)
        return result
    
    def experiment_5_cognitive_tools(self):
        """실험 5: Cognitive Tools - 인지 도구 활용"""
        print("\n" + "="*60)
        print("실험 5: COGNITIVE TOOLS - IBM 연구 기반 인지 도구")
        print("="*60)
        
        cognitive_tool_prompt = """## 인지 도구: 문제 분해 및 추론 도구

### 도구 1: 문제 이해
- 핵심 개념 식별
- 관련 정보 추출  
- 중요한 속성과 기법 강조

### 도구 2: 연관 지식 회상
- 관련 이론과 사례 찾기
- 유사한 문제 패턴 인식
- 적용 가능한 방법론 탐색

### 도구 3: 해답 검증
- 논리적 일관성 확인
- 반례 가능성 검토
- 개선 방안 모색

### 도구 4: 역추적 분석
- 해결 과정 재검토
- 대안적 접근법 탐색
- 학습 포인트 도출

이 인지 도구들을 사용해서 다음 문제를 해결해줘:

"LLM의 컨텍스트 윈도우가 제한적일 때, 긴 문서를 효과적으로 처리하는 방법은 무엇인가?"

각 도구를 순서대로 적용하면서 사고 과정을 보여줘."""
        
        result = self.simulate_llm_response(cognitive_tool_prompt, quality_multiplier=2.2)
        
        print(f"\n인지 도구 프롬프트 토큰 수: {result['tokens']}")
        print(f"예상 품질: {result['estimated_quality']}/10")
        print(f"타입: {result['prompt_type']}")
        
        self.experiments.append(result)
        return result
    
    def analyze_roi_curve(self):
        """토큰 대비 품질 ROI 곡선 분석"""
        print("\n" + "="*60)
        print("토큰 대비 품질 ROI 곡선 분석")
        print("="*60)
        
        tokens = [exp['tokens'] for exp in self.experiments]
        qualities = [exp['estimated_quality'] for exp in self.experiments]
        types = [exp['prompt_type'] for exp in self.experiments]
        
        # ROI 계산 (품질/토큰)
        rois = [q/t for q, t in zip(qualities, tokens)]
        
        print(f"\n{'타입':<20} {'토큰':<8} {'품질':<8} {'ROI':<8}")
        print("-" * 50)
        for i, exp in enumerate(self.experiments):
            print(f"{types[i]:<20} {tokens[i]:<8} {qualities[i]:<8} {rois[i]:.3f}")
        
        # 시각화 (matplotlib 사용 가능한 경우에만)
        if MATPLOTLIB_AVAILABLE:
            plt.figure(figsize=(12, 5))
            
            # 서브플롯 1: 토큰 vs 품질
            plt.subplot(1, 2, 1)
            colors = ['red', 'orange', 'yellow', 'green', 'blue']
            for i, (t, q, typ) in enumerate(zip(tokens, qualities, types)):
                plt.scatter(t, q, c=colors[i % len(colors)], s=100, alpha=0.7, label=typ)
            plt.xlabel('토큰 수')
            plt.ylabel('예상 품질')
            plt.title('토큰 수 vs 품질')
            plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
            plt.grid(True, alpha=0.3)
            
            # 서브플롯 2: ROI 분석
            plt.subplot(1, 2, 2)
            bars = plt.bar(range(len(rois)), rois, color=colors[:len(rois)], alpha=0.7)
            plt.xlabel('프롬프트 타입')
            plt.ylabel('ROI (품질/토큰)')
            plt.title('프롬프트 타입별 ROI')
            plt.xticks(range(len(types)), [t.split()[0] for t in types], rotation=45)
            plt.grid(True, alpha=0.3)
            
            plt.tight_layout()
            plt.savefig('context_engineering_analysis.png', dpi=300, bbox_inches='tight')
            print(f"\n분석 결과가 'context_engineering_analysis.png'로 저장되었습니다.")
        else:
            print("\n그래프 시각화를 위해서는 'pip install matplotlib numpy'를 실행해주세요.")
        
        if MATPLOTLIB_AVAILABLE:
            best_roi_index = np.argmax(rois)
        else:
            best_roi_index = rois.index(max(rois))
            
        return {
            'tokens': tokens,
            'qualities': qualities,
            'rois': rois,
            'best_roi_index': best_roi_index
        }
    
    def run_all_experiments(self):
        """모든 실험 실행"""
        print("Context Engineering 실습 시작!")
        print("Andrej Karpathy 정의: '컨텍스트 윈도우를 다음 단계에 필요한 올바른 정보로 채우는 섬세한 예술과 과학'")
        
        # 각 실험 실행
        self.experiment_1_atoms()
        self.experiment_2_molecules()
        self.experiment_3_cells()
        self.experiment_4_organs()
        self.experiment_5_cognitive_tools()
        
        # ROI 분석
        analysis = self.analyze_roi_curve()
        
        print("\n" + "="*60)
        print("실습 완료 및 결론")
        print("="*60)
        print(f"최고 ROI: {max(analysis['rois']):.3f} ({self.experiments[analysis['best_roi_index']]['prompt_type']})")
        print("\n핵심 인사이트:")
        print("1. 단순 프롬프트(Atoms)는 토큰 효율적이지만 품질 한계")
        print("2. Few-shot(Molecules)는 품질 향상 대비 적당한 토큰 증가") 
        print("3. 인지 도구(Cognitive Tools)는 복잡하지만 최고 품질 달성")
        print("4. 적절한 복잡도 선택이 ROI 최적화의 핵심")

def main():
    """메인 함수"""
    lab = ContextEngineeringLab()
    lab.run_all_experiments()

if __name__ == "__main__":
    main() 