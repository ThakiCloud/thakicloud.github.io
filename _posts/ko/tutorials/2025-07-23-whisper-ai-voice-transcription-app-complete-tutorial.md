---
title: "AI 음성 전사 앱 개발 완전 가이드: Whisper + Together.ai로 구축하는 현대적 음성 메모 시스템"
excerpt: "Together.ai, Next.js, Clerk을 활용하여 음성을 텍스트로 변환하고 AI로 변형하는 전문적인 음성 전사 앱을 단계별로 구축하는 실전 튜토리얼"
seo_title: "Whisper AI 음성 전사 앱 개발 튜토리얼 - Next.js Together.ai 완전 가이드 - Thaki Cloud"
seo_description: "Together.ai Whisper 모델과 Next.js를 사용한 AI 음성 전사 앱 개발 방법을 실전 코드와 함께 상세히 알아보세요. 인증, 파일 업로드, AI 변환까지 포함된 완전한 가이드입니다."
date: 2025-07-23
last_modified_at: 2025-07-23
categories:
  - tutorials
  - dev
tags:
  - Whisper
  - 음성전사
  - TogetherAI
  - NextJS
  - AI음성처리
  - Clerk인증
  - S3업로드
  - 음성메모앱
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/whisper-ai-voice-transcription-app-complete-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 서론

음성 기술이 일상에 깊숙이 자리잡으면서, 음성을 텍스트로 변환하고 AI로 가공하는 애플리케이션의 수요가 급증하고 있습니다. 회의록 작성, 강의 노트 정리, 아이디어 캡처 등 다양한 용도로 활용되는 음성 전사 앱을 직접 구축해보겠습니다.

이 튜토리얼에서는 [Nutlope의 Whisper 앱](https://github.com/Nutlope/whisper)을 참고하여, Together.ai의 Whisper 모델과 최신 웹 기술을 활용한 전문적인 음성 전사 시스템을 단계별로 구축합니다.

## 프로젝트 개요

### 핵심 기능

1. **음성 파일 업로드**: 다양한 오디오 포맷 지원
2. **AI 음성 전사**: Together.ai Whisper 모델 활용
3. **AI 텍스트 변환**: 요약, 추출, 분석 등
4. **사용자 인증**: Clerk을 통한 안전한 로그인
5. **대시보드**: 전사 기록 관리 및 검색

### 기술 스택

```yaml
tech_stack:
  frontend:
    - framework: "Next.js 14 App Router"
    - styling: "Tailwind CSS"
    - ui_components: "shadcn/ui"
    - state_management: "React Query"
  
  backend:
    - api: "Next.js API Routes"
    - orm: "Prisma"
    - database: "Neon PostgreSQL"
    - file_storage: "AWS S3"
  
  ai_services:
    - transcription: "Together.ai Whisper"
    - llm_framework: "Vercel AI SDK"
    - text_processing: "Together.ai LLM"
  
  infrastructure:
    - hosting: "Vercel"
    - authentication: "Clerk"
    - rate_limiting: "Upstash Redis"
    - monitoring: "Vercel Analytics"
```

## 프로젝트 설정

### 1. 환경 구성

```bash
# 프로젝트 생성
npx create-next-app@latest whisper-ai-app --typescript --tailwind --eslint --app
cd whisper-ai-app

# 필수 패키지 설치
npm install @clerk/nextjs @prisma/client prisma
npm install @aws-sdk/client-s3 @aws-sdk/s3-request-presigner
npm install @upstash/redis ai @ai-sdk/core
npm install @radix-ui/react-icons lucide-react
npm install class-variance-authority clsx tailwind-merge

# 개발 의존성
npm install -D @types/node
```

### 2. 환경 변수 설정

```bash
# .env.local 파일 생성
cat > .env.local << EOF
# Database
DATABASE_URL="postgresql://username:password@host:5432/whisper_db"

# Clerk Authentication
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY="pk_test_..."
CLERK_SECRET_KEY="sk_test_..."
NEXT_PUBLIC_CLERK_SIGN_IN_URL="/sign-in"
NEXT_PUBLIC_CLERK_SIGN_UP_URL="/sign-up"

# Together.ai
TOGETHER_API_KEY="your_together_api_key"

# AWS S3
AWS_ACCESS_KEY_ID="your_aws_access_key"
AWS_SECRET_ACCESS_KEY="your_aws_secret_key"
AWS_REGION="us-east-1"
AWS_S3_BUCKET_NAME="whisper-audio-files"

# Upstash Redis
UPSTASH_REDIS_REST_URL="https://your-redis.upstash.io"
UPSTASH_REDIS_REST_TOKEN="your_redis_token"

# App
NEXT_PUBLIC_APP_URL="http://localhost:3000"
EOF
```

## 데이터베이스 설계

### Prisma 스키마 설정

```prisma
// prisma/schema.prisma
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id        String   @id @default(cuid())
  clerkId   String   @unique
  email     String   @unique
  name      String?
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt

  transcriptions Transcription[]

  @@map("users")
}

model Transcription {
  id          String            @id @default(cuid())
  title       String
  audioUrl    String
  originalText String?
  duration    Int? // seconds
  status      TranscriptionStatus @default(PENDING)
  createdAt   DateTime          @default(now())
  updatedAt   DateTime          @updatedAt

  userId      String
  user        User              @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  transformations Transformation[]

  @@map("transcriptions")
}

model Transformation {
  id            String            @id @default(cuid())
  type          TransformationType
  prompt        String
  result        String
  createdAt     DateTime          @default(now())

  transcriptionId String
  transcription   Transcription     @relation(fields: [transcriptionId], references: [id], onDelete: Cascade)

  @@map("transformations")
}

enum TranscriptionStatus {
  PENDING
  PROCESSING
  COMPLETED
  FAILED
}

enum TransformationType {
  SUMMARY
  BULLET_POINTS
  ACTION_ITEMS
  KEYWORDS
  CUSTOM
}
```

### 데이터베이스 초기화

```bash
# Prisma 초기화
npx prisma generate
npx prisma db push

# 개발 환경에서 데이터베이스 확인
npx prisma studio
```

## 핵심 컴포넌트 구현

### 1. Clerk 인증 설정

```typescript
// app/layout.tsx
import { ClerkProvider } from '@clerk/nextjs'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <ClerkProvider>
      <html lang="ko">
        <body className={inter.className}>
          {children}
        </body>
      </html>
    </ClerkProvider>
  )
}
```

```typescript
// middleware.ts
import { authMiddleware } from '@clerk/nextjs'

export default authMiddleware({
  publicRoutes: ['/'],
  ignoredRoutes: ['/api/webhook'],
})

export const config = {
  matcher: ['/((?!.+\\.[\\w]+$|_next).*)', '/', '/(api|trpc)(.*)'],
}
```

### 2. 오디오 파일 업로드 컴포넌트

```typescript
// components/audio-upload.tsx
'use client'

import { useState, useCallback } from 'react'
import { useDropzone } from 'react-dropzone'
import { Upload, Music, AlertCircle } from 'lucide-react'
import { Button } from '@/components/ui/button'
import { Card, CardContent } from '@/components/ui/card'
import { Progress } from '@/components/ui/progress'

interface AudioUploadProps {
  onUploadComplete: (audioUrl: string, fileName: string) => void
  isUploading: boolean
}

export function AudioUpload({ onUploadComplete, isUploading }: AudioUploadProps) {
  const [uploadProgress, setUploadProgress] = useState(0)
  const [error, setError] = useState<string | null>(null)

  const onDrop = useCallback(async (acceptedFiles: File[]) => {
    const file = acceptedFiles[0]
    if (!file) return

    setError(null)
    setUploadProgress(0)

    try {
      // 프리사인 URL 생성
      const response = await fetch('/api/upload/presigned-url', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          fileName: file.name,
          fileType: file.type,
        }),
      })

      const { presignedUrl, audioUrl } = await response.json()

      // S3 업로드
      const uploadResponse = await fetch(presignedUrl, {
        method: 'PUT',
        body: file,
        headers: {
          'Content-Type': file.type,
        },
      })

      if (uploadResponse.ok) {
        onUploadComplete(audioUrl, file.name)
      } else {
        throw new Error('업로드 실패')
      }
    } catch (err) {
      setError('파일 업로드 중 오류가 발생했습니다.')
      console.error('Upload error:', err)
    }
  }, [onUploadComplete])

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      'audio/*': ['.mp3', '.wav', '.m4a', '.aac', '.ogg', '.flac']
    },
    maxSize: 100 * 1024 * 1024, // 100MB
    disabled: isUploading,
  })

  return (
    <Card className="w-full max-w-2xl mx-auto">
      <CardContent className="p-6">
        <div
          {...getRootProps()}
          className={`
            border-2 border-dashed rounded-lg p-8 text-center transition-colors cursor-pointer
            ${isDragActive ? 'border-blue-400 bg-blue-50' : 'border-gray-300'}
            ${isUploading ? 'opacity-50 cursor-not-allowed' : 'hover:border-gray-400'}
          `}
        >
          <input {...getInputProps()} />
          
          {isUploading ? (
            <div className="space-y-4">
              <Music className="mx-auto h-12 w-12 text-blue-500 animate-pulse" />
              <div>
                <p className="text-lg font-medium">업로드 중...</p>
                <Progress value={uploadProgress} className="mt-2" />
              </div>
            </div>
          ) : (
            <div className="space-y-4">
              <Upload className="mx-auto h-12 w-12 text-gray-400" />
              <div>
                <p className="text-lg font-medium">
                  {isDragActive ? '파일을 놓아주세요' : '오디오 파일을 드래그하거나 클릭하세요'}
                </p>
                <p className="text-sm text-gray-500 mt-1">
                  MP3, WAV, M4A, AAC, OGG, FLAC (최대 100MB)
                </p>
              </div>
            </div>
          )}
        </div>

        {error && (
          <div className="mt-4 flex items-center gap-2 text-red-600">
            <AlertCircle className="h-4 w-4" />
            <span className="text-sm">{error}</span>
          </div>
        )}
      </CardContent>
    </Card>
  )
}
```

### 3. S3 업로드 API

```typescript
// app/api/upload/presigned-url/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { S3Client, PutObjectCommand } from '@aws-sdk/client-s3'
import { getSignedUrl } from '@aws-sdk/s3-request-presigner'
import { auth } from '@clerk/nextjs'
import { v4 as uuidv4 } from 'uuid'

const s3Client = new S3Client({
  region: process.env.AWS_REGION!,
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID!,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY!,
  },
})

export async function POST(request: NextRequest) {
  try {
    const { userId } = auth()
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { fileName, fileType } = await request.json()
    
    // 고유한 파일명 생성
    const fileExtension = fileName.split('.').pop()
    const uniqueFileName = `${userId}/${uuidv4()}.${fileExtension}`

    // 프리사인 URL 생성
    const command = new PutObjectCommand({
      Bucket: process.env.AWS_S3_BUCKET_NAME!,
      Key: uniqueFileName,
      ContentType: fileType,
    })

    const presignedUrl = await getSignedUrl(s3Client, command, { expiresIn: 300 })
    const audioUrl = `https://${process.env.AWS_S3_BUCKET_NAME}.s3.${process.env.AWS_REGION}.amazonaws.com/${uniqueFileName}`

    return NextResponse.json({ presignedUrl, audioUrl })
  } catch (error) {
    console.error('Presigned URL generation error:', error)
    return NextResponse.json(
      { error: 'Failed to generate upload URL' },
      { status: 500 }
    )
  }
}
```

## AI 음성 전사 구현

### 1. Together.ai Whisper 전사 API

```typescript
// app/api/transcribe/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@clerk/nextjs'
import { prisma } from '@/lib/db'
import { rateLimiter } from '@/lib/rate-limiter'

export async function POST(request: NextRequest) {
  try {
    const { userId } = auth()
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Rate limiting
    const isAllowed = await rateLimiter.check(userId)
    if (!isAllowed) {
      return NextResponse.json(
        { error: 'Rate limit exceeded' },
        { status: 429 }
      )
    }

    const { audioUrl, title } = await request.json()

    // 전사 작업 생성
    const transcription = await prisma.transcription.create({
      data: {
        title,
        audioUrl,
        status: 'PROCESSING',
        userId: await getUserId(userId),
      },
    })

    // 백그라운드에서 전사 처리
    processTranscription(transcription.id, audioUrl)

    return NextResponse.json({ transcriptionId: transcription.id })
  } catch (error) {
    console.error('Transcription error:', error)
    return NextResponse.json(
      { error: 'Failed to start transcription' },
      { status: 500 }
    )
  }
}

async function processTranscription(transcriptionId: string, audioUrl: string) {
  try {
    // Together.ai Whisper API 호출
    const response = await fetch('https://api.together.xyz/v1/audio/transcriptions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${process.env.TOGETHER_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        file: audioUrl,
        model: 'whisper-large-v3',
        language: 'ko', // 한국어 지원
        response_format: 'verbose_json',
      }),
    })

    const result = await response.json()

    if (response.ok) {
      // 전사 결과 저장
      await prisma.transcription.update({
        where: { id: transcriptionId },
        data: {
          originalText: result.text,
          duration: result.duration,
          status: 'COMPLETED',
        },
      })
    } else {
      throw new Error(result.error?.message || 'Transcription failed')
    }
  } catch (error) {
    console.error('Transcription processing error:', error)
    
    // 실패 상태로 업데이트
    await prisma.transcription.update({
      where: { id: transcriptionId },
      data: { status: 'FAILED' },
    })
  }
}

async function getUserId(clerkId: string): Promise<string> {
  let user = await prisma.user.findUnique({
    where: { clerkId },
  })

  if (!user) {
    user = await prisma.user.create({
      data: {
        clerkId,
        email: '', // Clerk에서 가져올 수 있음
      },
    })
  }

  return user.id
}
```

### 2. Rate Limiting 구현

```typescript
// lib/rate-limiter.ts
import { Redis } from '@upstash/redis'

const redis = new Redis({
  url: process.env.UPSTASH_REDIS_REST_URL!,
  token: process.env.UPSTASH_REDIS_REST_TOKEN!,
})

export class RateLimiter {
  private limit: number
  private window: number

  constructor(limit: number = 10, windowInSeconds: number = 3600) {
    this.limit = limit
    this.window = windowInSeconds
  }

  async check(userId: string): Promise<boolean> {
    const key = `rate_limit:${userId}`
    const now = Math.floor(Date.now() / 1000)
    const windowStart = now - this.window

    try {
      // 현재 윈도우에서의 요청 수 확인
      const requests = await redis.zcount(key, windowStart, now)
      
      if (requests >= this.limit) {
        return false
      }

      // 새 요청 기록
      await redis.zadd(key, { score: now, member: `${now}-${Math.random()}` })
      
      // 만료된 항목 제거
      await redis.zremrangebyscore(key, 0, windowStart)
      
      // TTL 설정
      await redis.expire(key, this.window)

      return true
    } catch (error) {
      console.error('Rate limiter error:', error)
      return true // 에러 시 허용
    }
  }
}

export const rateLimiter = new RateLimiter(10, 3600) // 시간당 10회
```

## AI 텍스트 변환 기능

### 1. 텍스트 변환 API

```typescript
// app/api/transform/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@clerk/nextjs'
import { prisma } from '@/lib/db'
import { openai } from '@ai-sdk/openai'
import { generateText } from 'ai'

const TRANSFORMATION_PROMPTS = {
  SUMMARY: '다음 텍스트를 간결하고 핵심적인 내용으로 요약해주세요.',
  BULLET_POINTS: '다음 텍스트의 주요 포인트들을 불릿 포인트 형태로 정리해주세요.',
  ACTION_ITEMS: '다음 텍스트에서 실행해야 할 액션 아이템들을 추출해주세요.',
  KEYWORDS: '다음 텍스트의 핵심 키워드들을 추출해주세요.',
}

export async function POST(request: NextRequest) {
  try {
    const { userId } = auth()
    if (!userId) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    const { transcriptionId, type, customPrompt } = await request.json()

    // 전사 데이터 조회
    const transcription = await prisma.transcription.findFirst({
      where: {
        id: transcriptionId,
        user: { clerkId: userId },
      },
    })

    if (!transcription || !transcription.originalText) {
      return NextResponse.json(
        { error: 'Transcription not found' },
        { status: 404 }
      )
    }

    // 프롬프트 생성
    const systemPrompt = customPrompt || TRANSFORMATION_PROMPTS[type as keyof typeof TRANSFORMATION_PROMPTS]
    const fullPrompt = `${systemPrompt}\n\n텍스트:\n${transcription.originalText}`

    // AI 텍스트 변환
    const { text } = await generateText({
      model: openai('gpt-3.5-turbo'),
      prompt: fullPrompt,
      maxTokens: 1000,
    })

    // 변환 결과 저장
    const transformation = await prisma.transformation.create({
      data: {
        type: type || 'CUSTOM',
        prompt: systemPrompt,
        result: text,
        transcriptionId,
      },
    })

    return NextResponse.json({ 
      id: transformation.id,
      result: text 
    })
  } catch (error) {
    console.error('Transformation error:', error)
    return NextResponse.json(
      { error: 'Failed to transform text' },
      { status: 500 }
    )
  }
}
```

### 2. 텍스트 변환 컴포넌트

```typescript
// components/text-transformer.tsx
'use client'

import { useState } from 'react'
import { Button } from '@/components/ui/button'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Textarea } from '@/components/ui/textarea'
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select'
import { Loader2, Wand2 } from 'lucide-react'

interface TextTransformerProps {
  transcriptionId: string
  originalText: string
}

export function TextTransformer({ transcriptionId, originalText }: TextTransformerProps) {
  const [transformationType, setTransformationType] = useState<string>('')
  const [customPrompt, setCustomPrompt] = useState('')
  const [result, setResult] = useState<string>('')
  const [isTransforming, setIsTransforming] = useState(false)

  const transformationOptions = [
    { value: 'SUMMARY', label: '요약' },
    { value: 'BULLET_POINTS', label: '불릿 포인트' },
    { value: 'ACTION_ITEMS', label: '액션 아이템' },
    { value: 'KEYWORDS', label: '키워드 추출' },
    { value: 'CUSTOM', label: '커스텀' },
  ]

  const handleTransform = async () => {
    if (!transformationType) return

    setIsTransforming(true)
    try {
      const response = await fetch('/api/transform', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          transcriptionId,
          type: transformationType,
          customPrompt: transformationType === 'CUSTOM' ? customPrompt : undefined,
        }),
      })

      const data = await response.json()
      setResult(data.result)
    } catch (error) {
      console.error('Transformation error:', error)
    } finally {
      setIsTransforming(false)
    }
  }

  return (
    <div className="space-y-6">
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Wand2 className="h-5 w-5" />
            AI 텍스트 변환
          </CardTitle>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="flex gap-4">
            <Select value={transformationType} onValueChange={setTransformationType}>
              <SelectTrigger className="flex-1">
                <SelectValue placeholder="변환 유형 선택" />
              </SelectTrigger>
              <SelectContent>
                {transformationOptions.map((option) => (
                  <SelectItem key={option.value} value={option.value}>
                    {option.label}
                  </SelectItem>
                ))}
              </SelectContent>
            </Select>

            <Button 
              onClick={handleTransform} 
              disabled={!transformationType || isTransforming}
            >
              {isTransforming ? (
                <Loader2 className="h-4 w-4 animate-spin" />
              ) : (
                '변환'
              )}
            </Button>
          </div>

          {transformationType === 'CUSTOM' && (
            <Textarea
              placeholder="커스텀 프롬프트를 입력하세요..."
              value={customPrompt}
              onChange={(e) => setCustomPrompt(e.target.value)}
              rows={3}
            />
          )}
        </CardContent>
      </Card>

      {result && (
        <Card>
          <CardHeader>
            <CardTitle>변환 결과</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="prose max-w-none">
              <pre className="whitespace-pre-wrap font-sans">{result}</pre>
            </div>
          </CardContent>
        </Card>
      )}
    </div>
  )
}
```

## 대시보드 구현

### 1. 전사 목록 페이지

```typescript
// app/dashboard/page.tsx
import { auth } from '@clerk/nextjs'
import { redirect } from 'next/navigation'
import { prisma } from '@/lib/db'
import { TranscriptionList } from '@/components/transcription-list'
import { AudioUpload } from '@/components/audio-upload'

async function getTranscriptions(userId: string) {
  return await prisma.transcription.findMany({
    where: {
      user: { clerkId: userId },
    },
    orderBy: { createdAt: 'desc' },
    include: {
      transformations: true,
    },
  })
}

export default async function DashboardPage() {
  const { userId } = auth()
  
  if (!userId) {
    redirect('/sign-in')
  }

  const transcriptions = await getTranscriptions(userId)

  return (
    <div className="container mx-auto py-8 space-y-8">
      <div className="text-center space-y-4">
        <h1 className="text-3xl font-bold">음성 전사 대시보드</h1>
        <p className="text-gray-600">
          음성 파일을 업로드하고 AI로 전사 및 변환하세요
        </p>
      </div>

      <AudioUpload />

      <div className="space-y-4">
        <h2 className="text-2xl font-semibold">전사 기록</h2>
        <TranscriptionList transcriptions={transcriptions} />
      </div>
    </div>
  )
}
```

### 2. 전사 목록 컴포넌트

```typescript
// components/transcription-list.tsx
'use client'

import { useState } from 'react'
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card'
import { Badge } from '@/components/ui/badge'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Clock, FileText, Search, Trash2 } from 'lucide-react'
import { formatDistance } from 'date-fns'
import { ko } from 'date-fns/locale'

interface TranscriptionListProps {
  transcriptions: Array<{
    id: string
    title: string
    status: string
    createdAt: Date
    duration?: number | null
    transformations: Array<{
      id: string
      type: string
      createdAt: Date
    }>
  }>
}

export function TranscriptionList({ transcriptions }: TranscriptionListProps) {
  const [searchTerm, setSearchTerm] = useState('')

  const filteredTranscriptions = transcriptions.filter(t =>
    t.title.toLowerCase().includes(searchTerm.toLowerCase())
  )

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'COMPLETED': return 'bg-green-100 text-green-800'
      case 'PROCESSING': return 'bg-yellow-100 text-yellow-800'
      case 'FAILED': return 'bg-red-100 text-red-800'
      default: return 'bg-gray-100 text-gray-800'
    }
  }

  const formatDuration = (seconds?: number | null) => {
    if (!seconds) return null
    const minutes = Math.floor(seconds / 60)
    const remainingSeconds = seconds % 60
    return `${minutes}:${remainingSeconds.toString().padStart(2, '0')}`
  }

  return (
    <div className="space-y-4">
      <div className="flex items-center gap-2">
        <Search className="h-4 w-4 text-gray-400" />
        <Input
          placeholder="전사 기록 검색..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          className="max-w-sm"
        />
      </div>

      {filteredTranscriptions.length === 0 ? (
        <Card>
          <CardContent className="py-8 text-center text-gray-500">
            {searchTerm ? '검색 결과가 없습니다.' : '아직 전사 기록이 없습니다.'}
          </CardContent>
        </Card>
      ) : (
        <div className="grid gap-4">
          {filteredTranscriptions.map((transcription) => (
            <Card key={transcription.id} className="hover:shadow-md transition-shadow">
              <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                <CardTitle className="text-lg">{transcription.title}</CardTitle>
                <div className="flex items-center gap-2">
                  <Badge className={getStatusColor(transcription.status)}>
                    {transcription.status === 'COMPLETED' ? '완료' :
                     transcription.status === 'PROCESSING' ? '처리중' :
                     transcription.status === 'FAILED' ? '실패' : '대기중'}
                  </Badge>
                  <Button variant="ghost" size="sm">
                    <Trash2 className="h-4 w-4" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <div className="flex items-center justify-between text-sm text-gray-500">
                  <div className="flex items-center gap-4">
                    <div className="flex items-center gap-1">
                      <Clock className="h-4 w-4" />
                      {formatDistance(transcription.createdAt, new Date(), { 
                        addSuffix: true, 
                        locale: ko 
                      })}
                    </div>
                    {transcription.duration && (
                      <div className="flex items-center gap-1">
                        <FileText className="h-4 w-4" />
                        {formatDuration(transcription.duration)}
                      </div>
                    )}
                  </div>
                  <div className="text-xs">
                    변환 {transcription.transformations.length}개
                  </div>
                </div>
                
                {transcription.status === 'COMPLETED' && (
                  <div className="mt-3">
                    <Button variant="outline" size="sm">
                      상세 보기
                    </Button>
                  </div>
                )}
              </CardContent>
            </Card>
          ))}
        </div>
      )}
    </div>
  )
}
```

## 실시간 상태 업데이트

### 1. WebSocket 또는 SSE 구현

```typescript
// app/api/transcriptions/[id]/status/route.ts
import { NextRequest, NextResponse } from 'next/server'
import { auth } from '@clerk/nextjs'
import { prisma } from '@/lib/db'

export async function GET(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  const { userId } = auth()
  if (!userId) {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
  }

  try {
    const transcription = await prisma.transcription.findFirst({
      where: {
        id: params.id,
        user: { clerkId: userId },
      },
      include: {
        transformations: true,
      },
    })

    if (!transcription) {
      return NextResponse.json({ error: 'Not found' }, { status: 404 })
    }

    return NextResponse.json(transcription)
  } catch (error) {
    console.error('Status check error:', error)
    return NextResponse.json(
      { error: 'Failed to get status' },
      { status: 500 }
    )
  }
}
```

### 2. 폴링 기반 상태 확인

```typescript
// hooks/use-transcription-status.ts
import { useState, useEffect } from 'react'

interface TranscriptionStatus {
  id: string
  status: string
  originalText?: string
  duration?: number
}

export function useTranscriptionStatus(transcriptionId: string | null) {
  const [status, setStatus] = useState<TranscriptionStatus | null>(null)
  const [isLoading, setIsLoading] = useState(false)

  useEffect(() => {
    if (!transcriptionId) return

    let interval: NodeJS.Timeout

    const checkStatus = async () => {
      try {
        setIsLoading(true)
        const response = await fetch(`/api/transcriptions/${transcriptionId}/status`)
        const data = await response.json()
        setStatus(data)

        // 완료되거나 실패하면 폴링 중단
        if (data.status === 'COMPLETED' || data.status === 'FAILED') {
          clearInterval(interval)
        }
      } catch (error) {
        console.error('Status check error:', error)
      } finally {
        setIsLoading(false)
      }
    }

    // 즉시 실행
    checkStatus()

    // 5초마다 상태 확인
    interval = setInterval(checkStatus, 5000)

    return () => clearInterval(interval)
  }, [transcriptionId])

  return { status, isLoading }
}
```

## 성능 최적화 및 사용자 경험

### 1. 프로그레시브 업로드

```typescript
// components/progressive-upload.tsx
'use client'

import { useState } from 'react'
import { Progress } from '@/components/ui/progress'

export function ProgressiveUpload() {
  const [uploadProgress, setUploadProgress] = useState(0)

  const uploadWithProgress = async (file: File) => {
    const chunkSize = 1024 * 1024 // 1MB 청크
    const totalChunks = Math.ceil(file.size / chunkSize)
    
    for (let chunkIndex = 0; chunkIndex < totalChunks; chunkIndex++) {
      const start = chunkIndex * chunkSize
      const end = Math.min(start + chunkSize, file.size)
      const chunk = file.slice(start, end)
      
      // 청크 업로드
      await uploadChunk(chunk, chunkIndex, totalChunks)
      
      // 진행률 업데이트
      setUploadProgress(((chunkIndex + 1) / totalChunks) * 100)
    }
  }

  const uploadChunk = async (chunk: Blob, index: number, total: number) => {
    const formData = new FormData()
    formData.append('chunk', chunk)
    formData.append('chunkIndex', index.toString())
    formData.append('totalChunks', total.toString())

    await fetch('/api/upload/chunk', {
      method: 'POST',
      body: formData,
    })
  }

  return (
    <div className="space-y-2">
      <div className="flex justify-between text-sm">
        <span>업로드 진행률</span>
        <span>{Math.round(uploadProgress)}%</span>
      </div>
      <Progress value={uploadProgress} />
    </div>
  )
}
```

### 2. 에러 처리 및 재시도 로직

```typescript
// lib/retry-logic.ts
export class RetryableError extends Error {
  constructor(message: string, public retryAfter?: number) {
    super(message)
    this.name = 'RetryableError'
  }
}

export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries: number = 3,
  baseDelay: number = 1000
): Promise<T> {
  let lastError: Error

  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error
      
      if (attempt === maxRetries) {
        throw lastError
      }

      if (error instanceof RetryableError) {
        const delay = error.retryAfter || baseDelay * Math.pow(2, attempt)
        await new Promise(resolve => setTimeout(resolve, delay))
      } else {
        throw error
      }
    }
  }

  throw lastError!
}
```

## 테스트 및 배포

### 1. 유닛 테스트

```typescript
// __tests__/transcription.test.ts
import { describe, it, expect, jest } from '@jest/globals'
import { POST } from '@/app/api/transcribe/route'
import { NextRequest } from 'next/server'

// Clerk 모킹
jest.mock('@clerk/nextjs', () => ({
  auth: () => ({ userId: 'test-user-id' }),
}))

describe('/api/transcribe', () => {
  it('should create transcription successfully', async () => {
    const request = new NextRequest('http://localhost:3000/api/transcribe', {
      method: 'POST',
      body: JSON.stringify({
        audioUrl: 'https://example.com/audio.mp3',
        title: 'Test Audio',
      }),
    })

    const response = await POST(request)
    const data = await response.json()

    expect(response.status).toBe(200)
    expect(data.transcriptionId).toBeDefined()
  })

  it('should reject unauthorized requests', async () => {
    // userId를 null로 모킹
    jest.mocked(require('@clerk/nextjs').auth).mockReturnValue({ userId: null })

    const request = new NextRequest('http://localhost:3000/api/transcribe', {
      method: 'POST',
      body: JSON.stringify({
        audioUrl: 'https://example.com/audio.mp3',
        title: 'Test Audio',
      }),
    })

    const response = await POST(request)
    expect(response.status).toBe(401)
  })
})
```

### 2. 환경별 배포 설정

```yaml
# .github/workflows/deploy.yml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run test
      - run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
      - uses: actions/checkout@v3
      - uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

## 모니터링 및 분석

### 1. 사용량 추적

```typescript
// lib/analytics.ts
export class AnalyticsTracker {
  static async trackTranscription(userId: string, duration: number, success: boolean) {
    try {
      await fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: 'transcription_completed',
          userId,
          properties: { duration, success },
        }),
      })
    } catch (error) {
      console.error('Analytics tracking error:', error)
    }
  }

  static async trackTransformation(userId: string, type: string) {
    try {
      await fetch('/api/analytics/track', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          event: 'text_transformation',
          userId,
          properties: { type },
        }),
      })
    } catch (error) {
      console.error('Analytics tracking error:', error)
    }
  }
}
```

### 2. 에러 로깅

```typescript
// lib/logger.ts
export class Logger {
  static error(message: string, error: Error, context?: any) {
    console.error(`[ERROR] ${message}`, {
      error: {
        name: error.name,
        message: error.message,
        stack: error.stack,
      },
      context,
      timestamp: new Date().toISOString(),
    })

    // 프로덕션에서는 외부 로깅 서비스로 전송
    if (process.env.NODE_ENV === 'production') {
      // Sentry, LogRocket 등으로 전송
    }
  }

  static info(message: string, data?: any) {
    console.log(`[INFO] ${message}`, {
      data,
      timestamp: new Date().toISOString(),
    })
  }
}
```

## 향후 개선 방향

### 1. 고급 기능 추가

```typescript
// 계획된 기능들
const futureFeatures = {
  realtime_transcription: {
    description: '실시간 음성 전사',
    technology: 'WebRTC + WebSocket',
    priority: 'high'
  },
  
  speaker_diarization: {
    description: '화자 분리',
    technology: 'Together.ai Speaker Diarization',
    priority: 'medium'
  },
  
  multilingual_support: {
    description: '다국어 지원',
    technology: 'Whisper Multilingual',
    priority: 'medium'
  },
  
  collaboration_features: {
    description: '팀 협업 기능',
    technology: 'Real-time collaboration',
    priority: 'low'
  },
  
  api_access: {
    description: 'API 제공',
    technology: 'REST API + API Keys',
    priority: 'medium'
  }
}
```

### 2. 성능 최적화

```typescript
// 최적화 계획
const optimizations = {
  caching: {
    strategy: 'Redis caching for frequent queries',
    impact: 'Reduce DB load'
  },
  
  cdn: {
    strategy: 'CloudFront for audio file delivery',
    impact: 'Faster file access'
  },
  
  compression: {
    strategy: 'Audio compression before upload',
    impact: 'Reduce upload time and storage cost'
  },
  
  edge_computing: {
    strategy: 'Vercel Edge Functions for auth',
    impact: 'Lower latency'
  }
}
```

## 결론

이 튜토리얼을 통해 현대적인 기술 스택을 활용한 전문적인 AI 음성 전사 애플리케이션을 구축했습니다. 주요 성과는 다음과 같습니다:

### 핵심 성과

1. **완전한 음성 처리 파이프라인**: 업로드 → 전사 → AI 변환
2. **사용자 중심 설계**: 직관적인 UI/UX와 실시간 피드백
3. **확장 가능한 아키텍처**: 마이크로서비스 패턴과 클라우드 네이티브 설계
4. **프로덕션 준비**: 인증, Rate Limiting, 에러 처리, 모니터링

### 기술적 하이라이트

- **Together.ai Whisper**: 고품질 음성 전사
- **Next.js 14**: 최신 React 프레임워크
- **Clerk**: 간편한 사용자 인증
- **Prisma + Neon**: 현대적 데이터베이스 스택
- **AWS S3**: 안정적인 파일 저장
- **Vercel**: 간편한 배포와 호스팅

### 실무 적용 가치

이 애플리케이션은 다음과 같은 실제 사용 사례에 적용할 수 있습니다:

- **회의록 자동화**: 회의 녹음을 자동으로 전사하고 요약
- **강의 노트**: 온라인 강의나 세미나 내용 정리
- **인터뷰 분석**: 고객 인터뷰나 연구 인터뷰 분석
- **콘텐츠 제작**: 팟캐스트나 비디오 콘텐츠의 스크립트 생성

참고한 [Nutlope의 Whisper 앱](https://github.com/Nutlope/whisper)을 기반으로, 더욱 포괄적이고 실무에서 바로 활용할 수 있는 수준의 애플리케이션을 구현했습니다. 이제 여러분만의 독특한 기능을 추가하여 더욱 특별한 음성 전사 서비스를 만들어보세요!

---

**관련 리소스**:
- [원본 Whisper 앱 레포지토리](https://github.com/Nutlope/whisper)
- [Together.ai API 문서](https://docs.together.ai/)
- [Clerk 인증 가이드](https://clerk.com/docs)
- [Next.js 14 공식 문서](https://nextjs.org/docs) 