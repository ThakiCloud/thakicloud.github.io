---
title: "미드저니 이미지로 연속 동영상 제작하기 - FFmpeg 스크립트 완전 가이드"
excerpt: "미드저니로 생성한 이미지를 동영상으로 만들고, 마지막 프레임을 추출해 연속 영상을 생성하는 완전한 워크플로우"
date: 2025-06-22
categories: 
  - tutorials
  - dev
tags: 
  - midjourney
  - ffmpeg
  - video-editing
  - automation
  - zsh-scripting
author_profile: true
toc: true
toc_label: "미드저니 연속 동영상 제작"
---

## 개요

미드저니(Midjourney)로 생성한 이미지를 활용해 연속성 있는 짧은 동영상을 제작하는 완전한 워크플로우를 소개합니다. 이 튜토리얼을 통해 하나의 이미지에서 시작해 마지막 프레임을 추출하고, 그 프레임을 다음 영상의 시작점으로 사용해 자연스럽게 이어지는 영상을 만들 수 있습니다.

## 필요한 도구

### 기본 도구
- **Midjourney**: 초기 이미지 및 연속 이미지 생성
- **FFmpeg**: 동영상 편집 및 프레임 추출
- **Zsh**: 자동화 스크립트 실행 환경

### 설치 방법

```bash
# macOS에서 FFmpeg 설치
brew install ffmpeg

# Ubuntu/Debian에서 FFmpeg 설치  
sudo apt install ffmpeg
```

## 워크플로우 전체 과정

### 1단계: 미드저니 초기 이미지 생성

```
/imagine prompt: a serene mountain landscape at sunrise, cinematic style, 4K --ar 16:9 --v 6
```

### 2단계: 첫 번째 동영상 생성

미드저니에서 생성된 이미지를 기반으로 첫 번째 동영상을 생성합니다.

```
/create video [첫 번째 이미지 업로드]
```

### 3단계: 마지막 프레임 추출

생성된 동영상에서 마지막 프레임을 추출하는 자동화 스크립트를 작성합니다.

## 마지막 프레임 추출 스크립트

### 스크립트 생성

`get_last_frame.sh` 파일을 생성합니다:

```zsh
#!/bin/zsh

if [ -z "$1" ]; then
  echo "❗️사용법: getlastframe <video_filename>"
  exit 1
fi

INPUT="$1"
BASENAME="${INPUT%.*}"
EXT="png"
OUTPUT="${BASENAME}_lastframe.${EXT}"

echo "⏳ 마지막 프레임을 추출 중입니다..."
ffmpeg -sseof -3 -i "$INPUT" -vsync 0 -q:v 2 -update true "$OUTPUT"

if [ $? -eq 0 ]; then
  echo "✅ 마지막 프레임이 추출되었습니다: $OUTPUT"
else
  echo "❌ 추출 실패"
fi
```

### 실행 권한 부여 및 Alias 설정

```bash
# 실행 권한 부여
chmod +x get_last_frame.sh

# ~/.zshrc에 alias 추가
echo 'alias getlastframe="$HOME/scripts/get_last_frame.sh"' >> ~/.zshrc

# 설정 적용
source ~/.zshrc
```

### 사용 예시

```bash
getlastframe first_video.mp4
# → first_video_lastframe.png 생성
```

## 동영상 연결 스크립트

여러 동영상을 자연스럽게 연결하는 고급 스크립트를 제공합니다.

### 연결 스크립트 생성

`concat_videos.sh` 파일을 생성합니다:

```zsh
#!/bin/zsh

set -e

if [ -z "$1" ]; then
  echo "❗️사용법: concatvideos <폴더경로> [출력파일명.확장자]"
  exit 1
fi

INPUT_DIR="$1"
OUTPUT_FILE="${2:-merged_output.mp4}"

# 지원 확장자 설정
EXTS=("mp4" "mov" "mkv" "webm" "avi")
VIDEO_FILES=()

# 자연 정렬된 파일 수집 (개선된 버전)
for ext in $EXTS; do
  # globbing으로 파일 찾기
  files=("$INPUT_DIR"/*.$ext(N))
  if [[ ${#files[@]} -gt 0 ]]; then
    for file in "${files[@]}"; do
      # 파일이 실제로 존재하는지 확인
      if [[ -f "$file" ]]; then
        VIDEO_FILES+=("$file")
      fi
    done
  fi
done

# 자연 정렬 적용
VIDEO_FILES=(${(on)VIDEO_FILES})

if [ ${#VIDEO_FILES[@]} -eq 0 ]; then
  echo "❌ 영상 파일을 찾을 수 없습니다: $INPUT_DIR"
  exit 1
fi

echo "🔍 총 ${#VIDEO_FILES[@]}개 영상 파일 발견"

# 파일 목록 출력 (디버깅용)
for i in {1..${#VIDEO_FILES[@]}}; do
  echo "[$i] ${VIDEO_FILES[$i]:t}"  # :t는 파일명만 출력
done

# 첫 번째 파일이 존재하는지 확인
if [[ ! -f "${VIDEO_FILES[1]}" ]]; then
  echo "❌ 첫 번째 파일이 존재하지 않습니다: ${VIDEO_FILES[1]}"
  exit 1
fi

# 기준 정보 추출
echo "📊 첫 번째 파일의 정보를 확인 중..."
REF_INFO=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,height,width,r_frame_rate -of default=noprint_wrappers=1 "${VIDEO_FILES[1]}" 2>/dev/null)

if [[ -z "$REF_INFO" ]]; then
  echo "❌ 첫 번째 파일의 정보를 읽을 수 없습니다: ${VIDEO_FILES[1]}"
  exit 1
fi

NEED_REENCODE=0

# 모든 파일의 호환성 검사
for file in "${VIDEO_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    echo "❌ 파일이 존재하지 않습니다: $file"
    exit 1
  fi
  
  echo "🔍 검사 중: ${file:t}"
  INFO=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,height,width,r_frame_rate -of default=noprint_wrappers=1 "$file" 2>/dev/null)
  
  if [[ -z "$INFO" ]]; then
    echo "❌ 파일 정보를 읽을 수 없습니다: $file"
    exit 1
  fi
  
  if [[ "$INFO" != "$REF_INFO" ]]; then
    NEED_REENCODE=1
    echo "⚠️ 코덱/해상도/프레임레이트 불일치: ${file:t}"
  fi
done

# 임시 리스트 파일 생성
LIST_FILE=$(mktemp)
for f in "${VIDEO_FILES[@]}"; do
  # 파일 경로를 절대 경로로 변환하여 안전하게  처리
  absolute_path=$(realpath "$f")
  echo "file '$absolute_path'" >> "$LIST_FILE"
done

echo "📝 생성된 파일 리스트:"
cat "$LIST_FILE"

if [ $NEED_REENCODE -eq 0 ]; then
  echo "✅ 모든 파일이 동일한 코덱/해상도/프레임레이트입니다. 무손실 병합 중..."
  ffmpeg -f concat -safe 0 -i "$LIST_FILE" -c copy "$OUTPUT_FILE" -y
else
  echo "♻️ 포맷이 다릅니다. 재인코딩 모드로 병합 중..."
  ffmpeg -f concat -safe 0 -i "$LIST_FILE" -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -preset fast -crf 23 -c:a aac "$OUTPUT_FILE" -y
fi

rm "$LIST_FILE"

echo "✅ 완료: $OUTPUT_FILE"

```

### 설치 및 설정

```bash
# 실행 권한 부여
chmod +x concat_videos.sh

# Alias 설정
echo 'alias concatvideos="$HOME/scripts/concat_videos.sh"' >> ~/.zshrc
source ~/.zshrc
```

## 완전한 워크플로우 실행

### 단계별 프로세스

1. **미드저니 첫 이미지 생성**
   ```
   /imagine prompt: magical forest entrance, morning mist, cinematic --ar 16:9
   ```

2. **첫 번째 동영상 생성**
   ```
   /create video [이미지 업로드]
   ```

3. **마지막 프레임 추출**
   ```bash
   getlastframe video_01.mp4
   # → video_01_lastframe.png 생성
   ```

4. **다음 이미지 생성 (추출된 프레임 활용)**
   ```
   /imagine prompt: [video_01_lastframe.png] deeper into the magical forest, more mystical elements --ar 16:9
   ```

5. **두 번째 동영상 생성**
   ```
   /create video [새로운 이미지 업로드]
   ```

6. **과정 반복** (원하는 만큼)

7. **최종 동영상 연결**
   ```bash
   # 모든 동영상을 videos 폴더에 정리 후
   concatvideos ./videos final_story.mp4
   ```

### 폴더 구조 예시

```
project/
├── scripts/
│   ├── get_last_frame.sh
│   └── concat_videos.sh
├── images/
│   ├── frame_01_lastframe.png
│   ├── frame_02_lastframe.png
│   └── ...
├── videos/
│   ├── video_01.mp4
│   ├── video_02.mp4
│   ├── video_03.mp4
│   └── ...
└── output/
    └── final_story.mp4
```

## 고급 활용 팁

### 프레임 품질 최적화

JPG 형식으로 저장하려면 스크립트를 수정합니다:

```zsh
# get_last_frame.sh에서 다음 라인 수정
EXT="jpg"
```

### 다양한 출력 포맷 지원

```bash
# MP4 출력
concatvideos ./videos story.mp4

# MOV 출력  
concatvideos ./videos story.mov

# WebM 출력
concatvideos ./videos story.webm
```

### 해상도 및 품질 조정

고품질 출력을 원한다면 `concat_videos.sh`에서 다음 옵션을 수정합니다:

```zsh
# 더 높은 품질을 위해 CRF 값 낮추기 (18-23 권장)
-crf 18

# 더 빠른 인코딩을 위해 preset 변경
-preset medium
```

## 트러블슈팅

### 일반적인 문제 해결

**FFmpeg 명령어 실패**
```bash
# FFmpeg 설치 확인
ffmpeg -version

# 경로 문제 해결
which ffmpeg
```

**권한 오류**
```bash
# 스크립트 실행 권한 확인
ls -la get_last_frame.sh
chmod +x get_last_frame.sh
```

**동영상 포맷 불일치**
- 스크립트가 자동으로 재인코딩 모드로 전환됩니다
- 모든 동영상이 동일한 해상도, 프레임레이트를 가지도록 미드저니 설정을 일관되게 유지하세요

## 결론

이 워크플로우를 통해 미드저니의 이미지 생성 능력과 FFmpeg의 강력한 동영상 편집 기능을 결합하여 연속성 있는 스토리텔링 영상을 자동화된 방식으로 제작할 수 있습니다. 각 프레임이 자연스럽게 이어지는 영상을 만들어 더욱 몰입감 있는 콘텐츠를 제작해보세요.

## 추가 자료

- [FFmpeg 공식 문서](https://ffmpeg.org/documentation.html)
- [Midjourney 공식 가이드](https://docs.midjourney.com/)
- [Zsh 스크립팅 가이드](https://zsh.sourceforge.io/Guide/) 