---
title: "FinePDFs: HuggingFace 대용량 PDF 텍스트 데이터셋 완전 활용 가이드"
excerpt: "2.8M 문서와 1733개 언어를 포함한 51.6GB 규모의 FinePDFs 데이터셋을 LLM 훈련과 연구에 효과적으로 활용하는 방법을 학습하세요."
seo_title: "FinePDFs 튜토리얼: HuggingFace PDF 데이터셋 활용 가이드 - Thaki Cloud"
seo_description: "HuggingFace FinePDFs 데이터셋 완전 튜토리얼. 데이터 로딩, 전처리, 분석 및 LLM 훈련을 위한 실용적 활용법 안내."
date: 2025-09-08
lang: ko
permalink: /ko/tutorials/finepdfs-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/finepdfs-comprehensive-tutorial-guide/"
categories:
  - tutorials
tags:
  - finepdfs
  - huggingface
  - datasets
  - pdf
  - nlp
  - llm
author_profile: true
toc: true
toc_label: "목차"
---

⏱️ **예상 읽기 시간**: 15분

## 소개

FinePDFs는 오픈소스 데이터셋 생성 분야에서 획기적인 성과를 나타냅니다. HuggingFace에서 발표한 이 대규모 데이터셋은 **280만 개의 문서**와 **1,733개 언어**를 포함하며, 웹상의 PDF 파일에서 추출되었습니다. 총 **51.6GB** 규모의 FinePDFs는 고비용의 PDF 처리와 접근 가능한 고품질 텍스트 콘텐츠 사이의 중요한 격차를 해소합니다.

HTML 콘텐츠에 집중하는 기존 웹 스크래핑과 달리, PDF는 일반적으로 과학, 법률, 기술 문서 등의 도메인에서 더 높은 품질의 전문적인 콘텐츠를 포함합니다. 이 튜토리얼은 여러분의 프로젝트에서 FinePDFs를 효과적으로 활용하는 데 필요한 모든 것을 안내합니다.

## 데이터셋 개요

### 주요 통계
- **크기**: 51.6GB (압축)
- **문서 수**: 2,865,213행
- **언어**: 1,733개 언어 서브셋
- **라이선스**: ODC-By v1.0
- **형식**: 효율적 처리를 위한 Parquet 파일

### 추출 방법
FinePDFs는 두 가지 주요 추출 파이프라인을 사용합니다:
1. **Docling**: PDF에 내장된 텍스트에서 직접 추출
2. **RolmOCR**: 이미지가 많은 문서를 위한 OCR 기반 추출

## 사전 준비사항

튜토리얼을 시작하기 전에 다음이 설치되어 있는지 확인하세요:

```bash
# 필요한 패키지 설치
pip install datasets transformers torch pandas matplotlib seaborn
pip install huggingface_hub datasets[streaming]
```

## 시작하기

### 1. 데이터셋 로딩

데이터셋 구조를 탐색하고 서브셋을 로딩해보겠습니다:

```python
from datasets import load_dataset
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 특정 언어 서브셋 로딩 (예: 영어)
print("FinePDFs 데이터셋 로딩 중...")
dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", split="train", streaming=True)

# 쉬운 탐색을 위해 pandas로 변환
sample_data = []
for i, example in enumerate(dataset):
    if i >= 1000:  # 탐색을 위해 첫 1000개 예제로 제한
        break
    sample_data.append(example)

df = pd.DataFrame(sample_data)
print(f"샘플 데이터셋 크기: {df.shape}")
print(f"컬럼: {df.columns.tolist()}")
```

### 2. 데이터 구조 탐색

```python
# 처음 몇 행 검토
print("첫 3개 예제:")
for i in range(3):
    print(f"\n예제 {i+1}:")
    print(f"텍스트 길이: {len(df.iloc[i]['text'])} 문자")
    print(f"텍스트 미리보기: {df.iloc[i]['text'][:200]}...")
    
# 기본 통계
print(f"\n데이터셋 통계:")
print(f"샘플 내 총 문서 수: {len(df)}")
print(f"평균 텍스트 길이: {df['text'].str.len().mean():.2f} 문자")
print(f"중앙값 텍스트 길이: {df['text'].str.len().median():.2f} 문자")
```

### 3. 사용 가능한 언어 서브셋

```python
# 사용 가능한 언어 구성 목록
from datasets import get_dataset_config_names

configs = get_dataset_config_names("HuggingFaceFW/finepdfs")
print(f"사용 가능한 총 언어 서브셋: {len(configs)}")
print(f"첫 20개 언어 코드: {configs[:20]}")

# 더 많은 데이터가 있는 인기 언어 서브셋
popular_langs = [
    "eng_Latn",    # 영어
    "spa_Latn",    # 스페인어  
    "fra_Latn",    # 프랑스어
    "deu_Latn",    # 독일어
    "ita_Latn",    # 이탈리아어
    "por_Latn",    # 포르투갈어
    "rus_Cyrl",    # 러시아어
    "zho_Hans",    # 중국어 (간체)
    "jpn_Jpan",    # 일본어
    "arb_Arab"     # 아랍어
]

print(f"인기 언어 서브셋: {popular_langs}")
```

## 데이터 분석 및 전처리

### 4. 텍스트 품질 평가

```python
import re
from collections import Counter

def analyze_text_quality(texts):
    """텍스트 품질 지표 분석"""
    results = {
        'avg_length': [],
        'word_count': [],
        'sentence_count': [],
        'char_diversity': [],
        'contains_code': [],
        'contains_math': []
    }
    
    for text in texts[:100]:  # 분석을 위해 첫 100개 샘플링
        # 기본 지표
        results['avg_length'].append(len(text))
        results['word_count'].append(len(text.split()))
        results['sentence_count'].append(len(re.split(r'[.!?]+', text)))
        
        # 문자 다양성 (고유 문자 / 총 문자)
        unique_chars = len(set(text.lower()))
        total_chars = len(text)
        results['char_diversity'].append(unique_chars / max(total_chars, 1))
        
        # 코드 감지 (단순화)
        code_indicators = ['def ', 'function', 'import ', '#include', 'class ', '{', '}']
        results['contains_code'].append(any(indicator in text for indicator in code_indicators))
        
        # 수학 감지 (단순화)
        math_indicators = ['∫', '∑', '∂', '∆', '∇', '≥', '≤', '±', '²', '³']
        results['contains_math'].append(any(indicator in text for indicator in math_indicators))
    
    return results

# 샘플 데이터 분석
quality_metrics = analyze_text_quality(df['text'].tolist())

print("텍스트 품질 분석:")
print(f"평균 문서 길이: {sum(quality_metrics['avg_length'])/len(quality_metrics['avg_length']):.2f} 문자")
print(f"평균 단어 수: {sum(quality_metrics['word_count'])/len(quality_metrics['word_count']):.2f} 단어")
print(f"코드 포함 문서: {sum(quality_metrics['contains_code'])} / {len(quality_metrics['contains_code'])}")
print(f"수학 포함 문서: {sum(quality_metrics['contains_math'])} / {len(quality_metrics['contains_math'])}")
```

### 5. 콘텐츠 도메인 분류

```python
def classify_document_domain(text):
    """키워드 기반 단순 도메인 분류"""
    text_lower = text.lower()
    
    # 도메인 키워드 정의
    domains = {
        'scientific': ['research', 'study', 'experiment', 'hypothesis', 'methodology', 'results', 'conclusion'],
        'legal': ['court', 'law', 'statute', 'regulation', 'defendant', 'plaintiff', 'contract'],
        'technical': ['algorithm', 'implementation', 'system', 'framework', 'architecture', 'development'],
        'medical': ['patient', 'diagnosis', 'treatment', 'clinical', 'medical', 'therapy', 'disease'],
        'financial': ['investment', 'portfolio', 'market', 'economic', 'financial', 'revenue', 'profit'],
        'academic': ['university', 'education', 'learning', 'curriculum', 'academic', 'student', 'professor']
    }
    
    domain_scores = {}
    for domain, keywords in domains.items():
        score = sum(1 for keyword in keywords if keyword in text_lower)
        domain_scores[domain] = score
    
    return max(domain_scores, key=domain_scores.get) if max(domain_scores.values()) > 0 else 'general'

# 샘플 문서 분류
domains = [classify_document_domain(text) for text in df['text'][:200]]
domain_counts = Counter(domains)

print("도메인 분포 (200개 문서 샘플):")
for domain, count in domain_counts.most_common():
    print(f"{domain}: {count}개 문서 ({count/200*100:.1f}%)")
```

## 실용적 활용 사례

### 6. 파인튜닝 데이터 준비

```python
def prepare_finetuning_data(texts, max_length=512, min_length=50):
    """언어 모델 파인튜닝을 위한 데이터 준비"""
    processed_texts = []
    
    for text in texts:
        # 텍스트 정리
        cleaned = re.sub(r'\s+', ' ', text.strip())
        
        # 길이별 필터링
        if min_length <= len(cleaned) <= max_length * 4:  # 대략적인 문자-토큰 비율
            processed_texts.append(cleaned)
    
    return processed_texts

# 훈련 데이터 준비
training_texts = prepare_finetuning_data(df['text'].tolist())
print(f"파인튜닝을 위해 {len(training_texts)}개 텍스트 준비 완료")

# 훈련용 파일로 저장
with open('finepdfs_training_data.txt', 'w', encoding='utf-8') as f:
    for text in training_texts[:1000]:  # 첫 1000개 예제 저장
        f.write(text + '\n\n')

print("훈련 데이터가 'finepdfs_training_data.txt'에 저장되었습니다")
```

### 7. RAG (검색 증강 생성) 설정

```python
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def create_document_embeddings(texts, model_name='all-MiniLM-L6-v2'):
    """RAG 시스템을 위한 문서 임베딩 생성"""
    model = SentenceTransformer(model_name)
    
    # 더 나은 검색을 위한 텍스트 청킹
    chunks = []
    chunk_size = 512
    
    for text in texts[:100]:  # 첫 100개 문서 처리
        words = text.split()
        for i in range(0, len(words), chunk_size):
            chunk = ' '.join(words[i:i + chunk_size])
            if len(chunk.strip()) > 50:  # 최소 청크 크기
                chunks.append(chunk)
    
    print(f"{len(chunks)}개의 텍스트 청크 생성")
    
    # 임베딩 생성
    embeddings = model.encode(chunks, show_progress_bar=True)
    
    return chunks, embeddings, model

def retrieve_relevant_chunks(query, chunks, embeddings, model, top_k=5):
    """쿼리에 가장 관련성 높은 청크 검색"""
    query_embedding = model.encode([query])
    
    # 유사도 계산
    similarities = cosine_similarity(query_embedding, embeddings)[0]
    
    # 상위 k개 결과 가져오기
    top_indices = np.argsort(similarities)[-top_k:][::-1]
    
    results = []
    for idx in top_indices:
        results.append({
            'text': chunks[idx],
            'similarity': similarities[idx],
            'rank': len(results) + 1
        })
    
    return results

# RAG 시스템 설정
print("RAG 시스템 설정 중...")
chunks, embeddings, model = create_document_embeddings(df['text'].tolist())

# 검색 테스트
query = "machine learning algorithms"
relevant_chunks = retrieve_relevant_chunks(query, chunks, embeddings, model)

print(f"\n쿼리 '{query}'에 대한 상위 3개 관련 청크:")
for i, chunk in enumerate(relevant_chunks[:3]):
    print(f"\n순위 {chunk['rank']} (유사도: {chunk['similarity']:.3f}):")
    print(f"{chunk['text'][:200]}...")
```

### 8. 다국어 분석

```python
def analyze_multilingual_content():
    """여러 언어에 걸친 콘텐츠 분석"""
    languages_to_analyze = ['eng_Latn', 'spa_Latn', 'fra_Latn', 'deu_Latn']
    language_stats = {}
    
    for lang_code in languages_to_analyze:
        print(f"{lang_code} 분석 중...")
        
        # 언어 서브셋 로딩
        lang_dataset = load_dataset("HuggingFaceFW/finepdfs", lang_code, split="train", streaming=True)
        
        # 100개 문서 샘플링
        sample_texts = []
        for i, example in enumerate(lang_dataset):
            if i >= 100:
                break
            sample_texts.append(example['text'])
        
        # 통계 계산
        avg_length = sum(len(text) for text in sample_texts) / len(sample_texts)
        avg_words = sum(len(text.split()) for text in sample_texts) / len(sample_texts)
        
        language_stats[lang_code] = {
            'avg_length': avg_length,
            'avg_words': avg_words,
            'sample_count': len(sample_texts)
        }
    
    return language_stats

# 다국어 분석
multilingual_stats = analyze_multilingual_content()

print("\n다국어 분석 결과:")
for lang, stats in multilingual_stats.items():
    print(f"{lang}:")
    print(f"  평균 길이: {stats['avg_length']:.2f} 문자")
    print(f"  평균 단어 수: {stats['avg_words']:.2f} 단어")
    print(f"  샘플 수: {stats['sample_count']}")
```

## 고급 활용 사례

### 9. 전문 도메인 추출

```python
def extract_scientific_papers(texts, threshold=3):
    """과학 논문으로 보이는 텍스트 추출"""
    scientific_indicators = [
        'abstract', 'introduction', 'methodology', 'results', 'discussion',
        'conclusion', 'references', 'doi:', 'arxiv:', 'journal',
        'hypothesis', 'experiment', 'analysis', 'statistical'
    ]
    
    scientific_docs = []
    
    for text in texts:
        text_lower = text.lower()
        score = sum(1 for indicator in scientific_indicators if indicator in text_lower)
        
        if score >= threshold:
            scientific_docs.append({
                'text': text,
                'scientific_score': score,
                'length': len(text)
            })
    
    return sorted(scientific_docs, key=lambda x: x['scientific_score'], reverse=True)

# 과학적 콘텐츠 추출
scientific_content = extract_scientific_papers(df['text'].tolist())
print(f"{len(scientific_content)}개의 과학 문서 발견")

if scientific_content:
    print(f"최상위 과학 문서 (점수: {scientific_content[0]['scientific_score']}):")
    print(f"{scientific_content[0]['text'][:300]}...")
```

### 10. 데이터 품질 필터링

```python
def advanced_quality_filter(texts):
    """고급 품질 필터링 적용"""
    high_quality_texts = []
    
    for text in texts:
        # 길이 필터
        if len(text) < 100 or len(text) > 10000:
            continue
            
        # 언어 일관성 (단순 검사)
        words = text.split()
        if len(words) < 20:
            continue
            
        # 문자 다양성
        unique_chars = len(set(text.lower()))
        if unique_chars < 10:  # 너무 반복적
            continue
            
        # 대부분 숫자인 콘텐츠 피하기
        numeric_ratio = sum(1 for char in text if char.isdigit()) / len(text)
        if numeric_ratio > 0.3:
            continue
            
        # 합리적인 문장 구조 확인
        sentences = re.split(r'[.!?]+', text)
        avg_sentence_length = sum(len(s.split()) for s in sentences) / max(len(sentences), 1)
        if avg_sentence_length < 5 or avg_sentence_length > 50:
            continue
            
        high_quality_texts.append(text)
    
    return high_quality_texts

# 품질 필터링 적용
filtered_texts = advanced_quality_filter(df['text'].tolist())
print(f"품질 필터링: {len(df)} → {len(filtered_texts)} 문서")
print(f"보존율: {len(filtered_texts)/len(df)*100:.1f}%")
```

## 성능 최적화

### 11. 효율적인 데이터 로딩

```python
def efficient_batch_processing(dataset_name, lang_code, batch_size=1000):
    """효율적인 배치 단위 데이터셋 처리"""
    dataset = load_dataset(dataset_name, lang_code, split="train", streaming=True)
    
    batch = []
    processed_count = 0
    
    for example in dataset:
        batch.append(example['text'])
        
        if len(batch) >= batch_size:
            # 배치 처리
            yield batch
            batch = []
            processed_count += batch_size
            
            if processed_count % 10000 == 0:
                print(f"{processed_count}개 문서 처리 완료...")
    
    # 남은 배치 처리
    if batch:
        yield batch

# 사용 예시
print("배치 단위로 데이터셋 처리 중...")
for i, batch in enumerate(efficient_batch_processing("HuggingFaceFW/finepdfs", "eng_Latn")):
    # 각 배치 처리
    print(f"배치 {i+1}: {len(batch)}개 문서")
    
    # 여기에 처리 로직 추가
    # 예: 필터링, 임베딩 생성 등
    
    if i >= 4:  # 데모를 위해 첫 5개 배치만 처리
        break
```

### 12. 메모리 효율적 분석

```python
import gc
from typing import Generator

def memory_efficient_analysis(lang_code: str, max_docs: int = 10000) -> dict:
    """최소 메모리 사용량으로 분석 수행"""
    
    dataset = load_dataset("HuggingFaceFW/finepdfs", lang_code, split="train", streaming=True)
    
    # 카운터 초기화
    stats = {
        'total_docs': 0,
        'total_chars': 0,
        'total_words': 0,
        'domain_counts': Counter(),
        'length_distribution': []
    }
    
    for i, example in enumerate(dataset):
        if i >= max_docs:
            break
            
        text = example['text']
        
        # 통계 업데이트
        stats['total_docs'] += 1
        stats['total_chars'] += len(text)
        stats['total_words'] += len(text.split())
        stats['length_distribution'].append(len(text))
        
        # 도메인 분류
        domain = classify_document_domain(text)
        stats['domain_counts'][domain] += 1
        
        # 주기적 정리
        if i % 1000 == 0:
            gc.collect()
    
    # 최종 지표 계산
    stats['avg_chars'] = stats['total_chars'] / stats['total_docs']
    stats['avg_words'] = stats['total_words'] / stats['total_docs']
    
    return stats

# 메모리 효율적 분석 실행
analysis_results = memory_efficient_analysis("eng_Latn", max_docs=5000)
print("메모리 효율적 분석 결과:")
print(f"분석된 문서: {analysis_results['total_docs']}")
print(f"평균 문자 수: {analysis_results['avg_chars']:.2f}")
print(f"평균 단어 수: {analysis_results['avg_words']:.2f}")
print(f"상위 도메인: {analysis_results['domain_counts'].most_common(5)}")
```

## ML 워크플로우와의 통합

### 13. Hugging Face Transformers 통합

```python
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer
from torch.utils.data import Dataset
import torch

class FinePDFsDataset(Dataset):
    """FinePDFs를 위한 커스텀 데이터셋 클래스"""
    
    def __init__(self, texts, tokenizer, max_length=512):
        self.texts = texts
        self.tokenizer = tokenizer
        self.max_length = max_length
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, idx):
        text = self.texts[idx]
        encoding = self.tokenizer(
            text,
            truncation=True,
            padding='max_length',
            max_length=self.max_length,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': encoding['input_ids'].flatten()
        }

# 파인튜닝 설정 (예시)
model_name = "gpt2"
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

# 데이터셋 준비
train_texts = filtered_texts[:1000]  # 필터링된 고품질 텍스트 사용
train_dataset = FinePDFsDataset(train_texts, tokenizer)

print(f"{len(train_dataset)}개 예제로 훈련 데이터셋 생성 완료")
print("모델 파인튜닝 준비 완료!")

# 참고: 실제 훈련 코드는 더 많은 설정과 계산 자원이 필요합니다
```

### 14. 평가 지표

```python
def evaluate_dataset_quality(texts):
    """포괄적인 품질 평가"""
    
    metrics = {
        'readability': [],
        'information_density': [],
        'language_consistency': [],
        'structural_quality': []
    }
    
    for text in texts[:100]:  # 샘플 평가
        
        # 가독성 (단순화 - 문장 길이 기반)
        sentences = re.split(r'[.!?]+', text)
        avg_sent_len = sum(len(s.split()) for s in sentences) / max(len(sentences), 1)
        readability_score = 1.0 / (1.0 + abs(avg_sent_len - 15) / 10)  # 최적 ~15 단어
        metrics['readability'].append(readability_score)
        
        # 정보 밀도 (고유 단어 / 총 단어)
        words = text.lower().split()
        density = len(set(words)) / max(len(words), 1)
        metrics['information_density'].append(density)
        
        # 언어 일관성 (알파벳 문자 비율)
        alpha_chars = sum(1 for c in text if c.isalpha())
        consistency = alpha_chars / max(len(text), 1)
        metrics['language_consistency'].append(consistency)
        
        # 구조적 품질 (단락 및 서식 표시자)
        structure_indicators = ['\n\n', '. ', ', ', ': ', '; ']
        structure_score = sum(text.count(ind) for ind in structure_indicators) / len(text)
        metrics['structural_quality'].append(min(structure_score * 100, 1.0))
    
    # 평균 계산
    avg_metrics = {k: sum(v) / len(v) for k, v in metrics.items()}
    
    return avg_metrics

# 품질 평가
quality_scores = evaluate_dataset_quality(df['text'].tolist())
print("데이터셋 품질 평가:")
for metric, score in quality_scores.items():
    print(f"{metric}: {score:.3f}")

# 전체 품질 점수
overall_quality = sum(quality_scores.values()) / len(quality_scores)
print(f"전체 품질 점수: {overall_quality:.3f}")
```

## 문제 해결 및 모범 사례

### 일반적인 문제와 해결책

1. **메모리 오류**
   ```python
   # 대용량 데이터셋에는 streaming=True 사용
   dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", streaming=True)
   
   # 배치 단위로 처리
   for batch in efficient_batch_processing("HuggingFaceFW/finepdfs", "eng_Latn", batch_size=500):
       process_batch(batch)
   ```

2. **느린 로딩**
   ```python
   # 데이터셋을 로컬에 캐시
   dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", cache_dir="./cache")
   
   # 특정 프로세스 수 사용
   dataset = dataset.map(preprocess_function, num_proc=4)
   ```

3. **텍스트 인코딩 문제**
   ```python
   def clean_text_encoding(text):
       """일반적인 인코딩 문제 정리"""
       # 일반적인 유니코드 문제 해결
       text = text.encode('utf-8', errors='ignore').decode('utf-8')
       # 문제가 되는 문자 제거 또는 교체
       text = re.sub(r'[^\w\s\.\,\!\?\;\:\-\(\)]', ' ', text)
       return text
   ```

### 모범 사례

1. **데이터 샘플링**: 데이터 구조를 이해하기 위해 항상 작은 샘플부터 시작
2. **품질 필터링**: 고품질 훈련 데이터를 보장하기 위해 여러 품질 필터 구현
3. **배치 처리**: 메모리 효율성을 위해 배치 처리 사용
4. **도메인별 추출**: 사용 사례와 관련된 특정 도메인에 맞게 필터링
5. **다국어 고려사항**: 처리 시 언어별 특성 인식

## 결론

FinePDFs는 PDF에서 추출된 고품질의 다국어 텍스트 콘텐츠에 대한 액세스를 제공하여 머신러닝 커뮤니티에 귀중한 자원을 제공합니다. 이 튜토리얼은 다음을 다루었습니다:

- 데이터셋 구조 로딩 및 탐색
- 품질 평가 및 필터링 구현
- 다양한 ML 애플리케이션을 위한 데이터 준비
- RAG 시스템 및 파인튜닝 워크플로우 설정
- 대규모 처리를 위한 성능 최적화

언어와 도메인의 다양성은 다음과 같은 용도에 특히 유용합니다:
- **언어 모델 훈련**: 다국어 모델의 사전 훈련 및 파인튜닝
- **도메인 적응**: 과학, 법률, 기술 도메인을 위한 모델 전문화
- **검색 시스템**: 종합적인 지식 베이스 구축
- **교차 언어 연구**: 다양한 언어 간의 언어학적 패턴 연구

이 대규모 데이터셋으로 작업할 때는 항상 ODC-By 라이선스 조건을 준수하고 계산 요구사항을 고려하는 것을 잊지 마세요.

## 추가 자료

- [FinePDFs 데이터셋 페이지](https://huggingface.co/datasets/HuggingFaceFW/finepdfs)
- [HuggingFace Datasets 문서](https://huggingface.co/docs/datasets/)
- [Transformers 라이브러리](https://huggingface.co/transformers/)
- [데이터셋 라이선스 정보](https://opendatacommons.org/licenses/by/1-0/)

---

*이 튜토리얼은 FinePDFs 작업을 위한 종합적인 시작점을 제공합니다. 특정 사용 사례를 개발할 때는 요구사항과 계산 제약에 맞게 이러한 예제를 조정하세요.*
