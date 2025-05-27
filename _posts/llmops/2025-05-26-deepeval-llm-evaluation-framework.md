---
title: "DeepEval 소개"
excerpt: "DeepEval: LLM 시스템 평가를 위한 프레임워크 분석"
date: 2025-05-26
categories:
  - llmops
tags:
  - MLOps
  - LLMOps 
  - DeepEval
  - Evaluation
  - Thaki Cloud
author_profile: true # 회사 계정 또는 HR 담당자로 설정 가능
---

대규모 언어 모델(LLM)의 발전과 함께, LLM 기반 애플리케이션의 신뢰성과 성능을 체계적으로 평가하는 것은 모든 개발 및 연구 조직의 핵심 과제가 되었습니다. **DeepEval** ([GitHub 저장소](https://github.com/confident-ai/deepeval))은 이러한 LLM 시스템의 테스트 및 평가 과정을 혁신적으로 간소화하도록 설계된 강력한 오픈소스 프레임워크입니다. 마치 Pytest를 사용하는 것처럼 익숙한 개발 경험을 제공하면서도, LLM 출력 평가에 고도로 특화된 기능을 통해 RAG(Retrieval Augmented Generation) 파이프라인, 정교한 챗봇, 자율 에이전트 등 모든 종류의 LLM 활용 애플리케이션을 효과적으로 검증할 수 있도록 지원합니다.

본 글에서는 DeepEval의 핵심 기능, 주요 메트릭, 통합 생태계 및 강력한 벤치마킹 역량을 상세히 살펴보겠습니다.

## DeepEval: LLM 평가의 새로운 표준

DeepEval은 LLM 애플리케이션 개발 라이프사이클 전반에 걸쳐 평가 프로세스를 매끄럽게 통합하고자 하는 개발자 및 연구자들을 위한 포괄적인 솔루션을 제공합니다.

### 1. 핵심 특징 및 지원 메트릭

DeepEval은 단순한 단위 테스트를 넘어 LLM 시스템의 복잡성을 이해하고 평가할 수 있는 다양한 기능을 제공합니다.

* **엔드 투 엔드 및 컴포넌트 단위 평가**: 전체 LLM 애플리케이션의 최종 응답 품질뿐만 아니라, 내부 컴포넌트(예: 리트리버, LLM 호출 단계)의 성능까지 세밀하게 평가할 수 있습니다.
* **즉시 사용 가능한 풍부한 메트릭**:
    * **G-Eval**: LLM을 활용하여 LLM 출력을 평가하는 유연한 메트릭입니다.
    * **Hallucination (환각)**: 생성된 응답이 사실에 기반하는지, 혹은 잘못된 정보를 포함하는지 평가합니다.
    * **Answer Relevancy (답변 관련성)**: 주어진 입력에 대해 LLM의 답변이 얼마나 관련성이 높은지 측정합니다.
    * **RAGAS 메트릭**: RAG 시스템 평가에 특화된 Faithfulness, Context Precision/Recall 등을 지원합니다.
    * **Task Completion (과업 완료율)**: LLM이 특정 과업을 성공적으로 완수했는지 여부를 평가합니다.
* **강력한 레드팀(Red Teaming) 기능**: 약 40개 이상의 사전 정의된 레드팀 공격 시나리오(독성, 편향, SQL 인젝션 등)를 손쉽게 실행하여 모델의 안전성과 견고성을 테스트합니다.
* **커스텀 메트릭 정의 및 통합**: 사용자는 자체적인 평가 기준에 맞는 커스텀 메트릭을 정의하고, 이를 DeepEval 생태계에 원활하게 통합하여 활용할 수 있습니다.
* **Confident AI 플랫폼 연동**: 테스트 결과를 Confident AI 클라우드 플랫폼에 저장하고 공유함으로써, 팀 내 협업을 강화하고 평가 이력을 체계적으로 관리할 수 있습니다.

### 2. 주요 통합 기능

DeepEval은 기존 MLOps 및 개발 워크플로우에 쉽게 통합될 수 있도록 설계되었습니다.

* **주요 LLM 프레임워크 지원**: LangChain, LlamaIndex, Hugging Face 등 널리 사용되는 라이브러리와의 연동을 기본적으로 지원합니다.
* **CI/CD 파이프라인 통합**: 자동화된 테스트 및 평가를 CI/CD 파이프라인에 통합하여 지속적인 품질 관리를 실현합니다.
* **실시간 평가**: Hugging Face 트랜스포머 모델의 파인튜닝 과정 중에도 실시간으로 모델 성능을 평가하여 효율적인 모델 개선을 지원합니다.

## DeepEval 활용 방법론

### 1. 빠른 시작 (QuickStart)

DeepEval의 도입은 매우 간결합니다.

* **설치**:
    ```bash
    pip install -U deepeval
    ```
* **로그인 (선택 사항)**: Confident AI 플랫폼 연동을 위해 `deepeval login` 명령어로 계정을 생성하고 API 키를 CLI에 입력합니다.
* **테스트 파일 작성**:
    ```bash
    touch test_my_llm_app.py
    ```
    해당 파일 내에서 `LLMTestCase`를 정의하고, `GEval`과 같은 적절한 메트릭을 지정합니다.
* **실행**:
    ```bash
    deepeval test run test_my_llm_app.py
    ```
    테스트 통과 시 CLI에 ✅ 아이콘이 표시됩니다.

### 2. 테스트 케이스 구성

효과적인 평가를 위해서는 잘 구성된 테스트 케이스가 필수적입니다. `LLMTestCase`는 다음 요소들로 구성됩니다.

* `input`: LLM 애플리케이션에 전달될 사용자 입력 예시입니다.
* `actual_output`: LLM 애플리케이션으로부터 받은 실제 출력값입니다.
* `expected_output` (선택 사항): 기대하는 이상적인 응답이나 참조 답변입니다.
* `retrieval_context` (선택 사항): RAG 시스템의 경우, 검색된 컨텍스트 문서를 전달하여 평가에 활용합니다.

`assert_test()` 메서드를 사용하여 정의된 메트릭이 설정한 임계값(threshold)을 만족하는지 검증합니다.

### 3. 컴포넌트-레벨 평가 심층 분석

`@observe` 데코레이터를 활용하면 LLM 호출, 리트리버 작동, 외부 도구 사용과 같은 애플리케이션 내부의 개별 단계를 추적하고 평가할 수 있습니다. `update_current_span()` 함수를 통해 각 단계의 입력과 출력을 기록하고, 여기에 특정 메트릭을 적용하여 시스템의 병목 지점이나 개선 영역을 식별할 수 있습니다.

### 4. 스탠드얼론 메트릭 사용

개별 메트릭은 독립적으로도 활용 가능합니다. 메트릭 인스턴스를 생성한 후, `metric.measure(test_case)`를 호출하면 해당 테스트 케이스에 대한 점수와 상세 설명을 간편하게 얻을 수 있어, 특정 기준에 대한 빠른 검증이 가능합니다.

### 5. 대규모 데이터셋 평가

다수의 테스트 케이스를 `EvaluationDataset`으로 묶어 한 번에 실행하거나, Pytest의 파라미터라이즈 기능을 활용하여 여러 시나리오를 효율적으로 테스트할 수 있습니다. `evaluate()` 함수를 통해 병렬 및 배치 평가를 수행하여 대규모 데이터셋에 대한 평가 시간을 단축할 수 있습니다.

## LLM 벤치마킹: DeepEval의 전문가적 접근

표준화된 벤치마크를 통한 LLM 성능 평가는 모델의 객관적인 역량(추론, 이해, 지식 등)을 정량화하는 데 중요합니다.

### 1. DeepEval 제공 주요 벤치마크

DeepEval은 다양한 공개 벤치마크를 지원하며, 모든 벤치마크 구현은 원 논문의 프로토콜을 100% 준수하여 신뢰성 높은 결과를 제공합니다.

| 범주           | 벤치마크        | 특징                                     |
| -------------- | --------------- | ---------------------------------------- |
| 다중과제       | MMLU            | 57개 과목, 대학원 수준까지 포괄          |
| 상식·추론      | HellaSwag       | 극단적 문맥에서의 문장 완성 및 추론 능력 |
| 상식·추론      | BIG-Bench Hard  | 복잡하고 긴 문맥에서의 추론 능력         |
| 수치·추론      | DROP            | 복합적인 독해 및 계산 능력               |
| 신뢰성         | TruthfulQA      | 허위 정보 및 편향 탐지 능력              |
| 코드 생성      | HumanEval       | 함수 구현 및 테스트 케이스 통과율        |
| 수학 문제 해결 | GSM8K           | 초등 교육 수준의 단계별 계산 문제        |

### 2. LLM 벤치마킹 절차

DeepEval을 사용한 벤치마킹은 몇 줄의 코드로 간단하게 수행할 수 있습니다.

1.  **모델 래퍼 작성**: `DeepEvalBaseLLM`을 상속받아 사용하고자 하는 LLM(사내 모델, 오픈소스 모델, API 기반 모델 등)을 위한 래퍼 클래스를 구현합니다.
    ```python
    from deepeval.models.base_model import DeepEvalBaseLLM

    class MyCustomLLM(DeepEvalBaseLLM):
        def load_model(self):
            # 모델 로딩 로직
            return "your_model_instance"

        def generate(self, prompt: str) -> str:
            # 단일 프롬프트에 대한 생성 로직
            # return self.model.predict(prompt)
            pass # 실제 구현 필요

        async def a_generate(self, prompt: str) -> str: # 비동기 지원 시
            # return await self.model.apredict(prompt)
            pass # 실제 구현 필요

        def batch_generate(self, prompts: list[str]) -> list[str]: # 선택 사항
            # 배치 프롬프트에 대한 생성 로직 (효율성 증대)
            # return self.model.predict_batch(prompts)
            pass # 실제 구현 필요
        
        async def a_batch_generate(self, prompts: list[str]) -> list[str]: # 선택 사항, 비동기 지원 시
            # return await self.model.apredict_batch(prompts)
            pass # 실제 구현 필요

        def get_model_name(self):
            return "My Custom LLM"
    ```

2.  **벤치마크 인스턴스화**: 평가하고자 하는 벤치마크를 선택하고 인스턴스를 생성합니다. 특정 태스크만 선택하여 평가할 수도 있습니다.
    ```python
    from deepeval.benchmarks import MMLU
    from deepeval.benchmarks.mmlu.mmlu_metric import MMLUTask # 예시, 실제 사용 시 올바른 import 경로 확인

    # 전체 MMLU 벤치마크 실행
    benchmark = MMLU()

    # 특정 과목(예: 천문학)만 평가
    # benchmark = MMLU(tasks=[MMLUTask.ASTRONOMY]) # MMLUTask enum 값은 실제 라이브러리 참조
    ```

3.  **평가 실행**: 준비된 모델 래퍼와 벤치마크 인스턴스를 사용하여 평가를 실행합니다.
    ```python
    my_model_instance = MyCustomLLM()
    # results = benchmark.evaluate(model=my_model_instance, batch_size=8) # 배치 생성 지원 시
    # print(benchmark.overall_score)
    # print(benchmark.task_scores) # DataFrame 형태
    # print(benchmark.predictions) # DataFrame 형태
    ```
    *실제 `evaluate` 실행 및 결과 출력은 모델 래퍼가 완전하게 구현된 후 가능합니다.*

### 3. 벤치마크 구성 옵션

다양한 파라미터를 통해 벤치마크 실행 방식을 세밀하게 조정할 수 있습니다.

* `tasks`: 평가할 세부 과목이나 태스크를 지정합니다 (예: `[MMLUTask.ASTRONOMY]`).
* `n_shots`: Few-shot 프롬프팅에 사용될 예시의 개수를 설정합니다 (예: `HellaSwag(n_shots=3)`).
* `enable_cot`: Chain-of-Thought 프롬프팅을 활성화하여 모델의 추론 과정을 유도합니다 (예: `BigBenchHard(enable_cot=True)`).
* `batch_size`: 배치 생성을 사용하여 평가 속도를 높입니다. 모델 래퍼에 `batch_generate` 또는 `a_batch_generate` 메서드가 구현되어 있어야 합니다. (단, HumanEval, GSM8K 등 일부 벤치마크는 배치 처리를 지원하지 않을 수 있습니다.)

### 4. 출력 형식 문제 해결 및 결과 활용

다지선다형(MCQ) 벤치마크는 종종 단일 문자(예: A, B, C, D) 형태의 답변을 요구합니다. 모델이 불완전하거나 형식이 다른 문자열을 반환할 경우, 점수가 비정상적으로 낮게 나올 수 있습니다. 이를 해결하기 위해 DeepEval 모델 래퍼 내에서 후처리 로직을 추가하거나, 프롬프트 엔지니어링을 통해 응답 형식을 강제하는 것이 좋습니다.

평가 결과는 다음과 같이 활용됩니다:
* `overall_score`: 벤치마크 전체에 대한 종합 성능 지표입니다.
* `task_scores`: (DataFrame 형태) 각 세부 과제별 정확도 및 성능 지표를 제공합니다.
* `predictions`: (DataFrame 형태) 개별 입력, 모델의 예측, 정답 여부 등 상세 분석 자료를 제공합니다.

## Confident AI 플랫폼과의 시너지

DeepEval CLI를 통해 로컬에서 실행된 테스트 및 벤치마크 결과는 Confident AI 플랫폼과 연동될 경우 더욱 강력한 분석 및 관리 기능을 제공합니다. 웹 기반 대시보드를 통해 데이터셋 관리, 여러 실험 결과 비교, 시각화된 리포트 공유, 그리고 실 서비스 환경에서의 모델 성능 모니터링까지 통합적으로 처리할 수 있습니다. 테스트 실행 후 CLI에 표시되는 URL을 통해 손쉽게 웹 대시보드에서 결과를 확인할 수 있습니다.

## 커뮤니티 기여와 로드맵

DeepEval은 활발한 오픈소스 커뮤니티를 기반으로 성장하고 있습니다. 프로젝트에 대한 자세한 내용과 기여 방법은 공식 [DeepEval GitHub 저장소](https://github.com/confident-ai/deepeval)의 `CONTRIBUTING.md` 파일에 상세히 안내되어 있으며, 새로운 아이디어 제안 및 기능 개발 참여를 환영합니다. 향후 로드맵에는 Guardrails 기능 강화, 추가적인 고급 메트릭 지원, 자동 데이터셋 생성 도구 등 LLM 평가 생태계를 더욱 풍부하게 할 기능들이 계획되어 있습니다.

## 결론

DeepEval은 LLM 기반 시스템의 개발 및 운영에 있어 필수적인 '신뢰성'과 '성능'을 체계적으로 확보할 수 있도록 지원하는 포괄적이고 유연한 평가 프레임워크입니다. 전문가들은 DeepEval을 통해 몇 줄의 코드만으로도 복잡한 LLM 애플리케이션을 심층적으로 분석하고, 다양한 공개 벤치마크를 활용하여 모델 성능을 객관적으로 측정할 수 있습니다. 사내 모델 개발, 오픈소스 모델 검증, API 기반 서비스 평가 등 어떠한 LLM 활용 시나리오에서도 DeepEval은 일관되고 신뢰할 수 있는 평가 방법론을 제시하며, 더 나아가 Confident AI 플랫폼과의 연동을 통해 MLOps 파이프라인의 효율성을 극대화할 것입니다.
