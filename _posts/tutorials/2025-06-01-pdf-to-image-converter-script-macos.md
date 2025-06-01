---
title: "macOS에서 PDF를 페이지별 이미지로 변환하는 Bash 스크립트 완벽 가이드"
date: 2025-06-01
categories: 
  - tutorials
tags: 
  - pdf
  - image-conversion
  - bash-script
  - imagemagick
  - poppler
  - pdfcpu
  - macos
  - automation
author_profile: true
toc: true
toc_label: "목차"
---

PDF 문서를 페이지별로 PNG 및 JPG 이미지로 변환해야 하는 경우가 종종 있습니다. 프레젠테이션 자료를 웹에 게시하거나, 문서를 이미지 형태로 아카이브하거나, 각 페이지를 개별적으로 처리해야 할 때 유용합니다. 이번 포스트에서는 macOS 환경에서 PDF를 자동으로 페이지별 이미지로 변환하는 강력한 Bash 스크립트를 소개하고, 설치부터 실행까지의 전 과정을 상세히 안내해드리겠습니다.

## 스크립트 개요

이 스크립트는 다음과 같은 기능을 제공합니다:

- **PDF 페이지 분할**: 멀티페이지 PDF를 개별 페이지 PDF로 분할
- **고품질 이미지 변환**: 300 DPI 해상도로 PNG 및 JPG 이미지 생성
- **자동화된 처리**: 한 번의 명령으로 모든 페이지를 일괄 처리
- **오류 처리**: 상세한 오류 메시지와 해결 방안 제시
- **의존성 검사**: 필요한 도구들의 설치 여부 자동 확인

## 필요한 도구 설치

### 1. Homebrew 설치 (미설치 시)

먼저 macOS 패키지 관리자인 Homebrew가 설치되어 있는지 확인합니다.

```bash
# Homebrew 설치 여부 확인
brew --version
```

설치되어 있지 않다면 다음 명령으로 설치합니다:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. 필수 도구 설치

스크립트 실행에 필요한 세 가지 도구를 설치합니다:

```bash
# ImageMagick 설치 (이미지 변환용)
brew install imagemagick

# Poppler 설치 (PDF to PNG 변환용)
brew install poppler

# pdfcpu 설치 (PDF 분할용)
brew install pdfcpu
```

### 3. 설치 확인

모든 도구가 올바르게 설치되었는지 확인합니다:

```bash
# 각 명령어 버전 확인
convert --version
pdftoppm -h
pdfcpu version
```

## 스크립트 다운로드 및 설정

### 1. 스크립트 파일 생성

터미널에서 다음 명령으로 스크립트 파일을 생성합니다:

```bash
# 작업 디렉토리 생성
mkdir -p ~/pdf-converter
cd ~/pdf-converter

# 스크립트 파일 생성
touch pdf_to_images.sh
```

### 2. 스크립트 내용 작성

생성한 파일에 다음 스크립트 코드를 입력합니다:

```bash
#!/usr/bin/env bash

# 스크립트 실행 중 오류 발생 시 즉시 중단
set -e

# --- 필수 명령어 확인 ---
# ImageMagick (convert 명령어) 설치 확인
if ! command -v convert &> /dev/null; then
    echo "오류: ImageMagick이 설치되어 있지 않거나 'convert' 명령어를 찾을 수 없습니다." >&2
    echo "ImageMagick을 설치해주세요. (예: brew install imagemagick)" >&2
    exit 1
fi
# pdfcpu 명령어 설치 확인
if ! command -v pdfcpu &> /dev/null; then
    echo "오류: pdfcpu가 설치되어 있지 않거나 명령어를 찾을 수 없습니다." >&2
    echo "pdfcpu를 설치해주세요. (예: brew install pdfcpu)" >&2
    exit 1
fi
# pdftoppm 명령어 설치 확인
if ! command -v pdftoppm &> /dev/null; then
    echo "오류: Poppler (pdftoppm)가 설치되어 있지 않거나 명령어를 찾을 수 없습니다." >&2
    echo "Poppler를 설치해주세요. (예: brew install poppler)" >&2
    exit 1
fi
# --- 필수 명령어 확인 끝 ---

# 입력 PDF 파일 경로 (스크립트 실행 시 첫 번째 인자로 받음)
INPUT="$1"
# 출력 디렉토리 설정
OUTDIR="output"

# 사용법 안내 (입력 파일이 없는 경우)
if [ -z "$INPUT" ]; then
  echo "사용법: $0 <입력 PDF 파일 경로>"
  echo "예시: $0 나의문서.pdf"
  exit 1
fi

# 입력 파일 존재 여부 확인
if [ ! -f "$INPUT" ]; then
  echo "오류: 입력 파일 '$INPUT'을(를) 찾을 수 없습니다. 파일 경로를 확인해주세요." >&2
  exit 1
fi

# 출력 디렉토리 생성 (하위 이미지 디렉토리 포함)
mkdir -p "$OUTDIR/img"

echo "================================================="
echo "PDF 페이지별 PNG 및 JPG 이미지 추출 스크립트"
echo "(북마크 없음 가정, ImageMagick 사용)"
echo "================================================="
echo "입력 파일: $INPUT"
echo "출력 디렉토리: $OUTDIR (이미지 저장: $OUTDIR/img)"
echo "-------------------------------------------------"

# 1) PDF를 단일 페이지 PDF 파일들로 분할
echo "[1단계] PDF 파일을 개별 페이지 PDF들로 분할합니다 (pdfcpu 사용)..."
echo "대상 파일: $INPUT"
echo "분할된 파일 저장 위치: $OUTDIR/"
pdfcpu split "$INPUT" "$OUTDIR"

# 분할된 PDF 파일이 생성되었는지 확인
if ! ls "$OUTDIR"/*.pdf 1> /dev/null 2>&1; then
  echo ""
  echo "오류: 1단계 PDF 분할 후 '$OUTDIR' 디렉토리에서 PDF 파일을 찾을 수 없습니다." >&2
  echo "원인 가능성:" >&2
  echo "  1. 입력 PDF 파일('$INPUT')이 비어있거나, 손상되었거나, 처리할 수 없는 형식일 수 있습니다." >&2
  echo "  2. 'pdfcpu split' 명령 실행 중 예상치 못한 문제가 발생했을 수 있습니다." >&2
  echo "  3. 디스크 공간이 부족하거나 '$OUTDIR' 디렉토리에 쓰기 권한이 없을 수 있습니다." >&2
  echo "조치 사항:" >&2
  echo "  - 입력 PDF 파일이 올바른지, 다른 PDF 뷰어에서 정상적으로 열리는지 확인해보세요." >&2
  echo "  - 터미널에서 'pdfcpu validate \"$INPUT\"' 명령으로 PDF 파일의 유효성을 검사해보세요." >&2
  echo "  - pdfcpu 도구가 올바르게 설치되어 있고 최신 버전인지 확인해보세요 (예: 'brew upgrade pdfcpu')." >&2
  echo "  - '$OUTDIR' 디렉토리에 쓰기 권한이 있고 디스크 공간이 충분한지 확인하세요." >&2
  exit 1
fi
echo "1단계 PDF 분할 완료. 분할된 개별 페이지 PDF 파일들이 '$OUTDIR' 디렉토리에 저장되었습니다."
echo "-------------------------------------------------"

# 2) 분할된 PDF 파일들을 PNG로 변환 후, PNG를 JPG로 변환
echo "[2단계] 분할된 PDF 파일들을 PNG로 변환 후, JPG로 추가 변환합니다..."
echo "이미지 저장 위치: $OUTDIR/img/"

for pdf_file in "$OUTDIR"/*.pdf; do
  base_name=$(basename "$pdf_file" .pdf)
  png_output_root="$OUTDIR/img/${base_name}" # pdftoppm 출력 시 사용할 파일명 기본 부분

  echo "  - 처리 중인 PDF 페이지: '$pdf_file'"
  echo "    1. PDF -> PNG 변환 (pdftoppm): '${png_output_root}-1.png' (예상 파일명)"
  pdftoppm -png -r 300 "$pdf_file" "$png_output_root"

  # pdftoppm은 단일 페이지 PDF 입력 시 보통 <root>-1.png 형태로 파일을 생성합니다.
  # Poppler 버전에 따라 -01.png 등일 수 있으므로, 실제 파일명을 확인하는 것이 좋습니다.
  # 여기서는 일반적인 "-1.png"를 가정합니다.
  generated_png_file="${png_output_root}-1.png"

  if [ -f "$generated_png_file" ]; then
    echo "    PNG 변환 완료: '$generated_png_file'"
    
    # JPG 파일 경로 설정 (PNG와 동일한 이름에 확장자만 .jpg로 변경)
    jpg_file_path="${png_output_root}-1.jpg" # PNG 파일명 규칙과 일관되게 설정

    echo "    2. PNG -> JPG 변환 (ImageMagick): '$generated_png_file' -> '$jpg_file_path'"
    convert "$generated_png_file" "$jpg_file_path"
    echo "    JPG 변환 완료: '$jpg_file_path'"
  else
    echo "  오류: 예상된 PNG 파일 '$generated_png_file'을(를) 찾을 수 없습니다." >&2
    echo "        pdftoppm의 출력 파일명 규칙을 확인하거나 Poppler 버전을 점검해주세요." >&2
    echo "        해당 PDF 페이지의 JPG 변환을 건너뜁니다." >&2
  fi
  echo "  ---" # 각 파일 처리 구분
done

echo "2단계 이미지 변환 (PNG 및 JPG) 완료."
echo "-------------------------------------------------"
echo "모든 작업이 완료되었습니다."
echo "생성된 PNG 및 JPG 이미지 파일들은 '$OUTDIR/img' 디렉토리에서 확인할 수 있습니다."
echo "================================================="

exit 0
```

### 3. 실행 권한 부여

스크립트에 실행 권한을 부여합니다:

```bash
chmod +x pdf_to_images.sh
```

## 스크립트 실행 방법

### 1. 기본 사용법

```bash
# 현재 디렉토리의 PDF 파일 변환
./pdf_to_images.sh example.pdf

# 절대 경로로 PDF 파일 지정
./pdf_to_images.sh /Users/username/Documents/presentation.pdf

# 상대 경로로 PDF 파일 지정
./pdf_to_images.sh ../documents/report.pdf
```

### 2. 실행 예시

실제 PDF 파일을 변환하는 과정을 살펴보겠습니다:

```bash
# 테스트용 PDF 파일이 있다고 가정
./pdf_to_images.sh sample_document.pdf
```

실행하면 다음과 같은 출력을 볼 수 있습니다:

```
=================================================
PDF 페이지별 PNG 및 JPG 이미지 추출 스크립트
(북마크 없음 가정, ImageMagick 사용)
=================================================
입력 파일: sample_document.pdf
출력 디렉토리: output (이미지 저장: output/img)
-------------------------------------------------
[1단계] PDF 파일을 개별 페이지 PDF들로 분할합니다 (pdfcpu 사용)...
대상 파일: sample_document.pdf
분할된 파일 저장 위치: output/
1단계 PDF 분할 완료. 분할된 개별 페이지 PDF 파일들이 'output' 디렉토리에 저장되었습니다.
-------------------------------------------------
[2단계] 분할된 PDF 파일들을 PNG로 변환 후, JPG로 추가 변환합니다...
이미지 저장 위치: output/img/
  - 처리 중인 PDF 페이지: 'output/sample_document_1.pdf'
    1. PDF -> PNG 변환 (pdftoppm): 'output/img/sample_document_1-1.png' (예상 파일명)
    PNG 변환 완료: 'output/img/sample_document_1-1.png'
    2. PNG -> JPG 변환 (ImageMagick): 'output/img/sample_document_1-1.png' -> 'output/img/sample_document_1-1.jpg'
    JPG 변환 완료: 'output/img/sample_document_1-1.jpg'
  ---
2단계 이미지 변환 (PNG 및 JPG) 완료.
-------------------------------------------------
모든 작업이 완료되었습니다.
생성된 PNG 및 JPG 이미지 파일들은 'output/img' 디렉토리에서 확인할 수 있습니다.
=================================================
```

## 출력 파일 구조

스크립트 실행 후 다음과 같은 디렉토리 구조가 생성됩니다:

```
pdf-converter/
├── pdf_to_images.sh          # 스크립트 파일
├── sample_document.pdf       # 원본 PDF 파일
└── output/                   # 출력 디렉토리
    ├── sample_document_1.pdf # 분할된 PDF (1페이지)
    ├── sample_document_2.pdf # 분할된 PDF (2페이지)
    ├── sample_document_3.pdf # 분할된 PDF (3페이지)
    └── img/                  # 이미지 파일 디렉토리
        ├── sample_document_1-1.png
        ├── sample_document_1-1.jpg
        ├── sample_document_2-1.png
        ├── sample_document_2-1.jpg
        ├── sample_document_3-1.png
        └── sample_document_3-1.jpg
```

## 스크립트 코드 분석

### 핵심 기능 분석

#### 1. 의존성 검사

```bash
if ! command -v convert &> /dev/null; then
    echo "오류: ImageMagick이 설치되어 있지 않거나 'convert' 명령어를 찾을 수 없습니다." >&2
    echo "ImageMagick을 설치해주세요. (예: brew install imagemagick)" >&2
    exit 1
fi
```

스크립트 실행 전에 필요한 모든 도구가 설치되어 있는지 확인합니다.

#### 2. PDF 분할

```bash
pdfcpu split "$INPUT" "$OUTDIR"
```

`pdfcpu`를 사용하여 멀티페이지 PDF를 개별 페이지 PDF로 분할합니다.

#### 3. 이미지 변환

```bash
pdftoppm -png -r 300 "$pdf_file" "$png_output_root"
convert "$generated_png_file" "$jpg_file_path"
```

- `pdftoppm`: PDF를 300 DPI 해상도의 PNG로 변환
- `convert`: PNG를 JPG 형식으로 추가 변환

### 오류 처리 메커니즘

스크립트는 다음과 같은 오류 상황을 처리합니다:

- **파일 존재 여부 확인**: 입력 PDF 파일이 존재하는지 검사
- **의존성 검사**: 필요한 도구들이 설치되어 있는지 확인
- **분할 결과 검증**: PDF 분할이 성공적으로 완료되었는지 확인
- **상세한 오류 메시지**: 문제 발생 시 원인과 해결 방안 제시

## 고급 사용법 및 커스터마이징

### 1. 해상도 변경

더 높은 품질의 이미지가 필요한 경우 해상도를 조정할 수 있습니다:

```bash
# 300 DPI를 600 DPI로 변경
pdftoppm -png -r 600 "$pdf_file" "$png_output_root"
```

### 2. 출력 형식 변경

JPG 대신 다른 형식으로 변환하려면:

```bash
# TIFF 형식으로 변환
convert "$generated_png_file" "${png_output_root}-1.tiff"

# WebP 형식으로 변환
convert "$generated_png_file" "${png_output_root}-1.webp"
```

### 3. 압축 품질 조정

JPG 변환 시 압축 품질을 조정할 수 있습니다:

```bash
# 품질 90%로 JPG 변환
convert "$generated_png_file" -quality 90 "$jpg_file_path"
```

## 문제 해결

### 자주 발생하는 오류와 해결 방법

#### 1. "command not found" 오류

```bash
# 도구 재설치
brew reinstall imagemagick poppler pdfcpu

# PATH 환경변수 확인
echo $PATH
```

#### 2. 권한 오류

```bash
# 스크립트 실행 권한 확인
ls -la pdf_to_images.sh

# 권한 부여
chmod +x pdf_to_images.sh
```

#### 3. PDF 파일 손상

```bash
# PDF 파일 유효성 검사
pdfcpu validate your_file.pdf
```

### 성능 최적화

대용량 PDF 파일 처리 시 다음 사항을 고려하세요:

- **디스크 공간**: 원본 PDF 크기의 3-5배 공간 확보
- **메모리**: 고해상도 변환 시 충분한 RAM 필요
- **처리 시간**: 페이지 수와 해상도에 비례하여 증가

## 결론

이 PDF to Image 변환 스크립트는 macOS 환경에서 PDF 문서를 효율적으로 이미지로 변환할 수 있는 강력한 도구입니다. 자동화된 처리 과정과 상세한 오류 처리 메커니즘을 통해 안정적이고 사용자 친화적인 경험을 제공합니다.

스크립트의 주요 장점:

- **완전 자동화**: 한 번의 명령으로 모든 페이지 처리
- **고품질 출력**: 300 DPI 해상도의 선명한 이미지
- **다중 형식 지원**: PNG와 JPG 동시 생성
- **강력한 오류 처리**: 상세한 진단 메시지와 해결 방안
- **확장 가능성**: 쉽게 커스터마이징 가능한 구조

이 도구를 활용하여 PDF 문서 처리 작업을 효율적으로 자동화해보세요!

---

*이 튜토리얼은 macOS 환경을 기준으로 작성되었으며, 다른 운영체제에서는 패키지 설치 방법이 다를 수 있습니다.* 