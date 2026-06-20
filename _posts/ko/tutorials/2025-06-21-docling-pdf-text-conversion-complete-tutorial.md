---
title: "Docling 완전 정복: PDF를 텍스트로 변환하는 최고의 도구 사용법"
excerpt: "IBM에서 개발한 Docling을 이용해 PDF 문서를 텍스트로 완벽하게 변환하는 방법을 단계별로 설명합니다. 설치부터 고급 활용법까지 모든 것을 다룹니다."
date: 2025-06-21
categories: 
  - tutorials
  - dev
tags: 
  - Docling
  - PDF변환
  - 문서처리
  - Python
  - CLI도구
  - 자동화
  - 텍스트추출
author_profile: true
toc: true
toc_label: "Docling 튜토리얼"
published: false
---

## Docling이란 무엇인가?

**Docling**은 IBM에서 개발한 고성능 문서 파싱 라이브러리로, PDF, Word, PowerPoint 등 다양한 문서 형식을 구조화된 텍스트로 변환할 수 있는 강력한 도구입니다. 특히 **학술 논문, 기술 문서, 보고서** 등의 복잡한 레이아웃을 가진 문서도 정확하게 처리할 수 있어 연구자와 개발자들에게 매우 유용합니다.

### 주요 특징

- **고정밀 텍스트 추출**: 복잡한 레이아웃도 정확하게 파싱
- **다양한 출력 형식**: 텍스트, 마크다운, JSON 등 지원
- **이미지 처리 옵션**: 이미지 추출, 제외, 플레이스홀더 등 선택 가능
- **CLI와 Python API** 모두 지원
- **배치 처리** 기능으로 대량 문서 처리 가능

## 설치 방법

### 1. Python 환경 준비

Docling은 Python 3.9 이상에서 작동합니다. 먼저 Python 버전을 확인해보세요.

```bash
python --version
# 또는
python3 --version
```

### 2. 가상환경 생성 (권장)

프로젝트별로 독립적인 환경을 만들어 의존성 충돌을 방지합니다.

```bash
# 가상환경 생성
python -m venv docling-env

# 가상환경 활성화 (macOS/Linux)
source docling-env/bin/activate

# 가상환경 활성화 (Windows)
docling-env\Scripts\activate
```

### 3. Docling 설치

```bash
# 기본 설치
pip install docling

# 전체 기능 설치 (OCR 포함)
pip install docling[ocr]

# 설치 확인
docling --version
```

## 기본 사용법

### CLI를 통한 단일 파일 변환

```bash
# PDF를 텍스트로 변환
docling --from pdf --to text document.pdf

# 출력 파일 지정
docling --from pdf --to text document.pdf --output result.txt

# 마크다운으로 변환
docling --from pdf --to markdown document.pdf
```

### 이미지 처리 옵션

```bash
# 이미지 완전 제외
docling --from pdf --to text --image-export-mode none document.pdf

# 이미지를 플레이스홀더로 표시
docling --from pdf --to text --image-export-mode placeholder document.pdf

# 이미지를 별도 파일로 추출
docling --from pdf --to text --image-export-mode referenced document.pdf
```

## 편리한 Alias 설정: pdfdoc

매번 긴 명령어를 입력하는 것은 번거롭습니다. **pdfdoc**이라는 간단한 alias를 만들어 효율성을 높여보겠습니다.

### macOS/Linux 사용자

`.zshrc` 또는 `.bashrc` 파일에 다음 함수를 추가하세요:

```bash
# 파일 편집
nano ~/.zshrc  # zsh 사용자
# 또는
nano ~/.bashrc # bash 사용자
```

다음 함수를 추가합니다:

```bash
# pdfdoc — PDF 파일을 텍스트로 변환 (이미지 제외)
pdfdoc() {
  local src="$1"
  
  # 인자 확인
  if [[ -z "$src" ]]; then
    echo "Usage: pdfdoc <file.pdf>"
    echo "Example: pdfdoc research_paper.pdf"
    return 1
  fi
  
  # PDF 파일 확인
  if [[ "${src##*.}" != "pdf" ]]; then
    echo "Error: '$src' is not a PDF file."
    return 1
  fi
  
  # 파일 존재 확인
  if [[ ! -f "$src" ]]; then
    echo "Error: File '$src' not found."
    return 1
  fi
  
  # 출력 파일명 생성
  local dst="${src%.pdf}.txt"
  
  # 변환 실행
  echo "🚀 Converting '$src' to text..."
  docling \
    --from pdf \
    --to text \
    --image-export-mode placeholder \
    "$src" > "$dst"
  
  if [[ $? -eq 0 ]]; then
    echo "✅ Successfully converted '$src' → '$dst'"
    echo "📄 Output file size: $(du -h "$dst" | cut -f1)"
  else
    echo "❌ Conversion failed"
    return 1
  fi
}
```

설정을 적용합니다:

```bash
source ~/.zshrc
# 또는
source ~/.bashrc
```

### 사용 예시

```bash
# 간단한 변환
pdfdoc research_paper.pdf
# → research_paper.txt 생성

# 결과 확인
ls -la *.txt
cat research_paper.txt | head -20
```

## Python API 활용법

CLI 외에도 Python 스크립트에서 직접 사용할 수 있습니다.

### 기본 사용법

```python
from docling.document_converter import DocumentConverter

# 변환기 초기화
converter = DocumentConverter()

# PDF 변환
result = converter.convert("document.pdf")

# 텍스트 추출
text_content = result.document.export_to_text()
print(text_content)

# 파일로 저장
with open("output.txt", "w", encoding="utf-8") as f:
    f.write(text_content)
```

### 배치 처리 스크립트

여러 PDF 파일을 한 번에 처리하는 스크립트입니다:

```python
import os
import glob
from docling.document_converter import DocumentConverter
from pathlib import Path

def batch_convert_pdfs(input_dir, output_dir):
    """PDF 파일들을 일괄 변환"""
    
    # 출력 디렉토리 생성
    Path(output_dir).mkdir(exist_ok=True)
    
    # PDF 파일 찾기
    pdf_files = glob.glob(os.path.join(input_dir, "*.pdf"))
    
    if not pdf_files:
        print(f"No PDF files found in {input_dir}")
        return
    
    # 변환기 초기화
    converter = DocumentConverter()
    
    # 각 파일 처리
    for pdf_file in pdf_files:
        try:
            print(f"🔄 Processing: {os.path.basename(pdf_file)}")
            
            # 변환 실행
            result = converter.convert(pdf_file)
            text_content = result.document.export_to_text()
            
            # 출력 파일명 생성
            base_name = Path(pdf_file).stem
            output_file = os.path.join(output_dir, f"{base_name}.txt")
            
            # 파일 저장
            with open(output_file, "w", encoding="utf-8") as f:
                f.write(text_content)
            
            print(f"✅ Saved: {output_file}")
            
        except Exception as e:
            print(f"❌ Error processing {pdf_file}: {str(e)}")

# 사용 예시
if __name__ == "__main__":
    batch_convert_pdfs("./pdfs", "./outputs")
```

## 고급 활용법

### 1. 문서 구조 분석

```python
from docling.document_converter import DocumentConverter

converter = DocumentConverter()
result = converter.convert("document.pdf")

# 페이지별 정보
for page_no, page in enumerate(result.document.pages):
    print(f"Page {page_no + 1}:")
    print(f"  - Dimensions: {page.size}")
    print(f"  - Elements: {len(page.elements)}")

# 문서 메타데이터
metadata = result.document.metadata
print(f"Title: {metadata.get('title', 'N/A')}")
print(f"Author: {metadata.get('author', 'N/A')}")
```

### 2. 특정 섹션만 추출

```python
def extract_sections(pdf_path, keywords):
    """특정 키워드가 포함된 섹션만 추출"""
    
    converter = DocumentConverter()
    result = converter.convert(pdf_path)
    text_content = result.document.export_to_text()
    
    lines = text_content.split('\n')
    extracted_sections = []
    current_section = []
    in_target_section = False
    
    for line in lines:
        # 키워드 매칭 확인
        if any(keyword.lower() in line.lower() for keyword in keywords):
            if current_section:
                extracted_sections.append('\n'.join(current_section))
            current_section = [line]
            in_target_section = True
        elif in_target_section:
            current_section.append(line)
    
    if current_section:
        extracted_sections.append('\n'.join(current_section))
    
    return extracted_sections

# 사용 예시
sections = extract_sections("research.pdf", ["introduction", "methodology", "conclusion"])
for i, section in enumerate(sections):
    print(f"=== Section {i+1} ===")
    print(section[:200] + "...")
```

### 3. 마크다운 변환 with 자동 정리

```bash
# 향상된 pdfdoc 함수 (마크다운 버전)
pdfmd() {
  local src="$1"
  
  if [[ -z "$src" ]]; then
    echo "Usage: pdfmd <file.pdf>"
    return 1
  fi
  
  if [[ ! -f "$src" ]]; then
    echo "Error: File '$src' not found."
    return 1
  fi
  
  local dst="${src%.pdf}.md"
  
  echo "🚀 Converting '$src' to Markdown..."
  docling \
    --from pdf \
    --to markdown \
    --image-export-mode referenced \
    "$src" > "$dst"
  
  if [[ $? -eq 0 ]]; then
    echo "✅ Successfully converted '$src' → '$dst'"
    
    # 추가 정리 작업
    echo "🔧 Cleaning up markdown..."
    
    # 빈 줄 정리 (3개 이상의 연속 빈 줄을 2개로 축소)
    sed -i '' '/^$/N;/^\n$/d' "$dst"
    
    # 기본 통계 출력
    local lines=$(wc -l < "$dst")
    local words=$(wc -w < "$dst")
    echo "📊 Statistics: $lines lines, $words words"
  else
    echo "❌ Conversion failed"
    return 1
  fi
}
```

## 문제 해결

### 1. 설치 오류

```bash
# 의존성 문제 해결
pip install --upgrade pip setuptools wheel

# 시스템 라이브러리 설치 (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install python3-dev libxml2-dev libxslt1-dev

# macOS에서 Homebrew 사용
brew install libxml2 libxslt
```

### 2. OCR 관련 문제

```bash
# Tesseract OCR 설치
# macOS
brew install tesseract

# Ubuntu/Debian
sudo apt-get install tesseract-ocr

# 한국어 언어팩 추가
sudo apt-get install tesseract-ocr-kor  # Ubuntu
brew install tesseract-lang             # macOS
```

### 3. 메모리 부족 문제

```python
# 대용량 파일 처리를 위한 설정
import os
os.environ['DOCLING_MAX_MEMORY'] = '8G'  # 8GB로 제한

# 페이지별 처리
from docling.document_converter import DocumentConverter

def process_large_pdf(pdf_path, max_pages_per_batch=10):
    converter = DocumentConverter()
    
    # 총 페이지 수 확인
    result = converter.convert(pdf_path)
    total_pages = len(result.document.pages)
    
    all_text = []
    
    # 배치별로 처리
    for start_page in range(0, total_pages, max_pages_per_batch):
        end_page = min(start_page + max_pages_per_batch, total_pages)
        
        print(f"Processing pages {start_page+1}-{end_page}...")
        
        # 페이지 범위 지정 변환
        batch_result = converter.convert(
            pdf_path, 
            page_range=(start_page, end_page)
        )
        
        batch_text = batch_result.document.export_to_text()
        all_text.append(batch_text)
    
    return '\n'.join(all_text)
```

## 실전 활용 시나리오

### 1. 연구 논문 분석 자동화

```bash
#!/bin/bash
# research_analyzer.sh

echo "📚 Research Paper Analyzer"
echo "=========================="

# 논문 디렉토리 확인
PAPER_DIR="./papers"
OUTPUT_DIR="./analysis"

if [[ ! -d "$PAPER_DIR" ]]; then
    echo "Error: Papers directory not found"
    exit 1
fi

mkdir -p "$OUTPUT_DIR"

# 모든 PDF 처리
for pdf in "$PAPER_DIR"/*.pdf; do
    if [[ -f "$pdf" ]]; then
        filename=$(basename "$pdf" .pdf)
        echo "🔍 Analyzing: $filename"
        
        # 텍스트 변환
        pdfdoc "$pdf"
        
        # 키워드 추출 (간단한 예시)
        grep -i -E "(conclusion|result|finding)" "${pdf%.pdf}.txt" > "$OUTPUT_DIR/${filename}_keywords.txt"
        
        echo "✅ Analysis complete: $filename"
    fi
done

echo "🎉 All papers analyzed!"
```

### 2. 문서 검색 시스템

```python
import os
import json
from docling.document_converter import DocumentConverter
from collections import defaultdict

class DocumentSearcher:
    def __init__(self, docs_dir):
        self.docs_dir = docs_dir
        self.index = defaultdict(list)
        self.converter = DocumentConverter()
        self._build_index()
    
    def _build_index(self):
        """문서 인덱스 구축"""
        print("🔨 Building search index...")
        
        for filename in os.listdir(self.docs_dir):
            if filename.endswith('.pdf'):
                pdf_path = os.path.join(self.docs_dir, filename)
                
                try:
                    result = self.converter.convert(pdf_path)
                    text = result.document.export_to_text().lower()
                    
                    # 단어별 인덱싱
                    words = text.split()
                    for word in words:
                        if len(word) > 3:  # 3글자 이상만
                            self.index[word].append(filename)
                    
                    print(f"✅ Indexed: {filename}")
                    
                except Exception as e:
                    print(f"❌ Error indexing {filename}: {e}")
        
        print(f"🎉 Index built with {len(self.index)} unique terms")
    
    def search(self, query):
        """검색 실행"""
        query_words = query.lower().split()
        candidates = defaultdict(int)
        
        for word in query_words:
            for doc in self.index.get(word, []):
                candidates[doc] += 1
        
        # 점수순 정렬
        results = sorted(candidates.items(), key=lambda x: x[1], reverse=True)
        return results[:10]  # 상위 10개만

# 사용 예시
searcher = DocumentSearcher("./documents")
results = searcher.search("machine learning algorithm")

print("🔍 Search Results:")
for doc, score in results:
    print(f"  {doc} (score: {score})")
```

## 마무리

Docling은 PDF 문서 처리의 새로운 표준을 제시하는 강력한 도구입니다. 이 튜토리얼에서 다룬 내용들을 단계적으로 따라하면서 여러분만의 문서 처리 워크플로우를 구축해보세요.

### 핵심 포인트 요약

1. **설치**: `pip install docling[ocr]`로 전체 기능 설치
2. **기본 사용**: `docling --from pdf --to text document.pdf`
3. **편의성**: `pdfdoc` alias로 간단하게 사용
4. **자동화**: Python API로 배치 처리 및 고급 기능 구현
5. **문제 해결**: 의존성, OCR, 메모리 관련 이슈 대응

### 다음 단계

- 여러분의 특정 사용 사례에 맞는 스크립트 개발
- 다른 문서 형식(Word, PowerPoint) 처리 실험
- 웹 인터페이스 구축으로 비개발자도 사용할 수 있는 도구 제작

문서 처리 자동화의 첫걸음을 Docling과 함께 시작해보세요! 🚀

---

**참고 자료**:

- [Docling 공식 문서](https://docling-project.github.io/docling/)
- [GitHub 저장소](https://github.com/DS4SD/docling)
- [PyPI 패키지](https://pypi.org/project/docling/)
