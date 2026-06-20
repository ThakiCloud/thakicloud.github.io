---
title: "AI 워크플로우의 완성: yap + llm + yt-dlp로 YouTube 영상을 자동 요약하는 방법"
excerpt: "macOS의 yap 음성 전사 도구와 llm CLI, yt-dlp를 조합하여 YouTube 영상을 자동으로 다운로드하고 전사한 후 AI로 요약하는 완전한 워크플로우를 구축합니다."
date: 2025-06-21
categories: 
  - tutorials
  - dev
  - ai-application
tags: 
  - yap
  - llm
  - yt-dlp
  - 음성전사
  - AI워크플로우
  - macOS
  - CLI도구
  - 자동화
author_profile: true
toc: true
toc_label: "AI 워크플로우 가이드"
published: false
---

## 혁신적인 AI 워크플로우: 한 번의 명령으로 YouTube → 요약까지

YouTube 영상을 보다가 "이 내용을 빠르게 요약해서 읽고 싶다"고 생각해본 적이 있으신가요? 오늘 소개할 워크플로우를 사용하면 **단 한 줄의 명령어**로 YouTube 영상을 다운로드하고, 음성을 텍스트로 전사한 후, AI가 내용을 요약해주는 완전 자동화된 시스템을 구축할 수 있습니다.

이 튜토리얼에서는 세 가지 강력한 도구를 조합합니다:

- **🗣️ yap**: macOS 온디바이스 음성 전사
- **🤖 llm**: 다양한 LLM과의 CLI 인터페이스  
- **📹 yt-dlp**: YouTube 영상 다운로드

## 도구 소개: 각각의 강력한 기능들

### 🗣️ yap: macOS 네이티브 음성 전사의 혁신

[yap](https://github.com/finnvoor/yap)은 macOS 26의 Speech.framework를 활용한 **온디바이스 음성 전사 도구**입니다. 외부 API 호출 없이 로컬에서 고품질 전사를 제공합니다.

**주요 특징:**

- 🔒 **완전한 프라이버시**: 모든 처리가 로컬에서 진행
- ⚡ **빠른 속도**: macOS 최적화된 네이티브 성능
- 🎯 **높은 정확도**: Apple의 최신 Speech.framework 활용
- 📝 **다양한 출력**: 텍스트, SRT 자막 지원
- 🌍 **다국어 지원**: 현재 로케일 자동 감지

### 🤖 llm: 모든 LLM을 하나로 통합

[llm](https://llm.datasette.io/en/stable/)은 Simon Willison이 개발한 **범용 LLM CLI 도구**입니다. OpenAI, Anthropic, Google, Meta 등 모든 주요 LLM을 하나의 인터페이스로 사용할 수 있습니다.

**주요 특징:**

- 🔌 **플러그인 생태계**: 다양한 모델 지원
- 💾 **자동 로깅**: SQLite에 모든 대화 기록 저장
- 🔧 **도구 통합**: 함수 호출, 스키마 추출 지원
- 📊 **임베딩 지원**: 벡터 검색 기능
- 🎨 **템플릿 시스템**: 재사용 가능한 프롬프트

### 📹 yt-dlp: YouTube 다운로드의 표준

yt-dlp는 YouTube를 포함한 수많은 비디오 플랫폼에서 콘텐츠를 다운로드할 수 있는 **오픈소스 도구**입니다.

## 설치 방법

### 1. yap 설치

```bash
# Homebrew로 설치 (권장)
brew install finnvoor/tools/yap

# 또는 Mint 사용
mint install finnvoor/yap
```

### 2. llm 설치

```bash
# pip로 설치
pip install llm

# 또는 Homebrew
brew install llm

# 또는 uv 사용
uv tool install llm
```

### 3. yt-dlp 설치

```bash
# Homebrew로 설치
brew install yt-dlp

# 또는 pip 사용
pip install yt-dlp
```

## API 키 설정

### OpenAI API 키 설정

```bash
# OpenAI API 키 설정
llm keys set openai
# API 키를 입력하세요

# 테스트
llm "Hello, world!"
```

### 다른 모델 플러그인 설치

```bash
# Anthropic Claude 사용
llm install llm-anthropic
llm keys set anthropic

# Google Gemini 사용  
llm install llm-gemini
llm keys set gemini

# 로컬 Ollama 사용
llm install llm-ollama
ollama pull llama3.2:latest
```

## 기본 사용법

### yap을 이용한 음성 전사

```bash
# 기본 전사 (텍스트 출력)
yap transcribe video.mp4

# SRT 자막 생성
yap transcribe video.mp4 --srt -o captions.srt

# 특정 언어로 전사
yap transcribe video.mp4 --locale ko-KR

# 욕설 필터링
yap transcribe video.mp4 --censor
```

### llm을 이용한 AI 대화

```bash
# 기본 프롬프트
llm "Explain quantum computing"

# 시스템 프롬프트 사용
echo "print('Hello World')" | llm -s "Explain this code"

# 파일과 함께 사용
llm "Summarize this document" -a document.pdf

# 대화형 채팅
llm chat -m gpt-4o
```

### yt-dlp를 이용한 YouTube 다운로드

```bash
# 비디오 다운로드
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID"

# 오디오만 추출
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID" -x

# 특정 품질로 다운로드
yt-dlp "https://www.youtube.com/watch?v=VIDEO_ID" -f "best[height<=720]"
```

## 강력한 zshrc Alias 컬렉션

이제 이 도구들을 조합한 강력한 alias들을 만들어보겠습니다. `.zshrc` 파일에 다음 함수들을 추가하세요:

```bash
# .zshrc 편집
nano ~/.zshrc
```

### 1. 기본 YouTube 요약 워크플로우

```bash
# YouTube 영상을 다운로드하고 요약하는 완전 자동화 함수
ytsummary() {
    local url="$1"
    local model="${2:-gpt-4o-mini}"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytsummary <youtube-url> [model]"
        echo "Example: ytsummary 'https://youtube.com/watch?v=abc123' claude-3-sonnet"
        return 1
    fi
    
    echo "🚀 Starting YouTube summary workflow..."
    echo "📹 Downloading video: $url"
    
    # 임시 디렉토리 생성
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # YouTube 영상 다운로드 (오디오만)
    yt-dlp "$url" -x --audio-format mp3 --output "%(title)s.%(ext)s"
    
    # 다운로드된 파일 찾기
    local audio_file=$(find . -name "*.mp3" | head -1)
    
    if [[ -z "$audio_file" ]]; then
        echo "❌ Failed to download audio"
        return 1
    fi
    
    echo "🗣️ Transcribing audio with yap..."
    
    # 음성 전사
    yap transcribe "$audio_file" --output-file transcript.txt
    
    if [[ ! -f "transcript.txt" ]]; then
        echo "❌ Failed to transcribe audio"
        return 1
    fi
    
    echo "🤖 Generating summary with $model..."
    
    # AI 요약 생성
    cat transcript.txt | llm -m "$model" -s "Please provide a comprehensive summary of this transcript. Include key points, main topics, and important insights. Format the response in markdown with clear headings."
    
    # 정리
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    echo "✅ Summary complete!"
}
```

### 2. 빠른 YouTube 키워드 추출

```bash
# YouTube 영상에서 핵심 키워드만 빠르게 추출
ytkeys() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytkeys <youtube-url>"
        return 1
    fi
    
    echo "🔍 Extracting keywords from YouTube video..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "temp.%(ext)s"
    yap transcribe temp.mp3 --output-file transcript.txt
    
    cat transcript.txt | llm -s "Extract the 10 most important keywords or phrases from this transcript. Present them as a simple numbered list."
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

### 3. 다국어 지원 요약

```bash
# 다국어 YouTube 영상 요약 (한국어 출력)
ytsummary_kr() {
    local url="$1"
    local target_lang="${2:-ko-KR}"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytsummary_kr <youtube-url> [locale]"
        echo "Example: ytsummary_kr 'https://youtube.com/watch?v=abc123' ja-JP"
        return 1
    fi
    
    echo "🌍 다국어 YouTube 요약 시작..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "video.%(ext)s"
    yap transcribe video.mp3 --locale "$target_lang" --output-file transcript.txt
    
    cat transcript.txt | llm -s "이 전사 내용을 한국어로 요약해주세요. 주요 포인트와 핵심 인사이트를 포함하여 구조적으로 정리해주세요."
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

### 4. 교육 콘텐츠 분석기

```bash
# 교육 영상을 분석하고 학습 가이드 생성
ytedu() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytedu <youtube-educational-video-url>"
        return 1
    fi
    
    echo "📚 Educational content analysis starting..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "edu.%(ext)s"
    yap transcribe edu.mp3 --output-file transcript.txt
    
    cat transcript.txt | llm -s "This is a transcript from an educational video. Please analyze it and provide:

1. **Main Topic**: What is this video about?
2. **Key Concepts**: List 5-7 main concepts explained
3. **Learning Objectives**: What should viewers learn?
4. **Summary**: Concise overview of content
5. **Study Questions**: 3-5 questions to test understanding
6. **Further Reading**: Suggest related topics to explore

Format your response in markdown with clear sections."
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

### 5. 팟캐스트/인터뷰 분석기

```bash
# 팟캐스트나 인터뷰 영상 분석
ytpodcast() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytpodcast <youtube-podcast-url>"
        return 1
    fi
    
    echo "🎙️ Podcast analysis starting..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "podcast.%(ext)s"
    yap transcribe podcast.mp3 --output-file transcript.txt
    
    cat transcript.txt | llm -s "This is a transcript from a podcast or interview. Please provide:

1. **Participants**: Who are the speakers?
2. **Main Topics**: What topics were discussed?
3. **Key Quotes**: 3-5 most interesting or insightful quotes
4. **Highlights**: Most valuable insights or takeaways
5. **Timeline**: Rough breakdown of when different topics were discussed
6. **Action Items**: Any actionable advice or recommendations mentioned

Present this as a well-structured analysis."
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

### 6. 자막 생성기

```bash
# YouTube 영상용 SRT 자막 생성
ytsubs() {
    local url="$1"
    local output_name="${2:-captions}"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytsubs <youtube-url> [output-name]"
        return 1
    fi
    
    echo "📄 Generating SRT captions..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    # 비디오 다운로드 (자막 생성을 위해 전체 파일 필요)
    yt-dlp "$url" --output "video.%(ext)s"
    local video_file=$(find . -name "video.*" | head -1)
    
    # SRT 자막 생성
    yap transcribe "$video_file" --srt --output-file "${output_name}.srt"
    
    # 현재 디렉토리로 이동
    cp "${output_name}.srt" "$OLDPWD/"
    
    cd - > /dev/null
    rm -rf "$temp_dir"
    
    echo "✅ SRT captions saved as ${output_name}.srt"
}
```

### 7. 회의록/강의 정리

```bash
# 회의나 강의 영상을 체계적으로 정리
ytmeeting() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: ytmeeting <youtube-meeting-url>"
        return 1
    fi
    
    echo "📋 Meeting analysis starting..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "meeting.%(ext)s"
    yap transcribe meeting.mp3 --output-file transcript.txt
    
    cat transcript.txt | llm -s "This is a transcript from a meeting or lecture. Please create a structured meeting summary:

## Meeting Summary

### 📅 Overview
- **Topic**: [Main subject]
- **Duration**: [Approximate length]
- **Participants**: [Who spoke]

### 🎯 Key Decisions
- [List important decisions made]

### 📝 Action Items
- [List tasks or actions mentioned]

### 💡 Main Discussion Points
1. [Point 1]
2. [Point 2]
3. [Point 3]

### ❓ Questions Raised
- [Important questions discussed]

### 📋 Next Steps
- [What happens next]

Format everything clearly in markdown."
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

### 8. 빠른 음성 메모 전사

```bash
# 로컬 음성 파일 빠른 전사 및 정리
quicktranscribe() {
    local file="$1"
    local output_format="${2:-summary}"
    
    if [[ -z "$file" ]]; then
        echo "Usage: quicktranscribe <audio-file> [format]"
        echo "Formats: summary, keywords, action-items, full"
        return 1
    fi
    
    if [[ ! -f "$file" ]]; then
        echo "❌ File not found: $file"
        return 1
    fi
    
    echo "🎙️ Transcribing and processing: $file"
    
    # 전사
    yap transcribe "$file" --output-file temp_transcript.txt
    
    case "$output_format" in
        "summary")
            cat temp_transcript.txt | llm -s "Provide a concise summary of this transcript."
            ;;
        "keywords") 
            cat temp_transcript.txt | llm -s "Extract key keywords and phrases from this transcript."
            ;;
        "action-items")
            cat temp_transcript.txt | llm -s "Extract any action items, tasks, or to-dos mentioned in this transcript."
            ;;
        "full")
            cat temp_transcript.txt
            ;;
        *)
            echo "❌ Unknown format: $output_format"
            ;;
    esac
    
    rm -f temp_transcript.txt
}
```

## 설정 적용 및 사용법

### 1. 설정 적용

```bash
# .zshrc에 함수들을 추가한 후
source ~/.zshrc

# 또는 터미널 재시작
```

### 2. 사용 예시

```bash
# 기본 YouTube 요약
ytsummary "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# Claude로 요약
ytsummary "https://www.youtube.com/watch?v=dQw4w9WgXcQ" claude-3-sonnet

# 키워드 추출
ytkeys "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# 한국어 요약
ytsummary_kr "https://www.youtube.com/watch?v=dQw4w9WgXcQ"

# 교육 콘텐츠 분석
ytedu "https://www.youtube.com/watch?v=educational_video"

# SRT 자막 생성
ytsubs "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "my_captions"

# 로컬 파일 전사
quicktranscribe meeting_audio.mp3 summary
```

## 고급 활용법

### 1. 배치 처리 스크립트

```bash
# YouTube 플레이리스트 전체 요약
ytplaylist_summary() {
    local playlist_url="$1"
    
    if [[ -z "$playlist_url" ]]; then
        echo "Usage: ytplaylist_summary <playlist-url>"
        return 1
    fi
    
    echo "📺 Processing YouTube playlist..."
    
    # 플레이리스트의 모든 URL 추출
    yt-dlp --flat-playlist --get-url "$playlist_url" | while read url; do
        echo "Processing: $url"
        ytsummary "$url"
        echo "---"
    done
}
```

### 2. 로그 관리

```bash
# llm 로그 확인 및 관리
llm_stats() {
    echo "📊 LLM Usage Statistics:"
    llm logs -n 10 --short
    echo "\n🔍 Recent summaries:"
    llm logs | grep -i summary | head -5
}
```

### 3. 다중 모델 비교

```bash
# 여러 모델로 동시 요약
multi_summary() {
    local url="$1"
    
    if [[ -z "$url" ]]; then
        echo "Usage: multi_summary <youtube-url>"
        return 1
    fi
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    yt-dlp "$url" -x --audio-format mp3 --output "temp.%(ext)s"
    yap transcribe temp.mp3 --output-file transcript.txt
    
    echo "=== GPT-4o-mini Summary ==="
    cat transcript.txt | llm -m gpt-4o-mini -s "Summarize this transcript"
    
    echo "\n=== Claude-3-haiku Summary ==="
    cat transcript.txt | llm -m claude-3-haiku -s "Summarize this transcript"
    
    echo "\n=== Gemini-2.0-flash Summary ==="
    cat transcript.txt | llm -m gemini-2.0-flash -s "Summarize this transcript"
    
    cd - > /dev/null
    rm -rf "$temp_dir"
}
```

## 최적화 팁

### 1. 성능 최적화

```bash
# 임시 파일 정리를 위한 함수
cleanup_temp() {
    find /tmp -name "*yap*" -type d -mtime +1 -exec rm -rf {} +
    find /tmp -name "*yt-dlp*" -type f -mtime +1 -delete
}

# .zshrc에 추가하여 주기적 정리
```

### 2. 에러 처리 개선

```bash
# 네트워크 오류 시 재시도 로직
ytsummary_robust() {
    local url="$1"
    local max_retries=3
    local retry_count=0
    
    while [ $retry_count -lt $max_retries ]; do
        if ytsummary "$url"; then
            break
        else
            retry_count=$((retry_count + 1))
            echo "❌ Attempt $retry_count failed. Retrying in 5 seconds..."
            sleep 5
        fi
    done
    
    if [ $retry_count -eq $max_retries ]; then
        echo "❌ Failed after $max_retries attempts"
        return 1
    fi
}
```

## 문제 해결

### 일반적인 문제들

1. **yap 전사 오류**

   ```bash
   # macOS 권한 확인
   # System Preferences > Security & Privacy > Microphone
   ```

2. **yt-dlp 다운로드 실패**

   ```bash
   # yt-dlp 업데이트
   pip install --upgrade yt-dlp
   ```

3. **llm API 키 오류**

   ```bash
   # API 키 재설정
   llm keys set openai
   ```

## 실제 사용 사례

### 1. 연구자/학생

- 온라인 강의 요약
- 학술 발표 내용 정리
- 연구 인터뷰 전사

### 2. 콘텐츠 크리에이터

- 경쟁사 분석
- 트렌드 파악
- 자막 생성

### 3. 비즈니스 전문가

- 컨퍼런스 세션 요약
- 업계 인사이트 추출
- 회의록 작성

## 결론: AI 시대의 필수 워크플로우

yap, llm, yt-dlp의 조합은 **정보 소비 방식을 혁신**하는 강력한 도구입니다. 몇 시간짜리 영상을 몇 분 만에 핵심 내용으로 압축하고, 다양한 관점에서 분석할 수 있습니다.

이 워크플로우의 진정한 가치는:

- ⏰ **시간 절약**: 긴 영상을 빠르게 파악
- 🔒 **프라이버시 보호**: 로컬 전사로 민감한 내용도 안전
- 🎯 **맞춤 분석**: 필요에 따른 다양한 분석 형태
- 🔄 **재사용성**: 한 번 설정하면 계속 활용

**다음 단계**: 여러분의 특정 용도에 맞는 alias를 만들어보세요. 연구, 학습, 업무 등 각각의 목적에 특화된 워크플로우를 구축하면 더욱 강력한 도구가 됩니다.

---

**참고 자료**:

- [yap GitHub 저장소](https://github.com/finnvoor/yap)
- [llm 공식 문서](https://llm.datasette.io/en/stable/)
- [yt-dlp GitHub 저장소](https://github.com/yt-dlp/yt-dlp)
