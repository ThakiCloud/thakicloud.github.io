---
title: "dots.ocr: SOTA Multilingual Document Parsing with 1.7B Parameters - Complete Analysis"
excerpt: "How to implement multilingual document layout analysis and OCR in a single vision-language model using dots.ocr, released by RedNote."
seo_title: "dots.ocr Multilingual Document Parsing Model Complete Analysis - Thaki Cloud"
seo_description: "In-depth analysis of dots.ocr architecture, benchmark results, and practical usage. A 1.7B parameter VLM achieving SOTA performance on OmniDocBench."
date: 2025-08-06
last_modified_at: 2025-08-06
categories:
  - datasets
  - llmops
tags:
  - dots.ocr
  - document-parsing
  - multilingual-ocr
  - vision-language-model
  - document-ai
  - layout-detection
  - rednote
  - omnidocbench
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/datasets/dots-ocr-multilingual-document-parsing-guide/"
reading_time: true
lang: en
published: true
---

⏱️ **Estimated reading time**: 8 min

## Introduction

A significant shift is taking place in the field of document parsing. Traditionally, document layout detection and text recognition required multiple independent models chained together in a pipeline. However, **dots.ocr**, released by the RedNote research team, integrates all of these tasks into a single vision-language model (VLM) while achieving state-of-the-art (SOTA) performance.

A particularly notable aspect is that, despite having a relatively small size of 1.7B parameters, the model delivers performance comparable to much larger models such as Doubao-1.5 and Gemini 2.5 Pro. This makes it an excellent example of practical AI system design that pursues both efficiency and performance simultaneously.

## Core Features of dots.ocr

### 1. The Innovation of a Unified Architecture

The most significant innovation in dots.ocr is that a **single vision-language model** performs all of the following tasks concurrently:

- **Layout detection**: Identifying regions containing text, tables, images, formulas, and other elements
- **Text recognition**: Accurate text extraction via OCR
- **Reading order**: Ordering elements in the sequence a human would read
- **Format conversion**: Producing output in appropriate formats such as Markdown, HTML, and LaTeX

What once required a complex multi-model pipeline can now be switched between different task modes by simply changing a prompt.

### 2. Strong Multilingual Support

dots.ocr demonstrates a decisive advantage in multilingual document parsing, including low-resource languages:

```text
Supported languages (examples):
- English
- Chinese
- Tibetan
- Dutch
- Kannada
- Russian
```

This capability is highly valuable for organizations that need to process documents written in a variety of languages across a global business environment.

## Benchmark Performance Analysis

### OmniDocBench Results

dots.ocr achieved the following SOTA results on OmniDocBench:

| Task Area | dots.ocr Performance | Comparison |
|-----------|---------------------|------------|
| Text recognition | SOTA | Existing OCR models |
| Table recognition | SOTA | Specialized table recognition models |
| Reading order | SOTA | Layout analysis models |
| Formula recognition | On par with Doubao-1.5 / Gemini 2.5 Pro | Large-scale VLMs |

### Multilingual Performance Advantage

On the model's own multilingual benchmark, **dots.ocr-bench**, it demonstrated a decisive lead in both layout detection and content recognition. Unlike existing models that were primarily optimized for English and Chinese, this result reflects strong generalization capability across a wide range of languages.

## Implementation and Usage

### 1. Environment Setup

The following steps configure the environment required to use dots.ocr:

```bash
# Download and register the model
python3 tools/download_model.py
export hf_model_path=./weights/DotsOCR
export PYTHONPATH=$(dirname "$hf_model_path"):$PYTHONPATH

# vLLM server setup (note: directory names must not contain dots)
sed -i '/^from vllm\.entrypoints\.cli\.main import main$/a\
from DotsOCR import modeling_dots_ocr_vllm' `which vllm`
```

### 2. Starting the vLLM Server

```bash
# Launch a GPU memory-optimized vLLM server
CUDA_VISIBLE_DEVICES=0 vllm serve ${hf_model_path} \
  --tensor-parallel-size 1 \
  --gpu-memory-utilization 0.95 \
  --chat-template-content-format string \
  --served-model-name model \
  --trust-remote-code
```

### 3. Using Different Parsing Modes

The strength of dots.ocr lies in its ability to handle diverse tasks with a single model:

#### Full Layout Analysis and Recognition
```bash
# Parse an image file
python3 dots_ocr/parser.py demo/demo_image1.jpg

# Parse a PDF file (increase thread count for large PDFs)
python3 dots_ocr/parser.py demo/demo_pdf1.pdf --num_thread 64
```

#### Layout Detection Only
```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_layout_only_en
```

#### Text Extraction Only (excluding headers and footers)
```bash
python3 dots_ocr/parser.py demo/demo_image1.jpg --prompt prompt_ocr
```

#### Analysis of a Specific Region
```bash
# Analyze only a specified region using a bounding box
python3 dots_ocr/parser.py demo/demo_image1.jpg \
  --prompt prompt_grounding_ocr \
  --bbox 163 241 1536 705
```

### 4. Usage with HuggingFace Transformers

If you prefer HuggingFace Transformers over vLLM:

```python
import torch
from transformers import AutoModelForCausalLM, AutoProcessor
from qwen_vl_utils import process_vision_info

# Load the model
model_path = "./weights/DotsOCR"
model = AutoModelForCausalLM.from_pretrained(
    model_path,
    attn_implementation="flash_attention_2",
    torch_dtype=torch.bfloat16,
    device_map="auto",
    trust_remote_code=True
)
processor = AutoProcessor.from_pretrained(model_path, trust_remote_code=True)

# Define the prompt
prompt = """Please output the layout information from the PDF image, 
including each layout element's bbox, its category, and the corresponding 
text content within the bbox.

1. Bbox format: [x1, y1, x2, y2]
2. Layout Categories: ['Caption', 'Footnote', 'Formula', 'List-item', 
   'Page-footer', 'Page-header', 'Picture', 'Section-header', 'Table', 'Text', 'Title']
3. Text Extraction & Formatting Rules:
   - Picture: Text field omitted
   - Formula: LaTeX format
   - Table: HTML format
   - Others: Markdown format
4. Output: Single JSON object sorted by reading order
"""

# Construct messages and run inference
messages = [{
    "role": "user",
    "content": [
        {"type": "image", "image": "demo/demo_image1.jpg"},
        {"type": "text", "text": prompt}
    ]
}]

# Run inference
text = processor.apply_chat_template(messages, tokenize=False, add_generation_prompt=True)
image_inputs, video_inputs = process_vision_info(messages)
inputs = processor(text=[text], images=image_inputs, videos=video_inputs, 
                  padding=True, return_tensors="pt").to("cuda")

generated_ids = model.generate(**inputs, max_new_tokens=24000)
output_text = processor.batch_decode(
    [out_ids[len(in_ids):] for in_ids, out_ids in zip(inputs.input_ids, generated_ids)],
    skip_special_tokens=True, clean_up_tokenization_spaces=False
)
```

## Output Analysis

dots.ocr produces structured results in the following forms:

### 1. JSON Structured Data
- **Bounding boxes**: Precise coordinate positions for each element
- **Categories**: Automatic classification into 11 layout categories
- **Text content**: Extracted text per element

### 2. Markdown Conversion
- A Markdown file concatenating the text of all detected cells
- A version excluding headers and footers, provided for benchmark compatibility

### 3. Visualization Output
- The original image with detected layout bounding boxes overlaid

## Performance Optimization and Considerations

### Recommendations for Optimal Performance

#### Image Resolution Optimization
```bash
# DPI setting for PDF parsing (recommended: 200 DPI)
# Optimal resolution: 11,289,600 pixels or fewer
```

#### GPU Memory Optimization
```bash
# Adjust GPU memory utilization when starting the vLLM server
--gpu-memory-utilization 0.95  # Adjust as needed
```

### Known Limitations

#### 1. Complex Document Elements
- **Highly complex tables**: Not yet handled perfectly
- **Formulas**: Accuracy is limited for intricate mathematical expressions
- **Images**: Images embedded within documents are not currently parsed

#### 2. Conditions That Cause Parsing Failures
- When the character-to-pixel ratio is excessively high
- Infinite repetition in output triggered by consecutive special characters (e.g., `...`, `___`)

#### 3. Using Alternative Prompts
If you encounter issues, try the following prompts:
- `prompt_layout_only_en`: Layout detection only
- `prompt_ocr`: Text extraction only
- `prompt_grounding_ocr`: Analysis of a specific region

## Practical Use Cases

### 1. Multilingual Corporate Document Management
```python
# Batch processing of multilingual contracts and reports
for document in multilingual_documents:
    result = parse_document(document, language="auto")
    structured_data = extract_structured_info(result)
    store_to_database(structured_data)
```

### 2. Building an Academic Paper Database
```python
# Automated parsing of papers containing formulas and tables
papers = load_academic_papers()
for paper in papers:
    layout_info = dots_ocr.parse(paper, mode="academic")
    formulas = extract_latex_formulas(layout_info)
    tables = extract_html_tables(layout_info)
    create_searchable_index(formulas, tables)
```

### 3. Legal Document Digitization
```python
# Structuring complex legal documents
legal_docs = load_legal_documents()
for doc in legal_docs:
    parsed = dots_ocr.parse(doc, preserve_reading_order=True)
    sections = identify_legal_sections(parsed)
    create_legal_knowledge_base(sections)
```

## Future Development Directions

The RedNote research team has outlined the following planned improvements:

### Short-term Goals
- **Improved accuracy for table and formula parsing**
- **Performance optimization for large-scale PDF processing**
- **Adding image parsing capability within documents**

### Long-term Vision
- **Universal recognition model**: Integrating general detection, image captioning, and OCR
- **More capable and efficient models**: Improving both performance and efficiency simultaneously
- **Community collaboration**: Advancement through open-source contributions

## Conclusion

dots.ocr represents a paradigm shift in the field of document parsing. With a relatively compact size of 1.7B parameters, it achieves SOTA performance while demonstrating the viability of practical deployment.

Three core strengths stand out in particular: **a single model that handles diverse tasks**, **strong multilingual support**, and an **efficient architecture**. Together, these point to broad applicability in real-world production environments.

dots.ocr holds significant promise for improving operational efficiency across many domains, including multilingual document processing, academic material digitization, and legal document management. With a clear roadmap for future improvement, the model is expected to grow into an even more capable tool through continued development.

---

**References**
- [dots.ocr GitHub Repository](https://github.com/rednote-hilab/dots.ocr)
- [HuggingFace Model Hub](https://huggingface.co/models?search=dots.ocr)
- [OmniDocBench Official Documentation](https://omnidocbench.github.io/)
