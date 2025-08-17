---
title: "Yank Note: 고도로 확장 가능한 마크다운 에디터 완전 가이드 - AI 코파일럿부터 플러그인 개발까지"
excerpt: "Monaco 커널 기반의 Yank Note로 버전 관리, AI 코파일럿, 마인드 맵, 문서 암호화, 코드 실행 등 강력한 기능을 마스터하는 완전한 가이드입니다."
seo_title: "Yank Note 마크다운 에디터 완전 가이드 - VSCode 경험의 생산성 도구 - Thaki Cloud"
seo_description: "Yank Note의 설치부터 고급 기능까지. AI 코파일럿, 버전 관리, 플러그인 개발, 문서 암호화, 코드 실행 등 모든 기능을 상세하게 설명하는 완전 가이드"
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - tutorials
tags:
  - yank-note
  - markdown-editor
  - electron
  - ai-copilot
  - monaco-editor
  - version-control
  - document-encryption
  - plugin-development
  - productivity
  - vue
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/yank-note-markdown-editor-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 18분

## 개요

[Yank Note](https://github.com/purocean/yn)는 생산성 향상을 위해 설계된 **고도로 확장 가능한 마크다운 에디터**입니다. **GitHub 6.2k개의 스타**와 활발한 커뮤니티를 보유한 이 도구는 Monaco 커널(VSCode 편집기 엔진)을 사용하여 VSCode와 동일한 편집 경험을 제공하면서도, 마크다운 작성에 특화된 혁신적인 기능들을 제공합니다.

### 🎯 Yank Note의 핵심 가치

- **VSCode 급 편집 경험**: Monaco 에디터로 최고 수준의 텍스트 편집 환경
- **확장성**: 사용자 정의 플러그인으로 무한한 기능 확장
- **생산성**: AI 코파일럿, 버전 관리, 코드 실행 등 통합 기능
- **보안**: 파일별 암호화로 민감한 정보 안전 보관
- **호환성**: 표준 마크다운 문법을 유지하면서 고급 기능 제공

## Yank Note란 무엇인가?

### 🚀 차세대 마크다운 에디터

Yank Note는 단순한 텍스트 에디터를 넘어선 **종합적인 문서 작성 플랫폼**입니다:

```
아이디어 → Yank Note 작성 → 버전 관리 → AI 지원 → 출판/공유
```

### 🏗️ 현대적 아키텍처

**Electron + Vue.js 기반**:
- 크로스 플랫폼 지원 (Windows, macOS, Linux)
- 현대적 웹 기술로 빠른 성능
- 풍부한 UI/UX 경험

**Monaco 에디터 통합**:
- VSCode와 동일한 편집 엔진
- 문법 하이라이팅과 자동 완성
- 키보드 단축키 호환성

### 🔧 주요 특징 개요

| 기능 | 설명 | 활용도 |
|------|------|--------|
| **AI 코파일럿** | OpenAI 기반 자동 완성 | ⭐⭐⭐⭐⭐ |
| **버전 관리** | Git 스타일 문서 히스토리 | ⭐⭐⭐⭐⭐ |
| **암호화** | 파일별 개별 암호화 | ⭐⭐⭐⭐⭐ |
| **코드 실행** | 인라인 스크립트 실행 | ⭐⭐⭐⭐ |
| **플러그인** | JavaScript 기반 확장 | ⭐⭐⭐⭐⭐ |

## 시스템 요구사항

### 🖥️ 지원 플랫폼

**Desktop 환경**:
- **Windows**: Windows 10 이상
- **macOS**: macOS 10.14 이상
- **Linux**: Ubuntu 18.04, Debian 10, CentOS 8 이상

**하드웨어 요구사항**:
- **메모리**: 최소 4GB, 권장 8GB
- **저장 공간**: 500MB 여유 공간
- **CPU**: Intel i3 또는 AMD 동급 이상

### 🌐 웹 버전 지원

브라우저에서도 사용 가능:
- Chrome 90+
- Firefox 88+
- Safari 14+
- Edge 90+

## 설치 및 초기 설정

### 1단계: 다운로드

**공식 다운로드 페이지**:
- [GitHub Releases](https://github.com/purocean/yn/releases)
- [공식 웹사이트](https://yank-note.com)

**플랫폼별 설치 파일**:
```bash
# Windows
YankNote-3.84.0-win-x64.exe

# macOS (Apple Silicon)
YankNote-3.84.0-mac-arm64.dmg

# macOS (Intel)
YankNote-3.84.0-mac-x64.dmg

# Linux
YankNote-3.84.0-linux-x86_64.AppImage
YankNote-3.84.0-linux-amd64.deb
```

### 2단계: 플랫폼별 설치

#### macOS 설치
```bash
# Homebrew를 통한 설치 (권장)
brew install --cask yank-note

# 수동 설치
# 1. DMG 파일 다운로드
# 2. DMG 마운트
# 3. Yank Note.app을 Applications 폴더로 드래그
# 4. 첫 실행 시 보안 설정에서 허용
```

#### Windows 설치
```bash
# Chocolatey를 통한 설치
choco install yanknote

# 수동 설치
# 1. EXE 파일 다운로드 및 실행
# 2. 설치 마법사 따라하기
# 3. 바탕화면 바로가기 생성 선택
```

#### Linux 설치
```bash
# Ubuntu/Debian
sudo dpkg -i YankNote-3.84.0-linux-amd64.deb

# AppImage (모든 배포판)
chmod +x YankNote-3.84.0-linux-x86_64.AppImage
./YankNote-3.84.0-linux-x86_64.AppImage

# Snap Store
sudo snap install yank-note
```

### 3단계: 초기 환경 설정

#### 첫 실행 설정
```bash
# 1. 애플리케이션 실행
# 2. 데이터 저장 위치 설정
#    - 기본: ~/Documents/YankNote
#    - 사용자 정의: 원하는 디렉토리 선택

# 3. 언어 설정
#    - English (기본)
#    - 中文 (중국어)
#    - 한국어 지원 플러그인 설치 필요

# 4. 테마 설정
#    - Light Theme (기본)
#    - Dark Theme
#    - 사용자 정의 테마
```

#### 기본 설정 최적화
```json
{
  "editor.wordWrap": "on",
  "editor.fontSize": 14,
  "editor.lineHeight": 1.6,
  "editor.fontFamily": "Monaco, 'Courier New', monospace",
  "editor.minimap.enabled": false,
  "editor.folding": true,
  "preview.syncScroll": true,
  "preview.theme": "github"
}
```

## 핵심 기능 상세 가이드

### 📝 기본 편집 기능

#### Monaco 에디터 활용
```markdown
# VSCode와 동일한 단축키
Ctrl/Cmd + P: 빠른 파일 열기
Ctrl/Cmd + Shift + P: 명령 팔레트
Ctrl/Cmd + D: 단어 선택
Alt + Click: 다중 커서
Ctrl/Cmd + /: 주석 토글

# 마크다운 특화 기능
Ctrl/Cmd + B: **굵게**
Ctrl/Cmd + I: *기울임*
Ctrl/Cmd + K: [링크](url)
Ctrl/Cmd + Shift + K: ```코드 블록```
```

#### 동시 편집 및 미리보기
```
┌─────────────┬─────────────┐
│ 편집 영역   │ 미리보기     │
│             │             │
│ # 제목      │ 제목        │
│ **굵게**    │ 굵게        │
│ - 리스트    │ • 리스트    │
│             │             │
└─────────────┴─────────────┘
       ↕️ 동기화 스크롤
```

### 🔒 문서 암호화

#### 암호화 파일 생성
```bash
# 암호화 파일 생성 (확장자 .c.md)
새 파일 → 파일명.c.md

# 암호 설정
첫 저장 시 → 암호 입력 → 확인

# 암호화된 내용 예시
---
encrypted: true
cipher: aes-256-gcm
---

# 민감한 정보
계정: my-secret-account
비밀번호: super-secret-password
API 키: sk-1234567890abcdef
```

#### 암호화 보안 가이드
```bash
# 강력한 암호 생성 규칙
✅ 12자 이상
✅ 대소문자, 숫자, 특수문자 조합
✅ 사전에 없는 단어
❌ 개인정보 사용 금지
❌ 다른 서비스와 동일한 암호 사용 금지

# 암호 관리 팁
1. 암호 관리자 사용 (1Password, Bitwarden)
2. 복구 힌트를 별도 보관
3. 정기적인 암호 변경
```

### 📊 버전 관리

#### 자동 버전 추적
```bash
# 변경 사항 자동 감지
편집 → 자동 저장 → 버전 생성

# 버전 히스토리 보기
Ctrl/Cmd + H → 버전 목록 → 비교/복원

# 버전 정보 예시
Version 1.0.0 (2025-08-15 09:00)
+ Added introduction section
+ Created table of contents

Version 1.0.1 (2025-08-15 10:30)
* Modified code example
- Removed outdated information
```

#### 고급 버전 관리
```javascript
// 커스텀 버전 태그
---
version: "1.2.0"
tags: ["release", "stable"]
changelog: |
  - Added new features
  - Fixed critical bugs
  - Updated dependencies
---

// 브랜치 관리 (플러그인 필요)
main: 메인 문서
feature/new-section: 새 섹션 작업
hotfix/typo-fix: 오타 수정
```

### 🤖 AI 코파일럿

#### OpenAI 통합 설정
```bash
# API 키 설정
설정 → AI → OpenAI API Key 입력

# 모델 선택
- GPT-4: 최고 품질 (느림, 비쌈)
- GPT-3.5-turbo: 균형 (권장)
- GPT-3.5-turbo-16k: 긴 컨텍스트

# 사용량 제한 설정
월 사용량: $50
일 요청 수: 100개
```

#### AI 활용 예시
```markdown
<!-- AI 자동 완성 -->
## 머신러닝 개요

머신러닝은 [AI 제안: 데이터로부터 패턴을 학습하여...]

<!-- 코드 생성 -->
```python
# TODO: 선형 회귀 구현
[AI 제안: 
import numpy as np
from sklearn.linear_model import LinearRegression

# 데이터 준비
X = np.array([[1], [2], [3], [4]])
y = np.array([2, 4, 6, 8])

# 모델 훈련
model = LinearRegression()
model.fit(X, y)
]
```

<!-- 번역 기능 -->
AI: "Translate to English"
→ 선택된 한국어 텍스트를 영어로 번역
```

### ⚙️ 코드 실행

#### 지원 언어
```bash
# JavaScript/Node.js
```javascript
console.log("Hello, World!");
const data = [1, 2, 3, 4, 5];
console.log("Sum:", data.reduce((a, b) => a + b, 0));
```
<!-- 출력: Hello, World! Sum: 15 -->

# Python
```python
import matplotlib.pyplot as plt
import numpy as np

x = np.linspace(0, 10, 100)
y = np.sin(x)

plt.plot(x, y)
plt.title("Sine Wave")
plt.show()
```
<!-- 차트가 문서에 직접 표시됨 -->

# Bash
```bash
echo "Current directory: $(pwd)"
ls -la | head -5
date
```
<!-- 실시간 터미널 출력 -->
```

#### 코드 실행 환경 설정
```json
{
  "codeRunner": {
    "javascript": {
      "command": "node",
      "timeout": 30000,
      "showOutput": true
    },
    "python": {
      "command": "python3",
      "timeout": 60000,
      "showOutput": true,
      "env": {
        "PYTHONPATH": "/custom/path"
      }
    },
    "bash": {
      "command": "bash",
      "timeout": 10000,
      "showOutput": true
    }
  }
}
```

### 📈 차트 및 다이어그램

#### PlantUML 다이어그램
```plantuml
@startuml
actor User
participant "Yank Note" as YN
participant "AI Service" as AI
database "Local Files" as DB

User -> YN: 문서 작성
YN -> AI: 자동 완성 요청
AI --> YN: 제안 내용
YN -> DB: 자동 저장
YN --> User: 실시간 미리보기
@enduml
```

#### Mermaid 플로우차트
```mermaid
graph TD
    A[문서 작성] --> B{암호화 필요?}
    B -->|Yes| C[암호 설정]
    B -->|No| D[일반 저장]
    C --> E[암호화 저장]
    D --> F[버전 관리]
    E --> F
    F --> G[AI 자동 완성]
    G --> H[최종 출력]
```

#### ECharts 인터랙티브 차트
```echarts
{
  "title": {
    "text": "월별 문서 작성량"
  },
  "xAxis": {
    "type": "category",
    "data": ["1월", "2월", "3월", "4월", "5월", "6월"]
  },
  "yAxis": {
    "type": "value"
  },
  "series": [{
    "data": [120, 200, 150, 80, 70, 110],
    "type": "bar",
    "itemStyle": {
      "color": "#4CAF50"
    }
  }]
}
```

### 🧠 마인드 맵

#### 자동 마인드 맵 변환
```markdown
# 프로젝트 계획
- 기획 단계
  - 요구사항 분석
    - 기능 요구사항
    - 비기능 요구사항
  - 사용자 리서치
    - 설문 조사
    - 인터뷰
- 설계 단계
  - UI/UX 설계
  - 시스템 아키텍처
- 개발 단계
  - 프론트엔드
  - 백엔드
  - 테스트
```

위 목록이 자동으로 마인드 맵으로 변환됩니다:
```
프로젝트 계획
├── 기획 단계
│   ├── 요구사항 분석
│   └── 사용자 리서치
├── 설계 단계
└── 개발 단계
```

## 실전 활용 예제

### 예제 1: 기술 문서 작성

```markdown
---
title: "API 문서"
version: "1.0.0"
tags: ["api", "documentation"]
---

# REST API 가이드

## 인증

```javascript
// API 키 인증 예시
const response = await fetch('/api/users', {
  headers: {
    'Authorization': 'Bearer YOUR_API_KEY',
    'Content-Type': 'application/json'
  }
});
```

## 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| GET | `/api/users` | 사용자 목록 조회 |
| POST | `/api/users` | 새 사용자 생성 |

```plantuml
@startuml
participant Client
participant API
participant Database

Client -> API: POST /api/users
API -> Database: INSERT user
Database --> API: success
API --> Client: 201 Created
@enduml
```
```

### 예제 2: 프로젝트 회의록

```markdown
---
encrypted: true
meeting: "주간 스프린트 리뷰"
date: "2025-08-15"
attendees: ["김개발", "박기획", "이디자인"]
---

# 주간 스프린트 리뷰 회의록 🔒

## 완료된 작업
- [x] 로그인 API 개발 (김개발)
- [x] UI 목업 완성 (이디자인)
- [x] 요구사항 문서 업데이트 (박기획)

## 진행 중인 작업
- [ ] 데이터베이스 스키마 설계
- [ ] 프론트엔드 컴포넌트 개발

## 다음 주 계획

```mermaid
gantt
    title 다음 주 일정
    dateFormat  YYYY-MM-DD
    section 개발팀
    API 개발    :2025-08-16, 3d
    테스트 작성 :2025-08-19, 2d
    section 디자인팀
    프로토타입  :2025-08-16, 4d
```

## 기밀 정보 🚨
- 서버 접속 정보: `ssh admin@secret-server.com`
- 데이터베이스 패스워드: `超Secret123!`
```

### 예제 3: 학습 노트

```markdown
# 머신러닝 학습 노트

## 선형 회귀 실습

### 이론
선형 회귀는 독립 변수 X와 종속 변수 y 사이의 선형 관계를 모델링합니다.

공식: $y = wx + b$

### 실습 코드
```python
import numpy as np
import matplotlib.pyplot as plt
from sklearn.linear_model import LinearRegression

# 샘플 데이터 생성
np.random.seed(42)
X = np.random.randn(100, 1)
y = 2 * X.ravel() + np.random.randn(100)

# 모델 훈련
model = LinearRegression()
model.fit(X, y)

# 예측
y_pred = model.predict(X)

# 시각화
plt.scatter(X, y, alpha=0.6)
plt.plot(X, y_pred, color='red', linewidth=2)
plt.title('Linear Regression Example')
plt.xlabel('X')
plt.ylabel('y')
plt.show()

print(f"기울기: {model.coef_[0]:.2f}")
print(f"절편: {model.intercept_:.2f}")
```

### 결과 분석
모델이 학습한 기울기는 실제 값(2.0)에 가깝고, 
데이터의 선형 관계를 잘 포착했습니다.
```

## macOS에서 테스트해보기

실제로 Yank Note를 macOS에서 설치하고 테스트할 수 있는 스크립트를 작성해보겠습니다.

### 자동 설치 및 테스트 스크립트

```bash
#!/bin/bash
# yank-note-test-setup.sh

echo "🚀 Yank Note 설치 및 테스트 스크립트"
echo "===================================="

# 1. Homebrew 확인
if command -v brew &> /dev/null; then
    echo "✅ Homebrew 확인됨"
else
    echo "❌ Homebrew 필요: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# 2. Yank Note 설치
echo "📥 Yank Note 설치 중..."
if brew list --cask yank-note &> /dev/null; then
    echo "✅ Yank Note 이미 설치됨"
else
    brew install --cask yank-note
    echo "✅ Yank Note 설치 완료"
fi

# 3. 테스트 문서 디렉토리 생성
TEST_DIR="$HOME/YankNote-Test-$(date +%Y%m%d)"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 4. 샘플 문서 생성
cat > "01-기본-테스트.md" << 'EOF'
# Yank Note 기본 기능 테스트

## 텍스트 포맷팅
**굵게**, *기울임*, ~~취소선~~, `코드`

## 목록
- 항목 1
- 항목 2
  - 하위 항목 2.1
  - 하위 항목 2.2

## 표
| 항목 | 설명 | 상태 |
|------|------|------|
| 설치 | Yank Note 설치 | ✅ |
| 테스트 | 기능 확인 | 🔄 |

## 코드 블록
```javascript
console.log("Hello, Yank Note!");
const sum = (a, b) => a + b;
console.log("2 + 3 =", sum(2, 3));
```

## 수식
인라인 수식: $E = mc^2$

블록 수식:
$$
\int_{-\infty}^{\infty} e^{-x^2} dx = \sqrt{\pi}
$$
EOF

# 5. 암호화 테스트 문서 생성
cat > "02-암호화-테스트.c.md" << 'EOF'
# 암호화 문서 테스트 🔒

이 문서는 암호화되어 저장됩니다.

## 기밀 정보
- 테스트 계정: test@example.com
- 테스트 비밀번호: SecretPassword123!

## 중요 사항
- 암호를 절대 잊지 마세요
- 정기적으로 백업하세요
EOF

# 6. AI 테스트 문서 생성
cat > "03-AI-테스트.md" << 'EOF'
# AI 코파일럿 테스트

## AI 자동 완성 요청
머신러닝은 <!-- AI에게 완성 요청 -->

## 코드 생성 요청
```python
# TODO: 피보나치 수열 생성기 구현
<!-- AI에게 코드 생성 요청 -->
```

## 번역 테스트
Hello, World! <!-- 한국어로 번역 요청 -->
EOF

# 7. 다이어그램 테스트 문서 생성
cat > "04-다이어그램-테스트.md" << 'EOF'
# 다이어그램 기능 테스트

## Mermaid 플로우차트
```mermaid
graph TD
    A[시작] --> B{조건}
    B -->|Yes| C[처리]
    B -->|No| D[종료]
    C --> D
```

## PlantUML 시퀀스 다이어그램
```plantuml
@startuml
Alice -> Bob: 안녕하세요
Bob --> Alice: 안녕하세요!
Alice -> Bob: 잘 지내세요?
Bob --> Alice: 네, 감사합니다.
@enduml
```
EOF

# 8. 사용 가이드 생성
cat > "README.md" << 'EOF'
# Yank Note 테스트 가이드

## 설치 확인
1. Spotlight 검색(Cmd + Space)에서 "Yank Note" 검색
2. 애플리케이션 실행

## 테스트 순서
1. `01-기본-테스트.md` - 기본 마크다운 기능 확인
2. `02-암호화-테스트.c.md` - 암호화 기능 테스트
3. `03-AI-테스트.md` - AI 코파일럿 기능 (API 키 필요)
4. `04-다이어그램-테스트.md` - 차트 및 다이어그램 기능

## 주요 단축키
- `Cmd + P`: 파일 빠른 열기
- `Cmd + Shift + P`: 명령 팔레트
- `Cmd + B`: 굵게
- `Cmd + I`: 기울임
- `Cmd + K`: 링크 삽입

## AI 설정 (선택사항)
1. 설정 → AI → OpenAI API Key 입력
2. 모델 선택: GPT-3.5-turbo 권장
3. 월 사용량 제한 설정

## 플러그인 개발 (고급)
플러그인 디렉토리: `~/YankNote/plugins/`
EOF

echo ""
echo "🎉 Yank Note 테스트 환경 준비 완료!"
echo "================================="
echo ""
echo "📁 테스트 디렉토리: $TEST_DIR"
echo ""
echo "🚀 다음 단계:"
echo "1. Spotlight에서 'Yank Note' 검색 및 실행"
echo "2. File → Open Folder → $TEST_DIR 선택"
echo "3. README.md부터 순서대로 테스트"
echo ""
echo "📋 생성된 테스트 파일:"
echo "- 01-기본-테스트.md: 기본 마크다운 기능"
echo "- 02-암호화-테스트.c.md: 암호화 기능"
echo "- 03-AI-테스트.md: AI 코파일럿 기능"
echo "- 04-다이어그램-테스트.md: 차트/다이어그램"
echo "- README.md: 사용 가이드"

# 9. Yank Note 실행 (선택사항)
read -p "지금 Yank Note를 실행하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "🚀 Yank Note 실행 중..."
    open -a "Yank Note" "$TEST_DIR"
else
    echo "✅ 테스트 환경 준비 완료. 언제든지 Yank Note로 $TEST_DIR 폴더를 열어서 테스트하세요!"
fi
```

## 플러그인 개발 가이드

### 기본 플러그인 구조

```javascript
// ~/YankNote/plugins/my-plugin/index.js

module.exports = {
  name: 'my-plugin',
  version: '1.0.0',
  description: '나만의 플러그인',
  
  // 플러그인 초기화
  activate(ctx) {
    console.log('플러그인 활성화됨');
    
    // 메뉴 항목 추가
    ctx.addMenuItem({
      id: 'my-action',
      label: '내 기능',
      onclick: () => {
        ctx.showMessage('안녕하세요!');
      }
    });
    
    // 에디터 명령 등록
    ctx.addCommand({
      id: 'insert-date',
      title: '현재 날짜 삽입',
      callback: () => {
        const date = new Date().toISOString().split('T')[0];
        ctx.editor.insertText(date);
      }
    });
  },
  
  // 플러그인 비활성화
  deactivate(ctx) {
    console.log('플러그인 비활성화됨');
  }
};
```

### 고급 플러그인 예제

```javascript
// 마크다운 테이블 자동 포맷팅 플러그인
module.exports = {
  name: 'table-formatter',
  version: '1.0.0',
  
  activate(ctx) {
    // 테이블 포맷팅 함수
    function formatTable(text) {
      const lines = text.split('\n');
      const tableLines = [];
      let inTable = false;
      
      for (const line of lines) {
        if (line.includes('|')) {
          inTable = true;
          const cells = line.split('|').map(cell => cell.trim());
          const formattedLine = '| ' + cells.join(' | ') + ' |';
          tableLines.push(formattedLine);
        } else if (inTable) {
          break;
        }
      }
      
      return tableLines.join('\n');
    }
    
    // 단축키 등록
    ctx.addKeybinding({
      key: 'Ctrl+Shift+T',
      callback: () => {
        const selection = ctx.editor.getSelection();
        if (selection) {
          const formatted = formatTable(selection);
          ctx.editor.replaceSelection(formatted);
        }
      }
    });
  }
};
```

## 고급 활용 팁

### 워크플로우 자동화

```markdown
<!-- 매크로 대체 기능 -->
오늘 날짜: {{new Date().toLocaleDateString('ko-KR')}}
현재 시간: {{new Date().toLocaleTimeString('ko-KR')}}
문서 경로: {{ctx.currentFile.path}}
작성자: {{process.env.USER || 'Unknown'}}

<!-- 동적 목차 생성 -->
{{
  const headings = ctx.document.getHeadings();
  headings.map(h => `${'  '.repeat(h.level-1)}- [${h.text}](#${h.anchor})`).join('\n')
}}
```

### 팀 협업 설정

```json
{
  "team": {
    "repository": "/shared/docs",
    "syncInterval": 30,
    "conflictResolution": "manual",
    "backup": {
      "enabled": true,
      "interval": "1h",
      "location": "/backup/docs"
    }
  },
  "notifications": {
    "onChange": true,
    "onConflict": true,
    "onBackup": false
  }
}
```

## zshrc Aliases 설정

개발 효율성을 높이기 위한 유용한 alias들을 설정해보겠습니다:

```bash
# ~/.zshrc에 추가할 Yank Note 관련 alias들

# Yank Note 실행 단축 명령어
alias yn="open -a 'Yank Note'"
alias yank="open -a 'Yank Note'"
alias yanknote="open -a 'Yank Note'"

# 특정 디렉토리에서 Yank Note 실행
alias yn-docs="open -a 'Yank Note' ~/Documents"
alias yn-projects="open -a 'Yank Note' ~/Projects"
alias yn-notes="open -a 'Yank Note' ~/Notes"

# Yank Note 설정 및 플러그인 관리
alias yn-config="open ~/YankNote"
alias yn-plugins="open ~/YankNote/plugins"
alias yn-backup="cp -r ~/YankNote ~/YankNote-backup-$(date +%Y%m%d)"

# 마크다운 파일 빠른 생성
alias mkmd='function _mkmd(){ echo "# $1" > "$1.md" && yn "$1.md"; }; _mkmd'
alias mkenc='function _mkenc(){ echo "# $1" > "$1.c.md" && yn "$1.c.md"; }; _mkenc'

# 테스트 환경 설정
alias yn-test="cd ~/YankNote-Test && yn ."
alias yn-setup="curl -O https://raw.githubusercontent.com/purocean/yn/develop/scripts/test-setup.sh && chmod +x test-setup.sh && ./test-setup.sh"

# 유용한 마크다운 도구들
alias md2pdf="pandoc -o output.pdf"
alias md2html="pandoc -o output.html"
alias count-words="wc -w"
```

### alias 적용 방법

```bash
# 1. zshrc 파일 편집
nano ~/.zshrc

# 2. 위의 alias들을 파일 끝에 추가

# 3. 변경사항 적용
source ~/.zshrc

# 4. alias 확인
alias | grep yn
```

## 트러블슈팅

### 자주 발생하는 문제들

**1. 앱이 실행되지 않음 (macOS)**
```bash
# 해결 방법
sudo xattr -r -d com.apple.quarantine "/Applications/Yank Note.app"
```

**2. 암호화된 파일이 열리지 않음**
```bash
# 원인: 잘못된 암호 또는 파일 손상
# 해결 방법: 
# 1. 암호 재확인
# 2. 백업 파일에서 복원
# 3. 파일 복구 도구 사용 (파일이 손상된 경우)
```

**3. AI 기능이 작동하지 않음**
```bash
# 원인 확인:
# 1. API 키 유효성
# 2. 네트워크 연결
# 3. 사용량 한도 초과

# 해결 방법:
# 1. 설정 → AI → API 키 재입력
# 2. 네트워크 상태 확인
# 3. OpenAI 계정에서 사용량 확인
```

**4. 플러그인이 로드되지 않음**
```bash
# 플러그인 디렉토리 확인
ls ~/YankNote/plugins/

# 플러그인 로그 확인
Console.app에서 "Yank Note" 검색

# 플러그인 재설치
rm -rf ~/YankNote/plugins/plugin-name
# 플러그인 재다운로드 및 설치
```

## 보안 고려사항

### 중요한 보안 주의사항

1. **신뢰할 수 없는 파일 주의**: Yank Note는 코드 실행 기능으로 인해 악성 스크립트에 취약할 수 있습니다.
2. **암호 관리**: 암호화된 파일의 암호는 복구 불가능하므로 안전하게 보관하세요.
3. **플러그인 검증**: 제3자 플러그인 설치 시 코드를 검토하세요.
4. **정기 백업**: 중요한 문서는 정기적으로 백업하세요.

## 결론

Yank Note는 **마크다운 편집의 새로운 표준**을 제시하는 혁신적인 도구입니다. VSCode의 편집 경험을 마크다운에 최적화하여 제공하면서도, AI 코파일럿, 버전 관리, 문서 암호화, 플러그인 시스템 등 다양한 고급 기능을 통해 문서 작성의 생산성을 극대화합니다.

### 🎯 핵심 장점 요약

1. **최고의 편집 경험**: Monaco 에디터로 VSCode급 편집 환경
2. **포괄적 기능**: AI 지원부터 암호화까지 모든 기능을 하나에
3. **확장성**: 플러그인으로 무한한 기능 확장
4. **크로스 플랫폼**: Windows, macOS, Linux 모두 지원

### 🚀 앞으로의 전망

Yank Note의 지속적인 발전과 활발한 오픈소스 커뮤니티를 바탕으로, 마크다운 기반 문서 작성의 **필수 도구**로 자리잡을 것으로 예상됩니다. 특히 AI 기능의 발전과 함께 더욱 지능적이고 효율적인 문서 작성 경험을 제공할 것입니다.

지금 바로 [Yank Note](https://github.com/purocean/yn)를 설치해서 차세대 마크다운 편집의 새로운 경험을 시작해보세요! 🚀

---

**관련 글:**
- [마크다운 완전 가이드](https://thakicloud.github.io/tutorials/markdown-complete-guide/)
- [VSCode 확장 프로그램 개발](https://thakicloud.github.io/dev/vscode-extension-development/)
- [Electron 앱 개발 가이드](https://thakicloud.github.io/tutorials/electron-app-development/)
