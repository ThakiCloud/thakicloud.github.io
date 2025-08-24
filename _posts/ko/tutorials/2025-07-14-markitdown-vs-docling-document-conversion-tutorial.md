---
title: "MarkItDown vs Docling: 문서 변환 도구 완벽 비교 가이드"
excerpt: "Microsoft MarkItDown과 IBM Docling을 실제 테스트와 함께 비교 분석하여 최적의 문서 변환 도구를 선택하는 방법을 알아보겠습니다."
seo_title: "MarkItDown vs Docling 문서 변환 도구 비교 튜토리얼 - Thaki Cloud"
seo_description: "Microsoft MarkItDown과 IBM Docling의 기능, 성능, 사용법을 실제 테스트와 함께 비교하여 최적의 문서 변환 도구를 선택하는 완벽 가이드"
date: 2025-07-14
last_modified_at: 2025-07-14
categories:
  - tutorials
tags:
  - MarkItDown
  - Docling
  - DocumentConversion
  - Python
  - PDF
  - Markdown
  - Microsoft
  - IBM
  - LLMOps
  - MacOS
  - AI
  - DataProcessing
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/markitdown-vs-docling-document-conversion-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 서론

### 문서 변환 도구의 중요성

현대 AI 시스템과 LLMOps 환경에서는 다양한 형식의 문서를 구조화된 텍스트로 변환하는 것이 필수적입니다. Microsoft MarkItDown과 IBM Docling은 이러한 요구사항을 해결하기 위해 개발된 강력한 오픈소스 도구들입니다.

### 비교 대상 소개

**Microsoft MarkItDown**
- 다양한 파일 형식을 Markdown으로 변환하는 Python 라이브러리
- LLM과 텍스트 분석 파이프라인에 최적화
- 간단한 API와 광범위한 파일 형식 지원

**IBM Docling**
- 엔터프라이즈급 문서 변환 플랫폼
- 고품질 텍스트 추출과 구조 보존에 중점
- 복잡한 문서 레이아웃 처리에 특화

### 선택 기준

적절한 도구를 선택하기 위한 주요 기준:
- **사용 편의성**: 설치 및 사용법의 간단함
- **지원 형식**: 처리 가능한 파일 형식의 다양성
- **변환 품질**: 원본 문서의 구조와 내용 보존도
- **성능**: 처리 속도와 메모리 사용량
- **확장성**: 대용량 문서 처리 능력

## 기능 비교 분석

### 1. 지원 파일 형식 비교

**MarkItDown 지원 형식:**
- 문서: PDF, DOCX, PPTX, XLSX
- 이미지: PNG, JPG, JPEG, GIF
- 웹: HTML, URL
- 미디어: MP3, WAV, MP4
- 압축: ZIP
- 데이터: CSV, JSON, XML
- 전자책: EPUB
- 특수: YouTube URLs

**Docling 지원 형식:**
- 문서: PDF, DOCX, PPTX, HTML
- 이미지: PNG, JPG, JPEG
- 구조화 문서: XML, JSON
- 웹 콘텐츠: HTML, URL

### 2. 출력 형식 비교

**MarkItDown 출력:**
- 주 형식: Markdown
- 구조화된 텍스트 출력
- 메타데이터 포함

**Docling 출력:**
- 다양한 형식: JSON, Markdown, HTML
- 구조화된 데이터 출력
- 레이아웃 정보 보존

### 3. 핵심 기능 비교

| 기능 | MarkItDown | Docling |
|------|------------|---------|
| 설치 복잡도 | 간단 | 중간 |
| API 복잡도 | 간단 | 중간 |
| 텍스트 품질 | 우수 | 매우 우수 |
| 레이아웃 보존 | 기본 | 고급 |
| 속도 | 빠름 | 중간 |
| 메모리 사용량 | 적음 | 중간 |
| 확장성 | 높음 | 매우 높음 |

## 실제 설치 및 사용법

### MarkItDown 설치 및 테스트

**1. 환경 설정**
```bash
# Python 가상환경 생성
python -m venv markitdown_env
source markitdown_env/bin/activate

# MarkItDown 설치
pip install markitdown
```

**2. 기본 사용법**
```python
# markitdown_test.py
from markitdown import MarkItDown

# MarkItDown 인스턴스 생성
md = MarkItDown()

# PDF 파일 변환
result = md.convert("sample.pdf")
print(result.text_content)

# 이미지 파일 변환 (OCR)
result = md.convert("document.png")
print(result.text_content)

# PowerPoint 파일 변환
result = md.convert("presentation.pptx")
print(result.text_content)
```

**3. 고급 사용법**
```python
# 여러 파일 일괄 변환
import os
from pathlib import Path

def batch_convert(input_dir, output_dir):
    md = MarkItDown()
    
    for file_path in Path(input_dir).glob("*"):
        if file_path.suffix.lower() in ['.pdf', '.docx', '.pptx']:
            try:
                result = md.convert(str(file_path))
                output_path = Path(output_dir) / f"{file_path.stem}.md"
                with open(output_path, 'w', encoding='utf-8') as f:
                    f.write(result.text_content)
                print(f"변환 완료: {file_path.name}")
            except Exception as e:
                print(f"변환 실패: {file_path.name} - {e}")

# 사용 예시
batch_convert("./input", "./output")
```

### Docling 설치 및 테스트

**1. 환경 설정**
```bash
# Python 가상환경 생성
python -m venv docling_env
source docling_env/bin/activate

# Docling 설치
pip install docling
```

**2. 기본 사용법**
```python
# docling_test.py
from docling.document_converter import DocumentConverter

# DocumentConverter 인스턴스 생성
converter = DocumentConverter()

# PDF 파일 변환
result = converter.convert("sample.pdf")
print(result.document.export_to_markdown())

# 구조화된 출력
json_output = result.document.export_to_json()
print(json_output)
```

**3. 고급 사용법**
```python
# 고급 설정을 사용한 변환
from docling.document_converter import DocumentConverter, PdfFormatOption
from docling.datamodel.base_models import InputFormat

# 변환 옵션 설정
pipeline_options = PdfFormatOption(
    do_ocr=True,
    do_table_structure=True,
    table_structure_options={"do_cell_matching": True}
)

# 커스텀 변환기 생성
converter = DocumentConverter(
    format_options={
        InputFormat.PDF: pipeline_options,
    }
)

# 변환 실행
result = converter.convert("complex_document.pdf")

# 결과 저장
with open("output.md", "w", encoding="utf-8") as f:
    f.write(result.document.export_to_markdown())
```

## 성능 비교 테스트

### 테스트 환경 설정

```bash
# 테스트 스크립트 생성
cat > performance_test.py << 'EOF'
import time
import psutil
import os
from pathlib import Path
from markitdown import MarkItDown
from docling.document_converter import DocumentConverter

def measure_performance(func, *args):
    """성능 측정 함수"""
    process = psutil.Process(os.getpid())
    start_memory = process.memory_info().rss / 1024 / 1024  # MB
    
    start_time = time.time()
    result = func(*args)
    end_time = time.time()
    
    end_memory = process.memory_info().rss / 1024 / 1024  # MB
    
    return {
        'result': result,
        'time': end_time - start_time,
        'memory_used': end_memory - start_memory,
        'peak_memory': end_memory
    }

def test_markitdown(file_path):
    """MarkItDown 테스트"""
    md = MarkItDown()
    return md.convert(file_path).text_content

def test_docling(file_path):
    """Docling 테스트"""
    converter = DocumentConverter()
    result = converter.convert(file_path)
    return result.document.export_to_markdown()

# 테스트 실행
test_file = "sample.pdf"  # 테스트할 파일

print("=== MarkItDown 성능 테스트 ===")
markitdown_result = measure_performance(test_markitdown, test_file)
print(f"처리 시간: {markitdown_result['time']:.2f}초")
print(f"메모리 사용량: {markitdown_result['memory_used']:.2f}MB")

print("\n=== Docling 성능 테스트 ===")
docling_result = measure_performance(test_docling, test_file)
print(f"처리 시간: {docling_result['time']:.2f}초")
print(f"메모리 사용량: {docling_result['memory_used']:.2f}MB")
EOF
```

### 실제 테스트 결과 분석

**처리 속도 비교:**
- **MarkItDown**: 일반적으로 더 빠른 처리 속도
- **Docling**: 정확도를 위해 약간 느린 처리 속도

**메모리 사용량 비교:**
- **MarkItDown**: 상대적으로 적은 메모리 사용
- **Docling**: 고품질 처리를 위해 더 많은 메모리 사용

**변환 품질 비교:**
- **MarkItDown**: 빠르고 실용적인 변환 결과
- **Docling**: 더 정확한 구조 보존과 레이아웃 처리

## 실제 사용 사례별 비교

### 1. 대용량 문서 처리

**MarkItDown 사용 사례:**
```python
# 대용량 파일 스트리밍 처리
def process_large_documents(directory):
    md = MarkItDown()
    
    for file_path in Path(directory).glob("*.pdf"):
        try:
            # 메모리 효율적인 처리
            result = md.convert(str(file_path))
            
            # 청크 단위로 처리
            chunks = split_text_into_chunks(result.text_content, 1000)
            
            for i, chunk in enumerate(chunks):
                output_file = f"{file_path.stem}_chunk_{i}.md"
                with open(output_file, 'w', encoding='utf-8') as f:
                    f.write(chunk)
                    
        except Exception as e:
            print(f"처리 실패: {file_path.name} - {e}")

def split_text_into_chunks(text, chunk_size):
    """텍스트를 청크로 분할"""
    words = text.split()
    chunks = []
    
    for i in range(0, len(words), chunk_size):
        chunk = ' '.join(words[i:i + chunk_size])
        chunks.append(chunk)
    
    return chunks
```

**Docling 사용 사례:**
```python
# 고품질 대용량 문서 처리
def process_enterprise_documents(directory):
    converter = DocumentConverter()
    
    for file_path in Path(directory).glob("*.pdf"):
        try:
            # 고품질 변환 설정
            result = converter.convert(str(file_path))
            
            # 구조화된 출력
            markdown_output = result.document.export_to_markdown()
            json_output = result.document.export_to_json()
            
            # 결과 저장
            base_name = file_path.stem
            
            with open(f"{base_name}.md", 'w', encoding='utf-8') as f:
                f.write(markdown_output)
                
            with open(f"{base_name}.json", 'w', encoding='utf-8') as f:
                f.write(json_output)
                
        except Exception as e:
            print(f"처리 실패: {file_path.name} - {e}")
```

### 2. 실시간 문서 변환 서비스

**MarkItDown 기반 웹 서비스:**
```python
# Flask 기반 실시간 변환 서비스
from flask import Flask, request, jsonify
from markitdown import MarkItDown
import tempfile
import os

app = Flask(__name__)
md = MarkItDown()

@app.route('/convert', methods=['POST'])
def convert_document():
    try:
        # 업로드된 파일 받기
        file = request.files['document']
        
        # 임시 파일로 저장
        with tempfile.NamedTemporaryFile(delete=False) as tmp_file:
            file.save(tmp_file.name)
            
            # 변환 실행
            result = md.convert(tmp_file.name)
            
            # 임시 파일 삭제
            os.unlink(tmp_file.name)
            
            return jsonify({
                'status': 'success',
                'content': result.text_content,
                'metadata': result.metadata if hasattr(result, 'metadata') else {}
            })
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

if __name__ == '__main__':
    app.run(debug=True)
```

**Docling 기반 고급 서비스:**
```python
# FastAPI 기반 고급 변환 서비스
from fastapi import FastAPI, File, UploadFile, HTTPException
from docling.document_converter import DocumentConverter
import tempfile
import os

app = FastAPI()
converter = DocumentConverter()

@app.post("/convert")
async def convert_document(file: UploadFile = File(...)):
    try:
        # 임시 파일로 저장
        with tempfile.NamedTemporaryFile(delete=False, suffix=f".{file.filename.split('.')[-1]}") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file.flush()
            
            # 변환 실행
            result = converter.convert(tmp_file.name)
            
            # 임시 파일 삭제
            os.unlink(tmp_file.name)
            
            return {
                'status': 'success',
                'markdown': result.document.export_to_markdown(),
                'json': result.document.export_to_json(),
                'metadata': {
                    'pages': len(result.document.pages) if hasattr(result.document, 'pages') else 0,
                    'title': result.document.title if hasattr(result.document, 'title') else file.filename
                }
            }
            
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

### 3. LLM 데이터 전처리 파이프라인

**MarkItDown 기반 파이프라인:**
```python
# LLM 학습 데이터 전처리
import json
from pathlib import Path
from markitdown import MarkItDown

class DocumentPreprocessor:
    def __init__(self):
        self.md = MarkItDown()
        
    def process_training_data(self, input_dir, output_file):
        """학습 데이터 전처리"""
        training_data = []
        
        for file_path in Path(input_dir).glob("*"):
            if file_path.suffix.lower() in ['.pdf', '.docx', '.pptx']:
                try:
                    # 문서 변환
                    result = self.md.convert(str(file_path))
                    
                    # 텍스트 정제
                    cleaned_text = self.clean_text(result.text_content)
                    
                    # 청크 분할
                    chunks = self.create_chunks(cleaned_text)
                    
                    # 학습 데이터 형식으로 변환
                    for chunk in chunks:
                        training_data.append({
                            'text': chunk,
                            'source': str(file_path),
                            'length': len(chunk)
                        })
                        
                except Exception as e:
                    print(f"처리 실패: {file_path.name} - {e}")
        
        # 결과 저장
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(training_data, f, ensure_ascii=False, indent=2)
            
        return len(training_data)
    
    def clean_text(self, text):
        """텍스트 정제"""
        # 불필요한 공백 제거
        text = ' '.join(text.split())
        
        # 특수 문자 정리
        text = text.replace('\n\n', '\n')
        text = text.replace('\t', ' ')
        
        return text
    
    def create_chunks(self, text, max_length=1000):
        """텍스트 청크 생성"""
        sentences = text.split('. ')
        chunks = []
        current_chunk = []
        current_length = 0
        
        for sentence in sentences:
            if current_length + len(sentence) > max_length:
                chunks.append('. '.join(current_chunk) + '.')
                current_chunk = [sentence]
                current_length = len(sentence)
            else:
                current_chunk.append(sentence)
                current_length += len(sentence)
        
        if current_chunk:
            chunks.append('. '.join(current_chunk) + '.')
        
        return chunks

# 사용 예시
preprocessor = DocumentPreprocessor()
count = preprocessor.process_training_data("./documents", "training_data.json")
print(f"처리된 청크 수: {count}")
```

## 선택 가이드

### MarkItDown을 선택해야 하는 경우

**적합한 상황:**
- **빠른 프로토타이핑**: 신속한 개발과 테스트가 필요한 경우
- **다양한 파일 형식**: 오디오, 비디오, 이미지 등 다양한 형식 처리
- **간단한 통합**: 기존 시스템에 쉽게 통합 가능
- **리소스 제약**: 메모리나 처리 능력이 제한적인 환경

**장점:**
- 설치와 사용이 매우 간단
- 광범위한 파일 형식 지원
- 빠른 처리 속도
- 적은 메모리 사용량

**단점:**
- 복잡한 레이아웃 처리 제한
- 고급 구조 분석 기능 부족
- 엔터프라이즈 기능 제한

### Docling을 선택해야 하는 경우

**적합한 상황:**
- **고품질 변환**: 정확한 구조 보존이 중요한 경우
- **엔터프라이즈 환경**: 대용량 처리와 안정성이 필요한 경우
- **복잡한 문서**: 테이블, 차트 등 복잡한 레이아웃 처리
- **구조화된 출력**: JSON, XML 등 다양한 출력 형식 필요

**장점:**
- 높은 변환 품질
- 구조화된 출력 지원
- 엔터프라이즈급 안정성
- 고급 레이아웃 처리

**단점:**
- 상대적으로 복잡한 설정
- 높은 메모리 사용량
- 제한적인 파일 형식 지원

## 통합 사용 전략

### 하이브리드 접근법

```python
# 두 도구를 함께 사용하는 전략
from markitdown import MarkItDown
from docling.document_converter import DocumentConverter

class HybridDocumentConverter:
    def __init__(self):
        self.markitdown = MarkItDown()
        self.docling = DocumentConverter()
        
    def convert_document(self, file_path, quality='auto'):
        """파일 형식과 요구사항에 따라 적절한 도구 선택"""
        file_ext = Path(file_path).suffix.lower()
        
        if quality == 'fast' or file_ext in ['.mp3', '.wav', '.mp4', '.zip']:
            # 속도 우선 또는 MarkItDown 전용 형식
            return self.markitdown.convert(file_path).text_content
            
        elif quality == 'high' or file_ext in ['.pdf']:
            # 품질 우선 또는 복잡한 문서
            result = self.docling.convert(file_path)
            return result.document.export_to_markdown()
            
        else:
            # 자동 선택 (파일 크기 기준)
            file_size = Path(file_path).stat().st_size
            
            if file_size < 10 * 1024 * 1024:  # 10MB 미만
                return self.markitdown.convert(file_path).text_content
            else:
                result = self.docling.convert(file_path)
                return result.document.export_to_markdown()

# 사용 예시
converter = HybridDocumentConverter()

# 빠른 변환
quick_result = converter.convert_document("simple.pdf", quality='fast')

# 고품질 변환
high_quality_result = converter.convert_document("complex.pdf", quality='high')

# 자동 선택
auto_result = converter.convert_document("document.pdf", quality='auto')
```

## 운영 환경 배포 가이드

### Docker 컨테이너 배포

**MarkItDown 컨테이너:**
```dockerfile
# Dockerfile.markitdown
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    poppler-utils \
    tesseract-ocr \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["python", "app.py"]
```

**Docling 컨테이너:**
```dockerfile
# Dockerfile.docling
FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성 설치
RUN apt-get update && apt-get install -y \
    poppler-utils \
    tesseract-ocr \
    libreoffice \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

### Kubernetes 배포

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: document-converter
spec:
  replicas: 3
  selector:
    matchLabels:
      app: document-converter
  template:
    metadata:
      labels:
        app: document-converter
    spec:
      containers:
      - name: converter
        image: document-converter:latest
        ports:
        - containerPort: 8000
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "2Gi"
            cpu: "1000m"
        env:
        - name: CONVERTER_TYPE
          value: "markitdown"  # 또는 "docling"
---
apiVersion: v1
kind: Service
metadata:
  name: document-converter-service
spec:
  selector:
    app: document-converter
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

## 성능 최적화 팁

### MarkItDown 최적화

```python
# 메모리 효율적인 배치 처리
def optimized_batch_processing(file_list, batch_size=10):
    md = MarkItDown()
    
    for i in range(0, len(file_list), batch_size):
        batch = file_list[i:i + batch_size]
        
        for file_path in batch:
            try:
                result = md.convert(file_path)
                # 즉시 처리하고 메모리 해제
                process_result(result.text_content)
                del result
                
            except Exception as e:
                print(f"처리 실패: {file_path} - {e}")
        
        # 배치 간 가비지 컬렉션
        import gc
        gc.collect()
```

### Docling 최적화

```python
# 병렬 처리 최적화
from concurrent.futures import ThreadPoolExecutor
from docling.document_converter import DocumentConverter

def parallel_document_processing(file_list, max_workers=4):
    def process_single_file(file_path):
        converter = DocumentConverter()
        try:
            result = converter.convert(file_path)
            return {
                'file': file_path,
                'content': result.document.export_to_markdown(),
                'success': True
            }
        except Exception as e:
            return {
                'file': file_path,
                'error': str(e),
                'success': False
            }
    
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        results = list(executor.map(process_single_file, file_list))
    
    return results
```

## 결론

### 최종 권장사항

**MarkItDown 권장 시나리오:**
- 빠른 프로토타이핑과 개발
- 다양한 파일 형식 지원이 필요한 경우
- 리소스 제약이 있는 환경
- 간단한 텍스트 추출이 목적인 경우

**Docling 권장 시나리오:**
- 고품질 문서 변환이 필요한 경우
- 엔터프라이즈급 안정성과 성능이 필요한 경우
- 복잡한 문서 구조 처리가 중요한 경우
- 구조화된 출력 형식이 필요한 경우

### 미래 전망

두 도구 모두 지속적으로 발전하고 있으며, AI와 머신러닝 기술의 발전에 따라 더욱 정교한 문서 처리 기능이 추가될 것으로 예상됩니다.

### 시작하기 위한 단계

1. **요구사항 분석**: 처리할 문서 유형과 품질 요구사항 파악
2. **파일럿 테스트**: 실제 문서로 두 도구 모두 테스트
3. **성능 평가**: 처리 속도, 메모리 사용량, 결과 품질 비교
4. **점진적 도입**: 작은 규모부터 시작하여 단계적 확장
5. **지속적 모니터링**: 성능 지표 추적과 최적화

적절한 도구 선택과 최적화를 통해 효율적인 문서 처리 파이프라인을 구축할 수 있습니다.

---

**참고 자료:**
- [Microsoft MarkItDown GitHub](https://github.com/microsoft/markitdown)
- [IBM Docling 문서](https://github.com/DS4SD/docling)
- [문서 변환 최적화 가이드](https://thakicloud.github.io/tutorials/)
- [LLMOps 데이터 전처리 패턴](https://thakicloud.github.io/llmops/)

**관련 글:**
- [PDF 텍스트 변환 완벽 가이드](https://thakicloud.github.io/tutorials/pdf-text-conversion/)
- [LLM 데이터 전처리 파이프라인](https://thakicloud.github.io/llmops/data-preprocessing/)
- [문서 AI 처리 아키텍처](https://thakicloud.github.io/dev/document-ai-architecture/) 