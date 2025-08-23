---
title: "Agent Laboratory: LLM 기반 자율 연구 도우미 완전 가이드"
excerpt: "Agent Laboratory를 활용한 자동화된 연구 워크플로우 구축부터 실험 실행까지 단계별 완전 가이드"
seo_title: "Agent Laboratory LLM 자율 연구 도우미 튜토리얼 - macOS 설치 가이드"
seo_description: "Agent Laboratory로 문헌 리뷰부터 실험 실행, 보고서 작성까지 자동화하는 연구 워크플로우 구축 방법을 상세히 안내합니다"
date: 2025-08-21
last_modified_at: 2025-08-21
categories:
  - tutorials
tags:
  - Agent Laboratory
  - LLM
  - 자율 연구
  - 연구 자동화
  - OpenAI
  - DeepSeek
  - 논문 작성
  - 실험 자동화
  - macOS
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/agent-laboratory-autonomous-research-assistant-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 서론

**Agent Laboratory**는 대규모 언어 모델(LLM)을 활용하여 연구 프로세스를 자동화하는 혁신적인 도구입니다. 문헌 리뷰부터 실험 설계, 코드 구현, 결과 분석, 논문 작성까지 연구의 전 과정을 자율적으로 수행할 수 있는 AI 연구 어시스턴트입니다.

### Agent Laboratory의 핵심 기능

- **📚 자동 문헌 리뷰**: arXiv에서 관련 논문을 수집하고 분석
- **🧪 실험 설계 및 실행**: 연구 아이디어를 바탕으로 실험 계획 수립 및 코드 구현
- **📊 결과 분석**: 실험 결과를 분석하고 시각화
- **📝 논문 작성**: LaTeX 형식의 연구 보고서 자동 생성
- **🤝 AgentRxiv**: 여러 에이전트 간 연구 결과 공유 및 협업

## 사전 요구사항

### 시스템 요구사항

```bash
# macOS 시스템 정보 확인
system_profiler SPSoftwareDataType | grep "System Version"
# Python 3.12 이상 권장
python3.12 --version
```

### 필요한 API 키

1. **OpenAI API 키** (권장)
   - GPT-4o, o1, o3-mini 등 최신 모델 지원
   - 높은 품질의 연구 결과 제공

2. **DeepSeek API 키** (대안)
   - 비용 효율적인 대안
   - deepseek-v3 모델 지원

## 설치 가이드

### 1. 저장소 클론 및 환경 설정

```bash
# 1. Agent Laboratory 클론
git clone https://github.com/SamuelSchmidgall/AgentLaboratory.git
cd AgentLaboratory

# 2. Python 3.12 가상환경 생성
python3.12 -m venv venv_agent_lab

# 3. 가상환경 활성화
source venv_agent_lab/bin/activate

# 4. 의존성 설치
pip install -r requirements.txt
```

### 2. LaTeX 설치 (선택사항)

```bash
# macOS에서 LaTeX 설치
brew install --cask mactex

# 또는 기본 LaTeX 패키지만 설치
brew install texlive
```

**참고**: LaTeX가 없어도 Agent Laboratory는 실행 가능하며, `--compile-latex false` 플래그로 PDF 컴파일을 비활성화할 수 있습니다.

## 기본 설정

### 1. API 키 설정

```bash
# experiment_configs/MATH_agentlab.yaml 편집
code experiment_configs/MATH_agentlab.yaml
```

{% raw %}
```yaml
# OpenAI API 키 설정
api-key: "YOUR-OPENAI-API-KEY-HERE"

# 또는 DeepSeek API 키 사용
# deepseek-api-key: "YOUR-DEEPSEEK-API-KEY-HERE"

# 사용할 LLM 모델 설정
llm-backend: "gpt-4o"  # 또는 "o1", "o3-mini", "deepseek-chat"
lit-review-backend: "gpt-4o"
```
{% endraw %}

### 2. 연구 주제 설정

{% raw %}
```yaml
# 연구 주제 정의
research-topic: "MATH 벤치마크에서 정확도를 최대화하는 새로운 프롬프팅 기법 개발"

# 기본 언어 설정
language: "Korean"  # 또는 "English"

# 실험 설정
num-papers-lit-review: 5
num-papers-to-write: 1
mlesolver-max-steps: 3
papersolver-max-steps: 1
```
{% endraw %}

## 실행 방법

### 1. 기본 실행

```bash
# 가상환경 활성화 후 실행
source venv_agent_lab/bin/activate
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml"
```

### 2. Co-pilot 모드 실행

Co-pilot 모드에서는 중요한 결정 단계에서 사용자의 입력을 받습니다.

{% raw %}
```yaml
# YAML 설정에서 co-pilot 모드 활성화
copilot-mode: True
```
{% endraw %}

```bash
# Co-pilot 모드로 실행
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml"
```

### 3. 다양한 실행 옵션

```bash
# LaTeX 컴파일 비활성화
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --compile-latex "false"

# 기존 저장 상태에서 재개
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --load-existing "true"

# 특정 LLM 백엔드 지정
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --llm-backend "o3-mini"
```

## 실제 테스트 결과

### 환경 설정 테스트

테스트를 위해 작성한 스크립트로 환경을 확인했습니다:

```bash
#!/bin/bash
echo "🔬 Agent Laboratory 테스트 설정 스크립트"

# 현재 디렉토리 및 Python 버전 확인
echo "📁 현재 작업 디렉토리: $(pwd)"
echo "🐍 Python 버전: $(python --version)"

# 가상환경 확인
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ 가상환경 활성화됨: $VIRTUAL_ENV"
else
    echo "⚠️  가상환경 활성화 중..."
    source venv_agent_lab/bin/activate
fi

# 필수 패키지 확인
echo "📦 필수 패키지 설치 확인..."
python -c "import torch; print(f'✅ PyTorch: {torch.__version__}')"
python -c "import transformers; print(f'✅ Transformers: {transformers.__version__}')"
python -c "import openai; print(f'✅ OpenAI: {openai.__version__}')"
```

**실행 결과**:
```
🔬 Agent Laboratory 테스트 설정 스크립트
📁 현재 작업 디렉토리: /Users/hanhyojung/thaki/thaki.github.io/tutorials/agentlaboratory-test/AgentLaboratory
🐍 Python 버전: Python 3.12.8
✅ 가상환경 활성화됨: /Users/hanhyojung/thaki/thaki.github.io/tutorials/agentlaboratory-test/AgentLaboratory/venv_agent_lab
📦 필수 패키지 설치 확인...
✅ PyTorch: 2.5.1
✅ Transformers: 4.46.3
✅ OpenAI: 1.55.1
```

### 지원 모델 확인

Agent Laboratory에서 현재 지원하는 LLM 모델들:

#### OpenAI 모델
- **o3-mini**: 최신 추론 모델 (2025년 출시)
- **o1, o1-preview, o1-mini**: 향상된 추론 능력
- **gpt-4o**: 멀티모달 지원

#### DeepSeek 모델
- **deepseek-chat (deepseek-v3)**: 비용 효율적인 대안

## zshrc Aliases 설정

작업 효율성을 위한 유용한 aliases를 설정할 수 있습니다:

```bash
# zshrc에 Agent Laboratory aliases 추가
cat >> ~/.zshrc << 'EOF'

# Agent Laboratory Aliases
export AGENTLAB_DIR="$HOME/path/to/AgentLaboratory"

# 기본 명령어
alias agentlab="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate"
alias agentlab-run="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && python ai_lab_repo.py"
alias agentlab-test="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && ./test-setup.sh"

# 설정 파일 편집
alias agentlab-config="code $AGENTLAB_DIR/experiment_configs/"
alias agentlab-math="agentlab-run --yaml-location experiment_configs/MATH_agentlab.yaml"

# 결과 및 로그 확인
alias agentlab-logs="cd $AGENTLAB_DIR && find . -name '*.log' -o -name 'state_saves' -type d"
alias agentlab-status="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && python -c 'import torch; import transformers; import openai; print(\"✅ All dependencies loaded successfully\")'"

EOF

# 변경사항 적용
source ~/.zshrc
```

## 연구 워크플로우 이해

### 1. 문헌 리뷰 단계 (Literature Review)

```python
# Agent Laboratory의 문헌 리뷰 프로세스
1. arXiv에서 관련 논문 검색
2. 논문 요약 및 핵심 아이디어 추출
3. 연구 갭 및 기회 식별
4. 실험 계획 수립을 위한 배경 지식 구축
```

### 2. 실험 단계 (Experimentation)

```python
# 실험 설계 및 실행 과정
1. 연구 가설 설정
2. 실험 계획 수립
3. 데이터 준비 및 전처리
4. 모델 구현 및 훈련
5. 결과 분석 및 시각화
```

### 3. 보고서 작성 단계 (Report Writing)

```python
# 자동 보고서 생성 과정
1. 실험 결과 종합
2. 그래프 및 표 생성
3. LaTeX 논문 작성
4. 참고문헌 정리
5. PDF 컴파일 (선택사항)
```

## 고급 사용법

### 1. 커스텀 연구 주제 설정

{% raw %}
```yaml
# 복잡한 연구 주제 예시
research-topic: |
  멀티모달 대화 시스템에서 감정 인식과 공감적 응답 생성을 위한 
  새로운 트랜스포머 아키텍처 설계 및 평가

task-notes:
  plan-formulation:
    - '감정 인식 데이터셋 (IEMOCAP, MELD) 활용'
    - '공감적 응답 평가를 위한 새로운 메트릭 개발'
    - 'GPT-4o를 베이스라인으로 사용'
  
  data-preparation:
    - '멀티모달 데이터 전처리 파이프라인 구축'
    - '감정 라벨링 및 공감 점수 주석'
  
  running-experiments:
    - '병렬 처리를 통한 효율적인 실험 실행'
    - '시각화를 위한 상세한 그래프 생성'
```
{% endraw %}

### 2. 병렬 실험 실행

{% raw %}
```yaml
# 여러 실험을 병렬로 실행
parallel-labs: True
num-papers-to-write: 3

# 각 실험의 인덱스 설정
lab-index: 1  # 첫 번째 실험
```
{% endraw %}

### 3. 체크포인트 활용

Agent Laboratory는 자동으로 진행 상황을 저장하므로, 중단된 실험을 재개할 수 있습니다:

```bash
# 기존 저장점에서 재개
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --load-existing "true"

# 저장된 상태 확인
ls -la state_saves/
```

## 문제 해결

### 1. 일반적인 오류 및 해결책

**API 키 관련 오류**:
```bash
# OpenAI API 키 확인
python -c "import openai; print('✅ API 키 설정 확인')"

# DeepSeek API 키 테스트
curl -H "Authorization: Bearer YOUR-API-KEY" https://api.deepseek.com/v1/models
```

**메모리 부족 오류**:
```bash
# 시스템 메모리 확인
system_profiler SPHardwareDataType | grep Memory

# 배치 크기 조정 (YAML에서 설정)
# 더 작은 모델 사용 권장
```

**LaTeX 컴파일 오류**:
```bash
# LaTeX 비활성화
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --compile-latex "false"

# LaTeX 설치 확인
which pdflatex
```

### 2. 로그 분석

```bash
# 상세 로그 확인
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentlab.yaml" --verbose

# 특정 에러 검색
grep -r "ERROR" logs/ 2>/dev/null || echo "로그 디렉토리 없음"
```

## 성능 최적화 팁

### 1. 모델 선택 전략

```python
# 품질 우선 (높은 비용)
llm-backend: "o1"
lit-review-backend: "gpt-4o"

# 균형 잡힌 선택 (중간 비용)
llm-backend: "gpt-4o"
lit-review-backend: "gpt-4o-mini"

# 비용 효율성 우선 (낮은 비용)
llm-backend: "deepseek-chat"
lit-review-backend: "deepseek-chat"
```

### 2. 실험 범위 조정

{% raw %}
```yaml
# 빠른 프로토타이핑
num-papers-lit-review: 3
mlesolver-max-steps: 2
papersolver-max-steps: 1

# 심화 연구
num-papers-lit-review: 10
mlesolver-max-steps: 5
papersolver-max-steps: 3
```
{% endraw %}

### 3. 리소스 모니터링

```bash
# CPU 및 메모리 사용량 모니터링
top -pid $(pgrep -f "ai_lab_repo.py")

# GPU 사용량 확인 (NVIDIA GPU인 경우)
nvidia-smi

# 디스크 사용량 확인
du -sh AgentLaboratory/
```

## AgentRxiv 활용

AgentRxiv는 여러 연구 에이전트 간의 협업을 가능하게 하는 프레임워크입니다:

```bash
# AgentRxiv 설정으로 실행
python ai_lab_repo.py --yaml-location "experiment_configs/MATH_agentrxiv.yaml"
```

{% raw %}
```yaml
# AgentRxiv 특화 설정
research-topic: "다중 에이전트 환경에서의 협업적 연구 수행"

# 에이전트 간 결과 공유 설정
share-results: True
collaborative-mode: True
```
{% endraw %}

## 실제 연구 사례

### MATH 벤치마크 개선 연구

Agent Laboratory를 사용하여 MATH-500 벤치마크에서 성능을 개선하는 연구를 수행할 수 있습니다:

```python
# 연구 목표: GPT-4o-mini의 MATH-500 성능 향상
# 베이스라인: 70.2%
# 목표: 새로운 프롬프팅 기법으로 성능 개선

실험 과정:
1. 문헌 리뷰: 수학 문제 해결을 위한 최신 프롬프팅 기법 조사
2. 가설 설정: Chain-of-Thought, Tree-of-Thought 등의 변형 기법 개발
3. 실험 설계: 500개 테스트 문제에 대한 체계적 평가
4. 결과 분석: 정확도 개선 및 오류 패턴 분석
5. 논문 작성: 새로운 기법의 효과성 입증
```

## 개발환경 버전 정보

테스트된 환경에서의 주요 패키지 버전:

```
Python: 3.12.8
PyTorch: 2.5.1
Transformers: 4.46.3
OpenAI: 1.55.1
NumPy: 2.0.2
Pandas: 2.2.3
```

## 결론

Agent Laboratory는 연구 프로세스의 자동화를 통해 연구자들이 창의적 사고와 핵심 아이디어 개발에 집중할 수 있도록 돕는 강력한 도구입니다. 이 튜토리얼을 통해 기본 설정부터 고급 활용법까지 체계적으로 학습하여, 여러분의 연구 생산성을 크게 향상시킬 수 있을 것입니다.

### 주요 장점

- **⚡ 연구 속도 향상**: 문헌 리뷰부터 논문 작성까지 자동화
- **🎯 일관된 품질**: LLM의 체계적 접근으로 높은 품질 유지
- **💰 비용 효율성**: DeepSeek 등 저비용 모델 지원
- **🔄 재현 가능성**: 모든 실험이 코드로 기록되어 재현 가능
- **🤝 협업 지원**: AgentRxiv를 통한 다중 에이전트 협업

지속적인 연구 자동화 경험을 위해 Agent Laboratory의 [공식 GitHub 저장소](https://github.com/SamuelSchmidgall/AgentLaboratory)를 참고하시고, 새로운 기능과 업데이트를 확인해보세요.

## 참고 자료

- [Agent Laboratory GitHub Repository](https://github.com/SamuelSchmidgall/AgentLaboratory)
- [Agent Laboratory Paper (arXiv:2501.04227)](https://arxiv.org/abs/2501.04227)
- [AgentRxiv Paper (arXiv:2503.18102)](https://arxiv.org/abs/2503.18102)
- [OpenAI API Documentation](https://platform.openai.com/docs/)
- [DeepSeek API Documentation](https://platform.deepseek.com/docs/)
