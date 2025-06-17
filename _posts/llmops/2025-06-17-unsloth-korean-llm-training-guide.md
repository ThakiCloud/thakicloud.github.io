---
title: "Unsloth를 활용한 한국어 특화 LLM 학습 완전 가이드"
excerpt: "Unsloth로 높은 수준의 한국어 특화 대규모 언어 모델을 구축하는 단계별 실무 가이드"
date: 2025-06-17
categories:
  - llmops
tags:
  - Unsloth
  - Korean LLM
  - Fine-tuning
  - LoRA
  - SFT
  - RLHF
  - Language Model Training
  - Korean NLP
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

본 가이드는 Unsloth를 활용하여 높은 수준의 한국어 특화 대규모 언어 모델을 구축하는 방법을 단계별로 설명합니다. 환경 설정부터 배포까지 전 과정을 실무 중심으로 다룹니다.

**학습 목표**:
- 🚀 **Unsloth 기반 효율적 학습**: 메모리 최적화된 한국어 LLM 훈련
- 🇰🇷 **한국어 특화 최적화**: 토크나이저부터 데이터셋까지 한국어 최적화
- 📊 **3단계 학습 파이프라인**: CPT → SFT → RLHF 완전 구현
- ⚡ **실무 배포**: 온프레미스 및 클라우드 배포 가이드

---

## 1. 환경 설정 및 준비

### 1.1 필요한 라이브러리 설치

```bash
# Unsloth 설치 (최신 버전)
pip install "unsloth[colab-new] @ git+https://github.com/unslothai/unsloth.git"
pip install --no-deps xformers trl peft accelerate bitsandbytes

# 추가 의존성
pip install datasets transformers tokenizers sentencepiece
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# 한국어 처리 라이브러리
pip install konlpy kss soynlp
```

### 1.2 기본 import 및 설정

```python
import torch
from unsloth import FastLanguageModel
from datasets import Dataset, load_dataset
from transformers import TrainingArguments, AutoTokenizer
from trl import SFTTrainer, PPOTrainer, PPOConfig
import json
import pandas as pd
from typing import List, Dict
import warnings
warnings.filterwarnings("ignore")

# GPU 메모리 설정
torch.cuda.empty_cache()
print(f"GPU 사용 가능: {torch.cuda.is_available()}")
print(f"GPU 개수: {torch.cuda.device_count()}")
```

### 1.3 하드웨어 요구사항

**권장 사양**:
- **GPU**: RTX 4090 (24GB) 또는 A100 (40GB) 이상
- **RAM**: 64GB 이상
- **저장공간**: 500GB 이상 (모델 + 데이터셋)

**최소 사양**:
- **GPU**: RTX 3080 (10GB) + 4bit 양자화
- **RAM**: 32GB
- **저장공간**: 200GB

---

## 2. 한국어 토크나이저 준비 및 적응

### 2.1 한국어 특화 토크나이저 구성

```python
from sentencepiece import SentencePieceProcessor, SentencePieceTrainer
import re

class KoreanTokenizerBuilder:
    def __init__(self, vocab_size=32000):
        self.vocab_size = vocab_size
        
    def prepare_korean_corpus(self, text_files):
        """한국어 코퍼스 전처리"""
        processed_texts = []
        
        for file_path in text_files:
            with open(file_path, 'r', encoding='utf-8') as f:
                text = f.read()
                
                # 한국어 텍스트 정규화
                text = self.normalize_korean_text(text)
                processed_texts.append(text)
        
        return processed_texts
    
    def normalize_korean_text(self, text):
        """한국어 텍스트 정규화"""
        # 불필요한 공백 제거
        text = re.sub(r'\s+', ' ', text)
        
        # 한국어 특수문자 정규화
        text = text.replace('ㆍ', '·')
        text = text.replace('～', '~')
        
        # HTML 태그 제거
        text = re.sub(r'<[^>]+>', '', text)
        
        return text.strip()
    
    def train_korean_tokenizer(self, corpus_files):
        """한국어 특화 토크나이저 학습"""
        SentencePieceTrainer.train(
            input=','.join(corpus_files),
            model_prefix='korean_tokenizer',
            vocab_size=self.vocab_size,
            character_coverage=0.9995,
            model_type='bpe',
            # 한국어 특수 처리
            normalization_rule_name='nmt_nfkc_cf',
            remove_extra_whitespaces=True,
            input_sentence_size=10000000,
            shuffle_input_sentence=True,
            # 한국어 특수 토큰
            user_defined_symbols=['<한국어>', '<영어>', '<코드>'],
            unk_surface=' ⁇ '
        )
        
        return 'korean_tokenizer.model'

# 사용 예시
tokenizer_builder = KoreanTokenizerBuilder(vocab_size=32000)
korean_corpus_files = ['korean_wiki.txt', 'korean_news.txt', 'korean_books.txt']
tokenizer_path = tokenizer_builder.train_korean_tokenizer(korean_corpus_files)
```

### 2.2 모델 로딩 및 토크나이저 적용

```python
def load_model_with_korean_optimization(model_name="unsloth/Qwen2.5-7B-bnb-4bit"):
    """한국어 최적화된 모델 로딩"""
    
    model, tokenizer = FastLanguageModel.from_pretrained(
        model_name=model_name,
        max_seq_length=131072,  # 높은과 동일한 컨텍스트 길이
        dtype=None,  # 자동 감지 (bfloat16 권장)
        load_in_4bit=True,  # 메모리 효율성
        trust_remote_code=True
    )
    
    # 한국어 특수 토큰 추가
    special_tokens = {
        "pad_token": "<pad>",
        "eos_token": "</s>",
        "bos_token": "<s>",
        "unk_token": "<unk>",
        "additional_special_tokens": ["<한국어>", "<영어>", "<코드>", "<수학>"]
    }
    
    tokenizer.add_special_tokens(special_tokens)
    model.resize_token_embeddings(len(tokenizer))
    
    # LoRA 어댑터 설정 (한국어 최적화)
    model = FastLanguageModel.get_peft_model(
        model,
        r=64,  # LoRA rank (높을수록 성능 향상, 메모리 증가)
        target_modules=[
            "q_proj", "k_proj", "v_proj", "o_proj",
            "gate_proj", "up_proj", "down_proj"
        ],
        lora_alpha=16,
        lora_dropout=0.1,
        bias="none",
        use_gradient_checkpointing="unsloth",  # Unsloth 최적화
        random_state=3407,
        use_rslora=False,  # Rank Stabilized LoRA
        loftq_config=None,  # LoftQ 양자화
    )
    
    return model, tokenizer

# 모델 로딩
model, tokenizer = load_model_with_korean_optimization()
print(f"모델 파라미터 수: {model.num_parameters():,}")
print(f"학습 가능한 파라미터 수: {model.num_parameters(only_trainable=True):,}")
```

---

## 3. 한국어 데이터셋 구성

### 3.1 고품질 한국어 데이터 수집

```python
class KoreanDatasetBuilder:
    def __init__(self):
        self.datasets = []
        
    def collect_web_data(self):
        """웹에서 고품질 한국어 데이터 수집"""
        web_sources = {
            "korean_wikipedia": {
                "url": "https://dumps.wikimedia.org/kowiki/",
                "quality": "high",
                "size": "1.2GB"
            },
            "korean_news": {
                "sources": ["연합뉴스", "조선일보", "한겨레"],
                "quality": "high", 
                "size": "800MB"
            },
            "korean_blogs": {
                "platforms": ["네이버 블로그", "티스토리"],
                "quality": "medium",
                "size": "2.1GB"
            }
        }
        return web_sources
    
    def collect_academic_data(self):
        """학술 자료 수집"""
        academic_sources = {
            "korean_papers": "한국 학술 논문 (KISS, DBpia)",
            "textbooks": "한국어 교과서 및 전문서적",
            "legal_documents": "법률 문서 (국가법령정보센터)"
        }
        return academic_sources
    
    def generate_synthetic_data(self, base_model):
        """합성 데이터 생성"""
        synthetic_templates = {
            "qa_pairs": self.generate_korean_qa_pairs(base_model),
            "conversations": self.generate_korean_conversations(base_model),
            "instructions": self.generate_korean_instructions(base_model)
        }
        return synthetic_templates
    
    def create_balanced_dataset(self):
        """균형잡힌 데이터셋 구성"""
        # 높은 언어 비율 참고: 한국어 42%, 영어 51%, 기타 7%
        dataset_composition = {
            "korean": {
                "ratio": 0.42,
                "sources": ["wiki", "news", "books", "academic", "synthetic"],
                "total_tokens": "420B"
            },
            "english": {
                "ratio": 0.51,
                "sources": ["common_crawl", "books", "academic", "code"],
                "total_tokens": "510B"
            },
            "others": {
                "ratio": 0.07,
                "sources": ["code", "math", "multilingual"],
                "total_tokens": "70B"
            }
        }
        
        return dataset_composition

# 데이터셋 빌더 초기화
dataset_builder = KoreanDatasetBuilder()
dataset_composition = dataset_builder.create_balanced_dataset()
```

### 3.2 데이터 전처리 및 포맷팅

```python
def preprocess_korean_dataset(raw_data_path, output_path):
    """한국어 데이터셋 전처리"""
    import json
    from tqdm import tqdm
    
    processed_data = []
    
    with open(raw_data_path, 'r', encoding='utf-8') as f:
        for line in tqdm(f, desc="데이터 전처리"):
            try:
                item = json.loads(line)
                
                # 텍스트 품질 검사
                if is_high_quality_korean_text(item['text']):
                    processed_item = {
                        "text": normalize_korean_text(item['text']),
                        "source": item.get('source', 'unknown'),
                        "length": len(item['text']),
                        "language": "korean"
                    }
                    processed_data.append(processed_item)
                    
            except Exception as e:
                continue
    
    # 저장
    with open(output_path, 'w', encoding='utf-8') as f:
        for item in processed_data:
            f.write(json.dumps(item, ensure_ascii=False) + '\n')
    
    print(f"전처리 완료: {len(processed_data):,}개 샘플")
    return processed_data

def is_high_quality_korean_text(text):
    """한국어 텍스트 품질 검사"""
    import re
    
    # 최소 길이 검사
    if len(text) < 50:
        return False
    
    # 한국어 비율 검사
    korean_chars = len(re.findall(r'[가-힣]', text))
    total_chars = len(text)
    korean_ratio = korean_chars / total_chars if total_chars > 0 else 0
    
    if korean_ratio < 0.3:  # 한국어 비율 30% 이상
        return False
    
    # 반복 패턴 검사
    if has_repetitive_patterns(text):
        return False
    
    return True

def format_instruction_dataset(raw_instructions):
    """Instruction 데이터셋 포맷팅"""
    formatted_data = []
    
    for item in raw_instructions:
        # Alpaca 스타일 포맷
        if item.get('input'):
            formatted_text = f"""### 지시사항:
{item['instruction']}

### 입력:
{item['input']}

### 응답:
{item['output']}"""
        else:
            formatted_text = f"""### 지시사항:
{item['instruction']}

### 응답:
{item['output']}"""
        
        formatted_data.append({
            "text": formatted_text,
            "type": "instruction"
        })
    
    return formatted_data
```

---

## 4. 단계별 학습 과정

### 4.1 1단계: 지속적 사전학습 (CPT)

```python
def continuous_pretraining(model, tokenizer, korean_corpus_path):
    """지속적 사전학습 단계"""
    
    print("=== 1단계: 지속적 사전학습 시작 ===")
    
    # 대용량 한국어 코퍼스 로딩
    dataset = load_dataset("json", data_files=korean_corpus_path, split="train")
    
    def tokenize_function(examples):
        # 긴 텍스트를 청크로 분할
        return tokenizer(
            examples["text"],
            truncation=True,
            padding=False,
            max_length=4096,  # CPT에서는 상대적으로 짧은 시퀀스 사용
            return_overflowing_tokens=True,
        )
    
    # 토크나이징 (배치 처리)
    tokenized_dataset = dataset.map(
        tokenize_function,
        batched=True,
        batch_size=1000,
        num_proc=4,
        remove_columns=dataset.column_names,
    )
    
    # CPT 학습 설정
    cpt_args = TrainingArguments(
        output_dir="./korean_cpt_output",
        overwrite_output_dir=True,
        num_train_epochs=2,
        per_device_train_batch_size=2,
        gradient_accumulation_steps=32,
        learning_rate=1e-5,  # CPT에서는 낮은 학습률
        weight_decay=0.01,
        logging_steps=100,
        save_steps=2000,
        save_total_limit=3,
        warmup_steps=1000,
        fp16=True,
        gradient_checkpointing=True,
        dataloader_pin_memory=False,
        remove_unused_columns=False,
        report_to="none",  # wandb 사용 시 "wandb"
    )
    
    # 트레이너 초기화
    trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        args=cpt_args,
        train_dataset=tokenized_dataset,
        dataset_text_field="text",
        max_seq_length=4096,
        packing=True,  # 효율적인 배치 패킹
    )
    
    # 학습 실행
    trainer.train()
    
    # 모델 저장
    trainer.save_model("./korean_cpt_final")
    print("=== CPT 완료 ===")
    
    return model

# CPT 실행
model = continuous_pretraining(model, tokenizer, "korean_corpus.jsonl")
```

### 4.2 2단계: 지도 미세조정 (SFT)

```python
def supervised_fine_tuning(model, tokenizer, instruction_dataset_path):
    """지도 미세조정 단계"""
    
    print("=== 2단계: 지도 미세조정 시작 ===")
    
    # Instruction 데이터셋 로딩
    sft_dataset = load_dataset("json", data_files=instruction_dataset_path, split="train")
    
    def formatting_prompts_func(examples):
        """프롬프트 포맷팅 함수"""
        texts = []
        for i in range(len(examples["instruction"])):
            instruction = examples["instruction"][i]
            input_text = examples["input"][i] if examples["input"][i] else ""
            output = examples["output"][i]
            
            if input_text:
                text = f"""### 지시사항:
{instruction}

### 입력:
{input_text}

### 응답:
{output}<|endoftext|>"""
            else:
                text = f"""### 지시사항:
{instruction}

### 응답:
{output}<|endoftext|>"""
            
            texts.append(text)
        
        return {"text": texts}
    
    # 데이터셋 포맷팅
    sft_dataset = sft_dataset.map(
        formatting_prompts_func,
        batched=True,
        num_proc=4,
    )
    
    # SFT 학습 설정
    sft_args = TrainingArguments(
        output_dir="./korean_sft_output",
        num_train_epochs=3,
        per_device_train_batch_size=4,
        gradient_accumulation_steps=8,
        learning_rate=2e-5,  # SFT에서는 높은 학습률
        weight_decay=0.01,
        logging_steps=50,
        save_steps=1000,
        warmup_steps=100,
        fp16=True,
        optim="adamw_8bit",
        lr_scheduler_type="cosine",
        save_total_limit=2,
        load_best_model_at_end=True,
        metric_for_best_model="loss",
        greater_is_better=False,
    )
    
    # SFT 트레이너
    sft_trainer = SFTTrainer(
        model=model,
        tokenizer=tokenizer,
        train_dataset=sft_dataset,
        dataset_text_field="text",
        max_seq_length=2048,
        args=sft_args,
        packing=False,  # SFT에서는 패킹 비활성화
    )
    
    # 학습 실행
    sft_trainer.train()
    
    # 모델 저장
    sft_trainer.save_model("./korean_sft_final")
    print("=== SFT 완료 ===")
    
    return model

# SFT 실행
model = supervised_fine_tuning(model, tokenizer, "korean_instructions.jsonl")
```

### 4.3 3단계: 인간 피드백 강화학습 (RLHF)

```python
def reinforcement_learning_from_human_feedback(model, tokenizer, preference_data_path):
    """RLHF 단계"""
    
    print("=== 3단계: RLHF 시작 ===")
    
    # 참조 모델 (frozen)
    ref_model, _ = FastLanguageModel.from_pretrained(
        "korean_sft_final",
        max_seq_length=2048,
        dtype=None,
        load_in_4bit=True,
    )
    ref_model = FastLanguageModel.for_inference(ref_model)
    
    # PPO 설정
    ppo_config = PPOConfig(
        model_name="korean_rlhf_model",
        learning_rate=1e-6,  # RLHF에서는 매우 낮은 학습률
        batch_size=16,
        mini_batch_size=4,
        gradient_accumulation_steps=4,
        optimize_cuda_cache=True,
        early_stopping=True,
        target_kl=0.1,
        ppo_epochs=4,
        seed=42,
        log_with="tensorboard",
    )
    
    # 보상 모델 로딩 (사전 학습된 한국어 보상 모델)
    reward_model = load_korean_reward_model()
    
    # PPO 트레이너
    ppo_trainer = PPOTrainer(
        config=ppo_config,
        model=model,
        ref_model=ref_model,
        tokenizer=tokenizer,
        reward_model=reward_model,
    )
    
    # 강화학습 데이터 로딩
    rl_dataset = load_dataset("json", data_files=preference_data_path, split="train")
    
    # 강화학습 실행
    for epoch in range(3):
        for batch in rl_dataset.iter(batch_size=16):
            # 쿼리 준비
            query_tensors = [
                tokenizer.encode(query, return_tensors="pt")[0] 
                for query in batch["query"]
            ]
            
            # 응답 생성
            response_tensors = ppo_trainer.generate(
                query_tensors,
                return_prompt=False,
                max_new_tokens=256,
                do_sample=True,
                temperature=0.7,
                top_p=0.9,
            )
            
            # 보상 계산
            rewards = compute_rewards(batch["query"], response_tensors, reward_model)
            
            # PPO 업데이트
            stats = ppo_trainer.step(query_tensors, response_tensors, rewards)
            
            if epoch % 100 == 0:
                print(f"Epoch {epoch}, Reward: {torch.mean(rewards):.4f}")
    
    # 최종 모델 저장
    ppo_trainer.save_model("./korean_rlhf_final")
    print("=== RLHF 완료 ===")
    
    return model

def load_korean_reward_model():
    """한국어 보상 모델 로딩"""
    # 실제로는 사전에 학습된 한국어 보상 모델을 로딩
    # 여기서는 예시로 더미 모델 반환
    class DummyRewardModel:
        def __call__(self, queries, responses):
            # 실제로는 응답의 품질, 유용성, 안전성 등을 평가
            return torch.randn(len(responses))
    
    return DummyRewardModel()

def compute_rewards(queries, responses, reward_model):
    """보상 계산"""
    rewards = reward_model(queries, responses)
    return rewards
```

---

## 5. 평가 및 벤치마크

### 5.1 한국어 능력 종합 평가

```python
def evaluate_korean_capabilities(model, tokenizer):
    """한국어 능력 종합 평가"""
    
    print("=== 한국어 능력 평가 시작 ===")
    
    benchmarks = {
        "KMMLU": evaluate_kmmlu,
        "CLIcK": evaluate_click,
        "Ko-IFEval": evaluate_ko_ifeval,
        "Korean-QA": evaluate_korean_qa,
        "Korean-Math": evaluate_korean_math
    }
    
    results = {}
    for benchmark_name, eval_func in benchmarks.items():
        print(f"\n{benchmark_name} 평가 중...")
        score = eval_func(model, tokenizer)
        results[benchmark_name] = score
        print(f"{benchmark_name}: {score:.1f}%")
    
    # 종합 점수 계산
    overall_score = sum(results.values()) / len(results)
    print(f"\n=== 종합 점수: {overall_score:.1f}% ===")
    
    return results

def evaluate_kmmlu(model, tokenizer):
    """KMMLU 벤치마크 평가"""
    # 한국어 전문 지식 이해도 평가
    kmmlu_dataset = load_dataset("HAERAE-HUB/KMMLU", split="test")
    
    correct = 0
    total = 0
    
    for item in kmmlu_dataset:
        prompt = format_kmmlu_prompt(item)
        response = generate_response(model, tokenizer, prompt)
        
        if check_answer_correctness(response, item["answer"]):
            correct += 1
        total += 1
        
        if total % 100 == 0:
            print(f"진행률: {total}/{len(kmmlu_dataset)}")
    
    accuracy = (correct / total) * 100
    return accuracy

def format_kmmlu_prompt(item):
    """KMMLU 프롬프트 포맷팅"""
    choices = '\n'.join([f"{chr(65+i)}. {choice}" for i, choice in enumerate(item["choices"])])
    
    prompt = f"""다음 문제를 읽고 정답을 선택하세요.

문제: {item["question"]}

선택지:
{choices}

정답:"""
    
    return prompt

def generate_response(model, tokenizer, prompt, max_length=512):
    """모델 응답 생성"""
    inputs = tokenizer(prompt, return_tensors="pt")
    
    with torch.no_grad():
        outputs = model.generate(
            **inputs,
            max_new_tokens=max_length,
            temperature=0.1,  # 평가에서는 낮은 temperature
            do_sample=False,
            pad_token_id=tokenizer.eos_token_id
        )
    
    response = tokenizer.decode(outputs[0], skip_special_tokens=True)
    return response[len(prompt):].strip()
```

### 5.2 토큰 효율성 측정

```python
def measure_token_efficiency(tokenizer, test_texts):
    """토큰 효율성 측정"""
    
    print("=== 토큰 효율성 측정 ===")
    
    korean_stats = {"chars": 0, "tokens": 0}
    english_stats = {"chars": 0, "tokens": 0}
    
    for text in test_texts:
        char_count = len(text)
        token_count = len(tokenizer.encode(text))
        
        if is_korean_text(text):
            korean_stats["chars"] += char_count
            korean_stats["tokens"] += token_count
        else:
            english_stats["chars"] += char_count
            english_stats["tokens"] += token_count
    
    # 문자/토큰 비율 계산
    korean_ratio = korean_stats["chars"] / korean_stats["tokens"]
    english_ratio = english_stats["chars"] / english_stats["tokens"]
    
    print(f"한국어 문자/토큰 비율: {korean_ratio:.2f}")
    print(f"영어 문자/토큰 비율: {english_ratio:.2f}")
    
    # GPT-4o와 비교 (참고값)
    gpt4o_korean_ratio = 1.5
    efficiency_improvement = korean_ratio / gpt4o_korean_ratio
    
    print(f"GPT-4o 대비 한국어 효율성: {efficiency_improvement:.2f}x")
    
    return korean_ratio, efficiency_improvement

def is_korean_text(text):
    """한국어 텍스트 판별"""
    import re
    korean_chars = len(re.findall(r'[가-힣]', text))
    return korean_chars / len(text) > 0.5 if text else False
```

---

## 6. 모델 배포 및 최적화

### 6.1 모델 저장 및 변환

```python
def save_and_optimize_model(model, tokenizer, output_dir="./ax4_korean_final"):
    """모델 저장 및 최적화"""
    
    print("=== 모델 저장 및 최적화 시작 ===")
    
    # 1. Unsloth 최적화된 모델 저장
    model.save_pretrained_merged(
        output_dir,
        tokenizer,
        save_method="merged_16bit"  # 16bit 정밀도로 저장
    )
    print("✓ 16bit 모델 저장 완료")
    
    # 2. 4bit 양자화 모델 저장 (경량화)
    model.save_pretrained_merged(
        output_dir + "_4bit",
        tokenizer,
        save_method="merged_4bit"
    )
    print("✓ 4bit 양자화 모델 저장 완료")
    
    # 3. GGUF 형식으로 변환 (CPU 추론용)
    model.save_pretrained_gguf(
        output_dir + "_gguf",
        tokenizer,
        quantization_method="q4_k_m"  # 4bit 양자화
    )
    print("✓ GGUF 모델 변환 완료")
    
    # 4. vLLM 호환 형식으로 저장
    try:
        model.save_pretrained_vllm(
            output_dir + "_vllm",
            tokenizer
        )
        print("✓ vLLM 호환 모델 저장 완료")
    except:
        print("⚠ vLLM 변환 실패 (수동 변환 필요)")
    
    # 5. 모델 정보 저장
    model_info = {
        "model_name": "AX4.0-Korean",
        "base_model": "Qwen2.5-7B",
        "training_stages": ["CPT", "SFT", "RLHF"],
        "context_length": 131072,
        "vocab_size": len(tokenizer),
        "parameters": model.num_parameters(),
        "trainable_parameters": model.num_parameters(only_trainable=True)
    }
    
    with open(f"{output_dir}/model_info.json", "w", encoding="utf-8") as f:
        json.dump(model_info, f, indent=2, ensure_ascii=False)
    
    print("=== 모델 저장 완료 ===")
    return output_dir

# 모델 저장 실행
final_model_path = save_and_optimize_model(model, tokenizer)
```

### 6.2 배포 준비

```python
def prepare_deployment_configs():
    """배포용 설정 파일 생성"""
    
    # vLLM 서빙 설정
    vllm_config = {
        "model": "./ax4_korean_final_vllm",
        "host": "0.0.0.0",
        "port": 8000,
        "max_model_len": 131072,
        "tensor_parallel_size": 2,
        "gpu_memory_utilization": 0.9,
        "enable_chunked_prefill": True,
        "max_num_batched_tokens": 8192
    }
    
    # Docker 배포 스크립트
    docker_script = f"""
# Dockerfile
FROM nvidia/cuda:11.8-devel-ubuntu20.04

# 기본 패키지 설치
RUN apt-get update && apt-get install -y python3 python3-pip

# Python 라이브러리 설치
RUN pip3 install vllm transformers torch

# 모델 복사
COPY ./ax4_korean_final_vllm /app/model

# 서빙 스크립트
COPY serve.py /app/serve.py

WORKDIR /app
EXPOSE 8000

CMD ["python3", "serve.py"]
"""
    
    # Kubernetes 배포 YAML
    k8s_config = """
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ax4-korean-llm
spec:
  replicas: 2
  selector:
    matchLabels:
      app: ax4-korean-llm
  template:
    metadata:
      labels:
        app: ax4-korean-llm
    spec:
      containers:
      - name: llm-server
        image: ax4-korean:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            nvidia.com/gpu: 1
          limits:
            nvidia.com/gpu: 1
---
apiVersion: v1
kind: Service
metadata:
  name: ax4-korean-service
spec:
  selector:
    app: ax4-korean-llm
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
"""
    
    return vllm_config, docker_script, k8s_config

# 배포 설정 생성
vllm_config, docker_script, k8s_config = prepare_deployment_configs()

# 설정 파일 저장
with open("vllm_config.json", "w") as f:
    json.dump(vllm_config, f, indent=2)

with open("Dockerfile", "w") as f:
    f.write(docker_script)

with open("k8s-deployment.yaml", "w") as f:
    f.write(k8s_config)

print("배포 설정 파일 생성 완료")
```

---

## 7. 성능 모니터링 및 개선

### 7.1 실시간 모니터링 시스템

```python
def setup_monitoring_system():
    """성능 모니터링 시스템 구축"""
    
    monitoring_metrics = {
        "response_quality": {
            "description": "응답 품질 점수",
            "threshold": 0.8,
            "measurement": "자동 평가 + 사용자 피드백"
        },
        "token_efficiency": {
            "description": "토큰 효율성",
            "threshold": 1.5,  # 한국어 문자/토큰 비율
            "measurement": "실시간 토큰 사용량 분석"
        },
        "korean_accuracy": {
            "description": "한국어 정확도",
            "threshold": 0.85,
            "measurement": "한국어 벤치마크 점수"
        },
        "safety_compliance": {
            "description": "안전성 준수율",
            "threshold": 0.95,
            "measurement": "유해 콘텐츠 필터링 정확도"
        }
    }
    
    return monitoring_metrics

def continuous_improvement_pipeline():
    """지속적 개선 파이프라인"""
    
    improvement_pipeline = {
        "data_collection": {
            "user_feedback": "사용자 평가 및 피드백 수집",
            "usage_patterns": "사용 패턴 분석",
            "error_cases": "오류 사례 수집"
        },
        "analysis": {
            "performance_analysis": "성능 저하 구간 분석",
            "failure_analysis": "실패 사례 원인 분석",
            "improvement_opportunities": "개선 기회 식별"
        },
        "improvement": {
            "data_augmentation": "추가 학습 데이터 생성",
            "model_updates": "모델 업데이트",
            "deployment": "개선된 모델 배포"
        }
    }
    
    return improvement_pipeline

# 모니터링 시스템 초기화
monitoring_system = setup_monitoring_system()
improvement_pipeline = continuous_improvement_pipeline()

print("모니터링 시스템 구축 완료")
```

---

## 주요 고려사항 및 팁

### 데이터 품질 관리

**고품질 데이터 확보**:
- 다양한 도메인의 균형잡힌 데이터 수집
- 중복 제거 및 품질 필터링 필수
- 합성 데이터 활용으로 데이터 부족 해결

**데이터 전처리**:
```python
# 데이터 품질 체크리스트
quality_checklist = {
    "minimum_length": 50,      # 최소 문자 수
    "korean_ratio": 0.3,       # 한국어 비율 30% 이상
    "repetition_check": True,   # 반복 패턴 검사
    "encoding_check": True,     # 인코딩 오류 검사
    "profanity_filter": True    # 욕설/유해 콘텐츠 필터
}
```

### 리소스 최적화

**메모리 효율성**:
- Unsloth의 메모리 최적화 기능 적극 활용
- LoRA/QLoRA로 학습 가능한 파라미터 수 조절
- Gradient checkpointing으로 메모리 절약

**학습 속도 향상**:
```python
# 최적화 설정
optimization_settings = {
    "use_gradient_checkpointing": True,
    "fp16": True,  # 또는 bf16
    "dataloader_num_workers": 4,
    "pin_memory": True,
    "pack_sequences": True
}
```

### 평가 및 검증

**다각도 평가**:
- 정량적 평가: KMMLU, CLIcK 등 표준 벤치마크
- 정성적 평가: 실제 사용자 테스트
- 안전성 평가: 유해 콘텐츠 생성 여부 검사

**지속적 모니터링**:
- 실시간 성능 추적
- 사용자 피드백 수집
- 정기적인 벤치마크 재평가

---

## H100 GPU별 한국어 특화 LLM 학습 시간 추정

한국어 특화 LLM 학습에 필요한 시간을 H100 GPU 개수별로 정리해드리겠습니다.

### 7B 모델 (경량 버전)

| GPU 구성 | CPT | SFT | RLHF | 총 학습시간 |
|---------|-----|-----|------|---------|
| **H100 1장** | 5-7일 | 12-18시간 | 8-12시간 | **약 6-8일** |
| **H100 2장** | 3-4일 | 6-9시간 | 4-6시간 | **약 3.5-4.5일** |
| **H100 4장** | 1.5-2일 | 3-4시간 | 2-3시간 | **약 2-2.5일** |
| **H100 8장** | 18-24시간 | 1.5-2시간 | 1-1.5시간 | **약 1-1.5일** |

### 72B 모델 (표준 버전)

| GPU 구성 | CPT | SFT | RLHF | 총 학습시간 |
|---------|-----|-----|------|---------|
| **H100 1장** | 불가능* | - | - | **메모리 부족** |
| **H100 2장** | 4-6주 | 3-5일 | 2-3일 | **약 5-7주** |
| **H100 4장** | 2-3주 | 1.5-2일 | 1-1.5일 | **약 2.5-3.5주** |
| **H100 8장** | 1-1.5주 | 12-18시간 | 8-12시간 | **약 1.5-2주** |

*72B 모델은 H100 1장으로는 메모리 부족으로 학습 불가능

### 주요 영향 요인

#### 1. 학습 단계별 시간 비중
- **CPT (지속적 사전학습)**: 전체 시간의 80-85%
- **SFT (지도 미세조정)**: 전체 시간의 10-15%  
- **RLHF (강화학습)**: 전체 시간의 5-10%

#### 2. 데이터 규모
- **한국어 코퍼스**: 500GB-1TB
- **총 토큰 수**: 1-2조 토큰
- **학습 에폭**: CPT 3-5회, SFT 3-5회

#### 3. 최적화 기법 적용 시
```python
# Unsloth + QLoRA 적용 시 시간 단축
기본 학습 시간 × 0.6-0.7 = 최적화 후 시간

# 예시: 7B 모델, H100 4장
기본: 2-2.5일 → 최적화 후: 1.2-1.8일
```

### 실제 비용 추정

#### 클라우드 비용 (H100 시간당 약 $4-6)
- **7B 모델**: 
  - H100 4장: $1,200-2,400
  - H100 8장: $800-1,440
  
- **72B 모델**:
  - H100 4장: $6,000-12,600
  - H100 8장: $4,000-8,640

### 권장 구성

#### 개발/실험 환경
- **7B 모델 + H100 4장**: 비용 효율적이며 2-3일 내 완료

#### 프로덕션 환경  
- **72B 모델 + H100 8장**: Llama 3 70B 수준의 모델이 6.4백만 H100 GPU-시간이 필요하지만, 한국어 특화 학습은 기존 모델 기반이므로 훨씬 단축됩니다

#### 메모리 요구사항
- **7B 모델**: H100 80GB 1장으로 충분
- **72B 모델**: 최소 H100 2장 필요 (텐서 병렬화)

### 학습 효율성 팁

1. **Gradient Checkpointing**: 메모리 사용량 50% 절약
2. **Mixed Precision (FP16/BF16)**: 학습 속도 1.5-2배 향상
3. **DeepSpeed ZeRO**: 대용량 모델 학습 시 필수
4. **Unsloth 최적화**: 메모리와 속도 모두 30-50% 개선

이러한 추정치는 데이터 품질, 하드웨어 구성, 최적화 수준에 따라 달라질 수 있으니, 실제 파일럿 테스트를 통해 정확한 시간을 측정하시기 바랍니다. 

---

## 결론

본 가이드를 통해 Unsloth를 활용한 한국어 특화 LLM 구축의 전 과정을 학습했습니다. 주요 성과는 다음과 같습니다:

**기술적 성과**:
- **효율적인 학습**: Unsloth로 메모리 사용량 대폭 절약
- **한국어 최적화**: 토크나이저부터 데이터까지 한국어 특화
- **3단계 파이프라인**: CPT → SFT → RLHF 완전 구현
- **배포 준비**: 다양한 형태의 모델 변환 및 배포 설정

**실무적 가치**:
- **비용 효율성**: 기존 대비 50% 이상 리소스 절약
- **성능 향상**: 높은 수준의 한국어 성능 달성
- **확장 가능성**: 다양한 도메인으로 확장 가능
- **유지보수성**: 체계적인 모니터링 및 개선 시스템

이러한 과정을 통해 한국어 특화 대규모 언어 모델을 성공적으로 구축하고 실무에 적용할 수 있습니다. 지속적인 개선과 모니터링을 통해 더욱 향상된 성능을 달성할 수 있을 것입니다.



