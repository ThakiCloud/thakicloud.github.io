# MetaGPT 테스트 환경

이 디렉토리는 MetaGPT 멀티 에이전트 프레임워크의 테스트 및 학습을 위한 환경입니다.

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# 테스트 환경 자동 설정
./setup-test.sh

# 가상환경 활성화
source metagpt-test-env/bin/activate
```

### 2. MetaGPT 설정

```bash
# 설정 파일 초기화
metagpt --init-config

# 설정 파일 편집 (API 키 설정 필요)
nano ~/.metagpt/config2.yaml
```

### 3. 기본 테스트

```bash
# 설치 확인
python test_installation.py

# 간단한 프로젝트 생성 테스트
python simple_project_test.py

# 데이터 분석 테스트
python data_analysis_test.py
```

## 📁 파일 구조

```
metagpt-test/
├── setup-test.sh              # 환경 설정 스크립트
├── test_installation.py       # 설치 확인 테스트
├── simple_project_test.py     # 기본 프로젝트 생성 테스트
├── data_analysis_test.py      # 데이터 분석 테스트
├── advanced_examples.py       # 고급 사용 예제
├── custom_agent_demo.py       # 커스텀 에이전트 데모
├── production_demo.py         # 프로덕션 환경 데모
├── config_examples/           # 설정 예제들
└── sample_outputs/           # 샘플 출력 결과들
```

## ⚙️ 설정 예제

### OpenAI 설정

```yaml
llm:
  api_type: "openai"
  model: "gpt-4-turbo"
  base_url: "https://api.openai.com/v1"
  api_key: "YOUR_OPENAI_API_KEY"
```

### 개발 환경 최적화

```yaml
llm:
  api_type: "openai"
  model: "gpt-3.5-turbo"  # 빠르고 저렴
  base_url: "https://api.openai.com/v1"
  api_key: "YOUR_API_KEY"
  temperature: 0.3        # 일관성 우선
  max_tokens: 2048        # 토큰 절약
```

## 🧪 테스트 시나리오

### 기본 프로젝트 생성

- 웹 애플리케이션 (Todo List, 계산기)
- 게임 (2048, 틱택토)
- 유틸리티 (비밀번호 생성기, 단위 변환기)

### 데이터 분석

- Iris 데이터셋 분석
- 매출 데이터 시각화
- 금융 데이터 분석

### 고급 활용

- 커스텀 에이전트 개발
- 멀티 에이전트 협업
- 디베이트 시스템

## 🚨 문제 해결

### 일반적인 문제들

1. **API 키 오류**
   ```
   Error: Invalid API key
   ```
   해결: `~/.metagpt/config2.yaml`에서 API 키 확인

2. **Python 버전 오류**
   ```
   Error: Python version not supported
   ```
   해결: Python 3.9-3.11 버전 사용

3. **Node.js 누락**
   ```
   Error: node command not found
   ```
   해결: Node.js 18+ 설치 필요

4. **메모리 부족**
   ```
   Error: Out of memory
   ```
   해결: 더 작은 모델 사용 또는 시스템 리소스 확인

### 로그 확인

```bash
# MetaGPT 로그 위치
tail -f ~/.metagpt/logs/metagpt.log

# 디버그 모드 실행
METAGPT_LOG_LEVEL=DEBUG python your_script.py
```

## 🔧 고급 설정

### 리소스 모니터링

```python
# 시스템 리소스 확인
import psutil
print(f"CPU: {psutil.cpu_percent()}%")
print(f"Memory: {psutil.virtual_memory().percent}%")
```

### 캐시 관리

```bash
# 캐시 디렉토리 확인
ls -la ~/.metagpt/cache/

# 캐시 정리
rm -rf ~/.metagpt/cache/*
```

## 📚 학습 리소스

- [MetaGPT 공식 문서](https://docs.deepwisdom.ai/)
- [GitHub 저장소](https://github.com/FoundationAgents/MetaGPT)
- [Discord 커뮤니티](https://discord.gg/metagpt)
- [튜토리얼 비디오](https://www.youtube.com/watch?v=MetaGPT)

## 🤝 기여하기

버그 리포트나 기능 요청은 GitHub Issues에 등록해주세요.

## 📄 라이센스

MIT License
