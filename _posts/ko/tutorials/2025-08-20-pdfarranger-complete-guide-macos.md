---
title: "PDF Arranger 완벽 가이드: macOS에서 PDF 문서 편집하기"
excerpt: "Python 기반의 강력한 PDF 편집 도구 PDF Arranger 설치부터 활용까지 macOS 완벽 튜토리얼"
seo_title: "PDF Arranger macOS 설치 가이드 - Python PDF 편집 도구 - Thaki Cloud"
seo_description: "PDF Arranger를 macOS에서 설치하고 사용하는 완벽 가이드. PDF 병합, 분할, 회전, 페이지 재배열 기능을 pikepdf와 함께 활용하는 방법을 단계별로 설명합니다."
date: 2025-08-20
last_modified_at: 2025-08-20
categories:
  - tutorials
tags:
  - pdf-arranger
  - pdf-editor
  - python
  - pikepdf
  - macos
  - gtk
  - document-management
  - file-processing
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/pdfarranger-complete-guide-macos/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 12분

## 서론

PDF 문서 편집은 일상적인 업무에서 빈번하게 발생하는 작업입니다. 특히 여러 PDF 파일을 병합하거나, 특정 페이지만 추출하거나, 페이지 순서를 재배열하는 작업은 누구나 한 번쯤 경험해본 일일 것입니다.

**PDF Arranger**는 이러한 PDF 편집 작업을 직관적인 GUI 환경에서 수행할 수 있는 강력한 Python 기반 도구입니다. 상용 PDF 편집기의 비싼 라이선스 비용 없이도 전문적인 PDF 편집 기능을 제공합니다.

### PDF Arranger란?

[PDF Arranger](https://github.com/pdfarranger/pdfarranger)는 PDF-Shuffler의 포크 프로젝트로, **pikepdf**를 백엔드로 사용하는 Python-GTK 애플리케이션입니다. 주요 특징은 다음과 같습니다:

- **직관적인 드래그 앤 드롭 인터페이스**
- **다중 PDF 파일 동시 편집**
- **페이지별 미리보기 제공**
- **무료 오픈소스 라이선스 (GPL-3.0)**
- **크로스 플랫폼 지원 (Linux, Windows, macOS)**

### 주요 기능

1. **PDF 병합**: 여러 PDF 파일을 하나로 결합
2. **PDF 분할**: 큰 PDF를 여러 개의 작은 파일로 분리
3. **페이지 재배열**: 드래그 앤 드롭으로 페이지 순서 변경
4. **페이지 회전**: 90°, 180°, 270° 회전 지원
5. **페이지 자르기**: 불필요한 영역 제거
6. **이미지 가져오기**: img2pdf를 통한 이미지 파일 PDF 변환

## macOS 설치 가이드

### 시스템 요구사항

macOS에서 PDF Arranger를 실행하려면 다음 구성 요소가 필요합니다:

```bash
# 테스트 환경 정보
OS: macOS (Apple Silicon M1/M2 권장)
Python: 3.8 이상 (테스트: Python 3.12.8)
Homebrew: 최신 버전
```

### 1. 필수 시스템 라이브러리 설치

PDF Arranger는 GTK+3 기반 애플리케이션이므로 GUI 라이브러리들이 필요합니다:

```bash
# Homebrew를 통한 시스템 라이브러리 설치
brew install gtk+3 gobject-introspection libhandy poppler cairo
```

각 라이브러리의 역할:
- **gtk+3**: GUI 프레임워크
- **gobject-introspection**: Python-GTK 바인딩
- **libhandy**: 모던 GTK 위젯
- **poppler**: PDF 렌더링 라이브러리
- **cairo**: 2D 그래픽 라이브러리

### 2. Python 패키지 설치

```bash
# Python GTK 바인딩 설치
pip3 install --user pycairo PyGObject

# PDF 처리 핵심 라이브러리
pip3 install --user pikepdf img2pdf python-dateutil

# PDF Arranger 설치
pip3 install --user pdfarranger
```

### 3. 환경 변수 설정

macOS에서 GTK 애플리케이션이 정상 동작하려면 환경 변수를 설정해야 합니다:

```bash
# ~/.zshrc에 추가
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"
export PATH="$HOME/.local/bin:$PATH"

# 변경사항 적용
source ~/.zshrc
```

### 4. 설치 확인

```bash
# PDF Arranger 버전 확인
pdfarranger --version

# GUI 실행 테스트
pdfarranger
```

## 자동화 설치 스크립트

수동 설치가 번거롭다면 아래 스크립트를 사용하세요:

```bash
#!/bin/bash
# PDF Arranger macOS 자동 설치 스크립트

set -e

echo "🔍 PDF Arranger macOS 설치 시작"
echo "================================"

# 시스템 정보 출력
echo "📋 시스템 정보:"
echo "- OS: $(uname -s) $(uname -r)"
echo "- Python: $(python3 --version)"
echo "- pip: $(pip3 --version)"

# 필요한 시스템 라이브러리 설치
echo "📦 시스템 라이브러리 설치:"
brew install gtk+3 gobject-introspection libhandy poppler cairo

# Python 패키지 설치
echo "🐍 Python 패키지 설치:"
pip3 install --user pycairo PyGObject pikepdf img2pdf python-dateutil

# PDF Arranger 설치
echo "🚀 PDF Arranger 설치:"
pip3 install --user pdfarranger

# 환경 변수 설정
echo "🔧 환경 변수 설정:"
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"

echo "✅ 설치 완료!"
echo "실행 명령어: pdfarranger"
```

이 스크립트를 `install-pdfarranger.sh`로 저장하고 실행하세요:

```bash
chmod +x install-pdfarranger.sh
./install-pdfarranger.sh
```

## 기본 사용법

### GUI 인터페이스 시작

```bash
# 빈 상태로 시작
pdfarranger

# 특정 PDF 파일과 함께 시작
pdfarranger document1.pdf document2.pdf
```

### 인터페이스 구성 요소

PDF Arranger의 메인 창은 다음과 같이 구성됩니다:

1. **메뉴바**: 파일 작업, 편집, 도구 등
2. **툴바**: 자주 사용하는 기능 버튼
3. **페이지 썸네일 영역**: 드래그 앤 드롭으로 페이지 조작
4. **상태바**: 현재 작업 상태 표시

### 기본 워크플로우

1. **파일 불러오기**: `File > Import` 또는 드래그 앤 드롭
2. **페이지 편집**: 썸네일을 드래그하여 순서 변경
3. **페이지 회전**: 우클릭 > `Rotate` 메뉴
4. **내보내기**: `File > Export Selection` 또는 `Ctrl+E`

## 실전 예제: 커맨드라인 활용

GUI도 좋지만, 반복 작업에는 커맨드라인이 더 효율적입니다. **pikepdf**를 직접 활용한 스크립트들을 살펴보겠습니다.

### 1. PDF 병합

```python
#!/usr/bin/env python3
# merge_pdfs.py - PDF 파일들을 병합하는 스크립트

import pikepdf
import sys
from pathlib import Path

def merge_pdfs(input_files, output_file):
    """여러 PDF 파일을 하나로 병합"""
    merged = pikepdf.new()
    
    for file_path in input_files:
        if not Path(file_path).exists():
            print(f"❌ 파일을 찾을 수 없음: {file_path}")
            continue
            
        try:
            pdf = pikepdf.open(file_path)
            for page in pdf.pages:
                merged.pages.append(page)
            pdf.close()
            print(f"✅ {file_path} 추가됨 ({len(pdf.pages)}페이지)")
        except Exception as e:
            print(f"❌ {file_path} 처리 오류: {e}")
    
    merged.save(output_file)
    merged.close()
    print(f"🎉 병합 완료: {output_file} ({len(merged.pages)}페이지)")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("사용법: python3 merge_pdfs.py file1.pdf file2.pdf ... output.pdf")
        sys.exit(1)
    
    input_files = sys.argv[1:-1]
    output_file = sys.argv[-1]
    merge_pdfs(input_files, output_file)
```

사용 예시:

```bash
# 여러 PDF 병합
python3 merge_pdfs.py report1.pdf report2.pdf report3.pdf merged_report.pdf
```

### 2. PDF 페이지 추출

```python
#!/usr/bin/env python3
# extract_pages.py - 특정 페이지 범위 추출

import pikepdf
import sys

def extract_pages(input_file, start_page, end_page, output_file):
    """PDF에서 특정 페이지 범위 추출"""
    try:
        pdf = pikepdf.open(input_file)
        new_pdf = pikepdf.new()
        
        # 1-based 인덱스를 0-based로 변환
        start_idx = max(0, start_page - 1)
        end_idx = min(len(pdf.pages), end_page)
        
        for i in range(start_idx, end_idx):
            new_pdf.pages.append(pdf.pages[i])
        
        new_pdf.save(output_file)
        print(f"✅ 페이지 {start_page}-{end_page} 추출 완료: {output_file}")
        
        pdf.close()
        new_pdf.close()
        
    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("사용법: python3 extract_pages.py input.pdf start_page end_page output.pdf")
        print("예시: python3 extract_pages.py document.pdf 1 3 pages_1_3.pdf")
        sys.exit(1)
    
    input_file = sys.argv[1]
    start_page = int(sys.argv[2])
    end_page = int(sys.argv[3])
    output_file = sys.argv[4]
    
    extract_pages(input_file, start_page, end_page, output_file)
```

### 3. PDF 페이지별 분할

```python
#!/usr/bin/env python3
# split_pdf.py - PDF를 개별 페이지로 분할

import pikepdf
import sys
from pathlib import Path

def split_pdf(input_file, output_prefix="page"):
    """PDF를 개별 페이지로 분할"""
    try:
        pdf = pikepdf.open(input_file)
        total_pages = len(pdf.pages)
        output_dir = Path(input_file).stem + "_pages"
        Path(output_dir).mkdir(exist_ok=True)
        
        for i, page in enumerate(pdf.pages):
            new_pdf = pikepdf.new()
            new_pdf.pages.append(page)
            
            output_file = f"{output_dir}/{output_prefix}_{i+1:03d}.pdf"
            new_pdf.save(output_file)
            new_pdf.close()
            
            print(f"페이지 {i+1}/{total_pages}: {output_file}")
        
        pdf.close()
        print(f"✅ 분할 완료: {total_pages}개 파일 생성 ({output_dir}/)")
        
    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("사용법: python3 split_pdf.py input.pdf [prefix]")
        print("예시: python3 split_pdf.py document.pdf chapter")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_prefix = sys.argv[2] if len(sys.argv) > 2 else "page"
    
    split_pdf(input_file, output_prefix)
```

### 4. PDF 회전

```python
#!/usr/bin/env python3
# rotate_pdf.py - PDF 페이지 회전

import pikepdf
import sys

def rotate_pdf(input_file, angle, output_file):
    """PDF의 모든 페이지를 지정된 각도로 회전"""
    valid_angles = [90, 180, 270]
    
    if angle not in valid_angles:
        print(f"❌ 유효하지 않은 각도: {angle}")
        print(f"지원되는 각도: {valid_angles}")
        return
    
    try:
        pdf = pikepdf.open(input_file)
        
        for page in pdf.pages:
            page.rotate(angle, relative=True)
        
        pdf.save(output_file)
        pdf.close()
        
        print(f"✅ {angle}도 회전 완료: {output_file}")
        
    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("사용법: python3 rotate_pdf.py input.pdf angle output.pdf")
        print("각도: 90, 180, 270 (시계방향)")
        print("예시: python3 rotate_pdf.py document.pdf 90 rotated.pdf")
        sys.exit(1)
    
    input_file = sys.argv[1]
    angle = int(sys.argv[2])
    output_file = sys.argv[3]
    
    rotate_pdf(input_file, angle, output_file)
```

## zshrc 통합 Aliases

일상적인 PDF 작업을 간소화하기 위한 유용한 alias들을 설정해보겠습니다:

```bash
# ~/.zshrc에 추가

# =============================================================================
# PDF Arranger 관련 Aliases
# =============================================================================

# 기본 명령어
alias pdfgui="pdfarranger"                    # PDF Arranger GUI 실행
alias pdfinfo="python3 -c 'import pikepdf, sys; pdf=pikepdf.open(sys.argv[1]); print(f\"📄 {sys.argv[1]}: {len(pdf.pages)}페이지\"); pdf.close()'"

# PDF 병합 (간단 버전)
alias pdfmerge="python3 -c 'import pikepdf, sys; merged=pikepdf.new(); [merged.pages.extend(pikepdf.open(f).pages) for f in sys.argv[1:]]; merged.save(\"merged.pdf\"); print(\"✅ PDF 병합 완료: merged.pdf\")'"

# PDF 조작 함수들
pdfextract() {
    if [ $# -lt 3 ]; then
        echo "사용법: pdfextract <입력파일> <시작페이지> <끝페이지> [출력파일]"
        return 1
    fi
    
    python3 -c "
import pikepdf
pdf = pikepdf.open('$1')
new_pdf = pikepdf.new()
start, end = max(0, $2-1), min(len(pdf.pages), $3)
[new_pdf.pages.append(pdf.pages[i]) for i in range(start, end)]
new_pdf.save('${4:-extracted.pdf}')
print(f'✅ 페이지 $2-$3 추출 완료: ${4:-extracted.pdf}')
"
}

pdfsplit() {
    python3 -c "
import pikepdf
from pathlib import Path
pdf = pikepdf.open('$1')
output_dir = Path('$1').stem + '_pages'
Path(output_dir).mkdir(exist_ok=True)
for i, page in enumerate(pdf.pages):
    new_pdf = pikepdf.new()
    new_pdf.pages.append(page)
    new_pdf.save(f'{output_dir}/${2:-page}_{i+1:03d}.pdf')
    new_pdf.close()
print(f'✅ 분할 완료: {len(pdf.pages)}개 파일')
"
}

pdfrotate() {
    if [ $# -ne 3 ]; then
        echo "사용법: pdfrotate <입력파일> <각도> <출력파일>"
        echo "각도: 90, 180, 270"
        return 1
    fi
    
    python3 -c "
import pikepdf
pdf = pikepdf.open('$1')
[page.rotate($2, relative=True) for page in pdf.pages]
pdf.save('$3')
print(f'✅ $2도 회전 완료: $3')
"
}

# 유틸리티
alias pdfls="ls -la *.pdf 2>/dev/null || echo '📄 PDF 파일이 없습니다.'"
alias pdfclean="rm -f *.pdf && echo '🗑️ PDF 파일들을 삭제했습니다.'"
```

### Aliases 사용 예시

```bash
# PDF 정보 확인
pdfinfo document.pdf

# 여러 PDF 병합
pdfmerge file1.pdf file2.pdf file3.pdf

# 특정 페이지 추출 (1-3페이지)
pdfextract document.pdf 1 3 excerpt.pdf

# PDF를 개별 페이지로 분할
pdfsplit large_document.pdf chapter

# PDF 90도 회전
pdfrotate document.pdf 90 rotated.pdf

# 현재 디렉토리의 PDF 파일 목록
pdfls

# 모든 PDF 파일 삭제
pdfclean
```

## 고급 활용 팁

### 1. 이미지를 PDF로 변환

img2pdf를 활용하여 이미지 파일들을 PDF로 변환:

```python
#!/usr/bin/env python3
# images_to_pdf.py - 이미지들을 PDF로 변환

import img2pdf
import sys
from pathlib import Path

def images_to_pdf(image_files, output_file):
    """이미지 파일들을 PDF로 변환"""
    try:
        # 지원되는 이미지 형식 확인
        valid_images = []
        supported_formats = {'.jpg', '.jpeg', '.png', '.tiff', '.bmp'}
        
        for img_file in image_files:
            if Path(img_file).suffix.lower() in supported_formats:
                valid_images.append(img_file)
                print(f"✅ {img_file} 추가됨")
            else:
                print(f"❌ 지원되지 않는 형식: {img_file}")
        
        if not valid_images:
            print("❌ 유효한 이미지 파일이 없습니다.")
            return
        
        # PDF 생성
        with open(output_file, "wb") as f:
            f.write(img2pdf.convert(valid_images))
        
        print(f"🎉 PDF 생성 완료: {output_file} ({len(valid_images)}개 이미지)")
        
    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("사용법: python3 images_to_pdf.py image1.jpg image2.png ... output.pdf")
        sys.exit(1)
    
    image_files = sys.argv[1:-1]
    output_file = sys.argv[-1]
    images_to_pdf(image_files, output_file)
```

### 2. PDF 메타데이터 편집

```python
#!/usr/bin/env python3
# edit_metadata.py - PDF 메타데이터 편집

import pikepdf
import sys
from datetime import datetime

def edit_metadata(input_file, output_file, title=None, author=None, subject=None):
    """PDF 메타데이터 편집"""
    try:
        pdf = pikepdf.open(input_file)
        
        # 기존 메타데이터 확인
        with pdf.open_metadata() as meta:
            print("📋 기존 메타데이터:")
            print(f"  제목: {meta.get('dc:title', 'N/A')}")
            print(f"  작성자: {meta.get('dc:creator', 'N/A')}")
            print(f"  주제: {meta.get('dc:subject', 'N/A')}")
            
            # 새 메타데이터 설정
            if title:
                meta['dc:title'] = title
                print(f"✅ 제목 변경: {title}")
            
            if author:
                meta['dc:creator'] = author
                print(f"✅ 작성자 변경: {author}")
            
            if subject:
                meta['dc:subject'] = subject
                print(f"✅ 주제 변경: {subject}")
            
            # 수정 날짜 업데이트
            meta['xmp:ModifyDate'] = datetime.now().isoformat()
        
        pdf.save(output_file)
        pdf.close()
        print(f"🎉 메타데이터 업데이트 완료: {output_file}")
        
    except Exception as e:
        print(f"❌ 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("사용법: python3 edit_metadata.py input.pdf output.pdf [--title 제목] [--author 작성자] [--subject 주제]")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    # 인자 파싱
    args = sys.argv[3:]
    title = author = subject = None
    
    for i in range(0, len(args), 2):
        if i + 1 < len(args):
            if args[i] == '--title':
                title = args[i + 1]
            elif args[i] == '--author':
                author = args[i + 1]
            elif args[i] == '--subject':
                subject = args[i + 1]
    
    edit_metadata(input_file, output_file, title, author, subject)
```

### 3. PDF 암호화/복호화

```python
#!/usr/bin/env python3
# pdf_security.py - PDF 암호화 및 복호화

import pikepdf
import sys
import getpass

def encrypt_pdf(input_file, output_file, password):
    """PDF에 암호 설정"""
    try:
        pdf = pikepdf.open(input_file)
        pdf.save(output_file, encryption=pikepdf.Encryption(
            user=password,
            owner=password,
            R=4  # 128-bit 암호화
        ))
        pdf.close()
        print(f"🔒 암호화 완료: {output_file}")
    except Exception as e:
        print(f"❌ 암호화 오류: {e}")

def decrypt_pdf(input_file, output_file, password):
    """암호화된 PDF 복호화"""
    try:
        pdf = pikepdf.open(input_file, password=password)
        pdf.save(output_file)
        pdf.close()
        print(f"🔓 복호화 완료: {output_file}")
    except Exception as e:
        print(f"❌ 복호화 오류: {e}")

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("사용법:")
        print("  암호화: python3 pdf_security.py encrypt input.pdf output.pdf")
        print("  복호화: python3 pdf_security.py decrypt input.pdf output.pdf")
        sys.exit(1)
    
    action = sys.argv[1]
    input_file = sys.argv[2]
    output_file = sys.argv[3]
    
    password = getpass.getpass("암호 입력: ")
    
    if action == "encrypt":
        encrypt_pdf(input_file, output_file, password)
    elif action == "decrypt":
        decrypt_pdf(input_file, output_file, password)
    else:
        print("❌ 알 수 없는 작업:", action)
```

## 문제 해결

### 자주 발생하는 오류와 해결책

#### 1. GTK 관련 오류

```bash
# 오류: gi.repository.Gtk를 찾을 수 없음
pip3 install --user --force-reinstall PyGObject

# 환경 변수 재설정
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"
```

#### 2. PATH 오류

```bash
# PDF Arranger 실행 파일을 찾을 수 없음
export PATH="$HOME/.local/bin:$PATH"
which pdfarranger  # 경로 확인
```

#### 3. 메모리 부족 오류

대용량 PDF 처리 시 메모리 부족이 발생할 수 있습니다:

```python
# 큰 PDF 파일 처리 시 페이지별로 분할하여 처리
def process_large_pdf(input_file, chunk_size=50):
    """큰 PDF를 청크 단위로 처리"""
    pdf = pikepdf.open(input_file)
    total_pages = len(pdf.pages)
    
    for start in range(0, total_pages, chunk_size):
        end = min(start + chunk_size, total_pages)
        chunk_pdf = pikepdf.new()
        
        for i in range(start, end):
            chunk_pdf.pages.append(pdf.pages[i])
        
        chunk_pdf.save(f"chunk_{start//chunk_size + 1}.pdf")
        chunk_pdf.close()
        print(f"청크 {start//chunk_size + 1} 완료 (페이지 {start+1}-{end})")
    
    pdf.close()
```

#### 4. 권한 오류

```bash
# pip 권한 오류 시 사용자 디렉토리에 설치
pip3 install --user 패키지명

# Homebrew 권한 오류 시
sudo chown -R $(whoami) $(brew --prefix)/*
```

### 성능 최적화 팁

1. **큰 PDF 처리**: 청크 단위로 분할하여 메모리 사용량 최적화
2. **배치 처리**: 여러 파일을 한 번에 처리하여 시간 단축
3. **프로파일링**: `time` 명령어로 처리 시간 측정

```bash
# 처리 시간 측정
time python3 merge_pdfs.py *.pdf merged.pdf

# 메모리 사용량 모니터링
/usr/bin/time -l python3 split_pdf.py large_document.pdf
```

## 실제 사용 사례

### 1. 학술 논문 정리

```bash
# 여러 논문을 하나의 PDF로 병합
pdfmerge paper1.pdf paper2.pdf paper3.pdf research_collection.pdf

# 특정 섹션만 추출 (예: 초록과 결론 부분)
pdfextract paper1.pdf 1 2 abstract.pdf
pdfextract paper1.pdf 15 17 conclusion.pdf
```

### 2. 보고서 편집

```bash
# 보고서 표지와 본문 병합
pdfmerge cover.pdf main_report.pdf appendix.pdf final_report.pdf

# 각 챕터별로 분할
pdfsplit final_report.pdf chapter

# 페이지 회전 (스캔된 문서의 방향 수정)
pdfrotate scanned_document.pdf 90 corrected_document.pdf
```

### 3. 이미지 자료 PDF화

```bash
# 스캔한 이미지들을 PDF로 변환
python3 images_to_pdf.py scan001.jpg scan002.jpg scan003.jpg document.pdf

# 각 페이지를 이미지로 추출 (역방향)
pdftoppm -jpeg document.pdf page
```

## 마무리

PDF Arranger는 일상적인 PDF 편집 작업을 크게 간소화해주는 강력한 도구입니다. GUI 인터페이스의 직관성과 pikepdf의 강력한 기능을 결합하여, 전문적인 PDF 편집기 못지않은 성능을 제공합니다.

### 핵심 장점 요약

- **무료 오픈소스**: 상용 소프트웨어 대비 경제적
- **크로스 플랫폼**: Linux, Windows, macOS 지원
- **강력한 기능**: 병합, 분할, 회전, 자르기 등 모든 기본 편집 기능
- **확장성**: Python 기반으로 커스터마이징 가능
- **배치 처리**: 스크립트를 통한 대량 작업 자동화

### 추천 워크플로우

1. **일회성 작업**: PDF Arranger GUI 사용
2. **반복 작업**: 커스텀 Python 스크립트 작성
3. **일상 작업**: zshrc aliases 활용
4. **대량 처리**: 배치 스크립트 사용

PDF 편집 작업의 효율성을 높이고 싶다면, PDF Arranger를 도입해보시기 바랍니다. 특히 개발자나 연구자처럼 문서 작업이 빈번한 분들에게는 없어서는 안 될 도구가 될 것입니다.

### 다음 단계

PDF Arranger를 더 깊이 있게 활용하고 싶다면:

1. **pikepdf 공식 문서** 참고하여 고급 기능 학습
2. **GTK 개발** 학습하여 커스텀 GUI 개발
3. **자동화 스크립트** 작성으로 워크플로우 최적화
4. **CI/CD 파이프라인**에 통합하여 문서 자동 처리

PDF 편집의 새로운 차원을 경험해보세요! 🚀
