---
title: "Deep Chat: 완전히 커스터마이징 가능한 AI 챗봇 컴포넌트 구축하기 - 완벽 가이드"
excerpt: "단 한 줄의 코드로 웹사이트에 통합할 수 있는 강력한 AI 챗봇 컴포넌트 Deep Chat의 설치부터 OpenAI 연동, 음성 인식 및 카메라 지원 등 고급 기능까지 단계별로 완벽하게 안내합니다."
seo_title: "Deep Chat AI 챗봇 튜토리얼: 완벽한 통합 가이드 - Thaki Cloud"
seo_description: "Deep Chat 완벽 가이드 - OpenAI, HuggingFace, 커스텀 API 연동 방법. React, Vue, Angular 예제와 음성-텍스트 변환 기능 포함."
date: 2025-10-02
lang: ko
permalink: /ko/tutorials/deep-chat-ai-chatbot-complete-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/deep-chat-ai-chatbot-complete-guide/"
categories:
  - tutorials
tags:
  - deep-chat
  - ai-챗봇
  - openai
  - react
  - vue
  - angular
  - 음성인식
  - 웹컴포넌트
author_profile: true
toc: true
toc_label: "목차"
---

⏱️ **예상 읽기 시간**: 15분

## 소개

Deep Chat은 **단 한 줄의 코드**만으로 웹사이트에 완전히 커스터마이징 가능한 AI 챗봇을 추가할 수 있는 혁신적인 웹 컴포넌트입니다. 고객 지원 시스템, AI 어시스턴트, 대화형 인터페이스 등 무엇을 만들든 Deep Chat은 필요한 모든 기능을 즉시 제공합니다.

### Deep Chat의 특별한 점

- **프레임워크 독립적**: React, Vue, Angular, Svelte, 순수 JavaScript 모두 지원
- **직접 API 연결**: OpenAI, HuggingFace, Cohere 등과 직접 연결
- **풍부한 미디어 지원**: 텍스트, 이미지, 파일, 오디오, 비디오 처리
- **음성 통합**: 음성-텍스트 및 텍스트-음성 기능 내장
- **완전한 커스터마이징**: 모든 요소를 스타일링하고 설정 가능
- **브라우저 기반 LLM**: Web LLM으로 브라우저에서 직접 AI 모델 실행

## 1부: 설치 및 기본 설정

### 사전 준비사항

시작하기 전에 다음이 필요합니다:
- Node.js 14+ 설치
- 패키지 매니저(npm, yarn, 또는 pnpm)
- HTML과 JavaScript 기본 지식

### 설치

**순수 JavaScript 또는 TypeScript** 프로젝트:

```bash
npm install deep-chat
```

**React** 프로젝트:

```bash
npm install deep-chat-react
```

### 기본 구현

#### 순수 JavaScript/HTML

간단한 HTML 파일 생성:

```html
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deep Chat 데모</title>
    <script type="module">
        import 'deep-chat';
    </script>
</head>
<body>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px;"
        introMessage='{"text": "환영합니다! 오늘 무엇을 도와드릴까요?"}'
    ></deep-chat>
</body>
</html>
```

#### React 구현

```jsx
import { DeepChat } from 'deep-chat-react';

function App() {
    return (
        <div className="App">
            <DeepChat
                style={% raw %}{{borderRadius: '10px', width: '100%', height: '600px'}}{% endraw %}
                introMessage={% raw %}{{text: "환영합니다! 오늘 무엇을 도와드릴까요?"}}{% endraw %}}
            />
        </div>
    );
}

export default App;
```

#### Vue 3 구현

```vue
<template>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px"
        :introMessage="introMessage"
    />
</template>

<script setup>
import 'deep-chat';

const introMessage = { text: "환영합니다! 오늘 무엇을 도와드릴까요?" };
</script>
```

## 2부: OpenAI 연결하기

Deep Chat의 가장 강력한 기능 중 하나는 OpenAI와 같은 AI 서비스에 직접 연결할 수 있다는 것입니다.

### 직접 연결 (개발 전용)

**⚠️ 경고**: 이 방법은 브라우저에 API 키를 노출합니다. 로컬 개발/데모 용도로만 사용하세요.

```html
<deep-chat
    directConnection='{
        "openAI": {
            "key": "your-api-key-here",
            "chat": {
                "model": "gpt-4",
                "max_tokens": 1000,
                "temperature": 0.7
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 프로덕션 환경: 프록시 서버

프로덕션 환경에서는 백엔드 프록시를 생성하세요:

**Express.js 서버 예제:**

```javascript
// server.js
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/chat', async (req, res) => {
    try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
            },
            body: JSON.stringify({
                model: 'gpt-4',
                messages: req.body.messages,
                max_tokens: 1000,
                temperature: 0.7
            })
        });

        const data = await response.json();
        res.json({
            text: data.choices[0].message.content
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`서버가 포트 ${PORT}에서 실행 중입니다`);
});
```

**프론트엔드 설정:**

```html
<deep-chat
    request='{"url": "http://localhost:3000/chat", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## 3부: 채팅 인터페이스 커스터마이징

### 아바타와 이름 추가

```html
<deep-chat
    avatars='{
        "default": {
            "styles": {"avatar": {"width": "40px", "height": "40px"}}
        },
        "ai": {
            "src": "https://example.com/ai-avatar.png"
        },
        "user": {
            "src": "https://example.com/user-avatar.png"
        }
    }'
    names='{"ai": "AI 어시스턴트", "user": "나"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 메시지 스타일링

```html
<deep-chat
    messageStyles='{
        "default": {
            "shared": {
                "bubble": {
                    "maxWidth": "80%",
                    "borderRadius": "12px",
                    "padding": "12px"
                }
            },
            "user": {
                "bubble": {
                    "backgroundColor": "#007AFF",
                    "color": "white"
                }
            },
            "ai": {
                "bubble": {
                    "backgroundColor": "#F0F0F0",
                    "color": "#000000"
                }
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## 4부: 고급 기능

### 1. 파일 업로드 지원

사용자가 이미지와 문서를 업로드할 수 있도록 설정:

```html
<deep-chat
    textInput='{"files": {"button": {"position": "inside-left"}}}'
    request='{"url": "http://localhost:3000/upload", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 2. 음성-텍스트 변환 통합

음성 입력 활성화:

```html
<deep-chat
    speechToText='{"webSpeech": true}'
    microphone='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 3. 응답을 위한 텍스트-음성 변환

AI가 응답을 읽어주도록 설정:

```html
<deep-chat
    textToSpeech='{"webSpeech": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 4. 카메라 통합

채팅에서 직접 사진 촬영:

```html
<deep-chat
    camera='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 5. 마크다운 지원

풍부한 텍스트 서식 활성화:

```html
<deep-chat
    textToSpeech='{"displayMarkdown": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## 5부: Web Model을 사용한 브라우저 기반 LLM

서버 없이 브라우저에서 완전히 AI 모델 실행:

**1단계: Web LLM 패키지 설치**

```bash
npm install deep-chat-web-llm
```

**2단계: Deep Chat 설정**

```html
<script type="module">
    import 'deep-chat';
    import 'deep-chat-web-llm';
</script>

<deep-chat
    webModel='{"model": "Mistral-7B-Instruct-v0.2-q4f32_1"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

**장점:**
- ✅ API 비용 없음
- ✅ 완전한 프라이버시 (데이터가 브라우저를 벗어나지 않음)
- ✅ 오프라인 작동
- ✅ 서버 불필요

## 6부: 프로그래밍 방식으로 메시지 처리

### 커스텀 로직이 있는 React 예제

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function App() {
    const [chatHistory, setChatHistory] = useState([]);

    const handleNewMessage = (message) => {
        console.log('새 메시지:', message);
        setChatHistory(prev => [...prev, message]);
    };

    const customHandler = async (body, signals) => {
        try {
            // 커스텀 API 호출
            const response = await fetch('https://your-api.com/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            const data = await response.json();
            
            // Deep Chat 형식으로 응답 반환
            return { text: data.message };
        } catch (error) {
            return { error: error.message };
        }
    };

    return (
        <DeepChat
            handler={customHandler}
            onMessage={handleNewMessage}
            style={% raw %}{{borderRadius: '10px', width: '100%', height: '600px'}}{% endraw %}}
        />
    );
}
```

### 스트리밍 응답

실시간 스트리밍 응답(ChatGPT와 유사):

```javascript
const streamHandler = async (body, signals) => {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${API_KEY}`
        },
        body: JSON.stringify({
            ...body,
            stream: true
        }),
        signal: signals.controller.signal
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullText = '';

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(line => line.trim() !== '');

        for (const line of lines) {
            if (line.startsWith('data: ')) {
                const data = line.slice(6);
                if (data === '[DONE]') continue;

                try {
                    const parsed = JSON.parse(data);
                    const content = parsed.choices[0]?.delta?.content || '';
                    fullText += content;
                    signals.onResponse({ text: fullText });
                } catch (e) {
                    console.error('파싱 오류:', e);
                }
            }
        }
    }
};
```

## 7부: 구현 테스트하기

### 테스트 스크립트 생성

`test-deep-chat.sh`로 저장:

```bash
#!/bin/bash

echo "🚀 Deep Chat 테스트 스크립트"
echo "========================"

# Node.js 설치 확인
if ! command -v node &> /dev/null; then
    echo "❌ Node.js가 설치되지 않았습니다. Node.js를 먼저 설치해주세요."
    exit 1
fi

echo "✅ Node.js 버전: $(node --version)"

# 테스트 디렉토리 생성
TEST_DIR="deep-chat-test"
echo "📁 테스트 디렉토리 생성: $TEST_DIR"
mkdir -p $TEST_DIR
cd $TEST_DIR

# 프로젝트 초기화
echo "📦 npm 프로젝트 초기화..."
npm init -y

# 의존성 설치
echo "📥 deep-chat 설치 중..."
npm install deep-chat

# 테스트 HTML 파일 생성
echo "📝 테스트 HTML 파일 생성..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Deep Chat 테스트</title>
    <script type="module">
        import 'deep-chat';
    </script>
    <style>
        body {
            font-family: 'Malgun Gothic', Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #007AFF;
        }
    </style>
</head>
<body>
    <h1>Deep Chat 테스트</h1>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px; border: 2px solid #007AFF;"
        introMessage='{"text": "안녕하세요! AI 어시스턴트입니다. 메시지를 보내보세요!"}'
        messageStyles='{
            "default": {
                "user": {
                    "bubble": {
                        "backgroundColor": "#007AFF",
                        "color": "white"
                    }
                }
            }
        }'
    ></deep-chat>
</body>
</html>
EOF

echo "✅ 테스트 파일이 성공적으로 생성되었습니다!"
echo ""
echo "🌐 테스트 방법:"
echo "   1. 실행: npx serve"
echo "   2. 열기: http://localhost:3000"
echo ""
echo "📂 테스트 디렉토리: $(pwd)"
```

### 테스트 실행

```bash
chmod +x test-deep-chat.sh
./test-deep-chat.sh
```

## 8부: 모범 사례 및 팁

### 1. 보안 모범 사례

- **프론트엔드 코드에 API 키를 절대 노출하지 마세요**
- 프로덕션에서는 항상 백엔드 프록시 사용
- 서버에 속도 제한 구현
- 모든 사용자 입력을 검증하고 정제

### 2. 성능 최적화

```javascript
// 더 나은 초기 페이지 로드를 위해 Deep Chat 지연 로딩
const loadDeepChat = async () => {
    await import('deep-chat');
    // 로딩 후 채팅 초기화
};

// 사용자가 채팅 섹션으로 스크롤할 때 로드
const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
        loadDeepChat();
        observer.disconnect();
    }
});

observer.observe(document.querySelector('#chat-container'));
```

### 3. 오류 처리

```javascript
const chatElement = document.querySelector('deep-chat');

chatElement.addEventListener('error', (event) => {
    console.error('채팅 오류:', event.detail);
    // 사용자 친화적인 오류 메시지 표시
    chatElement.appendChild({
        role: 'ai',
        text: '죄송합니다, 오류가 발생했습니다. 다시 시도해주세요.'
    });
});
```

### 4. 접근성

```html
<deep-chat
    aria-label="AI 채팅 어시스턴트"
    aria-describedby="chat-description"
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
<p id="chat-description" class="sr-only">
    AI 어시스턴트와 대화할 수 있는 인터랙티브 채팅 인터페이스
</p>
```

## 완성 예제: 모든 기능을 갖춘 채팅 애플리케이션

여러 기능을 결합한 완전한 React 애플리케이션:

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function FullFeaturedChat() {
    const [isLoading, setIsLoading] = useState(false);
    const [messageCount, setMessageCount] = useState(0);

    const customHandler = async (body, signals) => {
        setIsLoading(true);
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            if (!response.ok) {
                throw new Error(`HTTP 오류! 상태: ${response.status}`);
            }

            const data = await response.json();
            setMessageCount(prev => prev + 1);
            
            return { text: data.message };
        } catch (error) {
            console.error('채팅 오류:', error);
            return { 
                error: '죄송합니다, 오류가 발생했습니다. 다시 시도해주세요.' 
            };
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div style={% raw %}{{ 
            maxWidth: '1200px', 
            margin: '0 auto', 
            padding: '20px' 
        }}{% endraw %}}>
            <div style={% raw %}{{ 
                marginBottom: '20px', 
                display: 'flex', 
                justifyContent: 'space-between' 
            }}{% endraw %}}>
                <h1>AI 채팅 어시스턴트</h1>
                <div>
                    메시지 수: {messageCount}
                    {isLoading && ' (로딩 중...)'}
                </div>
            </div>

            <DeepChat
                handler={customHandler}
                introMessage={% raw %}{{
                    text: "👋 환영합니다! AI 어시스턴트입니다. 다음과 같은 도움을 드릴 수 있습니다:\n\n" +
                          "• 질문에 답변하기\n" +
                          "• 이미지 분석하기 (파일 업로드)\n" +
                          "• 음성 대화 (마이크 사용)\n\n" +
                          "오늘 무엇을 도와드릴까요?"
                }}{% endraw %}}
                textInput={% raw %}{{
                    files: { button: { position: "inside-left" } },
                    placeholder: { text: "메시지를 입력하세요..." }
                }}{% endraw %}}
                microphone={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}}
                speechToText={% raw %}{{ webSpeech: true }}{% endraw %}}
                textToSpeech={% raw %}{{ webSpeech: true }}{% endraw %}}
                camera={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}}
                avatars={% raw %}{{
                    ai: { 
                        src: "https://api.dicebear.com/7.x/bottts/svg?seed=ai" 
                    },
                    user: { 
                        src: "https://api.dicebear.com/7.x/personas/svg?seed=user" 
                    }
                }}{% endraw %}}
                names={% raw %}{{ ai: "AI 어시스턴트", user: "나" }}{% endraw %}}
                messageStyles={% raw %}{{
                    default: {
                        shared: {
                            bubble: {
                                maxWidth: "80%",
                                borderRadius: "12px",
                                padding: "12px 16px"
                            }
                        },
                        user: {
                            bubble: {
                                backgroundColor: "#007AFF",
                                color: "white"
                            }
                        },
                        ai: {
                            bubble: {
                                backgroundColor: "#F0F0F0",
                                color: "#000000"
                            }
                        }
                    }
                }}{% endraw %}}
                style={% raw %}{{
                    borderRadius: '16px',
                    border: '2px solid #E5E5EA',
                    width: '100%',
                    height: '700px',
                    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
                }}{% endraw %}}
            />
        </div>
    );
}

export default FullFeaturedChat;
```

## 결론

Deep Chat은 웹 애플리케이션에 AI 채팅 기능을 추가하기 위한 강력하고 유연한 솔루션입니다. 광범위한 기능 세트, 프레임워크 지원, 커스터마이징 옵션을 통해 간단한 챗봇부터 정교한 AI 어시스턴트까지 무엇이든 만들 수 있습니다.

### 핵심 요약

1. **쉬운 통합**: 단 한 줄의 코드로 챗봇 추가
2. **프레임워크 유연성**: React, Vue, Angular 등과 호환
3. **AI 서비스 통합**: OpenAI, HuggingFace, Cohere 직접 연결
4. **풍부한 기능**: 음성, 카메라, 파일 업로드 등
5. **완전한 커스터마이징**: 브랜드에 맞게 모든 요소 스타일링
6. **프로덕션 준비**: 백엔드 프록시를 통한 적절한 보안 관행

### 다음 단계

- [deepchat.dev](https://deepchat.dev)에서 공식 문서 탐색
- 더 많은 예제를 위해 GitHub 저장소 확인
- 커뮤니티에 참여하고 기여하기
- 자신만의 커스텀 통합 구축하기

### 참고 자료

- 📚 [공식 문서](https://deepchat.dev)
- 💻 [GitHub 저장소](https://github.com/OvidijusParsiunas/deep-chat)
- 🎮 [인터랙티브 플레이그라운드](https://deepchat.dev/playground)
- 📺 [비디오 튜토리얼](https://www.youtube.com/@DeepChat)

즐거운 코딩 되세요! 🚀

