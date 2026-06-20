---
title: "NoteGen AI 마크다운 앱 완전 가이드 - 소스 컴파일부터 Docker까지"
excerpt: "AI 기반 크로스플랫폼 마크다운 노트 앱 NoteGen을 소스에서 컴파일하고 도커라이징하는 완전 가이드. RAG, 임베딩, 다중 AI 모델 지원 기능까지 상세히 다룹니다."
seo_title: "NoteGen AI 마크다운 앱 완전 가이드 - 소스 컴파일 Docker 설정 - Thaki Cloud"
seo_description: "AI 기반 크로스플랫폼 마크다운 노트 앱 NoteGen 소스 컴파일, Docker 설정, AI LLM 기능 완전 가이드. Tauri Next.js 기반 앱 개발 튜토리얼"
date: 2025-07-01
last_modified_at: 2025-07-01
categories:
  - tutorials
tags:
  - notegen
  - ai
  - markdown
  - tauri
  - nextjs
  - docker
  - rag
  - embedding
  - llm
  - chatgpt
  - ollama
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/notegen-ai-markdown-app-complete-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 서론

[NoteGen](https://github.com/codexu/note-gen)은 AI를 활용한 혁신적인 크로스플랫폼 마크다운 노트 앱입니다. Tauri2와 Next.js 기반으로 구축되어 데스크톱과 모바일을 모두 지원하며, ChatGPT, Gemini, Ollama 등 다양한 AI 모델과 RAG(Retrieval-Augmented Generation) 기능을 제공합니다.

이 가이드에서는 NoteGen을 소스에서 컴파일하고, Docker 환경을 구성하며, AI 기능을 상세히 살펴보겠습니다.

## 프로젝트 개요

### 주요 특징

- **경량**: 20MB 미만의 설치 파일
- **크로스플랫폼**: Windows, macOS, Linux, iOS, Android 지원
- **AI 통합**: 다중 AI 모델 지원 (ChatGPT, Gemini, Grok, Ollama, LM Studio 등)
- **RAG 기능**: 임베딩 모델과 리랭킹 모델 지원
- **오프라인**: 로컬 파일 시스템 기반
- **동기화**: GitHub, Gitee, WebDAV 지원

### 기술 스택

- **Frontend**: Next.js 15, React 19, TypeScript
- **Backend**: Tauri 2 (Rust)
- **UI**: Radix UI, Tailwind CSS
- **AI**: OpenAI SDK, 다중 프로바이더 지원
- **Database**: SQLite (벡터 데이터베이스)

## 개발 환경 설정

### 필수 요구사항

**macOS 환경 기준:**

```bash
# Node.js 및 pnpm 버전 확인
node --version  # v22.16.0+
pnpm --version  # v10.12.1+
```

**시스템 요구사항:**

- Node.js 22.16.0 이상
- Rust 1.70 이상
- pnpm (패키지 매니저)

### Rust 설치

```bash
# Rust 설치
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
source ~/.zshrc

# 버전 확인
rustc --version
cargo --version
```

### Tauri CLI 설치

```bash
# Tauri CLI 전역 설치
cargo install tauri-cli

# 또는 pnpm으로 설치
pnpm add -g @tauri-apps/cli
```

## 소스 컴파일 가이드

### 1. 저장소 클론

```bash
# 프로젝트 클론
git clone https://github.com/codexu/note-gen.git
cd note-gen

# 브랜치 확인 (dev 브랜치 사용)
git checkout dev
```

### 2. 의존성 설치

```bash
# pnpm으로 의존성 설치 (npm보다 권장)
pnpm install

# build scripts 승인 (필요시)
pnpm approve-builds
```

### 3. 개발 서버 실행

```bash
# Next.js 개발 서버 (웹 버전)
pnpm dev

# Tauri 개발 앱 실행 (데스크톱 버전)
pnpm tauri dev
```

### 4. 프로덕션 빌드

```bash
# 웹 빌드
pnpm build

# 데스크톱 앱 빌드
pnpm tauri build
```

## Docker 설정

NoteGen은 기본적으로 Dockerfile을 제공하지 않으므로, 웹 버전용 Docker 설정을 직접 구성해보겠습니다.

### Dockerfile 생성

```dockerfile
# 멀티스테이지 빌드
FROM node:22-alpine AS builder

# pnpm 설치
RUN npm install -g pnpm

WORKDIR /app

# 패키지 파일 복사
COPY package.json pnpm-lock.yaml ./

# 의존성 설치
RUN pnpm install --frozen-lockfile

# 소스 코드 복사
COPY . .

# 빌드
RUN pnpm build

# 프로덕션 스테이지
FROM node:22-alpine AS runner

RUN npm install -g pnpm serve

WORKDIR /app

# 프로덕션 의존성 설치
# COPY package.json pnpm-lock.yaml ./
# RUN pnpm install --prod --frozen-lockfile

# 빌드 결과물 복사
# COPY --from=builder /app/.next ./.next
# COPY --from=builder /app/public ./public
# COPY --from=builder /app/next.config.ts ./

# 정적 파일 서빙을 위한 빌드 결과물 복사
COPY --from=builder /app/out ./

# 포트 설정
EXPOSE 3456

# 서버 시작
# CMD ["pnpm", "start"]

# 정적 파일 서버 시작
CMD ["serve", "-s", ".", "-p", "3456"] 
```

### Docker Compose 설정

```yaml
# docker-compose.yml
version: '3.8'

services:
  notegen:
    build: .
    ports:
      - "3456:3456"
    environment:
      - NODE_ENV=production
    volumes:
      # 노트 데이터 영속화
      - notegen_data:/app/data
    restart: unless-stopped

volumes:
  notegen_data:
```

### Docker 실행

```bash
# 이미지 빌드 및 실행
docker-compose up -d

# 또는 직접 빌드
docker build -t notegen .
docker run -p 3456:3456 -v notegen_data:/app/data notegen
```

## AI 기능 상세 분석

### 지원 AI 모델

NoteGen은 다양한 AI 프로바이더를 지원합니다:

#### 1. 클라우드 AI 서비스

```typescript
// src/app/core/setting/config.tsx에서 확인
const aiProviders = [
  {
    key: 'chatgpt',
    title: 'ChatGPT',
    baseURL: 'https://api.openai.com/v1',
    apiKeyUrl: 'https://platform.openai.com/api-keys'
  },
  {
    key: 'gemini',
    title: 'Gemini',
    baseURL: 'https://generativelanguage.googleapis.com/v1beta/openai',
    apiKeyUrl: 'https://aistudio.google.com/app/apikey'
  },
  {
    key: 'grok',
    title: 'Grok',
    baseURL: 'https://api.x.ai/v1',
    apiKeyUrl: 'https://console.x.ai/'
  },
  {
    key: 'deepseek',
    title: 'DeepSeek',
    baseURL: 'https://api.deepseek.com',
    apiKeyUrl: 'https://platform.deepseek.com/api_keys'
  }
]
```

#### 2. 로컬 AI 서비스

```typescript
const localProviders = [
  {
    key: 'ollama',
    title: 'Ollama',
    baseURL: 'http://localhost:11434/v1'
  },
  {
    key: 'lmstudio',
    title: 'LM Studio',
    baseURL: 'http://localhost:1234/v1'
  }
]
```

### AI 클라이언트 생성

```typescript
// src/lib/ai.ts
export async function createOpenAIClient(aiConfig?: AiConfig) {
  const config = aiConfig || await getAISettings()
  if (!config) throw new Error('AI 설정을 찾을 수 없습니다')
  
  const { baseURL, apiKey, temperature = 0.7, topP = 1 } = config
  
  return new OpenAI({
    baseURL,
    apiKey,
    defaultQuery: { temperature, top_p: topP },
    dangerouslyAllowBrowser: true
  })
}
```

### 스트리밍 응답 처리

```typescript
export async function fetchAiStream(
  text: string, 
  onUpdate: (content: string) => void, 
  abortSignal?: AbortSignal
): Promise<string> {
  const { messages } = await prepareMessages(text)
  const openai = await createOpenAIClient()
  
  const stream = await openai.chat.completions.create({
    messages,
    stream: true,
    signal: abortSignal
  })
  
  let fullContent = ''
  
  for await (const chunk of stream) {
    const content = chunk.choices[0]?.delta?.content || ''
    fullContent += content
    onUpdate(fullContent)
  }
  
  return fullContent
}
```

## RAG (Retrieval-Augmented Generation) 기능

### 벡터 임베딩

```typescript
// src/lib/rag.ts
export async function processMarkdownFile(
  filePath: string, 
  fileContent?: string
): Promise<boolean> {
  try {
    const content = fileContent || await readTextFile(filePath)
    
    // 텍스트 청킹
    const chunks = chunkText(content, 1000, 200)
    const filename = filePath.split('/').pop() || filePath
    
    // 기존 벡터 삭제
    await deleteVectorDocumentsByFilename(filename)
    
    // 각 청크에 대해 임베딩 생성
    for (let i = 0; i < chunks.length; i++) {
      const chunk = chunks[i]
      const embedding = await fetchEmbedding(chunk)
      
      if (embedding) {
        await upsertVectorDocument({
          filename,
          chunk_id: i,
          content: chunk,
          embedding: JSON.stringify(embedding),
          updated_at: Date.now()
        })
      }
    }
    
    return true
  } catch (error) {
    console.error(`파일 처리 실패: ${filePath}`, error)
    return false
  }
}
```

### 텍스트 청킹 알고리즘

```typescript
export function chunkText(
  text: string, 
  chunkSize: number = 1000, 
  chunkOverlap: number = 200
): string[] {
  const chunks: string[] = []
  
  if (text.length <= chunkSize) {
    chunks.push(text)
    return chunks
  }
  
  // 문단 단위로 분할
  const paragraphs = text.split('\n\n')
  let currentChunk = ''
  
  for (const paragraph of paragraphs) {
    if (currentChunk.length + paragraph.length + 2 > chunkSize) {
      if (currentChunk.length > 0) {
        chunks.push(currentChunk)
        
        // 오버랩 부분 계산
        const overlapLength = Math.min(chunkOverlap, currentChunk.length)
        const lastChunkParts = currentChunk.split('\n\n')
        const overlapParts = []
        let currentLength = 0
        
        for (let i = lastChunkParts.length - 1; i >= 0; i--) {
          const part = lastChunkParts[i]
          if (currentLength + part.length + 2 <= overlapLength) {
            overlapParts.unshift(part)
            currentLength += part.length + 2
          } else {
            break
          }
        }
        
        currentChunk = overlapParts.join('\n\n')
      }
      currentChunk += paragraph + '\n\n'
    } else {
      currentChunk += paragraph + '\n\n'
    }
  }
  
  if (currentChunk.trim()) {
    chunks.push(currentChunk.trim())
  }
  
  return chunks
}
```

### 컨텍스트 검색

```typescript
export async function getContextForQuery(query: string): Promise<string> {
  try {
    // 쿼리 임베딩 생성
    const queryEmbedding = await fetchEmbedding(query)
    if (!queryEmbedding) return ''
    
    // 유사한 문서 검색 (코사인 유사도)
    const similarDocs = await getSimilarDocuments(queryEmbedding, 5)
    
    // 리랭킹 적용 (가능한 경우)
    const rerankModelAvailable = await checkRerankModelAvailable()
    let finalDocs = similarDocs
    
    if (rerankModelAvailable && similarDocs.length > 0) {
      finalDocs = await rerankDocuments(query, similarDocs)
    }
    
    // 컨텍스트 문자열 생성
    return finalDocs
      .map(doc => `파일: ${doc.filename}\n내용: ${doc.content}`)
      .join('\n\n---\n\n')
  } catch (error) {
    console.error('컨텍스트 검색 실패:', error)
    return ''
  }
}
```

### 리랭킹 모델

```typescript
export async function rerankDocuments(
  query: string,
  documents: {id: number, filename: string, content: string, similarity: number}[]
): Promise<{id: number, filename: string, content: string, similarity: number}[]> {
  try {
    const modelInfo = await getRerankModelInfo()
    if (!modelInfo) return documents
    
    const { baseURL, apiKey, model } = modelInfo
    const response = await fetch(baseURL + '/rerank', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model,
        query,
        documents: documents.map(doc => doc.content)
      })
    })
    
    if (!response.ok) return documents
    
    const data = await response.json()
    
    // 리랭킹 결과에 따라 문서 재정렬
    return data.results
      .map((result: any) => ({
        ...documents[result.index],
        similarity: result.relevance_score
      }))
      .sort((a: any, b: any) => b.similarity - a.similarity)
  } catch (error) {
    console.error('리랭킹 실패:', error)
    return documents
  }
}
```

## 실제 사용 예시

### AI 설정

1. **설정 페이지 접근**: 앱 실행 후 설정 버튼 클릭
2. **AI 모델 구성**: 
   - API 키 입력 (OpenAI, Anthropic 등)
   - 로컬 모델 URL 설정 (Ollama, LM Studio)
   - 모델명 지정

```bash
# Ollama 로컬 실행 예시
ollama serve
ollama pull llama3.1:8b
```

### 녹음 및 AI 대화

1. **녹음 페이지**: 스크린샷, 텍스트, 파일 등 다양한 형태로 정보 수집
2. **AI 어시스턴트**: 수집된 정보를 바탕으로 AI와 대화
3. **노트 생성**: 대화 내용을 정리하여 마크다운 노트로 변환

### RAG 활용

1. **문서 인덱싱**: 기존 마크다운 파일들을 벡터 데이터베이스에 저장
2. **컨텍스트 검색**: 질문 시 관련 문서 자동 검색
3. **지능형 답변**: 검색된 컨텍스트를 바탕으로 정확한 답변 생성

## 자동화 스크립트

### 빌드 자동화

```bash
#!/bin/bash
# build-notegen.sh

echo "🚀 NoteGen 빌드 시작..."

# 의존성 업데이트
echo "📦 의존성 설치..."
pnpm install

# 타입 체크
echo "🔍 타입 체크..."
pnpm run lint

# 빌드 실행
echo "🏗️  빌드 실행..."
if [ "$1" == "desktop" ]; then
    echo "🖥️  데스크톱 앱 빌드..."
    pnpm tauri build
else
    echo "🌐 웹 앱 빌드..."
    pnpm build
fi

echo "✅ 빌드 완료!"
```

### 개발 환경 설정

```bash
#!/bin/bash
# setup-dev.sh

echo "🛠️  NoteGen 개발 환경 설정..."

# Rust 설치 확인
if ! command -v rustc &> /dev/null; then
    echo "📥 Rust 설치 중..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    source ~/.zshrc
fi

# pnpm 설치 확인
if ! command -v pnpm &> /dev/null; then
    echo "📥 pnpm 설치 중..."
    npm install -g pnpm
fi

# Tauri CLI 설치
echo "📥 Tauri CLI 설치 중..."
cargo install tauri-cli

echo "✅ 개발 환경 설정 완료!"
echo "🎯 다음 명령어로 개발 서버를 시작하세요:"
echo "   pnpm dev      # 웹 버전"
echo "   pnpm tauri dev # 데스크톱 버전"
```

### zshrc Aliases

```bash
# ~/.zshrc에 추가
export NOTEGEN_DIR="$HOME/projects/note-gen"

# NoteGen 관련 alias
alias ng="cd $NOTEGEN_DIR"
alias ngdev="cd $NOTEGEN_DIR && pnpm dev"
alias ngtauri="cd $NOTEGEN_DIR && pnpm tauri dev"
alias ngbuild="cd $NOTEGEN_DIR && pnpm build"
alias ngdocker="cd $NOTEGEN_DIR && docker-compose up -d"

# 개발 도구 확인
alias checkdev="node --version && pnpm --version && rustc --version"
```

## 문제 해결

### 일반적인 오류

#### 1. 의존성 충돌

```bash
# npm 대신 pnpm 사용
rm -rf node_modules package-lock.json
pnpm install
```

#### 2. Rust 컴파일 오류

```bash
# Rust 툴체인 업데이트
rustup update
cargo clean
```

#### 3. Tauri 빌드 실패

```bash
# Tauri 의존성 재설치
cargo install tauri-cli --force
pnpm tauri info
```

### 성능 최적화

#### 청킹 파라미터 조정

```typescript
// 큰 문서용
const chunks = chunkText(content, 2000, 400)

// 정밀한 검색용
const chunks = chunkText(content, 500, 100)
```

#### 임베딩 배치 처리

```typescript
async function batchProcessFiles(files: string[]) {
  const batchSize = 5
  for (let i = 0; i < files.length; i += batchSize) {
    const batch = files.slice(i, i + batchSize)
    await Promise.all(batch.map(processMarkdownFile))
    
    // API 레이트 리밋 고려
    await new Promise(resolve => setTimeout(resolve, 1000))
  }
}
```

## 결론

NoteGen은 AI 기반 마크다운 노트 앱의 새로운 패러다임을 제시합니다. Tauri와 Next.js의 조합으로 뛰어난 성능과 크로스플랫폼 호환성을 제공하며, 다양한 AI 모델과 RAG 기능으로 지능형 노트 작성을 가능하게 합니다.

### 주요 장점

- **경량화**: 20MB 미만의 설치 파일
- **유연성**: 다중 AI 프로바이더 지원
- **확장성**: 플러그인 아키텍처
- **프라이버시**: 로컬 데이터 저장

### 추천 사용 사례

- **연구 노트**: 논문과 자료를 AI로 분석하고 정리
- **개발 문서**: 코드와 문서를 연결한 지식 관리
- **학습 노트**: AI 튜터와 함께하는 스마트 학습
- **회의록**: 음성과 텍스트를 통합한 회의 기록

NoteGen은 단순한 노트 앱을 넘어 AI 시대의 지식 관리 도구로 자리잡을 잠재력을 가지고 있습니다. 오픈소스 프로젝트로서 커뮤니티의 기여를 통해 지속적으로 발전할 것으로 기대됩니다. 