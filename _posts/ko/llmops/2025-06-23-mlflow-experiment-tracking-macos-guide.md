---
title: "맥북에서 MLflow로 모델 실험 추적하기 - FAIR 원칙 기반 개인 MLOps 가이드"
excerpt: "MLflow와 FAIR 원칙을 활용하여 맥북에서 개인 머신러닝 실험을 체계적으로 관리하고 추적하는 방법을 알아봅니다."
date: 2025-06-23
categories: 
  - llmops
  - dev
tags: 
  - mlflow
  - experiment-tracking
  - fair-principles
  - macos
  - machine-learning
  - mlops
author_profile: true
toc: true
toc_label: "목차"
---

## 개요

머신러닝 프로젝트에서 가장 중요한 것은 **실험의 재현성과 추적성**입니다. 특히 개인 연구자나 개발자라면 다양한 하이퍼파라미터 조합, 데이터 전처리 방법, 모델 아키텍처를 시도하면서 어떤 실험이 최고 성능을 보였는지 체계적으로 관리해야 합니다.

이 글에서는 [FAIR 원칙](https://doi.org/10.5334/dsj-2024-055)을 기반으로 MLflow를 활용하여 맥북에서 개인 머신러닝 실험을 체계적으로 추적하고 관리하는 방법을 소개합니다.

## FAIR 원칙과 머신러닝 실험 관리

FAIR 원칙은 과학 데이터 관리의 핵심 가이드라인으로, 머신러닝 아티팩트에도 적용할 수 있습니다:

- **Findable**: 실험과 모델을 쉽게 찾을 수 있어야 함
- **Accessible**: 실험 결과에 접근할 수 있어야 함  
- **Interoperable**: 다른 시스템과 호환되어야 함
- **Reusable**: 재사용 가능해야 함

MLflow는 이러한 FAIR 원칙을 실현하는 데 도움이 되는 오픈소스 플랫폼입니다.

## MLflow 설치 및 설정

### 1. 환경 준비

먼저 Python 가상환경을 생성하고 MLflow를 설치합니다:

```bash
# 가상환경 생성
python3 -m venv mlflow_env
source mlflow_env/bin/activate

# MLflow 설치
pip install mlflow

# 추가 의존성 설치
pip install pandas scikit-learn matplotlib seaborn plotly
```

### 2. MLflow 서버 시작

```bash
# MLflow UI 서버 시작 (기본 포트 5000)
mlflow ui --host 0.0.0.0 --port 5000
```

브라우저에서 `http://localhost:5000`으로 접속하면 MLflow UI를 확인할 수 있습니다.

## 실험 추적 예제: 주택 가격 예측 모델

### 1. 기본 실험 구조

```python
import mlflow
import mlflow.sklearn
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# MLflow 실험 설정
mlflow.set_experiment("housing_price_prediction")

# 샘플 데이터 생성
np.random.seed(42)
n_samples = 1000
data = {
    'area': np.random.normal(1500, 500, n_samples),
    'bedrooms': np.random.randint(1, 6, n_samples),
    'bathrooms': np.random.randint(1, 4, n_samples),
    'age': np.random.randint(0, 50, n_samples),
    'distance_to_city': np.random.normal(10, 5, n_samples)
}

df = pd.DataFrame(data)
# 가격 계산 (노이즈 포함)
df['price'] = (df['area'] * 100 + 
               df['bedrooms'] * 50000 + 
               df['bathrooms'] * 30000 - 
               df['age'] * 2000 - 
               df['distance_to_city'] * 5000 + 
               np.random.normal(0, 50000, n_samples))

# 특성과 타겟 분리
X = df.drop('price', axis=1)
y = df['price']

# 데이터 분할
X_train, X_test, y_train, y_test = train_test_split(
    X, y, test_size=0.2, random_state=42
)
```

### 2. 실험 실행 및 추적

```python
def run_experiment(n_estimators, max_depth, min_samples_split):
    """실험을 실행하고 MLflow로 추적"""
    
    with mlflow.start_run():
        # 하이퍼파라미터 로깅
        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_param("max_depth", max_depth)
        mlflow.log_param("min_samples_split", min_samples_split)
        
        # 모델 훈련
        model = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=max_depth,
            min_samples_split=min_samples_split,
            random_state=42
        )
        
        model.fit(X_train, y_train)
        
        # 예측
        y_pred = model.predict(X_test)
        
        # 메트릭 계산
        mse = mean_squared_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        rmse = np.sqrt(mse)
        
        # 메트릭 로깅
        mlflow.log_metric("mse", mse)
        mlflow.log_metric("r2_score", r2)
        mlflow.log_metric("rmse", rmse)
        
        # 모델 저장
        mlflow.sklearn.log_model(model, "model")
        
        # 특성 중요도 시각화
        feature_importance = pd.DataFrame({
            'feature': X.columns,
            'importance': model.feature_importances_
        }).sort_values('importance', ascending=False)
        
        plt.figure(figsize=(10, 6))
        plt.bar(feature_importance['feature'], feature_importance['importance'])
        plt.title('Feature Importance')
        plt.xticks(rotation=45)
        plt.tight_layout()
        
        # 시각화 저장 및 로깅
        plt.savefig('feature_importance.png')
        mlflow.log_artifact('feature_importance.png')
        plt.close()
        
        # 예측 vs 실제 값 시각화
        plt.figure(figsize=(10, 6))
        plt.scatter(y_test, y_pred, alpha=0.5)
        plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
        plt.xlabel('Actual Price')
        plt.ylabel('Predicted Price')
        plt.title('Predicted vs Actual House Prices')
        plt.tight_layout()
        
        plt.savefig('prediction_plot.png')
        mlflow.log_artifact('prediction_plot.png')
        plt.close()
        
        print(f"Run completed - R²: {r2:.4f}, RMSE: {rmse:.2f}")
        
        return model, r2, rmse

# 다양한 하이퍼파라미터로 실험 실행
experiments = [
    (100, 10, 2),
    (200, 15, 5),
    (150, 12, 3),
    (300, 20, 2),
    (100, 8, 10)
]

results = []
for n_est, max_dep, min_split in experiments:
    model, r2, rmse = run_experiment(n_est, max_dep, min_split)
    results.append({
        'n_estimators': n_est,
        'max_depth': max_dep,
        'min_samples_split': min_split,
        'r2_score': r2,
        'rmse': rmse
    })

# 결과 요약
results_df = pd.DataFrame(results)
print("\n실험 결과 요약:")
print(results_df.sort_values('r2_score', ascending=False))
```

### 3. 실험 비교 및 분석

```python
# MLflow에서 최고 성능 모델 로드
best_run = mlflow.search_runs(
    experiment_names=["housing_price_prediction"],
    order_by=["metrics.r2_score DESC"]
).iloc[0]

print(f"최고 성능 실험 ID: {best_run['run_id']}")
print(f"최고 R² 점수: {best_run['metrics.r2_score']:.4f}")

# 최고 성능 모델 로드
best_model = mlflow.sklearn.load_model(f"runs:/{best_run['run_id']}/model")

# 새로운 데이터로 예측
new_data = pd.DataFrame({
    'area': [2000],
    'bedrooms': [3],
    'bathrooms': [2],
    'age': [5],
    'distance_to_city': [8]
})

prediction = best_model.predict(new_data)[0]
print(f"예측 주택 가격: ${prediction:,.2f}")
```

## 고급 실험 관리 기능

### 1. 실험 태깅 및 메타데이터

```python
def run_experiment_with_tags(n_estimators, max_depth, min_samples_split, experiment_name):
    """태그와 메타데이터가 포함된 실험 실행"""
    
    with mlflow.start_run(run_name=experiment_name):
        # 태그 추가
        mlflow.set_tag("model_type", "RandomForest")
        mlflow.set_tag("dataset", "housing_price")
        mlflow.set_tag("preprocessing", "standard_scaling")
        mlflow.set_tag("author", "개발자명")
        
        # 하이퍼파라미터 로깅
        params = {
            "n_estimators": n_estimators,
            "max_depth": max_depth,
            "min_samples_split": min_samples_split
        }
        mlflow.log_params(params)
        
        # 모델 훈련 및 평가 (이전과 동일)
        # ... (이전 코드와 동일)
        
        # 추가 메타데이터 로깅
        mlflow.log_dict({
            "data_info": {
                "n_samples": len(X_train),
                "n_features": X_train.shape[1],
                "test_size": 0.2
            }
        }, "metadata.json")
```

### 2. 실험 비교 시각화

```python
import plotly.graph_objects as go
from plotly.subplots import make_subplots

def compare_experiments():
    """여러 실험 결과를 시각적으로 비교"""
    
    # 모든 실험 결과 가져오기
    runs = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        order_by=["start_time DESC"]
    )
    
    # 비교 차트 생성
    fig = make_subplots(
        rows=2, cols=2,
        subplot_titles=('R² Score 비교', 'RMSE 비교', '하이퍼파라미터 비교', '실험 타임라인'),
        specs=[[{"secondary_y": False}, {"secondary_y": False}],
               [{"secondary_y": False}, {"secondary_y": False}]]
    )
    
    # R² Score 비교
    fig.add_trace(
        go.Bar(x=runs['run_id'], y=runs['metrics.r2_score'], name='R² Score'),
        row=1, col=1
    )
    
    # RMSE 비교
    fig.add_trace(
        go.Bar(x=runs['run_id'], y=runs['metrics.rmse'], name='RMSE'),
        row=1, col=2
    )
    
    # 하이퍼파라미터 비교
    fig.add_trace(
        go.Scatter(x=runs['params.n_estimators'], 
                  y=runs['metrics.r2_score'], 
                  mode='markers', name='n_estimators vs R²'),
        row=2, col=1
    )
    
    fig.update_layout(height=800, title_text="실험 결과 비교")
    fig.show()
    
    # HTML 파일로 저장
    fig.write_html("experiment_comparison.html")
    mlflow.log_artifact("experiment_comparison.html")

# 실험 비교 실행
compare_experiments()
```

## FAIR 원칙 구현을 위한 모범 사례

### 1. 실험 문서화

```python
def log_experiment_documentation():
    """실험 문서화 및 로깅"""
    
    with mlflow.start_run(run_name="documentation_example"):
        # 실험 목적 및 방법론 문서화
        experiment_description = """
        # 주택 가격 예측 실험
        
        ## 목적
        다양한 하이퍼파라미터 조합으로 RandomForest 모델의 성능을 비교 분석
        
        ## 데이터
        - 샘플 크기: 1000개
        - 특성: 면적, 침실 수, 욕실 수, 건축 연도, 도시까지 거리
        - 전처리: 표준화 없음 (RandomForest는 스케일 불변)
        
        ## 평가 지표
        - R² Score: 모델 설명력
        - RMSE: 예측 오차
        - MSE: 평균 제곱 오차
        
        ## 하이퍼파라미터
        - n_estimators: 트리 개수
        - max_depth: 최대 깊이
        - min_samples_split: 분할 최소 샘플 수
        """
        
        # 문서 저장
        with open("experiment_description.md", "w") as f:
            f.write(experiment_description)
        
        mlflow.log_artifact("experiment_description.md")
        
        # 데이터 스키마 정보
        data_schema = {
            "features": list(X.columns),
            "target": "price",
            "data_types": X.dtypes.to_dict(),
            "missing_values": X.isnull().sum().to_dict()
        }
        
        mlflow.log_dict(data_schema, "data_schema.json")
```

### 2. 모델 버전 관리

```python
def register_best_model():
    """최고 성능 모델을 모델 레지스트리에 등록"""
    
    # 최고 성능 실험 찾기
    best_run = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        order_by=["metrics.r2_score DESC"]
    ).iloc[0]
    
    # 모델 등록
    model_name = "housing_price_predictor"
    model_version = mlflow.register_model(
        f"runs:/{best_run['run_id']}/model",
        model_name
    )
    
    print(f"모델이 등록되었습니다: {model_name} v{model_version.version}")
    
    # 모델 메타데이터 추가
    client = mlflow.tracking.MlflowClient()
    client.update_registered_model(
        name=model_name,
        description="주택 가격 예측을 위한 RandomForest 모델"
    )
    
    # 모델 태그 추가
    client.set_registered_model_tag(
        name=model_name,
        key="best_r2_score",
        value=str(best_run['metrics.r2_score'])
    )
    
    return model_version
```

## 실용적인 워크플로우

### 1. 일일 실험 관리 스크립트

```python
#!/usr/bin/env python3
"""
일일 실험 관리 스크립트
"""

import mlflow
import pandas as pd
from datetime import datetime
import os

def daily_experiment_summary():
    """일일 실험 요약 생성"""
    
    # 오늘 날짜의 실험들 가져오기
    today = datetime.now().strftime("%Y-%m-%d")
    
    runs = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        filter_string=f"start_time >= '{today}'"
    )
    
    if len(runs) > 0:
        summary = {
            "date": today,
            "total_experiments": len(runs),
            "best_r2_score": runs['metrics.r2_score'].max(),
            "best_rmse": runs['metrics.rmse'].min(),
            "experiments": []
        }
        
        for _, run in runs.iterrows():
            summary["experiments"].append({
                "run_id": run['run_id'],
                "r2_score": run['metrics.r2_score'],
                "rmse": run['metrics.rmse'],
                "params": {
                    "n_estimators": run['params.n_estimators'],
                    "max_depth": run['params.max_depth'],
                    "min_samples_split": run['params.min_samples_split']
                }
            })
        
        # 요약 저장
        summary_df = pd.DataFrame(summary["experiments"])
        summary_df.to_csv(f"daily_summary_{today}.csv", index=False)
        
        print(f"오늘 {len(runs)}개의 실험을 완료했습니다.")
        print(f"최고 R² 점수: {summary['best_r2_score']:.4f}")
        print(f"최저 RMSE: {summary['best_rmse']:.2f}")
        
        return summary
    else:
        print("오늘 완료된 실험이 없습니다.")
        return None

if __name__ == "__main__":
    daily_experiment_summary()
```

### 2. 실험 백업 및 공유

```python
def backup_experiments():
    """실험 결과 백업"""
    
    # 실험 내보내기
    mlflow.export_import.export_experiment(
        experiment_id=mlflow.get_experiment_by_name("housing_price_prediction").experiment_id,
        output_dir="./experiment_backup"
    )
    
    print("실험 백업이 완료되었습니다: ./experiment_backup")

def share_experiment_results():
    """실험 결과 공유용 리포트 생성"""
    
    # 최고 성능 실험들 가져오기
    top_runs = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        order_by=["metrics.r2_score DESC"],
        max_results=5
    )
    
    # HTML 리포트 생성
    html_report = """
    <html>
    <head>
        <title>주택 가격 예측 실험 결과</title>
        <style>
            body { font-family: Arial, sans-serif; margin: 20px; }
            table { border-collapse: collapse; width: 100%; }
            th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }
            th { background-color: #f2f2f2; }
        </style>
    </head>
    <body>
        <h1>주택 가격 예측 실험 결과</h1>
        <table>
            <tr>
                <th>실험 ID</th>
                <th>R² Score</th>
                <th>RMSE</th>
                <th>n_estimators</th>
                <th>max_depth</th>
                <th>min_samples_split</th>
            </tr>
    """
    
    for _, run in top_runs.iterrows():
        html_report += f"""
            <tr>
                <td>{run['run_id'][:8]}...</td>
                <td>{run['metrics.r2_score']:.4f}</td>
                <td>{run['metrics.rmse']:.2f}</td>
                <td>{run['params.n_estimators']}</td>
                <td>{run['params.max_depth']}</td>
                <td>{run['params.min_samples_split']}</td>
            </tr>
        """
    
    html_report += """
        </table>
    </body>
    </html>
    """
    
    with open("experiment_report.html", "w") as f:
        f.write(html_report)
    
    print("실험 리포트가 생성되었습니다: experiment_report.html")
```

## 완전한 실행 예제

다음은 위의 모든 기능을 포함한 완전한 실행 예제입니다:

```python
# complete_example.py
import mlflow
import mlflow.sklearn
import pandas as pd
import numpy as np
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score
import matplotlib.pyplot as plt
import plotly.graph_objects as go
from plotly.subplots import make_subplots
from datetime import datetime

def main():
    """완전한 MLflow 실험 예제"""
    
    # MLflow 실험 설정
    mlflow.set_experiment("housing_price_prediction")
    
    # 데이터 생성
    X_train, X_test, y_train, y_test = create_sample_data()
    
    # 실험 실행
    experiments = [
        (100, 10, 2),
        (200, 15, 5),
        (150, 12, 3),
        (300, 20, 2),
        (100, 8, 10)
    ]
    
    for n_est, max_dep, min_split in experiments:
        run_experiment(X_train, X_test, y_train, y_test, n_est, max_dep, min_split)
    
    # 최고 성능 모델 찾기
    best_run = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        order_by=["metrics.r2_score DESC"]
    ).iloc[0]
    
    print(f"최고 성능 실험 ID: {best_run['run_id']}")
    print(f"최고 R² 점수: {best_run['metrics.r2_score']:.4f}")
    
    # 모델 등록
    model_name = "housing_price_predictor"
    model_version = mlflow.register_model(
        f"runs:/{best_run['run_id']}/model",
        model_name
    )
    
    print(f"모델이 등록되었습니다: {model_name} v{model_version.version}")

def create_sample_data():
    """샘플 주택 가격 데이터 생성"""
    
    np.random.seed(42)
    n_samples = 1000
    
    data = {
        'area': np.random.normal(1500, 500, n_samples),
        'bedrooms': np.random.randint(1, 6, n_samples),
        'bathrooms': np.random.randint(1, 4, n_samples),
        'age': np.random.randint(0, 50, n_samples),
        'distance_to_city': np.random.normal(10, 5, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # 가격 계산 (노이즈 포함)
    df['price'] = (df['area'] * 100 + 
                   df['bedrooms'] * 50000 + 
                   df['bathrooms'] * 30000 - 
                   df['age'] * 2000 - 
                   df['distance_to_city'] * 5000 + 
                   np.random.normal(0, 50000, n_samples))
    
    X = df.drop('price', axis=1)
    y = df['price']
    
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42
    )
    
    return X_train, X_test, y_train, y_test

def run_experiment(X_train, X_test, y_train, y_test, n_estimators, max_depth, min_samples_split):
    """실험 실행 함수"""
    
    with mlflow.start_run():
        # 태그 설정
        mlflow.set_tag("model_type", "RandomForest")
        mlflow.set_tag("dataset", "housing_price")
        mlflow.set_tag("author", "개발자명")
        
        # 하이퍼파라미터 로깅
        mlflow.log_param("n_estimators", n_estimators)
        mlflow.log_param("max_depth", max_depth)
        mlflow.log_param("min_samples_split", min_samples_split)
        
        # 모델 훈련
        model = RandomForestRegressor(
            n_estimators=n_estimators,
            max_depth=max_depth,
            min_samples_split=min_samples_split,
            random_state=42
        )
        
        model.fit(X_train, y_train)
        y_pred = model.predict(X_test)
        
        # 메트릭 계산 및 로깅
        mse = mean_squared_error(y_test, y_pred)
        r2 = r2_score(y_test, y_pred)
        rmse = np.sqrt(mse)
        
        mlflow.log_metric("mse", mse)
        mlflow.log_metric("r2_score", r2)
        mlflow.log_metric("rmse", rmse)
        
        # 모델 저장
        mlflow.sklearn.log_model(model, "model")
        
        # 시각화 생성 및 로깅
        create_visualizations(model, X_test, y_test, y_pred, X_train.columns)
        
        print(f"실험 완료 - R²: {r2:.4f}, RMSE: {rmse:.2f}")

def create_visualizations(model, X_test, y_test, y_pred, feature_names):
    """시각화 생성 및 로깅"""
    
    # 특성 중요도
    feature_importance = pd.DataFrame({
        'feature': feature_names,
        'importance': model.feature_importances_
    }).sort_values('importance', ascending=False)
    
    plt.figure(figsize=(10, 6))
    plt.bar(feature_importance['feature'], feature_importance['importance'])
    plt.title('Feature Importance')
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.savefig('feature_importance.png')
    mlflow.log_artifact('feature_importance.png')
    plt.close()
    
    # 예측 vs 실제
    plt.figure(figsize=(10, 6))
    plt.scatter(y_test, y_pred, alpha=0.5)
    plt.plot([y_test.min(), y_test.max()], [y_test.min(), y_test.max()], 'r--', lw=2)
    plt.xlabel('Actual Price')
    plt.ylabel('Predicted Price')
    plt.title('Predicted vs Actual House Prices')
    plt.tight_layout()
    plt.savefig('prediction_plot.png')
    mlflow.log_artifact('prediction_plot.png')
    plt.close()

if __name__ == "__main__":
    main()
```

## 실행 방법

1. **환경 설정**:
```bash
# 가상환경 생성 및 활성화
python3 -m venv mlflow_env
source mlflow_env/bin/activate

# 의존성 설치
pip install mlflow pandas scikit-learn matplotlib plotly
```

2. **MLflow 서버 시작**:
```bash
mlflow ui --host 0.0.0.0 --port 5000
```

3. **실험 실행**:
```bash
python complete_example.py
```

4. **결과 확인**:
브라우저에서 `http://localhost:5000`으로 접속하여 실험 결과를 확인합니다.

## 고급 기능 및 팁

### 1. 하이퍼파라미터 튜닝 자동화

```python
from sklearn.model_selection import GridSearchCV
import mlflow.sklearn

def automated_hyperparameter_tuning():
    """GridSearchCV를 활용한 자동 하이퍼파라미터 튜닝"""
    
    with mlflow.start_run(run_name="automated_tuning"):
        # 그리드 서치 파라미터 정의
        param_grid = {
            'n_estimators': [100, 200, 300],
            'max_depth': [10, 15, 20, None],
            'min_samples_split': [2, 5, 10],
            'min_samples_leaf': [1, 2, 4]
        }
        
        # 기본 모델
        base_model = RandomForestRegressor(random_state=42)
        
        # GridSearchCV 설정
        grid_search = GridSearchCV(
            estimator=base_model,
            param_grid=param_grid,
            cv=5,
            scoring='r2',
            n_jobs=-1,
            verbose=1
        )
        
        # 그리드 서치 실행
        grid_search.fit(X_train, y_train)
        
        # 최고 성능 모델
        best_model = grid_search.best_estimator_
        
        # 예측 및 평가
        y_pred = best_model.predict(X_test)
        r2 = r2_score(y_test, y_pred)
        rmse = np.sqrt(mean_squared_error(y_test, y_pred))
        
        # MLflow에 로깅
        mlflow.log_params(grid_search.best_params_)
        mlflow.log_metric("best_r2_score", r2)
        mlflow.log_metric("best_rmse", rmse)
        mlflow.log_metric("cv_best_score", grid_search.best_score_)
        
        # 모델 저장
        mlflow.sklearn.log_model(best_model, "best_model")
        
        print(f"최고 성능 모델 - R²: {r2:.4f}, RMSE: {rmse:.2f}")
        print(f"최적 하이퍼파라미터: {grid_search.best_params_}")
        
        return best_model, grid_search.best_params_
```

### 2. 실험 결과 분석 및 리포트 생성

```python
import seaborn as sns
from datetime import datetime, timedelta

def generate_experiment_report():
    """실험 결과 분석 및 리포트 생성"""
    
    # 최근 7일간의 실험 결과 가져오기
    week_ago = (datetime.now() - timedelta(days=7)).strftime("%Y-%m-%d")
    
    runs = mlflow.search_runs(
        experiment_names=["housing_price_prediction"],
        filter_string=f"start_time >= '{week_ago}'"
    )
    
    if len(runs) == 0:
        print("분석할 실험이 없습니다.")
        return
    
    # 성능 트렌드 분석
    plt.figure(figsize=(15, 10))
    
    # R² Score 트렌드
    plt.subplot(2, 2, 1)
    plt.plot(runs['start_time'], runs['metrics.r2_score'], 'o-')
    plt.title('R² Score Trend')
    plt.xlabel('Date')
    plt.ylabel('R² Score')
    plt.xticks(rotation=45)
    
    # RMSE 트렌드
    plt.subplot(2, 2, 2)
    plt.plot(runs['start_time'], runs['metrics.rmse'], 'o-', color='red')
    plt.title('RMSE Trend')
    plt.xlabel('Date')
    plt.ylabel('RMSE')
    plt.xticks(rotation=45)
    
    # 하이퍼파라미터 분포
    plt.subplot(2, 2, 3)
    plt.scatter(runs['params.n_estimators'], runs['metrics.r2_score'], 
               c=runs['params.max_depth'], cmap='viridis', s=100)
    plt.colorbar(label='max_depth')
    plt.xlabel('n_estimators')
    plt.ylabel('R² Score')
    plt.title('Hyperparameter Impact')
    
    # 성능 분포
    plt.subplot(2, 2, 4)
    plt.hist(runs['metrics.r2_score'], bins=10, alpha=0.7, color='skyblue')
    plt.xlabel('R² Score')
    plt.ylabel('Frequency')
    plt.title('Performance Distribution')
    
    plt.tight_layout()
    plt.savefig('experiment_analysis.png', dpi=300, bbox_inches='tight')
    
    # MLflow에 로깅
    with mlflow.start_run(run_name="experiment_analysis"):
        mlflow.log_artifact('experiment_analysis.png')
        
        # 통계 요약
        summary_stats = {
            "total_experiments": len(runs),
            "avg_r2_score": runs['metrics.r2_score'].mean(),
            "best_r2_score": runs['metrics.r2_score'].max(),
            "std_r2_score": runs['metrics.r2_score'].std(),
            "avg_rmse": runs['metrics.rmse'].mean(),
            "best_rmse": runs['metrics.rmse'].min()
        }
        
        mlflow.log_dict(summary_stats, "summary_stats.json")
        
        print("실험 분석 리포트가 생성되었습니다.")
        print(f"총 실험 수: {summary_stats['total_experiments']}")
        print(f"평균 R² 점수: {summary_stats['avg_r2_score']:.4f}")
        print(f"최고 R² 점수: {summary_stats['best_r2_score']:.4f}")
```

### 3. 모델 성능 모니터링

```python
def monitor_model_performance(model_name, version):
    """등록된 모델의 성능 모니터링"""
    
    client = mlflow.tracking.MlflowClient()
    
    # 모델 로드
    model_uri = f"models:/{model_name}/{version}"
    model = mlflow.sklearn.load_model(model_uri)
    
    # 새로운 테스트 데이터로 성능 평가
    # (실제 환경에서는 새로운 데이터를 수집하여 사용)
    X_new, y_new = create_new_test_data()
    
    # 예측
    y_pred_new = model.predict(X_new)
    
    # 성능 계산
    r2_new = r2_score(y_new, y_pred_new)
    rmse_new = np.sqrt(mean_squared_error(y_new, y_pred_new))
    
    # 성능 변화 추적
    with mlflow.start_run(run_name=f"performance_monitoring_{model_name}_v{version}"):
        mlflow.log_metric("current_r2_score", r2_new)
        mlflow.log_metric("current_rmse", rmse_new)
        mlflow.log_param("model_name", model_name)
        mlflow.log_param("model_version", version)
        
        # 성능 저하 감지
        if r2_new < 0.8:  # 임계값 설정
            mlflow.set_tag("performance_alert", "R² score below threshold")
            print(f"성능 저하 감지: R² = {r2_new:.4f}")
        
        # 성능 리포트 생성
        performance_report = {
            "model_name": model_name,
            "version": version,
            "evaluation_date": datetime.now().isoformat(),
            "current_r2_score": r2_new,
            "current_rmse": rmse_new,
            "data_samples": len(X_new)
        }
        
        mlflow.log_dict(performance_report, "performance_report.json")
        
        return performance_report

def create_new_test_data():
    """새로운 테스트 데이터 생성 (시뮬레이션)"""
    
    np.random.seed(123)  # 다른 시드 사용
    n_samples = 200
    
    data = {
        'area': np.random.normal(1600, 600, n_samples),  # 약간 다른 분포
        'bedrooms': np.random.randint(1, 7, n_samples),
        'bathrooms': np.random.randint(1, 5, n_samples),
        'age': np.random.randint(0, 60, n_samples),
        'distance_to_city': np.random.normal(12, 6, n_samples)
    }
    
    df = pd.DataFrame(data)
    
    # 가격 계산 (약간 다른 공식)
    df['price'] = (df['area'] * 110 + 
                   df['bedrooms'] * 52000 + 
                   df['bathrooms'] * 32000 - 
                   df['age'] * 2200 - 
                   df['distance_to_city'] * 5200 + 
                   np.random.normal(0, 55000, n_samples))
    
    X = df.drop('price', axis=1)
    y = df['price']
    
    return X, y
```

### 4. 실험 환경 관리

```python
import yaml
import json
from pathlib import Path

def create_experiment_config():
    """실험 설정 파일 생성"""
    
    config = {
        "experiment_name": "housing_price_prediction",
        "data_config": {
            "n_samples": 1000,
            "test_size": 0.2,
            "random_state": 42,
            "features": ["area", "bedrooms", "bathrooms", "age", "distance_to_city"]
        },
        "model_config": {
            "model_type": "RandomForestRegressor",
            "hyperparameters": {
                "n_estimators": [100, 150, 200, 300],
                "max_depth": [8, 10, 12, 15, 20],
                "min_samples_split": [2, 3, 5, 10]
            }
        },
        "evaluation_config": {
            "metrics": ["r2_score", "rmse", "mse"],
            "cross_validation": 5
        },
        "mlflow_config": {
            "tracking_uri": "sqlite:///mlflow.db",
            "artifact_location": "./mlruns"
        }
    }
    
    # YAML 파일로 저장
    with open("experiment_config.yaml", "w") as f:
        yaml.dump(config, f, default_flow_style=False)
    
    # MLflow에 로깅
    with mlflow.start_run(run_name="experiment_config"):
        mlflow.log_artifact("experiment_config.yaml")
    
    return config

def load_experiment_config(config_path="experiment_config.yaml"):
    """실험 설정 파일 로드"""
    
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)
    
    return config
```

## 문제 해결 및 최적화

### 1. 일반적인 문제 해결

```python
def troubleshoot_common_issues():
    """일반적인 MLflow 문제 해결"""
    
    # 1. 포트 충돌 해결
    import subprocess
    import signal
    
    def kill_process_on_port(port):
        try:
            result = subprocess.run(['lsof', '-ti', f':{port}'], 
                                  capture_output=True, text=True)
            if result.stdout:
                pid = result.stdout.strip()
                subprocess.run(['kill', '-9', pid])
                print(f"포트 {port}의 프로세스 {pid}를 종료했습니다.")
        except Exception as e:
            print(f"포트 {port} 정리 중 오류: {e}")
    
    # 2. MLflow 서버 상태 확인
    def check_mlflow_server():
        try:
            import requests
            response = requests.get("http://localhost:5000")
            if response.status_code == 200:
                print("MLflow 서버가 정상적으로 실행 중입니다.")
                return True
            else:
                print("MLflow 서버에 연결할 수 없습니다.")
                return False
        except:
            print("MLflow 서버가 실행되지 않았습니다.")
            return False
    
    # 3. 실험 데이터 백업
    def backup_mlflow_data():
        import shutil
        from datetime import datetime
        
        backup_dir = f"mlflow_backup_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        
        if Path("mlruns").exists():
            shutil.copytree("mlruns", backup_dir)
            print(f"MLflow 데이터가 {backup_dir}에 백업되었습니다.")
        else:
            print("백업할 MLflow 데이터가 없습니다.")
    
    return {
        "kill_port": kill_process_on_port,
        "check_server": check_mlflow_server,
        "backup_data": backup_mlflow_data
    }
```

### 2. 성능 최적화

```python
def optimize_experiment_performance():
    """실험 성능 최적화"""
    
    # 1. 병렬 처리 설정
    import joblib
    from sklearn.model_selection import cross_val_score
    
    def parallel_cross_validation(model, X, y, cv=5):
        """병렬 교차 검증"""
        scores = cross_val_score(model, X, y, cv=cv, n_jobs=-1, scoring='r2')
        return scores.mean(), scores.std()
    
    # 2. 메모리 효율적인 데이터 처리
    def memory_efficient_training(X, y, batch_size=1000):
        """메모리 효율적인 훈련"""
        n_samples = len(X)
        
        for i in range(0, n_samples, batch_size):
            end_idx = min(i + batch_size, n_samples)
            X_batch = X.iloc[i:end_idx]
            y_batch = y.iloc[i:end_idx]
            
            # 배치별 처리
            yield X_batch, y_batch
    
    # 3. 실험 결과 캐싱
    import hashlib
    import pickle
    
    def cache_experiment_results(params, results, cache_dir="experiment_cache"):
        """실험 결과 캐싱"""
        Path(cache_dir).mkdir(exist_ok=True)
        
        # 파라미터 해시 생성
        param_str = json.dumps(params, sort_keys=True)
        param_hash = hashlib.md5(param_str.encode()).hexdigest()
        
        cache_file = Path(cache_dir) / f"{param_hash}.pkl"
        
        # 결과 저장
        with open(cache_file, 'wb') as f:
            pickle.dump(results, f)
        
        return cache_file
    
    def load_cached_results(params, cache_dir="experiment_cache"):
        """캐시된 결과 로드"""
        param_str = json.dumps(params, sort_keys=True)
        param_hash = hashlib.md5(param_str.encode()).hexdigest()
        
        cache_file = Path(cache_dir) / f"{param_hash}.pkl"
        
        if cache_file.exists():
            with open(cache_file, 'rb') as f:
                return pickle.load(f)
        
        return None
    
    return {
        "parallel_cv": parallel_cross_validation,
        "memory_efficient": memory_efficient_training,
        "cache_results": cache_experiment_results,
        "load_cache": load_cached_results
    }
```

## 결론

MLflow를 활용한 실험 추적은 개인 머신러닝 프로젝트에서 FAIR 원칙을 구현하는 효과적인 방법입니다. 이 가이드를 통해 다음과 같은 이점을 얻을 수 있습니다:

- **체계적인 실험 관리**: 모든 실험과 결과를 중앙화된 위치에서 관리
- **재현성 보장**: 정확한 하이퍼파라미터와 환경 정보 기록
- **성능 비교**: 다양한 실험 결과를 시각적으로 비교 분석
- **모델 버전 관리**: 최고 성능 모델의 체계적인 버전 관리
- **협업 지원**: 실험 결과를 팀원과 쉽게 공유

맥북에서 MLflow를 활용하여 개인 머신러닝 실험을 체계적으로 관리하고, FAIR 원칙을 실현하여 더 나은 연구 결과를 도출해보세요.

## 참고 자료

- [MLflow 공식 문서](https://mlflow.org/docs/latest/index.html)
- [FAIR 원칙 가이드라인](https://doi.org/10.5334/dsj-2024-055)
- [Scikit-learn 공식 문서](https://scikit-learn.org/stable/)
- [Pandas 공식 문서](https://pandas.pydata.org/docs/) 