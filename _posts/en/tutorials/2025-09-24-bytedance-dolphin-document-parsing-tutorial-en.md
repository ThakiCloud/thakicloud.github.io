---
title: "Complete Guide to ByteDance Dolphin: Advanced Document Image Parsing with Heterogeneous Anchor Prompting"
excerpt: "Learn how to use ByteDance Dolphin, a state-of-the-art multimodal document parsing model that combines layout analysis with element-specific parsing through innovative heterogeneous anchor prompting techniques."
seo_title: "ByteDance Dolphin Tutorial: Document Image Parsing Guide - Thaki Cloud"
seo_description: "Comprehensive tutorial on ByteDance Dolphin document parsing model. Learn installation, usage, and implementation of page-level and element-level parsing with practical examples."
date: 2025-09-24
categories:
  - tutorials
tags:
  - document-parsing
  - ocr
  - multimodal-ai
  - pdf-processing
  - layout-analysis
  - computer-vision
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/tutorials/bytedance-dolphin-document-parsing-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/bytedance-dolphin-document-parsing-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction to ByteDance Dolphin

ByteDance Dolphin (**Do**cument Image **P**arsing via **H**eterogeneous Anchor Prompt**in**g) represents a significant breakthrough in document image parsing technology. This innovative multimodal model follows an analyze-then-parse paradigm, addressing the complex challenges of parsing intertwined document elements such as text paragraphs, figures, formulas, and tables.

The model's architecture is built around a two-stage approach that first comprehensively analyzes the document layout and then efficiently parses individual elements in parallel. This methodology enables Dolphin to achieve remarkable performance across diverse document parsing tasks while maintaining superior efficiency through its lightweight architecture.

## Key Features and Innovations

### 🔄 Two-Stage Analyze-Then-Parse Approach

Dolphin's core innovation lies in its sophisticated two-stage methodology:

**Stage 1: Comprehensive Layout Analysis**
- Generates element sequences in natural reading order
- Identifies and categorizes document components
- Creates a structured understanding of document hierarchy

**Stage 2: Parallel Element Parsing**
- Utilizes heterogeneous anchors for different element types
- Employs task-specific prompts for optimal parsing
- Processes multiple elements simultaneously for efficiency

### 🧩 Heterogeneous Anchor Prompting

The model introduces heterogeneous anchor prompting, a novel technique that:
- Adapts prompting strategies based on element types (text, tables, formulas)
- Optimizes parsing accuracy for specific document components
- Maintains consistency across different document formats

### ⚡ Parallel Processing Architecture

Dolphin's parallel parsing mechanism delivers:
- Significant speed improvements over sequential processing
- Scalable batch processing capabilities
- Reduced computational overhead through efficient resource utilization

## Installation and Setup

### Prerequisites

Before installing Dolphin, ensure your system meets the following requirements:

- Python 3.8 or higher
- CUDA-compatible GPU (recommended for optimal performance)
- Sufficient RAM (minimum 8GB, 16GB+ recommended)
- Git and Git LFS for model downloading

### Step-by-Step Installation

**1. Clone the Repository**

```bash
git clone https://github.com/ByteDance/Dolphin.git
cd Dolphin
```

**2. Install Dependencies**

```bash
pip install -r requirements.txt
```

**3. Download Pre-trained Models**

You have two options for model acquisition:

**Option A: Original Model Format (Config-based)**

```bash
# Download from Google Drive or Baidu Yun
# Extract to ./checkpoints/ folder
mkdir -p ./checkpoints
# Place downloaded models in this directory
```

**Option B: Hugging Face Model Format**

```bash
# Install Git LFS if not already installed
git lfs install

# Clone the model repository
git clone https://huggingface.co/ByteDance/Dolphin ./hf_model

# Alternative: Use Hugging Face CLI
pip install huggingface_hub
huggingface-cli download ByteDance/Dolphin --local-dir ./hf_model
```

### Verification of Installation

Test your installation with a simple command:

```bash
python demo_page_hf.py --help
```

If the help message displays correctly, your installation is successful.

## Understanding Document Parsing Granularities

Dolphin supports two distinct parsing approaches, each designed for specific use cases:

### 📄 Page-Level Parsing

Page-level parsing processes entire document pages and outputs structured data in multiple formats:

**Output Formats:**
- **JSON**: Structured data with element coordinates and content
- **Markdown**: Human-readable format preserving document hierarchy
- **XML**: Hierarchical representation with detailed metadata

**Use Cases:**
- Document digitization projects
- Content management systems
- Academic paper processing
- Legal document analysis

### 🧩 Element-Level Parsing

Element-level parsing focuses on individual document components:

**Supported Element Types:**
- **Text Paragraphs**: OCR with layout preservation
- **Tables**: Structure recognition and data extraction
- **Formulas**: Mathematical expression parsing
- **Figures**: Caption and content analysis

**Use Cases:**
- Targeted data extraction
- Quality assurance workflows
- Specialized content processing
- Fine-grained document analysis

## Practical Tutorial: Page-Level Parsing

### Basic Page Parsing

Let's start with parsing a single document image:

**Using Hugging Face Framework:**

```bash
python demo_page_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/page_imgs/page_1.jpeg \
  --save_dir ./results
```

**Using Original Framework:**

```bash
python demo_page.py \
  --config ./config/Dolphin.yaml \
  --input_path ./demo/page_imgs/page_1.jpeg \
  --save_dir ./results
```

### Processing PDF Documents

Dolphin supports direct PDF processing:

```bash
python demo_page_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/page_imgs/document.pdf \
  --save_dir ./results
```

### Batch Processing Multiple Documents

For processing entire directories:

```bash
python demo_page_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/page_imgs \
  --save_dir ./results \
  --max_batch_size 8
```

### Understanding Output Structure

The parsed output includes several files:

```
results/
├── page_1/
│   ├── parsed_result.json      # Structured data
│   ├── parsed_result.md        # Markdown format
│   ├── layout_analysis.json    # Layout information
│   └── element_details/        # Individual elements
│       ├── table_1.html
│       ├── formula_1.latex
│       └── text_1.txt
```

**JSON Output Example:**

```json
{
  "page_info": {
    "width": 595,
    "height": 842,
    "elements_count": 15
  },
  "elements": [
    {
      "type": "text",
      "bbox": [50, 100, 500, 150],
      "content": "Introduction to Document Processing",
      "confidence": 0.98
    },
    {
      "type": "table",
      "bbox": [100, 200, 450, 350],
      "structure": {
        "rows": 3,
        "columns": 4
      },
      "data": [...]
    }
  ]
}
```

## Advanced Tutorial: Element-Level Parsing

### Table Processing

Extract structured data from table images:

```bash
python demo_element_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/element_imgs/table_1.jpeg \
  --element_type table
```

**Table Output Features:**
- Cell-level content extraction
- Row and column structure preservation
- HTML and CSV format generation
- Merged cell detection

### Formula Recognition

Parse mathematical expressions and equations:

```bash
python demo_element_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/element_imgs/formula.jpeg \
  --element_type formula
```

**Formula Output Formats:**
- LaTeX representation
- MathML format
- Plain text approximation
- Rendered image verification

### Text Paragraph Extraction

Process text blocks with layout preservation:

```bash
python demo_element_hf.py \
  --model_path ./hf_model \
  --input_path ./demo/element_imgs/paragraph.jpg \
  --element_type text
```

**Text Processing Features:**
- Font style recognition
- Paragraph structure preservation
- Multi-language support
- Reading order maintenance

## Performance Optimization Strategies

### Batch Size Optimization

Adjust batch sizes based on your hardware capabilities:

```bash
# For high-end GPUs (24GB+ VRAM)
--max_batch_size 16

# For mid-range GPUs (8-16GB VRAM)
--max_batch_size 8

# For limited resources (4-8GB VRAM)
--max_batch_size 4
```

### Memory Management

Monitor memory usage during processing:

```bash
# Enable verbose logging
python demo_page_hf.py \
  --model_path ./hf_model \
  --input_path ./documents \
  --save_dir ./results \
  --verbose \
  --max_batch_size 8
```

### GPU Utilization

Optimize GPU usage for better performance:

```python
import torch

# Check GPU availability
if torch.cuda.is_available():
    print(f"GPU: {torch.cuda.get_device_name()}")
    print(f"Memory: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}GB")
```

## Integration with Existing Workflows

### Python Script Integration

Create custom processing scripts:

```python
import os
import json
from pathlib import Path

def process_documents(input_dir, output_dir):
    """
    Process all documents in a directory using Dolphin
    """
    input_path = Path(input_dir)
    output_path = Path(output_dir)
    
    # Ensure output directory exists
    output_path.mkdir(parents=True, exist_ok=True)
    
    for doc_file in input_path.glob("*.{pdf,jpg,jpeg,png}"):
        print(f"Processing: {doc_file.name}")
        
        # Run Dolphin processing
        os.system(f"""
            python demo_page_hf.py \
              --model_path ./hf_model \
              --input_path "{doc_file}" \
              --save_dir "{output_path}"
        """)
        
        print(f"Completed: {doc_file.name}")

# Usage
process_documents("./input_docs", "./processed_results")
```

### API Wrapper Development

Create a simple API wrapper for web integration:

```python
from flask import Flask, request, jsonify
import subprocess
import json

app = Flask(__name__)

@app.route('/parse_document', methods=['POST'])
def parse_document():
    """
    API endpoint for document parsing
    """
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    # Save uploaded file
    filepath = f"./temp/{file.filename}"
    file.save(filepath)
    
    # Process with Dolphin
    result = subprocess.run([
        'python', 'demo_page_hf.py',
        '--model_path', './hf_model',
        '--input_path', filepath,
        '--save_dir', './temp/results'
    ], capture_output=True, text=True)
    
    # Return results
    with open('./temp/results/parsed_result.json', 'r') as f:
        parsed_data = json.load(f)
    
    return jsonify(parsed_data)

if __name__ == '__main__':
    app.run(debug=True)
```

## Troubleshooting Common Issues

### Memory Errors

**Problem**: Out of memory errors during processing

**Solutions:**
1. Reduce batch size: `--max_batch_size 2`
2. Process smaller images: Resize images to 1024px max width
3. Use CPU processing: Set `CUDA_VISIBLE_DEVICES=""`

### Model Loading Issues

**Problem**: Models fail to load properly

**Solutions:**
1. Verify model path: Check `./hf_model` directory exists
2. Re-download models: Delete and re-clone the model repository
3. Check dependencies: `pip install -r requirements.txt --upgrade`

### Poor Parsing Quality

**Problem**: Inaccurate parsing results

**Solutions:**
1. Improve image quality: Use high-resolution scans (300+ DPI)
2. Preprocess images: Ensure proper contrast and orientation
3. Validate input format: Use supported formats (JPEG, PNG, PDF)

### Performance Issues

**Problem**: Slow processing speeds

**Solutions:**
1. Enable GPU acceleration: Ensure CUDA is properly installed
2. Optimize batch sizes: Find the optimal batch size for your hardware
3. Use TensorRT: Consider TensorRT-LLM for production deployments

## Advanced Features and Extensions

### TensorRT-LLM Acceleration

For production deployments, consider TensorRT-LLM integration:

```bash
# Install TensorRT-LLM (requires NVIDIA GPU)
pip install tensorrt-llm

# Convert model to TensorRT format
python convert_to_tensorrt.py \
  --model_path ./hf_model \
  --output_path ./tensorrt_model
```

### vLLM Integration

Accelerate inference with vLLM:

```bash
# Install vLLM
pip install vllm

# Use vLLM backend
python demo_page_vllm.py \
  --model_path ./hf_model \
  --input_path ./documents \
  --save_dir ./results
```

### Multi-page PDF Processing

Process complete documents with multiple pages:

```python
import fitz  # PyMuPDF
from pathlib import Path

def process_multipage_pdf(pdf_path, output_dir):
    """
    Process multi-page PDF documents
    """
    doc = fitz.open(pdf_path)
    
    for page_num in range(len(doc)):
        page = doc.load_page(page_num)
        pix = page.get_pixmap(matrix=fitz.Matrix(2, 2))  # 2x scaling
        
        # Save page as image
        page_image = f"{output_dir}/page_{page_num + 1}.png"
        pix.save(page_image)
        
        # Process with Dolphin
        os.system(f"""
            python demo_page_hf.py \
              --model_path ./hf_model \
              --input_path "{page_image}" \
              --save_dir "{output_dir}/page_{page_num + 1}"
        """)
```

## Best Practices and Recommendations

### Input Preparation

1. **Image Quality**: Use high-resolution images (300+ DPI)
2. **Format Consistency**: Prefer PDF for multi-page documents
3. **Preprocessing**: Ensure proper orientation and contrast

### Processing Workflow

1. **Start Small**: Test with single pages before batch processing
2. **Monitor Resources**: Watch memory and GPU utilization
3. **Validate Results**: Always review parsing accuracy

### Production Deployment

1. **Containerization**: Use Docker for consistent environments
2. **Scaling**: Implement horizontal scaling for high-volume processing
3. **Monitoring**: Set up logging and performance monitoring

## Comparison with Other Solutions

### Dolphin vs. Traditional OCR

| Feature | Dolphin | Traditional OCR |
|---------|---------|-----------------|
| Layout Understanding | ✅ Advanced | ❌ Limited |
| Table Recognition | ✅ Excellent | ⚠️ Basic |
| Formula Parsing | ✅ Native Support | ❌ Not Supported |
| Multi-language | ✅ Built-in | ⚠️ Language-specific |
| Processing Speed | ✅ Parallel | ❌ Sequential |

### Dolphin vs. Other AI Models

| Aspect | Dolphin | Nougat | GOT-OCR |
|--------|---------|--------|---------|
| Architecture | Two-stage | End-to-end | Single-stage |
| Element Types | All types | Academic papers | General text |
| Customization | High | Medium | Low |
| Performance | Excellent | Good | Variable |

## Future Developments and Roadmap

### Upcoming Features

1. **Enhanced Multi-language Support**: Expanded language coverage
2. **Real-time Processing**: Live document parsing capabilities
3. **Custom Model Training**: Domain-specific fine-tuning options
4. **Cloud Integration**: Seamless cloud service deployment

### Community Contributions

The Dolphin project welcomes community contributions:

1. **Bug Reports**: Submit issues for model improvements
2. **Feature Requests**: Propose new functionality
3. **Performance Optimizations**: Share efficiency improvements
4. **Documentation**: Help improve tutorials and guides

## Conclusion

ByteDance Dolphin represents a significant advancement in document image parsing technology. Its innovative two-stage approach, combined with heterogeneous anchor prompting, delivers exceptional performance across diverse document types. The model's parallel processing capabilities and support for both page-level and element-level parsing make it an invaluable tool for modern document processing workflows.

Whether you're working on document digitization projects, content management systems, or specialized data extraction tasks, Dolphin provides the accuracy, efficiency, and flexibility needed for production-scale deployments. The comprehensive API support and multiple output formats ensure seamless integration with existing systems.

As the field of document AI continues to evolve, Dolphin's architecture and methodologies position it as a leading solution for complex document parsing challenges. The active development community and continuous improvements promise even more powerful capabilities in future releases.

### Getting Started Today

Ready to implement Dolphin in your projects? Follow these next steps:

1. **Download and Install**: Set up Dolphin using the installation guide
2. **Test with Samples**: Process sample documents to understand capabilities
3. **Integrate Gradually**: Start with pilot projects before full deployment
4. **Monitor and Optimize**: Continuously improve processing workflows
5. **Join the Community**: Contribute to the project's ongoing development

For additional support and resources, visit the [official GitHub repository](https://github.com/bytedance/Dolphin) and explore the comprehensive documentation and community discussions.

