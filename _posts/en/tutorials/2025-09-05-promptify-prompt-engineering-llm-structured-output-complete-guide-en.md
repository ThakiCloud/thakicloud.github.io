---
title: "Promptify: Complete Guide to Structured LLM Output with Prompt Engineering"
excerpt: "Master prompt engineering and get structured outputs from GPT, PaLM, and other LLMs using Promptify - a powerful Python library for NLP tasks without training data."
seo_title: "Promptify Tutorial: LLM Prompt Engineering for Structured Output - Complete Guide"
seo_description: "Learn how to use Promptify for prompt engineering with GPT and other LLMs. Get structured outputs for NER, classification, QA, and more NLP tasks without training data."
date: 2025-09-05
categories:
  - tutorials
tags:
  - prompt-engineering
  - llm
  - nlp
  - gpt
  - openai
  - machine-learning
  - python
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/tutorials/promptify-prompt-engineering-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/promptify-prompt-engineering-guide/"
---

⏱️ **Estimated Reading Time**: 15 minutes

Are you tired of getting unstructured, inconsistent outputs from Large Language Models (LLMs) like GPT-3, GPT-4, or PaLM? Do you want to perform complex NLP tasks without training data or fine-tuning models? **Promptify** is here to solve these problems!

In this comprehensive tutorial, we'll explore how to use [Promptify](https://github.com/promptslab/Promptify), a powerful Python library that enables structured output generation from LLMs through intelligent prompt engineering.

## What is Promptify?

Promptify is an open-source Python library designed to make prompt engineering more systematic and reliable. It addresses one of the biggest challenges when working with LLMs: **getting consistent, structured outputs** that can be easily parsed and used in applications.

### Key Problems Promptify Solves

1. **Unstructured LLM Output**: Raw LLM responses are often inconsistent and difficult to parse
2. **No Training Data Required**: Perform NLP tasks without labeled datasets
3. **Prompt Consistency**: Standardized templates for different NLP tasks
4. **Output Validation**: Handles out-of-bounds predictions from LLMs

### Main Features

- 🎯 **Zero-shot NLP tasks** in just 2 lines of code
- 📝 **Multiple prompt strategies**: one-shot, few-shot examples
- 🔧 **Structured output**: Always returns Python objects (lists, dictionaries)
- 🤗 **Multi-model support**: OpenAI GPT, Hugging Face models, Azure, PaLM
- 💰 **Cost optimization**: Optimized prompts to reduce token usage
- 🛡️ **Error handling**: Robust validation for LLM predictions

## Installation and Setup

### Installing Promptify

First, let's install Promptify using pip:

```bash
# Install from PyPI
pip install promptify

# Or install from GitHub (latest version)
pip install git+https://github.com/promptslab/Promptify.git
```

### Setting Up OpenAI API

You'll need an OpenAI API key to use GPT models:

```python
import os
from promptify import Prompter, OpenAI, Pipeline

# Set your OpenAI API key
api_key = "your-openai-api-key-here"
# Or use environment variable
# os.environ["OPENAI_API_KEY"] = "your-api-key"
```

### Alternative Model Setup

Promptify supports multiple LLM providers:

```python
# For Hugging Face models
from promptify import HubModel
model = HubModel()

# For Azure OpenAI
from promptify import Azure
model = Azure(api_key="your-azure-key")
```

## Basic Usage: The Pipeline API

The Pipeline API is the easiest way to get started with Promptify. Let's see how to perform Named Entity Recognition (NER) on medical text:

```python
from promptify import Prompter, OpenAI, Pipeline

# Sample medical text
sentence = """The patient is a 93-year-old female with a medical  
             history of chronic right hip pain, osteoporosis,
             hypertension, depression, and chronic atrial
             fibrillation admitted for evaluation and management
             of severe nausea and vomiting and urinary tract
             infection"""

# Initialize components
model = OpenAI(api_key)              # LLM model
prompter = Prompter('ner.jinja')     # NER template
pipe = Pipeline(prompter, model)      # Complete pipeline

# Execute NER task
result = pipe.fit(sentence, domain="medical", labels=None)
print(result)
```

### Expected Output

```json
[
    {"E": "93-year-old", "T": "Age"},
    {"E": "chronic right hip pain", "T": "Medical Condition"},
    {"E": "osteoporosis", "T": "Medical Condition"},
    {"E": "hypertension", "T": "Medical Condition"},
    {"E": "depression", "T": "Medical Condition"},
    {"E": "chronic atrial fibrillation", "T": "Medical Condition"},
    {"E": "severe nausea and vomiting", "T": "Symptom"},
    {"E": "urinary tract infection", "T": "Medical Condition"},
    {"Branch": "Internal Medicine", "Group": "Geriatrics"}
]
```

## Advanced NLP Tasks with Promptify

### 1. Text Classification

Promptify excels at zero-shot text classification:

```python
# Multi-class sentiment analysis
from promptify import Prompter, OpenAI, Pipeline

text = "I absolutely love this new smartphone! The camera quality is amazing and the battery lasts all day."

model = OpenAI(api_key)
prompter = Prompter('classification.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(
    text, 
    labels=["positive", "negative", "neutral"],
    task="sentiment_analysis"
)
print(result)
# Output: {"label": "positive", "confidence": 0.95}
```

### 2. Question Answering

Build a QA system without training:

```python
# Question answering setup
context = """Promptify is a Python library for prompt engineering. 
           It helps developers get structured outputs from Large Language Models 
           like GPT-3, GPT-4, and PaLM. The library supports various NLP tasks
           including named entity recognition, text classification, and summarization."""

question = "What NLP tasks does Promptify support?"

model = OpenAI(api_key)
prompter = Prompter('qa.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(context, question=question)
print(result)
# Output: {"answer": "named entity recognition, text classification, and summarization"}
```

### 3. Relation Extraction

Extract relationships between entities:

```python
# Relation extraction
text = """Tim Cook is the CEO of Apple Inc. Apple was founded by Steve Jobs in 1976. 
         The company is headquartered in Cupertino, California."""

model = OpenAI(api_key)
prompter = Prompter('relation_extraction.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(text, domain="business")
print(result)
# Output: [
#   {"subject": "Tim Cook", "relation": "CEO_of", "object": "Apple Inc."},
#   {"subject": "Apple", "relation": "founded_by", "object": "Steve Jobs"},
#   {"subject": "Apple", "relation": "founded_in", "object": "1976"},
#   {"subject": "Apple", "relation": "headquartered_in", "object": "Cupertino, California"}
# ]
```

### 4. Text Summarization

Generate concise summaries:

```python
# Text summarization
long_text = """
Large Language Models (LLMs) have revolutionized natural language processing. 
These models, trained on vast amounts of text data, can perform a wide variety 
of tasks including translation, summarization, question answering, and creative writing. 
However, getting structured and consistent outputs from LLMs remains a challenge. 
Promptify addresses this by providing a framework for systematic prompt engineering, 
enabling developers to get reliable, structured outputs for various NLP tasks without 
the need for training data or model fine-tuning.
"""

model = OpenAI(api_key)
prompter = Prompter('summarization.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(long_text, max_length=50)
print(result)
# Output: {"summary": "LLMs excel at NLP tasks but lack structured output. Promptify solves this through systematic prompt engineering."}
```

## Advanced Features and Customization

### Custom Prompt Templates

Create your own prompt templates for specific use cases:

```python
# Custom template for code review
custom_template = """
You are an expert code reviewer. Analyze the following code and provide structured feedback.

Code:
{{ code }}

Please provide feedback in the following JSON format:
{
    "issues": [list of issues found],
    "suggestions": [list of improvement suggestions],
    "severity": "low|medium|high",
    "score": (1-10)
}
"""

# Use custom template
from promptify import Prompter, OpenAI, Pipeline

code_snippet = """
def calculate_average(numbers):
    return sum(numbers) / len(numbers)
"""

model = OpenAI(api_key)
prompter = Prompter(custom_template)
pipe = Pipeline(prompter, model)

result = pipe.fit(code=code_snippet)
```

### Few-Shot Learning

Add examples to improve model performance:

```python
# Few-shot learning for better accuracy
examples = [
    {
        "text": "The weather is sunny and warm today.",
        "entities": [{"E": "sunny", "T": "Weather"}, {"E": "warm", "T": "Temperature"}]
    },
    {
        "text": "John works at Microsoft in Seattle.",
        "entities": [{"E": "John", "T": "Person"}, {"E": "Microsoft", "T": "Organization"}, {"E": "Seattle", "T": "Location"}]
    }
]

model = OpenAI(api_key)
prompter = Prompter('ner.jinja')
pipe = Pipeline(prompter, model)

result = pipe.fit(
    "Sarah studies at Stanford University in California.",
    examples=examples,
    domain="general"
)
```

### Batch Processing

Process multiple texts efficiently:

```python
# Batch processing multiple documents
texts = [
    "Apple Inc. reported strong quarterly earnings.",
    "Google announced new AI breakthrough.",
    "Microsoft Azure cloud services expanded to new regions."
]

model = OpenAI(api_key)
prompter = Prompter('classification.jinja')
pipe = Pipeline(prompter, model)

results = []
for text in texts:
    result = pipe.fit(
        text, 
        labels=["technology", "finance", "healthcare", "sports"],
        task="topic_classification"
    )
    results.append(result)

print(results)
```

## Real-World Applications

### 1. Content Moderation System

```python
def moderate_content(text):
    """Automated content moderation using Promptify"""
    
    model = OpenAI(api_key)
    prompter = Prompter('classification.jinja')
    pipe = Pipeline(prompter, model)
    
    # Check for inappropriate content
    result = pipe.fit(
        text,
        labels=["safe", "toxic", "spam", "hate_speech"],
        task="content_moderation"
    )
    
    return result["label"], result.get("confidence", 0.0)

# Usage
comment = "This is a great article, very informative!"
label, confidence = moderate_content(comment)
print(f"Content classification: {label} (confidence: {confidence})")
```

### 2. Document Analysis Pipeline

```python
def analyze_document(document_text):
    """Comprehensive document analysis"""
    
    model = OpenAI(api_key)
    results = {}
    
    # Extract entities
    ner_prompter = Prompter('ner.jinja')
    ner_pipe = Pipeline(ner_prompter, model)
    results['entities'] = ner_pipe.fit(document_text)
    
    # Classify document
    class_prompter = Prompter('classification.jinja')
    class_pipe = Pipeline(class_prompter, model)
    results['category'] = class_pipe.fit(
        document_text,
        labels=["legal", "technical", "marketing", "financial"]
    )
    
    # Generate summary
    summary_prompter = Prompter('summarization.jinja')
    summary_pipe = Pipeline(summary_prompter, model)
    results['summary'] = summary_pipe.fit(document_text, max_length=100)
    
    return results

# Usage
document = "Your document text here..."
analysis = analyze_document(document)
```

### 3. Customer Support Automation

```python
def process_support_ticket(ticket_text):
    """Automated support ticket processing"""
    
    model = OpenAI(api_key)
    
    # Classify urgency
    urgency_prompter = Prompter('classification.jinja')
    urgency_pipe = Pipeline(urgency_prompter, model)
    urgency = urgency_pipe.fit(
        ticket_text,
        labels=["low", "medium", "high", "critical"],
        task="urgency_classification"
    )
    
    # Extract issue type
    issue_prompter = Prompter('classification.jinja')
    issue_pipe = Pipeline(issue_prompter, model)
    issue_type = issue_pipe.fit(
        ticket_text,
        labels=["billing", "technical", "account", "feature_request"],
        task="issue_classification"
    )
    
    # Extract key information
    info_prompter = Prompter('ner.jinja')
    info_pipe = Pipeline(info_prompter, model)
    entities = info_pipe.fit(ticket_text, domain="customer_support")
    
    return {
        "urgency": urgency["label"],
        "issue_type": issue_type["label"],
        "entities": entities,
        "routing": determine_routing(urgency["label"], issue_type["label"])
    }

def determine_routing(urgency, issue_type):
    """Route tickets based on classification"""
    if urgency == "critical":
        return "tier_3_immediate"
    elif issue_type == "billing":
        return "billing_department"
    elif issue_type == "technical":
        return "technical_support"
    else:
        return "general_support"
```

## Best Practices and Tips

### 1. Prompt Optimization

```python
# Good: Specific and clear instructions
good_prompt = """
Extract named entities from the text below. Return only the entities in JSON format:
{"entities": [{"text": "entity", "label": "TYPE"}]}

Text: {{ text }}
"""

# Bad: Vague instructions
bad_prompt = """
Find things in this text: {{ text }}
"""
```

### 2. Error Handling

```python
def safe_nlp_processing(text, task="ner"):
    """Robust NLP processing with error handling"""
    
    try:
        model = OpenAI(api_key)
        prompter = Prompter(f'{task}.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(text)
        return {"success": True, "data": result}
        
    except Exception as e:
        return {
            "success": False, 
            "error": str(e),
            "fallback": "Manual processing required"
        }

# Usage with error handling
result = safe_nlp_processing("Your text here", "classification")
if result["success"]:
    print("Processing successful:", result["data"])
else:
    print("Error occurred:", result["error"])
```

### 3. Performance Optimization

```python
# Cache frequently used prompts
import functools

@functools.lru_cache(maxsize=128)
def get_cached_prompt(template_name):
    return Prompter(template_name)

# Batch similar requests
def batch_classify_texts(texts, labels):
    """Efficient batch classification"""
    
    model = OpenAI(api_key)
    prompter = get_cached_prompt('classification.jinja')
    pipe = Pipeline(prompter, model)
    
    # Process in batches to optimize API calls
    batch_size = 10
    results = []
    
    for i in range(0, len(texts), batch_size):
        batch = texts[i:i + batch_size]
        batch_results = []
        
        for text in batch:
            result = pipe.fit(text, labels=labels)
            batch_results.append(result)
            
        results.extend(batch_results)
    
    return results
```

## Testing and Validation

Let's create a comprehensive test script to validate our Promptify setup:

```python
#!/usr/bin/env python3
"""
Promptify Tutorial Test Script
Tests all major functionality covered in the tutorial
"""

import os
import sys
from promptify import Prompter, OpenAI, Pipeline

def test_basic_setup():
    """Test basic Promptify setup"""
    print("🔧 Testing basic setup...")
    
    # Check if API key is available
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        print("❌ OpenAI API key not found. Set OPENAI_API_KEY environment variable.")
        return False
    
    try:
        model = OpenAI(api_key)
        print("✅ OpenAI model initialized successfully")
        return True
    except Exception as e:
        print(f"❌ Failed to initialize OpenAI model: {e}")
        return False

def test_ner():
    """Test Named Entity Recognition"""
    print("\n🔍 Testing Named Entity Recognition...")
    
    try:
        sentence = "John Smith works at Apple Inc. in Cupertino, California."
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('ner.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(sentence, domain="general")
        print(f"✅ NER successful: {len(result) if isinstance(result, list) else 1} entities found")
        return True
        
    except Exception as e:
        print(f"❌ NER test failed: {e}")
        return False

def test_classification():
    """Test text classification"""
    print("\n📊 Testing Text Classification...")
    
    try:
        text = "I love this new smartphone! Great camera and battery life."
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('classification.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(
            text,
            labels=["positive", "negative", "neutral"],
            task="sentiment_analysis"
        )
        print(f"✅ Classification successful: {result}")
        return True
        
    except Exception as e:
        print(f"❌ Classification test failed: {e}")
        return False

def test_summarization():
    """Test text summarization"""
    print("\n📝 Testing Summarization...")
    
    try:
        text = """
        Artificial Intelligence has made remarkable progress in recent years. 
        Machine learning algorithms can now perform complex tasks like image recognition, 
        natural language processing, and strategic game playing. Deep learning, 
        a subset of machine learning, has been particularly successful in achieving 
        human-level performance in many domains.
        """
        
        model = OpenAI(os.getenv("OPENAI_API_KEY"))
        prompter = Prompter('summarization.jinja')
        pipe = Pipeline(prompter, model)
        
        result = pipe.fit(text, max_length=50)
        print(f"✅ Summarization successful: Generated summary")
        return True
        
    except Exception as e:
        print(f"❌ Summarization test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("🚀 Starting Promptify Tutorial Tests\n")
    
    tests = [
        test_basic_setup,
        test_ner,
        test_classification,
        test_summarization
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
    
    print(f"\n📊 Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Promptify is working correctly.")
    else:
        print("⚠️  Some tests failed. Check your setup and API key.")
        sys.exit(1)

if __name__ == "__main__":
    main()
```

## Troubleshooting Common Issues

### Issue 1: API Key Not Working

```bash
# Set environment variable
export OPENAI_API_KEY="your-api-key-here"

# Or in Python
import os
os.environ["OPENAI_API_KEY"] = "your-api-key-here"
```

### Issue 2: Installation Problems

```bash
# Upgrade pip first
pip install --upgrade pip

# Install with specific version
pip install promptify==1.0.0

# Force reinstall
pip install --force-reinstall promptify
```

### Issue 3: Template Not Found

```python
# List available templates
from promptify import Prompter
prompter = Prompter()
print(prompter.list_templates())

# Use custom template path
prompter = Prompter('/path/to/your/template.jinja')
```

## Next Steps and Advanced Topics

### 1. Custom Model Integration

Explore integrating your own fine-tuned models:

```python
# Custom model wrapper
class CustomModel:
    def __init__(self, model_path):
        self.model = load_your_model(model_path)
    
    def generate(self, prompt, **kwargs):
        return self.model.predict(prompt)

# Use with Promptify
custom_model = CustomModel("path/to/model")
prompter = Prompter('ner.jinja')
pipe = Pipeline(prompter, custom_model)
```

### 2. Prompt Template Development

Learn to create sophisticated prompt templates:

```jinja2
{# Advanced NER template with few-shot examples #}
You are an expert named entity recognizer. Extract entities from text.

Examples:
{% for example in examples %}
Text: {{ example.text }}
Entities: {{ example.entities | tojson }}
{% endfor %}

Now extract entities from:
Text: {{ text }}
Domain: {{ domain }}

Return only valid JSON:
```

### 3. Production Deployment

Consider these factors for production use:

- **Rate limiting**: Implement proper API rate limiting
- **Caching**: Cache frequent prompt-response pairs
- **Monitoring**: Log API usage and model performance
- **Fallbacks**: Have backup models for high availability

## Conclusion

Promptify represents a significant step forward in making LLMs more practical for real-world applications. By providing structured outputs, standardized templates, and robust error handling, it bridges the gap between raw LLM capabilities and production-ready NLP systems.

### Key Takeaways

1. **Zero-shot capability**: Perform complex NLP tasks without training data
2. **Structured outputs**: Get consistent, parseable results every time
3. **Multiple models**: Support for OpenAI, Hugging Face, and other providers
4. **Production ready**: Built-in error handling and validation
5. **Extensible**: Custom templates and model integration

### What's Next?

- Explore the [official documentation](https://promptify.readthedocs.io/)
- Join the [Promptify Discord community](https://discord.gg/m88xfYMbK6)
- Contribute to the [GitHub repository](https://github.com/promptslab/Promptify)
- Try building your own NLP applications with Promptify

With Promptify, the power of large language models is now more accessible and reliable than ever. Start building amazing NLP applications today!

---

*Did you find this tutorial helpful? Share your Promptify projects and experiences in the comments below!*
