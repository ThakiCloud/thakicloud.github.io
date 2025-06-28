---
title: "Yandex Yambda: 50억 규모 음악 추천시스템 데이터셋 완전 가이드"
excerpt: "Yandex가 공개한 대규모 음악 청취 행동 데이터셋으로 추천시스템 연구의 새로운 표준을 제시하는 Yambda 완전 분석"
seo_title: "Yandex Yambda 음악 추천 데이터셋 완전 가이드 - 50억 청취 데이터 분석 - Thaki Cloud"
seo_description: "Yandex Yambda 음악 추천시스템 데이터셋 완전 가이드. 50억 청취 데이터, 오디오 임베딩, 사용자 행동 분석까지 상세 튜토리얼"
date: 2025-06-28
categories:
  - datasets
  - research
tags:
  - Yandex
  - Yambda
  - 음악추천
  - 추천시스템
  - HuggingFace
  - 오디오임베딩
  - 사용자행동
  - 빅데이터
  - 머신러닝
  - RecSys
author_profile: true
toc: true
toc_label: "Yambda 데이터셋 가이드"
canonical_url: "https://thakicloud.github.io/yandex-yambda-music-recommendation-dataset-guide/"
---

⏱️ **예상 읽기 시간**: 15분

음악 추천시스템 연구에 혁신을 가져올 대규모 데이터셋이 공개되었습니다. **Yandex Yambda**는 실제 음악 스트리밍 서비스에서 수집된 50억 개의 사용자 행동 데이터를 포함하며, 추천시스템 연구의 새로운 표준을 제시합니다. 이 가이드에서는 Yambda 데이터셋의 구조부터 실제 활용 방법까지 상세히 분석합니다.

## Yandex Yambda 데이터셋 개요

**Yambda**는 Yandex에서 공개한 대규모 음악 청취 행동 데이터셋으로, [Hugging Face](https://huggingface.co/datasets/yandex/yambda)에서 Apache 2.0 라이선스로 제공됩니다. 이 데이터셋은 추천시스템과 정보 검색 연구를 위해 특별히 설계되었습니다.

### 핵심 특징

- **규모**: 최대 50억 개의 사용자 상호작용 데이터
- **다양성**: 청취, 좋아요, 싫어요 등 다양한 행동 유형
- **실제성**: 실제 음악 스트리밍 서비스에서 수집
- **풍부함**: 오디오 임베딩과 메타데이터 포함
- **접근성**: Hugging Face를 통한 쉬운 다운로드

### 데이터셋 통계

| **항목** | **상세 정보** |
|----------|---------------|
| **총 행 수** | 5,313,905,900개 (53억 개) |
| **파일 크기** | 42.5GB (Parquet 형식) |
| **다운로드 수** | 50,131회 (지난 달) |
| **라이선스** | Apache 2.0 |
| **형식** | Parquet, Croissant |

## 데이터 구조 및 스키마

### 제공되는 데이터 유형

Yambda 데이터셋은 다음과 같은 여러 유형의 사용자 행동 데이터를 제공합니다:

| **파일명** | **설명** | **주요 필드** |
|------------|----------|---------------|
| `listens.parquet` | 음악 청취 이벤트 | uid, item_id, timestamp, played_ratio_pct, track_length_seconds |
| `likes.parquet` | 좋아요 액션 | uid, item_id, timestamp, is_organic |
| `dislikes.parquet` | 싫어요 액션 | uid, item_id, timestamp, is_organic |
| `undislikes.parquet` | 싫어요 취소 액션 | uid, item_id, timestamp, is_organic |
| `unlikes.parquet` | 좋아요 취소 액션 | uid, item_id, timestamp, is_organic |
| `embeddings.parquet` | 오디오 임베딩 | item_id, embed, normalized_embed |

### 공통 이벤트 구조

대부분의 이벤트 파일은 다음과 같은 공통 구조를 가집니다:

```python
{
    "uid": "uint32",           # 고유 사용자 식별자
    "item_id": "uint32",       # 고유 트랙 식별자  
    "timestamp": "uint32",     # 5초 단위로 양자화된 델타 시간
    "is_organic": "uint8"      # 알고리즘(0) vs 자연(1) 상호작용
}
```

### 통합 이벤트 구조

모든 이벤트 유형을 하나로 통합한 형식도 제공됩니다:

```python
{
    "uid": "uint32",
    "item_id": "uint32", 
    "timestamp": "uint32",
    "is_organic": "uint8",
    "event_type": "enum",      # listen, like, dislike, unlike, undislike
    "played_ratio_pct": "Optional[uint16]",    # 청취 이벤트만
    "track_length_seconds": "Optional[uint32]" # 청취 이벤트만
}
```

## 데이터셋 크기별 제공

### 선택 가능한 크기

Yambda는 연구 목적에 따라 세 가지 크기로 제공됩니다:

| **크기** | **행 수** | **용도** | **권장 대상** |
|----------|-----------|----------|---------------|
| **5M** | 47.8M | 빠른 프로토타이핑 | 개념 검증, 초기 실험 |
| **500M** | 480M | 중간 규모 연구 | 알고리즘 개발, 논문 실험 |
| **5B** | 4.79B | 대규모 벤치마크 | 프로덕션 평가, 최종 검증 |

### 데이터 형식

각 크기는 두 가지 형식으로 제공됩니다:

**1. Flat (평면) 형식**
```python
# 각 행이 하나의 이벤트
uid | timestamp | item_id | is_organic | event_type
10  | 3848010   | 6490652 | 0          | listen
10  | 3848650   | 686823  | 0          | listen
```

**2. Sequential (순차) 형식**
```python
# 사용자별로 집계된 형식
uid | item_ids           | timestamps      | is_organic
10  | [6490652, 686823] | [3848010, ...] | [0, 0]
```

## 실제 데이터 다운로드 및 사용

### 기본 다운로드

```python
from datasets import load_dataset

# 50M 크기의 좋아요 데이터 다운로드
ds = load_dataset("yandex/yambda", 
                  data_dir="flat/50m", 
                  data_files="likes.parquet")

print(f"데이터셋 크기: {len(ds['train'])} 행")
print(f"컬럼: {ds['train'].column_names}")
```

### 편의 래퍼 클래스 사용

```python
from typing import Literal
from datasets import Dataset, DatasetDict, load_dataset

class YambdaDataset:
    INTERACTIONS = frozenset([
        "likes", "listens", "multi_event", 
        "dislikes", "unlikes", "undislikes"
    ])

    def __init__(
        self,
        dataset_type: Literal["flat", "sequential"] = "flat",
        dataset_size: Literal["50m", "500m", "5b"] = "50m"
    ):
        self.dataset_type = dataset_type
        self.dataset_size = dataset_size

    def interaction(self, event_type: str) -> Dataset:
        return self._download(
            f"{self.dataset_type}/{self.dataset_size}", 
            event_type
        )

    def audio_embeddings(self) -> Dataset:
        return self._download("", "embeddings")

    @staticmethod
    def _download(data_dir: str, file: str) -> Dataset:
        data = load_dataset("yandex/yambda", 
                          data_dir=data_dir, 
                          data_files=f"{file}.parquet")
        return data["train"]

# 사용 예시
dataset = YambdaDataset("flat", "50m")
likes = dataset.interaction("likes")
listens = dataset.interaction("listens")
embeddings = dataset.audio_embeddings()

print(f"좋아요 데이터: {len(likes)} 행")
print(f"청취 데이터: {len(listens)} 행")
print(f"임베딩 데이터: {len(embeddings)} 행")
```

## 데이터 분석 및 시각화

### 사용자 행동 패턴 분석

```python
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# 청취 데이터 분석
listens_df = dataset.interaction("listens").to_pandas()

# 재생 비율 분포
plt.figure(figsize=(12, 4))

plt.subplot(1, 2, 1)
plt.hist(listens_df['played_ratio_pct'], bins=50, alpha=0.7)
plt.xlabel('재생 비율 (%)')
plt.ylabel('빈도')
plt.title('음악 재생 비율 분포')

# 트랙 길이 분포
plt.subplot(1, 2, 2)
plt.hist(listens_df['track_length_seconds'], bins=50, alpha=0.7)
plt.xlabel('트랙 길이 (초)')
plt.ylabel('빈도')
plt.title('트랙 길이 분포')

plt.tight_layout()
plt.show()

# 사용자별 상호작용 통계
user_stats = listens_df.groupby('uid').agg({
    'item_id': 'count',
    'played_ratio_pct': 'mean',
    'track_length_seconds': 'mean'
}).rename(columns={
    'item_id': 'total_listens',
    'played_ratio_pct': 'avg_play_ratio',
    'track_length_seconds': 'avg_track_length'
})

print("사용자별 청취 통계:")
print(user_stats.describe())
```

### Organic vs 알고리즘 추천 분석

```python
# 추천 유형별 분석
organic_analysis = listens_df.groupby('is_organic').agg({
    'played_ratio_pct': 'mean',
    'item_id': 'count'
}).round(2)

organic_analysis.index = ['알고리즘 추천', '자연 발견']
print("추천 유형별 청취 패턴:")
print(organic_analysis)

# 시간대별 청취 패턴
listens_df['hour'] = (listens_df['timestamp'] // 720) % 24  # 5초 단위를 시간으로 변환
hourly_listens = listens_df.groupby('hour')['item_id'].count()

plt.figure(figsize=(10, 6))
hourly_listens.plot(kind='bar')
plt.xlabel('시간 (24시간 형식)')
plt.ylabel('청취 횟수')
plt.title('시간대별 음악 청취 패턴')
plt.xticks(rotation=0)
plt.show()
```

## 오디오 임베딩 활용

### 임베딩 데이터 구조

```python
embeddings = dataset.audio_embeddings()
embedding_df = embeddings.to_pandas()

print(f"임베딩 차원: {len(embedding_df['embed'][0])}")
print(f"총 트랙 수: {len(embedding_df)}")

# 임베딩 벡터 정규화 확인
import numpy as np

sample_embed = np.array(embedding_df['embed'][0])
sample_normalized = np.array(embedding_df['normalized_embed'][0])

print(f"원본 임베딩 노름: {np.linalg.norm(sample_embed):.4f}")
print(f"정규화 임베딩 노름: {np.linalg.norm(sample_normalized):.4f}")
```

### 유사 음악 찾기

```python
from sklearn.metrics.pairwise import cosine_similarity
import numpy as np

def find_similar_tracks(target_item_id, embeddings_df, top_k=10):
    """주어진 트랙과 유사한 음악 찾기"""
    
    # 타겟 트랙의 임베딩 찾기
    target_row = embeddings_df[embeddings_df['item_id'] == target_item_id]
    if len(target_row) == 0:
        return []
    
    target_embed = np.array(target_row['normalized_embed'].iloc[0]).reshape(1, -1)
    
    # 모든 임베딩과 코사인 유사도 계산
    all_embeds = np.vstack(embeddings_df['normalized_embed'].values)
    similarities = cosine_similarity(target_embed, all_embeds)[0]
    
    # 유사도 순으로 정렬
    similar_indices = np.argsort(similarities)[::-1][1:top_k+1]  # 자기 자신 제외
    
    results = []
    for idx in similar_indices:
        results.append({
            'item_id': embeddings_df.iloc[idx]['item_id'],
            'similarity': similarities[idx]
        })
    
    return results

# 예시 사용
target_track = embedding_df['item_id'].iloc[0]
similar_tracks = find_similar_tracks(target_track, embedding_df)

print(f"트랙 {target_track}와 유사한 음악:")
for track in similar_tracks[:5]:
    print(f"- 트랙 {track['item_id']}: 유사도 {track['similarity']:.4f}")
```

## 추천시스템 벤치마크

### 협업 필터링 구현

```python
from scipy.sparse import csr_matrix
from sklearn.decomposition import TruncatedSVD

def build_user_item_matrix(listens_df, min_listens=5):
    """사용자-아이템 상호작용 매트릭스 구축"""
    
    # 충분히 들은 음악만 필터링 (재생률 50% 이상)
    listened_tracks = listens_df[listens_df['played_ratio_pct'] >= 50]
    
    # 사용자별 청취 횟수 계산
    user_item_counts = listened_tracks.groupby(['uid', 'item_id']).size().reset_index(name='count')
    
    # 최소 청취 횟수 필터링
    user_item_counts = user_item_counts[user_item_counts['count'] >= min_listens]
    
    # 희소 매트릭스 생성
    user_ids = user_item_counts['uid'].unique()
    item_ids = user_item_counts['item_id'].unique()
    
    user_to_idx = {uid: idx for idx, uid in enumerate(user_ids)}
    item_to_idx = {iid: idx for idx, iid in enumerate(item_ids)}
    
    rows = [user_to_idx[uid] for uid in user_item_counts['uid']]
    cols = [item_to_idx[iid] for iid in user_item_counts['item_id']]
    data = user_item_counts['count'].values
    
    matrix = csr_matrix((data, (rows, cols)), 
                       shape=(len(user_ids), len(item_ids)))
    
    return matrix, user_to_idx, item_to_idx

# 매트릭스 분해 모델 학습
user_item_matrix, user_idx, item_idx = build_user_item_matrix(listens_df)

print(f"사용자 수: {user_item_matrix.shape[0]}")
print(f"아이템 수: {user_item_matrix.shape[1]}")
print(f"희소성: {1 - user_item_matrix.nnz / (user_item_matrix.shape[0] * user_item_matrix.shape[1]):.4f}")

# SVD 분해
svd = TruncatedSVD(n_components=50, random_state=42)
user_factors = svd.fit_transform(user_item_matrix)
item_factors = svd.components_.T

print(f"설명 분산 비율: {svd.explained_variance_ratio_.sum():.4f}")
```

### 추천 성능 평가

```python
from sklearn.model_selection import train_test_split
from sklearn.metrics import precision_score, recall_score

def evaluate_recommendations(user_item_matrix, user_factors, item_factors, test_ratio=0.2):
    """추천 시스템 성능 평가"""
    
    # 훈련/테스트 분할
    train_matrix = user_item_matrix.copy()
    test_matrix = user_item_matrix.copy()
    
    # 각 사용자의 상호작용 중 일부를 테스트용으로 마스킹
    for user_idx in range(user_item_matrix.shape[0]):
        user_items = user_item_matrix[user_idx].nonzero()[1]
        if len(user_items) > 5:  # 충분한 상호작용이 있는 경우만
            n_test = max(1, int(len(user_items) * test_ratio))
            test_items = np.random.choice(user_items, n_test, replace=False)
            
            for item_idx in test_items:
                train_matrix[user_idx, item_idx] = 0
                test_matrix[user_idx, item_idx] = 1
            
            # 훈련 데이터에는 테스트 아이템 제거
            for item_idx in user_items:
                if item_idx not in test_items:
                    test_matrix[user_idx, item_idx] = 0
    
    # 추천 점수 계산
    predicted_scores = user_factors @ item_factors.T
    
    # Top-K 정밀도/재현율 계산
    k_values = [5, 10, 20]
    metrics = {}
    
    for k in k_values:
        precisions = []
        recalls = []
        
        for user_idx in range(user_item_matrix.shape[0]):
            # 사용자의 실제 테스트 아이템
            true_items = set(test_matrix[user_idx].nonzero()[1])
            
            if len(true_items) == 0:
                continue
            
            # Top-K 추천 아이템
            user_scores = predicted_scores[user_idx]
            # 이미 상호작용한 아이템 제외
            user_scores[train_matrix[user_idx].nonzero()[1]] = -np.inf
            
            top_k_items = set(np.argsort(user_scores)[::-1][:k])
            
            # 정밀도와 재현율 계산
            intersection = len(true_items & top_k_items)
            precision = intersection / k if k > 0 else 0
            recall = intersection / len(true_items) if len(true_items) > 0 else 0
            
            precisions.append(precision)
            recalls.append(recall)
        
        metrics[f'precision@{k}'] = np.mean(precisions)
        metrics[f'recall@{k}'] = np.mean(recalls)
    
    return metrics

# 성능 평가 실행
performance = evaluate_recommendations(user_item_matrix, user_factors, item_factors)

print("추천 시스템 성능:")
for metric, value in performance.items():
    print(f"{metric}: {value:.4f}")
```

## 연구 활용 방안

### 1. 음악 추천 알고리즘 개발

**혼합 추천 시스템**
```python
def hybrid_recommendation(user_id, user_factors, item_factors, 
                         embeddings_df, alpha=0.7):
    """협업 필터링 + 콘텐츠 기반 혼합 추천"""
    
    # 협업 필터링 점수
    cf_scores = user_factors[user_id] @ item_factors.T
    
    # 콘텐츠 기반 점수 (사용자가 들은 음악과 유사한 음악)
    user_items = user_item_matrix[user_id].nonzero()[1]
    if len(user_items) > 0:
        # 사용자 선호 음악의 평균 임베딩
        user_embeds = []
        for item_idx in user_items:
            item_id = list(item_idx.keys())[list(item_idx.values()).index(item_idx)]
            embed_row = embeddings_df[embeddings_df['item_id'] == item_id]
            if len(embed_row) > 0:
                user_embeds.append(embed_row['normalized_embed'].iloc[0])
        
        if user_embeds:
            user_profile = np.mean(user_embeds, axis=0)
            content_scores = cosine_similarity(
                [user_profile], 
                np.vstack(embeddings_df['normalized_embed'].values)
            )[0]
        else:
            content_scores = np.zeros(len(embeddings_df))
    else:
        content_scores = np.zeros(len(embeddings_df))
    
    # 가중 평균으로 최종 점수 계산
    final_scores = alpha * cf_scores + (1 - alpha) * content_scores
    
    return final_scores
```

### 2. 음악 발견 패턴 연구

**Organic vs 알고리즘 추천 효과 분석**
```python
def analyze_discovery_patterns(listens_df, likes_df):
    """음악 발견 패턴 분석"""
    
    # 추천 유형별 참여도 분석
    organic_engagement = listens_df[listens_df['is_organic'] == 1]['played_ratio_pct'].mean()
    algo_engagement = listens_df[listens_df['is_organic'] == 0]['played_ratio_pct'].mean()
    
    print(f"자연 발견 음악 참여도: {organic_engagement:.2f}%")
    print(f"알고리즘 추천 음악 참여도: {algo_engagement:.2f}%")
    
    # 좋아요로 이어지는 비율
    listen_like_conversion = pd.merge(
        listens_df, likes_df, 
        on=['uid', 'item_id'], 
        suffixes=('_listen', '_like')
    )
    
    organic_conversion = len(listen_like_conversion[
        listen_like_conversion['is_organic_listen'] == 1
    ]) / len(listens_df[listens_df['is_organic'] == 1])
    
    algo_conversion = len(listen_like_conversion[
        listen_like_conversion['is_organic_listen'] == 0
    ]) / len(listens_df[listens_df['is_organic'] == 0])
    
    print(f"자연 발견 → 좋아요 전환율: {organic_conversion:.4f}")
    print(f"알고리즘 추천 → 좋아요 전환율: {algo_conversion:.4f}")
    
    return {
        'organic_engagement': organic_engagement,
        'algo_engagement': algo_engagement,
        'organic_conversion': organic_conversion,
        'algo_conversion': algo_conversion
    }

discovery_stats = analyze_discovery_patterns(listens_df, likes_df)
```

### 3. 시간적 행동 패턴 분석

```python
def temporal_analysis(listens_df):
    """시간적 음악 청취 패턴 분석"""
    
    # 타임스탬프를 시간 단위로 변환
    listens_df['time_of_day'] = (listens_df['timestamp'] // 720) % 24
    listens_df['day_of_week'] = (listens_df['timestamp'] // (720 * 24)) % 7
    
    # 시간대별 선호 장르 분석 (트랙 길이로 추정)
    hourly_patterns = listens_df.groupby('time_of_day').agg({
        'track_length_seconds': 'mean',
        'played_ratio_pct': 'mean',
        'item_id': 'count'
    })
    
    # 주중/주말 패턴
    weekday_patterns = listens_df.groupby('day_of_week').agg({
        'track_length_seconds': 'mean',
        'played_ratio_pct': 'mean'
    })
    
    return hourly_patterns, weekday_patterns

hourly, weekday = temporal_analysis(listens_df)
print("시간대별 청취 패턴:")
print(hourly.head())
```

## 고급 분석 및 인사이트

### 사용자 세그멘테이션

```python
from sklearn.cluster import KMeans
from sklearn.preprocessing import StandardScaler

def user_segmentation(listens_df, likes_df, n_clusters=5):
    """사용자 행동 기반 세그멘테이션"""
    
    # 사용자별 특성 추출
    user_features = listens_df.groupby('uid').agg({
        'item_id': 'count',  # 총 청취 횟수
        'played_ratio_pct': 'mean',  # 평균 완료율
        'track_length_seconds': 'mean',  # 선호 트랙 길이
        'is_organic': 'mean'  # 자연 발견 비율
    }).rename(columns={
        'item_id': 'total_listens',
        'played_ratio_pct': 'avg_completion',
        'track_length_seconds': 'avg_track_length',
        'is_organic': 'organic_ratio'
    })
    
    # 좋아요 활동 추가
    like_counts = likes_df.groupby('uid').size().to_frame('total_likes')
    user_features = user_features.join(like_counts, how='left').fillna(0)
    
    # 참여도 점수 계산
    user_features['engagement_score'] = (
        user_features['avg_completion'] * 
        user_features['total_likes'] / user_features['total_listens']
    ).fillna(0)
    
    # 정규화 및 클러스터링
    scaler = StandardScaler()
    features_scaled = scaler.fit_transform(user_features)
    
    kmeans = KMeans(n_clusters=n_clusters, random_state=42)
    user_features['cluster'] = kmeans.fit_predict(features_scaled)
    
    # 클러스터별 특성 분석
    cluster_summary = user_features.groupby('cluster').mean()
    
    return user_features, cluster_summary

user_segments, cluster_info = user_segmentation(listens_df, likes_df)
print("사용자 클러스터 특성:")
print(cluster_info)
```

### 음악 트렌드 분석

```python
def music_trend_analysis(listens_df, window_size=7):
    """음악 인기도 트렌드 분석"""
    
    # 시간 윈도우별 트랙 인기도 계산
    listens_df['time_window'] = listens_df['timestamp'] // (720 * 24 * window_size)
    
    # 트랙별 주간 청취 수
    track_popularity = listens_df.groupby(['time_window', 'item_id']).agg({
        'uid': 'count',  # 청취자 수
        'played_ratio_pct': 'mean'  # 평균 완료율
    }).rename(columns={'uid': 'listener_count'})
    
    # 버즈 트랙 식별 (급격한 인기 상승)
    buzz_tracks = []
    for item_id in track_popularity.index.get_level_values('item_id').unique():
        item_data = track_popularity.xs(item_id, level='item_id')
        if len(item_data) >= 2:
            # 이전 대비 증가율 계산
            item_data['growth_rate'] = item_data['listener_count'].pct_change()
            max_growth = item_data['growth_rate'].max()
            
            if max_growth > 2.0:  # 200% 이상 증가
                buzz_tracks.append({
                    'item_id': item_id,
                    'max_growth': max_growth,
                    'peak_listeners': item_data['listener_count'].max()
                })
    
    return track_popularity, buzz_tracks

popularity_trends, viral_tracks = music_trend_analysis(listens_df)
print(f"바이럴 트랙 발견: {len(viral_tracks)}개")
if viral_tracks:
    top_viral = sorted(viral_tracks, key=lambda x: x['max_growth'], reverse=True)[:5]
    for track in top_viral:
        print(f"트랙 {track['item_id']}: {track['max_growth']:.1f}x 성장")
```

## 성능 최적화 및 대용량 처리

### 청크 단위 처리

```python
def process_large_dataset(dataset_size="5b", chunk_size=1000000):
    """대용량 데이터셋 청크 단위 처리"""
    
    dataset = YambdaDataset("flat", dataset_size)
    listens = dataset.interaction("listens")
    
    # 청크별 통계 계산
    total_rows = len(listens)
    chunk_stats = []
    
    for i in range(0, total_rows, chunk_size):
        chunk = listens.select(range(i, min(i + chunk_size, total_rows)))
        chunk_df = chunk.to_pandas()
        
        stats = {
            'chunk_id': i // chunk_size,
            'avg_play_ratio': chunk_df['played_ratio_pct'].mean(),
            'total_listens': len(chunk_df),
            'unique_users': chunk_df['uid'].nunique(),
            'unique_tracks': chunk_df['item_id'].nunique()
        }
        chunk_stats.append(stats)
        
        if i % (chunk_size * 10) == 0:
            print(f"처리 완료: {i:,} / {total_rows:,} 행")
    
    return pd.DataFrame(chunk_stats)

# 큰 데이터셋 처리 예시
# chunk_results = process_large_dataset("500m", chunk_size=500000)
```

### 메모리 효율적 분석

```python
import dask.dataframe as dd

def memory_efficient_analysis(dataset_size="500m"):
    """Dask를 사용한 메모리 효율적 분석"""
    
    dataset = YambdaDataset("flat", dataset_size)
    listens = dataset.interaction("listens")
    
    # Dask DataFrame으로 변환
    df = dd.from_pandas(listens.to_pandas(), npartitions=10)
    
    # 지연 계산으로 집계
    user_stats = df.groupby('uid').agg({
        'item_id': 'count',
        'played_ratio_pct': 'mean'
    }).compute()
    
    track_stats = df.groupby('item_id').agg({
        'uid': 'count',
        'played_ratio_pct': 'mean'
    }).compute()
    
    return user_stats, track_stats

# user_analysis, track_analysis = memory_efficient_analysis("500m")
```

## 연구 논문 및 벤치마크

### 관련 연구

Yambda 데이터셋은 다음과 같은 연구 영역에서 활용할 수 있습니다:

**1. 추천시스템 알고리즘**
- 협업 필터링 개선
- 딥러닝 기반 추천
- 실시간 추천 시스템

**2. 음악 정보 검색**
- 오디오 임베딩 학습
- 음악 유사도 측정
- 장르 분류

**3. 사용자 행동 분석**
- 청취 패턴 모델링
- 참여도 예측
- 이탈 방지

### 논문 인용

```bibtex
@article{yambda2025,
    title={Yambda: Large-Scale Music Recommendation Dataset},
    author={Yandex Research Team},
    journal={arXiv preprint arXiv:2505.22238},
    year={2025}
}
```

## 결론

Yandex Yambda는 음악 추천시스템 연구를 위한 가장 대규모이고 포괄적인 데이터셋 중 하나입니다. 50억 개의 실제 사용자 상호작용 데이터와 고품질 오디오 임베딩을 통해 연구자들은 다음과 같은 혁신을 이룰 수 있습니다:

### 핵심 가치

- **규모의 현실성**: 실제 서비스 환경에서 수집된 대규모 데이터
- **다양성**: 청취, 좋아요, 싫어요 등 풍부한 행동 유형
- **시간성**: 시간에 따른 선호 변화 추적 가능
- **접근성**: Hugging Face를 통한 쉬운 다운로드와 활용

### 활용 분야

1. **추천 알고리즘 개발**: 차세대 음악 추천 시스템
2. **사용자 분석**: 청취 행동 패턴과 선호도 연구
3. **콘텐츠 분석**: 오디오 임베딩을 통한 음악 특성 연구
4. **산업 응용**: 실제 음악 플랫폼의 추천 성능 개선

### 시작하기

```python
# 간단한 시작
from datasets import load_dataset

ds = load_dataset("yandex/yambda", 
                  data_dir="flat/50m", 
                  data_files="listens.parquet")

print("Yambda 데이터셋으로 음악 추천 연구를 시작하세요!")
```

음악 추천의 미래를 만들어갈 연구에 Yandex Yambda가 강력한 기반이 되어줄 것입니다.

**참고 자료**:
- [Yambda 데이터셋 페이지](https://huggingface.co/datasets/yandex/yambda)
- [ArXiv 논문](https://arxiv.org/abs/2505.22238)
- [Hugging Face Datasets 라이브러리](https://huggingface.co/docs/datasets/) 