---
title: "STOCHASTOK: LLM의 서브워드 이해 능력을 혁신하는 확률적 토크나이제이션"
excerpt: "옥스포드 대학교 연구진이 제안한 STOCHASTOK은 기존 토크나이저의 한계를 극복하고 LLM의 서브워드 레벨 이해 능력을 획기적으로 향상시키는 새로운 접근법입니다."
date: 2025-06-23
categories: 
  - research
  - llmops
tags: 
  - STOCHASTOK
  - tokenization
  - subword-understanding
  - language-models
  - oxford-research
author_profile: true
toc: true
toc_label: "STOCHASTOK 연구 분석"
---

옥스포드 대학교 연구진이 발표한 이 논문은 대규모 언어 모델(LLM)의 서브워드 레벨 이해 능력을 획기적으로 향상시키는 새로운 토크나이제이션 방법인 **STOCHASTOK**을 제안합니다.

## 해결하고자 하는 문제

### 기존 토크나이제이션의 한계

현재 LLM들은 다음과 같은 서브워드 레벨 작업에서 어려움을 겪고 있습니다:

- **문자 세기**: "strawberry에서 'r'이 몇 개인가?" 같은 간단한 질문
- **언어 유희**: 운율, 말장난, 어원 이해
- **수학적 처리**: 다자리 숫자, 화학 공식, 수학적 방정식
- **철자법**: 약어, 철자 오류 처리

이러한 문제의 근본 원인은 **토크나이제이션이 단어의 세밀한 구조를 가려서** 인간이 언어를 인식하는 방식과 다르게 처리하기 때문입니다.

### 기존 해결책의 한계

기존의 확률적 토크나이제이션 방법들:
- **BPE-dropout**: BPE 병합 단계를 건너뛰는 방식
- **문자 레벨 토크나이저**: 계산 비용이 크고 일관성 없는 개선

## STOCHASTOK 방법론

### 핵심 아이디어

STOCHASTOK은 기존 토크나이제이션 과정을 수정하는 대신, **토큰을 무작위로 더 작은 토큰 쌍으로 분할**하여 LLM이 토큰 내부 구조를 직접 '볼' 수 있게 합니다.

### 동작 원리

![image](/assets/images/posts/research/stochastok/figure_stochastok_resize.jpg)

STOCHASTOK은 **2단계 과정**으로 작동합니다:

#### 1단계: 기본 토크나이제이션
먼저 기존의 결정론적 토크나이저(예: BPE, Unigram)를 사용하여 텍스트를 토큰 시퀀스로 변환합니다.

#### 2단계: 확률적 토큰 분할 (Expand Steps)
생성된 토큰 시퀀스에 대해 `p × len(token_ids)` 번의 **expand 단계**를 반복 수행합니다:

1. **무작위 토큰 선택**: 현재 토큰 시퀀스에서 하나의 토큰을 무작위로 선택
2. **분할 가능성 확인**: 선택된 토큰이 어휘에서 더 작은 토큰 쌍으로 분할 가능한지 확인
3. **토큰 분할 실행**: 가능한 경우, 해당 토큰을 동등한 의미의 두 개 토큰으로 교체
4. **건너뛰기**: 분할 불가능한 경우(예: 단일 문자 토큰) 해당 단계 생략

```python
# STOCHASTOK 상세 의사코드
def stochastok_tokenize(text, base_tokenizer, p=0.1):
    # 1. 기본 토크나이저로 텍스트 토크나이즈
    token_ids = base_tokenizer.encode(text)
    
    # 2. p * len(token_ids) 번의 expand 단계 수행
    num_expansions = int(p * len(token_ids))
    
    for _ in range(num_expansions):
        # 무작위로 토큰 인덱스 선택
        random_idx = random.randint(0, len(token_ids) - 1)
        selected_token = token_ids[random_idx]
        
        # 선택된 토큰의 분할 가능한 쌍 찾기
        token_pairs = find_equivalent_pairs(selected_token, base_tokenizer.vocab)
        
        if token_pairs:
            # 무작위로 하나의 분할 방법 선택
            left_token, right_token = random.choice(token_pairs)
            # 원래 토큰을 두 개의 토큰으로 교체
            token_ids[random_idx:random_idx+1] = [left_token, right_token]
    
    return token_ids

def find_equivalent_pairs(token, vocab):
    """주어진 토큰과 동등한 의미의 토큰 쌍들을 찾는 함수"""
    token_text = vocab.decode([token])
    pairs = []
    
    # 어휘에서 가능한 모든 토큰 쌍 조합 확인
    for left_token in vocab:
        for right_token in vocab:
            if vocab.decode([left_token]) + vocab.decode([right_token]) == token_text:
                pairs.append((left_token, right_token))
    
    return pairs
```

### 구체적 예시

**원본 텍스트**: "The example works"

#### 기본 BPE 토크나이제이션:
```
["The", "example", "works"] → [464, 1672, 2618]
```

#### STOCHASTOK 적용 과정 (p=0.1):
```
초기: [464, 1672, 2618]  # "The", "example", "works"

Expand 1: 토큰 1672("example") 선택
         → [464, 1672, 2618] → [464, 1119, 1150, 2618]  # "The", "exam", "ple", "works"

결과: [464, 1119, 1150, 2618]
```

### 다양한 토크나이제이션 변형

동일한 텍스트가 훈련 과정에서 다음과 같이 다양하게 나타날 수 있습니다:

**"example" 단어의 가능한 토크나이제이션들:**
- `[example]` ← 원본
- `[exam][ple]` ← 한 번 분할
- `[ex][ample]` ← 다른 위치 분할
- `[ex][am][ple]` ← 두 번 분할
- `[e][x][am][ple]` ← 세 번 분할

이러한 **다양한 토크나이제이션 노출**을 통해 모델이:
- 단어의 내부 구조를 학습
- 문자 레벨 패턴을 인식
- 서브워드 간의 관계를 이해

### 핵심 차별점

| 특징 | 기존 토크나이저 | STOCHASTOK |
|------|----------------|------------|
| **일관성** | 동일 입력 → 동일 출력 | 동일 입력 → 다양한 출력 |
| **구조 노출** | 토큰 내부 구조 숨김 | 토큰 내부 구조 노출 |
| **학습 데이터** | 고정된 토큰 시퀀스 | 다양한 토큰 시퀀스 변형 |
| **서브워드 이해** | 제한적 | 향상됨 |

## 실험 결과

### 언어 게임 성능

**LangGame 태스크**에서 STOCHASTOK으로 사전 훈련된 모델이 거의 완벽한 정확도를 달성:
- 단어 길이 식별
- 부분 문자열 찾기
- 개별 문자 세기

### 수학 작업 성능

**다자리 덧셈 작업**에서 놀라운 성과:
- STOCHASTOK 모델: 빠른 그로킹(grokking)으로 거의 완벽한 정확도 달성
- 기존 방법들: 선형적 학습으로 느린 진전
- **일반화 능력**: 훈련 시 보지 못한 토크나이제이션 방식에도 적용 가능

### 기존 모델 개선

**Continued Pretraining (CPT)** 실험:
- 기존에 결정론적 토크나이제이션으로 훈련된 모델
- 2,000회 추가 훈련만으로 서브워드 이해 능력 획득
- 전체 재훈련 없이도 성능 향상 가능

## STOCHASTOK의 장점

### 실용적 이점

- **효율성**: 메모리와 계산 비용이 저렴
- **호환성**: 모든 기본 토크나이저와 호환 (BPE, Unigram, WordPiece 등)
- **단순성**: 토크나이제이션 후 가벼운 후처리 단계
- **어휘 보존**: 원래 토크나이저 어휘를 유지
- **강건성**: 하이퍼파라미터 선택에 민감하지 않음

### 기술적 우수성

- **일관성**: 동일한 프롬프트의 다양한 토크나이제이션에 대해 일관된 응답
- **표현 학습**: 대안 토크나이제이션들이 점진적으로 동일한 표현으로 수렴
- **구조 캡처**: 서브워드 레벨의 형태학적 구조를 효과적으로 학습

## 내부 메커니즘 분석

### 표현 학습 변화

**PCA 시각화 결과**:
- STOCHASTOK 훈련 모델: 동일 단어의 대안 토크나이제이션들이 유사한 임베딩 공간에 위치
- 기존 모델: 토크나이제이션별로 상이한 임베딩 분포

### 레이어별 수렴 패턴

각 트랜스포머 레이어를 거치면서 대안 토크나이제이션들이 점진적으로 동일한 표현으로 수렴하는 패턴을 보여줍니다.

## 향후 연구 방향

### 확장 가능성

- **더 큰 모델**: 더 강력한 모델에 적용 시 잠재적 영향
- **복잡한 태스크**: 코딩, 대수학, 과학적 추론 영역
- **다국어 지원**: 다양한 언어에 대한 적용

### 실용적 적용

- **기존 모델 개선**: 사전 훈련된 대형 모델의 후훈련 적용
- **특수 도메인**: 화학, 수학, 언어학 분야의 특화 모델
- **교육 도구**: 언어 학습 및 문자 이해 교육 도구

## 결론

STOCHASTOK은 최소한의 변경으로 LLM의 서브워드 이해 능력을 획기적으로 향상시키는 혁신적인 방법입니다. 특히 다음과 같은 측면에서 의미가 큽니다:

1. **실용성**: 기존 시스템에 쉽게 통합 가능
2. **효과성**: 언어 게임과 수학 작업에서 현저한 성능 개선
3. **효율성**: 계산 비용 증가 없이 성능 향상
4. **확장성**: 다양한 규모와 아키텍처에 적용 가능

이 연구는 토크나이제이션이 여전히 LLM 성능 향상의 핵심 요소임을 보여주며, 인간과 기계의 언어 인식 차이를 줄이는 중요한 진전을 나타냅니다.

**GitHub 코드**: [github.com/anyasims/stochastok](https://github.com/anyasims/stochastok) 