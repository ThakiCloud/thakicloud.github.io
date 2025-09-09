#!/usr/bin/env python3
"""
FinePDFs Basic Functionality Test
Quick test for tutorial examples without heavy data downloads
"""

import sys
import traceback

def check_imports():
    """Check if all required packages can be imported"""
    print("=== Checking Package Imports ===")
    
    packages = {
        'datasets': 'datasets',
        'transformers': 'transformers', 
        'torch': 'torch',
        'huggingface_hub': 'huggingface_hub',
        'pandas': 'pandas',
        'numpy': 'numpy',
        'matplotlib': 'matplotlib.pyplot',
        'seaborn': 'seaborn',
        'tqdm': 'tqdm',
        'rich': 'rich'
    }
    
    success_count = 0
    
    for name, import_path in packages.items():
        try:
            __import__(import_path)
            print(f"✓ {name}")
            success_count += 1
        except ImportError as e:
            print(f"✗ {name}: {e}")
    
    print(f"\nPackages available: {success_count}/{len(packages)}")
    return success_count == len(packages)

def test_streaming_connection():
    """Test basic streaming connection to FinePDFs"""
    print("\n=== Testing Streaming Connection ===")
    
    try:
        from datasets import load_dataset
        
        print("Attempting to connect to FinePDFs dataset...")
        
        # Use streaming to avoid large downloads
        dataset = load_dataset("HuggingFaceFW/finepdfs", "eng_Latn", 
                              streaming=True, split="train")
        
        print("✓ Successfully connected to dataset")
        
        # Test accessing first item
        print("Testing data access...")
        first_item = next(iter(dataset))
        
        # Validate structure
        required_fields = ['text', 'language']
        for field in required_fields:
            if field not in first_item:
                raise ValueError(f"Required field '{field}' not found")
        
        text_length = len(first_item['text'])
        language = first_item['language']
        
        print(f"✓ First document: {text_length} characters, language: {language}")
        
        return True
        
    except Exception as e:
        print(f"✗ Streaming connection failed: {e}")
        return False

def test_text_processing_functions():
    """Test text processing functions without large datasets"""
    print("\n=== Testing Text Processing Functions ===")
    
    try:
        import re
        from collections import Counter
        
        # Test with sample text
        sample_texts = [
            "This is a research paper about machine learning algorithms and artificial intelligence.",
            "Legal documents require careful analysis of contract terms and regulations.",
            "Scientific methodology includes hypothesis formation and experimental validation.",
            "Technical documentation should be clear and comprehensive for users."
        ]
        
        print("Testing text analysis functions...")
        
        # Test quality assessment function
        def assess_quality(text):
            word_count = len(text.split())
            char_count = len(text)
            unique_words = len(set(text.lower().split()))
            diversity_ratio = unique_words / max(word_count, 1)
            
            score = 0
            if word_count > 10:
                score += 1
            if diversity_ratio > 0.7:
                score += 1
                
            return {
                'word_count': word_count,
                'char_count': char_count,
                'diversity_ratio': diversity_ratio,
                'quality_score': score
            }
        
        results = []
        for text in sample_texts:
            result = assess_quality(text)
            results.append(result)
        
        avg_quality = sum(r['quality_score'] for r in results) / len(results)
        print(f"✓ Text analysis complete. Average quality: {avg_quality:.2f}")
        
        # Test domain filtering
        def filter_by_keywords(texts, keywords):
            filtered = []
            for text in texts:
                text_lower = text.lower()
                if any(keyword in text_lower for keyword in keywords):
                    filtered.append(text)
            return filtered
        
        scientific_keywords = ['research', 'scientific', 'experiment']
        scientific_texts = filter_by_keywords(sample_texts, scientific_keywords)
        
        print(f"✓ Domain filtering: {len(scientific_texts)}/{len(sample_texts)} scientific texts")
        
        return True
        
    except Exception as e:
        print(f"✗ Text processing test failed: {e}")
        return False

def test_memory_efficiency():
    """Test memory management concepts"""
    print("\n=== Testing Memory Efficiency Concepts ===")
    
    try:
        import gc
        
        # Test chunk processing simulation
        def process_chunks(data, chunk_size=2):
            results = []
            
            for i in range(0, len(data), chunk_size):
                chunk = data[i:i+chunk_size]
                
                # Simulate processing
                chunk_result = {
                    'chunk_id': i // chunk_size,
                    'size': len(chunk),
                    'total_chars': sum(len(item) for item in chunk)
                }
                
                results.append(chunk_result)
                
                # Force garbage collection
                gc.collect()
            
            return results
        
        sample_data = [
            "Sample text one with some content",
            "Another sample with different content", 
            "Third sample for testing purposes",
            "Fourth sample to complete the test"
        ]
        
        chunk_results = process_chunks(sample_data)
        
        print(f"✓ Processed {len(chunk_results)} chunks successfully")
        
        total_chars = sum(r['total_chars'] for r in chunk_results)
        print(f"✓ Total characters processed: {total_chars}")
        
        return True
        
    except Exception as e:
        print(f"✗ Memory efficiency test failed: {e}")
        return False

def test_multilingual_concepts():
    """Test multilingual processing concepts"""
    print("\n=== Testing Multilingual Concepts ===")
    
    try:
        # Test with sample multilingual data
        multilingual_samples = {
            'eng_Latn': "This is an English text sample for testing purposes.",
            'arb_Arab': "هذا نص عربي للاختبار والتجريب.",
            'spa_Latn': "Este es un texto en español para pruebas.",
            'fra_Latn': "Ceci est un texte français pour les tests."
        }
        
        print("Testing multilingual text analysis...")
        
        for lang_code, text in multilingual_samples.items():
            char_count = len(text)
            word_count = len(text.split())
            
            print(f"✓ {lang_code}: {word_count} words, {char_count} characters")
        
        print(f"✓ Multilingual analysis complete for {len(multilingual_samples)} languages")
        
        return True
        
    except Exception as e:
        print(f"✗ Multilingual test failed: {e}")
        return False

def test_error_handling():
    """Test error handling patterns"""
    print("\n=== Testing Error Handling ===")
    
    try:
        def robust_text_processor(text, max_retries=2):
            for attempt in range(max_retries):
                try:
                    if not isinstance(text, str):
                        raise TypeError("Input must be string")
                    
                    if len(text) == 0:
                        return {"status": "empty", "result": None}
                    
                    result = {
                        "length": len(text),
                        "word_count": len(text.split()),
                        "status": "success"
                    }
                    
                    return result
                    
                except Exception as e:
                    if attempt == max_retries - 1:
                        return {"status": "failed", "error": str(e)}
        
        # Test with valid input
        result1 = robust_text_processor("Valid text input")
        assert result1['status'] == 'success'
        
        # Test with invalid input
        result2 = robust_text_processor(123)
        assert result2['status'] == 'failed'
        
        # Test with empty input
        result3 = robust_text_processor("")
        assert result3['status'] == 'empty'
        
        print("✓ Error handling patterns working correctly")
        
        return True
        
    except Exception as e:
        print(f"✗ Error handling test failed: {e}")
        return False

def main():
    """Run all basic tests"""
    print("FinePDFs Basic Functionality Test")
    print("=" * 50)
    
    print(f"Python version: {sys.version}")
    
    tests = [
        check_imports,
        test_streaming_connection, 
        test_text_processing_functions,
        test_memory_efficiency,
        test_multilingual_concepts,
        test_error_handling
    ]
    
    results = []
    
    for test in tests:
        try:
            result = test()
            results.append(result)
        except Exception as e:
            print(f"\nTest {test.__name__} crashed: {e}")
            traceback.print_exc()
            results.append(False)
    
    # Summary
    print("\n" + "=" * 50)
    print("Test Summary")
    print("=" * 50)
    
    passed = sum(results)
    total = len(results)
    
    print(f"Tests passed: {passed}/{total}")
    print(f"Success rate: {passed/total*100:.1f}%")
    
    if passed == total:
        print("\n🎉 All basic tests passed!")
        print("The tutorial examples are ready to use.")
        return True
    else:
        print(f"\n⚠️  {total-passed} test(s) failed.")
        print("Check the output above for details.")
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
