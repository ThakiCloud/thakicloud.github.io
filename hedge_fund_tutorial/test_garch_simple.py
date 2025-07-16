#!/usr/bin/env python3
"""
헤지펀드 수준의 GARCH 모델 간단 테스트
"""

import numpy as np
import pandas as pd
from arch import arch_model
import warnings
warnings.filterwarnings('ignore')

def test_garch_model():
    """GARCH 모델 기본 테스트"""
    print("🏦 헤지펀드 GARCH 모델 테스트 시작")
    print("=" * 50)
    
    # 1. 가상 데이터 생성 (GARCH 스타일)
    np.random.seed(42)
    n_days = 1000
    
    # GARCH(1,1) 시뮬레이션
    omega = 0.00001
    alpha = 0.05
    beta = 0.90
    
    returns = np.zeros(n_days)
    volatilities = np.zeros(n_days)
    volatilities[0] = 0.02
    
    for t in range(1, n_days):
        volatilities[t] = np.sqrt(
            omega + alpha * returns[t-1]**2 + beta * volatilities[t-1]**2
        )
        returns[t] = np.random.normal(0, volatilities[t])
    
    print(f"📊 시뮬레이션 데이터 생성 완료: {n_days}일")
    print(f"  평균 수익률: {returns.mean():.6f}")
    print(f"  평균 변동성: {volatilities.mean():.6f}")
    
    # 2. GARCH 모델 학습
    print("\n🔄 GARCH 모델 학습 중...")
    
    # GARCH(1,1) 모델
    model = arch_model(returns * 100, vol='GARCH', p=1, q=1, dist='normal')
    result = model.fit(disp='off')
    
    print("✅ GARCH 모델 학습 완료")
    print(f"  AIC: {result.aic:.2f}")
    print(f"  BIC: {result.bic:.2f}")
    print(f"  Log-likelihood: {result.loglikelihood:.2f}")
    
    # 3. 모델 파라미터 출력
    print("\n📈 모델 파라미터:")
    params = result.params
    for param_name, param_value in params.items():
        print(f"  {param_name}: {param_value:.6f}")
    
    # 4. 변동성 예측
    print("\n🔮 변동성 예측 (5일):")
    forecast = result.forecast(horizon=5)
    vol_forecast = np.sqrt(forecast.variance.iloc[-1].values) / 100
    
    for i, vol in enumerate(vol_forecast, 1):
        print(f"  {i}일 후 예상 변동성: {vol:.4f}")
    
    # 5. VaR 계산
    print("\n📊 VaR (Value at Risk) 계산:")
    from scipy.stats import norm
    
    confidence_levels = [0.01, 0.05, 0.10]
    for confidence in confidence_levels:
        z_score = norm.ppf(confidence)
        var_estimate = z_score * vol_forecast[0]
        print(f"  {confidence*100}% VaR (1일): {var_estimate:.4f}")
    
    print("\n✅ GARCH 모델 테스트 완료!")
    
    return {
        'model': result,
        'forecast': vol_forecast,
        'returns': returns,
        'volatilities': volatilities
    }

def test_multiple_garch_models():
    """여러 GARCH 모델 변형 테스트"""
    print("\n🔄 다중 GARCH 모델 테스트")
    print("=" * 50)
    
    # 동일한 데이터 사용
    np.random.seed(42)
    n_days = 500
    returns = np.random.normal(0, 0.02, n_days)
    
    models = {
        'GARCH(1,1)': {'vol': 'GARCH', 'p': 1, 'q': 1, 'dist': 'normal'},
        'EGARCH(1,1)': {'vol': 'EGARCH', 'p': 1, 'q': 1, 'dist': 'normal'},
        'GJR-GARCH(1,1)': {'vol': 'GARCH', 'p': 1, 'q': 1, 'dist': 't'},
    }
    
    results = {}
    
    for model_name, config in models.items():
        try:
            print(f"\n📊 {model_name} 학습 중...")
            
            model = arch_model(
                returns * 100,
                vol=config['vol'],
                p=config['p'],
                q=config['q'],
                dist=config['dist']
            )
            
            result = model.fit(disp='off', show_warning=False)
            
            results[model_name] = {
                'aic': result.aic,
                'bic': result.bic,
                'loglik': result.loglikelihood
            }
            
            print(f"  ✅ AIC: {result.aic:.2f}, BIC: {result.bic:.2f}")
            
        except Exception as e:
            print(f"  ❌ 오류: {str(e)}")
            results[model_name] = None
    
    # 최적 모델 선택
    print(f"\n🏆 모델 성능 비교:")
    valid_results = {k: v for k, v in results.items() if v is not None}
    
    if valid_results:
        best_model = min(valid_results.keys(), key=lambda x: valid_results[x]['aic'])
        print(f"  최적 모델 (AIC 기준): {best_model}")
        
        for model_name, metrics in valid_results.items():
            marker = "🏆" if model_name == best_model else "  "
            print(f"  {marker} {model_name}: AIC={metrics['aic']:.2f}")
    
    return results

def performance_benchmark():
    """성능 벤치마크"""
    print("\n⚡ 성능 벤치마크")
    print("=" * 50)
    
    import time
    
    # 다양한 데이터 크기로 테스트
    data_sizes = [100, 500, 1000, 2000]
    
    for size in data_sizes:
        print(f"\n📊 데이터 크기: {size}일")
        
        # 데이터 생성
        np.random.seed(42)
        returns = np.random.normal(0, 0.02, size)
        
        # 시간 측정
        start_time = time.time()
        
        try:
            model = arch_model(returns * 100, vol='GARCH', p=1, q=1)
            result = model.fit(disp='off')
            
            end_time = time.time()
            training_time = end_time - start_time
            
            print(f"  ⏱️  학습 시간: {training_time:.3f}초")
            print(f"  📈 AIC: {result.aic:.2f}")
            
        except Exception as e:
            print(f"  ❌ 오류: {str(e)}")

if __name__ == "__main__":
    # 기본 GARCH 테스트
    basic_results = test_garch_model()
    
    # 다중 모델 테스트
    multi_results = test_multiple_garch_models()
    
    # 성능 벤치마크
    performance_benchmark()
    
    print("\n🎉 모든 테스트 완료!")
    print("\n💡 다음 단계:")
    print("  1. source hedge_fund_env/bin/activate")
    print("  2. python scripts/data_generator.py")
    print("  3. python models/garch/garch_ensemble.py")
