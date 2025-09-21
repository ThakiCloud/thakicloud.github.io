---
title: "LangExtract: Comprehensive Tutorial for Structured Text Extraction with LLMs"
excerpt: "Master Google's LangExtract library for extracting structured information from unstructured text using advanced LLMs with precise source grounding and interactive visualization capabilities."
seo_title: "LangExtract Tutorial: LLM-Powered Text Extraction Guide - Thaki Cloud"
seo_description: "Complete tutorial on Google's LangExtract library for structured data extraction from unstructured text using Gemini, OpenAI, and Ollama models with practical examples."
date: 2025-09-21
categories:
  - tutorials
tags:
  - LangExtract
  - LLM
  - Google
  - Gemini
  - Text Extraction
  - Structured Data
  - NLP
  - Python
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/langextract-comprehensive-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/langextract-comprehensive-tutorial/"
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

LangExtract is a powerful Python library developed by Google that revolutionizes how we extract structured information from unstructured text using Large Language Models (LLMs). With over 15,400 stars on GitHub, this cutting-edge tool provides precise source grounding and interactive visualization capabilities, making it an essential tool for modern data extraction workflows.

## What is LangExtract?

LangExtract is designed to bridge the gap between unstructured text data and structured information extraction. Unlike traditional parsing methods, LangExtract leverages the power of advanced LLMs to understand context, relationships, and nuanced information within text documents.

### Key Features

- **Multi-Model Support**: Works with Gemini, OpenAI, and local Ollama models
- **Source Grounding**: Provides precise attribution to source text
- **Interactive Visualization**: Built-in tools for exploring extraction results
- **Schema Constraints**: Enforces structured output formats
- **Parallel Processing**: Handles large documents efficiently
- **Plugin System**: Extensible architecture for custom model providers

## Installation and Setup

### Basic Installation

The simplest way to get started is through pip:

```bash
# Create virtual environment
python -m venv langextract_env
source langextract_env/bin/activate  # On Windows: langextract_env\Scripts\activate

# Install LangExtract
pip install langextract
```

### Development Installation

For development work or accessing the latest features:

```bash
git clone https://github.com/google/langextract.git
cd langextract

# Basic installation
pip install -e .

# With development tools
pip install -e ".[dev]"

# With testing dependencies
pip install -e ".[test]"
```

### Docker Setup

For containerized deployments:

```bash
docker build -t langextract .
docker run --rm -e LANGEXTRACT_API_KEY="your-api-key" langextract python your_script.py
```

## API Key Configuration

### Cloud Models Setup

LangExtract supports multiple cloud providers. Here's how to configure API keys:

#### Option 1: Environment Variables

```bash
export LANGEXTRACT_API_KEY="your-api-key-here"
```

#### Option 2: .env File (Recommended)

```bash
# Create .env file
cat >> .env << 'EOF'
LANGEXTRACT_API_KEY=your-api-key-here
EOF

# Secure your API key
echo '.env' >> .gitignore
```

#### Option 3: Vertex AI Authentication

For enterprise environments using Google Cloud:

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="Extract information...",
    examples=[...],
    model_id="gemini-2.5-flash",
    language_model_params={
        "vertexai": True,
        "project": "your-project-id",
        "location": "global"
    }
)
```

### API Key Sources

- **Gemini Models**: Get API keys from [AI Studio](https://aistudio.google.com/)
- **OpenAI Models**: Access keys from [OpenAI Platform](https://platform.openai.com/)
- **Vertex AI**: For enterprise use with service accounts

## Basic Usage Examples

### Simple Information Extraction

Let's start with a basic example extracting contact information:

```python
import langextract as lx

# Sample text
text = """
Dr. Sarah Johnson is a cardiologist at Metro Hospital.
You can reach her at sarah.johnson@metro.com or call (555) 123-4567.
Her office is located at 123 Medical Drive, Suite 456, Boston, MA 02101.
"""

# Define extraction prompt
prompt = "Extract contact information including name, title, email, phone, and address"

# Basic extraction
result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash"
)

print(result)
```

### Structured Extraction with Examples

For more complex scenarios, provide examples to guide the extraction:

```python
import langextract as lx

# Medical text
medical_text = """
Patient presents with chest pain, shortness of breath, and elevated heart rate.
Prescribed Metoprolol 50mg twice daily and Lisinopril 10mg once daily.
Follow-up appointment scheduled in 2 weeks.
"""

# Define examples
examples = [
    {
        "input": "Patient taking Aspirin 81mg daily for prevention",
        "output": {
            "medications": [
                {
                    "name": "Aspirin",
                    "dosage": "81mg",
                    "frequency": "daily",
                    "purpose": "prevention"
                }
            ]
        }
    }
]

# Extract with examples
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="Extract medication information including name, dosage, frequency, and purpose",
    examples=examples,
    model_id="gemini-2.5-flash"
)

print(result)
```

## Working with Different Model Providers

### Using OpenAI Models

```python
import langextract as lx
import os

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="Extract key information",
    examples=examples,
    model_id="gpt-4o",
    api_key=os.environ.get('OPENAI_API_KEY'),
    fence_output=True,
    use_schema_constraints=False  # Required for OpenAI
)
```

### Using Local Models with Ollama

For privacy-focused deployments or offline processing:

```bash
# Install and setup Ollama
# Visit ollama.com for installation instructions
ollama pull gemma2:2b
ollama serve
```

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="Extract information",
    examples=examples,
    model_id="gemma2:2b",
    model_url="http://localhost:11434",
    fence_output=False,
    use_schema_constraints=False
)
```

## Advanced Features

### Large Document Processing

LangExtract excels at processing large documents with parallel processing:

```python
import langextract as lx
import requests

# Download large document (Romeo and Juliet example)
url = "https://www.gutenberg.org/files/1513/1513-0.txt"
response = requests.get(url)
full_text = response.text

# Extract character information
result = lx.extract(
    text_or_documents=full_text,
    prompt_description="Extract character names, relationships, and key scenes",
    model_id="gemini-2.5-flash",
    max_parallel_calls=4  # Parallel processing
)
```

### Schema-Constrained Extraction

Define precise output schemas for consistent results:

```python
from pydantic import BaseModel
from typing import List

class Medication(BaseModel):
    name: str
    dosage: str
    frequency: str
    route: str = "oral"

class MedicalRecord(BaseModel):
    patient_id: str
    medications: List[Medication]
    symptoms: List[str]

# Use schema for extraction
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="Extract medical information",
    schema=MedicalRecord,
    model_id="gemini-2.5-flash",
    use_schema_constraints=True
)
```

### Interactive Visualization

LangExtract provides built-in visualization tools:

```python
# Enable visualization
result = lx.extract(
    text_or_documents=text,
    prompt_description="Extract entities",
    model_id="gemini-2.5-flash",
    visualize=True
)

# Access visualization data
print(result.visualization_data)
```

## Real-World Use Cases

### Healthcare: Medical Records Processing

```python
def extract_medical_info(clinical_notes):
    """Extract structured medical information from clinical notes."""
    
    examples = [
        {
            "input": "Patient reports severe headache, prescribed Ibuprofen 600mg every 6 hours",
            "output": {
                "symptoms": ["severe headache"],
                "medications": [
                    {
                        "name": "Ibuprofen",
                        "dosage": "600mg",
                        "frequency": "every 6 hours"
                    }
                ]
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=clinical_notes,
        prompt_description="Extract symptoms, medications, and treatment plans",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

### Legal: Contract Analysis

```python
def extract_contract_terms(contract_text):
    """Extract key terms from legal contracts."""
    
    prompt = """
    Extract contract information including:
    - Parties involved
    - Contract duration
    - Key obligations
    - Payment terms
    - Termination clauses
    """
    
    return lx.extract(
        text_or_documents=contract_text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        temperature=0.1  # Lower temperature for legal accuracy
    )
```

### Academic: Research Paper Analysis

```python
def extract_research_info(paper_text):
    """Extract structured information from research papers."""
    
    examples = [
        {
            "input": "This study examines 500 participants over 12 months...",
            "output": {
                "sample_size": 500,
                "study_duration": "12 months",
                "methodology": "longitudinal study"
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=paper_text,
        prompt_description="Extract research methodology, sample size, and key findings",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

## Custom Model Providers

LangExtract's plugin system allows you to add custom model providers:

```python
from langextract.registry import registry

@registry.register(
    name="custom_provider",
    priority=10,
    model_ids=["custom-model-v1"]
)
class CustomProvider:
    def __init__(self, model_id, api_key=None, **kwargs):
        self.model_id = model_id
        self.api_key = api_key
    
    def generate(self, prompt, **kwargs):
        # Implement your custom generation logic
        pass
    
    @staticmethod
    def get_schema_class():
        # Optional: return custom schema class
        return None
```

## Performance Optimization

### Best Practices

1. **Use Appropriate Models**: Choose the right model for your use case
   - Gemini 2.5 Flash: Fast, cost-effective
   - GPT-4: High accuracy for complex tasks
   - Local models: Privacy and offline processing

2. **Optimize Prompts**: Clear, specific prompts yield better results
3. **Leverage Examples**: Provide 2-3 high-quality examples
4. **Batch Processing**: Process multiple documents in parallel
5. **Schema Constraints**: Use schemas for consistent output format

### Error Handling

```python
import langextract as lx
from langextract.exceptions import LangExtractError

try:
    result = lx.extract(
        text_or_documents=text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        max_retries=3,
        timeout=30
    )
except LangExtractError as e:
    print(f"Extraction failed: {e}")
    # Implement fallback logic
```

## Testing and Validation

### Unit Testing

```python
import unittest
import langextract as lx

class TestLangExtract(unittest.TestCase):
    def setUp(self):
        self.sample_text = "Dr. John Doe can be reached at john@example.com"
        
    def test_contact_extraction(self):
        result = lx.extract(
            text_or_documents=self.sample_text,
            prompt_description="Extract email addresses",
            model_id="gemini-2.5-flash"
        )
        
        self.assertIn("john@example.com", str(result))

if __name__ == "__main__":
    unittest.main()
```

### Integration Testing

```bash
# Run full test suite
pytest tests

# Test specific provider
pytest tests/test_ollama.py

# Run with coverage
pytest --cov=langextract tests
```

## Troubleshooting

### Common Issues

1. **API Key Errors**
   - Verify API key is correctly set
   - Check key permissions and quotas

2. **Model Availability**
   - Ensure model ID is correct
   - Verify model is available in your region

3. **Memory Issues with Large Documents**
   - Use chunk processing for very large texts
   - Enable parallel processing

4. **Inconsistent Output Format**
   - Use schema constraints
   - Provide more examples
   - Lower temperature for consistency

### Debug Mode

```python
import logging
logging.basicConfig(level=logging.DEBUG)

result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash",
    debug=True
)
```

## Security Considerations

### Data Privacy

- **Local Processing**: Use Ollama for sensitive data
- **API Security**: Rotate API keys regularly
- **Data Retention**: Understand provider data policies

### Input Validation

```python
def safe_extract(text, max_length=10000):
    """Safely extract with input validation."""
    
    if len(text) > max_length:
        raise ValueError("Input text too long")
    
    # Sanitize input
    text = text.strip()
    
    return lx.extract(
        text_or_documents=text,
        prompt_description="Extract information",
        model_id="gemini-2.5-flash"
    )
```

## Conclusion

LangExtract represents a significant advancement in structured information extraction from unstructured text. Its combination of powerful LLM integration, precise source grounding, and flexible architecture makes it an invaluable tool for modern data processing workflows.

Whether you're processing medical records, analyzing legal documents, or extracting insights from research papers, LangExtract provides the tools and flexibility needed to transform unstructured text into actionable structured data.

### Next Steps

1. **Explore Examples**: Check the [official examples](https://github.com/google/langextract/tree/main/examples)
2. **Join Community**: Contribute to the [community providers](https://github.com/google/langextract/blob/main/COMMUNITY_PROVIDERS.md)
3. **Read Documentation**: Visit the [official documentation](https://github.com/google/langextract/tree/main/docs)
4. **Try Live Demo**: Experience [RadExtract demo](https://huggingface.co/spaces/google/radextract)

Start your journey with LangExtract today and revolutionize how you work with unstructured text data!

---

**💡 Pro Tip**: Begin with simple extraction tasks and gradually increase complexity as you become familiar with the library's capabilities. The key to success with LangExtract is crafting clear prompts and providing good examples.
