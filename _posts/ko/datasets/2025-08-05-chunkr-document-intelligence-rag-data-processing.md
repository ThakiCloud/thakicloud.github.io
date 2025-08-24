---
title: "Chunkr: RAG/LLM을 위한 지능형 문서 데이터 처리 플랫폼"
excerpt: "복잡한 PDF, PPT, Word 문서를 레이아웃 분석, OCR, 시맨틱 청킹을 통해 RAG 시스템에 최적화된 구조화 데이터로 변환하는 오픈소스 문서 지능형 API 플랫폼"
seo_title: "Chunkr 문서 지능형 데이터 처리 플랫폼 완전 가이드 - Thaki Cloud"
seo_description: "Chunkr의 레이아웃 분석, OCR, 시맨틱 청킹을 활용한 문서 데이터 처리 방법. PDF, PPT, Word 문서를 RAG/LLM 친화적 구조화 데이터로 변환하는 실전 가이드"
date: 2025-08-05
last_modified_at: 2025-08-05
categories:
  - datasets
tags:
  - chunkr
  - document-intelligence
  - rag-data
  - ocr
  - layout-analysis
  - semantic-chunking
  - llm-data
  - data-processing
  - pdf-extraction
  - document-ai
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/datasets/chunkr-document-intelligence-rag-data-processing/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 18분

## 서론

현대 AI 시스템에서 **RAG(Retrieval-Augmented Generation)**와 **LLM 기반 응용프로그램**의 성능은 입력 데이터의 품질에 크게 의존합니다. 특히 PDF, PowerPoint, Word 문서와 같은 **복잡한 구조의 문서**에서 의미 있는 정보를 추출하고 적절히 청킹(chunking)하는 것은 여전히 큰 도전 과제입니다.

기존의 단순한 텍스트 추출 방식으로는 **문서의 레이아웃, 표, 이미지, 그래프** 등의 구조적 정보가 손실되어 LLM이 문맥을 제대로 이해하지 못하는 경우가 많았습니다. 이러한 문제를 해결하기 위해 등장한 [Chunkr](https://github.com/lumina-ai-inc/chunkr)은 **비전 기반 문서 지능형 API 플랫폼**으로, 문서의 구조와 의미를 정확히 파악하여 RAG 시스템에 최적화된 데이터를 생성합니다.

이번 글에서는 Chunkr의 핵심 기능, 실제 구현 방법, 그리고 다양한 문서 형식에서 고품질 데이터를 추출하는 실전 가이드를 상세히 다루겠습니다.

## Chunkr 핵심 혁신 기술

### 1. 고급 레이아웃 분석

**레이아웃 분석**은 Chunkr의 가장 강력한 기능 중 하나로, 문서의 구조적 요소를 정확히 식별하고 분류합니다.

#### 지원 레이아웃 요소
- **텍스트 블록**: 제목, 본문, 캡션 구분
- **표 구조**: 행/열 관계 유지한 데이터 추출
- **이미지 및 그래프**: 위치와 캡션 관계 파악
- **목록 구조**: 순서/비순서 목록의 계층 구조
- **다단 레이아웃**: 신문/잡지 스타일 다단 문서 처리

#### 레이아웃 분석 예제
```python
# 레이아웃 분석 결과 구조
layout_elements = {
    "headers": [
        {"text": "Chapter 1: Introduction", "level": 1, "bbox": [50, 100, 500, 130]},
        {"text": "1.1 Overview", "level": 2, "bbox": [50, 150, 300, 180]}
    ],
    "paragraphs": [
        {"text": "This document explains...", "bbox": [50, 200, 500, 280]}
    ],
    "tables": [
        {
            "bbox": [50, 300, 500, 450],
            "rows": 5,
            "columns": 3,
            "data": [["Name", "Age", "City"], ["John", "25", "Seoul"]]
        }
    ],
    "images": [
        {"bbox": [50, 500, 300, 700], "caption": "Figure 1: System Architecture"}
    ]
}
```

### 2. 정밀한 OCR 및 바운딩 박스

**OCR(Optical Character Recognition)** 기능은 단순한 텍스트 추출을 넘어서 **문자의 정확한 위치 정보**까지 제공합니다.

#### OCR 특징
- **높은 정확도**: 최신 비전 모델 기반 텍스트 인식
- **다국어 지원**: 한국어, 영어, 중국어, 일본어 등
- **바운딩 박스**: 각 텍스트의 정확한 좌표 정보
- **폰트 정보**: 크기, 스타일, 색상 등 메타데이터
- **회전 텍스트**: 기울어진 텍스트도 정확히 인식

### 3. 시맨틱 청킹 (Semantic Chunking)

**시맨틱 청킹**은 단순한 문자 수나 단어 수 기반이 아닌, **의미적 연관성**을 고려한 지능형 분할 방식입니다.

#### 청킹 전략
```python
# 시맨틱 청킹 설정 예제
chunking_config = {
    "strategy": "semantic",
    "max_chunk_size": 1000,  # 최대 토큰 수
    "overlap": 200,          # 청크 간 겹침
    "preserve_structure": True,  # 구조 보존
    "semantic_threshold": 0.7,   # 의미적 유사도 임계값
    "respect_boundaries": [
        "paragraph", "section", "table", "list"
    ]
}
```

## 설치 및 기본 환경 구성

### 1. 클라우드 API 방식

가장 간단한 시작 방법은 [chunkr.ai](https://chunkr.ai)의 클라우드 서비스를 이용하는 것입니다.

```python
# Python SDK 설치
pip install chunkr-ai

# 기본 사용법
from chunkr_ai import Chunkr

# API 키로 초기화
chunkr = Chunkr(api_key="your_api_key_from_chunkr_ai")

# 문서 업로드 및 처리
url = "https://example.com/document.pdf"
task = chunkr.upload(url)

# 다양한 형식으로 결과 추출
html = task.html(output_file="output.html")
markdown = task.markdown(output_file="output.md")
content = task.content(output_file="output.txt")
json_data = task.json(output_file="output.json")

# 리소스 정리
chunkr.close()
```

### 2. Docker 기반 셀프 호스팅

프라이버시나 커스터마이징이 중요한 경우 셀프 호스팅 방식을 선택할 수 있습니다.

```bash
# 프로젝트 클론
git clone https://github.com/lumina-ai-inc/chunkr
cd chunkr

# 환경 설정
cp .env.example .env
cp models.example.yaml models.yaml

# GPU 환경에서 실행
docker compose up -d

# CPU 전용 환경에서 실행
docker compose -f compose.yaml -f compose.cpu.yaml up -d

# macOS ARM (M1/M2/M3) 환경
docker compose -f compose.yaml -f compose.cpu.yaml -f compose.mac.yaml up -d
```

### 3. 환경별 접근 주소

```bash
# 서비스 접속 주소
Web UI: http://localhost:5173
API: http://localhost:8000
API Documentation: http://localhost:8000/docs
Health Check: http://localhost:8000/health
```

## 고급 문서 처리 기능

### 1. 다양한 문서 형식 지원

Chunkr은 광범위한 문서 형식을 지원하며, 각 형식에 최적화된 처리 방식을 제공합니다.

```python
# 지원 문서 형식별 처리 예제
from chunkr_ai import Chunkr

class DocumentProcessor:
    def __init__(self, api_key):
        self.chunkr = Chunkr(api_key=api_key)
    
    def process_document(self, file_path, doc_type="auto"):
        """문서 형식별 최적화 처리"""
        
        # 문서 형식별 설정
        processing_configs = {
            "pdf": {
                "ocr_strategy": "auto",  # 텍스트/스캔 문서 자동 감지
                "preserve_layout": True,
                "extract_images": True,
                "table_detection": True
            },
            "pptx": {
                "slide_separation": True,  # 슬라이드별 분리
                "preserve_animations": False,
                "extract_speaker_notes": True,
                "image_extraction": True
            },
            "docx": {
                "preserve_styles": True,   # 스타일 정보 보존
                "extract_headers_footers": True,
                "table_structure": True,
                "comment_extraction": False
            },
            "xlsx": {
                "sheet_separation": True,  # 시트별 분리
                "preserve_formulas": True,
                "data_validation": True,
                "chart_extraction": True
            }
        }
        
        # 문서 업로드 및 처리
        task = self.chunkr.upload(
            file_path,
            config=processing_configs.get(doc_type, {})
        )
        
        return task
    
    def extract_structured_data(self, task):
        """구조화된 데이터 추출"""
        
        # JSON 형태로 상세 구조 정보 획득
        json_result = task.json()
        
        # 구조별 데이터 분리
        structured_data = {
            "metadata": json_result.get("metadata", {}),
            "pages": [],
            "tables": [],
            "images": [],
            "text_blocks": []
        }
        
        for page in json_result.get("pages", []):
            page_data = {
                "page_number": page.get("page_number"),
                "dimensions": page.get("dimensions"),
                "elements": []
            }
            
            # 페이지 내 요소들 분류
            for element in page.get("elements", []):
                element_type = element.get("type")
                
                if element_type == "table":
                    structured_data["tables"].append({
                        "page": page.get("page_number"),
                        "bbox": element.get("bbox"),
                        "data": element.get("data"),
                        "headers": element.get("headers")
                    })
                
                elif element_type == "image":
                    structured_data["images"].append({
                        "page": page.get("page_number"),
                        "bbox": element.get("bbox"),
                        "caption": element.get("caption"),
                        "alt_text": element.get("alt_text")
                    })
                
                elif element_type in ["paragraph", "header", "footer"]:
                    structured_data["text_blocks"].append({
                        "page": page.get("page_number"),
                        "type": element_type,
                        "text": element.get("text"),
                        "bbox": element.get("bbox"),
                        "style": element.get("style", {})
                    })
                
                page_data["elements"].append(element)
            
            structured_data["pages"].append(page_data)
        
        return structured_data

# 사용 예제
processor = DocumentProcessor("your_api_key")

# PDF 문서 처리
pdf_task = processor.process_document("report.pdf", "pdf")
pdf_data = processor.extract_structured_data(pdf_task)

# PowerPoint 문서 처리
ppt_task = processor.process_document("presentation.pptx", "pptx")
ppt_data = processor.extract_structured_data(ppt_task)
```

### 2. RAG 최적화 청킹 전략

RAG 시스템의 성능을 최대화하기 위한 고급 청킹 전략을 구현할 수 있습니다.

```python
# RAG 최적화 청킹 구현
class RAGOptimizedChunker:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
    
    def create_rag_chunks(self, task, chunk_strategy="adaptive"):
        """RAG 시스템에 최적화된 청크 생성"""
        
        # 구조화된 데이터 추출
        structured_data = task.json()
        
        chunks = []
        
        if chunk_strategy == "adaptive":
            chunks = self._adaptive_chunking(structured_data)
        elif chunk_strategy == "semantic":
            chunks = self._semantic_chunking(structured_data)
        elif chunk_strategy == "hierarchical":
            chunks = self._hierarchical_chunking(structured_data)
        
        return chunks
    
    def _adaptive_chunking(self, data):
        """적응형 청킹: 콘텐츠 유형에 따라 동적 조정"""
        
        chunks = []
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                element_type = element.get("type")
                
                if element_type == "table":
                    # 표는 통째로 하나의 청크
                    chunks.append({
                        "type": "table",
                        "content": self._format_table(element),
                        "metadata": {
                            "page": page.get("page_number"),
                            "bbox": element.get("bbox"),
                            "element_type": "table"
                        }
                    })
                
                elif element_type == "header":
                    # 헤더와 다음 문단들을 함께 청킹
                    header_chunk = self._create_header_chunk(element, page)
                    chunks.append(header_chunk)
                
                elif element_type == "paragraph":
                    # 문단 길이에 따라 분할 또는 병합
                    para_chunks = self._split_paragraph(element)
                    chunks.extend(para_chunks)
        
        return chunks
    
    def _semantic_chunking(self, data):
        """의미적 청킹: 주제별 그룹핑"""
        
        # 전체 텍스트 추출
        full_text = self._extract_full_text(data)
        
        # 임베딩 기반 의미적 유사도 계산
        semantic_chunks = self._compute_semantic_boundaries(full_text)
        
        return semantic_chunks
    
    def _hierarchical_chunking(self, data):
        """계층적 청킹: 문서 구조 기반"""
        
        chunks = []
        current_section = None
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") == "header":
                    level = element.get("style", {}).get("level", 1)
                    
                    if level == 1:
                        # 새로운 섹션 시작
                        if current_section:
                            chunks.append(current_section)
                        
                        current_section = {
                            "type": "section",
                            "title": element.get("text"),
                            "content": [],
                            "subsections": []
                        }
                    
                    elif level == 2 and current_section:
                        # 서브섹션 추가
                        current_section["subsections"].append({
                            "title": element.get("text"),
                            "content": []
                        })
                
                else:
                    # 현재 섹션에 콘텐츠 추가
                    if current_section:
                        if current_section["subsections"]:
                            current_section["subsections"][-1]["content"].append(element)
                        else:
                            current_section["content"].append(element)
        
        # 마지막 섹션 추가
        if current_section:
            chunks.append(current_section)
        
        return chunks
    
    def _format_table(self, table_element):
        """표 데이터를 RAG 친화적 형식으로 변환"""
        
        data = table_element.get("data", [])
        if not data:
            return ""
        
        # 헤더와 데이터 분리
        headers = data[0] if data else []
        rows = data[1:] if len(data) > 1 else []
        
        # 마크다운 표 형식으로 변환
        markdown_table = "| " + " | ".join(headers) + " |\n"
        markdown_table += "| " + " | ".join(["---"] * len(headers)) + " |\n"
        
        for row in rows:
            markdown_table += "| " + " | ".join(str(cell) for cell in row) + " |\n"
        
        return markdown_table
    
    def optimize_for_retrieval(self, chunks, max_tokens=500):
        """검색 최적화를 위한 청크 후처리"""
        
        optimized_chunks = []
        
        for chunk in chunks:
            # 토큰 수 확인 및 조정
            if self._count_tokens(chunk.get("content", "")) > max_tokens:
                # 큰 청크를 분할
                sub_chunks = self._split_large_chunk(chunk, max_tokens)
                optimized_chunks.extend(sub_chunks)
            else:
                optimized_chunks.append(chunk)
        
        # 메타데이터 강화
        for i, chunk in enumerate(optimized_chunks):
            chunk["metadata"]["chunk_id"] = i
            chunk["metadata"]["total_chunks"] = len(optimized_chunks)
            
            # 검색 키워드 추출
            chunk["metadata"]["keywords"] = self._extract_keywords(
                chunk.get("content", "")
            )
        
        return optimized_chunks

# 사용 예제
chunker = RAGOptimizedChunker(chunkr)

# 문서 처리 및 RAG 최적화 청킹
task = chunkr.upload("complex_document.pdf")
rag_chunks = chunker.create_rag_chunks(task, "adaptive")

# 검색 최적화
optimized_chunks = chunker.optimize_for_retrieval(rag_chunks, max_tokens=400)
```

## LLM 통합 및 설정

### 1. 다양한 LLM 프로바이더 설정

Chunkr은 다양한 LLM 프로바이더와 통합하여 문서 처리 과정에서 AI 기능을 활용할 수 있습니다.

```yaml
# models.yaml 설정 파일
models:
  # OpenAI GPT 모델
  - id: gpt-4o
    model: gpt-4o
    provider_url: https://api.openai.com/v1/chat/completions
    api_key: "your_openai_api_key"
    default: true
    rate-limit: 200  # requests per minute
    
  # Google Gemini 모델
  - id: gemini-pro
    model: gemini-1.5-pro
    provider_url: https://generativelanguage.googleapis.com/v1beta/openai/chat/completions
    api_key: "your_google_api_key"
    rate-limit: 100
    
  # Anthropic Claude 모델
  - id: claude-3-sonnet
    model: claude-3-5-sonnet-20241022
    provider_url: https://api.anthropic.com/v1/messages
    api_key: "your_anthropic_api_key"
    rate-limit: 50
    
  # 로컬 모델 (vLLM 또는 Ollama)
  - id: local-llama
    model: llama-3.1-8b-instruct
    provider_url: http://localhost:8000/v1/chat/completions
    api_key: "not_required"
    rate-limit: 1000
    
  # OpenRouter (다양한 모델 접근)
  - id: openrouter-mixtral
    model: mistralai/mixtral-8x7b-instruct
    provider_url: https://openrouter.ai/api/v1/chat/completions
    api_key: "your_openrouter_api_key"
    rate-limit: 150

# 환경별 설정
environments:
  development:
    default_model: local-llama
    fallback_model: gpt-4o
  
  production:
    default_model: gpt-4o
    fallback_model: gemini-pro
```

### 2. LLM 기반 고급 문서 분석

```python
# LLM 통합 문서 분석 클래스
class LLMEnhancedDocumentAnalyzer:
    def __init__(self, chunkr_instance, llm_config):
        self.chunkr = chunkr_instance
        self.llm_config = llm_config
    
    def analyze_document_content(self, task):
        """LLM을 활용한 문서 내용 분석"""
        
        # 기본 구조화 데이터 추출
        structured_data = task.json()
        
        # LLM 분석 결과
        analysis = {
            "summary": self._generate_summary(structured_data),
            "key_topics": self._extract_topics(structured_data),
            "entities": self._extract_entities(structured_data),
            "sentiment": self._analyze_sentiment(structured_data),
            "document_type": self._classify_document(structured_data),
            "quality_score": self._assess_quality(structured_data)
        }
        
        return analysis
    
    def _generate_summary(self, data):
        """문서 요약 생성"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        다음 문서의 핵심 내용을 3-4문장으로 요약해주세요:
        
        {full_text[:2000]}...
        
        요약:
        """
        
        return self._call_llm(prompt, model="gpt-4o")
    
    def _extract_topics(self, data):
        """주요 주제 추출"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        다음 문서에서 주요 주제들을 추출하여 리스트로 제시해주세요:
        
        {full_text[:1500]}...
        
        주요 주제 (5개 이내):
        """
        
        response = self._call_llm(prompt, model="gemini-pro")
        return self._parse_topics(response)
    
    def _extract_entities(self, data):
        """개체명 인식"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        다음 텍스트에서 중요한 개체명을 추출해주세요:
        - 인명 (PERSON)
        - 조직명 (ORGANIZATION)  
        - 지명 (LOCATION)
        - 날짜 (DATE)
        - 기술/제품명 (TECHNOLOGY)
        
        텍스트:
        {full_text[:1000]}...
        
        JSON 형식으로 응답:
        """
        
        response = self._call_llm(prompt, model="claude-3-sonnet")
        return self._parse_entities(response)
    
    def _assess_quality(self, data):
        """문서 품질 평가"""
        
        metrics = {
            "text_clarity": 0.0,      # 텍스트 명확성
            "structure_quality": 0.0,  # 구조적 완성도
            "content_depth": 0.0,      # 내용 깊이
            "readability": 0.0,        # 가독성
            "completeness": 0.0        # 완전성
        }
        
        # OCR 정확도 기반 품질 평가
        ocr_confidence = self._calculate_ocr_confidence(data)
        
        # 구조적 요소 평가
        structure_score = self._evaluate_structure(data)
        
        # LLM 기반 내용 품질 평가
        content_score = self._evaluate_content_quality(data)
        
        overall_score = (ocr_confidence + structure_score + content_score) / 3
        
        return {
            "overall_score": overall_score,
            "metrics": metrics,
            "recommendations": self._get_quality_recommendations(overall_score)
        }
    
    def _call_llm(self, prompt, model="gpt-4o"):
        """LLM API 호출"""
        import requests
        
        model_config = next(
            (m for m in self.llm_config["models"] if m["id"] == model), 
            None
        )
        
        if not model_config:
            raise ValueError(f"Model {model} not found in configuration")
        
        headers = {
            "Authorization": f"Bearer {model_config['api_key']}",
            "Content-Type": "application/json"
        }
        
        payload = {
            "model": model_config["model"],
            "messages": [
                {"role": "user", "content": prompt}
            ],
            "max_tokens": 500,
            "temperature": 0.1
        }
        
        response = requests.post(
            model_config["provider_url"],
            headers=headers,
            json=payload
        )
        
        if response.status_code == 200:
            return response.json()["choices"][0]["message"]["content"]
        else:
            raise Exception(f"LLM API call failed: {response.text}")

# 사용 예제
llm_config = {
    "models": [
        {
            "id": "gpt-4o",
            "model": "gpt-4o",
            "provider_url": "https://api.openai.com/v1/chat/completions",
            "api_key": "your_openai_api_key"
        }
    ]
}

analyzer = LLMEnhancedDocumentAnalyzer(chunkr, llm_config)

# 문서 분석 실행
task = chunkr.upload("research_paper.pdf")
analysis = analyzer.analyze_document_content(task)

print(f"문서 요약: {analysis['summary']}")
print(f"주요 주제: {analysis['key_topics']}")
print(f"품질 점수: {analysis['quality_score']['overall_score']:.2f}")
```

## 실제 사용 사례 및 구현

### 1. 학술 논문 처리 파이프라인

```python
# 학술 논문 전용 처리 파이프라인
class AcademicPaperProcessor:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
    
    def process_research_paper(self, paper_path):
        """학술 논문 전문 처리"""
        
        # 문서 처리
        task = self.chunkr.upload(paper_path)
        structured_data = task.json()
        
        # 논문 구조 분석
        paper_structure = self._analyze_paper_structure(structured_data)
        
        # 섹션별 처리
        processed_sections = {}
        
        for section_name, section_data in paper_structure.items():
            if section_name == "abstract":
                processed_sections[section_name] = self._process_abstract(section_data)
            elif section_name == "introduction":
                processed_sections[section_name] = self._process_introduction(section_data)
            elif section_name == "methodology":
                processed_sections[section_name] = self._process_methodology(section_data)
            elif section_name == "results":
                processed_sections[section_name] = self._process_results(section_data)
            elif section_name == "discussion":
                processed_sections[section_name] = self._process_discussion(section_data)
            elif section_name == "references":
                processed_sections[section_name] = self._process_references(section_data)
        
        # 메타데이터 추출
        metadata = self._extract_paper_metadata(structured_data)
        
        return {
            "metadata": metadata,
            "sections": processed_sections,
            "figures": self._extract_figures(structured_data),
            "tables": self._extract_tables(structured_data),
            "equations": self._extract_equations(structured_data),
            "citations": self._extract_citations(structured_data)
        }
    
    def _analyze_paper_structure(self, data):
        """논문 구조 자동 인식"""
        
        sections = {}
        current_section = None
        
        section_keywords = {
            "abstract": ["abstract", "요약"],
            "introduction": ["introduction", "서론", "1. introduction"],
            "methodology": ["methodology", "method", "방법론", "실험방법"],
            "results": ["results", "result", "결과", "실험결과"],
            "discussion": ["discussion", "토론", "논의"],
            "conclusion": ["conclusion", "결론"],
            "references": ["references", "참고문헌", "bibliography"]
        }
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") == "header":
                    header_text = element.get("text", "").lower()
                    
                    for section_type, keywords in section_keywords.items():
                        if any(keyword in header_text for keyword in keywords):
                            current_section = section_type
                            if current_section not in sections:
                                sections[current_section] = []
                            break
                
                elif current_section and element.get("type") in ["paragraph", "table", "image"]:
                    sections[current_section].append(element)
        
        return sections
    
    def _extract_paper_metadata(self, data):
        """논문 메타데이터 추출"""
        
        # 첫 페이지에서 메타데이터 추출
        first_page = data.get("pages", [{}])[0]
        elements = first_page.get("elements", [])
        
        metadata = {
            "title": "",
            "authors": [],
            "affiliations": [],
            "keywords": [],
            "doi": "",
            "publication_date": "",
            "journal": "",
            "abstract": ""
        }
        
        # 제목 추출 (보통 첫 번째 큰 폰트 텍스트)
        for element in elements[:5]:  # 첫 5개 요소에서 찾기
            if element.get("type") == "header":
                style = element.get("style", {})
                if style.get("font_size", 0) > 16:
                    metadata["title"] = element.get("text", "")
                    break
        
        # 저자 정보 추출 (제목 다음 요소에서)
        # 이메일 패턴이나 대학 이름 패턴으로 식별
        
        return metadata

# 사용 예제
processor = AcademicPaperProcessor(chunkr)
paper_data = processor.process_research_paper("research_paper.pdf")

print(f"논문 제목: {paper_data['metadata']['title']}")
print(f"섹션 수: {len(paper_data['sections'])}")
print(f"그림 수: {len(paper_data['figures'])}")
print(f"표 수: {len(paper_data['tables'])}")
```

### 2. 기업 문서 자동 분류 시스템

```python
# 기업 문서 자동 분류 및 처리
class CorporateDocumentClassifier:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
        self.document_types = {
            "contract": ["계약서", "계약", "agreement", "contract"],
            "report": ["보고서", "report", "analysis", "분석"],
            "manual": ["매뉴얼", "manual", "guide", "가이드"],
            "presentation": ["발표", "presentation", "slide"],
            "financial": ["재무", "financial", "budget", "예산"],
            "hr": ["인사", "hr", "human resource", "채용"],
            "legal": ["법무", "legal", "compliance", "규정"]
        }
    
    def classify_and_process(self, document_path):
        """문서 분류 및 타입별 처리"""
        
        # 기본 문서 처리
        task = self.chunkr.upload(document_path)
        structured_data = task.json()
        
        # 문서 타입 분류
        doc_type = self._classify_document_type(structured_data)
        
        # 타입별 특화 처리
        if doc_type == "contract":
            return self._process_contract(structured_data)
        elif doc_type == "report":
            return self._process_report(structured_data)
        elif doc_type == "financial":
            return self._process_financial_document(structured_data)
        else:
            return self._process_generic_document(structured_data)
    
    def _classify_document_type(self, data):
        """문서 타입 자동 분류"""
        
        # 전체 텍스트 추출
        full_text = ""
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") in ["paragraph", "header"]:
                    full_text += element.get("text", "") + " "
        
        full_text = full_text.lower()
        
        # 키워드 매칭을 통한 분류
        type_scores = {}
        
        for doc_type, keywords in self.document_types.items():
            score = sum(1 for keyword in keywords if keyword in full_text)
            type_scores[doc_type] = score
        
        # 가장 높은 점수의 타입 반환
        return max(type_scores, key=type_scores.get) if type_scores else "generic"
    
    def _process_contract(self, data):
        """계약서 특화 처리"""
        
        contract_data = {
            "parties": self._extract_contract_parties(data),
            "terms": self._extract_contract_terms(data),
            "dates": self._extract_important_dates(data),
            "amounts": self._extract_monetary_amounts(data),
            "signatures": self._detect_signature_areas(data),
            "clauses": self._extract_clauses(data)
        }
        
        return contract_data
    
    def _process_financial_document(self, data):
        """재무 문서 특화 처리"""
        
        financial_data = {
            "financial_tables": self._extract_financial_tables(data),
            "key_metrics": self._extract_financial_metrics(data),
            "charts": self._extract_financial_charts(data),
            "currency_amounts": self._extract_currency_amounts(data),
            "accounting_periods": self._extract_accounting_periods(data)
        }
        
        return financial_data
    
    def _extract_financial_tables(self, data):
        """재무 표 추출 및 분석"""
        
        financial_tables = []
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") == "table":
                    table_data = element.get("data", [])
                    
                    # 재무 관련 테이블인지 확인
                    if self._is_financial_table(table_data):
                        processed_table = {
                            "raw_data": table_data,
                            "headers": table_data[0] if table_data else [],
                            "rows": table_data[1:] if len(table_data) > 1 else [],
                            "page": page.get("page_number"),
                            "bbox": element.get("bbox"),
                            "financial_metrics": self._parse_financial_metrics(table_data)
                        }
                        financial_tables.append(processed_table)
        
        return financial_tables
    
    def _is_financial_table(self, table_data):
        """재무 테이블 여부 판단"""
        
        if not table_data:
            return False
        
        # 헤더에서 재무 관련 키워드 찾기
        headers = table_data[0] if table_data else []
        financial_keywords = [
            "revenue", "매출", "profit", "이익", "cost", "비용",
            "asset", "자산", "liability", "부채", "equity", "자본",
            "cash", "현금", "investment", "투자", "expense", "지출"
        ]
        
        header_text = " ".join(str(header).lower() for header in headers)
        
        return any(keyword in header_text for keyword in financial_keywords)

# 사용 예제
classifier = CorporateDocumentClassifier(chunkr)

# 다양한 문서 처리
documents = [
    "sales_contract.pdf",
    "quarterly_report.pdf", 
    "user_manual.pdf",
    "budget_proposal.xlsx"
]

for doc in documents:
    result = classifier.classify_and_process(doc)
    print(f"{doc}: {type(result).__name__}")
```

### 3. 다국어 문서 처리

```python
# 다국어 문서 처리 시스템
class MultilingualDocumentProcessor:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
        self.supported_languages = {
            "ko": "Korean",
            "en": "English", 
            "ja": "Japanese",
            "zh": "Chinese",
            "de": "German",
            "fr": "French",
            "es": "Spanish"
        }
    
    def process_multilingual_document(self, document_path):
        """다국어 문서 처리"""
        
        # 기본 문서 처리
        task = self.chunkr.upload(document_path)
        structured_data = task.json()
        
        # 언어 감지 및 분석
        language_analysis = self._analyze_languages(structured_data)
        
        # 언어별 텍스트 분리
        language_segments = self._segment_by_language(structured_data, language_analysis)
        
        # 번역 처리 (필요한 경우)
        translated_content = self._translate_content(language_segments)
        
        return {
            "original_data": structured_data,
            "language_analysis": language_analysis,
            "language_segments": language_segments,
            "translations": translated_content,
            "unified_content": self._create_unified_content(language_segments, translated_content)
        }
    
    def _analyze_languages(self, data):
        """문서 내 언어 분석"""
        
        from langdetect import detect, detect_langs
        
        language_stats = {}
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") in ["paragraph", "header"]:
                    text = element.get("text", "")
                    
                    if len(text.strip()) > 20:  # 충분한 길이의 텍스트만 분석
                        try:
                            detected_langs = detect_langs(text)
                            for lang_info in detected_langs:
                                lang_code = lang_info.lang
                                confidence = lang_info.prob
                                
                                if lang_code not in language_stats:
                                    language_stats[lang_code] = {
                                        "count": 0,
                                        "total_confidence": 0,
                                        "text_samples": []
                                    }
                                
                                language_stats[lang_code]["count"] += 1
                                language_stats[lang_code]["total_confidence"] += confidence
                                language_stats[lang_code]["text_samples"].append(text[:100])
                        
                        except:
                            continue  # 언어 감지 실패 시 건너뛰기
        
        # 평균 신뢰도 계산
        for lang in language_stats:
            count = language_stats[lang]["count"]
            if count > 0:
                language_stats[lang]["avg_confidence"] = (
                    language_stats[lang]["total_confidence"] / count
                )
        
        return language_stats
    
    def _segment_by_language(self, data, language_analysis):
        """언어별 텍스트 세그먼트 분리"""
        
        from langdetect import detect
        
        segments = {}
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") in ["paragraph", "header"]:
                    text = element.get("text", "")
                    
                    if len(text.strip()) > 10:
                        try:
                            detected_lang = detect(text)
                            
                            if detected_lang not in segments:
                                segments[detected_lang] = []
                            
                            segments[detected_lang].append({
                                "text": text,
                                "page": page.get("page_number"),
                                "bbox": element.get("bbox"),
                                "element_type": element.get("type")
                            })
                        
                        except:
                            # 감지 실패 시 기본 언어로 분류
                            default_lang = max(language_analysis.keys(), 
                                             key=lambda x: language_analysis[x]["count"])
                            
                            if default_lang not in segments:
                                segments[default_lang] = []
                            
                            segments[default_lang].append({
                                "text": text,
                                "page": page.get("page_number"),
                                "bbox": element.get("bbox"),
                                "element_type": element.get("type")
                            })
        
        return segments
    
    def _translate_content(self, language_segments, target_lang="en"):
        """다국어 콘텐츠 번역"""
        
        # 여기서는 간단한 예제로 구글 번역 API 사용
        # 실제로는 DeepL, Azure Translator, 또는 로컬 번역 모델 사용 가능
        
        translated_content = {}
        
        for source_lang, segments in language_segments.items():
            if source_lang != target_lang:
                translated_segments = []
                
                for segment in segments:
                    # 번역 API 호출 (예제)
                    translated_text = self._call_translation_api(
                        segment["text"], 
                        source_lang, 
                        target_lang
                    )
                    
                    translated_segment = segment.copy()
                    translated_segment["translated_text"] = translated_text
                    translated_segment["source_language"] = source_lang
                    translated_segment["target_language"] = target_lang
                    
                    translated_segments.append(translated_segment)
                
                translated_content[f"{source_lang}_to_{target_lang}"] = translated_segments
        
        return translated_content
    
    def _call_translation_api(self, text, source_lang, target_lang):
        """번역 API 호출 (예제)"""
        
        # 실제 구현에서는 선택한 번역 서비스의 API 사용
        # 여기서는 간단한 플레이스홀더
        
        return f"[TRANSLATED from {source_lang} to {target_lang}] {text}"

# 사용 예제
multilingual_processor = MultilingualDocumentProcessor(chunkr)

# 다국어 문서 처리
result = multilingual_processor.process_multilingual_document("multilingual_report.pdf")

print("감지된 언어:")
for lang, stats in result["language_analysis"].items():
    print(f"  {lang}: {stats['count']}개 세그먼트 (평균 신뢰도: {stats['avg_confidence']:.2f})")

print(f"\n번역된 콘텐츠: {len(result['translations'])}개 언어 쌍")
```

## 성능 최적화 및 스케일링

### 1. 대용량 문서 배치 처리

```python
# 대용량 문서 배치 처리 시스템
import asyncio
import aiohttp
from concurrent.futures import ThreadPoolExecutor
import time

class BatchDocumentProcessor:
    def __init__(self, chunkr_instance, max_workers=5):
        self.chunkr = chunkr_instance
        self.max_workers = max_workers
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
    
    async def process_documents_batch(self, document_paths):
        """비동기 배치 문서 처리"""
        
        # 작업 큐 생성
        tasks = []
        
        for doc_path in document_paths:
            task = asyncio.create_task(
                self._process_single_document_async(doc_path)
            )
            tasks.append(task)
        
        # 모든 작업 완료 대기
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # 결과 정리
        processed_results = []
        failed_documents = []
        
        for i, result in enumerate(results):
            if isinstance(result, Exception):
                failed_documents.append({
                    "document": document_paths[i],
                    "error": str(result)
                })
            else:
                processed_results.append({
                    "document": document_paths[i],
                    "result": result
                })
        
        return {
            "successful": processed_results,
            "failed": failed_documents,
            "total_processed": len(processed_results),
            "total_failed": len(failed_documents)
        }
    
    async def _process_single_document_async(self, doc_path):
        """단일 문서 비동기 처리"""
        
        loop = asyncio.get_event_loop()
        
        # CPU 집약적 작업을 별도 스레드에서 실행
        result = await loop.run_in_executor(
            self.executor,
            self._process_document_sync,
            doc_path
        )
        
        return result
    
    def _process_document_sync(self, doc_path):
        """동기적 문서 처리"""
        
        try:
            # 문서 처리
            task = self.chunkr.upload(doc_path)
            
            # 다양한 형식으로 결과 생성
            result = {
                "html": task.html(),
                "markdown": task.markdown(),
                "json": task.json(),
                "processing_time": time.time(),
                "file_size": self._get_file_size(doc_path)
            }
            
            return result
            
        except Exception as e:
            raise Exception(f"Failed to process {doc_path}: {str(e)}")
    
    def _get_file_size(self, file_path):
        """파일 크기 계산"""
        import os
        return os.path.getsize(file_path) if os.path.exists(file_path) else 0
    
    def process_with_priority_queue(self, documents_with_priority):
        """우선순위 기반 문서 처리"""
        
        import heapq
        
        # 우선순위 큐 생성 (낮은 숫자 = 높은 우선순위)
        priority_queue = []
        
        for priority, doc_path in documents_with_priority:
            heapq.heappush(priority_queue, (priority, doc_path))
        
        results = []
        
        while priority_queue:
            priority, doc_path = heapq.heappop(priority_queue)
            
            try:
                print(f"Processing priority {priority}: {doc_path}")
                result = self._process_document_sync(doc_path)
                results.append({
                    "priority": priority,
                    "document": doc_path,
                    "result": result,
                    "status": "success"
                })
                
            except Exception as e:
                results.append({
                    "priority": priority,
                    "document": doc_path,
                    "error": str(e),
                    "status": "failed"
                })
        
        return results

# 사용 예제
batch_processor = BatchDocumentProcessor(chunkr, max_workers=3)

# 비동기 배치 처리
document_list = [
    "document1.pdf",
    "document2.pptx", 
    "document3.docx",
    "document4.pdf"
]

# 비동기 실행
async def run_batch_processing():
    results = await batch_processor.process_documents_batch(document_list)
    
    print(f"성공: {results['total_processed']}개")
    print(f"실패: {results['total_failed']}개")
    
    for failed in results['failed']:
        print(f"실패한 문서: {failed['document']} - {failed['error']}")

# 우선순위 기반 처리
priority_documents = [
    (1, "urgent_contract.pdf"),    # 높은 우선순위
    (3, "quarterly_report.pdf"),   # 중간 우선순위
    (2, "legal_document.pdf"),     # 중상 우선순위
    (5, "training_manual.pdf")     # 낮은 우선순위
]

priority_results = batch_processor.process_with_priority_queue(priority_documents)
```

### 2. 메모리 및 성능 최적화

```python
# 성능 최적화 관리자
class PerformanceOptimizer:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
        self.performance_metrics = {}
    
    def optimize_for_large_documents(self, doc_path, max_memory_mb=2048):
        """대용량 문서 최적화 처리"""
        
        import psutil
        import gc
        
        # 초기 메모리 상태 확인
        initial_memory = psutil.Process().memory_info().rss / 1024 / 1024
        
        # 문서 크기 확인
        file_size = self._get_file_size_mb(doc_path)
        
        # 메모리 기반 처리 전략 결정
        if file_size > 100:  # 100MB 이상
            strategy = "streaming"
        elif file_size > 50:  # 50MB 이상
            strategy = "chunked"
        else:
            strategy = "standard"
        
        print(f"파일 크기: {file_size:.1f}MB, 전략: {strategy}")
        
        start_time = time.time()
        
        try:
            if strategy == "streaming":
                result = self._streaming_process(doc_path, max_memory_mb)
            elif strategy == "chunked":
                result = self._chunked_process(doc_path, max_memory_mb)
            else:
                result = self._standard_process(doc_path)
            
            processing_time = time.time() - start_time
            peak_memory = psutil.Process().memory_info().rss / 1024 / 1024
            
            # 성능 메트릭 기록
            self.performance_metrics[doc_path] = {
                "file_size_mb": file_size,
                "processing_time": processing_time,
                "initial_memory_mb": initial_memory,
                "peak_memory_mb": peak_memory,
                "memory_delta_mb": peak_memory - initial_memory,
                "strategy": strategy,
                "throughput_mb_per_sec": file_size / processing_time if processing_time > 0 else 0
            }
            
            # 메모리 정리
            gc.collect()
            
            return result
            
        except Exception as e:
            print(f"최적화 처리 실패: {e}")
            raise
    
    def _streaming_process(self, doc_path, max_memory_mb):
        """스트리밍 방식 처리 (대용량 파일용)"""
        
        # 페이지별 순차 처리
        task = self.chunkr.upload(doc_path)
        
        # JSON 결과를 스트림으로 처리
        json_result = task.json()
        
        # 페이지별로 나누어 처리
        processed_pages = []
        
        for page in json_result.get("pages", []):
            # 페이지 단위로 처리하여 메모리 사용량 제한
            processed_page = self._process_single_page(page)
            processed_pages.append(processed_page)
            
            # 메모리 사용량 체크
            current_memory = psutil.Process().memory_info().rss / 1024 / 1024
            if current_memory > max_memory_mb:
                # 중간 결과 저장 및 메모리 정리
                self._save_intermediate_results(processed_pages, doc_path)
                processed_pages = []  # 리스트 초기화
                gc.collect()
        
        return {
            "pages": processed_pages,
            "processing_method": "streaming"
        }
    
    def _chunked_process(self, doc_path, max_memory_mb):
        """청크 방식 처리 (중간 크기 파일용)"""
        
        # 문서를 여러 청크로 나누어 처리
        task = self.chunkr.upload(doc_path)
        full_result = task.json()
        
        # 페이지를 청크로 그룹핑
        pages = full_result.get("pages", [])
        chunk_size = max(1, len(pages) // 4)  # 4개 청크로 분할
        
        processed_chunks = []
        
        for i in range(0, len(pages), chunk_size):
            chunk_pages = pages[i:i + chunk_size]
            
            # 청크 처리
            chunk_result = self._process_page_chunk(chunk_pages)
            processed_chunks.append(chunk_result)
            
            # 중간 정리
            if i % (chunk_size * 2) == 0:  # 2청크마다 정리
                gc.collect()
        
        return {
            "chunks": processed_chunks,
            "processing_method": "chunked"
        }
    
    def _standard_process(self, doc_path):
        """표준 처리 (일반 크기 파일용)"""
        
        task = self.chunkr.upload(doc_path)
        
        return {
            "html": task.html(),
            "markdown": task.markdown(),
            "json": task.json(),
            "processing_method": "standard"
        }
    
    def get_performance_report(self):
        """성능 리포트 생성"""
        
        if not self.performance_metrics:
            return "No performance data available"
        
        total_files = len(self.performance_metrics)
        total_size = sum(m["file_size_mb"] for m in self.performance_metrics.values())
        total_time = sum(m["processing_time"] for m in self.performance_metrics.values())
        avg_throughput = sum(m["throughput_mb_per_sec"] for m in self.performance_metrics.values()) / total_files
        
        report = f"""
        성능 리포트
        ====================
        처리된 파일 수: {total_files}
        총 파일 크기: {total_size:.1f}MB
        총 처리 시간: {total_time:.1f}초
        평균 처리량: {avg_throughput:.2f}MB/초
        전체 처리량: {total_size/total_time:.2f}MB/초
        
        파일별 상세 정보:
        """
        
        for doc_path, metrics in self.performance_metrics.items():
            report += f"""
        {doc_path}:
          - 크기: {metrics['file_size_mb']:.1f}MB
          - 시간: {metrics['processing_time']:.1f}초
          - 처리량: {metrics['throughput_mb_per_sec']:.2f}MB/초
          - 메모리 증가: {metrics['memory_delta_mb']:.1f}MB
          - 전략: {metrics['strategy']}
        """
        
        return report

# 사용 예제
optimizer = PerformanceOptimizer(chunkr)

# 대용량 문서 최적화 처리
large_documents = [
    "large_report_150mb.pdf",
    "huge_manual_300mb.pdf",
    "massive_dataset_500mb.xlsx"
]

for doc in large_documents:
    try:
        result = optimizer.optimize_for_large_documents(doc, max_memory_mb=4096)
        print(f"✅ {doc} 처리 완료")
    except Exception as e:
        print(f"❌ {doc} 처리 실패: {e}")

# 성능 리포트 출력
print(optimizer.get_performance_report())
```

## 라이센스 및 배포 옵션

### 오픈소스 vs 상용 서비스 비교

Chunkr은 다양한 사용 케이스에 맞는 **유연한 라이센스 옵션**을 제공합니다:

| 특징 | 오픈소스 (AGPL-3.0) | 상용 API | 엔터프라이즈 |
|------|---------------------|----------|-------------|
| **적용 대상** | 개발 및 테스트 | 프로덕션 애플리케이션 | 대규모/고보안 배포 |
| **레이아웃 분석** | 기본 모델 | 고급 모델 | 고급 + 커스텀 튜닝 |
| **OCR 정확도** | 표준 모델 | 프리미엄 모델 | 프리미엄 + 도메인 튜닝 |
| **VLM 처리** | 기본 비전 모델 | 향상된 VLM 모델 | 향상된 + 커스텀 파인튜닝 |
| **Excel 지원** | ❌ | ✅ 네이티브 파서 | ✅ 네이티브 파서 |
| **인프라** | 셀프 호스팅 | 완전 관리형 | 완전 관리형 (온프렘/클라우드) |
| **지원** | Discord 커뮤니티 | 우선 이메일 + 커뮤니티 | 24/7 전용 팀 지원 |

### 실제 배포 시나리오

```python
# 배포 환경별 설정 관리
class DeploymentManager:
    def __init__(self):
        self.deployment_configs = {
            "development": {
                "mode": "self_hosted",
                "docker_compose": "compose.yaml",
                "gpu_support": False,
                "scaling": "single_instance",
                "monitoring": "basic"
            },
            "staging": {
                "mode": "hybrid",
                "docker_compose": "compose.yaml + compose.cpu.yaml",
                "gpu_support": True,
                "scaling": "horizontal",
                "monitoring": "detailed"
            },
            "production": {
                "mode": "commercial_api",
                "endpoint": "https://api.chunkr.ai",
                "gpu_support": True,
                "scaling": "auto",
                "monitoring": "enterprise"
            },
            "enterprise": {
                "mode": "on_premise",
                "docker_compose": "enterprise.yaml",
                "gpu_support": True,
                "scaling": "kubernetes",
                "monitoring": "full_observability"
            }
        }
    
    def setup_environment(self, env_type):
        """환경별 설정 적용"""
        
        config = self.deployment_configs.get(env_type)
        if not config:
            raise ValueError(f"Unsupported environment: {env_type}")
        
        if config["mode"] == "self_hosted":
            return self._setup_self_hosted(config)
        elif config["mode"] == "commercial_api":
            return self._setup_commercial_api(config)
        elif config["mode"] == "enterprise":
            return self._setup_enterprise(config)
    
    def _setup_self_hosted(self, config):
        """셀프 호스팅 환경 설정"""
        
        return f"""
        # 셀프 호스팅 설정
        git clone https://github.com/lumina-ai-inc/chunkr
        cd chunkr
        
        # 환경 설정
        cp .env.example .env
        cp models.example.yaml models.yaml
        
        # Docker Compose 실행
        docker compose -f {config['docker_compose']} up -d
        
        # 접속 정보
        Web UI: http://localhost:5173
        API: http://localhost:8000
        """
    
    def _setup_commercial_api(self, config):
        """상용 API 설정"""
        
        return f"""
        # 상용 API 설정
        pip install chunkr-ai
        
        # 사용 코드
        from chunkr_ai import Chunkr
        
        chunkr = Chunkr(api_key="your_api_key_from_chunkr_ai")
        
        # API 엔드포인트: {config['endpoint']}
        """
    
    def _setup_enterprise(self, config):
        """엔터프라이즈 환경 설정"""
        
        return f"""
        # 엔터프라이즈 환경 설정
        # 1. 전용 인프라 구성
        # 2. 보안 설정 적용
        # 3. {config['scaling']} 스케일링 구성
        # 4. {config['monitoring']} 모니터링 설치
        
        # Kubernetes 배포 (예제)
        kubectl apply -f k8s/chunkr-enterprise.yaml
        """

# 성능 비교 및 선택 가이드
deployment_guide = """
# Chunkr 배포 가이드

## 1. 개발 및 테스트 단계
- **권장**: 오픈소스 셀프 호스팅
- **이유**: 무료, 커스터마이징 가능, 학습 목적
- **제한**: 기본 모델, Excel 지원 없음

## 2. 소규모 프로덕션
- **권장**: 상용 API
- **이유**: 관리 부담 없음, 고급 기능, 안정성
- **비용**: 사용량 기반 과금

## 3. 대규모 프로덕션
- **권장**: 엔터프라이즈
- **이유**: 전용 지원, 커스터마이징, 보안 강화
- **특징**: 온프레미스 또는 전용 클라우드

## 4. 하이브리드 접근
- **개발**: 오픈소스 로컬 환경
- **테스트**: 상용 API 검증
- **프로덕션**: 엔터프라이즈 배포
"""

print(deployment_guide)
```

## 자동화 테스트 및 검증

### 통합 테스트 스크립트

```bash
#!/bin/bash
# test-chunkr.sh

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

PROJECT_DIR="$HOME/ai-projects/chunkr"

echo "🚀 Chunkr 환경 테스트 시작"
echo "=============================="

# 1. 시스템 요구사항 확인
log_info "시스템 정보 확인 중..."
echo "📱 OS: $(uname -s) $(uname -r)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'Docker not found')"
echo "📦 Docker Compose: $(docker compose version 2>/dev/null || echo 'Docker Compose not found')"

# 2. 프로젝트 클론 및 설정
log_info "프로젝트 설정 중..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -d ".git" ]; then
    log_info "Chunkr 프로젝트 클론 중..."
    git clone https://github.com/lumina-ai-inc/chunkr.git .
fi

# 3. 환경 파일 설정
if [ ! -f ".env" ]; then
    log_info "환경 파일 설정 중..."
    cp .env.example .env
fi

if [ ! -f "models.yaml" ]; then
    log_info "모델 설정 파일 생성 중..."
    cp models.example.yaml models.yaml
fi

# 4. Docker 환경 확인
if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
    log_info "Docker 환경 테스트 중..."
    
    # GPU 지원 확인
    if command -v nvidia-smi &> /dev/null; then
        log_info "NVIDIA GPU 감지됨, GPU 모드로 실행"
        COMPOSE_FILES="compose.yaml"
    elif [[ $(uname -s) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
        log_info "Apple Silicon 감지됨, MAC ARM 모드로 실행"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml -f compose.mac.yaml"
    else
        log_info "CPU 모드로 실행"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml"
    fi
    
    # Docker Compose 실행
    log_info "Chunkr 서비스 시작 중..."
    docker compose -f $COMPOSE_FILES up -d
    
    # 서비스 준비 대기
    log_info "서비스 초기화 대기 중..."
    sleep 30
    
    # 헬스체크
    log_info "서비스 상태 확인 중..."
    for i in {1..10}; do
        if curl -s http://localhost:8000/health > /dev/null; then
            log_success "API 서버 정상 동작 확인"
            break
        elif [ $i -eq 10 ]; then
            log_error "API 서버 응답 없음"
            docker compose -f $COMPOSE_FILES logs api
        else
            echo "대기 중... ($i/10)"
            sleep 5
        fi
    done
    
    if curl -s http://localhost:5173 > /dev/null; then
        log_success "웹 UI 정상 동작 확인"
    else
        log_warning "웹 UI 응답 없음"
    fi
    
else
    log_warning "Docker가 설치되어 있지 않음, Python SDK 테스트만 진행"
fi

# 5. Python SDK 테스트
log_info "Python SDK 테스트 중..."

# 가상환경 생성
if [ ! -d "chunkr-env" ]; then
    python3 -m venv chunkr-env
fi

source chunkr-env/bin/activate

# SDK 설치
pip install --upgrade pip
pip install chunkr-ai requests

# SDK 테스트 스크립트 생성
cat > test_chunkr_sdk.py << 'EOF'
#!/usr/bin/env python3
"""
Chunkr SDK 기능 테스트
"""

import sys
import os
import tempfile
import requests

def test_imports():
    """패키지 import 테스트"""
    print("📦 SDK import 테스트...")
    
    try:
        from chunkr_ai import Chunkr
        print("  ✅ chunkr-ai 패키지")
        return True
    except ImportError as e:
        print(f"  ❌ chunkr-ai import 실패: {e}")
        return False

def test_local_api():
    """로컬 API 연결 테스트"""
    print("\n🔌 로컬 API 연결 테스트...")
    
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        if response.status_code == 200:
            print("  ✅ 로컬 API 서버 응답")
            return True
        else:
            print(f"  ❌ API 서버 오류: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"  ❌ API 연결 실패: {e}")
        return False

def test_sample_document():
    """샘플 문서 처리 테스트"""
    print("\n📄 샘플 문서 처리 테스트...")
    
    # 간단한 텍스트 파일 생성
    sample_content = """
    # 테스트 문서
    
    ## 개요
    이것은 Chunkr 테스트를 위한 샘플 문서입니다.
    
    ## 내용
    - 항목 1: 레이아웃 분석 테스트
    - 항목 2: OCR 기능 테스트  
    - 항목 3: 시맨틱 청킹 테스트
    
    ## 결론
    모든 기능이 정상적으로 작동해야 합니다.
    """
    
    try:
        # 임시 파일 생성
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(sample_content)
            temp_file = f.name
        
        print(f"  📝 임시 파일 생성: {temp_file}")
        
        # 로컬 API 사용 (Cloud API 키가 없어도 테스트 가능)
        if test_local_api():
            print("  💡 로컬 API가 사용 가능하므로 실제 테스트 수행")
            # 실제 구현에서는 로컬 API 엔드포인트 사용
            print("  ✅ 샘플 문서 처리 테스트 통과 (모의)")
        else:
            print("  💡 로컬 API 없음, Cloud API 키 필요")
            print("  ℹ️ chunkr.ai에서 API 키 발급 후 테스트 가능")
        
        # 임시 파일 정리
        os.unlink(temp_file)
        
        return True
        
    except Exception as e:
        print(f"  ❌ 샘플 문서 처리 실패: {e}")
        return False

def main():
    print("🧪 Chunkr SDK 테스트\n")
    
    tests = [
        ("패키지 Import", test_imports),
        ("로컬 API 연결", test_local_api),
        ("샘플 문서 처리", test_sample_document)
    ]
    
    passed = 0
    for name, test_func in tests:
        try:
            if test_func():
                passed += 1
                print(f"✅ {name}: PASS")
            else:
                print(f"❌ {name}: FAIL")
        except Exception as e:
            print(f"❌ {name}: ERROR - {e}")
    
    print(f"\n📊 테스트 결과: {passed}/{len(tests)} 통과")
    
    if passed == len(tests):
        print("\n🎉 모든 테스트 통과!")
        print("💡 이제 Chunkr로 문서 처리를 시작할 수 있습니다.")
    else:
        print(f"\n⚠️ {len(tests)-passed}개 테스트 실패")
        print("💡 실패한 항목을 확인하고 환경을 재설정해보세요.")
    
    return passed == len(tests)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# Python 테스트 실행
log_info "SDK 기능 테스트 실행 중..."
if python test_chunkr_sdk.py; then
    log_success "SDK 테스트 통과!"
else
    log_warning "일부 SDK 테스트 실패"
fi

# 6. 사용법 안내
echo ""
echo "🎯 Chunkr 사용 가이드:"
echo "====================="
echo "1. 프로젝트 디렉토리:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. 웹 UI 접속:"
echo "   http://localhost:5173"
echo ""
echo "3. API 문서:"
echo "   http://localhost:8000/docs"
echo ""
echo "4. Python SDK 사용:"
echo "   source chunkr-env/bin/activate"
echo "   python"
echo '   >>> from chunkr_ai import Chunkr'
echo '   >>> chunkr = Chunkr(api_key="your_key_or_use_local")'
echo ""
echo "5. 서비스 중지:"
echo "   docker compose -f $COMPOSE_FILES down"

echo ""
echo "💡 주요 특징:"
echo "============="
echo "• 고급 레이아웃 분석으로 문서 구조 정확히 파악"
echo "• 정밀한 OCR + 바운딩 박스로 텍스트 위치 추적"
echo "• 시맨틱 청킹으로 RAG 시스템 최적화"
echo "• PDF, PPT, Word, Excel 등 다양한 형식 지원"
echo "• 오픈소스 + 상용 서비스 선택 가능"

log_success "Chunkr 환경 설정 완료!"
echo "📁 프로젝트 위치: $PROJECT_DIR"
echo "🚀 이제 문서 지능형 데이터 처리를 시작해보세요!"
```

## 결론

Chunkr는 **문서 기반 AI 애플리케이션의 패러다임을 변화**시키는 혁신적인 플랫폼입니다. 주요 성과와 가치를 요약하면:

### 🎯 핵심 혁신 성과

1. **지능형 문서 이해**: 단순한 텍스트 추출을 넘어서 **구조, 의미, 맥락**을 모두 파악
2. **RAG 시스템 최적화**: 시맨틱 청킹으로 **검색 정확도 향상** 및 **컨텍스트 보존**
3. **다양한 형식 지원**: PDF, PPT, Word, Excel을 **일관된 품질**로 처리
4. **확장 가능한 아키텍처**: 개발부터 엔터프라이즈까지 **모든 규모**에 대응

### 💡 기술적 차별화

- **비전 기반 레이아웃 분석**: 표, 이미지, 그래프의 **구조적 관계** 정확히 파악
- **정밀한 OCR + 바운딩 박스**: 텍스트의 **위치와 스타일 정보** 보존
- **적응형 청킹 전략**: 콘텐츠 유형에 따른 **최적화된 분할**
- **LLM 통합**: 다양한 AI 모델과의 **seamless 연동**

### 🔮 실제 활용 가치

1. **연구 및 학술**: 논문, 보고서의 **체계적 분석**과 **지식 추출**
2. **기업 문서 관리**: 계약서, 재무제표의 **자동 분류**와 **핵심 정보 추출**
3. **콘텐츠 제작**: 복잡한 문서를 **RAG 친화적 데이터**로 변환
4. **다국어 처리**: 글로벌 문서의 **언어별 분석**과 **번역 지원**

### 🌐 오픈 워크플로우 생태계

- **유연한 배포 옵션**: 셀프 호스팅부터 엔터프라이즈까지
- **오픈소스 커뮤니티**: AGPL-3.0 라이센스로 **투명한 개발**
- **상용 서비스**: 프로덕션 환경을 위한 **관리형 솔루션**
- **확장성**: Docker, Kubernetes 기반 **클라우드 네이티브** 아키텍처

### 🚀 미래 전망

Chunkr는 **문서 AI의 민주화**를 통해 누구나 고품질의 문서 지능형 애플리케이션을 구축할 수 있게 합니다. 특히 한국의 개발자와 기업들에게는:

- **언어 장벽 해소**: 한국어 문서 처리 특화 기능
- **기술 접근성**: 복잡한 문서 AI를 **간단한 API**로 활용
- **비용 효율성**: 오픈소스 기반의 **합리적 가격** 정책
- **커스터마이징**: 업종별 **특화 모델** 개발 가능

Chunkr를 통해 단순한 문서 저장소를 **지능형 지식 베이스**로 전환하고, RAG 시스템의 성능을 **극대화**해보시기 바랍니다. 문서 처리의 새로운 표준을 경험하며, AI 기반 워크플로우의 **무한한 가능성**을 발견하시길 바랍니다! 📄🤖✨

---

> **참고 자료**
> - [Chunkr GitHub Repository](https://github.com/lumina-ai-inc/chunkr)
> - [Chunkr 공식 웹사이트](https://chunkr.ai)
> - [Chunkr API 문서](https://docs.chunkr.ai)
> - [Python SDK 가이드](https://pypi.org/project/chunkr-ai/)