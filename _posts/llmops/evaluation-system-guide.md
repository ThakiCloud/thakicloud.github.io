---
title: "EVAlchemy 평가 시스템 완전 가이드 - LLM 성능 평가의 모든 것"
excerpt: "언어 모델의 성능을 체계적으로 평가하기 위한 종합적인 EVAlchemy 시스템의 전체 동작 과정을 단계별로 상세히 설명합니다. 수학, 코딩, 주관식 문제 채점부터 분산 처리까지 완벽 가이드."
date: 2025-06-19
categories: 
  - llmops
  - dev
tags: 
  - LLM평가
  - 벤치마크
  - EVAlchemy
  - 모델평가
  - 채점시스템
  - 분산처리
  - AIME24
  - HumanEval
  - MATH500
author_profile: true
toc: true
toc_label: EVAlchemy 가이드
---

## 개요

EVAlchemy는 언어 모델의 성능을 체계적으로 평가하기 위한 종합적인 평가 시스템입니다. 이 문서는 평가 시스템의 전체적인 동작 과정을 단계별로 상세히 설명합니다.

## 전체 평가 플로우

```mermaid
graph TD
    A["🚀 시작: python -m eval.eval"] --> B["📝 명령어 파라미터 파싱"]
    B --> C{"🔧 설정 파일 존재?"}
    C -->|Yes| D["📄 YAML 설정 로드<br/>--tasks, --batch_size 등 덮어쓰기"]
    C -->|No| E["💾 평가 추적기 초기화<br/>DCEvaluationTracker"]
    D --> E
    
    E --> F["📋 태스크 목록 분류"]
    F --> G["📊 벤치마크 태스크<br/>(AIME24, HumanEval 등)"]
    F --> H["📚 사전훈련 태스크<br/>(MMLU, HellaSwag 등)"]
    
    G --> I["🎯 InstructTaskManager 초기화<br/>- 어노테이터 모델 설정<br/>- 최대 토큰 설정<br/>- 시드 설정"]
    H --> J["📖 PretrainTaskManager 초기화<br/>- lm-eval-harness 연동"]
    
    I --> K["🤖 모델 초기화<br/>initialize_model()"]
    J --> K
    K --> L{"🔍 모델 타입 확인"}
    L -->|curator| M["🌐 Curator API 모델<br/>- API 엔드포인트 설정<br/>- 인증 키 설정"]
    L -->|hf| N["🤗 HuggingFace 모델<br/>- 로컬 모델 로드<br/>- GPU 할당"]
    L -->|vllm| O["⚡ VLLM 모델<br/>- 분산 추론 설정<br/>- 배치 최적화"]
    
    M --> P["🔄 평가 루프 시작<br/>evaluate()"]
    N --> P
    O --> P
    
    P --> Q{"📊 벤치마크 태스크 존재?"}
    Q -->|Yes| R["🎯 벤치마크 태스크 처리"]
    Q -->|No| S["📚 사전훈련 태스크만 처리"]
    
    R --> T["🔁 태스크별 응답 생성<br/>(순차적)"]
    T --> U["📝 인스턴스 생성<br/>Instance 객체"]
    U --> V["💬 메시지 템플릿 적용<br/>- 시스템 명령어 추가<br/>- 채팅 템플릿 적용"]
    V --> W["🎲 생성 파라미터 설정<br/>- temperature<br/>- max_tokens<br/>- seed"]
    W --> X["🚀 모델 추론 실행<br/>model.generate_until()"]
    
    X --> Y{"🌐 분산 처리?"}
    Y -->|Yes| Z["⚖️ 랭크별 작업 분배<br/>결과 통합"]
    Y -->|No| AA["💻 단일 프로세스 처리"]
    Z --> BB["📤 응답 수집 완료"]
    AA --> BB
    
    BB --> CC["🔄 다음 태스크?"]
    CC -->|Yes| T
    CC -->|No| DD["⚡ 병렬 평가 시작<br/>ThreadPoolExecutor"]
    
    DD --> EE["📋 태스크별 평가<br/>evaluate_responses()"]
    EE --> FF{"🎯 태스크 타입?"}
    
    FF -->|수학| GG["🧮 수학 문제 채점<br/>- \\boxed{} 답안 추출<br/>- is_equiv() 동치성 검증<br/>- 반복 실험 통계"]
    FF -->|코딩| HH["💻 코딩 문제 채점<br/>- 코드 블록 추출<br/>- 테스트 케이스 실행<br/>- Pass@K 계산"]
    FF -->|주관식| II["🧠 모델 기반 채점<br/>- GPT-4 심사<br/>- 점수 패턴 추출<br/>- [[점수]] 형식"]
    FF -->|객관식| JJ["✅ 정확 일치 채점<br/>- 선택지 비교<br/>- 문자열 정규화"]
    
    GG --> KK["📊 통계 계산<br/>- 평균 정확도<br/>- 표준 오차<br/>- 신뢰 구간"]
    HH --> KK
    II --> KK
    JJ --> KK
    
    KK --> LL["🔄 모든 태스크 완료?"]
    LL -->|No| EE
    LL -->|Yes| MM["📊 결과 집계<br/>results['results']"]
    
    S --> NN["📚 lm-eval-harness 실행<br/>pretrain_evaluator.simple_evaluate()"]
    NN --> MM
    
    MM --> OO["📝 메타데이터 추가<br/>add_results_metadata()"]
    OO --> PP["💾 결과 저장<br/>handle_evaluation_output()"]
    
    PP --> QQ{"💾 저장 방식?"}
    QQ -->|파일| RR["📄 JSON 파일 저장<br/>- 타임스탬프 포함<br/>- 모델별 디렉토리"]
    QQ -->|데이터베이스| SS["🗄️ PostgreSQL 저장<br/>- 모델 정보<br/>- 평가 결과<br/>- 설정 정보"]
    QQ -->|둘 다| TT["📊 파일 + DB 저장"]
    
    RR --> UU["✅ 평가 완료<br/>결과 출력"]
    SS --> UU
    TT --> UU
    
    UU --> VV["🧹 정리 작업<br/>- 임시 파일 삭제<br/>- 리소스 해제<br/>- 분산 프로세스 종료"]
    VV --> WW["🏁 종료"]
```

## 시스템 아키텍처

### 핵심 구성 요소

1. **평가 엔트리포인트 (`eval.py`)**
   - 전체 평가 과정을 조율하는 메인 모듈
   - 명령줄 인터페이스 제공
   - 모델 초기화 및 결과 저장 관리

2. **태스크 매니저 (`task.py`)**
   - 다양한 벤치마크 태스크를 동적으로 로드 및 관리
   - 벤치마크 인스턴스 생성 및 실행 조율

3. **베이스 벤치마크 (`BaseBenchmark`)**
   - 모든 평가 태스크의 추상 기반 클래스
   - 일관된 평가 인터페이스 제공

4. **평가 추적기 (`eval_tracker.py`)**
   - 평가 결과 저장 및 데이터베이스 관리
   - 메타데이터 추적 및 결과 분석

## 평가 과정 상세 분석

### 1. 시스템 초기화 단계

#### 1.1 명령줄 파라미터 파싱
```bash
python -m eval.eval --model curator --tasks AIME24 --limit 1 \
--model_name "lm_studio/deepseek-r1-0528-qwen3-8b-mlx" \
--model_args "api_base=http://127.0.0.1:1234/v1,api_key=dummy" \
--apply_chat_template True --batch_size 1 \
--output_path logs/quickcheck.json
```

**주요 파라미터:**
- `--model`: 모델 타입 (curator, hf, vllm 등)
- `--tasks`: 평가할 태스크 목록 (AIME24, MATH500, HumanEval 등)
- `--model_name`: 모델 식별자
- `--model_args`: 모델별 추가 설정
- `--output_path`: 결과 저장 경로

#### 1.2 설정 파일 처리 (선택사항)
- YAML 설정 파일을 통해 배치 크기, 태스크, 어노테이터 모델 등을 일괄 설정
- 개별 파라미터보다 우선순위가 높음

#### 1.3 평가 추적기 초기화
- 파일 기반 또는 데이터베이스 기반 결과 저장 설정
- 메타데이터 추적을 위한 일반 설정 추적기 생성

### 2. 태스크 및 모델 초기화

#### 2.1 태스크 분류
평가 태스크는 두 가지 범주로 분류됩니다:

**a) 벤치마크 태스크 (Instruction-based)**
- AIME24, MATH500, HumanEval, MTBench 등
- 대화형 인터페이스 및 복잡한 채점 로직 포함
- 순차적 생성, 병렬 평가 방식 사용

**b) 사전 훈련 태스크 (Pretrain-based)**
- MMLU, HellaSwag 등 전통적인 NLP 벤치마크
- lm-evaluation-harness 프레임워크 활용

#### 2.2 태스크 매니저 초기화
```python
task_manager = InstructTaskManager(
    annotator_model=args.annotator_model,
    max_tokens=int(args.max_tokens),
    debug=args.debug,
    seed=args.seed,
    task_list=task_list,
    system_instruction=args.system_instruction,
)
```

#### 2.3 모델 초기화
- 모델 타입에 따른 적절한 백엔드 선택 (HuggingFace, VLLM, OpenAI API 등)
- 배치 크기, 생성 파라미터 설정
- 채팅 템플릿 적용 여부 확인

## 모델별 처리 과정

```mermaid
graph TD
    A["🤖 모델 초기화 요청<br/>initialize_model()"] --> B{"🔍 모델 타입 확인<br/>args.model"}
    
    B -->|curator| C["🌐 Curator API 모델"]
    B -->|hf| D["🤗 HuggingFace 모델"]
    B -->|vllm| E["⚡ VLLM 모델"]
    B -->|openai| F["🔵 OpenAI API 모델"]
    
    C --> G["📡 API 설정<br/>- model_name 설정<br/>- backend_params 구성<br/>- generation_params 설정"]
    G --> H["🔐 인증 정보<br/>- API 키 확인<br/>- 엔드포인트 설정"]
    H --> I["🚀 curator.LLM 인스턴스 생성"]
    
    D --> J["💾 모델 가중치 로드<br/>- pretrained 경로<br/>- device 할당<br/>- precision 설정"]
    J --> K["🎯 토크나이저 설정<br/>- 채팅 템플릿<br/>- 특수 토큰"]
    K --> L["🤗 HFLM 인스턴스 생성"]
    
    E --> M["⚙️ VLLM 엔진 설정<br/>- tensor_parallel_size<br/>- gpu_memory_utilization<br/>- max_model_len"]
    M --> N["📊 배치 설정<br/>- batch_size<br/>- max_num_seqs"]
    N --> O["⚡ VLLM 인스턴스 생성"]
    
    F --> P["🔑 OpenAI 설정<br/>- API 키 확인<br/>- 모델명 설정<br/>- 엔드포인트 URL"]
    P --> Q["📊 생성 파라미터<br/>- max_tokens<br/>- temperature<br/>- top_p"]
    Q --> R["🔵 OpenAI 클라이언트 생성"]
    
    I --> S["🔄 생성 메서드<br/>generate_until()"]
    L --> S
    O --> S
    R --> S
    
    S --> T["📝 인스턴스 처리<br/>List[Instance]"]
    T --> U["🔧 파라미터 정규화<br/>_normalize_model_args()"]
    
    U --> V{"🤖 모델별 파라미터 변환"}
    
    V -->|OpenAI| W["🔄 OpenAI 형식<br/>- max_tokens → max_new_tokens<br/>- seed → 단일값<br/>- 4o 모델 토큰 제한"]
    V -->|VLLM| X["⚡ VLLM 형식<br/>- max_gen_toks<br/>- sampling_params"]
    V -->|HuggingFace| Y["🤗 HF 형식<br/>- max_new_tokens<br/>- generation_config<br/>- seed 제거"]
    
    W --> Z["🌐 메시지 템플릿 적용<br/>apply_chat_template()"]
    X --> Z
    Y --> Z
    
    Z --> AA["📤 실제 추론 실행"]
    AA --> BB{"🌐 분산 환경?"}
    
    BB -->|Yes| CC["⚖️ 워크로드 분산<br/>- 랭크별 데이터 분할<br/>- islice() 사용"]
    BB -->|No| DD["💻 단일 프로세스"]
    
    CC --> EE["🚀 모델 추론<br/>model.generate_until()"]
    DD --> EE
    
    EE --> FF["📨 결과 수집"]
    FF --> GG{"🌐 분산 환경?"}
    
    GG -->|Yes| HH["🔄 결과 통합<br/>- all_gather_object()<br/>- 랭크별 결과 병합"]
    GG -->|No| II["📤 결과 반환"]
    
    HH --> II
    II --> JJ["✅ 생성 완료<br/>List[str]"]
```

### 3. 응답 생성 단계

#### 3.1 인스턴스 생성
각 평가 예제에 대해 `Instance` 객체를 생성합니다:

```python
instance = Instance(
    "generate_until",  # 생성 모드
    example,           # 원본 데이터
    (
        templated_messages,  # 템플릿 적용된 메시지
        {
            "do_sample": False,
            "max_new_tokens": max_new_tokens,
            "temperature": 0.7,
            "seed": seed,
        }
    ),
    idx  # 인덱스
)
```

#### 3.2 메시지 템플릿 적용
1. **시스템 명령어 추가** (선택사항)
2. **채팅 템플릿 적용**: 모델별 대화 형식으로 변환
3. **모델별 파라미터 정규화**: 시드, 토큰 제한 등 조정

#### 3.3 모델 추론 실행
- **분산 처리**: 여러 GPU에서 병렬 처리
- **배치 처리**: 효율적인 메모리 사용
- **결과 수집**: 모든 랭크에서 결과 통합

### 4. 태스크별 응답 생성 세부 과정

#### 4.1 AIME24 수학 문제 해결
**프롬프트 형식:**
```
Problem: {problem}
Mark your solution with \boxed
Answer:
```

**생성 설정:**
- 반복 횟수: 10회 (통계적 신뢰성 확보)
- 온도: 0.7 (적당한 다양성)
- 최대 토큰: 32,768

**특수 처리:**
- 반복별 시드 값 조정으로 다양한 응답 생성
- 메타데이터에 문제 ID, 정답, 참조 해법 저장

#### 4.2 코딩 벤치마크 (HumanEval)
**프롬프트 형식:**
```
Please provide a {language} solution to the following problem:
{prompt}
```

**생성 설정:**
- 언어별 처리 (Python, JavaScript, Shell 등)
- 코드 실행을 위한 특수 형식 적용

### 5. 평가 및 채점 단계

## 채점 시스템 상세 플로우

```mermaid
graph TD
    A["📋 평가 응답 수신<br/>evaluate_responses()"] --> B{"🎯 태스크 타입 분류"}
    
    B -->|수학 문제| C["🧮 수학 채점 시스템"]
    B -->|코딩 문제| D["💻 코딩 채점 시스템"]
    B -->|주관식| E["🧠 LLM 심사 시스템"]
    B -->|객관식| F["✅ 규칙 기반 채점"]
    
    C --> G["📝 답안 추출<br/>extract_answer()"]
    G --> H["🔍 \\boxed{답안} 패턴 검색<br/>last_boxed_only_string()"]
    H --> I["🧹 답안 정리<br/>remove_boxed()"]
    I --> J["🔢 동치성 검증<br/>is_equiv()"]
    
    J --> K["📊 문자열 정규화<br/>- 공백 제거<br/>- 특수문자 처리"]
    K --> L["🔢 수치 변환 시도<br/>- float 변환<br/>- 분수 처리"]
    L --> M["🧮 SymPy 심볼릭 비교<br/>- 대수식 단순화<br/>- 수학적 동치성"]
    M --> N{"✅ 정답 여부"}
    
    N -->|정답| O["1️⃣ 점수: 1"]
    N -->|오답| P["0️⃣ 점수: 0"]
    
    O --> Q["📊 반복 실험 통계<br/>- 10회 반복 평균<br/>- 표준편차 계산<br/>- 신뢰구간"]
    P --> Q
    
    D --> R["💻 코드 추출<br/>코드 블록 파싱"]
    R --> S["✅ 구문 검증<br/>- 파싱 가능 여부<br/>- 실행 가능성"]
    S --> T["🧪 테스트 실행<br/>- 입력 데이터 제공<br/>- 출력 결과 수집"]
    T --> U["📊 결과 비교<br/>- 예상 출력 vs 실제 출력<br/>- 정확 일치 검사"]
    U --> V{"✅ 테스트 통과?"}
    
    V -->|통과| W["1️⃣ 점수: 1"]
    V -->|실패| X["0️⃣ 점수: 0"]
    
    W --> Y["📈 Pass@K 계산<br/>K번 시도 중 성공률"]
    X --> Y
    
    E --> Z["🤔 심사 프롬프트 구성"]
    Z --> AA["📝 프롬프트 템플릿<br/>- 질문 포함<br/>- 모델 답안<br/>- 참조 답안<br/>- 채점 기준"]
    AA --> BB["🌐 심사 모델 호출<br/>GPT-4, Claude 등"]
    BB --> CC["🔍 점수 추출<br/>[[점수]] 패턴 검색"]
    CC --> DD{"📊 점수 범위?"}
    
    DD -->|1-10| EE["📊 정규화된 점수"]
    DD -->|패턴 없음| FF["❌ 오류 점수: -1"]
    
    EE --> GG["📈 평균 점수 계산"]
    FF --> GG
    
    F --> HH["📋 선택지 추출<br/>A, B, C, D 패턴"]
    HH --> II["🔤 정답과 비교<br/>문자열 정확 일치"]
    II --> JJ{"✅ 일치 여부"}
    
    JJ -->|일치| KK["1️⃣ 점수: 1"]
    JJ -->|불일치| LL["0️⃣ 점수: 0"]
    
    KK --> MM["📊 정확도 계산"]
    LL --> MM
    
    Q --> NN["📋 최종 결과 집계"]
    Y --> NN
    GG --> NN
    MM --> NN
    
    NN --> OO["📊 결과 구조<br/>{<br/>  'accuracy_avg': float,<br/>  'accuracy_std_err': float,<br/>  'num_total': int,<br/>  'solved_avg': float<br/>}"]
    
    OO --> PP["✅ 채점 완료"]
```

#### 5.1 답안 추출
각 태스크별로 특화된 답안 추출 로직을 사용합니다:

**수학 문제 (AIME24, MATH500):**
```python
def extract_answer(self, output: str) -> str:
    try:
        answer = remove_boxed(last_boxed_only_string(output))
        return answer
    except:
        return ""
```

**코딩 문제:**
- 코드 블록 추출
- 구문 분석 및 실행 가능성 검증

#### 5.2 채점 방식

**a) 정확 일치 채점 (Exact Match)**
- 수학 문제: `is_equiv()` 함수로 수학적 동치성 검증
- 다중 선택: 선택지 문자 일치 확인

**b) 실행 기반 채점**
- 코딩 문제: 테스트 케이스 실행 결과 비교
- Pass@K 메트릭 계산

**c) 모델 기반 채점**
- 주관식 답안: GPT-4 등 심사 모델 활용
- 구조화된 채점 기준 적용

#### 5.3 통계 분석
```python
# 반복 실험 결과 통계 계산
solved_avg = np.mean([result["num_solved"] for result in all_results])
accuracy_avg = np.mean([result["accuracy"] for result in all_results])
accuracy_std_err = np.std([result["accuracy"] for result in all_results]) / np.sqrt(n_repeat)
```

### 6. 결과 처리 및 저장

#### 6.1 결과 집계
- 태스크별 개별 결과 수집
- 전체 평가 결과 통합
- 메타데이터 추가 (모델 정보, 실행 환경 등)

#### 6.2 저장 방식
**파일 저장:**
```json
{
  "results": {
    "AIME24": {
      "accuracy_avg": 0.65,
      "accuracy_std_err": 0.05,
      "num_total": 30,
      "solved_avg": 19.5
    }
  },
  "model_info": {
    "model_name": "deepseek-r1",
    "model_args": "api_base=...",
    "timestamp": "2024-01-01T12:00:00"
  }
}
```

**데이터베이스 저장:**
- PostgreSQL 기반 구조화된 저장
- 모델, 데이터셋, 평가 설정, 결과 테이블 관리
- 중복 평가 방지 및 이력 추적

### 7. 고급 기능

#### 7.1 분산 평가
- 여러 GPU에서 병렬 처리
- 랭크별 작업 분배
- 결과 통합 및 동기화

#### 7.2 디버그 모드
- 제한된 예제로 빠른 테스트
- 상세한 로깅 및 오류 추적

#### 7.3 데이터베이스 통합
- 평가 결과 영구 저장
- 모델 성능 비교 및 분석
- 재평가 방지 시스템

## 채점 시스템 상세

### 1. 수학 문제 채점 (`is_equiv`)

**동치성 검증 과정:**
1. 문자열 정규화 (공백, 특수문자 제거)
2. 수치 변환 및 근사 비교
3. 대수적 표현 단순화
4. SymPy를 활용한 심볼릭 비교

**예시:**
```python
# 정답: "2/3"
# 모델 답안: "0.667" → 근사치 비교로 정답 처리
# 모델 답안: "4/6" → 기약분수 변환 후 정답 처리
```

### 2. 코딩 문제 채점

**단계별 채점:**
1. **구문 분석**: 코드 파싱 가능 여부 확인
2. **테스트 실행**: 제공된 테스트 케이스 실행
3. **결과 비교**: 예상 출력과 실제 출력 비교
4. **Pass@K 계산**: K번의 시도 중 성공 횟수

### 3. 주관식 답안 채점

**GPT-4 심사 시스템:**
```python
def run_judge_single(question, answer, judge, ref_answer):
    # 심사 프롬프트 구성
    user_prompt = judge.prompt_template.format(
        question=question,
        answer=answer,
        ref_answer=ref_answer
    )
    
    # 점수 추출 패턴
    rating_pattern = r"\[\[(\d+\.?\d*)\]\]"
    match = re.search(rating_pattern, judgment)
    
    return float(match.groups()[0]) if match else -1
```

## 성능 최적화

### 1. 병렬 처리 전략
- **생성 단계**: 순차적 (GPU 메모리 제약)
- **평가 단계**: 병렬 (CPU 집약적 작업)
- **ThreadPoolExecutor**: 최적 워커 수 자동 조정

### 2. 메모리 관리
- 배치 크기 동적 조정
- 대용량 결과 스트리밍 처리
- 임시 파일 자동 정리

### 3. 캐싱 전략
- 모델 응답 캐싱
- 중복 평가 방지
- 부분 결과 복구

## 오류 처리 및 복구

### 1. 견고한 오류 처리
- 개별 예제 실패 시 전체 평가 중단 방지
- 상세한 오류 로깅 및 추적
- 부분 결과 저장 및 복구

### 2. 재시도 메커니즘
- API 호출 실패 시 자동 재시도
- 지수 백오프 적용
- 레이트 리미팅 준수

## 확장성 고려사항

### 1. 새로운 벤치마크 추가
```python
class NewBenchmark(BaseBenchmark):
    def generate_responses(self, model: LM) -> Dict[str, Any]:
        # 응답 생성 로직 구현
        pass
    
    def evaluate_responses(self, results: Dict[str, Any]) -> Dict[str, float]:
        # 평가 로직 구현
        pass
```

### 2. 새로운 모델 백엔드 지원
- lm-eval-harness 호환 인터페이스 구현
- 모델별 특수 처리 로직 추가

## 실행 예시 및 결과 해석

### 1. 기본 실행 명령어
```bash
# 단일 태스크 평가
python -m eval.eval --model curator --tasks AIME24 --limit 1 \
--model_name "lm_studio/deepseek-r1-0528-qwen3-8b-mlx" \
--model_args "api_base=http://127.0.0.1:1234/v1,api_key=dummy" \
--apply_chat_template True --batch_size 1 \
--output_path logs/quickcheck.json

# 다중 태스크 평가
python -m eval.eval --model hf --tasks "AIME24,HumanEval,MATH500" \
--model_args "pretrained=microsoft/Phi-3-mini-4k-instruct" \
--batch_size 4 --output_path logs/multi_eval.json

# 설정 파일 기반 평가
python -m eval.eval --config configs/full_evaluation.yaml \
--model_name "custom-model" --output_path logs/config_eval.json
```

### 2. 결과 구조 해석
```json
{
  "results": {
    "AIME24": {
      "accuracy_avg": 0.65,           // 평균 정확도
      "accuracy_std_err": 0.05,       // 표준 오차
      "num_total": 30,                // 전체 문제 수
      "solved_avg": 19.5,             // 평균 해결 문제 수
      "num_repeat": 10,               // 반복 실험 횟수
      "run_stats": [...]              // 실험별 상세 결과
    }
  },
  "model_info": {
    "model_name": "deepseek-r1",
    "model_args": "...",
    "timestamp": "2024-01-01T12:00:00",
    "git_hash": "abc123...",
    "total_evaluation_time": 1234.56
  }
}
```

### 3. 성능 지표 설명

**정확도 관련:**
- `accuracy_avg`: 반복 실험의 평균 정확도
- `accuracy_std_err`: 표준 오차 (신뢰도 측정)
- `solved_avg`: 평균 해결 문제 수

**통계적 신뢰성:**
- 반복 실험 (n_repeat=10)을 통한 안정적인 성능 측정
- 표준 오차를 통한 결과의 신뢰 구간 제공

이 문서는 EVAlchemy 평가 시스템의 전체적인 동작 과정을 상세히 설명합니다. 각 단계는 신뢰성, 확장성, 성능을 고려하여 설계되었으며, 다양한 언어 모델과 평가 태스크를 지원합니다.


