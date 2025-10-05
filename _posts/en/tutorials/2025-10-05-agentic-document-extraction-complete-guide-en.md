---
title: "Complete Guide to LandingAI Agentic Document Extraction: AI-Powered PDF and Image Processing"
excerpt: "Master LandingAI's Agentic Document Extraction library for intelligent document processing. Extract structured data from complex PDFs, images, and documents with AI-powered parsing capabilities."
seo_title: "LandingAI Agentic Document Extraction Tutorial - AI PDF Processing Guide"
seo_description: "Learn how to use LandingAI's Agentic Document Extraction library for AI-powered document processing. Complete tutorial with code examples, batch processing, and visualization features."
date: 2025-10-05
categories:
  - tutorials
tags:
  - LandingAI
  - Document-Extraction
  - AI
  - PDF-Processing
  - Python
  - Machine-Learning
  - OCR
  - Document-AI
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/agentic-document-extraction-complete-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/agentic-document-extraction-complete-guide/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

In today's data-driven world, extracting structured information from complex documents like PDFs, images, and charts is a critical challenge for businesses and developers. Traditional OCR solutions often struggle with visually complex layouts, tables, and mixed content types. This is where **LandingAI's Agentic Document Extraction** library comes to the rescue.

The Agentic Document Extraction API is a powerful Python library that leverages advanced AI to pull structured data from visually complex documents and returns hierarchical JSON with exact element locations. Whether you're dealing with financial reports, research papers, or multi-page technical documentation, this library provides enterprise-grade document processing capabilities.

## What is Agentic Document Extraction?

LandingAI's Agentic Document Extraction is an AI-powered document processing library that excels at:

- **Complex Layout Understanding**: Handles tables, pictures, charts, and mixed content layouts
- **Long Document Support**: Processes 100+ page PDFs in a single call
- **Structured Output**: Returns hierarchical JSON with exact element locations
- **Visual Grounding**: Provides bounding box information for extracted content
- **Batch Processing**: Handles multiple documents simultaneously with parallel processing

### Key Features

- 📦 **Simple Installation**: One-line pip install with no additional dependencies
- 🗂️ **Universal File Support**: PDFs of any length, images, and URLs
- 📚 **Enterprise Scale**: Auto-split and parallel processing for 1000+ page documents
- 🧩 **Structured Output**: Hierarchical JSON plus ready-to-render Markdown
- 👁️ **Visual Debugging**: Bounding box snippets and full-page visualizations
- 🏃 **Parallel Processing**: Configurable batch processing with thread management
- 🔄 **Resilient**: Automatic retry with exponential backoff for API errors
- ⚙️ **Flexible Configuration**: Environment-based settings for production deployment

## Prerequisites and Setup

### System Requirements

- Python 3.9, 3.10, 3.11, or 3.12
- LandingAI API key (obtain from [LandingAI](https://landing.ai/))
- Internet connection for API calls

### Installation

The installation process is straightforward with pip:

```bash
# Install the agentic-doc library
pip install agentic-doc

# Verify installation
python -c "import agentic_doc; print('Installation successful!')"
```

### API Key Configuration

After obtaining your LandingAI API key, configure it as an environment variable:

```bash
# Set API key as environment variable
export VISION_AGENT_API_KEY=your-api-key-here

# Or create a .env file in your project directory
echo "VISION_AGENT_API_KEY=your-api-key-here" > .env
```

For production environments, consider using secure secret management systems rather than plain text environment variables.

## Basic Usage Examples

### Simple Document Parsing

Let's start with the most basic usage - parsing a single document:

```python
from agentic_doc.parse import parse

# Parse a local PDF file
results = parse("path/to/your/document.pdf")

# Parse from URL
results = parse("https://example.com/document.pdf")

# Parse an image
results = parse("path/to/your/image.jpg")

# Access the parsed content
parsed_doc = results[0]
print(f"Document title: {parsed_doc.title}")
print(f"Number of chunks: {len(parsed_doc.chunks)}")
print(f"Markdown content: {parsed_doc.markdown}")
```

### Understanding the Result Structure

The library returns a structured result with the following key components:

```python
from agentic_doc.parse import parse

results = parse("document.pdf")
parsed_doc = results[0]

# Document metadata
print(f"Title: {parsed_doc.title}")
print(f"Page count: {parsed_doc.page_count}")
print(f"Processing time: {parsed_doc.processing_time}")

# Iterate through content chunks
for i, chunk in enumerate(parsed_doc.chunks):
    print(f"Chunk {i}:")
    print(f"  Type: {chunk.chunk_type}")
    print(f"  Content: {chunk.content[:100]}...")  # First 100 chars
    print(f"  Page: {chunk.page}")
    print(f"  Bounding box: {chunk.grounding[0].bbox if chunk.grounding else 'N/A'}")
    print("---")

# Get the full markdown representation
markdown_content = parsed_doc.markdown
print("Full document as Markdown:")
print(markdown_content)
```

## Advanced Features

### Processing Large PDF Files

One of the library's standout features is its ability to handle large documents automatically:

```python
from agentic_doc.parse import parse

# The library automatically handles large PDFs
# by splitting them into manageable chunks and processing in parallel
results = parse("very-large-document.pdf")

parsed_doc = results[0]
print(f"Successfully processed {parsed_doc.page_count} pages")

# Check for any processing errors
if parsed_doc.errors:
    print("Processing errors encountered:")
    for error in parsed_doc.errors:
        print(f"  Page {error.page}: {error.message}")
```

### Batch Processing Multiple Documents

Process multiple documents simultaneously with configurable parallelism:

```python
from agentic_doc.parse import parse

# Process multiple documents in batch
document_paths = [
    "document1.pdf",
    "document2.pdf", 
    "https://example.com/document3.pdf",
    "image.jpg"
]

# Batch processing with default settings
results = parse(document_paths)

# Process results
for i, parsed_doc in enumerate(results):
    print(f"Document {i+1}: {parsed_doc.title}")
    print(f"  Pages: {parsed_doc.page_count}")
    print(f"  Chunks: {len(parsed_doc.chunks)}")
    
    # Check for errors
    if parsed_doc.errors:
        print(f"  Errors: {len(parsed_doc.errors)}")
```

### Visual Grounding and Debugging

Extract and save visual regions where content was found:

```python
from agentic_doc.parse import parse

# Parse document and save grounding images
results = parse(
    "document.pdf",
    grounding_save_dir="./grounding_images"
)

parsed_doc = results[0]

# Print paths to saved grounding images
for chunk in parsed_doc.chunks:
    for grounding in chunk.grounding:
        if grounding.image_path:
            print(f"Grounding saved to: {grounding.image_path}")
```

### Document Visualization

Create annotated visualizations showing extraction results:

```python
from agentic_doc.parse import parse
from agentic_doc.utils import viz_parsed_document
from agentic_doc.config import VisualizationConfig
from agentic_doc.schema import ChunkType

# Parse document
results = parse("document.pdf")
parsed_doc = results[0]

# Create visualizations with default settings
images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./visualizations"
)

# Customize visualization appearance
viz_config = VisualizationConfig(
    thickness=3,  # Thicker bounding boxes
    text_bg_opacity=0.9,  # More opaque text background
    font_scale=0.8,  # Larger text
    color_map={
        ChunkType.TITLE: (255, 0, 0),    # Red for titles
        ChunkType.TEXT: (0, 255, 0),     # Green for text
        ChunkType.TABLE: (0, 0, 255),    # Blue for tables
    }
)

# Create custom visualizations
custom_images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./custom_visualizations",
    viz_config=viz_config
)

print(f"Created {len(custom_images)} visualization images")
```

## Configuration and Optimization

### Environment Configuration

Create a `.env` file to customize library behavior:

```bash
# .env file configuration
VISION_AGENT_API_KEY=your-api-key-here

# Parallelism settings
BATCH_SIZE=4          # Number of files to process in parallel
MAX_WORKERS=5         # Threads per file for large document processing

# Retry configuration
MAX_RETRIES=100       # Maximum retry attempts
MAX_RETRY_WAIT_TIME=60  # Maximum wait time per retry (seconds)

# Logging configuration
RETRY_LOGGING_STYLE=log_msg  # Options: log_msg, inline_block, none
```

### Performance Optimization

```python
import os
from agentic_doc.parse import parse

# Configure performance settings programmatically
os.environ['BATCH_SIZE'] = '6'
os.environ['MAX_WORKERS'] = '8'
os.environ['MAX_RETRIES'] = '50'

# Process documents with optimized settings
results = parse(["doc1.pdf", "doc2.pdf", "doc3.pdf"])
```

### Advanced Parsing Options

```python
from agentic_doc.parse import parse

# Advanced parsing with custom options
results = parse(
    "document.pdf",
    include_marginalia=False,        # Exclude headers/footers
    include_metadata_in_markdown=False,  # Clean markdown output
    grounding_save_dir="./groundings"    # Save visual groundings
)

parsed_doc = results[0]
print(f"Clean content extracted: {len(parsed_doc.chunks)} chunks")
```

## Error Handling and Troubleshooting

### Robust Error Handling

```python
from agentic_doc.parse import parse
import logging

# Enable detailed logging
logging.basicConfig(level=logging.INFO)

try:
    results = parse("problematic-document.pdf")
    parsed_doc = results[0]
    
    # Check for parsing errors
    if parsed_doc.errors:
        print("Document processed with errors:")
        for error in parsed_doc.errors:
            print(f"  Page {error.page}: {error.error_code} - {error.message}")
    else:
        print("Document processed successfully!")
        
except Exception as e:
    print(f"Failed to process document: {e}")
    # Handle API key issues, network problems, etc.
```

### Common Issues and Solutions

```python
# Handle rate limiting gracefully
import os
from agentic_doc.parse import parse

# Reduce parallelism for rate-limited accounts
os.environ['BATCH_SIZE'] = '1'
os.environ['MAX_WORKERS'] = '2'
os.environ['RETRY_LOGGING_STYLE'] = 'inline_block'

try:
    results = parse("large-document.pdf")
    print("Processing completed successfully")
except Exception as e:
    if "rate limit" in str(e).lower():
        print("Rate limit exceeded. Consider reducing BATCH_SIZE and MAX_WORKERS")
    elif "api key" in str(e).lower():
        print("API key issue. Check VISION_AGENT_API_KEY environment variable")
    else:
        print(f"Unexpected error: {e}")
```

## Real-World Use Cases

### Financial Document Processing

```python
from agentic_doc.parse import parse
import json

def process_financial_reports(report_paths):
    """Process financial reports and extract key information."""
    results = parse(report_paths)
    
    financial_data = []
    for i, parsed_doc in enumerate(results):
        doc_data = {
            'filename': report_paths[i],
            'title': parsed_doc.title,
            'page_count': parsed_doc.page_count,
            'tables': [],
            'key_figures': []
        }
        
        # Extract tables and numerical data
        for chunk in parsed_doc.chunks:
            if chunk.chunk_type.name == 'TABLE':
                doc_data['tables'].append(chunk.content)
            elif any(keyword in chunk.content.lower() 
                    for keyword in ['revenue', 'profit', 'loss', '$', '%']):
                doc_data['key_figures'].append(chunk.content)
        
        financial_data.append(doc_data)
    
    return financial_data

# Process quarterly reports
reports = ['q1_report.pdf', 'q2_report.pdf', 'q3_report.pdf']
financial_analysis = process_financial_reports(reports)

# Save structured data
with open('financial_analysis.json', 'w') as f:
    json.dump(financial_analysis, f, indent=2)
```

### Research Paper Analysis

```python
from agentic_doc.parse import parse
import re

def analyze_research_papers(paper_urls):
    """Analyze research papers and extract abstracts, conclusions."""
    results = parse(paper_urls)
    
    analysis = []
    for i, parsed_doc in enumerate(results):
        paper_analysis = {
            'url': paper_urls[i],
            'title': parsed_doc.title,
            'abstract': None,
            'conclusion': None,
            'references_count': 0,
            'figures_count': 0
        }
        
        for chunk in parsed_doc.chunks:
            content_lower = chunk.content.lower()
            
            # Extract abstract
            if 'abstract' in content_lower and not paper_analysis['abstract']:
                paper_analysis['abstract'] = chunk.content
            
            # Extract conclusion
            if any(word in content_lower for word in ['conclusion', 'summary', 'findings']):
                paper_analysis['conclusion'] = chunk.content
            
            # Count references and figures
            if 'reference' in content_lower or 'bibliography' in content_lower:
                paper_analysis['references_count'] += len(re.findall(r'\[\d+\]', chunk.content))
            
            if chunk.chunk_type.name in ['FIGURE', 'IMAGE']:
                paper_analysis['figures_count'] += 1
        
        analysis.append(paper_analysis)
    
    return analysis

# Analyze research papers
paper_urls = [
    'https://arxiv.org/pdf/2301.00001.pdf',
    'https://arxiv.org/pdf/2301.00002.pdf'
]

research_analysis = analyze_research_papers(paper_urls)
for paper in research_analysis:
    print(f"Title: {paper['title']}")
    print(f"Figures: {paper['figures_count']}")
    print(f"References: {paper['references_count']}")
    print("---")
```

## Best Practices and Tips

### Performance Optimization

1. **Batch Processing**: Process multiple documents together for better throughput
2. **Parallel Configuration**: Adjust `BATCH_SIZE` and `MAX_WORKERS` based on your API limits
3. **Error Handling**: Always check for processing errors in results
4. **Resource Management**: Use grounding images only when needed for debugging

### Production Deployment

```python
import os
from agentic_doc.parse import parse
import logging

# Production configuration
def setup_production_config():
    """Configure library for production use."""
    os.environ['BATCH_SIZE'] = '2'  # Conservative for stability
    os.environ['MAX_WORKERS'] = '3'
    os.environ['MAX_RETRIES'] = '10'
    os.environ['RETRY_LOGGING_STYLE'] = 'none'  # Reduce log noise
    
    # Setup logging
    logging.basicConfig(
        level=logging.WARNING,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def process_documents_safely(document_paths):
    """Safely process documents with comprehensive error handling."""
    setup_production_config()
    
    successful_results = []
    failed_documents = []
    
    try:
        results = parse(document_paths)
        
        for i, result in enumerate(results):
            if result.errors:
                failed_documents.append({
                    'path': document_paths[i],
                    'errors': result.errors
                })
            else:
                successful_results.append(result)
                
    except Exception as e:
        logging.error(f"Batch processing failed: {e}")
        return None, document_paths
    
    return successful_results, failed_documents

# Use in production
documents = ['doc1.pdf', 'doc2.pdf', 'doc3.pdf']
success, failures = process_documents_safely(documents)

if success:
    print(f"Successfully processed {len(success)} documents")
if failures:
    print(f"Failed to process {len(failures)} documents")
```

## Conclusion

LandingAI's Agentic Document Extraction library represents a significant advancement in AI-powered document processing. Its ability to handle complex layouts, process large documents, and provide structured output with visual grounding makes it an invaluable tool for modern data extraction workflows.

### Key Takeaways

- **Enterprise-Ready**: Handles documents of any size with automatic scaling
- **AI-Powered**: Advanced understanding of complex document layouts
- **Developer-Friendly**: Simple API with powerful configuration options
- **Production-Ready**: Built-in retry mechanisms and error handling
- **Flexible Output**: Structured JSON and Markdown formats

### Next Steps

1. **Experiment**: Try the library with your own documents
2. **Optimize**: Fine-tune configuration for your specific use case
3. **Integrate**: Build the library into your existing workflows
4. **Scale**: Leverage batch processing for production workloads

The future of document processing is here, and with LandingAI's Agentic Document Extraction, you're equipped to handle even the most complex document processing challenges with confidence.

---

**Resources:**
- [LandingAI Agentic Document Extraction GitHub](https://github.com/landing-ai/agentic-doc)
- [Official Documentation](https://landing.ai/agentic-document-extraction)
- [API Documentation](https://landing.ai/docs)
- [Get API Key](https://landing.ai/)

*Happy document processing! 🚀*
