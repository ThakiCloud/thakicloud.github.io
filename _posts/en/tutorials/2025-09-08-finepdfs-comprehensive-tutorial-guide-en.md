---
title: "FinePDFs: Complete Guide to Using HuggingFace's Massive PDF Text Dataset"
excerpt: "Learn how to effectively use FinePDFs, a 51.6GB dataset with 2.8M documents across 1733 languages for LLM training and research applications."
seo_title: "FinePDFs Tutorial: HuggingFace PDF Dataset Guide - Thaki Cloud"
seo_description: "Comprehensive tutorial on using FinePDFs dataset from HuggingFace. Learn data loading, preprocessing, analysis and applications for LLM training."
date: 2025-09-08
lang: en
permalink: /en/tutorials/finepdfs-comprehensive-tutorial-guide/
canonical_url: "https://thakicloud.github.io/en/tutorials/finepdfs-comprehensive-tutorial-guide/"
categories:
  - tutorials
tags:
  - finepdfs
  - huggingface
  - datasets
  - pdf
  - nlp
  - llm
author_profile: true
toc: true
toc_label: "Contents"
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

FinePDFs represents a groundbreaking achievement in open-source dataset creation. Released by HuggingFace, this massive dataset contains **2.8 million documents** spanning **1,733 languages**, extracted from PDF files across the web. With a total size of **51.6GB**, FinePDFs bridges the critical gap between expensive PDF processing and accessible high-quality textual content.

Unlike traditional web scraping that focuses on HTML content, PDFs typically contain higher-quality, more specialized content from domains like science, law, and technical documentation. This tutorial will guide you through everything you need to know to effectively use FinePDFs in your projects.

## Dataset Overview

### Key Statistics
- **Size**: 51.6GB compressed
- **Documents**: 2,865,213 rows
- **Languages**: 1,733 language subsets
- **License**: ODC-By v1.0
- **Format**: Parquet files for efficient processing

### Extraction Methods
FinePDFs uses two primary extraction pipelines:
1. **Docling**: Direct text extraction from embedded PDF text
2. **RolmOCR**: OCR-based extraction for image-heavy documents

## Prerequisites

Before diving into the tutorial, ensure you have the following installed:

```bash
# Install required packages
pip install datasets transformers torch pandas matplotlib seaborn
pip install huggingface_hub datasets[streaming]
```

## Getting Started

### 1. Loading the Dataset

Let's start by exploring the dataset structure and loading a subset:

```python
from datasets import load_dataset
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

# Load a specific language subset (English for example)
print("Loading FinePDFs dataset...")
dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", split="train", streaming=True)

# Convert to pandas for easier exploration
sample_data = []
for i, example in enumerate(dataset):
    if i >= 1000:  # Limit to first 1000 examples for exploration
        break
    sample_data.append(example)

df = pd.DataFrame(sample_data)
print(f"Sample dataset shape: {df.shape}")
print(f"Columns: {df.columns.tolist()}")
```

### 2. Exploring the Data Structure

```python
# Examine the first few rows
print("First 3 examples:")
for i in range(3):
    print(f"\nExample {i+1}:")
    print(f"Text length: {len(df.iloc[i]['text'])} characters")
    print(f"Text preview: {df.iloc[i]['text'][:200]}...")
    
# Basic statistics
print(f"\nDataset Statistics:")
print(f"Total documents in sample: {len(df)}")
print(f"Average text length: {df['text'].str.len().mean():.2f} characters")
print(f"Median text length: {df['text'].str.len().median():.2f} characters")
```

### 3. Available Language Subsets

```python
# List available language configurations
from datasets import get_dataset_config_names

configs = get_dataset_config_names("HuggingFaceFW/finepdfs")
print(f"Total language subsets available: {len(configs)}")
print(f"First 20 language codes: {configs[:20]}")

# Popular language subsets with more data
popular_langs = [
    "eng_Latn",    # English
    "spa_Latn",    # Spanish  
    "fra_Latn",    # French
    "deu_Latn",    # German
    "ita_Latn",    # Italian
    "por_Latn",    # Portuguese
    "rus_Cyrl",    # Russian
    "zho_Hans",    # Chinese (Simplified)
    "jpn_Jpan",    # Japanese
    "arb_Arab"     # Arabic
]

print(f"Popular language subsets: {popular_langs}")
```

## Data Analysis and Preprocessing

### 4. Text Quality Assessment

```python
import re
from collections import Counter

def analyze_text_quality(texts):
    """Analyze text quality metrics"""
    results = {
        'avg_length': [],
        'word_count': [],
        'sentence_count': [],
        'char_diversity': [],
        'contains_code': [],
        'contains_math': []
    }
    
    for text in texts[:100]:  # Sample first 100 for analysis
        # Basic metrics
        results['avg_length'].append(len(text))
        results['word_count'].append(len(text.split()))
        results['sentence_count'].append(len(re.split(r'[.!?]+', text)))
        
        # Character diversity (unique chars / total chars)
        unique_chars = len(set(text.lower()))
        total_chars = len(text)
        results['char_diversity'].append(unique_chars / max(total_chars, 1))
        
        # Code detection (simplified)
        code_indicators = ['def ', 'function', 'import ', '#include', 'class ', '{', '}']
        results['contains_code'].append(any(indicator in text for indicator in code_indicators))
        
        # Math detection (simplified)
        math_indicators = ['∫', '∑', '∂', '∆', '∇', '≥', '≤', '±', '²', '³']
        results['contains_math'].append(any(indicator in text for indicator in math_indicators))
    
    return results

# Analyze sample data
quality_metrics = analyze_text_quality(df['text'].tolist())

print("Text Quality Analysis:")
print(f"Average document length: {sum(quality_metrics['avg_length'])/len(quality_metrics['avg_length']):.2f} chars")
print(f"Average word count: {sum(quality_metrics['word_count'])/len(quality_metrics['word_count']):.2f} words")
print(f"Documents with code: {sum(quality_metrics['contains_code'])} / {len(quality_metrics['contains_code'])}")
print(f"Documents with math: {sum(quality_metrics['contains_math'])} / {len(quality_metrics['contains_math'])}")
```

### 5. Content Domain Classification

```python
def classify_document_domain(text):
    """Simple domain classification based on keywords"""
    text_lower = text.lower()
    
    # Define domain keywords
    domains = {
        'scientific': ['research', 'study', 'experiment', 'hypothesis', 'methodology', 'results', 'conclusion'],
        'legal': ['court', 'law', 'statute', 'regulation', 'defendant', 'plaintiff', 'contract'],
        'technical': ['algorithm', 'implementation', 'system', 'framework', 'architecture', 'development'],
        'medical': ['patient', 'diagnosis', 'treatment', 'clinical', 'medical', 'therapy', 'disease'],
        'financial': ['investment', 'portfolio', 'market', 'economic', 'financial', 'revenue', 'profit'],
        'academic': ['university', 'education', 'learning', 'curriculum', 'academic', 'student', 'professor']
    }
    
    domain_scores = {}
    for domain, keywords in domains.items():
        score = sum(1 for keyword in keywords if keyword in text_lower)
        domain_scores[domain] = score
    
    return max(domain_scores, key=domain_scores.get) if max(domain_scores.values()) > 0 else 'general'

# Classify sample documents
domains = [classify_document_domain(text) for text in df['text'][:200]]
domain_counts = Counter(domains)

print("Domain Distribution (sample of 200 documents):")
for domain, count in domain_counts.most_common():
    print(f"{domain}: {count} documents ({count/200*100:.1f}%)")
```

## Practical Applications

### 6. Fine-tuning Data Preparation

```python
def prepare_finetuning_data(texts, max_length=512, min_length=50):
    """Prepare data for language model fine-tuning"""
    processed_texts = []
    
    for text in texts:
        # Clean text
        cleaned = re.sub(r'\s+', ' ', text.strip())
        
        # Filter by length
        if min_length <= len(cleaned) <= max_length * 4:  # Rough character to token ratio
            processed_texts.append(cleaned)
    
    return processed_texts

# Prepare training data
training_texts = prepare_finetuning_data(df['text'].tolist())
print(f"Prepared {len(training_texts)} texts for fine-tuning")

# Save to file for training
with open('finepdfs_training_data.txt', 'w', encoding='utf-8') as f:
    for text in training_texts[:1000]:  # Save first 1000 examples
        f.write(text + '\n\n')

print("Training data saved to 'finepdfs_training_data.txt'")
```

### 7. RAG (Retrieval Augmented Generation) Setup

```python
from sentence_transformers import SentenceTransformer
import numpy as np
from sklearn.metrics.pairwise import cosine_similarity

def create_document_embeddings(texts, model_name='all-MiniLM-L6-v2'):
    """Create embeddings for RAG system"""
    model = SentenceTransformer(model_name)
    
    # Chunk texts for better retrieval
    chunks = []
    chunk_size = 512
    
    for text in texts[:100]:  # Process first 100 documents
        words = text.split()
        for i in range(0, len(words), chunk_size):
            chunk = ' '.join(words[i:i + chunk_size])
            if len(chunk.strip()) > 50:  # Minimum chunk size
                chunks.append(chunk)
    
    print(f"Created {len(chunks)} text chunks")
    
    # Generate embeddings
    embeddings = model.encode(chunks, show_progress_bar=True)
    
    return chunks, embeddings, model

def retrieve_relevant_chunks(query, chunks, embeddings, model, top_k=5):
    """Retrieve most relevant chunks for a query"""
    query_embedding = model.encode([query])
    
    # Calculate similarities
    similarities = cosine_similarity(query_embedding, embeddings)[0]
    
    # Get top-k results
    top_indices = np.argsort(similarities)[-top_k:][::-1]
    
    results = []
    for idx in top_indices:
        results.append({
            'text': chunks[idx],
            'similarity': similarities[idx],
            'rank': len(results) + 1
        })
    
    return results

# Set up RAG system
print("Setting up RAG system...")
chunks, embeddings, model = create_document_embeddings(df['text'].tolist())

# Test retrieval
query = "machine learning algorithms"
relevant_chunks = retrieve_relevant_chunks(query, chunks, embeddings, model)

print(f"\nTop 3 relevant chunks for query: '{query}'")
for i, chunk in enumerate(relevant_chunks[:3]):
    print(f"\nRank {chunk['rank']} (similarity: {chunk['similarity']:.3f}):")
    print(f"{chunk['text'][:200]}...")
```

### 8. Multilingual Analysis

```python
def analyze_multilingual_content():
    """Analyze content across multiple languages"""
    languages_to_analyze = ['eng_Latn', 'spa_Latn', 'fra_Latn', 'deu_Latn']
    language_stats = {}
    
    for lang_code in languages_to_analyze:
        print(f"Analyzing {lang_code}...")
        
        # Load language subset
        lang_dataset = load_dataset("HuggingFaceFW/finepdfs", lang_code, split="train", streaming=True)
        
        # Sample 100 documents
        sample_texts = []
        for i, example in enumerate(lang_dataset):
            if i >= 100:
                break
            sample_texts.append(example['text'])
        
        # Calculate statistics
        avg_length = sum(len(text) for text in sample_texts) / len(sample_texts)
        avg_words = sum(len(text.split()) for text in sample_texts) / len(sample_texts)
        
        language_stats[lang_code] = {
            'avg_length': avg_length,
            'avg_words': avg_words,
            'sample_count': len(sample_texts)
        }
    
    return language_stats

# Analyze multiple languages
multilingual_stats = analyze_multilingual_content()

print("\nMultilingual Analysis Results:")
for lang, stats in multilingual_stats.items():
    print(f"{lang}:")
    print(f"  Average length: {stats['avg_length']:.2f} characters")
    print(f"  Average words: {stats['avg_words']:.2f} words")
    print(f"  Sample count: {stats['sample_count']}")
```

## Advanced Use Cases

### 9. Specialized Domain Extraction

```python
def extract_scientific_papers(texts, threshold=3):
    """Extract texts that appear to be scientific papers"""
    scientific_indicators = [
        'abstract', 'introduction', 'methodology', 'results', 'discussion',
        'conclusion', 'references', 'doi:', 'arxiv:', 'journal',
        'hypothesis', 'experiment', 'analysis', 'statistical'
    ]
    
    scientific_docs = []
    
    for text in texts:
        text_lower = text.lower()
        score = sum(1 for indicator in scientific_indicators if indicator in text_lower)
        
        if score >= threshold:
            scientific_docs.append({
                'text': text,
                'scientific_score': score,
                'length': len(text)
            })
    
    return sorted(scientific_docs, key=lambda x: x['scientific_score'], reverse=True)

# Extract scientific content
scientific_content = extract_scientific_papers(df['text'].tolist())
print(f"Found {len(scientific_content)} scientific documents")

if scientific_content:
    print(f"Top scientific document (score: {scientific_content[0]['scientific_score']}):")
    print(f"{scientific_content[0]['text'][:300]}...")
```

### 10. Data Quality Filtering

```python
def advanced_quality_filter(texts):
    """Apply advanced quality filtering"""
    high_quality_texts = []
    
    for text in texts:
        # Length filters
        if len(text) < 100 or len(text) > 10000:
            continue
            
        # Language coherence (simplified check)
        words = text.split()
        if len(words) < 20:
            continue
            
        # Character diversity
        unique_chars = len(set(text.lower()))
        if unique_chars < 10:  # Too repetitive
            continue
            
        # Avoid mostly numeric content
        numeric_ratio = sum(1 for char in text if char.isdigit()) / len(text)
        if numeric_ratio > 0.3:
            continue
            
        # Check for reasonable sentence structure
        sentences = re.split(r'[.!?]+', text)
        avg_sentence_length = sum(len(s.split()) for s in sentences) / max(len(sentences), 1)
        if avg_sentence_length < 5 or avg_sentence_length > 50:
            continue
            
        high_quality_texts.append(text)
    
    return high_quality_texts

# Apply quality filtering
filtered_texts = advanced_quality_filter(df['text'].tolist())
print(f"Quality filtering: {len(df)} → {len(filtered_texts)} documents")
print(f"Retention rate: {len(filtered_texts)/len(df)*100:.1f}%")
```

## Performance Optimization

### 11. Efficient Data Loading

```python
def efficient_batch_processing(dataset_name, lang_code, batch_size=1000):
    """Process dataset in efficient batches"""
    dataset = load_dataset(dataset_name, lang_code, split="train", streaming=True)
    
    batch = []
    processed_count = 0
    
    for example in dataset:
        batch.append(example['text'])
        
        if len(batch) >= batch_size:
            # Process batch
            yield batch
            batch = []
            processed_count += batch_size
            
            if processed_count % 10000 == 0:
                print(f"Processed {processed_count} documents...")
    
    # Process remaining batch
    if batch:
        yield batch

# Example usage
print("Processing dataset in batches...")
for i, batch in enumerate(efficient_batch_processing("HuggingFaceFW/finepdfs", "eng_Latn")):
    # Process each batch
    print(f"Batch {i+1}: {len(batch)} documents")
    
    # Your processing logic here
    # e.g., filtering, embedding generation, etc.
    
    if i >= 4:  # Process only first 5 batches for demo
        break
```

### 12. Memory-Efficient Analysis

```python
import gc
from typing import Generator

def memory_efficient_analysis(lang_code: str, max_docs: int = 10000) -> dict:
    """Perform analysis with minimal memory footprint"""
    
    dataset = load_dataset("HuggingFaceFW/finepdfs", lang_code, split="train", streaming=True)
    
    # Initialize counters
    stats = {
        'total_docs': 0,
        'total_chars': 0,
        'total_words': 0,
        'domain_counts': Counter(),
        'length_distribution': []
    }
    
    for i, example in enumerate(dataset):
        if i >= max_docs:
            break
            
        text = example['text']
        
        # Update statistics
        stats['total_docs'] += 1
        stats['total_chars'] += len(text)
        stats['total_words'] += len(text.split())
        stats['length_distribution'].append(len(text))
        
        # Domain classification
        domain = classify_document_domain(text)
        stats['domain_counts'][domain] += 1
        
        # Periodic cleanup
        if i % 1000 == 0:
            gc.collect()
    
    # Calculate final metrics
    stats['avg_chars'] = stats['total_chars'] / stats['total_docs']
    stats['avg_words'] = stats['total_words'] / stats['total_docs']
    
    return stats

# Run memory-efficient analysis
analysis_results = memory_efficient_analysis("eng_Latn", max_docs=5000)
print("Memory-efficient analysis results:")
print(f"Documents analyzed: {analysis_results['total_docs']}")
print(f"Average characters: {analysis_results['avg_chars']:.2f}")
print(f"Average words: {analysis_results['avg_words']:.2f}")
print(f"Top domains: {analysis_results['domain_counts'].most_common(5)}")
```

## Integration with ML Workflows

### 13. Hugging Face Transformers Integration

```python
from transformers import AutoTokenizer, AutoModelForCausalLM, TrainingArguments, Trainer
from torch.utils.data import Dataset
import torch

class FinePDFsDataset(Dataset):
    """Custom dataset class for FinePDFs"""
    
    def __init__(self, texts, tokenizer, max_length=512):
        self.texts = texts
        self.tokenizer = tokenizer
        self.max_length = max_length
    
    def __len__(self):
        return len(self.texts)
    
    def __getitem__(self, idx):
        text = self.texts[idx]
        encoding = self.tokenizer(
            text,
            truncation=True,
            padding='max_length',
            max_length=self.max_length,
            return_tensors='pt'
        )
        
        return {
            'input_ids': encoding['input_ids'].flatten(),
            'attention_mask': encoding['attention_mask'].flatten(),
            'labels': encoding['input_ids'].flatten()
        }

# Setup for fine-tuning (example)
model_name = "gpt2"
tokenizer = AutoTokenizer.from_pretrained(model_name)
tokenizer.pad_token = tokenizer.eos_token

# Prepare dataset
train_texts = filtered_texts[:1000]  # Use filtered high-quality texts
train_dataset = FinePDFsDataset(train_texts, tokenizer)

print(f"Created training dataset with {len(train_dataset)} examples")
print("Ready for model fine-tuning!")

# Note: Actual training code would require more setup and computational resources
```

### 14. Evaluation Metrics

```python
def evaluate_dataset_quality(texts):
    """Comprehensive quality evaluation"""
    
    metrics = {
        'readability': [],
        'information_density': [],
        'language_consistency': [],
        'structural_quality': []
    }
    
    for text in texts[:100]:  # Sample evaluation
        
        # Readability (simplified - based on sentence length)
        sentences = re.split(r'[.!?]+', text)
        avg_sent_len = sum(len(s.split()) for s in sentences) / max(len(sentences), 1)
        readability_score = 1.0 / (1.0 + abs(avg_sent_len - 15) / 10)  # Optimal ~15 words
        metrics['readability'].append(readability_score)
        
        # Information density (unique words / total words)
        words = text.lower().split()
        density = len(set(words)) / max(len(words), 1)
        metrics['information_density'].append(density)
        
        # Language consistency (alphabet character ratio)
        alpha_chars = sum(1 for c in text if c.isalpha())
        consistency = alpha_chars / max(len(text), 1)
        metrics['language_consistency'].append(consistency)
        
        # Structural quality (paragraph and formatting indicators)
        structure_indicators = ['\n\n', '. ', ', ', ': ', '; ']
        structure_score = sum(text.count(ind) for ind in structure_indicators) / len(text)
        metrics['structural_quality'].append(min(structure_score * 100, 1.0))
    
    # Calculate averages
    avg_metrics = {k: sum(v) / len(v) for k, v in metrics.items()}
    
    return avg_metrics

# Evaluate quality
quality_scores = evaluate_dataset_quality(df['text'].tolist())
print("Dataset Quality Evaluation:")
for metric, score in quality_scores.items():
    print(f"{metric}: {score:.3f}")

# Overall quality score
overall_quality = sum(quality_scores.values()) / len(quality_scores)
print(f"Overall Quality Score: {overall_quality:.3f}")
```

## Troubleshooting and Best Practices

### Common Issues and Solutions

1. **Memory Errors**
   ```python
   # Use streaming=True for large datasets
   dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", streaming=True)
   
   # Process in batches
   for batch in efficient_batch_processing("HuggingFaceFW/finepdfs", "eng_Latn", batch_size=500):
       process_batch(batch)
   ```

2. **Slow Loading**
   ```python
   # Cache dataset locally
   dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", cache_dir="./cache")
   
   # Use specific number of processes
   dataset = dataset.map(preprocess_function, num_proc=4)
   ```

3. **Text Encoding Issues**
   ```python
   def clean_text_encoding(text):
       """Clean common encoding issues"""
       # Fix common unicode issues
       text = text.encode('utf-8', errors='ignore').decode('utf-8')
       # Remove or replace problematic characters
       text = re.sub(r'[^\w\s\.\,\!\?\;\:\-\(\)]', ' ', text)
       return text
   ```

### Best Practices

1. **Data Sampling**: Always start with a small sample to understand the data structure
2. **Quality Filtering**: Implement multiple quality filters to ensure high-quality training data
3. **Batch Processing**: Use batch processing for memory efficiency
4. **Domain-Specific Extraction**: Filter for specific domains relevant to your use case
5. **Multilingual Considerations**: Be aware of language-specific characteristics when processing

## Conclusion

FinePDFs represents a valuable resource for the machine learning community, providing access to high-quality, multilingual textual content extracted from PDFs. This tutorial has covered:

- Loading and exploring the dataset structure
- Implementing quality assessment and filtering
- Preparing data for various ML applications
- Setting up RAG systems and fine-tuning workflows
- Optimizing performance for large-scale processing

The dataset's diversity in languages and domains makes it particularly valuable for:
- **Language Model Training**: Pre-training and fine-tuning multilingual models
- **Domain Adaptation**: Specializing models for scientific, legal, or technical domains
- **Retrieval Systems**: Building comprehensive knowledge bases
- **Cross-lingual Research**: Studying linguistic patterns across different languages

Remember to always respect the ODC-By license terms and consider the computational requirements when working with this large-scale dataset.

## Additional Resources

- [FinePDFs Dataset Page](https://huggingface.co/datasets/HuggingFaceFW/finepdfs)
- [HuggingFace Datasets Documentation](https://huggingface.co/docs/datasets/)
- [Transformers Library](https://huggingface.co/transformers/)
- [Dataset Licensing Information](https://opendatacommons.org/licenses/by/1-0/)

---

*This tutorial provides a comprehensive starting point for working with FinePDFs. As you develop your specific use cases, adapt these examples to meet your requirements and computational constraints.*
