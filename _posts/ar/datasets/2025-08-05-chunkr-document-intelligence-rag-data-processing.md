---
title: "Chunkr: منصة معالجة البيانات الوثائقية الذكية لنظم RAG ونماذج اللغة الكبيرة"
excerpt: "منصة API مفتوحة المصدر لذكاء المستندات تحول ملفات PDF وPPT وWord المعقدة إلى بيانات منظمة محسّنة لنظم RAG عبر تحليل التخطيط وOCR والتقسيم الدلالي"
seo_title: "Chunkr: الدليل الشامل لمنصة معالجة المستندات الذكية - Thaki Cloud"
seo_description: "كيفية معالجة بيانات المستندات باستخدام تحليل التخطيط وOCR والتقسيم الدلالي في Chunkr. دليل عملي لتحويل ملفات PDF وPPT وWord إلى بيانات منظمة ملائمة لنظم RAG ونماذج اللغة الكبيرة"
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
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/datasets/chunkr-document-intelligence-rag-data-processing/"
reading_time: true
lang: ar
published: true
---

⏱️ **وقت القراءة المقدر**: 18 دقيقة

## مقدمة

في أنظمة الذكاء الاصطناعي الحديثة، يعتمد أداء تطبيقات **RAG (التوليد المعزز بالاسترجاع)** وتطبيقات **LLM** اعتماداً كبيراً على جودة البيانات المدخلة. يظل استخراج المعلومات ذات المعنى من **المستندات ذات البنية المعقدة** كملفات PDF وPowerPoint وWord، وتقسيمها بصورة ملائمة، تحدياً حقيقياً يواجه المطورين والباحثين.

غالباً ما تفقد مناهج استخراج النص العادي التقليدية المعلومات البنيوية المضمنة في **تخطيطات المستندات والجداول والصور والمخططات البيانية**، مما يُصعّب على LLMs فهم السياق على النحو الصحيح. جاء [Chunkr](https://github.com/lumina-ai-inc/chunkr) لمعالجة هذه الإشكاليات: فهو **منصة API لذكاء المستندات تعتمد على الرؤية الحاسوبية** وتلتقط بنية المستند ودلالاته بدقة لتوليد بيانات محسّنة لنظم RAG.

تتناول هذه المقالة الميزات الأساسية لـ Chunkr وكيفية تطبيقها، فضلاً عن دليل عملي لاستخراج بيانات عالية الجودة من مجموعة متنوعة من تنسيقات المستندات.

## التقنيات الأساسية في Chunkr

### 1. تحليل التخطيط المتقدم

يُعدّ **تحليل التخطيط** من أقوى ميزات Chunkr، إذ يحدد العناصر البنيوية للمستند ويصنفها بدقة عالية.

#### عناصر التخطيط المدعومة
- **كتل النص**: التمييز بين العناوين ونص المتن والتعليقات التوضيحية
- **بنية الجداول**: استخراج البيانات مع الحفاظ على علاقات الصفوف والأعمدة
- **الصور والمخططات البيانية**: فهم علاقات الموضع والتسميات التوضيحية
- **بنية القوائم**: البنية الهرمية للقوائم المرتبة وغير المرتبة
- **التخطيطات متعددة الأعمدة**: معالجة المستندات متعددة الأعمدة على غرار الصحف والمجلات

#### مثال على نتيجة تحليل التخطيط
```python
# Layout analysis result structure
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

### 2. OCR الدقيق والمربعات المحيطة

تتجاوز ميزة **OCR (التعرف الضوئي على الحروف)** مجرد استخراج النص البسيط لتوفر **معلومات موضعية دقيقة لكل حرف**.

#### أبرز مزايا OCR
- **دقة عالية**: التعرف على النص استناداً إلى أحدث نماذج الرؤية الحاسوبية
- **دعم متعدد اللغات**: الكورية والإنجليزية والصينية واليابانية وغيرها
- **المربعات المحيطة**: معلومات إحداثيات دقيقة لكل قطعة نصية
- **بيانات الخط الوصفية**: الحجم والأسلوب واللون وتفاصيل طباعية أخرى
- **النص المائل**: التعرف الدقيق على النصوص المنحرفة

### 3. التقسيم الدلالي

**التقسيم الدلالي** منهج تقسيم ذكي يراعي **الصلة الدلالية** بدلاً من الاكتفاء بعدد الأحرف أو الكلمات.

#### استراتيجيات التقسيم
```python
# Semantic chunking configuration example
chunking_config = {
    "strategy": "semantic",
    "max_chunk_size": 1000,  # maximum token count
    "overlap": 200,          # overlap between chunks
    "preserve_structure": True,  # preserve structure
    "semantic_threshold": 0.7,   # semantic similarity threshold
    "respect_boundaries": [
        "paragraph", "section", "table", "list"
    ]
}
```

## التثبيت والإعداد الأساسي

### 1. نهج Cloud API

أبسط طريقة للبدء هي استخدام الخدمة السحابية على [chunkr.ai](https://chunkr.ai).

```python
# Install the Python SDK
pip install chunkr-ai

# Basic usage
from chunkr_ai import Chunkr

# Initialize with your API key
chunkr = Chunkr(api_key="your_api_key_from_chunkr_ai")

# Upload and process a document
url = "https://example.com/document.pdf"
task = chunkr.upload(url)

# Extract results in multiple formats
html = task.html(output_file="output.html")
markdown = task.markdown(output_file="output.md")
content = task.content(output_file="output.txt")
json_data = task.json(output_file="output.json")

# Clean up resources
chunkr.close()
```

### 2. الاستضافة الذاتية باستخدام Docker

إذا كانت الخصوصية أو التخصيص أولوية، يمكنك اختيار الاستضافة الذاتية.

```bash
# Clone the project
git clone https://github.com/lumina-ai-inc/chunkr
cd chunkr

# Configure environment
cp .env.example .env
cp models.example.yaml models.yaml

# Run in a GPU environment
docker compose up -d

# Run in a CPU-only environment
docker compose -f compose.yaml -f compose.cpu.yaml up -d

# macOS ARM (M1/M2/M3) environment
docker compose -f compose.yaml -f compose.cpu.yaml -f compose.mac.yaml up -d
```

### 3. نقاط الوصول للخدمات حسب البيئة

```bash
# Service access addresses
Web UI: http://localhost:5173
API: http://localhost:8000
API Documentation: http://localhost:8000/docs
Health Check: http://localhost:8000/health
```

## ميزات معالجة المستندات المتقدمة

### 1. دعم تنسيقات مستندات متعددة

يدعم Chunkr مجموعة واسعة من تنسيقات المستندات، ويوفر معالجة محسّنة لكل تنسيق.

```python
# Document format-specific processing examples
from chunkr_ai import Chunkr

class DocumentProcessor:
    def __init__(self, api_key):
        self.chunkr = Chunkr(api_key=api_key)
    
    def process_document(self, file_path, doc_type="auto"):
        """Format-optimized document processing"""
        
        # Format-specific configuration
        processing_configs = {
            "pdf": {
                "ocr_strategy": "auto",  # auto-detect text/scanned documents
                "preserve_layout": True,
                "extract_images": True,
                "table_detection": True
            },
            "pptx": {
                "slide_separation": True,  # separate by slide
                "preserve_animations": False,
                "extract_speaker_notes": True,
                "image_extraction": True
            },
            "docx": {
                "preserve_styles": True,   # preserve style information
                "extract_headers_footers": True,
                "table_structure": True,
                "comment_extraction": False
            },
            "xlsx": {
                "sheet_separation": True,  # separate by sheet
                "preserve_formulas": True,
                "data_validation": True,
                "chart_extraction": True
            }
        }
        
        # Upload and process document
        task = self.chunkr.upload(
            file_path,
            config=processing_configs.get(doc_type, {})
        )
        
        return task
    
    def extract_structured_data(self, task):
        """Extract structured data"""
        
        # Get detailed structure information in JSON format
        json_result = task.json()
        
        # Separate data by structure
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
            
            # Classify elements within the page
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

# Usage example
processor = DocumentProcessor("your_api_key")

# Process a PDF document
pdf_task = processor.process_document("report.pdf", "pdf")
pdf_data = processor.extract_structured_data(pdf_task)

# Process a PowerPoint document
ppt_task = processor.process_document("presentation.pptx", "pptx")
ppt_data = processor.extract_structured_data(ppt_task)
```

### 2. استراتيجيات التقسيم المحسّنة لنظم RAG

يمكن تطبيق استراتيجيات تقسيم متقدمة لتحقيق أقصى أداء لنظام RAG.

```python
# RAG-optimized chunking implementation
class RAGOptimizedChunker:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
    
    def create_rag_chunks(self, task, chunk_strategy="adaptive"):
        """Create chunks optimized for RAG systems"""
        
        # Extract structured data
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
        """Adaptive chunking: dynamically adjust by content type"""
        
        chunks = []
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                element_type = element.get("type")
                
                if element_type == "table":
                    # Tables become a single chunk
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
                    # Chunk headers together with following paragraphs
                    header_chunk = self._create_header_chunk(element, page)
                    chunks.append(header_chunk)
                
                elif element_type == "paragraph":
                    # Split or merge based on paragraph length
                    para_chunks = self._split_paragraph(element)
                    chunks.extend(para_chunks)
        
        return chunks
    
    def _semantic_chunking(self, data):
        """Semantic chunking: group by topic"""
        
        # Extract full text
        full_text = self._extract_full_text(data)
        
        # Compute semantic similarity based on embeddings
        semantic_chunks = self._compute_semantic_boundaries(full_text)
        
        return semantic_chunks
    
    def _hierarchical_chunking(self, data):
        """Hierarchical chunking: based on document structure"""
        
        chunks = []
        current_section = None
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") == "header":
                    level = element.get("style", {}).get("level", 1)
                    
                    if level == 1:
                        # Start a new section
                        if current_section:
                            chunks.append(current_section)
                        
                        current_section = {
                            "type": "section",
                            "title": element.get("text"),
                            "content": [],
                            "subsections": []
                        }
                    
                    elif level == 2 and current_section:
                        # Add a subsection
                        current_section["subsections"].append({
                            "title": element.get("text"),
                            "content": []
                        })
                
                else:
                    # Add content to the current section
                    if current_section:
                        if current_section["subsections"]:
                            current_section["subsections"][-1]["content"].append(element)
                        else:
                            current_section["content"].append(element)
        
        # Append the last section
        if current_section:
            chunks.append(current_section)
        
        return chunks
    
    def _format_table(self, table_element):
        """Convert table data to a RAG-friendly format"""
        
        data = table_element.get("data", [])
        if not data:
            return ""
        
        # Separate headers and data
        headers = data[0] if data else []
        rows = data[1:] if len(data) > 1 else []
        
        # Convert to Markdown table format
        markdown_table = "| " + " | ".join(headers) + " |\n"
        markdown_table += "| " + " | ".join(["---"] * len(headers)) + " |\n"
        
        for row in rows:
            markdown_table += "| " + " | ".join(str(cell) for cell in row) + " |\n"
        
        return markdown_table
    
    def optimize_for_retrieval(self, chunks, max_tokens=500):
        """Post-process chunks for retrieval optimization"""
        
        optimized_chunks = []
        
        for chunk in chunks:
            # Check and adjust token count
            if self._count_tokens(chunk.get("content", "")) > max_tokens:
                # Split large chunks
                sub_chunks = self._split_large_chunk(chunk, max_tokens)
                optimized_chunks.extend(sub_chunks)
            else:
                optimized_chunks.append(chunk)
        
        # Enrich metadata
        for i, chunk in enumerate(optimized_chunks):
            chunk["metadata"]["chunk_id"] = i
            chunk["metadata"]["total_chunks"] = len(optimized_chunks)
            
            # Extract search keywords
            chunk["metadata"]["keywords"] = self._extract_keywords(
                chunk.get("content", "")
            )
        
        return optimized_chunks

# Usage example
chunker = RAGOptimizedChunker(chunkr)

# Process document and create RAG-optimized chunks
task = chunkr.upload("complex_document.pdf")
rag_chunks = chunker.create_rag_chunks(task, "adaptive")

# Retrieval optimization
optimized_chunks = chunker.optimize_for_retrieval(rag_chunks, max_tokens=400)
```

## التكامل مع LLM والإعداد

### 1. إعداد موفري LLM المتعددين

يتكامل Chunkr مع مجموعة متنوعة من موفري LLM للاستفادة من قدرات الذكاء الاصطناعي أثناء معالجة المستندات.

```yaml
# models.yaml configuration file
models:
  # OpenAI GPT models
  - id: gpt-4o
    model: gpt-4o
    provider_url: https://api.openai.com/v1/chat/completions
    api_key: "your_openai_api_key"
    default: true
    rate-limit: 200  # requests per minute
    
  # Google Gemini models
  - id: gemini-pro
    model: gemini-1.5-pro
    provider_url: https://generativelanguage.googleapis.com/v1beta/openai/chat/completions
    api_key: "your_google_api_key"
    rate-limit: 100
    
  # Anthropic Claude models
  - id: claude-3-sonnet
    model: claude-3-5-sonnet-20241022
    provider_url: https://api.anthropic.com/v1/messages
    api_key: "your_anthropic_api_key"
    rate-limit: 50
    
  # Local models (vLLM or Ollama)
  - id: local-llama
    model: llama-3.1-8b-instruct
    provider_url: http://localhost:8000/v1/chat/completions
    api_key: "not_required"
    rate-limit: 1000
    
  # OpenRouter (access to a variety of models)
  - id: openrouter-mixtral
    model: mistralai/mixtral-8x7b-instruct
    provider_url: https://openrouter.ai/api/v1/chat/completions
    api_key: "your_openrouter_api_key"
    rate-limit: 150

# Environment-specific settings
environments:
  development:
    default_model: local-llama
    fallback_model: gpt-4o
  
  production:
    default_model: gpt-4o
    fallback_model: gemini-pro
```

### 2. تحليل المستندات المعزز بـ LLM

```python
# LLM-integrated document analysis class
class LLMEnhancedDocumentAnalyzer:
    def __init__(self, chunkr_instance, llm_config):
        self.chunkr = chunkr_instance
        self.llm_config = llm_config
    
    def analyze_document_content(self, task):
        """Document content analysis using LLM"""
        
        # Extract basic structured data
        structured_data = task.json()
        
        # LLM analysis results
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
        """Generate document summary"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        Summarize the key content of the following document in 3-4 sentences:
        
        {full_text[:2000]}...
        
        Summary:
        """
        
        return self._call_llm(prompt, model="gpt-4o")
    
    def _extract_topics(self, data):
        """Extract key topics"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        Extract the main topics from the following document and present them as a list:
        
        {full_text[:1500]}...
        
        Main topics (up to 5):
        """
        
        response = self._call_llm(prompt, model="gemini-pro")
        return self._parse_topics(response)
    
    def _extract_entities(self, data):
        """Named entity recognition"""
        
        full_text = self._extract_text_content(data)
        
        prompt = f"""
        Extract important named entities from the following text:
        - Person (PERSON)
        - Organization (ORGANIZATION)
        - Location (LOCATION)
        - Date (DATE)
        - Technology/Product (TECHNOLOGY)
        
        Text:
        {full_text[:1000]}...
        
        Respond in JSON format:
        """
        
        response = self._call_llm(prompt, model="claude-3-sonnet")
        return self._parse_entities(response)
    
    def _assess_quality(self, data):
        """Assess document quality"""
        
        metrics = {
            "text_clarity": 0.0,
            "structure_quality": 0.0,
            "content_depth": 0.0,
            "readability": 0.0,
            "completeness": 0.0
        }
        
        # Quality assessment based on OCR accuracy
        ocr_confidence = self._calculate_ocr_confidence(data)
        
        # Structural element assessment
        structure_score = self._evaluate_structure(data)
        
        # LLM-based content quality assessment
        content_score = self._evaluate_content_quality(data)
        
        overall_score = (ocr_confidence + structure_score + content_score) / 3
        
        return {
            "overall_score": overall_score,
            "metrics": metrics,
            "recommendations": self._get_quality_recommendations(overall_score)
        }
    
    def _call_llm(self, prompt, model="gpt-4o"):
        """Call the LLM API"""
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

# Usage example
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

# Run document analysis
task = chunkr.upload("research_paper.pdf")
analysis = analyzer.analyze_document_content(task)

print(f"Document summary: {analysis['summary']}")
print(f"Key topics: {analysis['key_topics']}")
print(f"Quality score: {analysis['quality_score']['overall_score']:.2f}")
```

## حالات الاستخدام الفعلية والتطبيقات

### 1. خط معالجة الأوراق البحثية الأكاديمية

```python
# Dedicated processing pipeline for academic papers
class AcademicPaperProcessor:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
    
    def process_research_paper(self, paper_path):
        """Dedicated processing for academic papers"""
        
        # Process document
        task = self.chunkr.upload(paper_path)
        structured_data = task.json()
        
        # Analyze paper structure
        paper_structure = self._analyze_paper_structure(structured_data)
        
        # Process each section
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
        
        # Extract metadata
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
        """Automatic paper structure recognition"""
        
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
        """Extract paper metadata"""
        
        # Extract metadata from the first page
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
        
        # Extract title (typically the first large-font text)
        for element in elements[:5]:  # look in the first 5 elements
            if element.get("type") == "header":
                style = element.get("style", {})
                if style.get("font_size", 0) > 16:
                    metadata["title"] = element.get("text", "")
                    break
        
        # Extract author information from elements after the title
        # Identified by email patterns or university name patterns
        
        return metadata

# Usage example
processor = AcademicPaperProcessor(chunkr)
paper_data = processor.process_research_paper("research_paper.pdf")

print(f"Paper title: {paper_data['metadata']['title']}")
print(f"Number of sections: {len(paper_data['sections'])}")
print(f"Number of figures: {len(paper_data['figures'])}")
print(f"Number of tables: {len(paper_data['tables'])}")
```

### 2. نظام التصنيف التلقائي للمستندات المؤسسية

```python
# Corporate document auto-classification and processing
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
        """Classify document and process by type"""
        
        # Basic document processing
        task = self.chunkr.upload(document_path)
        structured_data = task.json()
        
        # Classify document type
        doc_type = self._classify_document_type(structured_data)
        
        # Type-specific processing
        if doc_type == "contract":
            return self._process_contract(structured_data)
        elif doc_type == "report":
            return self._process_report(structured_data)
        elif doc_type == "financial":
            return self._process_financial_document(structured_data)
        else:
            return self._process_generic_document(structured_data)
    
    def _classify_document_type(self, data):
        """Automatic document type classification"""
        
        # Extract full text
        full_text = ""
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") in ["paragraph", "header"]:
                    full_text += element.get("text", "") + " "
        
        full_text = full_text.lower()
        
        # Classify via keyword matching
        type_scores = {}
        
        for doc_type, keywords in self.document_types.items():
            score = sum(1 for keyword in keywords if keyword in full_text)
            type_scores[doc_type] = score
        
        # Return the type with the highest score
        return max(type_scores, key=type_scores.get) if type_scores else "generic"
    
    def _process_contract(self, data):
        """Contract-specific processing"""
        
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
        """Financial document-specific processing"""
        
        financial_data = {
            "financial_tables": self._extract_financial_tables(data),
            "key_metrics": self._extract_financial_metrics(data),
            "charts": self._extract_financial_charts(data),
            "currency_amounts": self._extract_currency_amounts(data),
            "accounting_periods": self._extract_accounting_periods(data)
        }
        
        return financial_data
    
    def _extract_financial_tables(self, data):
        """Extract and analyze financial tables"""
        
        financial_tables = []
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") == "table":
                    table_data = element.get("data", [])
                    
                    # Check if this is a financial table
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
        """Determine whether a table is financial"""
        
        if not table_data:
            return False
        
        # Look for finance-related keywords in headers
        headers = table_data[0] if table_data else []
        financial_keywords = [
            "revenue", "매출", "profit", "이익", "cost", "비용",
            "asset", "자산", "liability", "부채", "equity", "자본",
            "cash", "현금", "investment", "투자", "expense", "지출"
        ]
        
        header_text = " ".join(str(header).lower() for header in headers)
        
        return any(keyword in header_text for keyword in financial_keywords)

# Usage example
classifier = CorporateDocumentClassifier(chunkr)

# Process a variety of documents
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

### 3. معالجة المستندات متعددة اللغات

```python
# Multilingual document processing system
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
        """Process a multilingual document"""
        
        # Basic document processing
        task = self.chunkr.upload(document_path)
        structured_data = task.json()
        
        # Language detection and analysis
        language_analysis = self._analyze_languages(structured_data)
        
        # Separate text by language
        language_segments = self._segment_by_language(structured_data, language_analysis)
        
        # Translation processing (if needed)
        translated_content = self._translate_content(language_segments)
        
        return {
            "original_data": structured_data,
            "language_analysis": language_analysis,
            "language_segments": language_segments,
            "translations": translated_content,
            "unified_content": self._create_unified_content(language_segments, translated_content)
        }
    
    def _analyze_languages(self, data):
        """Analyze languages present in the document"""
        
        from langdetect import detect, detect_langs
        
        language_stats = {}
        
        for page in data.get("pages", []):
            for element in page.get("elements", []):
                if element.get("type") in ["paragraph", "header"]:
                    text = element.get("text", "")
                    
                    if len(text.strip()) > 20:  # only analyze text of sufficient length
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
                            continue  # skip on detection failure
        
        # Calculate average confidence
        for lang in language_stats:
            count = language_stats[lang]["count"]
            if count > 0:
                language_stats[lang]["avg_confidence"] = (
                    language_stats[lang]["total_confidence"] / count
                )
        
        return language_stats
    
    def _segment_by_language(self, data, language_analysis):
        """Separate text segments by language"""
        
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
                            # On detection failure, classify under the default language
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
        """Translate multilingual content"""
        
        # This simplified example uses the Google Translate API.
        # In practice, you can use DeepL, Azure Translator, or a local translation model.
        
        translated_content = {}
        
        for source_lang, segments in language_segments.items():
            if source_lang != target_lang:
                translated_segments = []
                
                for segment in segments:
                    # Call the translation API (example)
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
        """Call the translation API (example)"""
        
        # In a real implementation, use the API of your chosen translation service.
        # This is a simple placeholder.
        
        return f"[TRANSLATED from {source_lang} to {target_lang}] {text}"

# Usage example
multilingual_processor = MultilingualDocumentProcessor(chunkr)

# Process a multilingual document
result = multilingual_processor.process_multilingual_document("multilingual_report.pdf")

print("Detected languages:")
for lang, stats in result["language_analysis"].items():
    print(f"  {lang}: {stats['count']} segments (avg confidence: {stats['avg_confidence']:.2f})")

print(f"\nTranslated content: {len(result['translations'])} language pairs")
```

## تحسين الأداء والتوسع

### 1. المعالجة الدفعية لأحجام كبيرة من المستندات

```python
# Batch processing system for large document volumes
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
        """Asynchronous batch document processing"""
        
        # Create task queue
        tasks = []
        
        for doc_path in document_paths:
            task = asyncio.create_task(
                self._process_single_document_async(doc_path)
            )
            tasks.append(task)
        
        # Wait for all tasks to complete
        results = await asyncio.gather(*tasks, return_exceptions=True)
        
        # Organize results
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
        """Single document async processing"""
        
        loop = asyncio.get_event_loop()
        
        # Run CPU-intensive work in a separate thread
        result = await loop.run_in_executor(
            self.executor,
            self._process_document_sync,
            doc_path
        )
        
        return result
    
    def _process_document_sync(self, doc_path):
        """Synchronous document processing"""
        
        try:
            # Process document
            task = self.chunkr.upload(doc_path)
            
            # Generate results in multiple formats
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
        """Calculate file size"""
        import os
        return os.path.getsize(file_path) if os.path.exists(file_path) else 0
    
    def process_with_priority_queue(self, documents_with_priority):
        """Priority-based document processing"""
        
        import heapq
        
        # Create priority queue (lower number = higher priority)
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

# Usage example
batch_processor = BatchDocumentProcessor(chunkr, max_workers=3)

# Asynchronous batch processing
document_list = [
    "document1.pdf",
    "document2.pptx", 
    "document3.docx",
    "document4.pdf"
]

# Asynchronous execution
async def run_batch_processing():
    results = await batch_processor.process_documents_batch(document_list)
    
    print(f"Successful: {results['total_processed']}")
    print(f"Failed: {results['total_failed']}")
    
    for failed in results['failed']:
        print(f"Failed document: {failed['document']} - {failed['error']}")

# Priority-based processing
priority_documents = [
    (1, "urgent_contract.pdf"),    # high priority
    (3, "quarterly_report.pdf"),   # medium priority
    (2, "legal_document.pdf"),     # medium-high priority
    (5, "training_manual.pdf")     # low priority
]

priority_results = batch_processor.process_with_priority_queue(priority_documents)
```

### 2. تحسين الذاكرة والأداء

```python
# Performance optimization manager
class PerformanceOptimizer:
    def __init__(self, chunkr_instance):
        self.chunkr = chunkr_instance
        self.performance_metrics = {}
    
    def optimize_for_large_documents(self, doc_path, max_memory_mb=2048):
        """Optimized processing for large documents"""
        
        import psutil
        import gc
        
        # Check initial memory state
        initial_memory = psutil.Process().memory_info().rss / 1024 / 1024
        
        # Check document size
        file_size = self._get_file_size_mb(doc_path)
        
        # Determine processing strategy based on memory
        if file_size > 100:  # over 100 MB
            strategy = "streaming"
        elif file_size > 50:  # over 50 MB
            strategy = "chunked"
        else:
            strategy = "standard"
        
        print(f"File size: {file_size:.1f}MB, strategy: {strategy}")
        
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
            
            # Record performance metrics
            self.performance_metrics[doc_path] = {
                "file_size_mb": file_size,
                "processing_time": processing_time,
                "initial_memory_mb": initial_memory,
                "peak_memory_mb": peak_memory,
                "memory_delta_mb": peak_memory - initial_memory,
                "strategy": strategy,
                "throughput_mb_per_sec": file_size / processing_time if processing_time > 0 else 0
            }
            
            # Clean up memory
            gc.collect()
            
            return result
            
        except Exception as e:
            print(f"Optimization processing failed: {e}")
            raise
    
    def _streaming_process(self, doc_path, max_memory_mb):
        """Streaming processing (for large files)"""
        
        # Sequential page-by-page processing
        task = self.chunkr.upload(doc_path)
        
        # Process JSON results as a stream
        json_result = task.json()
        
        # Process page by page
        processed_pages = []
        
        for page in json_result.get("pages", []):
            # Process one page at a time to limit memory usage
            processed_page = self._process_single_page(page)
            processed_pages.append(processed_page)
            
            # Check memory usage
            current_memory = psutil.Process().memory_info().rss / 1024 / 1024
            if current_memory > max_memory_mb:
                # Save intermediate results and free memory
                self._save_intermediate_results(processed_pages, doc_path)
                processed_pages = []  # reset list
                gc.collect()
        
        return {
            "pages": processed_pages,
            "processing_method": "streaming"
        }
    
    def _chunked_process(self, doc_path, max_memory_mb):
        """Chunked processing (for medium-sized files)"""
        
        # Process document in multiple chunks
        task = self.chunkr.upload(doc_path)
        full_result = task.json()
        
        # Group pages into chunks
        pages = full_result.get("pages", [])
        chunk_size = max(1, len(pages) // 4)  # divide into 4 chunks
        
        processed_chunks = []
        
        for i in range(0, len(pages), chunk_size):
            chunk_pages = pages[i:i + chunk_size]
            
            # Process chunk
            chunk_result = self._process_page_chunk(chunk_pages)
            processed_chunks.append(chunk_result)
            
            # Intermediate cleanup
            if i % (chunk_size * 2) == 0:  # clean every 2 chunks
                gc.collect()
        
        return {
            "chunks": processed_chunks,
            "processing_method": "chunked"
        }
    
    def _standard_process(self, doc_path):
        """Standard processing (for regular-sized files)"""
        
        task = self.chunkr.upload(doc_path)
        
        return {
            "html": task.html(),
            "markdown": task.markdown(),
            "json": task.json(),
            "processing_method": "standard"
        }
    
    def get_performance_report(self):
        """Generate performance report"""
        
        if not self.performance_metrics:
            return "No performance data available"
        
        total_files = len(self.performance_metrics)
        total_size = sum(m["file_size_mb"] for m in self.performance_metrics.values())
        total_time = sum(m["processing_time"] for m in self.performance_metrics.values())
        avg_throughput = sum(m["throughput_mb_per_sec"] for m in self.performance_metrics.values()) / total_files
        
        report = f"""
        Performance Report
        ====================
        Files processed: {total_files}
        Total file size: {total_size:.1f}MB
        Total processing time: {total_time:.1f}s
        Average throughput: {avg_throughput:.2f}MB/s
        Overall throughput: {total_size/total_time:.2f}MB/s
        
        Per-file details:
        """
        
        for doc_path, metrics in self.performance_metrics.items():
            report += f"""
        {doc_path}:
          - Size: {metrics['file_size_mb']:.1f}MB
          - Time: {metrics['processing_time']:.1f}s
          - Throughput: {metrics['throughput_mb_per_sec']:.2f}MB/s
          - Memory increase: {metrics['memory_delta_mb']:.1f}MB
          - Strategy: {metrics['strategy']}
        """
        
        return report

# Usage example
optimizer = PerformanceOptimizer(chunkr)

# Optimized processing for large documents
large_documents = [
    "large_report_150mb.pdf",
    "huge_manual_300mb.pdf",
    "massive_dataset_500mb.xlsx"
]

for doc in large_documents:
    try:
        result = optimizer.optimize_for_large_documents(doc, max_memory_mb=4096)
        print(f"✅ {doc} processed successfully")
    except Exception as e:
        print(f"❌ {doc} processing failed: {e}")

# Output performance report
print(optimizer.get_performance_report())
```

## الترخيص وخيارات النشر

### مقارنة المصدر المفتوح مقابل الخدمة التجارية

يوفر Chunkr **خيارات ترخيص مرنة** تلائم حالات استخدام متنوعة:

| الميزة | مصدر مفتوح (AGPL-3.0) | API تجاري | مؤسسي |
|--------|------------------------|----------------|------------|
| **الفئة المستهدفة** | التطوير والاختبار | تطبيقات الإنتاج | عمليات النشر واسعة النطاق وعالية الأمان |
| **تحليل التخطيط** | نماذج أساسية | نماذج متقدمة | متقدم مع ضبط مخصص |
| **دقة OCR** | نماذج قياسية | نماذج متميزة | متميز مع ضبط حسب النطاق |
| **معالجة VLM** | نماذج رؤية أساسية | نماذج VLM محسّنة | محسّن مع ضبط دقيق مخصص |
| **دعم Excel** | غير مضمّن | محلل أصلي | محلل أصلي |
| **البنية التحتية** | استضافة ذاتية | مُدار بالكامل | مُدار بالكامل (محلي/سحابي) |
| **الدعم** | مجتمع Discord | بريد إلكتروني ذو أولوية | فريق مخصص على مدار الساعة |

### سيناريوهات النشر الفعلية

```python
# Deployment environment configuration management
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
        """Apply environment-specific configuration"""
        
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
        """Self-hosted environment setup"""
        
        return f"""
        # Self-hosted setup
        git clone https://github.com/lumina-ai-inc/chunkr
        cd chunkr
        
        # Configure environment
        cp .env.example .env
        cp models.example.yaml models.yaml
        
        # Run Docker Compose
        docker compose -f {config['docker_compose']} up -d
        
        # Access
        Web UI: http://localhost:5173
        API: http://localhost:8000
        """
    
    def _setup_commercial_api(self, config):
        """Commercial API setup"""
        
        return f"""
        # Commercial API setup
        pip install chunkr-ai
        
        # Usage code
        from chunkr_ai import Chunkr
        
        chunkr = Chunkr(api_key="your_api_key_from_chunkr_ai")
        
        # API endpoint: {config['endpoint']}
        """
    
    def _setup_enterprise(self, config):
        """Enterprise environment setup"""
        
        return f"""
        # Enterprise environment setup
        # 1. Configure dedicated infrastructure
        # 2. Apply security settings
        # 3. Configure {config['scaling']} scaling
        # 4. Install {config['monitoring']} monitoring
        
        # Kubernetes deployment (example)
        kubectl apply -f k8s/chunkr-enterprise.yaml
        """

# Performance comparison and selection guide
deployment_guide = """
# Chunkr Deployment Guide

## 1. Development and Testing Phase
- **Recommended**: Open source self-hosting
- **Reason**: Free, customizable, for learning purposes
- **Limitations**: Basic models, no Excel support

## 2. Small-Scale Production
- **Recommended**: Commercial API
- **Reason**: No management overhead, advanced features, stability
- **Cost**: Usage-based billing

## 3. Large-Scale Production
- **Recommended**: Enterprise
- **Reason**: Dedicated support, customization, enhanced security
- **Features**: On-premises or dedicated cloud

## 4. Hybrid Approach
- **Development**: Open source local environment
- **Testing**: Validate with commercial API
- **Production**: Enterprise deployment
"""

print(deployment_guide)
```

## الاختبار الآلي والتحقق

### نص برمجي لاختبار التكامل

```bash
#!/bin/bash
# test-chunkr.sh

set -e

# Color definitions
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

echo "🚀 Chunkr environment test starting"
echo "=============================="

# 1. Check system requirements
log_info "Checking system information..."
echo "📱 OS: $(uname -s) $(uname -r)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'Docker not found')"
echo "📦 Docker Compose: $(docker compose version 2>/dev/null || echo 'Docker Compose not found')"

# 2. Clone and set up project
log_info "Setting up project..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -d ".git" ]; then
    log_info "Cloning Chunkr project..."
    git clone https://github.com/lumina-ai-inc/chunkr.git .
fi

# 3. Configure environment files
if [ ! -f ".env" ]; then
    log_info "Configuring environment file..."
    cp .env.example .env
fi

if [ ! -f "models.yaml" ]; then
    log_info "Creating model configuration file..."
    cp models.example.yaml models.yaml
fi

# 4. Check Docker environment
if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
    log_info "Testing Docker environment..."
    
    # Check GPU support
    if command -v nvidia-smi &> /dev/null; then
        log_info "NVIDIA GPU detected, running in GPU mode"
        COMPOSE_FILES="compose.yaml"
    elif [[ $(uname -s) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
        log_info "Apple Silicon detected, running in MAC ARM mode"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml -f compose.mac.yaml"
    else
        log_info "Running in CPU mode"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml"
    fi
    
    # Run Docker Compose
    log_info "Starting Chunkr services..."
    docker compose -f $COMPOSE_FILES up -d
    
    # Wait for services to be ready
    log_info "Waiting for service initialization..."
    sleep 30
    
    # Health check
    log_info "Checking service status..."
    for i in {1..10}; do
        if curl -s http://localhost:8000/health > /dev/null; then
            log_success "API server confirmed operational"
            break
        elif [ $i -eq 10 ]; then
            log_error "API server not responding"
            docker compose -f $COMPOSE_FILES logs api
        else
            echo "Waiting... ($i/10)"
            sleep 5
        fi
    done
    
    if curl -s http://localhost:5173 > /dev/null; then
        log_success "Web UI confirmed operational"
    else
        log_warning "Web UI not responding"
    fi
    
else
    log_warning "Docker not installed, running Python SDK tests only"
fi

# 5. Python SDK test
log_info "Testing Python SDK..."

# Create virtual environment
if [ ! -d "chunkr-env" ]; then
    python3 -m venv chunkr-env
fi

source chunkr-env/bin/activate

# Install SDK
pip install --upgrade pip
pip install chunkr-ai requests

# Create SDK test script
cat > test_chunkr_sdk.py << 'EOF'
#!/usr/bin/env python3
"""
Chunkr SDK feature tests
"""

import sys
import os
import tempfile
import requests

def test_imports():
    """Package import test"""
    print("📦 SDK import test...")
    
    try:
        from chunkr_ai import Chunkr
        print("  ✅ chunkr-ai package")
        return True
    except ImportError as e:
        print(f"  ❌ chunkr-ai import failed: {e}")
        return False

def test_local_api():
    """Local API connection test"""
    print("\n🔌 Local API connection test...")
    
    try:
        response = requests.get("http://localhost:8000/health", timeout=5)
        if response.status_code == 200:
            print("  ✅ Local API server responding")
            return True
        else:
            print(f"  ❌ API server error: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"  ❌ API connection failed: {e}")
        return False

def test_sample_document():
    """Sample document processing test"""
    print("\n📄 Sample document processing test...")
    
    # Create a simple text file
    sample_content = """
    # Test Document
    
    ## Overview
    This is a sample document for Chunkr testing.
    
    ## Content
    - Item 1: Layout analysis test
    - Item 2: OCR feature test
    - Item 3: Semantic chunking test
    
    ## Conclusion
    All features should work correctly.
    """
    
    try:
        # Create a temporary file
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            f.write(sample_content)
            temp_file = f.name
        
        print(f"  📝 Temporary file created: {temp_file}")
        
        # Use local API (test possible even without Cloud API key)
        if test_local_api():
            print("  💡 Local API available, running actual test")
            # In a real implementation, use the local API endpoint
            print("  ✅ Sample document processing test passed (simulated)")
        else:
            print("  💡 No local API, Cloud API key required")
            print("  ℹ️ Test possible after obtaining API key from chunkr.ai")
        
        # Clean up temporary file
        os.unlink(temp_file)
        
        return True
        
    except Exception as e:
        print(f"  ❌ Sample document processing failed: {e}")
        return False

def main():
    print("🧪 Chunkr SDK Test\n")
    
    tests = [
        ("Package Import", test_imports),
        ("Local API Connection", test_local_api),
        ("Sample Document Processing", test_sample_document)
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
    
    print(f"\n📊 Test results: {passed}/{len(tests)} passed")
    
    if passed == len(tests):
        print("\n🎉 All tests passed!")
        print("💡 You can now start processing documents with Chunkr.")
    else:
        print(f"\n⚠️ {len(tests)-passed} test(s) failed")
        print("💡 Check the failures and reconfigure your environment.")
    
    return passed == len(tests)

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# Run Python tests
log_info "Running SDK feature tests..."
if python test_chunkr_sdk.py; then
    log_success "SDK tests passed!"
else
    log_warning "Some SDK tests failed"
fi

# 6. Usage guide
echo ""
echo "🎯 Chunkr Usage Guide:"
echo "====================="
echo "1. Project directory:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. Access Web UI:"
echo "   http://localhost:5173"
echo ""
echo "3. API documentation:"
echo "   http://localhost:8000/docs"
echo ""
echo "4. Python SDK usage:"
echo "   source chunkr-env/bin/activate"
echo "   python"
echo '   >>> from chunkr_ai import Chunkr'
echo '   >>> chunkr = Chunkr(api_key="your_key_or_use_local")'
echo ""
echo "5. Stop services:"
echo "   docker compose -f $COMPOSE_FILES down"

echo ""
echo "💡 Key Features:"
echo "============="
echo "• Advanced layout analysis for accurate document structure detection"
echo "• Precise OCR + bounding boxes for text position tracking"
echo "• Semantic chunking for RAG system optimization"
echo "• Supports a wide range of formats: PDF, PPT, Word, Excel"
echo "• Flexible options: open source or commercial service"

log_success "Chunkr environment setup complete!"
echo "📁 Project location: $PROJECT_DIR"
echo "🚀 Start processing documents with document intelligence now!"
```

## خاتمة

Chunkr منصة تغيّر نموذج تطبيقات الذكاء الاصطناعي المستندة إلى المستندات. فيما يلي أبرز النتائج والقيم:

### الابتكارات الجوهرية

1. **فهم المستندات بذكاء**: تجاوز استخراج النص العادي للتقاط **البنية والمعنى والسياق**
2. **تحسين نظام RAG**: تقسيم دلالي يرفع **دقة الاسترجاع** ويحافظ على **السياق**
3. **دعم تنسيقات واسع**: جودة معالجة متسقة عبر PDF وPPT وWord وExcel
4. **بنية قابلة للتوسع**: تغطي **كل الأحجام** من التطوير حتى المؤسسات الكبرى

### التميز التقني

- **تحليل التخطيط المبني على الرؤية الحاسوبية**: يحدد بدقة **العلاقات البنيوية** بين الجداول والصور والمخططات البيانية
- **OCR الدقيق مع المربعات المحيطة**: يحفظ **المعلومات الموضعية والطباعية** للنص
- **استراتيجية التقسيم التكيفية**: **تقسيم محسّن** بحسب نوع المحتوى
- **تكامل LLM**: تكامل سلس مع نماذج الذكاء الاصطناعي المتعددة

### القيمة العملية

1. **البحث والأوساط الأكاديمية**: التحليل المنهجي واستخراج المعرفة من الأوراق البحثية والتقارير
2. **إدارة الوثائق المؤسسية**: التصنيف التلقائي واستخراج المعلومات الرئيسية من العقود والبيانات المالية
3. **إنتاج المحتوى**: تحويل المستندات المعقدة إلى بيانات جاهزة لنظم RAG
4. **المعالجة متعددة اللغات**: تحليل خاص بكل لغة ودعم الترجمة للمستندات العالمية

### منظومة سير العمل المفتوحة

- **خيارات نشر مرنة**: من الاستضافة الذاتية حتى المستوى المؤسسي
- **مجتمع مصدر مفتوح**: تطوير شفاف تحت رخصة AGPL-3.0
- **خدمة تجارية**: حلول مُدارة لبيئات الإنتاج
- **قابلية التوسع**: بنية سحابية أصلية تعتمد على Docker وKubernetes

### النظرة إلى الأمام

يُمكّن Chunkr أي شخص من بناء تطبيقات ذكاء وثائقي عالية الجودة. للمطورين والشركات التي تتعامل مع مستندات بلغات غير الإنجليزية، يوفر Chunkr دعم معالجة خاصاً بكل لغة، وواجهات API سهلة الوصول لسير عمل الذكاء الاصطناعي للمستندات المعقدة، وأساساً مفتوح المصدر فعّال من حيث التكلفة، ونماذج قابلة للتخصيص حسب النطاق.

حوّل مستودع المستندات لديك إلى قاعدة معرفية ذكية باستخدام Chunkr، وحقق أقصى أداء لنظم RAG الخاصة بك.

---

> **المراجع**
> - [مستودع Chunkr على GitHub](https://github.com/lumina-ai-inc/chunkr)
> - [الموقع الرسمي لـ Chunkr](https://chunkr.ai)
> - [توثيق Chunkr API](https://docs.chunkr.ai)
> - [دليل Python SDK](https://pypi.org/project/chunkr-ai/)
