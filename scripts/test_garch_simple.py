#!/usr/bin/env python3
# test_garch_simple.py

import numpy as np
import pandas as pd
import warnings
warnings.filterwarnings('ignore')

print("🏦 헤지펀드 GARCH 모델 기본 테스트")
print("="*50)

# 1. 간단한 시장 데이터 생성
def generate_simple_returns(n_days=500):
    """기본적인 시계열 수익률 생성"""
    print("📊 시장 데이터 생성 중...")
    
    # 간단한 GARCH 효과 시뮬레이션
    returns = np.zeros(n_days)
    volatilities = np.zeros(n_days)
    volatilities[0] = 0.02  # 초기 변동성
    
    for t in range(1, n_days):
        # 변동성 클러스터링 효과
        volatilities[t] = 0.02 + 0.1 * abs(returns[t-1]) + 0.85 * volatilities[t-1]
        
        # 수익률 생성
        returns[t] = np.random.normal(0, volatilities[t])
    
    print(f"✅ {n_days}일 데이터 생성 완료")
    print(f"📈 평균 수익률: {returns.mean():.6f}")
    print(f"📊 수익률 변동성: {returns.std():.6f}")
    
    return returns, volatilities

# 2. 기본 변동성 예측
def simple_volatility_forecast(returns, window=20):
    """이동평균 기반 변동성 예측"""
    squared_returns = returns ** 2
    volatility = np.sqrt(np.mean(squared_returns[-window:]))
    return volatility

# 3. VaR 계산
def calculate_var(volatility, confidence_levels=[0.01, 0.05, 0.10]):
    """정규분포 가정 VaR 계산"""
    from scipy.stats import norm
    
    var_results = {}
    for conf in confidence_levels:
        z_score = norm.ppf(conf)
        var_estimate = z_score * volatility
        var_results[f"{(1-conf)*100:.0f}%"] = var_estimate
    
    return var_results

# 4. 테스트 실행
if __name__ == "__main__":
    try:
        # 데이터 생성
        returns, true_volatilities = generate_simple_returns(500)
        
        # 변동성 예측
        print("\n🔮 변동성 예측:")
        predicted_vol = simple_volatility_forecast(returns)
        actual_vol = true_volatilities[-1]
        
        print(f"  예측 변동성: {predicted_vol:.4f} ({predicted_vol*100:.2f}%)")
        print(f"  실제 변동성: {actual_vol:.4f} ({actual_vol*100:.2f}%)")
        print(f"  예측 오차: {abs(predicted_vol - actual_vol):.4f}")
        
        # VaR 계산
        print("\n📊 VaR (Value at Risk) 계산:")
        var_results = calculate_var(predicted_vol)
        
        for level, var_val in var_results.items():
            print(f"  {level} VaR: {var_val:.4f} ({var_val*100:.2f}%)")
        
        # 간단한 백테스팅
        print("\n🧪 간단한 백테스팅:")
        prediction_window = 100
        predictions = []
        actuals = []
        
        for i in range(prediction_window, len(returns) - 1):
            # 과거 데이터로 예측
            pred_vol = simple_volatility_forecast(returns[:i])
            actual_vol = abs(returns[i+1])  # 다음날 실제 수익률 절댓값
            
            predictions.append(pred_vol)
            actuals.append(actual_vol)
        
        # 예측 성능 계산
        mae = np.mean(np.abs(np.array(predictions) - np.array(actuals)))
        correlation = np.corrcoef(predictions, actuals)[0, 1]
        
        print(f"  평균 절대 오차 (MAE): {mae:.6f}")
        print(f"  상관관계: {correlation:.3f}")
        
        print("\n✅ 기본 GARCH 테스트 완료!")
        
        # 헤지펀드 확장 시나리오
        print("\n🏦 헤지펀드 환경 확장 가능성:")
        
        models_per_asset = 5  # GARCH, EGARCH, TGARCH, DCC, GJR
        assets = 500
        total_models = models_per_asset * assets
        
        # 현재 테스트 기준 예상 학습 시간
        single_model_time = 0.1  # 초 (간단한 모델 기준)
        total_time_serial = total_models * single_model_time
        
        print(f"  🔢 총 모델 수: {total_models:,}개")
        print(f"  ⏱️  순차 처리 시간: {total_time_serial:,.0f}초 ({total_time_serial/3600:.1f}시간)")
        
        # 병렬 처리 시나리오
        available_cores = 8  # 일반적인 macOS
        parallel_time = total_time_serial / available_cores
        
        print(f"  🚀 병렬 처리 시간 (8코어): {parallel_time:,.0f}초 ({parallel_time/3600:.1f}시간)")
        
        # GPU 클러스터 시나리오
        gpu_speedup = 100
        gpu_time = total_time_serial / gpu_speedup
        
        print(f"  ⚡ GPU 클러스터 처리 시간: {gpu_time:,.0f}초 ({gpu_time/60:.1f}분)")
        
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        import traceback
        traceback.print_exc()
        print("\n필요한 패키지:")
        print("pip install numpy pandas scipy") 