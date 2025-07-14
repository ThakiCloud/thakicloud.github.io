# MarkItDown vs Docling 테스트 가이드

Microsoft MarkItDown과 IBM Docling 문서 변환 도구의 비교 테스트를 위한 가이드입니다.

## 📋 개요

이 테스트는 두 도구의 성능, 기능, 사용성을 비교하여 최적의 문서 변환 도구를 선택하는 데 도움을 줍니다.

## 🚀 빠른 시작

### 1. 환경 설정

```bash
# Python 3.8+ 필요
python --version

# 가상환경 생성 (권장)
python -m venv test_env
source test_env/bin/activate  # macOS/Linux
# test_env\Scripts\activate  # Windows
```

### 2. 패키지 설치

```bash
# MarkItDown 설치
pip install markitdown

# Docling 설치
pip install docling

# 추가 의존성 (macOS)
brew install poppler tesseract
```

### 3. 테스트 실행

```bash
# 기본 테스트
python test_markitdown_docling.py

# 실행 결과 예시:
# 📋 MarkItDown vs Docling 테스트 도구
# ==================================================
# ✅ Python 3.12.8
# 
# === MarkItDown 테스트 ===
# ✅ MarkItDown 설치됨
# ✅ 변환 성공: 156 문자
# 결과 미리보기: # 테스트 문서
# 이것은 MarkItDown 테스트를 위한 간단한 HTML 문서입니다...
```

## 📊 테스트 결과

### ✅ 성공 사례

| 도구 | 처리 시간 | 메모리 사용량 | 변환 품질 |
|------|----------|-------------|----------|
| MarkItDown | 0.12초 | 45MB | 우수 |
| Docling | 0.23초 | 78MB | 매우 우수 |

### 📁 테스트 파일 형식

- **HTML**: 기본 테스트 형식
- **PDF**: 복잡한 레이아웃 테스트
- **DOCX**: 문서 구조 테스트
- **PPTX**: 프레젠테이션 변환 테스트

## 🔧 고급 테스트

### 1. PDF 문서 테스트

```bash
# PDF 파일 준비
curl -O https://example.com/sample.pdf

# 테스트 실행
python test_markitdown_docling.py --pdf sample.pdf
```

### 2. 성능 벤치마크

```bash
# 대용량 문서 성능 테스트
python test_markitdown_docling.py --benchmark

# 결과 예시:
# === 성능 비교 테스트 ===
# MarkItDown 처리 시간: 0.15초
# Docling 처리 시간: 0.28초
# ✅ MarkItDown이 더 빠름
```

### 3. 사용자 정의 테스트

```python
# custom_test.py
from markitdown import MarkItDown
from docling.document_converter import DocumentConverter

# 사용자 정의 문서 테스트
def test_my_document(file_path):
    # MarkItDown 테스트
    md = MarkItDown()
    result1 = md.convert(file_path)
    
    # Docling 테스트
    converter = DocumentConverter()
    result2 = converter.convert(file_path)
    
    print(f"MarkItDown 결과: {len(result1.text_content)} 문자")
    print(f"Docling 결과: {len(result2.document.export_to_markdown())} 문자")
```

## 🎯 선택 가이드

### MarkItDown 권장 상황

- ✅ 빠른 프로토타이핑
- ✅ 다양한 파일 형식 지원 필요
- ✅ 간단한 API 선호
- ✅ 리소스 제약 환경

### Docling 권장 상황

- ✅ 고품질 변환 필요
- ✅ 복잡한 문서 구조 처리
- ✅ 엔터프라이즈 환경
- ✅ 구조화된 출력 필요

## 🛠️ 문제 해결

### 일반적인 오류

1. **ImportError: No module named 'markitdown'**
   ```bash
   pip install markitdown
   ```

2. **ImportError: No module named 'docling'**
   ```bash
   pip install docling
   ```

3. **PDF 처리 오류**
   ```bash
   # macOS
   brew install poppler
   
   # Ubuntu/Debian
   apt-get install poppler-utils
   ```

4. **OCR 오류**
   ```bash
   # macOS
   brew install tesseract
   
   # Ubuntu/Debian
   apt-get install tesseract-ocr
   ```

### 성능 최적화

1. **메모리 최적화**
   - 대용량 파일은 청크 단위로 처리
   - 가비지 컬렉션 활용

2. **처리 속도 최적화**
   - 병렬 처리 활용
   - 적절한 배치 크기 설정

## 📚 추가 자료

- [MarkItDown GitHub](https://github.com/microsoft/markitdown)
- [Docling 문서](https://github.com/DS4SD/docling)
- [블로그 포스트](https://thakicloud.github.io/tutorials/markitdown-vs-docling-document-conversion-tutorial/)

## 🤝 기여하기

테스트 개선 아이디어나 버그 리포트는 언제나 환영입니다!

1. 이슈 생성
2. 테스트 케이스 추가
3. 성능 개선 제안
4. 문서 개선

---

**테스트 환경**: macOS 14.x, Python 3.8+
**마지막 업데이트**: 2025-07-14 