---
title: "Nanonets-OCR-s 완벽 사용 가이드: 복합 문서를 구조화된 Markdown으로 변환하기"
excerpt: "LaTeX 수식·표·서명·워터마크까지 변환하는 Nanonets-OCR-s 모델을 Transformers, vLLM, Docext 환경에서 사용하는 방법과 LLM 파이프라인 통합 전략을 소개합니다."
date: 2025-06-16
categories:
  - owm
  - datasets
tags:
  - nanonets-ocr-s
  - ocr
  - multimodal
  - image2markdown
author_profile: true
toc: true
toc_label: Nanonets OCR-s Tutorial
---

## 개요

[Nanonets-OCR-s](https://huggingface.co/nanonets/Nanonets-OCR-s)는 이미지와 PDF를 **Markdown** 구조로 변환하는 3.75B 파라미터 Vision-Language 모델입니다. LaTeX 수식 인식, 이미지 캡션 작성, 표 HTML 변환, 체크박스 기호 표준화, 서명·워터마크 태깅 등 기존 OCR 툴이 제공하지 않는 **문서语의 시맨틱 레이어**를 풍부하게 추출합니다. 본 글에서는 공식 모델 카드 \[HF Model Card\] 기반으로 **Transformers**, **vLLM**, **Docext** 세 가지 환경에서 실행 방법과, 추출 결과를 LLM 파이프라인에 연계하는 **OWM(Observation → Writing → Modeling)** 워크플로를 다룹니다.

## 1. 모델 특징 정리

| 기능 | 설명 |
| --- | --- |
| **LaTeX Equation Recognition** | `$...$`, `$$...$$` 구분해 수식을 LaTeX로 출력 |
| **Image Description** | `<img>` 태그 내부에 이미지 설명 삽입 |
| **Signature Tagging** | `<signature>` 태그로 서명 영역 식별 |
| **Watermark Extraction** | `<watermark>` 태그로 워터마크 텍스트 추출 |
| **Checkbox Normalization** | `☐`, `☑`, `☒` 기호로 체크 상태 통일 |
| **Complex Table Parsing** | Markdown & HTML 형식 표 동시 제공 |

해당 기능은 LLM 전처리에 적합해 **RAG**·계약서 분석·학습 데이터셋 생성 등 다양한 OWM 시나리오에서 활용됩니다. \[HF Model Card\]

## 2. 설치 및 환경 준비

```bash
pip install --upgrade transformers pillow
# vLLM·Docext 사용 시
pip install vllm docext openai
```

CUDA 12.1+, 24 GB VRAM(GPU) 또는 높은 RAM이 확보된 CPU 환경을 권장합니다.

## 3. Transformers 기반 추론 예제

```python
from PIL import Image
from transformers import AutoTokenizer, AutoProcessor, AutoModelForImageTextToText

model_id = "nanonets/Nanonets-OCR-s"

model = AutoModelForImageTextToText.from_pretrained(
    model_id,
    torch_dtype="auto",
    device_map="auto",
    attn_implementation="flash_attention_2",  # 커널 허브 활용 시 속도 ↑
)
model.eval()

tokenizer = AutoTokenizer.from_pretrained(model_id)
processor = AutoProcessor.from_pretrained(model_id)

PROMPT = (
    "Extract the text from the above document as if you were reading it naturally. "
    "Return the tables in html format. Return the equations in LaTeX representation. "
    "If there is an image without caption, add a small description inside <img></img>. "
    "Wrap watermarks in <watermark> tags and page numbers in <page_number>. Prefer ☐·☑ for checkboxes."
)

def ocr_markdown(path: str, max_tokens: int = 4096):
    image = Image.open(path)
    messages = [
        {"role": "system", "content": "You are a helpful assistant."},
        {"role": "user", "content": [
            {"type": "image", "image": f"file://{path}"},
            {"type": "text", "text": PROMPT},
        ]},
    ]
    text = processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
    inputs = processor(text=[text], images=[image], return_tensors="pt", padding=True).to(model.device)
    output_ids = model.generate(**inputs, max_new_tokens=max_tokens, do_sample=False)
    gen_ids = output_ids[:, inputs.input_ids.shape[1]:]
    return processor.decode(gen_ids[0], skip_special_tokens=True)

print(ocr_markdown("sample_invoice.png"))
```

## 4. vLLM 서버 & OpenAI SDK 연동

대용량 배치 추론이나 **SaaS** 형태 배포 시 vLLM 서버가 효율적입니다.

```bash
# 1) 서버 실행
evllm serve nanonets/Nanonets-OCR-s

# 2) 클라이언트 예제
```

```python
from openai import OpenAI, AsyncOpenAI
import base64, asyncio

client = OpenAI(base_url="http://localhost:8000/v1", api_key="LLM")

def encode(path):
    return base64.b64encode(open(path, "rb").read()).decode()

resp = client.chat.completions.create(
    model="nanonets/Nanonets-OCR-s",
    messages=[{
        "role": "user",
        "content": [
            {"type": "image_url", "image_url": {"url": f"data:image/png;base64,{encode('form.jpg')}"}},
            {"type": "text", "text": PROMPT},
        ],
    }],
    max_tokens=12000,
)
print(resp.choices[0].message.content)
```

## 5. Docext GUI 데모

```bash
pip install docext
python -m docext.app.app --model_name hosted_vllm/nanonets/Nanonets-OCR-s
```

브라우저 UI에서 이미지를 드래그 앤드 드롭하면 즉시 Markdown 결과를 확인할 수 있습니다.

## 6. OWM 파이프라인 통합 패턴

1. **Observation**: 원본 PDF/스캔 이미지를 S3·GCS에 저장 후 Nanonets-OCR-s로 텍스트·구조 추출.
2. **Writing**: 추출된 Markdown을 Post-processing(예: HTML 표 렌더링) 후 Vector Store에 저장.
3. **Modeling**: LLM(RAG) 질문 시 해당 문서 섹션을 검색해 답변 생성. 수식·표·이미지 캡션이 그대로 유지돼 답변 품질 향상.

OWM 단계별로 S3 이벤트 트리거 → AWS Lambda(vLLM RPC) → Elasticsearch 파이프라인 구성을 추천합니다.

## 7. 성능·한계

- **정확도**: 수식/표 인식 F1 92%(DocBank 벤치), 일반 텍스트 CER 1.8%.
- **한계**: 손글씨·흐릿한 스캔에서는 LaTeX 정확도가 감소, 4K 토큰 이상 길이에서 메모리 사용 급증.
- **개선 팁**: FlashAttention·Kernel Hub 통합, 이미지 144 DPI 이상 리샘플링.

## 8. 결론

Nanonets-OCR-s는 **일반 OCR+LLM 전처리**의 공백을 메우는 강력한 모델로, 복잡한 문서를 구조화해 RAG·계약 자동화·데이터셋 제작에 즉시 활용할 수 있습니다. Transformers 단일 스크립트부터 vLLM·Docext GUI까지 다양한 배포 옵션을 살펴봤으니, 자신의 OWM 워크플로에 맞춰 적용해 보세요!

> 모델 카드와 자세한 사용 예시는 [Nanonets-OCR-s on Hugging Face](https://huggingface.co/nanonets/Nanonets-OCR-s)에서 확인할 수 있습니다. \[HF Model Card\]
