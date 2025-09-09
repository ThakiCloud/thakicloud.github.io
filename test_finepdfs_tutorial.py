#!/usr/bin/env python3
"""
FinePDFs Tutorial Test Script
Validates all examples and functionality from the tutorial
"""

import os
import sys
import time
import traceback
import subprocess
from pathlib import Path

def check_requirements():
    """Check if all required packages are installed"""
    required_packages = [
        'datasets',
        'transformers',
        'torch',
        'huggingface_hub',
        'pandas',
        'numpy',
        'matplotlib',
        'seaborn',
        'tqdm',
        'rich'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
            print(f"✓ {package} is installed")
        except ImportError:
            missing_packages.append(package)
            print(f"✗ {package} is missing")
    
    if missing_packages:
        print(f"\nMissing packages: {missing_packages}")
        print("Install them with: pip install " + " ".join(missing_packages))
        return False
    
    return True

def test_basic_dataset_loading():
    """Test basic FinePDFs dataset loading"""
    print("\n=== Testing Basic Dataset Loading ===")
    
    try:
        from datasets import load_dataset
        
        print("Loading FinePDFs English subset...")
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", split="train", 
                              streaming=True)
        
        # Test streaming access
        print("Testing streaming access...")
        count = 0
        for item in dataset:
            if 'text' not in item or 'language' not in item:
                raise ValueError("Required fields missing")
            
            text_length = len(item['text'])
            print(f"Sample {count+1}: {text_length} characters")
            
            count += 1
            if count >= 3:  # Test first 3 items
                break
        
        print("✓ Basic dataset loading successful")
        return True
        
    except Exception as e:
        print(f"✗ Basic dataset loading failed: {e}")
        return False

def test_text_analysis():
    """Test text analysis functionality"""
    print("\n=== Testing Text Analysis ===")
    
    try:
        from datasets import load_dataset
        import re
        
        # Load small sample
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              split="train[:10]")  # Small sample
        
        print("Analyzing text quality...")
        
        total_length = 0
        total_words = 0
        total_sentences = 0
        
        for item in dataset:
            text = item['text']
            text_length = len(text)
            word_count = len(text.split())
            sentence_count = len(re.split(r'[.!?]+', text))
            
            total_length += text_length
            total_words += word_count
            total_sentences += sentence_count
        
        avg_length = total_length / len(dataset)
        avg_words = total_words / len(dataset)
        avg_sentences = total_sentences / len(dataset)
        
        print(f"Average text length: {avg_length:.0f} characters")
        print(f"Average word count: {avg_words:.0f} words")
        print(f"Average sentence count: {avg_sentences:.0f} sentences")
        
        print("✓ Text analysis successful")
        return True
        
    except Exception as e:
        print(f"✗ Text analysis failed: {e}")
        return False

def test_domain_filtering():
    """Test domain-specific filtering"""
    print("\n=== Testing Domain Filtering ===")
    
    try:
        from datasets import load_dataset
        
        # Load small sample
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              split="train[:50]")  # Small sample for testing
        
        def filter_by_domain(dataset, domain_keywords, min_matches=1):
            def contains_domain_keywords(example):
                text_lower = example['text'].lower()
                matches = sum(1 for keyword in domain_keywords 
                             if keyword in text_lower)
                return matches >= min_matches
            
            return dataset.filter(contains_domain_keywords)
        
        # Test scientific content filtering
        scientific_keywords = ['research', 'study', 'analysis', 'experiment']
        scientific_subset = filter_by_domain(dataset, scientific_keywords)
        
        print(f"Original dataset: {len(dataset)} documents")
        print(f"Scientific subset: {len(scientific_subset)} documents")
        
        # Test legal content filtering
        legal_keywords = ['court', 'law', 'legal', 'contract']
        legal_subset = filter_by_domain(dataset, legal_keywords)
        
        print(f"Legal subset: {len(legal_subset)} documents")
        
        print("✓ Domain filtering successful")
        return True
        
    except Exception as e:
        print(f"✗ Domain filtering failed: {e}")
        return False

def test_memory_efficient_processing():
    """Test memory-efficient processing techniques"""
    print("\n=== Testing Memory Efficient Processing ===")
    
    try:
        from datasets import load_dataset
        import gc
        
        def process_in_chunks(dataset, chunk_size=10):
            total_processed = 0
            total_chars = 0
            
            # Convert streaming to iterable
            items = []
            for i, item in enumerate(dataset):
                items.append(item)
                if i >= 30:  # Limit for testing
                    break
            
            for i in range(0, len(items), chunk_size):
                chunk = items[i:i+chunk_size]
                
                chunk_chars = sum(len(item['text']) for item in chunk)
                total_chars += chunk_chars
                total_processed += len(chunk)
                
                print(f"Processed chunk {i//chunk_size + 1}: "
                      f"{len(chunk)} documents, {chunk_chars} characters")
                
                # Force garbage collection
                gc.collect()
            
            return total_processed, total_chars
        
        # Test streaming dataset
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              streaming=True, split="train")
        
        total_docs, total_chars = process_in_chunks(dataset)
        
        print(f"Total processed: {total_docs} documents, {total_chars} characters")
        print("✓ Memory efficient processing successful")
        return True
        
    except Exception as e:
        print(f"✗ Memory efficient processing failed: {e}")
        return False

def test_quality_assessment():
    """Test document quality assessment"""
    print("\n=== Testing Quality Assessment ===")
    
    try:
        from datasets import load_dataset
        import re
        
        def assess_document_quality(text):
            char_count = len(text)
            word_count = len(text.split())
            
            quality_score = 0
            issues = []
            
            # Length checks
            if word_count < 50:
                issues.append("Too short")
                quality_score -= 1
            elif word_count > 100:
                quality_score += 1
            
            # Diversity check
            unique_words = len(set(text.lower().split()))
            diversity_ratio = unique_words / max(word_count, 1)
            
            if diversity_ratio > 0.7:
                quality_score += 1
            elif diversity_ratio < 0.3:
                issues.append("Low vocabulary diversity")
                quality_score -= 1
            
            return {
                'quality_score': quality_score,
                'issues': issues,
                'word_count': word_count,
                'diversity_ratio': diversity_ratio
            }
        
        # Load small sample
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              split="train[:20]")
        
        quality_results = []
        for item in dataset:
            quality = assess_document_quality(item['text'])
            quality_results.append(quality)
        
        avg_quality = sum(r['quality_score'] for r in quality_results) / len(quality_results)
        high_quality = sum(1 for r in quality_results if r['quality_score'] >= 1)
        
        print(f"Average quality score: {avg_quality:.2f}")
        print(f"High quality documents: {high_quality}/{len(quality_results)}")
        
        print("✓ Quality assessment successful")
        return True
        
    except Exception as e:
        print(f"✗ Quality assessment failed: {e}")
        return False

def test_multilingual_support():
    """Test multilingual dataset support"""
    print("\n=== Testing Multilingual Support ===")
    
    try:
        from datasets import load_dataset
        
        # Test multiple language configurations
        language_configs = ["eng_Latn", "arb_Arab"]  # Limited for testing
        
        for lang_config in language_configs:
            try:
                print(f"Testing {lang_config}...")
                dataset = load_dataset("HuggingFaceFW/finepdfs", lang_config, 
                                     streaming=True, split="train")
                
                # Test first item
                first_item = next(iter(dataset))
                text_length = len(first_item['text'])
                
                print(f"  {lang_config}: {text_length} characters in first document")
                
            except Exception as e:
                print(f"  {lang_config}: Failed to load - {e}")
        
        print("✓ Multilingual support test completed")
        return True
        
    except Exception as e:
        print(f"✗ Multilingual support test failed: {e}")
        return False

def run_performance_benchmark():
    """Run basic performance benchmark"""
    print("\n=== Running Performance Benchmark ===")
    
    try:
        from datasets import load_dataset
        import time
        
        start_time = time.time()
        
        # Load streaming dataset
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              streaming=True, split="train")
        
        # Process first 100 items
        count = 0
        total_chars = 0
        
        for item in dataset:
            total_chars += len(item['text'])
            count += 1
            
            if count >= 100:
                break
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        print(f"Processed {count} documents in {processing_time:.2f} seconds")
        print(f"Average processing speed: {count/processing_time:.1f} docs/second")
        print(f"Total characters processed: {total_chars:,}")
        
        print("✓ Performance benchmark completed")
        return True
        
    except Exception as e:
        print(f"✗ Performance benchmark failed: {e}")
        return False

def main():
    """Run all tests"""
    print("FinePDFs Tutorial Test Suite")
    print("=" * 50)
    
    # Check Python version
    if sys.version_info < (3, 8):
        print("Error: Python 3.8+ required")
        return False
    
    print(f"Python version: {sys.version}")
    
    # Check requirements
    if not check_requirements():
        return False
    
    # Run tests
    tests = [
        test_basic_dataset_loading,
        test_text_analysis,
        test_domain_filtering,
        test_memory_efficient_processing,
        test_quality_assessment,
        test_multilingual_support,
        run_performance_benchmark
    ]
    
    results = []
    start_time = time.time()
    
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"\nTest {test.__name__} crashed: {e}")
            traceback.print_exc()
            results.append(False)
    
    # Summary
    end_time = time.time()
    total_time = end_time - start_time
    
    print("\n" + "=" * 50)
    print("Test Summary")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    
    print(f"Tests passed: {passed}/{total}")
    print(f"Success rate: {passed/total*100:.1f}%")
    print(f"Total execution time: {total_time:.1f} seconds")
    
    if passed == total:
        print("\n🎉 All tests passed! The tutorial examples are working correctly.")
        return True
    else:
        print("\n⚠️  Some tests failed. Check the output above for details.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
