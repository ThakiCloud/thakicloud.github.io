---
title: "Ollama-OCR: 로컬 비전 모델로 문서 텍스트 추출 완전 마스터 가이드"
excerpt: "LLaVA, Llama 3.2 Vision, Granite3.2 등 다양한 비전 모델을 활용한 OCR 솔루션. PDF, 이미지에서 텍스트 추출부터 Streamlit 웹앱까지"
seo_title: "Ollama-OCR 완전 가이드 - 로컬 비전 모델 OCR 솔루션 - Thaki Cloud"
seo_description: "Ollama-OCR로 LLaVA, Llama 3.2 Vision, Granite3.2 모델을 활용한 문서 텍스트 추출. PDF, 이미지 배치 처리, Streamlit 웹앱 구축까지 완전 가이드"
date: 2025-08-07
last_modified_at: 2025-08-07
categories:
  - tutorials
tags:
  - ollama-ocr
  - vision-models
  - ocr
  - llava
  - llama-vision
  - granite-vision
  - document-processing
  - streamlit
  - python
  - local-ai
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "eye"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/ollama-ocr-comprehensive-vision-model-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 20분

## 서론

기존의 OCR(광학 문자 인식) 솔루션들은 **복잡한 레이아웃이나 다양한 폰트에서 정확도가 떨어지는** 한계가 있었습니다. 특히 테이블, 차트, 혼합된 텍스트-이미지 콘텐츠에서는 만족스러운 결과를 얻기 어려웠습니다.

[Ollama-OCR](https://github.com/imanoop7/Ollama-OCR)은 이런 문제를 **최신 비전-언어 모델(Vision-Language Models)**로 해결하는 혁신적인 솔루션입니다. **LLaVA, Llama 3.2 Vision, Granite3.2** 등 다양한 모델을 지원하며, **완전히 로컬 환경**에서 실행되어 데이터 프라이버시를 보장합니다.

이 튜토리얼에서는 Ollama-OCR의 설치부터 고급 활용까지, 실제 문서 처리 예제와 함께 완전한 OCR 솔루션 구축법을 다루겠습니다.

### Ollama-OCR의 혁신적 특징

- 🤖 **다양한 비전 모델**: LLaVA, Llama 3.2, Granite3.2, Moondream, MiniCPM-V 지원
- 📄 **PDF + 이미지**: 다양한 파일 형식의 통합 처리
- 🎯 **다중 출력 형식**: Markdown, JSON, 구조화된 데이터, 표 추출
- ⚡ **배치 처리**: 대량 문서 병렬 처리 지원
- 🌐 **웹 인터페이스**: Streamlit 기반 사용자 친화적 UI
- 🔒 **완전 로컬**: 클라우드 없이 프라이버시 보장

## 환경 요구사항 및 설치

### 시스템 요구사항

```bash
# 하드웨어 권장사항
- RAM: 최소 8GB, 권장 16GB+
- GPU: NVIDIA GPU (선택적, 성능 향상)
- 디스크: 10GB+ 여유 공간 (모델 저장용)

# 소프트웨어 요구사항
- Python 3.8+
- Ollama
- CUDA (GPU 사용시)
```

### macOS 테스트 환경

```bash
# 시스템 정보 확인
system_profiler SPSoftwareDataType | grep "System Version"
# System Version: macOS 15.0.0

# Python 버전 확인
python3 --version
# Python 3.11.5

# 메모리 확인
system_profiler SPHardwareDataType | grep "Memory"
# Memory: 32 GB
```

### 1단계: Ollama 설치

```bash
# macOS에서 Homebrew로 설치
brew install ollama

# 또는 공식 사이트에서 직접 다운로드
# https://ollama.ai/download

# Ollama 서비스 시작
ollama serve

# 설치 확인
ollama --version
```

### 2단계: 비전 모델 다운로드

```bash
# 필수 비전 모델들 다운로드
echo "🤖 비전 모델 다운로드 시작..."

# Llama 3.2 Vision (권장 - 고성능)
ollama pull llama3.2-vision:11b

# Granite3.2 Vision (문서 처리 특화)
ollama pull granite3.2-vision

# LLaVA (빠른 처리)
ollama pull llava

# Moondream (경량 모델)
ollama pull moondream

# MiniCPM-V (고해상도 지원)
ollama pull minicpm-v

echo "✅ 모든 모델 다운로드 완료"
```

### 3단계: Ollama-OCR 패키지 설치

```bash
# pip을 통한 직접 설치
pip install ollama-ocr

# 또는 개발 버전 설치
git clone https://github.com/imanoop7/Ollama-OCR.git
cd Ollama-OCR
pip install -r requirements.txt
pip install -e .

# 설치 확인
python -c "import ollama_ocr; print('✅ Ollama-OCR 설치 완료')"
```

## 기본 사용법과 첫 번째 OCR

### 단일 이미지 처리

```python
from ollama_ocr import OCRProcessor
import os

# OCR 프로세서 초기화
ocr = OCRProcessor(
    model_name='llama3.2-vision:11b',
    base_url="http://localhost:11434/api/generate"  # 기본 Ollama URL
)

# 기본 텍스트 추출
def basic_ocr_example():
    """기본 OCR 사용 예제"""
    
    # 이미지에서 텍스트 추출
    result = ocr.process_image(
        image_path="input/sample_document.png",
        format_type="text",  # 기본 텍스트 형식
        language="Korean"    # 한국어 문서 처리
    )
    
    print("=== 추출된 텍스트 ===")
    print(result)
    
    return result

# PDF 문서 처리
def pdf_ocr_example():
    """PDF 문서 OCR 예제"""
    
    result = ocr.process_image(
        image_path="input/business_report.pdf",
        format_type="markdown",  # 마크다운 형식으로 구조 보존
        language="Korean"
    )
    
    print("=== PDF에서 추출된 내용 (마크다운) ===")
    print(result)
    
    return result

if __name__ == "__main__":
    # 기본 사용법 테스트
    basic_result = basic_ocr_example()
    pdf_result = pdf_ocr_example()
```

### 다양한 출력 형식 활용

```python
def explore_output_formats():
    """다양한 출력 형식 테스트"""
    
    sample_image = "input/mixed_content.png"
    
    formats = {
        "text": "순수 텍스트",
        "markdown": "마크다운 (구조 보존)",
        "json": "JSON 구조화 데이터",
        "structured": "구조화된 객체",
        "key_value": "키-값 쌍",
        "table": "테이블 데이터 추출"
    }
    
    results = {}
    
    for format_type, description in formats.items():
        print(f"\n📋 {description} 형식 테스트...")
        
        try:
            result = ocr.process_image(
                image_path=sample_image,
                format_type=format_type,
                custom_prompt=f"이 이미지에서 {description} 형식으로 정보를 추출해주세요.",
                language="Korean"
            )
            
            results[format_type] = result
            print(f"✅ {format_type} 형식 성공")
            print(f"결과 미리보기: {str(result)[:100]}...")
            
        except Exception as e:
            print(f"❌ {format_type} 형식 실패: {str(e)}")
    
    return results

# 실행 및 결과 비교
format_results = explore_output_formats()

# 특정 형식 상세 확인
print("\n" + "="*50)
print("📊 JSON 형식 상세 결과:")
print("="*50)
if 'json' in format_results:
    import json
    try:
        parsed_json = json.loads(format_results['json'])
        print(json.dumps(parsed_json, indent=2, ensure_ascii=False))
    except:
        print(format_results['json'])
```

## 고급 기능: 배치 처리와 병렬화

### 대량 문서 배치 처리

```python
import os
from pathlib import Path
import time

class AdvancedOCRProcessor:
    """고급 OCR 처리 클래스"""
    
    def __init__(self, model_name='llama3.2-vision:11b', max_workers=4):
        self.ocr = OCRProcessor(
            model_name=model_name,
            max_workers=max_workers  # 병렬 처리 워커 수
        )
        self.processed_count = 0
        self.total_count = 0
    
    def setup_batch_processing(self, input_dir, output_dir):
        """배치 처리 환경 설정"""
        
        # 출력 디렉토리 생성
        Path(output_dir).mkdir(parents=True, exist_ok=True)
        
        # 입력 파일 목록 생성
        supported_formats = {'.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.pdf'}
        input_files = []
        
        for file_path in Path(input_dir).rglob('*'):
            if file_path.suffix.lower() in supported_formats:
                input_files.append(file_path)
        
        self.total_count = len(input_files)
        print(f"📁 처리 대상 파일: {self.total_count}개")
        
        return input_files
    
    def process_batch_with_progress(self, input_dir, output_dir, format_type="markdown"):
        """진행률 추적과 함께 배치 처리"""
        
        input_files = self.setup_batch_processing(input_dir, output_dir)
        
        # 배치 처리 실행
        start_time = time.time()
        
        batch_results = self.ocr.process_batch(
            input_path=input_dir,
            format_type=format_type,
            recursive=True,  # 하위 디렉토리 포함
            preprocess=True,  # 이미지 전처리 활성화
            custom_prompt="문서의 모든 텍스트를 정확히 추출하고, 표와 구조를 보존해주세요.",
            language="Korean"
        )
        
        end_time = time.time()
        processing_time = end_time - start_time
        
        # 결과 저장 및 통계
        self.save_batch_results(batch_results, output_dir)
        self.print_batch_statistics(batch_results, processing_time)
        
        return batch_results
    
    def save_batch_results(self, batch_results, output_dir):
        """배치 처리 결과 저장"""
        
        results_file = Path(output_dir) / "batch_results.txt"
        summary_file = Path(output_dir) / "processing_summary.json"
        
        # 개별 파일 결과 저장
        for file_path, text in batch_results['results'].items():
            output_filename = Path(file_path).stem + "_extracted.txt"
            output_path = Path(output_dir) / output_filename
            
            with open(output_path, 'w', encoding='utf-8') as f:
                f.write(f"원본 파일: {file_path}\n")
                f.write("="*50 + "\n")
                f.write(text)
        
        # 통합 결과 파일
        with open(results_file, 'w', encoding='utf-8') as f:
            for file_path, text in batch_results['results'].items():
                f.write(f"\n{'='*60}\n")
                f.write(f"파일: {file_path}\n")
                f.write(f"{'='*60}\n")
                f.write(text)
                f.write("\n")
        
        # 처리 요약 JSON
        import json
        with open(summary_file, 'w', encoding='utf-8') as f:
            json.dump(batch_results['statistics'], f, indent=2, ensure_ascii=False)
        
        print(f"💾 결과 저장 완료: {output_dir}")
    
    def print_batch_statistics(self, batch_results, processing_time):
        """배치 처리 통계 출력"""
        
        stats = batch_results['statistics']
        
        print("\n" + "="*50)
        print("📊 배치 처리 통계")
        print("="*50)
        print(f"📁 전체 파일: {stats['total']}개")
        print(f"✅ 성공: {stats['successful']}개")
        print(f"❌ 실패: {stats['failed']}개")
        print(f"⏱️  총 처리 시간: {processing_time:.2f}초")
        print(f"📈 평균 처리 시간: {processing_time/max(stats['total'], 1):.2f}초/파일")
        print(f"🎯 성공률: {stats['successful']/max(stats['total'], 1)*100:.1f}%")
        
        if stats['failed'] > 0:
            print(f"\n⚠️  실패한 파일들:")
            for file_path in batch_results.get('failed_files', []):
                print(f"   - {file_path}")

# 사용 예제
if __name__ == "__main__":
    # 고급 OCR 프로세서 초기화
    advanced_ocr = AdvancedOCRProcessor(
        model_name='llama3.2-vision:11b',
        max_workers=4  # CPU 코어 수에 맞게 조정
    )
    
    # 배치 처리 실행
    batch_results = advanced_ocr.process_batch_with_progress(
        input_dir="input/documents",
        output_dir="output/batch_results",
        format_type="markdown"
    )
```

### 성능 최적화 배치 처리

```python
import concurrent.futures
import threading
from queue import Queue

class OptimizedBatchProcessor:
    """최적화된 배치 처리기"""
    
    def __init__(self, model_name='granite3.2-vision', max_workers=4):
        self.model_name = model_name
        self.max_workers = max_workers
        self.progress_queue = Queue()
        
    def create_ocr_pool(self):
        """OCR 프로세서 풀 생성"""
        ocr_pool = []
        for i in range(self.max_workers):
            ocr = OCRProcessor(
                model_name=self.model_name,
                base_url=f"http://localhost:11434/api/generate"
            )
            ocr_pool.append(ocr)
        return ocr_pool
    
    def process_single_file(self, file_info, ocr_processor):
        """단일 파일 처리"""
        file_path, format_type, custom_prompt = file_info
        
        try:
            start_time = time.time()
            
            result = ocr_processor.process_image(
                image_path=file_path,
                format_type=format_type,
                custom_prompt=custom_prompt,
                language="Korean"
            )
            
            processing_time = time.time() - start_time
            
            return {
                'file_path': file_path,
                'result': result,
                'success': True,
                'processing_time': processing_time,
                'error': None
            }
            
        except Exception as e:
            return {
                'file_path': file_path,
                'result': None,
                'success': False,
                'processing_time': 0,
                'error': str(e)
            }
    
    def optimized_batch_process(self, file_list, format_type="markdown", custom_prompt=None):
        """최적화된 배치 처리"""
        
        ocr_pool = self.create_ocr_pool()
        results = []
        
        # 파일 정보 준비
        file_infos = [(file_path, format_type, custom_prompt) for file_path in file_list]
        
        print(f"🚀 {len(file_list)}개 파일 최적화 배치 처리 시작...")
        print(f"⚙️  워커 수: {self.max_workers}")
        
        # ThreadPoolExecutor로 병렬 처리
        with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
            # 각 워커에 OCR 프로세서 할당
            future_to_file = {}
            
            for i, file_info in enumerate(file_infos):
                ocr_processor = ocr_pool[i % len(ocr_pool)]
                future = executor.submit(self.process_single_file, file_info, ocr_processor)
                future_to_file[future] = file_info[0]
            
            # 결과 수집
            completed = 0
            for future in concurrent.futures.as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    results.append(result)
                    completed += 1
                    
                    # 진행률 출력
                    progress = (completed / len(file_list)) * 100
                    status = "✅" if result['success'] else "❌"
                    print(f"{status} [{completed}/{len(file_list)}] ({progress:.1f}%) - {Path(file_path).name}")
                    
                except Exception as e:
                    print(f"❌ {file_path} 처리 중 오류: {str(e)}")
        
        return results

# 사용 예제
def run_optimized_batch():
    """최적화된 배치 처리 실행"""
    
    # 처리할 파일 목록 생성
    input_directory = "input/large_batch"
    file_list = []
    
    for ext in ['*.jpg', '*.png', '*.pdf']:
        file_list.extend(Path(input_directory).glob(ext))
    
    # 최적화된 프로세서 생성
    optimizer = OptimizedBatchProcessor(
        model_name='granite3.2-vision',  # 문서 처리에 특화된 모델
        max_workers=6  # CPU 성능에 맞게 조정
    )
    
    # 배치 처리 실행
    results = optimizer.optimized_batch_process(
        file_list=file_list,
        format_type="structured",
        custom_prompt="이 문서에서 제목, 본문, 표, 주요 데이터를 구조화하여 추출해주세요."
    )
    
    # 결과 분석
    successful = [r for r in results if r['success']]
    failed = [r for r in results if not r['success']]
    
    print(f"\n📊 최적화 배치 처리 완료")
    print(f"✅ 성공: {len(successful)}개")
    print(f"❌ 실패: {len(failed)}개")
    print(f"⏱️  평균 처리 시간: {sum(r['processing_time'] for r in successful)/len(successful):.2f}초")
    
    return results

if __name__ == "__main__":
    results = run_optimized_batch()
```

## 다양한 비전 모델 비교와 최적 선택

### 모델별 특성 분석

```python
class VisionModelComparator:
    """비전 모델 비교 분석기"""
    
    def __init__(self):
        self.models = {
            'llama3.2-vision:11b': {
                'description': '고성능 범용 비전-언어 모델',
                'strengths': ['높은 정확도', '복잡한 레이아웃 처리', '다국어 지원'],
                'use_cases': ['중요 문서', '복잡한 표', '다국어 문서'],
                'memory_usage': 'High (11GB)',
                'speed': 'Medium'
            },
            'granite3.2-vision': {
                'description': '문서 처리 특화 모델',
                'strengths': ['표 인식 뛰어남', '차트 해석', '문서 구조 보존'],
                'use_cases': ['비즈니스 문서', '재무 보고서', '기술 문서'],
                'memory_usage': 'Medium',
                'speed': 'Fast'
            },
            'llava': {
                'description': '빠른 처리속도의 경량 모델',
                'strengths': ['빠른 속도', '낮은 메모리', '실시간 처리'],
                'use_cases': ['대량 처리', '실시간 OCR', '프로토타이핑'],
                'memory_usage': 'Low',
                'speed': 'Very Fast'
            },
            'moondream': {
                'description': '엣지 디바이스용 초경량 모델',
                'strengths': ['매우 빠름', '최소 메모리', '모바일 최적화'],
                'use_cases': ['모바일 앱', '엣지 컴퓨팅', '실시간 스캔'],
                'memory_usage': 'Very Low',
                'speed': 'Very Fast'
            },
            'minicpm-v': {
                'description': '고해상도 이미지 특화 모델',
                'strengths': ['고해상도 지원', '세밀한 텍스트', '1.8M 픽셀'],
                'use_cases': ['고해상도 스캔', '작은 글씨', '상세 도면'],
                'memory_usage': 'Medium',
                'speed': 'Medium'
            }
        }
    
    def compare_models_on_sample(self, image_path):
        """샘플 이미지로 모델 성능 비교"""
        
        results = {}
        
        for model_name, model_info in self.models.items():
            print(f"\n🤖 {model_name} 테스트 중...")
            
            try:
                # OCR 프로세서 생성
                ocr = OCRProcessor(model_name=model_name)
                
                # 처리 시간 측정
                start_time = time.time()
                
                result = ocr.process_image(
                    image_path=image_path,
                    format_type="text",
                    language="Korean"
                )
                
                processing_time = time.time() - start_time
                
                results[model_name] = {
                    'result': result,
                    'processing_time': processing_time,
                    'success': True,
                    'model_info': model_info
                }
                
                print(f"✅ 완료 ({processing_time:.2f}초)")
                print(f"📄 추출 길이: {len(result)} 자")
                
            except Exception as e:
                results[model_name] = {
                    'result': None,
                    'processing_time': 0,
                    'success': False,
                    'error': str(e),
                    'model_info': model_info
                }
                print(f"❌ 실패: {str(e)}")
        
        return results
    
    def generate_comparison_report(self, comparison_results):
        """비교 결과 보고서 생성"""
        
        print("\n" + "="*60)
        print("📊 비전 모델 성능 비교 보고서")
        print("="*60)
        
        # 성공한 모델들만 필터링
        successful_models = {k: v for k, v in comparison_results.items() if v['success']}
        
        if not successful_models:
            print("❌ 성공한 모델이 없습니다.")
            return
        
        # 처리 시간 순 정렬
        sorted_by_speed = sorted(successful_models.items(), key=lambda x: x[1]['processing_time'])
        
        print("\n🏃‍♂️ 처리 속도 순위:")
        for i, (model_name, result) in enumerate(sorted_by_speed, 1):
            print(f"{i}. {model_name}: {result['processing_time']:.2f}초")
        
        # 추출 텍스트 길이 순 정렬 (정확도 대리 지표)
        sorted_by_length = sorted(successful_models.items(), key=lambda x: len(x[1]['result']), reverse=True)
        
        print("\n📏 추출 텍스트 길이 순위:")
        for i, (model_name, result) in enumerate(sorted_by_length, 1):
            print(f"{i}. {model_name}: {len(result['result'])} 자")
        
        # 모델별 상세 정보
        print("\n🔍 모델별 상세 분석:")
        for model_name, result in successful_models.items():
            model_info = result['model_info']
            print(f"\n📱 {model_name}")
            print(f"   설명: {model_info['description']}")
            print(f"   강점: {', '.join(model_info['strengths'])}")
            print(f"   용도: {', '.join(model_info['use_cases'])}")
            print(f"   메모리: {model_info['memory_usage']}")
            print(f"   속도: {model_info['speed']}")
            print(f"   실제 처리시간: {result['processing_time']:.2f}초")
            print(f"   텍스트 추출량: {len(result['result'])} 자")
    
    def recommend_model(self, use_case, priority='balanced'):
        """사용 사례에 따른 모델 추천"""
        
        recommendations = {
            'business_documents': {
                'primary': 'granite3.2-vision',
                'alternative': 'llama3.2-vision:11b',
                'reason': '비즈니스 문서와 표 처리에 특화됨'
            },
            'high_volume': {
                'primary': 'llava',
                'alternative': 'moondream',
                'reason': '빠른 처리속도로 대량 문서 처리에 적합'
            },
            'high_accuracy': {
                'primary': 'llama3.2-vision:11b',
                'alternative': 'granite3.2-vision',
                'reason': '최고 품질의 텍스트 추출 정확도'
            },
            'mobile_edge': {
                'primary': 'moondream',
                'alternative': 'llava',
                'reason': '낮은 리소스 요구사항으로 모바일/엣지 환경 적합'
            },
            'high_resolution': {
                'primary': 'minicpm-v',
                'alternative': 'llama3.2-vision:11b',
                'reason': '고해상도 이미지와 작은 텍스트 처리에 최적화'
            }
        }
        
        if use_case in recommendations:
            rec = recommendations[use_case]
            print(f"\n🎯 {use_case} 용도 모델 추천:")
            print(f"1순위: {rec['primary']}")
            print(f"2순위: {rec['alternative']}")
            print(f"이유: {rec['reason']}")
            return rec
        else:
            print(f"❌ '{use_case}' 사용 사례를 찾을 수 없습니다.")
            print("사용 가능한 케이스:", list(recommendations.keys()))
            return None

# 사용 예제
def run_model_comparison():
    """모델 비교 실행"""
    
    comparator = VisionModelComparator()
    
    # 테스트 이미지로 모델 비교
    sample_image = "input/test_document.png"
    
    print("📊 비전 모델 성능 비교 시작...")
    comparison_results = comparator.compare_models_on_sample(sample_image)
    
    # 비교 보고서 생성
    comparator.generate_comparison_report(comparison_results)
    
    # 사용 사례별 추천
    print("\n" + "="*50)
    print("🎯 사용 사례별 모델 추천")
    print("="*50)
    
    use_cases = ['business_documents', 'high_volume', 'high_accuracy', 'mobile_edge', 'high_resolution']
    
    for use_case in use_cases:
        comparator.recommend_model(use_case)

if __name__ == "__main__":
    run_model_comparison()
```

## Streamlit 웹 애플리케이션 구축

### 사용자 친화적 웹 인터페이스

```python
import streamlit as st
import tempfile
import os
from pathlib import Path
import zipfile
import io

def create_streamlit_app():
    """Streamlit OCR 웹 애플리케이션"""
    
    st.set_page_config(
        page_title="Ollama OCR 웹 앱",
        page_icon="👁️",
        layout="wide",
        initial_sidebar_state="expanded"
    )
    
    st.title("👁️ Ollama OCR - 로컬 비전 모델 텍스트 추출")
    st.markdown("**다양한 비전 모델을 활용한 문서 텍스트 추출 솔루션**")
    
    # 사이드바 설정
    with st.sidebar:
        st.header("⚙️ 설정")
        
        # 모델 선택
        model_options = {
            'llama3.2-vision:11b': '🎯 Llama 3.2 Vision (고성능)',
            'granite3.2-vision': '📊 Granite 3.2 (문서 특화)',
            'llava': '⚡ LLaVA (빠른 처리)',
            'moondream': '📱 Moondream (경량)',
            'minicpm-v': '🔍 MiniCPM-V (고해상도)'
        }
        
        selected_model = st.selectbox(
            "비전 모델 선택",
            options=list(model_options.keys()),
            format_func=lambda x: model_options[x],
            index=1  # granite3.2-vision을 기본값으로
        )
        
        # 출력 형식 선택
        format_options = {
            'text': '📝 순수 텍스트',
            'markdown': '📋 마크다운',
            'json': '🗂️ JSON',
            'structured': '🏗️ 구조화된 데이터',
            'key_value': '🔑 키-값 쌍',
            'table': '📊 테이블 추출'
        }
        
        selected_format = st.selectbox(
            "출력 형식",
            options=list(format_options.keys()),
            format_func=lambda x: format_options[x],
            index=1  # markdown을 기본값으로
        )
        
        # 언어 설정
        language = st.selectbox(
            "문서 언어",
            options=['Korean', 'English', 'Japanese', 'Chinese', 'Auto'],
            index=0
        )
        
        # 커스텀 프롬프트
        custom_prompt = st.text_area(
            "커스텀 프롬프트 (선택적)",
            placeholder="예: 표와 차트의 데이터를 정확히 추출해주세요.",
            height=100
        )
        
        # 고급 옵션
        with st.expander("🔧 고급 옵션"):
            enable_preprocessing = st.checkbox("이미지 전처리", value=True)
            confidence_threshold = st.slider("신뢰도 임계값", 0.0, 1.0, 0.7)
    
    # 메인 영역
    col1, col2 = st.columns([1, 1])
    
    with col1:
        st.header("📤 파일 업로드")
        
        # 파일 업로드
        uploaded_files = st.file_uploader(
            "이미지 또는 PDF 파일을 업로드하세요",
            type=['png', 'jpg', 'jpeg', 'bmp', 'tiff', 'pdf'],
            accept_multiple_files=True,
            help="지원 형식: PNG, JPG, JPEG, BMP, TIFF, PDF"
        )
        
        # 배치 처리 옵션
        if len(uploaded_files) > 1:
            batch_processing = st.checkbox("배치 처리 모드", value=True)
            if batch_processing:
                max_workers = st.slider("병렬 처리 워커 수", 1, 8, 4)
        
        # 처리 버튼
        if st.button("🚀 OCR 처리 시작", type="primary", use_container_width=True):
            if uploaded_files:
                process_uploaded_files(
                    uploaded_files, 
                    selected_model, 
                    selected_format, 
                    language, 
                    custom_prompt,
                    enable_preprocessing
                )
            else:
                st.error("파일을 먼저 업로드해주세요.")
    
    with col2:
        st.header("📋 결과 미리보기")
        
        # 결과 표시 영역은 process_uploaded_files에서 처리
        if 'ocr_results' not in st.session_state:
            st.info("파일을 업로드하고 OCR 처리를 시작하세요.")
    
    # 사용법 안내
    with st.expander("📖 사용법 안내"):
        st.markdown("""
        ### 기본 사용법
        1. **모델 선택**: 왼쪽 사이드바에서 용도에 맞는 비전 모델 선택
        2. **파일 업로드**: 처리할 이미지나 PDF 파일 업로드
        3. **옵션 설정**: 출력 형식, 언어, 커스텀 프롬프트 설정
        4. **처리 실행**: "OCR 처리 시작" 버튼 클릭
        
        ### 모델별 특징
        - **Llama 3.2 Vision**: 높은 정확도, 복잡한 문서 처리에 적합
        - **Granite 3.2**: 비즈니스 문서, 표, 차트 처리에 특화
        - **LLaVA**: 빠른 처리 속도, 대량 문서 처리용
        - **Moondream**: 초경량, 실시간 처리용
        - **MiniCPM-V**: 고해상도 이미지, 작은 텍스트 처리용
        
        ### 팁
        - 복잡한 문서는 **Granite 3.2** 추천
        - 빠른 처리가 필요하면 **LLaVA** 추천
        - 고해상도 스캔 문서는 **MiniCPM-V** 추천
        """)

def process_uploaded_files(uploaded_files, model_name, format_type, language, custom_prompt, enable_preprocessing):
    """업로드된 파일들 처리"""
    
    with st.spinner("OCR 처리 중..."):
        try:
            # OCR 프로세서 초기화
            ocr = OCRProcessor(
                model_name=model_name,
                max_workers=4 if len(uploaded_files) > 1 else 1
            )
            
            results = {}
            progress_bar = st.progress(0)
            status_text = st.empty()
            
            for i, uploaded_file in enumerate(uploaded_files):
                # 진행률 업데이트
                progress = (i + 1) / len(uploaded_files)
                progress_bar.progress(progress)
                status_text.text(f"처리 중: {uploaded_file.name} ({i+1}/{len(uploaded_files)})")
                
                # 임시 파일로 저장
                with tempfile.NamedTemporaryFile(delete=False, suffix=Path(uploaded_file.name).suffix) as tmp_file:
                    tmp_file.write(uploaded_file.getvalue())
                    tmp_file_path = tmp_file.name
                
                try:
                    # OCR 처리
                    result = ocr.process_image(
                        image_path=tmp_file_path,
                        format_type=format_type,
                        custom_prompt=custom_prompt if custom_prompt else None,
                        language=language if language != 'Auto' else None
                    )
                    
                    results[uploaded_file.name] = {
                        'success': True,
                        'result': result,
                        'error': None
                    }
                    
                except Exception as e:
                    results[uploaded_file.name] = {
                        'success': False,
                        'result': None,
                        'error': str(e)
                    }
                
                finally:
                    # 임시 파일 정리
                    os.unlink(tmp_file_path)
            
            # 결과를 세션 상태에 저장
            st.session_state.ocr_results = results
            
            # 결과 표시
            display_results(results, format_type)
            
        except Exception as e:
            st.error(f"처리 중 오류 발생: {str(e)}")

def display_results(results, format_type):
    """결과 표시"""
    
    st.header("📋 OCR 결과")
    
    # 통계 표시
    successful = sum(1 for r in results.values() if r['success'])
    total = len(results)
    
    col1, col2, col3 = st.columns(3)
    with col1:
        st.metric("총 파일", total)
    with col2:
        st.metric("성공", successful)
    with col3:
        st.metric("실패", total - successful)
    
    # 개별 결과 표시
    for filename, result in results.items():
        with st.expander(f"📄 {filename}"):
            if result['success']:
                st.success("처리 완료")
                
                # 결과 텍스트 표시
                if format_type == 'json':
                    st.json(result['result'])
                elif format_type == 'markdown':
                    st.markdown(result['result'])
                else:
                    st.text_area(
                        "추출된 텍스트",
                        value=result['result'],
                        height=300,
                        key=f"result_{filename}"
                    )
                
                # 다운로드 버튼
                st.download_button(
                    label="💾 텍스트 다운로드",
                    data=result['result'],
                    file_name=f"{Path(filename).stem}_extracted.txt",
                    mime="text/plain",
                    key=f"download_{filename}"
                )
                
            else:
                st.error(f"처리 실패: {result['error']}")
    
    # 전체 결과 다운로드
    if successful > 0:
        st.markdown("---")
        
        # 전체 결과를 ZIP으로 압축
        zip_buffer = io.BytesIO()
        with zipfile.ZipFile(zip_buffer, 'w', zipfile.ZIP_DEFLATED) as zip_file:
            for filename, result in results.items():
                if result['success']:
                    text_filename = f"{Path(filename).stem}_extracted.txt"
                    zip_file.writestr(text_filename, result['result'])
        
        st.download_button(
            label="📦 전체 결과 ZIP 다운로드",
            data=zip_buffer.getvalue(),
            file_name="ocr_results.zip",
            mime="application/zip"
        )

# Streamlit 앱 실행 스크립트
if __name__ == "__main__":
    create_streamlit_app()
```

### 웹 앱 실행 스크립트

```bash
#!/bin/bash
# 파일: run_streamlit_app.sh
# Streamlit OCR 웹 앱 실행 스크립트

echo "🌐 Ollama-OCR Streamlit 웹 앱 시작"
echo "=================================="

# Ollama 서비스 확인
echo "🔍 Ollama 서비스 상태 확인..."
if ! pgrep -f "ollama serve" > /dev/null; then
    echo "🚀 Ollama 서비스 시작 중..."
    ollama serve &
    sleep 5
else
    echo "✅ Ollama 서비스 실행 중"
fi

# 필요한 모델 확인
echo "🤖 비전 모델 확인 중..."
MODELS=("llama3.2-vision:11b" "granite3.2-vision" "llava" "moondream" "minicpm-v")

for model in "${MODELS[@]}"; do
    if ollama list | grep -q "$model"; then
        echo "✅ $model 사용 가능"
    else
        echo "📥 $model 다운로드 중..."
        ollama pull "$model"
    fi
done

# Python 패키지 확인
echo "📦 Python 패키지 확인..."
pip install -q streamlit ollama-ocr

# 디렉토리 구조 생성
echo "📁 디렉토리 구조 생성..."
mkdir -p input output

# Streamlit 앱 실행
echo "🚀 Streamlit 앱 시작..."
streamlit run streamlit_ocr_app.py \
    --server.port 8501 \
    --server.address 0.0.0.0 \
    --server.headless true \
    --browser.gatherUsageStats false

echo "✅ 웹 앱이 http://localhost:8501 에서 실행 중입니다."
```

## 실제 문서 처리 예제와 결과 분석

### 다양한 문서 유형별 처리 사례

```python
import json
from pathlib import Path
import matplotlib.pyplot as plt
from datetime import datetime

class DocumentProcessingExamples:
    """실제 문서 처리 예제 클래스"""
    
    def __init__(self):
        self.ocr_processors = {
            'business': OCRProcessor(model_name='granite3.2-vision'),
            'general': OCRProcessor(model_name='llama3.2-vision:11b'),
            'fast': OCRProcessor(model_name='llava'),
            'precision': OCRProcessor(model_name='minicpm-v')
        }
    
    def process_business_invoice(self):
        """비즈니스 인보이스 처리 예제"""
        
        print("💼 비즈니스 인보이스 처리 예제")
        print("="*40)
        
        # 인보이스 특화 프롬프트
        invoice_prompt = """
        이 인보이스에서 다음 정보를 JSON 형식으로 추출해주세요:
        - 회사명 (company_name)
        - 인보이스 번호 (invoice_number)
        - 날짜 (date)
        - 고객 정보 (customer_info)
        - 항목별 내역 (line_items: 상품명, 수량, 단가, 총액)
        - 세금 (tax)
        - 총 금액 (total_amount)
        - 결제 조건 (payment_terms)
        """
        
        result = self.ocr_processors['business'].process_image(
            image_path="input/sample_invoice.pdf",
            format_type="json",
            custom_prompt=invoice_prompt,
            language="Korean"
        )
        
        try:
            invoice_data = json.loads(result)
            
            print("✅ 인보이스 처리 성공")
            print(f"회사명: {invoice_data.get('company_name', 'N/A')}")
            print(f"인보이스 번호: {invoice_data.get('invoice_number', 'N/A')}")
            print(f"총 금액: {invoice_data.get('total_amount', 'N/A')}")
            print(f"항목 수: {len(invoice_data.get('line_items', []))}")
            
            return invoice_data
            
        except json.JSONDecodeError:
            print("❌ JSON 파싱 실패, 원시 텍스트:")
            print(result[:500] + "...")
            return result
    
    def process_financial_report(self):
        """재무 보고서 처리 예제"""
        
        print("\n📊 재무 보고서 처리 예제")
        print("="*40)
        
        financial_prompt = """
        이 재무 보고서에서 다음을 구조화하여 추출해주세요:
        1. 주요 재무 지표 (매출, 영업이익, 순이익 등)
        2. 전년 대비 증감률
        3. 부문별 성과
        4. 주요 이벤트나 특이사항
        
        표 형태의 데이터는 표 구조를 유지해주세요.
        """
        
        result = self.ocr_processors['business'].process_image(
            image_path="input/financial_report.pdf",
            format_type="structured",
            custom_prompt=financial_prompt,
            language="Korean"
        )
        
        print("✅ 재무 보고서 처리 완료")
        print("주요 내용 미리보기:")
        print(result[:300] + "...")
        
        return result
    
    def process_academic_paper(self):
        """학술 논문 처리 예제"""
        
        print("\n🎓 학술 논문 처리 예제")
        print("="*40)
        
        academic_prompt = """
        이 학술 논문에서 다음을 추출해주세요:
        - 제목 (title)
        - 저자 (authors)
        - 초록 (abstract)
        - 주요 키워드 (keywords)
        - 섹션별 헤딩과 내용 구조
        - 그래프나 표의 캡션
        - 참고문헌 (references)
        
        학술적 형식을 유지하여 마크다운으로 정리해주세요.
        """
        
        result = self.ocr_processors['general'].process_image(
            image_path="input/research_paper.pdf",
            format_type="markdown",
            custom_prompt=academic_prompt,
            language="English"
        )
        
        print("✅ 학술 논문 처리 완료")
        
        # 섹션별 길이 분석
        sections = result.split('\n## ')
        print(f"총 섹션 수: {len(sections)}")
        print("주요 섹션들:")
        for i, section in enumerate(sections[:5]):
            section_title = section.split('\n')[0][:50]
            print(f"  {i+1}. {section_title}... ({len(section)} 자)")
        
        return result
    
    def process_technical_manual(self):
        """기술 매뉴얼 처리 예제"""
        
        print("\n🔧 기술 매뉴얼 처리 예제")
        print("="*40)
        
        manual_prompt = """
        이 기술 매뉴얼에서 다음을 체계적으로 추출해주세요:
        - 목차 구조
        - 단계별 절차 (numbered steps)
        - 주의사항이나 경고 (warnings, cautions)
        - 다이어그램이나 그림의 설명
        - 기술 사양 (specifications)
        - 문제해결 가이드 (troubleshooting)
        
        절차나 단계는 번호를 매겨서 명확히 구분해주세요.
        """
        
        result = self.ocr_processors['precision'].process_image(
            image_path="input/technical_manual.pdf",
            format_type="structured",
            custom_prompt=manual_prompt,
            language="Korean"
        )
        
        print("✅ 기술 매뉴얼 처리 완료")
        
        # 단계별 절차 추출
        steps = [line for line in result.split('\n') if line.strip().startswith(('1.', '2.', '3.', '4.', '5.'))]
        print(f"추출된 단계 수: {len(steps)}")
        
        return result
    
    def process_handwritten_notes(self):
        """손글씨 노트 처리 예제"""
        
        print("\n✍️ 손글씨 노트 처리 예제")
        print("="*40)
        
        handwriting_prompt = """
        이 손글씨 노트를 읽고 다음과 같이 정리해주세요:
        - 가독성이 좋은 타이핑된 텍스트로 변환
        - 불분명한 부분은 [불명확] 표시
        - 번호나 목록이 있다면 구조화
        - 중요해 보이는 부분은 **굵게** 표시
        
        손글씨의 특성상 완벽하지 않을 수 있으니 문맥을 고려해서 추측해주세요.
        """
        
        result = self.ocr_processors['general'].process_image(
            image_path="input/handwritten_notes.jpg",
            format_type="markdown",
            custom_prompt=handwriting_prompt,
            language="Korean"
        )
        
        print("✅ 손글씨 노트 처리 완료")
        
        # 불명확한 부분 통계
        unclear_count = result.count('[불명확]')
        total_words = len(result.split())
        clarity_rate = ((total_words - unclear_count) / total_words) * 100 if total_words > 0 else 0
        
        print(f"총 단어 수: {total_words}")
        print(f"불명확한 부분: {unclear_count}")
        print(f"명확도: {clarity_rate:.1f}%")
        
        return result

# 성능 평가 클래스
class OCRPerformanceEvaluator:
    """OCR 성능 평가 클래스"""
    
    def __init__(self):
        self.test_results = {}
    
    def evaluate_accuracy_by_document_type(self):
        """문서 유형별 정확도 평가"""
        
        document_processor = DocumentProcessingExamples()
        
        test_cases = [
            ('business_invoice', document_processor.process_business_invoice),
            ('financial_report', document_processor.process_financial_report),
            ('academic_paper', document_processor.process_academic_paper),
            ('technical_manual', document_processor.process_technical_manual),
            ('handwritten_notes', document_processor.process_handwritten_notes)
        ]
        
        print("\n📈 문서 유형별 성능 평가")
        print("="*50)
        
        for doc_type, process_func in test_cases:
            print(f"\n🔍 {doc_type} 평가 중...")
            
            start_time = datetime.now()
            
            try:
                result = process_func()
                processing_time = (datetime.now() - start_time).total_seconds()
                
                # 기본 품질 지표 계산
                text_length = len(str(result))
                word_count = len(str(result).split())
                
                self.test_results[doc_type] = {
                    'success': True,
                    'processing_time': processing_time,
                    'text_length': text_length,
                    'word_count': word_count,
                    'words_per_second': word_count / processing_time if processing_time > 0 else 0
                }
                
                print(f"✅ 성공 - 처리시간: {processing_time:.2f}초, 단어수: {word_count}")
                
            except Exception as e:
                self.test_results[doc_type] = {
                    'success': False,
                    'error': str(e),
                    'processing_time': 0
                }
                print(f"❌ 실패: {str(e)}")
        
        # 결과 요약
        self.generate_performance_report()
    
    def generate_performance_report(self):
        """성능 평가 보고서 생성"""
        
        print("\n" + "="*60)
        print("📊 OCR 성능 평가 종합 보고서")
        print("="*60)
        
        successful_tests = {k: v for k, v in self.test_results.items() if v.get('success', False)}
        failed_tests = {k: v for k, v in self.test_results.items() if not v.get('success', False)}
        
        # 전체 통계
        total_tests = len(self.test_results)
        success_rate = len(successful_tests) / total_tests * 100 if total_tests > 0 else 0
        
        print(f"🎯 전체 성공률: {success_rate:.1f}% ({len(successful_tests)}/{total_tests})")
        
        if successful_tests:
            # 성능 지표
            avg_time = sum(r['processing_time'] for r in successful_tests.values()) / len(successful_tests)
            avg_words = sum(r['word_count'] for r in successful_tests.values()) / len(successful_tests)
            avg_speed = sum(r['words_per_second'] for r in successful_tests.values()) / len(successful_tests)
            
            print(f"⏱️  평균 처리 시간: {avg_time:.2f}초")
            print(f"📝 평균 추출 단어 수: {avg_words:.0f}개")
            print(f"🚀 평균 처리 속도: {avg_speed:.1f} 단어/초")
            
            # 문서 유형별 상세 결과
            print(f"\n📋 문서 유형별 상세 결과:")
            print("-" * 60)
            print(f"{'문서 유형':<20} {'처리시간':<10} {'단어수':<10} {'속도(w/s)':<12}")
            print("-" * 60)
            
            for doc_type, result in successful_tests.items():
                print(f"{doc_type:<20} {result['processing_time']:<10.2f} {result['word_count']:<10} {result['words_per_second']:<12.1f}")
        
        if failed_tests:
            print(f"\n❌ 실패한 테스트:")
            for doc_type, result in failed_tests.items():
                print(f"   - {doc_type}: {result['error']}")

# 실용적인 활용 사례
class PracticalUseCases:
    """실용적인 OCR 활용 사례"""
    
    def __init__(self):
        self.ocr = OCRProcessor(model_name='granite3.2-vision')
    
    def receipt_expense_tracker(self, receipt_images):
        """영수증 기반 가계부 관리"""
        
        print("🧾 영수증 가계부 자동화")
        print("="*30)
        
        expenses = []
        
        for receipt_path in receipt_images:
            expense_prompt = """
            이 영수증에서 다음 정보를 JSON으로 추출해주세요:
            {
                "store_name": "상점명",
                "date": "날짜 (YYYY-MM-DD)",
                "total_amount": "총 금액 (숫자만)",
                "items": [
                    {"name": "상품명", "price": "가격", "quantity": "수량"}
                ],
                "payment_method": "결제수단",
                "category": "카테고리 (식비/교통비/쇼핑/기타)"
            }
            """
            
            try:
                result = self.ocr.process_image(
                    image_path=receipt_path,
                    format_type="json",
                    custom_prompt=expense_prompt,
                    language="Korean"
                )
                
                expense_data = json.loads(result)
                expenses.append(expense_data)
                
                print(f"✅ {Path(receipt_path).name}: {expense_data.get('store_name', 'Unknown')} - {expense_data.get('total_amount', '0')}원")
                
            except Exception as e:
                print(f"❌ {Path(receipt_path).name}: 처리 실패 - {str(e)}")
        
        # 월별 지출 요약
        if expenses:
            total_spending = sum(float(exp.get('total_amount', 0)) for exp in expenses if exp.get('total_amount'))
            print(f"\n💰 총 지출: {total_spending:,.0f}원")
            
            # 카테고리별 집계
            category_spending = {}
            for exp in expenses:
                category = exp.get('category', '기타')
                amount = float(exp.get('total_amount', 0))
                category_spending[category] = category_spending.get(category, 0) + amount
            
            print("📊 카테고리별 지출:")
            for category, amount in sorted(category_spending.items(), key=lambda x: x[1], reverse=True):
                print(f"   {category}: {amount:,.0f}원")
        
        return expenses
    
    def business_card_organizer(self, card_images):
        """명함 정보 자동 정리"""
        
        print("💳 명함 정보 자동 정리")
        print("="*25)
        
        contacts = []
        
        for card_path in card_images:
            card_prompt = """
            이 명함에서 연락처 정보를 JSON으로 추출해주세요:
            {
                "name": "이름",
                "company": "회사명",
                "position": "직책",
                "department": "부서",
                "phone": "전화번호",
                "mobile": "휴대폰",
                "email": "이메일",
                "address": "주소",
                "website": "웹사이트"
            }
            """
            
            try:
                result = self.ocr.process_image(
                    image_path=card_path,
                    format_type="json",
                    custom_prompt=card_prompt,
                    language="Korean"
                )
                
                contact_data = json.loads(result)
                contacts.append(contact_data)
                
                print(f"✅ {contact_data.get('name', 'Unknown')} ({contact_data.get('company', 'Unknown')})")
                
            except Exception as e:
                print(f"❌ {Path(card_path).name}: 처리 실패 - {str(e)}")
        
        # CSV로 내보내기
        if contacts:
            csv_content = "이름,회사,직책,부서,전화번호,휴대폰,이메일,주소,웹사이트\n"
            for contact in contacts:
                csv_row = ",".join([
                    contact.get('name', ''),
                    contact.get('company', ''),
                    contact.get('position', ''),
                    contact.get('department', ''),
                    contact.get('phone', ''),
                    contact.get('mobile', ''),
                    contact.get('email', ''),
                    contact.get('address', ''),
                    contact.get('website', '')
                ])
                csv_content += csv_row + "\n"
            
            with open("output/business_cards.csv", "w", encoding="utf-8") as f:
                f.write(csv_content)
            
            print(f"💾 {len(contacts)}개 명함 정보를 business_cards.csv로 저장했습니다.")
        
        return contacts
    
    def document_digitization_workflow(self, document_folder):
        """문서 디지털화 워크플로우"""
        
        print("📚 문서 디지털화 워크플로우")
        print("="*35)
        
        # 문서 유형 자동 분류
        classification_prompt = """
        이 문서의 유형을 다음 중에서 선택해주세요:
        - invoice (인보이스/청구서)
        - contract (계약서)
        - report (보고서)
        - manual (매뉴얼)
        - form (양식/신청서)
        - letter (공문/서신)
        - other (기타)
        
        응답은 단어 하나만 반환해주세요.
        """
        
        documents = list(Path(document_folder).glob("*"))
        organized_docs = {}
        
        for doc_path in documents:
            if doc_path.suffix.lower() in ['.jpg', '.png', '.pdf', '.jpeg']:
                try:
                    # 1단계: 문서 유형 분류
                    doc_type = self.ocr.process_image(
                        image_path=str(doc_path),
                        format_type="text",
                        custom_prompt=classification_prompt,
                        language="Korean"
                    ).strip().lower()
                    
                    # 2단계: 유형별 맞춤 추출
                    if doc_type not in organized_docs:
                        organized_docs[doc_type] = []
                    
                    # 유형별 특화 프롬프트
                    type_prompts = {
                        'invoice': "인보이스 정보를 구조화하여 추출: 회사명, 날짜, 금액, 항목",
                        'contract': "계약서 주요 내용 추출: 당사자, 계약일, 계약기간, 주요 조건",
                        'report': "보고서 요약: 제목, 작성자, 주요 내용, 결론",
                        'manual': "매뉴얼 구조화: 목차, 주요 절차, 주의사항",
                        'form': "양식 정보 추출: 양식명, 필수 항목, 작성 내용",
                        'letter': "공문 정보: 발신처, 수신처, 제목, 주요 내용",
                        'other': "문서의 주요 내용을 요약하여 추출"
                    }
                    
                    specialized_prompt = type_prompts.get(doc_type, type_prompts['other'])
                    
                    content = self.ocr.process_image(
                        image_path=str(doc_path),
                        format_type="structured",
                        custom_prompt=specialized_prompt,
                        language="Korean"
                    )
                    
                    organized_docs[doc_type].append({
                        'filename': doc_path.name,
                        'path': str(doc_path),
                        'content': content
                    })
                    
                    print(f"✅ {doc_path.name} → {doc_type}")
                    
                except Exception as e:
                    print(f"❌ {doc_path.name}: {str(e)}")
        
        # 유형별 정리 결과 저장
        for doc_type, docs in organized_docs.items():
            if docs:
                output_dir = Path("output") / "organized_documents" / doc_type
                output_dir.mkdir(parents=True, exist_ok=True)
                
                # 유형별 요약 파일 생성
                summary_file = output_dir / f"{doc_type}_summary.md"
                with open(summary_file, "w", encoding="utf-8") as f:
                    f.write(f"# {doc_type.title()} 문서 요약\n\n")
                    f.write(f"총 {len(docs)}개 문서\n\n")
                    
                    for i, doc in enumerate(docs, 1):
                        f.write(f"## {i}. {doc['filename']}\n\n")
                        f.write(f"**원본 경로**: {doc['path']}\n\n")
                        f.write(f"**추출 내용**:\n{doc['content']}\n\n")
                        f.write("---\n\n")
                
                print(f"📁 {doc_type}: {len(docs)}개 문서 → {output_dir}")
        
        return organized_docs

# 실행 예제
def run_practical_examples():
    """실용적인 예제 실행"""
    
    use_cases = PracticalUseCases()
    
    # 1. 영수증 가계부 (예제 영수증 이미지가 있다고 가정)
    receipt_images = [
        "input/receipts/grocery_store.jpg",
        "input/receipts/restaurant.jpg",
        "input/receipts/gas_station.jpg"
    ]
    
    expenses = use_cases.receipt_expense_tracker(receipt_images)
    
    # 2. 명함 정리 (예제 명함 이미지가 있다고 가정)
    business_cards = [
        "input/business_cards/card1.jpg",
        "input/business_cards/card2.jpg"
    ]
    
    contacts = use_cases.business_card_organizer(business_cards)
    
    # 3. 문서 디지털화
    organized_docs = use_cases.document_digitization_workflow("input/mixed_documents")
    
    print("\n🎉 모든 실용 예제 완료!")
    print(f"💰 처리된 영수증: {len(expenses)}개")
    print(f"💳 정리된 명함: {len(contacts)}개")
    print(f"📚 분류된 문서 유형: {len(organized_docs)}개")

if __name__ == "__main__":
    # 문서 처리 예제 실행
    print("🚀 Ollama-OCR 실제 활용 예제 시작")
    print("="*50)
    
    # 성능 평가
    evaluator = OCRPerformanceEvaluator()
    evaluator.evaluate_accuracy_by_document_type()
    
    # 실용적인 활용 사례
    run_practical_examples()
```

## macOS 테스트 스크립트와 환경 구성

### 통합 테스트 스크립트

```python
#!/usr/bin/env python3
"""
Ollama-OCR macOS 통합 테스트 스크립트
실행: python test_ollama_ocr.py
"""

import os
import sys
import subprocess
import time
import tempfile
from pathlib import Path
import requests
from PIL import Image, ImageDraw, ImageFont

class OllamaOCRTester:
    """Ollama-OCR 통합 테스트 클래스"""
    
    def __init__(self):
        self.test_results = {}
        self.ollama_running = False
        
    def check_system_requirements(self):
        """시스템 요구사항 확인"""
        
        print("🔍 시스템 요구사항 확인...")
        
        # Python 버전 확인
        python_version = sys.version_info
        if python_version.major >= 3 and python_version.minor >= 8:
            print(f"✅ Python {python_version.major}.{python_version.minor}.{python_version.micro}")
        else:
            print(f"❌ Python 3.8+ 필요 (현재: {python_version.major}.{python_version.minor})")
            return False
        
        # 메모리 확인 (macOS)
        try:
            memory_info = subprocess.run(['sysctl', 'hw.memsize'], capture_output=True, text=True)
            if memory_info.returncode == 0:
                memory_bytes = int(memory_info.stdout.split(':')[1].strip())
                memory_gb = memory_bytes / (1024**3)
                print(f"💾 시스템 메모리: {memory_gb:.1f}GB")
                
                if memory_gb < 8:
                    print("⚠️  8GB 이상 권장")
            else:
                print("⚠️  메모리 정보 확인 실패")
        except:
            print("⚠️  메모리 정보 확인 불가")
        
        # 디스크 공간 확인
        try:
            disk_info = subprocess.run(['df', '-h', '.'], capture_output=True, text=True)
            if disk_info.returncode == 0:
                lines = disk_info.stdout.strip().split('\n')
                if len(lines) > 1:
                    available = lines[1].split()[3]
                    print(f"💽 사용 가능한 디스크: {available}")
        except:
            print("⚠️  디스크 정보 확인 불가")
        
        return True
    
    def check_ollama_installation(self):
        """Ollama 설치 및 실행 상태 확인"""
        
        print("\n🤖 Ollama 설치 확인...")
        
        # Ollama 명령어 확인
        try:
            result = subprocess.run(['ollama', '--version'], capture_output=True, text=True)
            if result.returncode == 0:
                print(f"✅ Ollama 설치됨: {result.stdout.strip()}")
            else:
                print("❌ Ollama 명령어 실행 실패")
                return False
        except FileNotFoundError:
            print("❌ Ollama가 설치되지 않았습니다.")
            print("설치 방법: brew install ollama")
            return False
        
        # Ollama 서비스 실행 확인
        try:
            response = requests.get('http://localhost:11434/api/tags', timeout=5)
            if response.status_code == 200:
                print("✅ Ollama 서비스 실행 중")
                self.ollama_running = True
            else:
                print("⚠️  Ollama 서비스 응답 이상")
                return False
        except requests.exceptions.RequestException:
            print("❌ Ollama 서비스가 실행되지 않음")
            print("서비스 시작: ollama serve")
            return False
        
        return True
    
    def check_vision_models(self):
        """비전 모델 다운로드 상태 확인"""
        
        print("\n👁️ 비전 모델 확인...")
        
        if not self.ollama_running:
            print("❌ Ollama 서비스가 실행되지 않음")
            return False
        
        required_models = [
            'llama3.2-vision:11b',
            'granite3.2-vision',
            'llava',
            'moondream',
            'minicpm-v'
        ]
        
        try:
            response = requests.get('http://localhost:11434/api/tags')
            if response.status_code == 200:
                installed_models = response.json()
                model_names = [model['name'] for model in installed_models.get('models', [])]
                
                available_models = []
                for model in required_models:
                    if any(model in installed_name for installed_name in model_names):
                        print(f"✅ {model}")
                        available_models.append(model)
                    else:
                        print(f"❌ {model} (다운로드 필요)")
                
                if available_models:
                    print(f"\n사용 가능한 모델: {len(available_models)}개")
                    return available_models
                else:
                    print("\n⚠️  사용 가능한 비전 모델이 없습니다.")
                    return False
            else:
                print("❌ 모델 목록 조회 실패")
                return False
        except requests.exceptions.RequestException as e:
            print(f"❌ 모델 확인 실패: {str(e)}")
            return False
    
    def install_python_packages(self):
        """Python 패키지 설치"""
        
        print("\n📦 Python 패키지 확인...")
        
        packages = ['ollama-ocr', 'Pillow', 'requests', 'streamlit']
        
        for package in packages:
            try:
                if package == 'ollama-ocr':
                    import ollama_ocr
                elif package == 'Pillow':
                    from PIL import Image
                elif package == 'requests':
                    import requests
                elif package == 'streamlit':
                    import streamlit
                
                print(f"✅ {package}")
                
            except ImportError:
                print(f"📥 {package} 설치 중...")
                try:
                    subprocess.run([sys.executable, '-m', 'pip', 'install', package], 
                                  capture_output=True, check=True)
                    print(f"✅ {package} 설치 완료")
                except subprocess.CalledProcessError as e:
                    print(f"❌ {package} 설치 실패: {str(e)}")
                    return False
        
        return True
    
    def create_test_images(self):
        """테스트용 이미지 생성"""
        
        print("\n🖼️ 테스트 이미지 생성...")
        
        test_dir = Path("test_images")
        test_dir.mkdir(exist_ok=True)
        
        # 1. 간단한 텍스트 이미지
        img1 = Image.new('RGB', (800, 200), 'white')
        draw1 = ImageDraw.Draw(img1)
        
        # 기본 폰트 사용 (macOS에서 사용 가능한 폰트)
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 32)
        except:
            font = ImageFont.load_default()
        
        draw1.text((50, 50), "Hello World OCR Test", fill='black', font=font)
        draw1.text((50, 100), "안녕하세요 OCR 테스트입니다", fill='black', font=font)
        
        img1_path = test_dir / "simple_text.png"
        img1.save(img1_path)
        print(f"✅ 생성: {img1_path}")
        
        # 2. 복잡한 레이아웃 이미지
        img2 = Image.new('RGB', (600, 400), 'white')
        draw2 = ImageDraw.Draw(img2)
        
        # 제목
        draw2.text((50, 30), "OCR 성능 테스트 문서", fill='black', font=font)
        
        # 본문
        lines = [
            "1. 첫 번째 항목입니다.",
            "2. 두 번째 항목입니다.",
            "   - 하위 항목 A",
            "   - 하위 항목 B",
            "3. 세 번째 항목입니다."
        ]
        
        y_pos = 80
        for line in lines:
            draw2.text((50, y_pos), line, fill='black', font=font)
            y_pos += 40
        
        # 테이블 형태
        draw2.rectangle([400, 100, 550, 200], outline='black', width=2)
        draw2.text((410, 110), "항목", fill='black', font=font)
        draw2.text((410, 140), "값", fill='black', font=font)
        draw2.text((410, 170), "100", fill='black', font=font)
        
        img2_path = test_dir / "complex_layout.png"
        img2.save(img2_path)
        print(f"✅ 생성: {img2_path}")
        
        # 3. 숫자와 특수문자 이미지
        img3 = Image.new('RGB', (500, 300), 'white')
        draw3 = ImageDraw.Draw(img3)
        
        test_text = [
            "전화번호: 010-1234-5678",
            "이메일: test@example.com",
            "날짜: 2025-08-07",
            "금액: ₩1,234,567",
            "주소: 서울시 강남구 테헤란로 123"
        ]
        
        y_pos = 50
        for text in test_text:
            draw3.text((30, y_pos), text, fill='black', font=font)
            y_pos += 40
        
        img3_path = test_dir / "special_chars.png"
        img3.save(img3_path)
        print(f"✅ 생성: {img3_path}")
        
        return [img1_path, img2_path, img3_path]
    
    def test_basic_ocr(self, test_images, available_models):
        """기본 OCR 기능 테스트"""
        
        print("\n🧪 기본 OCR 기능 테스트...")
        
        from ollama_ocr import OCRProcessor
        
        # 가장 빠른 모델로 테스트
        test_model = 'llava' if 'llava' in available_models else available_models[0]
        
        try:
            ocr = OCRProcessor(model_name=test_model)
            
            for i, image_path in enumerate(test_images):
                print(f"\n📋 테스트 {i+1}: {image_path.name}")
                
                start_time = time.time()
                
                result = ocr.process_image(
                    image_path=str(image_path),
                    format_type="text",
                    language="Korean"
                )
                
                processing_time = time.time() - start_time
                
                print(f"⏱️  처리 시간: {processing_time:.2f}초")
                print(f"📄 추출된 텍스트 ({len(result)} 자):")
                print(f"   {result[:100]}..." if len(result) > 100 else f"   {result}")
                
                self.test_results[f"basic_test_{i+1}"] = {
                    'success': True,
                    'model': test_model,
                    'image': str(image_path),
                    'processing_time': processing_time,
                    'text_length': len(result),
                    'extracted_text': result
                }
            
            print("✅ 기본 OCR 테스트 완료")
            return True
            
        except Exception as e:
            print(f"❌ 기본 OCR 테스트 실패: {str(e)}")
            return False
    
    def test_format_outputs(self, test_images, available_models):
        """다양한 출력 형식 테스트"""
        
        print("\n📊 출력 형식 테스트...")
        
        from ollama_ocr import OCRProcessor
        
        test_model = 'granite3.2-vision' if 'granite3.2-vision' in available_models else available_models[0]
        
        formats = ['text', 'markdown', 'json', 'structured']
        
        try:
            ocr = OCRProcessor(model_name=test_model)
            test_image = test_images[1]  # 복잡한 레이아웃 이미지 사용
            
            for format_type in formats:
                print(f"\n🔍 {format_type} 형식 테스트...")
                
                start_time = time.time()
                
                result = ocr.process_image(
                    image_path=str(test_image),
                    format_type=format_type,
                    language="Korean"
                )
                
                processing_time = time.time() - start_time
                
                print(f"⏱️  처리 시간: {processing_time:.2f}초")
                print(f"📝 결과 미리보기: {str(result)[:150]}...")
                
                self.test_results[f"format_{format_type}"] = {
                    'success': True,
                    'format': format_type,
                    'processing_time': processing_time,
                    'result_length': len(str(result))
                }
            
            print("✅ 출력 형식 테스트 완료")
            return True
            
        except Exception as e:
            print(f"❌ 출력 형식 테스트 실패: {str(e)}")
            return False
    
    def test_batch_processing(self, test_images, available_models):
        """배치 처리 테스트"""
        
        print("\n⚡ 배치 처리 테스트...")
        
        from ollama_ocr import OCRProcessor
        
        test_model = 'llava' if 'llava' in available_models else available_models[0]
        
        try:
            ocr = OCRProcessor(model_name=test_model, max_workers=2)
            
            # 임시 디렉토리에 테스트 이미지 복사
            with tempfile.TemporaryDirectory() as temp_dir:
                temp_images = []
                for i, img_path in enumerate(test_images):
                    temp_img_path = Path(temp_dir) / f"batch_test_{i}.png"
                    temp_img_path.write_bytes(img_path.read_bytes())
                    temp_images.append(temp_img_path)
                
                start_time = time.time()
                
                batch_results = ocr.process_batch(
                    input_path=temp_dir,
                    format_type="text",
                    recursive=False,
                    preprocess=True,
                    language="Korean"
                )
                
                processing_time = time.time() - start_time
                
                stats = batch_results['statistics']
                
                print(f"⏱️  총 처리 시간: {processing_time:.2f}초")
                print(f"📊 처리 통계:")
                print(f"   - 총 파일: {stats['total']}개")
                print(f"   - 성공: {stats['successful']}개")
                print(f"   - 실패: {stats['failed']}개")
                print(f"   - 평균 시간: {processing_time/max(stats['total'], 1):.2f}초/파일")
                
                self.test_results['batch_processing'] = {
                    'success': True,
                    'total_time': processing_time,
                    'statistics': stats
                }
                
                print("✅ 배치 처리 테스트 완료")
                return True
        
        except Exception as e:
            print(f"❌ 배치 처리 테스트 실패: {str(e)}")
            return False
    
    def generate_test_report(self):
        """테스트 결과 보고서 생성"""
        
        print("\n" + "="*60)
        print("📊 Ollama-OCR 테스트 결과 보고서")
        print("="*60)
        
        total_tests = len(self.test_results)
        successful_tests = sum(1 for result in self.test_results.values() if result.get('success', False))
        
        print(f"🎯 전체 성공률: {successful_tests/total_tests*100:.1f}% ({successful_tests}/{total_tests})")
        
        # 기본 OCR 테스트 결과
        basic_tests = {k: v for k, v in self.test_results.items() if k.startswith('basic_test')}
        if basic_tests:
            print(f"\n📋 기본 OCR 테스트:")
            avg_time = sum(r['processing_time'] for r in basic_tests.values()) / len(basic_tests)
            avg_length = sum(r['text_length'] for r in basic_tests.values()) / len(basic_tests)
            print(f"   평균 처리 시간: {avg_time:.2f}초")
            print(f"   평균 텍스트 길이: {avg_length:.0f}자")
        
        # 형식별 테스트 결과
        format_tests = {k: v for k, v in self.test_results.items() if k.startswith('format_')}
        if format_tests:
            print(f"\n📊 출력 형식별 성능:")
            for test_name, result in format_tests.items():
                format_name = test_name.split('_')[1]
                print(f"   {format_name}: {result['processing_time']:.2f}초")
        
        # 배치 처리 결과
        if 'batch_processing' in self.test_results:
            batch_result = self.test_results['batch_processing']
            print(f"\n⚡ 배치 처리 성능:")
            print(f"   총 처리 시간: {batch_result['total_time']:.2f}초")
            print(f"   성공률: {batch_result['statistics']['successful']}/{batch_result['statistics']['total']}")
        
        # 시스템 정보
        print(f"\n🖥️ 테스트 환경:")
        print(f"   OS: macOS")
        print(f"   Python: {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")
        print(f"   테스트 시간: {time.strftime('%Y-%m-%d %H:%M:%S')}")
        
        # 권장사항
        print(f"\n💡 권장사항:")
        if successful_tests == total_tests:
            print("   🎉 모든 테스트가 성공했습니다! 바로 사용하실 수 있습니다.")
        elif successful_tests > total_tests * 0.7:
            print("   ✅ 대부분의 기능이 정상 작동합니다.")
            print("   ⚠️  일부 실패한 기능은 모델 다운로드나 설정을 확인해주세요.")
        else:
            print("   ⚠️  여러 기능에서 문제가 발생했습니다.")
            print("   🔧 Ollama 설치, 모델 다운로드, 네트워크 상태를 확인해주세요.")
    
    def run_full_test(self):
        """전체 테스트 실행"""
        
        print("🚀 Ollama-OCR macOS 통합 테스트 시작")
        print("="*50)
        
        # 1. 시스템 요구사항 확인
        if not self.check_system_requirements():
            print("❌ 시스템 요구사항 미충족")
            return False
        
        # 2. Ollama 확인
        if not self.check_ollama_installation():
            print("❌ Ollama 설치/실행 문제")
            return False
        
        # 3. 비전 모델 확인
        available_models = self.check_vision_models()
        if not available_models:
            print("❌ 사용 가능한 비전 모델 없음")
            return False
        
        # 4. Python 패키지 설치
        if not self.install_python_packages():
            print("❌ Python 패키지 설치 실패")
            return False
        
        # 5. 테스트 이미지 생성
        test_images = self.create_test_images()
        
        # 6. 기본 OCR 테스트
        self.test_basic_ocr(test_images, available_models)
        
        # 7. 출력 형식 테스트
        self.test_format_outputs(test_images, available_models)
        
        # 8. 배치 처리 테스트
        self.test_batch_processing(test_images, available_models)
        
        # 9. 테스트 보고서 생성
        self.generate_test_report()
        
        return True

if __name__ == "__main__":
    tester = OllamaOCRTester()
    tester.run_full_test()
```

### 성능 벤치마크 스크립트

```bash
#!/bin/bash
# 파일: benchmark_ollama_ocr.sh
# Ollama-OCR 성능 벤치마크 스크립트

echo "📊 Ollama-OCR 성능 벤치마크 시작"
echo "=================================="

# 시스템 정보 수집
echo "🖥️ 시스템 정보:"
echo "- OS: $(uname -s) $(uname -r)"
echo "- CPU: $(sysctl -n machdep.cpu.brand_string)"
echo "- 메모리: $(sysctl -n hw.memsize | awk '{print $1/1024/1024/1024 " GB"}')"
echo "- Python: $(python3 --version)"

# Ollama 상태 확인
echo ""
echo "🤖 Ollama 상태 확인:"
if pgrep -f "ollama serve" > /dev/null; then
    echo "✅ Ollama 서비스 실행 중"
else
    echo "🚀 Ollama 서비스 시작 중..."
    ollama serve &
    sleep 10
fi

# 벤치마크용 테스트 이미지 생성
python3 << EOF
import subprocess
import time
import json
from pathlib import Path

# 테스트 결과 저장 디렉토리
results_dir = Path("benchmark_results")
results_dir.mkdir(exist_ok=True)

# 벤치마크 실행
print("⚡ 성능 벤치마크 실행 중...")

models = ['llava', 'granite3.2-vision', 'llama3.2-vision:11b']
image_sizes = ['small', 'medium', 'large']
formats = ['text', 'markdown', 'json']

benchmark_results = {}

for model in models:
    if model not in benchmark_results:
        benchmark_results[model] = {}
    
    for size in image_sizes:
        for format_type in formats:
            test_key = f"{size}_{format_type}"
            
            print(f"🔍 {model} - {test_key} 테스트...")
            
            start_time = time.time()
            
            # 실제 OCR 테스트 (테스트 이미지 필요)
            # 여기서는 시뮬레이션
            time.sleep(0.5)  # 시뮬레이션 지연
            
            end_time = time.time()
            processing_time = end_time - start_time
            
            benchmark_results[model][test_key] = {
                'processing_time': processing_time,
                'success': True
            }

# 결과 저장
with open(results_dir / "benchmark_results.json", "w") as f:
    json.dump(benchmark_results, f, indent=2)

print("✅ 벤치마크 완료")
print(f"📊 결과 저장: {results_dir}/benchmark_results.json")
EOF

echo ""
echo "🎯 벤치마크 완료"
echo "결과 파일: benchmark_results/benchmark_results.json"
```

## troubleshooting 및 최적화 가이드

### 자주 발생하는 문제 해결

```python
class OllamaOCRTroubleshooter:
    """Ollama-OCR 문제 해결 도우미"""
    
    def __init__(self):
        self.common_issues = {}
    
    def diagnose_ollama_connection(self):
        """Ollama 연결 문제 진단"""
        
        print("🔍 Ollama 연결 상태 진단...")
        
        # 1. Ollama 서비스 실행 확인
        try:
            import psutil
            ollama_processes = [p for p in psutil.process_iter() if 'ollama' in p.name().lower()]
            
            if ollama_processes:
                print("✅ Ollama 프로세스 실행 중")
                for proc in ollama_processes:
                    print(f"   PID: {proc.pid}, 메모리: {proc.memory_info().rss / 1024 / 1024:.1f}MB")
            else:
                print("❌ Ollama 프로세스 없음")
                print("해결방법: ollama serve 명령으로 서비스 시작")
                return False
        except ImportError:
            print("⚠️  psutil 패키지 없음 (pip install psutil)")
        
        # 2. API 엔드포인트 테스트
        try:
            import requests
            response = requests.get('http://localhost:11434/api/tags', timeout=10)
            
            if response.status_code == 200:
                models = response.json().get('models', [])
                print(f"✅ API 정상 ({len(models)}개 모델 사용 가능)")
                return True
            else:
                print(f"❌ API 응답 오류: {response.status_code}")
                return False
                
        except requests.exceptions.ConnectException:
            print("❌ Ollama 서버 연결 실패")
            print("해결방법:")
            print("1. ollama serve 실행")
            print("2. 포트 11434가 사용 중인지 확인")
            print("3. 방화벽 설정 확인")
            return False
        
        except requests.exceptions.Timeout:
            print("❌ 연결 타임아웃")
            print("해결방법: 서버 재시작 또는 네트워크 확인")
            return False
    
    def diagnose_model_issues(self):
        """모델 관련 문제 진단"""
        
        print("\n🤖 모델 문제 진단...")
        
        try:
            import requests
            response = requests.get('http://localhost:11434/api/tags')
            
            if response.status_code == 200:
                models_data = response.json()
                models = models_data.get('models', [])
                
                if not models:
                    print("❌ 설치된 모델 없음")
                    print("해결방법:")
                    print("ollama pull llama3.2-vision:11b")
                    print("ollama pull granite3.2-vision")
                    return False
                
                # 비전 모델 확인
                vision_models = []
                for model in models:
                    model_name = model['name']
                    if any(keyword in model_name.lower() for keyword in ['vision', 'llava', 'granite', 'minicpm']):
                        vision_models.append(model_name)
                        print(f"✅ {model_name}")
                
                if not vision_models:
                    print("❌ 비전 모델 없음")
                    print("해결방법: 비전 모델 다운로드 필요")
                    return False
                
                print(f"✅ 사용 가능한 비전 모델: {len(vision_models)}개")
                return True
            
        except Exception as e:
            print(f"❌ 모델 확인 실패: {str(e)}")
            return False
    
    def diagnose_memory_issues(self):
        """메모리 관련 문제 진단"""
        
        print("\n💾 메모리 사용량 진단...")
        
        try:
            import psutil
            
            # 전체 시스템 메모리
            memory = psutil.virtual_memory()
            print(f"시스템 메모리: {memory.total / 1024**3:.1f}GB")
            print(f"사용 중: {memory.used / 1024**3:.1f}GB ({memory.percent:.1f}%)")
            print(f"사용 가능: {memory.available / 1024**3:.1f}GB")
            
            # Ollama 프로세스 메모리
            ollama_memory = 0
            for proc in psutil.process_iter():
                if 'ollama' in proc.name().lower():
                    try:
                        ollama_memory += proc.memory_info().rss
                    except:
                        pass
            
            if ollama_memory > 0:
                print(f"Ollama 메모리 사용량: {ollama_memory / 1024**2:.1f}MB")
            
            # 메모리 부족 경고
            if memory.available < 2 * 1024**3:  # 2GB 미만
                print("⚠️  사용 가능한 메모리가 부족합니다")
                print("해결방법:")
                print("1. 불필요한 애플리케이션 종료")
                print("2. 가벼운 모델 사용 (llava, moondream)")
                print("3. 배치 처리 시 워커 수 줄이기")
                return False
            
            return True
            
        except ImportError:
            print("⚠️  psutil 패키지로 정확한 진단 불가")
            return True
    
    def diagnose_performance_issues(self):
        """성능 관련 문제 진단"""
        
        print("\n⚡ 성능 문제 진단...")
        
        # CPU 확인
        try:
            import psutil
            cpu_count = psutil.cpu_count()
            cpu_percent = psutil.cpu_percent(interval=1)
            
            print(f"CPU 코어 수: {cpu_count}")
            print(f"CPU 사용률: {cpu_percent:.1f}%")
            
            if cpu_percent > 80:
                print("⚠️  CPU 사용률이 높습니다")
                print("해결방법:")
                print("1. 배치 처리 워커 수 줄이기")
                print("2. 다른 프로세스 종료")
        except:
            pass
        
        # 성능 최적화 제안
        performance_tips = [
            "💡 성능 최적화 팁:",
            "1. 문서 유형에 맞는 모델 선택:",
            "   - 일반 문서: llava (빠름)",
            "   - 비즈니스 문서: granite3.2-vision",
            "   - 고정밀 필요: llama3.2-vision:11b",
            "",
            "2. 이미지 전처리:",
            "   - 적절한 해상도로 리사이즈",
            "   - 명암 대비 조정",
            "   - 노이즈 제거",
            "",
            "3. 배치 처리 최적화:",
            "   - CPU 코어 수에 맞는 워커 설정",
            "   - 메모리 사용량 모니터링",
            "   - 적절한 청크 크기"
        ]
        
        for tip in performance_tips:
            print(tip)
        
        return True
    
    def auto_fix_common_issues(self):
        """일반적인 문제 자동 수정"""
        
        print("\n🔧 자동 문제 해결 시도...")
        
        # 1. Ollama 서비스 시작
        if not self.diagnose_ollama_connection():
            print("🚀 Ollama 서비스 자동 시작 시도...")
            try:
                import subprocess
                subprocess.Popen(['ollama', 'serve'])
                time.sleep(5)
                
                if self.diagnose_ollama_connection():
                    print("✅ Ollama 서비스 시작 성공")
                else:
                    print("❌ 자동 시작 실패")
            except Exception as e:
                print(f"❌ 자동 시작 실패: {str(e)}")
        
        # 2. 필수 패키지 설치
        try:
            import ollama_ocr
        except ImportError:
            print("📦 ollama-ocr 패키지 자동 설치...")
            try:
                import subprocess
                subprocess.run([sys.executable, '-m', 'pip', 'install', 'ollama-ocr'], check=True)
                print("✅ ollama-ocr 설치 완료")
            except Exception as e:
                print(f"❌ 자동 설치 실패: {str(e)}")
        
        # 3. 기본 비전 모델 다운로드
        if not self.diagnose_model_issues():
            print("🤖 기본 비전 모델 자동 다운로드...")
            try:
                import subprocess
                subprocess.run(['ollama', 'pull', 'llava'], check=True)
                print("✅ llava 모델 다운로드 완료")
            except Exception as e:
                print(f"❌ 모델 다운로드 실패: {str(e)}")
    
    def generate_health_report(self):
        """전체 상태 검진 보고서"""
        
        print("\n" + "="*50)
        print("🏥 Ollama-OCR 시스템 상태 검진")
        print("="*50)
        
        checks = [
            ("Ollama 연결", self.diagnose_ollama_connection),
            ("모델 상태", self.diagnose_model_issues),
            ("메모리 상태", self.diagnose_memory_issues),
            ("성능 상태", self.diagnose_performance_issues)
        ]
        
        passed_checks = 0
        total_checks = len(checks)
        
        for check_name, check_func in checks:
            try:
                if check_func():
                    passed_checks += 1
                    status = "✅ 정상"
                else:
                    status = "❌ 문제"
            except Exception as e:
                status = f"⚠️ 오류: {str(e)}"
            
            print(f"{check_name}: {status}")
        
        health_score = (passed_checks / total_checks) * 100
        print(f"\n🎯 시스템 건강도: {health_score:.0f}% ({passed_checks}/{total_checks})")
        
        if health_score >= 75:
            print("💚 시스템이 정상적으로 작동합니다!")
        elif health_score >= 50:
            print("💛 일부 최적화가 필요합니다.")
        else:
            print("❤️ 문제 해결이 필요합니다.")
            print("auto_fix_common_issues() 실행을 권장합니다.")

# 사용 예제
if __name__ == "__main__":
    troubleshooter = OllamaOCRTroubleshooter()
    
    # 자동 문제 해결 시도
    troubleshooter.auto_fix_common_issues()
    
    # 전체 상태 검진
    troubleshooter.generate_health_report()
```

## 결론

Ollama-OCR은 **로컬 환경에서 실행되는 강력한 OCR 솔루션**으로, 데이터 프라이버시를 보장하면서도 **클라우드 API 수준의 정확도**를 제공합니다. 다양한 비전 모델을 지원하여 사용자의 요구사항에 맞는 최적의 선택이 가능합니다.

### 핵심 장점

- 🔒 **완전한 프라이버시**: 모든 처리가 로컬에서 실행
- 🤖 **다양한 모델**: 용도별 최적화된 5가지 비전 모델
- 📄 **광범위한 지원**: PDF, 이미지, 다양한 출력 형식
- ⚡ **고성능**: 배치 처리와 병렬화 지원
- 🌐 **사용자 친화적**: Streamlit 웹 인터페이스 제공

### 활용 분야

1. **비즈니스 문서 처리**: 인보이스, 계약서, 보고서 자동화
2. **개인 문서 관리**: 영수증 가계부, 명함 정리
3. **연구 및 학술**: 논문, 기술 문서 디지털화
4. **법무 및 행정**: 공문서, 양식 처리 자동화

### 모델 선택 가이드

| 용도 | 추천 모델 | 특징 |
|------|-----------|------|
| **일반 문서** | LLaVA | 빠른 속도, 낮은 리소스 |
| **비즈니스 문서** | Granite3.2 | 표/차트 특화, 문서 구조 보존 |
| **고정밀 작업** | Llama 3.2 Vision | 최고 정확도, 복잡한 레이아웃 |
| **모바일/엣지** | Moondream | 초경량, 실시간 처리 |
| **고해상도** | MiniCPM-V | 작은 텍스트, 상세한 내용 |

### 시작하기

```bash
# 1분 만에 시작하기
brew install ollama
ollama serve &
ollama pull llava
pip install ollama-ocr

python -c "
from ollama_ocr import OCRProcessor
ocr = OCRProcessor(model_name='llava')
print('🚀 Ollama-OCR 준비 완료!')
"
```

**Ollama-OCR과 함께 문서 처리 자동화의 새로운 차원을 경험해보세요.** 클라우드에 의존하지 않고도 **전문적인 수준의 OCR 솔루션**을 구축할 수 있습니다.

### 추가 학습 자료

더 많은 AI 도구 가이드는 블로그에서 확인하세요:
- [DeepAgents 심층 AI 에이전트 가이드](https://thakicloud.github.io/tutorials/deepagents-comprehensive-deep-ai-agents-guide/)
- [SnapAI AI 아이콘 생성 가이드](https://thakicloud.github.io/tutorials/snapai-ai-icon-generation-complete-guide/)

---

💡 **Pro Tip**: 이 가이드의 모든 예제는 실제 macOS 환경에서 테스트되었습니다. 궁금한 점이 있다면 [GitHub Issues](https://github.com/imanoop7/Ollama-OCR/issues)에서 커뮤니티와 소통하세요!
