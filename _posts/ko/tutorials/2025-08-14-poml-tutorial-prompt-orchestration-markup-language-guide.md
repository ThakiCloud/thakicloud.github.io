---
title: "POML 튜토리얼: Prompt Orchestration Markup Language 완전 가이드"
excerpt: "Microsoft POML로 구조화된 프롬프트 엔지니어링을 배워보세요. HTML-like 문법, 데이터 통합, CSS-like 스타일링, 템플릿 엔진으로 LLM 프롬프트를 체계적으로 관리하고 재사용할 수 있습니다."
seo_title: "POML 튜토리얼: 프롬프트 오케스트레이션 마크업 언어 가이드 - Thaki Cloud"
seo_description: "Microsoft POML로 LLM 프롬프트를 구조화하세요. VS Code 확장, Node.js/Python SDK, 템플릿 엔진, 데이터 통합까지 실전 예제와 함께 완전 정리한 튜토리얼."
date: 2025-08-14
last_modified_at: 2025-08-14
categories:
  - tutorials
  - llmops
tags:
  - POML
  - Microsoft
  - LLM
  - PromptEngineering
  - VSCode
  - Node.js
  - Python
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/poml-tutorial/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 18분

## 개요

**POML (Prompt Orchestration Markup Language)**는 Microsoft에서 개발한 프롬프트 엔지니어링을 위한 혁신적인 마크업 언어입니다. HTML과 유사한 구조화된 문법을 통해 LLM 프롬프트의 가독성, 재사용성, 유지보수성을 대폭 향상시킵니다. 복잡한 데이터 통합, 조건부 로직, 스타일 분리 등을 지원하여 기업급 AI 애플리케이션 개발에 최적화되어 있습니다.

참고: [microsoft/poml GitHub 리포지토리](https://github.com/microsoft/poml)

## 무엇을 만들 것인가

- **구조화된 프롬프트 시스템**: HTML-like 문법으로 역할, 작업, 예시를 모듈화
- **데이터 통합 파이프라인**: 텍스트 파일, 스프레드시트, 이미지를 프롬프트에 직접 임베드
- **동적 템플릿 엔진**: 변수, 반복문, 조건문으로 데이터 기반 프롬프트 생성
- **스타일 분리 시스템**: CSS-like 스타일시트로 콘텐츠와 프레젠테이션 분리

## 핵심 기능

### 1. 구조화된 프롬프트 마크업
HTML과 유사한 시맨틱 컴포넌트(`<role>`, `<task>`, `<example>`)로 모듈화된 설계를 촉진합니다.

### 2. 포괄적인 데이터 처리
특화된 데이터 컴포넌트(`<document>`, `<table>`, `<img>`)로 외부 데이터 소스를 원활하게 통합합니다.

### 3. 분리된 프레젠테이션 스타일링
CSS-like 스타일링 시스템으로 콘텐츠와 프레젠테이션을 분리하여 LLM 포맷 민감성을 완화합니다.

### 4. 통합 템플릿 엔진
변수(`{% raw %}{{ }}{% endraw %}`), 반복문(`for`), 조건문(`if`), 변수 정의(`<let>`)를 지원합니다.

### 5. 풍부한 개발 도구
VS Code 확장, Node.js/Python SDK를 제공합니다.

## 사전 요구사항 및 macOS 테스트 환경

- **OS**: macOS Monterey 이상 권장
- **Node.js**: 18+ (npm/pnpm 포함)
- **Python**: 3.8+
- **VS Code**: 최신 버전

버전 확인:

```bash
node --version      # v20.x.x
npm --version       # 10.x.x
python --version    # Python 3.11.x
code --version      # 1.9x.x
```

## 설치 및 설정

### VS Code 확장 설치

**방법 1: 마켓플레이스에서 설치**

1. VS Code 실행
2. Extensions 탭 (Cmd+Shift+X)
3. "POML" 검색 후 설치

**방법 2: 수동 설치**

```bash
# GitHub releases에서 .vsix 파일 다운로드 후
code --install-extension poml-x.x.x.vsix
```

### API 설정

VS Code에서 POML 확장 설정:

```json
// settings.json
{
  "poml.provider": "openai",
  "poml.apiKey": "your-api-key",
  "poml.endpoint": "https://api.openai.com/v1"
}
```

또는 Settings UI에서:
1. `Cmd+,` → "POML" 검색
2. Model Provider, API Key, Endpoint URL 설정

### Node.js SDK 설치

```bash
npm install pomljs
# 또는
pnpm add pomljs
```

### Python SDK 설치

```bash
pip install poml
# 또는 개발용
pip install -e .
```

## 기본 문법 및 구조

### 기본 POML 예제

```xml
<poml>
  <role>You are a patient teacher explaining concepts to a 10-year-old.</role>
  <task>Explain the concept of photosynthesis using the provided image as a reference.</task>

  <img src="photosynthesis_diagram.png" alt="Diagram of photosynthesis" />

  <output-format>
    Keep the explanation simple, engaging, and under 100 words.
    Start with "Hey there, future scientist!".
  </output-format>
</poml>
```

### 핵심 컴포넌트

| 컴포넌트 | 용도 | 예시 |
|---------|------|------|
| `<role>` | AI의 역할 정의 | `<role>Senior software architect</role>` |
| `<task>` | 수행할 작업 | `<task>Review this code for security issues</task>` |
| `<example>` | 예시 제공 | `<example>Input: ... Output: ...</example>` |
| `<document>` | 텍스트 파일 임베드 | `<document src="api_spec.md" />` |
| `<table>` | 스프레드시트 데이터 | `<table src="data.csv" format="markdown" />` |
| `<img>` | 이미지 참조 | `<img src="diagram.png" alt="Architecture" />` |

## 실전 예제

### 예제 1: 코드 리뷰 시스템

```xml
<poml>
  <role>
    You are a senior software engineer conducting a thorough code review.
    Focus on security, performance, and maintainability.
  </role>

  <task>
    Review the following code changes and provide detailed feedback.
  </task>

  <document src="pull_request.diff" />
  
  <context>
    <document src="coding_standards.md" />
    <table src="security_checklist.csv" format="list" />
  </context>

  <output-format>
    ## Summary
    Brief overview of changes

    ## Issues Found
    - **Security**: [List security concerns]
    - **Performance**: [List performance issues]
    - **Style**: [List style violations]

    ## Recommendations
    [Specific actionable recommendations]

    ## Approval Status
    [APPROVED/NEEDS_CHANGES/REJECTED]
  </output-format>
</poml>
```

### 예제 2: 데이터 분석 리포트

```xml
<poml>
  <role>Data analyst creating executive summaries</role>

  <task>
    Analyze the quarterly sales data and create an executive summary 
    with key insights and recommendations.
  </task>

  <table src="q4_sales_data.xlsx" sheet="Summary" format="markdown" />
  
  <let quarter="Q4 2024" />
  <let target_growth="15%" />

  <context>
    Previous quarter performance: {% raw %}{{ previous_quarter_data }}{% endraw %}
    Market conditions: {% raw %}{{ market_analysis }}{% endraw %}
  </context>

  <style verbosity="concise" format="business-formal" />

  <output-format>
    # {% raw %}{{ quarter }}{% endraw %} Sales Performance Executive Summary

    ## Key Metrics
    - Revenue: [amount and % change]
    - Growth rate: [vs target of {% raw %}{{ target_growth }}{% endraw %}]
    - Top performing products/regions

    ## Strategic Insights
    [3-5 key business insights]

    ## Recommendations
    [Specific actionable recommendations for next quarter]
  </output-format>
</poml>
```

## 고급 기능

### 템플릿 엔진

**변수 정의 및 사용:**

```xml
<let company_name="TechCorp" />
<let analysis_date="2024-08-14" />

<task>
  Generate a security assessment report for {% raw %}{{ company_name }}{% endraw %} 
  as of {% raw %}{{ analysis_date }}{% endraw %}.
</task>
```

**조건부 로직:**

```xml
{% raw %}{% if security_level == "high" %}{% endraw %}
<context>
  <document src="classified_threats.md" />
</context>
{% raw %}{% else %}{% endraw %}
<context>
  <document src="general_threats.md" />
</context>
{% raw %}{% endif %}{% endraw %}
```

**반복문:**

```xml
<examples>
{% raw %}{% for issue in security_issues %}{% endraw %}
  <example>
    Issue: {% raw %}{{ issue.title }}{% endraw %}
    Severity: {% raw %}{{ issue.severity }}{% endraw %}
    Solution: {% raw %}{{ issue.solution }}{% endraw %}
  </example>
{% raw %}{% endfor %}{% endraw %}
</examples>
```

### 스타일링 시스템

**인라인 스타일:**

```xml
<task style="verbosity: detailed; format: technical; tone: formal">
  Conduct a comprehensive security audit of the application.
</task>
```

**스타일시트 정의:**

```xml
<stylesheet>
  .technical {
    verbosity: detailed;
    format: structured;
    include_code_examples: true;
  }
  
  .executive {
    verbosity: concise;
    format: business;
    focus: high_level_insights;
  }
</stylesheet>

<task class="technical">
  Analyze the API security implementation.
</task>
```

## SDK 통합

### Node.js 예제

```javascript
import { POML } from 'pomljs';

const prompt = `
<poml>
  <role>Technical writer</role>
  <task>Create API documentation for the user service</task>
  <document src="user_api.yaml" />
</poml>
`;

const poml = new POML();
const renderedPrompt = await poml.render(prompt, {
  user_api: './docs/user_api.yaml'
});

// LLM에 전달
const response = await openai.chat.completions.create({
  model: "gpt-4",
  messages: [{ role: "user", content: renderedPrompt }]
});
```

### Python 예제

```python
from poml import POML

prompt_template = """
<poml>
  <role>{{ role }}</role>
  <task>{{ task }}</task>
  
  {% if include_data %}
  <table src="{{ data_file }}" format="markdown" />
  {% endif %}
  
  <output-format>{{ output_format }}</output-format>
</poml>
"""

poml = POML()
rendered = poml.render(prompt_template, {
    'role': 'Data scientist',
    'task': 'Analyze customer churn patterns',
    'include_data': True,
    'data_file': 'customer_data.csv',
    'output_format': 'Statistical summary with visualizations'
})

# OpenAI API 호출
import openai
response = openai.chat.completions.create(
    model="gpt-4",
    messages=[{"role": "user", "content": rendered}]
)
```

## macOS 테스트 스크립트

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "🔍 [1/7] Checking prerequisites"
node --version || { echo "❌ Node.js not found"; exit 1; }
python --version || { echo "❌ Python not found"; exit 1; }
code --version || { echo "❌ VS Code not found"; exit 1; }

echo "📦 [2/7] Installing Node.js SDK"
npm install -g pomljs || echo "⚠️ Global install failed, trying local..."
npm install pomljs

echo "🐍 [3/7] Installing Python SDK"
pip install poml

echo "📝 [4/7] Creating test POML file"
cat > test_example.poml << 'EOF'
<poml>
  <role>Helpful assistant</role>
  <task>Explain POML benefits in 3 bullet points</task>
  
  <output-format>
    - Point 1: [benefit]
    - Point 2: [benefit]  
    - Point 3: [benefit]
  </output-format>
</poml>
EOF

echo "🧪 [5/7] Testing Node.js integration"
cat > test_node.js << 'EOF'
const fs = require('fs');
console.log('POML content:');
console.log(fs.readFileSync('test_example.poml', 'utf8'));
console.log('✅ Node.js file read successful');
EOF

node test_node.js

echo "🐍 [6/7] Testing Python integration"
cat > test_python.py << 'EOF'
try:
    import poml
    print("✅ POML Python package imported successfully")
    
    with open('test_example.poml', 'r') as f:
        content = f.read()
        print("POML content loaded:", len(content), "characters")
except ImportError as e:
    print(f"⚠️ Import error: {e}")
except Exception as e:
    print(f"⚠️ Other error: {e}")
EOF

python test_python.py

echo "🧹 [7/7] Cleaning up test files"
rm -f test_example.poml test_node.js test_python.py

echo "✅ All tests completed successfully!"
echo "🎯 Next steps:"
echo "   1. Install VS Code POML extension"
echo "   2. Configure API keys in VS Code settings"
echo "   3. Create your first .poml file"
```

예상 출력:

```text
🔍 [1/7] Checking prerequisites
v20.11.0
Python 3.11.7
1.95.3
📦 [2/7] Installing Node.js SDK
+ pomljs@x.x.x
🐍 [3/7] Installing Python SDK
Successfully installed poml-x.x.x
📝 [4/7] Creating test POML file
🧪 [5/7] Testing Node.js integration
POML content:
<poml>
  <role>Helpful assistant</role>
  <task>Explain POML benefits in 3 bullet points</task>
  
  <output-format>
    - Point 1: [benefit]
    - Point 2: [benefit]  
    - Point 3: [benefit]
  </output-format>
</poml>
✅ Node.js file read successful
🐍 [6/7] Testing Python integration
✅ POML Python package imported successfully
POML content loaded: 234 characters
🧹 [7/7] Cleaning up test files
✅ All tests completed successfully!
🎯 Next steps:
   1. Install VS Code POML extension
   2. Configure API keys in VS Code settings
   3. Create your first .poml file
```

## zshrc 별칭 가이드

```bash
# ~/.zshrc
alias poml-new='mkdir -p poml-project && cd poml-project && npm init -y && npm install pomljs'
alias poml-test='node -e "console.log(require(\"pomljs\"))"'
alias poml-py='python -c "import poml; print(\"POML Python ready\")"'
alias poml-code='code --install-extension ms-vscode.poml || echo "Extension already installed"'
```

터미널 재시작 또는 `source ~/.zshrc` 후:

```bash
poml-new     # 새 POML 프로젝트 생성
poml-test    # Node.js SDK 테스트
poml-py      # Python SDK 테스트
poml-code    # VS Code 확장 설치
```

## 실전 활용 시나리오

### 1. API 문서 자동 생성

```xml
<poml>
  <role>Technical documentation specialist</role>
  <task>Generate comprehensive API documentation</task>
  
  <document src="openapi.yaml" />
  <table src="endpoint_examples.csv" format="markdown" />
  
  <style class="technical-doc" />
  
  <output-format>
    # API Documentation
    
    ## Overview
    [Brief description]
    
    ## Endpoints
    [Detailed endpoint documentation with examples]
    
    ## Authentication
    [Auth requirements and examples]
    
    ## Error Handling
    [Common errors and responses]
  </output-format>
</poml>
```

### 2. 코드 생성 및 리팩터링

```xml
<poml>
  <role>Senior full-stack developer</role>
  <task>Refactor legacy code to modern TypeScript patterns</task>
  
  <document src="legacy_code.js" />
  <document src="typescript_guidelines.md" />
  
  <requirements>
    - Convert to TypeScript with strict types
    - Implement proper error handling
    - Add comprehensive unit tests
    - Follow clean code principles
  </requirements>
  
  <output-format>
    ## Refactored Code
    ```typescript
    [Refactored TypeScript code]
    ```
    
    ## Unit Tests
    ```typescript
    [Comprehensive test suite]
    ```
    
    ## Migration Notes
    [Key changes and considerations]
  </output-format>
</poml>
```

### 3. 데이터 분석 및 인사이트

```xml
<poml>
  <role>Senior data analyst with business intelligence expertise</role>
  <task>Analyze user behavior patterns and provide actionable insights</task>
  
  <table src="user_analytics.csv" format="markdown" />
  <table src="conversion_funnel.xlsx" sheet="Summary" />
  
  <let analysis_period="Q4 2024" />
  <let target_conversion="12%" />
  
  <context>
    Business goals: Increase user engagement and conversion rates
    Previous period baseline: {% raw %}{{ baseline_metrics }}{% endraw %}
  </context>
  
  <output-format>
    # User Behavior Analysis - {% raw %}{{ analysis_period }}{% endraw %}
    
    ## Key Findings
    [Top 3-5 insights from data]
    
    ## Conversion Analysis
    - Current rate vs target ({% raw %}{{ target_conversion }}{% endraw %})
    - Bottlenecks identified
    - Opportunities for improvement
    
    ## Recommendations
    [Specific, actionable recommendations with expected impact]
  </output-format>
</poml>
```

## 트러블슈팅

### 일반적인 문제들

**1. VS Code 확장이 작동하지 않음**
- VS Code 재시작
- 확장 업데이트 확인
- 설정에서 API 키 재설정

**2. 파일 경로 오류**
```xml
<!-- ❌ 절대 경로 사용 금지 -->
<document src="/Users/username/file.txt" />

<!-- ✅ 상대 경로 사용 -->
<document src="./data/file.txt" />
```

**3. 템플릿 변수 렌더링 실패**
```xml
<!-- ❌ 잘못된 문법 -->
<task>Analyze {{ data_file }}</task>

<!-- ✅ 올바른 문법 -->
<task>Analyze {% raw %}{{ data_file }}{% endraw %}</task>
```

**4. 스타일 적용 안됨**
```xml
<!-- 스타일시트를 먼저 정의해야 함 -->
<stylesheet>
  .detailed { verbosity: high; }
</stylesheet>

<task class="detailed">...</task>
```

### 디버깅 팁

1. **VS Code 출력 패널 확인**: View → Output → POML 선택
2. **단계별 테스트**: 복잡한 프롬프트를 작은 단위로 분할하여 테스트
3. **문법 검증**: VS Code에서 실시간 진단 기능 활용
4. **로그 확인**: SDK 사용 시 verbose 모드 활성화

## 다음 단계

1. **고급 템플릿 패턴** 학습
2. **커스텀 컴포넌트** 개발
3. **팀 프롬프트 라이브러리** 구축
4. **CI/CD 파이프라인** 통합
5. **성능 최적화** 및 캐싱 전략

## 참고 링크

- POML 공식 문서: [microsoft.github.io/poml](https://microsoft.github.io/poml/)
- GitHub 리포지토리: [microsoft/poml](https://github.com/microsoft/poml)
- VS Code 마켓플레이스: POML 확장
- Discord 커뮤니티: POML 사용자 그룹

## 결론

POML은 프롬프트 엔지니어링의 패러다임을 바꾸는 강력한 도구입니다. 구조화된 마크업, 데이터 통합, 템플릿 엔진, 스타일 분리 등의 기능을 통해 복잡한 LLM 애플리케이션을 체계적으로 개발할 수 있습니다. VS Code 확장과 SDK를 활용하여 팀 단위의 프롬프트 관리와 재사용성을 크게 향상시킬 수 있습니다.
