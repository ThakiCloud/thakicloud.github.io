---
title: "로컬 LM Studio 모델을 API처럼 벤치마킹하기: Evalchemy + LiteLLM 완벽 가이드"
excerpt: "LM Studio와 Evalchemy를 연동하여 로컬 언어 모델을 OpenAI API처럼 간편하게 평가하는 방법"
date: 2025-06-14
categories: 
  - llmops
  - dev
tags: 
  - lm-studio
  - evalchemy
  - litellm
  - benchmarking
  - local-llm
  - model-evaluation
author_profile: true
toc: true
toc_label: "목차"
---

## 소개

로컬에서 직접 돌리는 언어 모델의 성능, 궁금하지 않으셨나요? 보통은 HuggingFace나 vLLM 라이브러리를 설치하고 코드를 짜야 해서 번거로웠습니다. 하지만 **Evalchemy**와 **LM Studio**를 연동하면, 마치 OpenAI나 Anthropic의 API를 쓰듯 간단하게 로컬 모델의 벤치마크를 실행할 수 있습니다.

이 글에서는 LM Studio로 모델을 실행한 뒤, Evalchemy의 `Curator` 모델 어댑터와 `LM-Eval-Harness`를 통해 REST API로 모델을 호출하고 평가하는 전 과정을 정리합니다. CLI 플래그에서 `--model curator` 또는 `--model openai`만 바꿔주면 GPT-4o, Claude 3, Gemini는 물론, 자체 vLLM 서버나 100종 이상의 API 모델을 설치 없이 동일한 방식으로 평가할 수 있다는 것이 핵심입니다.

### TL;DR: 핵심 포인트

약간의 설정만 손보면 됩니다. 명령어는 거의 표준과 같지만, `model_name`에 LM Studio가 지정한 **API Identifier (밑줄 `_` 사용)**를 정확히 입력해야 합니다. 또한, `lm_studio/` 접두사를 인식하는 LiteLLM v1.72 이상 버전이 필요하며, API Base URL과 키 설정을 올바르게 맞춰주어야 합니다.

## 설정: 벤치마크 실행 전 필수 확인 사항

성공적인 벤치마크를 위해 몇 가지 핵심 설정을 확인해야 합니다. 특히 모델 ID 형식과 LiteLLM 버전이 중요합니다.

### 올바른 모델 ID 사용: 슬래시(`/`) 대신 밑줄(`_`)

LM Studio의 OpenAI 호환 API는 `GET /v1/models` 엔드포인트에서 모델 목록을 제공합니다. 이때 반환되는 **"API identifier"**는 모델 폴더 이름을 밑줄(`_`)로 연결한 형태(예: `deepseek-ai_deepseek-r1-0528-qwen3-8b`)입니다.

LiteLLM 공식 문서 역시 `lm_studio/<identifier>` 형식을 그대로 사용하라고 명시합니다. 만약 Hugging Face에서처럼 `organization/model-name` 형태로 입력하면 "모델을 찾을 수 없다"는 오류가 발생합니다.

### LiteLLM 버전 점검 (v1.72 이상)

`lm_studio/` Provider는 LiteLLM v1.72 (2025년 봄 릴리스)부터 지원되기 시작했습니다. 터미널에서 버전을 확인하고 필요 시 업그레이드하세요.

```bash
# 버전 확인
pip show litellm

# v1.72 이상으로 업그레이드
pip install -U "litellm>=1.72"

pip install --upgrade bespokelabs-curator litellm

git clone https://github.com/mlfoundations/evalchemy.git

cd evalchemy

# eval/chat_benchmarks/curator_lm.py  
- response = self.llm(payload)["response"]
+ response_obj = self.llm(payload)       # CuratorResponse
#+ response = response_obj.response       # 실제 텍스트
#+ response  = response_obj.to_list()[0]["response"]
+ response  = response_obj.dataset[0]["response"]

or

sed -i '' 's/\["response"\]/.to_list()[0]["response"]/' \
  eval/chat_benchmarks/curator_lm.py
```

### 서버 및 API 키 설정

LM Studio 서버 설정에 따라 API 키와 Base URL을 맞춰야 합니다.

| 시나리오 | 해결 방법 |
|:---------|:----------|
| **API 키 없이 서버 실행**<br/>`lms server start --port 1234` | 환경 변수 `OPENAI_API_KEY`를 비워둡니다. (`unset OPENAI_API_KEY`) |
| **API 키 설정 후 서버 실행**<br/>`lms server start --port 1234 --api-key my-secret-key` | 설정한 키를 `LM_STUDIO_API_KEY` 또는 `OPENAI_API_KEY` 환경 변수로 내보냅니다. (`export LM_STUDIO_API_KEY="my-secret-key"`) |

> **중요: Base URL에 `/v1` 포함하기**
> 
> 모든 OpenAI 호환 클라이언트는 Base URL 끝에 반드시 `/v1`을 포함해야 합니다 (예: `http://127.0.0.1:1234/v1`). 이 부분을 빠뜨리면 `404 Not Found` 오류가 발생합니다.

## 실행: 예시 명령어와 테스트

모든 설정이 끝났다면 이제 벤치마크를 실행할 차례입니다.

### 최종 Evalchemy 실행 명령어

아래는 AIME24와 MATH500 태스크에 대해 로컬 `deepseek-qwen3-8b` 모델을 평가하는 명령어 예시입니다.

```bash
# 키가 없는 경우 환경 변수 비우기
unset OPENAI_API_KEY

# Evalchemy 실행
python -m eval.eval \
  --model curator \
  --tasks AIME24,MATH500 \
  --model_name "lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://127.0.0.1:1234/v1" \
  --apply_chat_template True \
  --output_path logs/deepseek-qwen3-8b_lmstudio.json

# 1) litellm 최신 (≥ 1.72) 확인
pip install -U "litellm>=1.72"
 
# 2) LM Studio 엔드포인트·키를 환경변수로 전달
export LM_STUDIO_API_BASE="http://127.0.0.1:1234/v1"   # /v1 포함
export LM_STUDIO_API_KEY="dummy"                      # 아무 문자열이면 됨
 
# 3) Evalchemy 실행 — 모델 ID는 _밑줄_ 버전 그대로!
python -m eval.eval \
  --model curator \
  --tasks AIME24,MATH500 \
  --model_name "lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b" \
  --apply_chat_template True \
  --output_path logs/deepseek-qwen3-8b_lmstudio.json
```

**API 키 사용 시**: `--model_args`에 `api_key`를 직접 추가할 수 있습니다.

```bash
--model_args "api_base=http://127.0.0.1:1234/v1,api_key=my-secret-key"
```

### `curl`을 이용한 사전 연결 테스트

Evalchemy를 실행하기 전에 `curl` 명령으로 LM Studio 서버가 정상적으로 응답하는지 확인할 수 있습니다.

```bash
# 1. 사용 가능한 모델 ID 확인
curl -s http://127.0.0.1:1234/v1/models | jq .

# 2. 간단한 채팅 호출 테스트
curl -s -H "Content-Type: application/json" \
     -d '{"model":"deepseek-ai_deepseek-r1-0528-qwen3-8b","messages":[{"role":"user","content":"ping"}]}' \
     http://127.0.0.1:1234/v1/chat/completions

python - <<'PY'
from litellm import completion
import os, json
os.environ["LM_STUDIO_API_BASE"]="http://127.0.0.1:1234/v1"
os.environ["LM_STUDIO_API_KEY"]="dummy"
print( completion(
        model="lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b",
        messages=[{"role":"user","content":"ping?"}]
      )["choices"][0]["message"]["content"][:120] )
PY

cp  eval/chat_benchmarks/AIME24/data/aime24.json \
    eval/chat_benchmarks/AIME24/data/aime24_full.json

jq '.[0]' \
  eval/chat_benchmarks/AIME24/data/aime24_full.json \
  > eval/chat_benchmarks/AIME24/data/aime24.json

mv eval/chat_benchmarks/AIME24/data/aime24_full.json \
   eval/chat_benchmarks/AIME24/data/aime24.json

```

## YAML 하위 셋(AIME24_subset) 위치·작성법

```text
<repo root>/
├─ configs/
│   └─ aime24_subset.yaml   ← 여기!
├─ eval/
│   └─ chat_benchmarks/
│       └─ AIME24/
│           └─ data/aime24.json  (30 문제 원본)
└─ … 기타 파일 …


```

| 용도                          | 실제 경로                                                      |
| --------------------------- | ---------------------------------------------------------- |
| **원본 문제 JSON** (30 문제 전부)   | `eval/chat_benchmarks/AIME24/data/aime24.json`             |
| **하위 YAML**(1 문제만 쓰는 설정 파일) | `eval/chat_benchmarks/AIME24/aime24_subset.yaml` ← 새로 만드세요 |





## 결과 분석: 통계표 읽는 법

벤치마크가 완료되면 터미널에 다음과 같은 최종 통계표가 출력됩니다.

```bash
python -m eval.eval --model curator --tasks AIME24 --limit 1 \
  --model_name "lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://127.0.0.1:1234/v1,api_key=dummy" \
  --apply_chat_template True --batch_size 1 \
  --gen_kwargs "max_new_tokens=256,stop=[\"\\n\"]" \
  --output_path logs/quickcheck.json

python -m eval.eval --model curator --config configs/aime24_subset.yaml \
  --model_name "lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://127.0.0.1:1234/v1,api_key=dummy" \
  --apply_chat_template True --batch_size 1 \
  --output_path logs/quickcheck.json

python -m eval.eval            \
  --model curator              \
  --tasks AIME24               \
  --limit 1 --predict_only --skip_eval \
  --model_name "lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://127.0.0.1:1234/v1,api_key=dummy" \
  --apply_chat_template True   \
  --batch_size 1               \
  --gen_kwargs "max_new_tokens=256" \
  --output_path logs/quickcheck.json
```

```text
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% • Time Elapsed 0:49:49 • Time Remaining 0:00:00
Requests: Total: 30 • Cached: 0✓ • Success: 30✓ • Failed: 0✗ • In Progress: 0⋯ • Req/min: 0.6 • Res/min: 0.6

                            Final Curator Statistics
╭────────────────────────────┬─────────────────────────────────────────────────╮
│ Section/Metric             │ Value                                           │
├────────────────────────────┼─────────────────────────────────────────────────┤
│ Model                      │                                                 │
│ Name                       │ lm_studio/deepseek-ai_deepseek-r1-0528-qwen3-8b │
│ Requests                   │                                                 │
│ Total Processed            │ 30                                              │
│ Successful                 │ 30                                              │
│ Performance                │                                                 │
│ Total Time                 │ 2989.12s                                        │
│ Average Time per Request   │ 99.64s                                          │
│ Requests per Minute        │ 0.6                                             │
╰────────────────────────────┴─────────────────────────────────────────────────╯
```

### 통계표 핵심 지표 해석

| 구간 | 의미 | 해석 예시 |
|:-----|:-----|:----------|
| **Requests** | 총 API 호출, 성공, 실패 횟수입니다. | `Successful: 30` / `Failed: 0`은 API 연결, 키, 모델 ID가 모두 정상임을 의미합니다. |
| **Tokens** | 처리된 입력/출력 토큰의 총량 및 평균입니다. | `Average Output Tokens: 2040`은 AIME24 태스크가 긴 서술형 풀이를 요구한다는 것을 보여줍니다. |
| **Performance** | 요청당 평균 시간, 분당 요청/응답 처리량(RPM)입니다. | `Average Time per Request: 99.64s`는 CPU 기반 환경의 한계를 보여줍니다. GPU(vLLM) 환경에서는 10배 이상 빨라질 수 있습니다. |
| **Cost** | 토큰 사용량 기반의 예상 비용입니다. | 로컬 모델은 가격표가 없으므로 `N/A` 및 `$0.000`으로 표시됩니다. |

### 왜 `--limit 1`인데 요청이 30건일까?

`lm-evaluation-harness`의 `--limit N` 플래그는 **태스크(데이터셋)의 개수**를 제한할 뿐, 태스크 내의 **문제(샘플) 수**를 제한하지 않습니다. AIME24 데이터셋은 30개의 문제로 구성되어 있으므로, `--limit 1`로 AIME24 태스크 하나만 실행해도 30번의 API 호출이 발생하는 것이 정상입니다. 약 50분이 소요된 이유이기도 합니다 (`100초/문제 × 30문제`).

### 결과 파일 위치

- **결과 JSON**: `--output_path`로 지정한 경로(예: `logs/quickcheck.json`)에 생성됩니다. 해당 디렉터리가 없으면 자동으로 생성됩니다. 파일이 보이지 않으면 경로 오타나 쓰기 권한을 확인하세요.
- **원본 응답 캐시**: 모든 원본 API 응답은 `~/.cache/curator/<run-id>/responses_*.jsonl` 파일에 백업됩니다.

## 문제 해결 및 성능 튜닝

### 자주 묻는 질문 (FAQ)

| 문제 | 원인 및 해결책 |
|:-----|:---------------|
| **404 Not Found** | Base URL에서 `/v1`을 빠뜨렸거나 모델 ID에 오타가 있는 경우입니다. |
| **401 Invalid API key** | LM Studio 서버에 `--api-key`를 설정했는데, 요청 헤더에 다른 키가 전달된 경우입니다. |
| **429 Too Many Requests** | LM Studio의 동시 처리 한도(`max_batch`)가 낮은 경우입니다. `Developer` 탭에서 값을 높여주세요. |
| **Invalid request - model not found** | 모델 ID에 슬래시(`/`)를 사용한 경우입니다. 밑줄(`_`)을 사용한 API Identifier로 교체하세요. |

### 속도 및 효율 개선 팁

| 계층 | 팁 |
|:-----|:---|
| **LM Studio** | GPU 가속(vLLM) 서버로 전환하면 처리량(TPS)이 20배 이상 향상되고 첫 토큰 지연(TTFT)이 단축됩니다. |
| **vLLM Flags** | `--enable-chunked-prefill`, `--max-num-batched-tokens` 같은 플래그로 동적 배치를 최적화하여 처리량을 높일 수 있습니다. |
| **Curator** | `batch=True` 모드를 사용하면 내부적으로 요청을 묶어 처리해 토큰 비용과 지연 시간을 줄일 수 있습니다. |
| **Harness** | `--batch_size auto:8` 과 같이 클라이언트 측에서도 프롬프트를 묶어 보내면 API 왕복 시간을 줄일 수 있습니다. |

## 결과 파일 상세 분석

### 한눈에 보기

- **결과 JSON** → `logs/quickcheck.json` 이 디렉터리가 자동으로 생성돼 그 안에 쓰입니다. 없으면 `--output_path`에 절대경로를 주거나, 쓰기 권한·경로 오타를 확인하세요.
- **요약 지표**
  - **총 30 requests**는 AIME24 데이터셋이 30문제로 구성돼 있어서입니다(`--limit 1`은 태스크 수 제한이지 문제 수 제한이 아님)
  - **평균 2040 output 토큰** × 30 건 → 61k 토큰. CPU-only 환경이라 1 req당 ≈ 100s가 소요돼 응답률 0.6 req/min, 토큰 처리량 1.2k tpm을 기록했습니다.
  - **0 에러** ⇒ Curator ↔ LiteLLM ↔ LM Studio API 경로·키가 모두 정상.
  - **비용이 $0**로 찍힌 것은 Curator가 가격표를 못 찾은 모델(로컬 LM Studio)이라고 판단했기 때문입니다.

### 결과 파일이 보이지 않는다면

| 체크 항목 | 설명 |
|:----------|:-----|
| 경로 | `--output_path`는 **현재 작업 디렉터리 기준 상대경로**입니다. 디렉터리를 미리 만들지 않아도 Python이 자동 생성합니다(표준 `os.makedirs(..., exist_ok=True)` 호출). |
| 쓰기 권한 | macOS zsh에서 루트 폴더가 read-only이면 파일이 안 써집니다. `--output_path /Users/username/work/results/quick.json` 처럼 풀 경로로 지정하면 안전. |
| 캐시 위치 | 모든 원본 응답은 `~/.cache/curator/<run-id>/responses_*.jsonl`에 1행 1응답으로 복사 저장됩니다. |

### Curator 통계표 읽는 법

| 구간 | 의미 | 해석 |
|:-----|:-----|:-----|
| **Requests** | 총 호출·성공·실패 수 | 30 건 모두 성공 → API·모델 연결 문제 없음. |
| **Tokens** | 입력·출력·합계 | AIME24는 서술형 풀이라 출력이 길어 평균 2k tokens/문제. |
| **Performance** | `Average Time per Request`·`Requests per Minute` | CPU 맥북 + 2k 토큰 decoding → ≈ 100s. vLLM GPU라면 10–20× 빨라집니다. |
| **Rate Limit** | LiteLLM이 받은 provider 한도 | LM Studio는 제한이 없지만 LiteLLM이 기본값 RPM 200/TPM 100k로 세팅해 보여줍니다. |
| **Cost** | token×단가 계산 | 로컬 모델엔 가격표가 없어서 N/A → $0 출력. |

## 성능 최적화 가이드

### 왜 --limit 1이어도 30 요청이 나갔을까?

LM-Eval-Harness의 `--limit N`은 **"태스크 개수"**(datasets)만 잘라냅니다. AIME24처럼 1 태스크 = 30 문제 구조에선 문제 수까지 줄여주지 않습니다. → 하나의 quick-sanity run이라도 30회 호출이 정상이며, 시간 ≈ 100s × 30 = 50분이 걸린 이유도 여기서 비롯됩니다.

### 속도·효율을 올리려면

| 레이어 | 팁 | 근거 |
|:-------|:----|:-----|
| **LM Studio** | GPU 서버(vLLM)로 옮기면 20× 이상 TPS 상승 · TTFT(첫 토큰 지연) 단축 | |
| **vLLM Flags** | `--enable-chunked-prefill` & `--max-num-batched-tokens 8192`로 동적 배치 토큰↑, throughput↑ | |
| **Curator** | batch 모드(`batch=True`) 전환 시 내부 일괄 제출 → 토큰 비용 50%↓, 속도↑ | |
| **Harness** | `--batch_size auto:8` 정도로 클라이언트도 프롬프트를 묶어 전송 → API RT 줄어듦 | |
| **데이터셋 스케일링** | 진짜 "샘플 1개"만 돌리려면 `--limit 1 --skip_train --skip_eval --subset 1` 등 YAML 태스크 파라미터를 추가 지정해야 합니다. | |

## 최종 확인 리스트

벤치마크 실행 전, 아래 항목을 최종 확인하세요.

- [x] LM Studio 서버가 실행 중인가? (`Developer` ▶ `Server` 탭의 녹색 체크 확인)
- [x] LiteLLM 버전이 v1.72 이상인가?
- [x] `model_name`이 `lm_studio/` + `(API_identifier_밑줄_형식)`인가?
- [x] `api_base` URL이 `http://127.0.0.1:1234/v1` 형식을 따르는가?
- [x] API 키 설정이 서버와 클라이언트 간에 일치하는가?

## 결론

### 당장 읽을 포인트

1. **결과 파일**은 지정한 경로에 생성되며 없다면 경로·권한을 재확인.
2. 통계표는 **토큰 소비(65k)**, **평균 시간(100s)**, **TPS(0.6 req/min)**을 한눈에 보여주며, 여기서 병목(GPU 미사용, 긴 답변)도 드러납니다.
3. AIME24 자체가 30문제인지라 `limit=1`은 **태스크 수**만 자르므로 요청수=30은 정상.
4. 실전 벤치마크 전에는 **vLLM GPU + chunked prefill + Curator batch** 조합으로 TPS를 최대한 끌어올려야 전체 러닝타임이 관리 가능합니다.

이 설정들을 모두 맞췄다면 **`Requests: Success: 30✓`**와 같은 성공 메시지와 함께 벤치마크가 순조롭게 진행될 것입니다. 이 가이드를 통해 로컬 모델의 성능을 손쉽고 정확하게 측정해 보시길 바랍니다! 🚀

이 지표들을 바탕으로 서버 스펙·배치 파라미터를 조정해 보시면, 같은 AIME24 세트가 몇 분 내에 끝나는 것을 확인하실 수 있을 거예요.

---

**참고 자료:**
- [Bespoke Labs - Evalchemy](https://www.bespokelabs.ai/blog/measuring-reasoning-with-evalchemy)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [LM Studio API Reference](https://lmstudio.ai/docs/api)
- [vLLM Performance Optimization](https://docs.vllm.ai/en/latest/design/v1/metrics.html) 