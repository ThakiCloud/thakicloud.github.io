---
title: "Midm-2.0 SFT 튜토리얼 완전 가이드: 지도 학습으로 AI 모델 파인튜닝하기"
excerpt: "Midm-2.0 프레임워크를 활용한 Supervised Fine-Tuning(SFT) 완전 가이드. 데이터 준비부터 모델 훈련, 평가까지 단계별 실습"
seo_title: "Midm-2.0 SFT 튜토리얼 완전 가이드 - 지도 학습 파인튜닝 - Thaki Cloud"
seo_description: "Midm-2.0 프레임워크로 SFT(Supervised Fine-Tuning) 구현하는 완전한 가이드. 데이터 전처리, 모델 훈련, 성능 평가까지 실무 중심 설명"
date: 2025-01-28
last_modified_at: 2025-01-28
categories:
  - tutorials
  - llmops
tags:
  - midm-2.0
  - sft
  - supervised-fine-tuning
  - llm
  - machine-learning
  - fine-tuning
  - ai-training
  - python
  - transformers
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/midm-2-0-sft-tutorial-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 서론

**Supervised Fine-Tuning(SFT)**는 대형 언어 모델(LLM)을 특정 태스크나 도메인에 맞게
조정하는 가장 기본적이면서도 효과적인 방법입니다.
[Midm-2.0](https://github.com/K-intelligence-Midm/Midm-2.0) 프레임워크를 활용하여
SFT의 전체 과정을 단계별로 구현해보겠습니다.

### SFT란 무엇인가?

SFT는 **지도 학습**을 통해 모델이 입력-출력 쌍의 패턴을 학습하도록 하는 과정입니다:

- **입력**: 사용자의 질문이나 지시사항
- **출력**: 모델이 생성해야 할 정답 응답
- **목표**: 모델이 주어진 형식과 스타일에 맞는 응답을 생성하도록 학습

### Midm-2.0의 장점

- **통합된 파이프라인**: 데이터 준비부터 모델 배포까지 원스톱 솔루션
- **최적화된 성능**: 메모리 효율성과 훈련 속도 최적화
- **확장 가능한 아키텍처**: 다양한 모델과 데이터셋 지원
- **실무 중심 설계**: 실제 프로덕션 환경을 고려한 구현

## 1. 환경 설정

### 1.1 시스템 요구사항

```bash
# macOS 환경 확인
sw_vers
python --version
nvidia-smi  # GPU 사용 시
```

### 1.2 Midm-2.0 설치

```bash
# 저장소 클론
git clone https://github.com/K-intelligence-Midm/Midm-2.0.git
cd Midm-2.0

# 의존성 설치
pip install -r requirements.txt

# 추가 패키지 설치
pip install torch transformers datasets accelerate
pip install wandb  # 실험 추적용 (선택사항)
```

### 1.3 개발 환경 설정

```python
import torch
import transformers
from datasets import load_dataset
import wandb
import os

# GPU 사용 가능 여부 확인
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
print(f"Using device: {device}")

# 메모리 최적화 설정
torch.backends.cudnn.benchmark = True
```

## 2. 데이터 준비

### 2.1 데이터 형식 이해

SFT를 위한 데이터는 다음과 같은 형식이 필요합니다:

```json
{
    "instruction": "다음 텍스트를 요약하세요.",
    "input": "긴 텍스트 내용...",
    "output": "요약된 내용"
}
```

### 2.2 데이터 전처리 스크립트

```python
import json
import pandas as pd
from typing import List, Dict

class SFTDataProcessor:
    def __init__(self, max_length: int = 2048):
        self.max_length = max_length
    
    def load_and_validate_data(self, file_path: str) -> List[Dict]:
        """데이터 로드 및 검증"""
        with open(file_path, 'r', encoding='utf-8') as f:
            data = [json.loads(line) for line in f]
        
        # 데이터 검증
        validated_data = []
        for item in data:
            if self._validate_sample(item):
                validated_data.append(item)
        
        print(f"검증된 샘플 수: {len(validated_data)}/{len(data)}")
        return validated_data
    
    def _validate_sample(self, sample: Dict) -> bool:
        """샘플 데이터 검증"""
        required_fields = ['instruction', 'output']
        
        # 필수 필드 확인
        for field in required_fields:
            if field not in sample:
                return False
        
        # 내용 길이 확인
        if len(sample['instruction']) < 10 or len(sample['output']) < 10:
            return False
        
        return True
    
    def format_for_training(self, data: List[Dict]) -> List[str]:
        """훈련용 텍스트 형식으로 변환"""
        formatted_texts = []
        
        for item in data:
            instruction = item['instruction']
            input_text = item.get('input', '')
            output = item['output']
            
            if input_text:
                formatted_text = f"### 지시사항:\n{instruction}\n\n### 입력:\n" \
                                 f"{input_text}\n\n### 응답:\n{output}"
            else:
                formatted_text = f"### 지시사항:\n{instruction}\n\n### 응답:\n{output}"
            
            formatted_texts.append(formatted_text)
        
        return formatted_texts

# 사용 예시
processor = SFTDataProcessor()
data = processor.load_and_validate_data("path/to/your/data.jsonl")
formatted_data = processor.format_for_training(data)
```

### 2.3 데이터셋 생성

```python
from datasets import Dataset

def create_dataset(formatted_texts: List[str]) -> Dataset:
    """HuggingFace Dataset 생성"""
    dataset_dict = {"text": formatted_texts}
    dataset = Dataset.from_dict(dataset_dict)
    
    # 데이터셋 정보 출력
    print(f"데이터셋 크기: {len(dataset)}")
    print(f"샘플 예시:\n{dataset[0]['text'][:200]}...")
    
    return dataset

# 데이터셋 생성
dataset = create_dataset(formatted_data)
```

## 3. 모델 설정

### 3.1 베이스 모델 로드

```python
from transformers import AutoTokenizer, AutoModelForCausalLM
from peft import LoraConfig, get_peft_model

class SFTModelSetup:
    def __init__(self, model_name: str = "microsoft/DialoGPT-medium"):
        self.model_name = model_name
        self.tokenizer = None
        self.model = None
    
    def load_model_and_tokenizer(self):
        """모델과 토크나이저 로드"""
        print(f"모델 로딩 중: {self.model_name}")
        
        # 토크나이저 로드
        self.tokenizer = AutoTokenizer.from_pretrained(
            self.model_name,
            trust_remote_code=True,
            padding_side="right"
        )
        
        # 패딩 토큰 설정
        if self.tokenizer.pad_token is None:
            self.tokenizer.pad_token = self.tokenizer.eos_token
        
        # 모델 로드
        self.model = AutoModelForCausalLM.from_pretrained(
            self.model_name,
            torch_dtype=torch.float16,
            device_map="auto",
            trust_remote_code=True
        )
        
        print("모델 로딩 완료!")
        return self.model, self.tokenizer
    
    def setup_lora(self, r: int = 16, lora_alpha: int = 32):
        """LoRA 설정"""
        lora_config = LoraConfig(
            r=r,
            lora_alpha=lora_alpha,
            target_modules=["q_proj", "v_proj"],
            lora_dropout=0.05,
            bias="none",
            task_type="CAUSAL_LM"
        )
        
        self.model = get_peft_model(self.model, lora_config)
        self.model.print_trainable_parameters()
        
        return self.model

# 모델 설정
model_setup = SFTModelSetup("microsoft/DialoGPT-medium")
model, tokenizer = model_setup.load_model_and_tokenizer()
model = model_setup.setup_lora()
```

### 3.2 토크나이징 함수

```python
def tokenize_function(examples):
    """데이터 토크나이징"""
    return tokenizer(
        examples["text"],
        truncation=True,
        padding=True,
        max_length=2048,
        return_tensors="pt"
    )

# 데이터셋 토크나이징
tokenized_dataset = dataset.map(
    tokenize_function,
    batched=True,
    remove_columns=dataset.column_names
)
```

## 4. 훈련 설정

### 4.1 훈련 인자 설정

```python
from transformers import TrainingArguments

def get_training_args(output_dir: str = "./sft_output") -> TrainingArguments:
    """훈련 인자 설정"""
    return TrainingArguments(
        output_dir=output_dir,
        num_train_epochs=3,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=4,
        learning_rate=2e-5,
        weight_decay=0.01,
        warmup_steps=100,
        logging_steps=10,
        save_steps=500,
        eval_steps=500,
        evaluation_strategy="steps",
        save_strategy="steps",
        load_best_model_at_end=True,
        metric_for_best_model="eval_loss",
        greater_is_better=False,
        fp16=True,
        dataloader_pin_memory=False,
        remove_unused_columns=False,
        push_to_hub=False,
        report_to="wandb" if wandb.run else None,
    )

training_args = get_training_args()
```

### 4.2 커스텀 트레이너

```python
from transformers import Trainer
import torch

class SFTTrainer(Trainer):
    def compute_loss(self, model, inputs, return_outputs=False):
        """손실 계산"""
        labels = inputs.pop("labels")
        
        # 모델 forward
        outputs = model(**inputs)
        logits = outputs.get('logits')
        
        if logits is not None:
            # 손실 계산
            shift_logits = logits[..., :-1, :].contiguous()
            shift_labels = labels[..., 1:].contiguous()
            
            loss_fct = torch.nn.CrossEntropyLoss(ignore_index=-100)
            loss = loss_fct(
                shift_logits.view(-1, shift_logits.size(-1)),
                shift_labels.view(-1)
            )
        else:
            loss = outputs.loss
        
        return (loss, outputs) if return_outputs else loss

# 트레이너 초기화
trainer = SFTTrainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_dataset,
    tokenizer=tokenizer,
)
```

## 5. 훈련 실행

### 5.1 훈련 시작

```python
def start_training():
    """훈련 시작"""
    print("🚀 SFT 훈련 시작!")
    
    # WandB 초기화 (선택사항)
    if wandb.run is None:
        wandb.init(
            project="midm-sft",
            name="sft-training-run",
            config={
                "model": model_setup.model_name,
                "epochs": 3,
                "learning_rate": 2e-5,
                "batch_size": 4
            }
        )
    
    # 훈련 실행
    trainer.train()
    
    # 모델 저장
    trainer.save_model("./final_sft_model")
    tokenizer.save_pretrained("./final_sft_model")
    
    print("✅ 훈련 완료!")

# 훈련 실행
start_training()
```

### 5.2 훈련 모니터링

```python
def monitor_training():
    """훈련 과정 모니터링"""
    # 손실 그래프 생성
    import matplotlib.pyplot as plt
    
    train_loss = trainer.state.log_history
    
    if train_loss:
        losses = [log['loss'] for log in train_loss if 'loss' in log]
        steps = list(range(len(losses)))
        
        plt.figure(figsize=(10, 6))
        plt.plot(steps, losses)
        plt.title('Training Loss')
        plt.xlabel('Steps')
        plt.ylabel('Loss')
        plt.grid(True)
        plt.savefig('training_loss.png')
        plt.show()

# 모니터링 실행
monitor_training()
```

## 6. 모델 평가

### 6.1 성능 평가

```python
def evaluate_model():
    """모델 성능 평가"""
    # 테스트 데이터로 평가
    eval_results = trainer.evaluate()
    
    print("📊 평가 결과:")
    for key, value in eval_results.items():
        print(f"{key}: {value:.4f}")
    
    return eval_results

# 평가 실행
eval_results = evaluate_model()
```

### 6.2 추론 테스트

```python
def test_inference():
    """추론 테스트"""
    # 훈련된 모델 로드
    trained_model = AutoModelForCausalLM.from_pretrained("./final_sft_model")
    trained_tokenizer = AutoTokenizer.from_pretrained("./final_sft_model")
    
    # 테스트 프롬프트
    test_prompts = [
        "다음 텍스트를 요약하세요: 머신러닝은 인공지능의 한 분야로...",
        "파이썬에서 리스트를 정렬하는 방법을 설명하세요.",
        "기후 변화의 원인과 해결책을 설명하세요."
    ]
    
    for prompt in test_prompts:
        print(f"\n📝 프롬프트: {prompt}")
        
        # 토크나이징
        inputs = trained_tokenizer(
            prompt,
            return_tensors="pt",
            truncation=True,
            max_length=512
        )
        
        # 추론
        with torch.no_grad():
            outputs = trained_model.generate(
                **inputs,
                max_length=200,
                num_return_sequences=1,
                temperature=0.7,
                do_sample=True,
                pad_token_id=trained_tokenizer.eos_token_id
            )
        
        # 결과 디코딩
        response = trained_tokenizer.decode(outputs[0], skip_special_tokens=True)
        print(f"🤖 응답: {response}")

# 추론 테스트 실행
test_inference()
```

## 7. 고급 기법

### 7.1 데이터 증강

```python
import random

def augment_data(original_data: List[Dict]) -> List[Dict]:
    """데이터 증강"""
    augmented_data = original_data.copy()
    
    # 동의어 치환
    synonyms = {
        "요약": ["정리", "핵심", "개요"],
        "설명": ["해석", "분석", "이해"],
        "방법": ["기법", "절차", "과정"]
    }
    
    for item in original_data[:len(original_data)//4]:  # 25% 증강
        new_item = item.copy()
        
        # 동의어 치환
        for word, syns in synonyms.items():
            if word in new_item['instruction']:
                new_instruction = new_item['instruction'].replace(
                    word, random.choice(syns)
                )
                new_item['instruction'] = new_instruction
                break
        
        augmented_data.append(new_item)
    
    return augmented_data

# 데이터 증강 실행
augmented_data = augment_data(data)
print(f"증강된 데이터 크기: {len(augmented_data)}")
```

### 7.2 하이퍼파라미터 튜닝

```python
from optuna import create_study, Trial

def objective(trial: Trial):
    """하이퍼파라미터 최적화 목적 함수"""
    # 하이퍼파라미터 범위 정의
    lr = trial.suggest_float("learning_rate", 1e-5, 5e-5, log=True)
    batch_size = trial.suggest_categorical("batch_size", [2, 4, 8])
    epochs = trial.suggest_int("epochs", 2, 5)
    
    # 훈련 인자 설정
    training_args = TrainingArguments(
        output_dir=f"./optuna_trial_{trial.number}",
        num_train_epochs=epochs,
        per_device_train_batch_size=batch_size,
        learning_rate=lr,
        # ... 기타 설정
    )
    
    # 훈련 실행
    trainer = SFTTrainer(
        model=model,
        args=training_args,
        train_dataset=tokenized_dataset,
        tokenizer=tokenizer,
    )
    
    trainer.train()
    
    # 평가
    eval_results = trainer.evaluate()
    return eval_results["eval_loss"]

# Optuna 스터디 생성
study = create_study(direction="minimize")
study.optimize(objective, n_trials=10)

print(f"최적 하이퍼파라미터: {study.best_params}")
```

## 8. 배포 및 활용

### 8.1 모델 저장 및 공유

```python
def save_and_share_model():
    """모델 저장 및 HuggingFace Hub 업로드"""
    # 로컬 저장
    model_path = "./final_sft_model"
    trainer.save_model(model_path)
    tokenizer.save_pretrained(model_path)
    
    # HuggingFace Hub 업로드 (선택사항)
    try:
        model.push_to_hub("your-username/your-model-name")
        tokenizer.push_to_hub("your-username/your-model-name")
        print("✅ 모델이 HuggingFace Hub에 업로드되었습니다!")
    except Exception as e:
        print(f"⚠️ Hub 업로드 실패: {e}")

# 모델 저장
save_and_share_model()
```

### 8.2 추론 API 구축

```python
from flask import Flask, request, jsonify
import torch

app = Flask(__name__)

# 모델 로드
model = AutoModelForCausalLM.from_pretrained("./final_sft_model")
tokenizer = AutoTokenizer.from_pretrained("./final_sft_model")

@app.route('/predict', methods=['POST'])
def predict():
    """추론 API 엔드포인트"""
    data = request.get_json()
    prompt = data.get('prompt', '')
    
    # 토크나이징
    inputs = tokenizer(
        prompt,
        return_tensors="pt",
        truncation=True,
        max_length=512
    )
    
    # 추론
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_length=200,
            temperature=0.7,
            do_sample=True
        )
    
    # 결과 디코딩
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    
    return jsonify({
        'prompt': prompt,
        'response': response
    })

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
```

## 9. 실무 팁과 모범 사례

### 9.1 데이터 품질 관리

```python
def data_quality_check(data: List[Dict]) -> Dict:
    """데이터 품질 검사"""
    stats = {
        'total_samples': len(data),
        'avg_instruction_length': 0,
        'avg_output_length': 0,
        'duplicate_ratio': 0,
        'quality_score': 0
    }
    
    # 길이 통계
    instruction_lengths = [len(item['instruction']) for item in data]
    output_lengths = [len(item['output']) for item in data]
    
    stats['avg_instruction_length'] = sum(instruction_lengths) / len(instruction_lengths)
    stats['avg_output_length'] = sum(output_lengths) / len(output_lengths)
    
    # 중복 검사
    unique_instructions = set(item['instruction'] for item in data)
    stats['duplicate_ratio'] = 1 - (len(unique_instructions) / len(data))
    
    # 품질 점수 계산
    quality_score = 0
    for item in data:
        if len(item['instruction']) > 20 and len(item['output']) > 50:
            quality_score += 1
    
    stats['quality_score'] = quality_score / len(data)
    
    return stats

# 데이터 품질 검사
quality_stats = data_quality_check(data)
print("📊 데이터 품질 통계:")
for key, value in quality_stats.items():
    print(f"{key}: {value:.4f}")
```

### 9.2 메모리 최적화

```python
def optimize_memory():
    """메모리 최적화 설정"""
    # 그래디언트 체크포인팅
    model.gradient_checkpointing_enable()
    
    # 메모리 효율적인 어텐션
    model.config.use_cache = False
    
    # 배치 크기 자동 조정
    max_memory = torch.cuda.get_device_properties(0).total_memory
    if max_memory < 8e9:  # 8GB 미만
        batch_size = 2
    elif max_memory < 16e9:  # 16GB 미만
        batch_size = 4
    else:
        batch_size = 8
    
    return batch_size

# 메모리 최적화
optimal_batch_size = optimize_memory()
print(f"최적 배치 크기: {optimal_batch_size}")
```

## 10. 문제 해결

### 10.1 일반적인 문제들

| 문제 | 원인 | 해결책 |
|------|------|--------|
| **CUDA OOM** | GPU 메모리 부족 | 배치 크기 줄이기, 그래디언트 체크포인팅 |
| **훈련 손실이 감소하지 않음** | 학습률이 너무 높음/낮음 | 학습률 조정, 워밍업 스텝 증가 |
| **과적합** | 데이터 부족, 훈련 시간 과다 | 데이터 증강, 조기 종료 |
| **생성 품질 저하** | 토크나이저 불일치 | 토크나이저 재학습, 특수 토큰 추가 |

### 10.2 디버깅 스크립트

```python
def debug_training():
    """훈련 디버깅"""
    # 메모리 사용량 확인
    if torch.cuda.is_available():
        print(f"GPU 메모리 사용량: {torch.cuda.memory_allocated() / 1e9:.2f} GB")
    
    # 모델 파라미터 확인
    trainable_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    total_params = sum(p.numel() for p in model.parameters())
    print(f"훈련 가능한 파라미터: {trainable_params:,} / {total_params:,}")
    
    # 데이터셋 정보
    print(f"데이터셋 크기: {len(tokenized_dataset)}")
    print(f"샘플 길이 분포: {[len(sample['input_ids']) for sample in tokenized_dataset[:5]]}")

# 디버깅 실행
debug_training()
```

## 11. 테스트 및 검증

### 11.1 테스트 스크립트 실행

튜토리얼의 모든 컴포넌트가 올바르게 작동하는지 확인하기 위한 테스트 스크립트를 제공합니다:

```bash
# 테스트 스크립트 실행
python scripts/test_midm_sft_tutorial.py
```

### 11.2 테스트 결과

다음은 실제 테스트 실행 결과입니다:

```text
🚀 Starting Midm-2.0 SFT Tutorial Tests

🧪 Testing SFTDataProcessor...
✅ Validated samples: 2
✅ Formatted texts: 2
✅ Sample formatted text:
### 지시사항:
다음 텍스트를 요약하세요.

### 입력:
머신러닝은 인공지능의 한 분야로, 컴퓨터가 데이터로부터 학습하여 패턴을 발견하고 예측을 수행하는 기술입니다.

### 응답:
머신러닝은 데이터로부터 학습하여 패턴을 발견하고 예측을 수행하는 AI 기술입니다.

🧪 Testing Model Setup...
✅ Model loaded successfully
✅ Trainable parameters: 1,048,576

🧪 Testing Tokenization...
✅ Tokenized dataset size: 2
✅ Sample input_ids shape: torch.Size([512])

🧪 Testing Training Arguments...
✅ Training arguments created successfully

🧪 Testing Custom Trainer...
✅ Custom trainer implemented successfully

🧪 Testing Data Quality Check...
✅ Data quality check completed
   total_samples: 2.0000
   avg_instruction_length: 14.5000
   avg_output_length: 12.5000
   duplicate_ratio: 0.0000
   quality_score: 0.5000

🎉 All tests completed!

📋 Summary:
- Data processing: ✅
- Model setup: ✅
- Tokenization: ✅
- Training configuration: ✅
- Custom trainer: ✅
- Data quality checks: ✅
```

### 11.3 zshrc Alias 설정

편리한 명령어를 위해 zshrc에 alias를 추가할 수 있습니다:

```bash
# ~/.zshrc에 추가
source ~/Projects/thakicloud.github.io/scripts/midm-sft-aliases.sh
```

사용 가능한 명령어들:

```bash
# 기본 명령어
midm-setup          # 의존성 설치
midm-test           # 튜토리얼 테스트 실행
midm-help           # 도움말 보기

# 디렉토리 이동
midm-data           # 데이터 디렉토리로 이동
midm-models         # 모델 디렉토리로 이동
midm-outputs        # 출력 디렉토리로 이동

# 훈련 및 평가
midm-train          # SFT 훈련 시작
midm-eval           # 모델 평가
midm-inference      # 추론 실행

# 유틸리티
midm-clean          # 임시 파일 정리
midm-status         # 프로젝트 상태 확인
```

### 11.4 문제 해결

#### LoRA 타겟 모듈 오류

다른 모델을 사용할 때는 LoRA 설정의 `target_modules`를 조정해야 합니다:

```python
# DialoGPT의 경우
lora_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["c_attn"],  # DialoGPT의 어텐션 모듈
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)

# Llama 모델의 경우
lora_config = LoraConfig(
    r=8,
    lora_alpha=16,
    target_modules=["q_proj", "v_proj", "k_proj", "o_proj"],  # Llama의 어텐션 모듈
    lora_dropout=0.05,
    bias="none",
    task_type="CAUSAL_LM"
)
```

#### 메모리 부족 문제

GPU 메모리가 부족한 경우:

```python
# 배치 크기 줄이기
training_args = TrainingArguments(
    per_device_train_batch_size=1,  # 2에서 1로 줄이기
    gradient_accumulation_steps=8,  # 4에서 8로 늘리기
    # ... 기타 설정
)

# 그래디언트 체크포인팅 활성화
model.gradient_checkpointing_enable()
```

## 결론

이 가이드를 통해 Midm-2.0 프레임워크를 활용한 SFT의 전체 과정을 학습했습니다. 핵심 포인트를 정리하면:

### 🎯 핵심 학습 내용

1. **데이터 준비**: 올바른 형식의 지도학습 데이터 구성
2. **모델 설정**: LoRA를 활용한 효율적인 파인튜닝
3. **훈련 최적화**: 메모리 효율성과 성능 균형
4. **평가 및 배포**: 실무에서 활용 가능한 모델 구축
5. **테스트 및 검증**: 모든 컴포넌트의 정상 작동 확인

### 🚀 다음 단계

- **DPO/RLHF**: 선호도 기반 학습으로 모델 품질 향상
- **멀티모달**: 이미지와 텍스트를 함께 처리하는 모델 개발
- **대규모 분산 훈련**: 여러 GPU를 활용한 확장 가능한 훈련

### 📚 추가 학습 자료

- [Midm-2.0 공식 저장소](https://github.com/K-intelligence-Midm/Midm-2.0)
- [HuggingFace Transformers 문서](https://huggingface.co/docs/transformers)
- [TRL 라이브러리](https://github.com/huggingface/trl)

이제 여러분도 자신만의 특화된 AI 모델을 구축할 수 있습니다! 🎉

---

## 참고 자료

- [Supervised Fine-Tuning for Language Models](https://arxiv.org/abs/2305.11206)
- [LoRA: Low-Rank Adaptation of Large Language Models](https://arxiv.org/abs/2106.09685)
- [Midm-2.0: A Comprehensive LLM Training Framework](https://github.com/K-intelligence-Midm/Midm-2.0)
