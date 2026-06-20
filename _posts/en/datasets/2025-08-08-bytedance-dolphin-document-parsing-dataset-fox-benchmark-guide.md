---
title: "ByteDance Dolphin Document Image Parsing: Fox Dataset and Benchmark Complete Analysis"
excerpt: "A detailed analysis of ByteDance's Dolphin project Fox dataset and benchmark, including the Analyze-then-Parse paradigm from ACL 2025 and a large-scale dataset with 30M+ samples."
seo_title: "ByteDance Dolphin Fox Dataset Analysis - Document Image Parsing Benchmark Guide - Thaki Cloud"
seo_description: "Complete analysis of ByteDance Dolphin's Fox dataset and document image parsing benchmark. Covers the ACL 2025 paper, the Analyze-then-Parse paradigm, and the 30M-sample dataset structure."
date: 2025-08-08
last_modified_at: 2025-08-08
categories:
  - datasets
  - research
tags:
  - dolphin
  - bytedance
  - document-parsing
  - fox-dataset
  - acl-2025
  - multimodal
  - vision-language-model
  - ocr
  - document-understanding
  - benchmark
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/en/datasets/bytedance-dolphin-document-parsing-dataset-fox-benchmark-guide/"
reading_time: true
lang: en
published: true
---

⏱️ **Estimated reading time**: 18 min

## Introduction

Document image parsing is a core AI technology for extracting structured information from scanned documents, PDFs, or photographed pages. ByteDance's Dolphin project proposes an innovative approach in this space, and building on research published at [ACL 2025](https://arxiv.org/abs/2505.14059), the team has released the Fox dataset and benchmark.

This article provides a thorough analysis of Dolphin's core techniques together with the large-scale dataset the researchers constructed, with particular focus on the structure and practical use of the Fox-Page benchmark.

## Dolphin Project Overview

### 🎯 Core Idea: The Analyze-then-Parse Paradigm

[Dolphin](https://github.com/bytedance/Dolphin) adopts an "Analyze-then-Parse" approach that sets it apart from conventional document parsing methods.

#### Limitations of Existing Methods

```python
# Conventional approach: specialized model pipeline
traditional_pipeline = {
    "layout_detection": "YOLO/Faster R-CNN",
    "ocr_engine": "Tesseract/PaddleOCR", 
    "table_extraction": "TableNet/CascadeTabNet",
    "formula_recognition": "Im2Latex/InftyReader"
}
# Problems: integration overhead, lack of consistency, high complexity
```

```python
# Conventional approach: autoregressive generation
autoregressive_approach = {
    "input": "document_image",
    "output": "sequential_text_generation",
    "problem": "layout_structure_degradation"
}
# Problems: loss of layout structure, reduced efficiency
```

#### Dolphin's Innovative Approach

```python
# Dolphin: two-stage Analyze-then-Parse paradigm
dolphin_paradigm = {
    "stage_1": {
        "task": "layout_analysis",
        "output": "element_sequence_in_reading_order",
        "elements": ["text", "table", "figure", "formula"]
    },
    "stage_2": {
        "task": "parallel_element_parsing", 
        "method": "heterogeneous_anchor_prompting",
        "efficiency": "parallel_processing"
    }
}
```

### 🏗️ Model Architecture

Dolphin is built on a Vision-Encoder-Decoder structure:

#### Vision Encoder
- **Backbone**: Swin Transformer
- **Function**: Extracting visual features from document images
- **Resolution**: Multi-scale processing supported

#### Text Decoder
- **Base**: MBart architecture
- **Languages**: Chinese and English supported simultaneously
- **Vocabulary size**: 32K tokens

#### Prompt-based Interface
```python
# Heterogeneous anchor prompting example
prompts = {
    "layout_analysis": "Analyze the layout and generate element sequence:",
    "table_parsing": "Parse the table content in the red box:",
    "formula_recognition": "Recognize the mathematical formula in the blue box:",
    "text_extraction": "Extract text content from the green box:"
}
```

## Fox Dataset: Detailed Analysis

### 📊 Dataset Composition

The ByteDance research team built a large-scale multi-granularity dataset for training Dolphin.

#### Overall Dataset Scale
```yaml
dataset_statistics:
  total_samples: 30_000_000+
  granularity_levels:
    - page_level: "full-page parsing"
    - element_level: "individual element parsing"
  
  task_distribution:
    layout_analysis: 8_500_000
    table_extraction: 7_200_000  
    formula_recognition: 5_800_000
    text_recognition: 8_500_000
```

#### Fox-Page Benchmark Characteristics

Fox-Page is a high-quality subset manually refined from the original Fox dataset.

```yaml
fox_page_benchmark:
  release_date: "2025-07-10"
  quality: "manually_refined"
  purpose: "evaluation_benchmark"
  
  download_links:
    baidu_yun: "https://pan.baidu.com/..."
    google_drive: "https://drive.google.com/..."
  
  characteristics:
    diversity: "diverse document types"
    complexity: "complex layout structures"
    quality: "expert-verified"
```

### 🔍 Data Category Analysis

#### 1. Academic Papers
```python
academic_papers = {
    "sources": ["arXiv", "ACL", "NeurIPS", "ICLR"],
    "elements": {
        "multi_column_text": "two- and three-column text",
        "complex_tables": "statistical tables, results comparison tables",
        "mathematical_formulas": "inline and display formulas",
        "figures_with_captions": "graphs, diagrams"
    },
    "challenges": [
        "dense_layout",
        "interleaved_elements", 
        "scientific_notation"
    ]
}
```

#### 2. Business Documents
```python
business_documents = {
    "types": ["invoices", "reports", "presentations"],
    "layouts": {
        "structured_forms": "form-based documents",
        "mixed_content": "text and chart combinations",
        "branded_headers": "logos and header information"
    },
    "extraction_targets": [
        "key_value_pairs",
        "financial_data",
        "contact_information"
    ]
}
```

#### 3. Educational Materials
```python
educational_materials = {
    "categories": ["textbooks", "worksheets", "exams"],
    "special_elements": {
        "question_answer_pairs": "Q&A format",
        "step_by_step_solutions": "step-by-step solutions",
        "mixed_languages": "mixed multilingual content"
    },
    "complexity_factors": [
        "handwritten_annotations",
        "geometric_diagrams",
        "chemical_formulas"
    ]
}
```

### 📈 Benchmark Performance Metrics

#### Page-level Evaluation Metrics
```python
page_level_metrics = {
    "structure_accuracy": {
        "description": "layout structure accuracy",
        "calculation": "correct_elements / total_elements",
        "weight": 0.3
    },
    "content_fidelity": {
        "description": "content fidelity", 
        "measures": ["BLEU", "ROUGE", "Edit Distance"],
        "weight": 0.4
    },
    "reading_order": {
        "description": "reading order accuracy",
        "metric": "sequence_alignment_score", 
        "weight": 0.3
    }
}
```

#### Element-level Evaluation Metrics
```python
element_level_metrics = {
    "table_extraction": {
        "cell_accuracy": "per-cell accuracy",
        "structure_score": "table structure score", 
        "format_preservation": "degree of format preservation"
    },
    "formula_recognition": {
        "latex_accuracy": "LaTeX syntax accuracy",
        "semantic_correctness": "semantic correctness",
        "rendering_quality": "rendering quality"
    },
    "text_extraction": {
        "character_accuracy": "character-level accuracy",
        "word_accuracy": "word-level accuracy", 
        "layout_preservation": "layout preservation"
    }
}
```

## Practical Usage Guide

### 🚀 Using the Dolphin Model

#### Installation and Setup

```bash
# Clone the repository
git clone https://github.com/bytedance/Dolphin.git
cd Dolphin

# Install dependencies
pip install -r requirements.txt

# Download the model (HuggingFace approach)
git lfs install
git clone https://huggingface.co/ByteDance/Dolphin ./hf_model
```

#### Page-level Parsing Example

```python
# Usage example for demo_page_hf.py
import argparse
from pathlib import Path

# Process a single document image
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/academic_paper.jpeg \
    --save_dir ./results

# Process a PDF document
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/business_report.pdf \
    --save_dir ./results

# Batch processing (entire directory)
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs \
    --save_dir ./results \
    --max_batch_size 16
```

#### Element-level Parsing Example

```python
# Table extraction
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/complex_table.jpeg \
    --element_type table

# Formula recognition
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/math_formula.jpeg \
    --element_type formula

# Text paragraph extraction
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/text_paragraph.jpg \
    --element_type text
```

### 📊 Performance Optimization Tips

#### TensorRT-LLM Acceleration (added 2025.06.30)

```bash
# Install TensorRT-LLM
pip install tensorrt-llm

# Convert the model
python convert_to_tensorrt.py \
    --model_path ./hf_model \
    --output_dir ./tensorrt_model \
    --precision fp16

# Run accelerated inference
python demo_page_tensorrt.py \
    --model_path ./tensorrt_model \
    --input_path ./test_images
```

#### vLLM Acceleration (added 2025.06.27)

```bash
# Install vLLM
pip install vllm

# Start the vLLM server
python -m vllm.entrypoints.openai.api_server \
    --model ./hf_model \
    --tensor-parallel-size 2 \
    --dtype half

# Call from a client
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "ByteDance/Dolphin",
        "messages": [{"role": "user", "content": "Parse this document"}]
    }'
```

### 🔧 Building a Custom Dataset

#### Data Preparation Guidelines

```python
# Custom dataset structure
custom_dataset = {
    "images": {
        "format": ["JPEG", "PNG", "PDF"],
        "resolution": "minimum 300 DPI recommended",
        "quality": "high-resolution, sharp images"
    },
    "annotations": {
        "layout": {
            "bounding_boxes": "bounding box for each element",
            "element_types": ["text", "table", "figure", "formula"],
            "reading_order": "natural reading order"
        },
        "content": {
            "ground_truth": "accurate text content", 
            "markup": "structured markup (HTML/Markdown)",
            "latex": "LaTeX representation of formulas"
        }
    }
}
```

#### Annotation Guidelines

```yaml
annotation_guidelines:
  layout_analysis:
    text_blocks:
      - "Distinguish paragraphs, headings, and captions"
      - "Assign sequence numbers that reflect reading order"
    
    tables:
      - "Distinguish header rows from data rows"
      - "Include information on merged cells"
      - "Link table captions to tables"
    
    figures:
      - "Images, charts, and diagrams"
      - "Relationship between figure and its caption"
      - "Reference number information"
    
    formulas:
      - "Distinguish inline from display formulas"
      - "Accurate LaTeX representation"
      - "Consistent use of variables and symbols"

  quality_control:
    consistency_checks:
      - "Style consistency within the same document"
      - "Unified terminology and notation"
    
    accuracy_validation:
      - "Compare OCR output with source"
      - "Verify formula rendering"
      - "Confirm table structure accuracy"
```

## Comparison with Other Datasets

### 📋 Comparison of Major Document Understanding Benchmarks

| Dataset | Scale | Characteristics | Limitations |
|---------|-------|-----------------|-------------|
| **Fox-Page** | Refined, high quality | Multilingual, complex layouts | Relatively smaller size |
| DocVQA | 50K+ | VQA format | Limited to question-answer pairs |
| ChartQA | 20K+ | Chart-focused | Lacks non-chart elements |
| PubLayNet | 360K+ | Layout-centric | Limited content extraction |
| TableBank | 417K+ | Table-focused | Tables only |

### 🎯 What Sets the Dolphin Fox Dataset Apart

#### 1. Multi-Granularity Support
```python
multi_granularity = {
    "page_level": {
        "task": "understanding full document structure",
        "output": "JSON + Markdown",
        "applications": ["document digitization", "automatic summarization"]
    },
    "element_level": {
        "task": "precise extraction of individual elements", 
        "output": "structured data",
        "applications": ["data mining", "information retrieval"]
    }
}
```

#### 2. Grounded in Real-World Scenarios
```python
real_world_scenarios = {
    "academic_research": {
        "documents": "arXiv papers, conference proceedings",
        "challenges": "complex formulas, multi-column layouts"
    },
    "business_intelligence": {
        "documents": "financial statements, business reports",
        "challenges": "table structures, chart interpretation"
    },
    "education_technology": {
        "documents": "textbooks, exam questions",
        "challenges": "multilingual content, handwriting"
    }
}
```

#### 3. Comprehensive Evaluation Metrics
```python
comprehensive_evaluation = {
    "structure_preservation": "preservation of layout structure",
    "content_accuracy": "content accuracy",
    "efficiency_metrics": "processing speed and memory usage",
    "robustness_testing": "stability across diverse conditions"
}
```

## Research and Development Use Cases

### 🔬 Academic Research Applications

#### 1. Document Understanding Model Development
```python
research_applications = {
    "baseline_comparison": {
        "purpose": "benchmarking new model performance",
        "metrics": "Fox-Page benchmark scores",
        "advantage": "standardized evaluation environment"
    },
    "ablation_studies": {
        "components": ["vision_encoder", "text_decoder", "prompting"],
        "methodology": "per-component contribution analysis"
    },
    "cross_lingual_analysis": {
        "languages": ["Chinese", "English", "Mixed"],
        "research_questions": "analysis of performance differences by language"
    }
}
```

#### 2. Validating New Techniques
```python
technique_validation = {
    "anchor_prompting": {
        "hypothesis": "heterogeneous anchors improve performance",
        "experiment": "comparison experiments with and without prompts"
    },
    "parallel_processing": {
        "hypothesis": "parallel processing improves efficiency",
        "measurement": "processing time and memory usage"
    }
}
```

### 🏭 Industrial Applications

#### 1. Digital Transformation Projects
```python
digital_transformation = {
    "document_digitization": {
        "scope": "digitizing large-scale document archives",
        "pipeline": [
            "scan / photograph",
            "Dolphin parsing",
            "structured data storage",
            "search indexing"
        ]
    },
    "automated_processing": {
        "workflows": [
            "automated invoice processing",
            "contract information extraction", 
            "automated report summarization"
        ]
    }
}
```

#### 2. Knowledge Management Systems
```python
knowledge_management = {
    "academic_libraries": {
        "task": "automatic extraction of paper metadata",
        "benefits": "improved classification and search accuracy"
    },
    "corporate_archives": {
        "task": "building corporate document knowledge bases",
        "benefits": "providing information to support decision-making"
    }
}
```

## Advanced Usage and Extension

### 🛠️ Model Fine-tuning Guide

#### 1. Domain-specific Fine-tuning
```python
# Medical document fine-tuning example
medical_domain_config = {
    "data_preparation": {
        "medical_reports": "diagnostic reports, prescriptions",
        "terminology": "adding medical terminology dictionaries",
        "privacy": "masking personally identifiable information"
    },
    "training_config": {
        "learning_rate": 1e-5,
        "batch_size": 8,
        "epochs": 10,
        "special_tokens": ["<MEDICAL>", "<PRESCRIPTION>", "<DIAGNOSIS>"]
    }
}
```

#### 2. Multilingual Extension
```python
# Korean language extension example
korean_extension = {
    "tokenizer_expansion": {
        "korean_vocab": "adding Korean vocabulary",
        "hanja_support": "supporting Chinese character notation",
        "mixed_script": "processing Korean-English mixed documents"
    },
    "dataset_creation": {
        "korean_documents": [
            "official documents", "academic papers", "news articles", "textbooks"
        ],
        "annotation_guidelines": "reflecting Korean language characteristics"
    }
}
```

### 📊 Performance Monitoring and Optimization

#### 1. Real-time Performance Tracking
```python
# Performance monitoring script
import time
import psutil
import torch

class PerformanceMonitor:
    def __init__(self):
        self.start_time = None
        self.memory_usage = []
        
    def start_monitoring(self):
        self.start_time = time.time()
        self.memory_usage = []
        
    def log_metrics(self, step, accuracy):
        current_memory = psutil.virtual_memory().used / 1024**3  # GB
        elapsed_time = time.time() - self.start_time
        
        metrics = {
            "step": step,
            "accuracy": accuracy,
            "memory_gb": current_memory,
            "elapsed_time": elapsed_time,
            "gpu_memory": torch.cuda.memory_allocated() / 1024**3 if torch.cuda.is_available() else 0
        }
        
        return metrics
```

#### 2. Deployment Optimization
```python
# Production deployment configuration
production_config = {
    "model_optimization": {
        "quantization": "INT8 quantization",
        "pruning": "weight pruning", 
        "distillation": "knowledge distillation"
    },
    "inference_optimization": {
        "batching": "dynamic batching",
        "caching": "result caching",
        "parallel_workers": 4
    },
    "monitoring": {
        "latency_tracking": "response time tracking",
        "error_logging": "error logging",
        "usage_analytics": "usage pattern analysis"
    }
}
```

## Conclusion and Future Outlook

### 🎯 Significance of Dolphin and the Fox Dataset

The Dolphin project and the Fox dataset mark an important milestone in document image parsing:

#### 1. Technical Innovation
- **Analyze-then-Parse paradigm**: An intuitive approach that mirrors how humans read documents
- **Heterogeneous anchor prompting**: Effective handling of diverse document elements
- **Parallel processing mechanism**: High efficiency and scalability

#### 2. Dataset Value
- **Large-scale multi-granularity**: Over 30 million diverse samples
- **Real-world scenario coverage**: Academic, business, and educational domains included
- **Standardized evaluation environment**: A fair comparison baseline for the research community

### 🚀 Future Research Directions

#### 1. Technical Development Directions
```python
future_directions = {
    "multimodal_fusion": {
        "vision_language": "more refined vision-language fusion",
        "3d_documents": "understanding three-dimensional document structure"
    },
    "interactive_parsing": {
        "user_feedback": "improvement based on user feedback",
        "adaptive_learning": "adaptive learning mechanisms"
    },
    "efficiency_improvements": {
        "edge_deployment": "deployment on edge devices",
        "real_time_processing": "real-time processing optimization"
    }
}
```

#### 2. Application Domain Expansion
```python
application_expansion = {
    "specialized_domains": [
        "legal_documents",
        "medical_records",
        "financial_reports",
        "historical_archives"
    ],
    "emerging_technologies": [
        "ar_vr_integration",
        "voice_interaction",
        "blockchain_verification"
    ]
}
```

### 💡 Recommendations for Practical Adoption

#### 1. Adoption Strategy
1. **Pilot project**: Start small and expand gradually
2. **Domain specialization**: Customize for specific document types
3. **Performance benchmarking**: Establish a baseline using the Fox dataset
4. **Continuous improvement**: Update the model based on user feedback

#### 2. Quality Assurance
```python
quality_assurance = {
    "validation_pipeline": {
        "automated_testing": "automated accuracy testing",
        "human_review": "expert review process",
        "error_analysis": "error pattern analysis and improvement"
    },
    "continuous_monitoring": {
        "performance_tracking": "real-time performance monitoring",
        "drift_detection": "detecting model performance degradation",
        "retraining_triggers": "automatic determination of retraining timing"
    }
}
```

ByteDance Dolphin and the Fox dataset set a new benchmark for document understanding AI, enabling practical solutions across industries and research domains. Continued technical advancement and community contributions are expected to yield more refined and capable document parsing systems.

---

**Further Reading:**
- [Dolphin GitHub Repository](https://github.com/bytedance/Dolphin)
- [ACL 2025 Paper (arXiv)](https://arxiv.org/abs/2505.14059)
- [Dolphin Hugging Face Model](https://huggingface.co/ByteDance/Dolphin)
- [Fox-Page Benchmark Download](https://github.com/bytedance/Dolphin#fox-page-benchmark)
