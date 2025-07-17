#!/usr/bin/env python3
"""
Gemma3n FineVideo 파인튜닝 테스트 스크립트
macOS 환경에서 실행 가능한 간단한 테스트 코드
"""

import sys
import subprocess
import os
from datetime import datetime

def check_system_requirements():
    """시스템 요구사항 체크"""
    print("=== 시스템 요구사항 체크 ===")
    
    # Python 버전 확인
    python_version = sys.version_info
    print(f"Python 버전: {python_version.major}.{python_version.minor}.{python_version.micro}")
    
    if python_version < (3, 9):
        print("❌ Python 3.9 이상이 필요합니다.")
        return False
    
    # macOS 확인
    try:
        result = subprocess.run(['sw_vers'], capture_output=True, text=True)
        if result.returncode == 0:
            print(f"macOS 정보:\n{result.stdout}")
        else:
            print("⚠️ macOS 정보를 가져올 수 없습니다.")
    except FileNotFoundError:
        print("⚠️ macOS가 아닌 환경인 것 같습니다.")
    
    # Apple Silicon 확인
    try:
        result = subprocess.run(['system_profiler', 'SPDisplaysDataType'], 
                              capture_output=True, text=True)
        if 'Apple' in result.stdout:
            print("✅ Apple Silicon 감지됨")
        else:
            print("⚠️ Intel Mac인 것 같습니다.")
    except:
        print("⚠️ GPU 정보를 확인할 수 없습니다.")
    
    return True

def check_dependencies():
    """필수 패키지 설치 상태 확인"""
    print("\n=== 패키지 의존성 체크 ===")
    
    required_packages = [
        ('torch', 'torch'),
        ('transformers', 'transformers'), 
        ('datasets', 'datasets'),
        ('huggingface_hub', 'huggingface_hub'),
        ('opencv-python', 'cv2'),
        ('pillow', 'PIL'),
        ('numpy', 'numpy')
    ]
    
    missing_packages = []
    
    for package_name, import_name in required_packages:
        try:
            __import__(import_name)
            print(f"✅ {package_name} 설치됨")
        except ImportError:
            print(f"❌ {package_name} 설치 필요")
            missing_packages.append(package_name)
    
    if missing_packages:
        print(f"\n설치 필요한 패키지:")
        print(f"pip install {' '.join(missing_packages)}")
        return False
    
    return True

def test_huggingface_access():
    """HuggingFace 접근 테스트"""
    print("\n=== HuggingFace 접근 테스트 ===")
    
    try:
        from huggingface_hub import whoami
        
        # 토큰 확인
        try:
            user_info = whoami()
            print(f"✅ HuggingFace 로그인됨: {user_info}")
            return True
        except:
            print("❌ HuggingFace 토큰이 설정되지 않았습니다.")
            print("huggingface-cli login 명령으로 로그인하세요.")
            return False
            
    except ImportError:
        print("❌ huggingface_hub 패키지가 필요합니다.")
        return False

def test_small_dataset_load():
    """작은 데이터셋 로드 테스트"""
    print("\n=== 데이터셋 로드 테스트 ===")
    
    try:
        from datasets import load_dataset
        
        print("FineVideo 데이터셋 스트리밍 로드 테스트...")
        dataset = load_dataset(
            "HuggingFaceFV/finevideo", 
            split="train", 
            streaming=True
        )
        
        # 첫 번째 샘플 확인
        sample = next(iter(dataset))
        print(f"✅ 데이터셋 로드 성공")
        print(f"샘플 키: {list(sample.keys())}")
        
        # 메타데이터 크기 확인
        json_size = len(sample['json'])
        mp4_size = len(sample['mp4'])
        print(f"JSON 크기: {json_size:,} bytes")
        print(f"MP4 크기: {mp4_size:,} bytes")
        
        return True
        
    except Exception as e:
        print(f"❌ 데이터셋 로드 실패: {e}")
        return False

def test_video_processing():
    """비디오 처리 테스트"""
    print("\n=== 비디오 처리 테스트 ===")
    
    try:
        import cv2
        import numpy as np
        from PIL import Image
        
        # 테스트용 더미 비디오 데이터 생성
        print("더미 비디오 프레임 생성 테스트...")
        
        # 간단한 컬러 프레임 생성
        frames = []
        for i in range(4):
            # RGB 랜덤 컬러 프레임
            frame = np.random.randint(0, 256, (224, 224, 3), dtype=np.uint8)
            pil_frame = Image.fromarray(frame)
            frames.append(pil_frame)
        
        print(f"✅ {len(frames)}개 테스트 프레임 생성됨")
        print(f"프레임 크기: {frames[0].size}")
        
        return True
        
    except Exception as e:
        print(f"❌ 비디오 처리 테스트 실패: {e}")
        return False

def test_model_loading():
    """모델 로딩 테스트 (작은 모델로)"""
    print("\n=== 모델 로딩 테스트 ===")
    
    try:
        # Unsloth가 설치되어 있는지 확인
        try:
            import unsloth
            print("✅ Unsloth 패키지 확인됨")
        except ImportError:
            print("❌ Unsloth 설치 필요: pip install unsloth")
            return False
        
        # 간단한 transformers 모델로 테스트
        from transformers import AutoTokenizer
        
        print("작은 모델로 토크나이저 테스트...")
        tokenizer = AutoTokenizer.from_pretrained("google/gemma-2b")
        
        test_text = "안녕하세요, 테스트입니다."
        tokens = tokenizer(test_text, return_tensors="pt")
        
        print(f"✅ 토크나이저 테스트 성공")
        print(f"입력 텍스트: {test_text}")
        print(f"토큰 수: {tokens['input_ids'].shape[1]}")
        
        return True
        
    except Exception as e:
        print(f"❌ 모델 로딩 테스트 실패: {e}")
        return False

def estimate_memory_requirements():
    """메모리 요구사항 추정"""
    print("\n=== 메모리 요구사항 추정 ===")
    
    try:
        import psutil
        
        # 시스템 메모리 확인
        memory = psutil.virtual_memory()
        total_gb = memory.total / (1024**3)
        available_gb = memory.available / (1024**3)
        
        print(f"총 메모리: {total_gb:.1f} GB")
        print(f"사용 가능: {available_gb:.1f} GB")
        
        # 권장사항
        if total_gb >= 32:
            print("✅ Gemma3n-12B 훈련 가능 (32GB+)")
            recommended_model = "12B"
        elif total_gb >= 16:
            print("⚠️ Gemma3n-4B 권장 (16GB+)")
            recommended_model = "4B"
        elif total_gb >= 8:
            print("⚠️ Gemma3n-1B 권장 (8GB+)")
            recommended_model = "1B"
        else:
            print("❌ 메모리 부족 (최소 8GB 필요)")
            recommended_model = None
        
        return recommended_model
        
    except ImportError:
        print("❌ psutil 패키지 필요: pip install psutil")
        return None

def create_test_script():
    """실제 테스트 실행을 위한 스크립트 생성"""
    print("\n=== 테스트 스크립트 생성 ===")
    
    script_content = '''#!/usr/bin/env python3
"""
Gemma3n FineVideo 파인튜닝 실제 테스트
"""

def run_minimal_test():
    """최소한의 파인튜닝 테스트"""
    try:
        # 필수 임포트
        from datasets import load_dataset
        from transformers import AutoTokenizer
        import torch
        import json
        
        print("1. 데이터셋 로드...")
        dataset = load_dataset("HuggingFaceFV/finevideo", split="train", streaming=True)
        
        print("2. 샘플 처리...")
        samples = []
        for i, sample in enumerate(dataset):
            if i >= 3:  # 3개 샘플만 테스트
                break
            samples.append(sample)
        
        print(f"처리된 샘플: {len(samples)}개")
        
        print("3. 토크나이저 테스트...")
        tokenizer = AutoTokenizer.from_pretrained("google/gemma-2b")
        
        # 첫 번째 샘플의 메타데이터로 텍스트 생성
        metadata = json.loads(samples[0]['json'])
        title = metadata.get('youtube_title', 'Test Video')
        
        tokens = tokenizer(f"제목: {title}", return_tensors="pt")
        print(f"토큰화 완료: {tokens['input_ids'].shape}")
        
        print("✅ 기본 테스트 완료!")
        
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")

if __name__ == "__main__":
    run_minimal_test()
'''
    
    script_path = "gemma3n_minimal_test.py"
    with open(script_path, 'w', encoding='utf-8') as f:
        f.write(script_content)
    
    print(f"✅ 테스트 스크립트 생성됨: {script_path}")
    print(f"실행: python {script_path}")
    
    return script_path

def main():
    """메인 테스트 함수"""
    print("🦥 Gemma3n FineVideo 파인튜닝 환경 테스트")
    print(f"실행 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 50)
    
    # 각 테스트 실행
    tests = [
        check_system_requirements,
        check_dependencies,
        test_huggingface_access,
        test_small_dataset_load,
        test_video_processing,
        test_model_loading,
    ]
    
    passed_tests = 0
    total_tests = len(tests)
    
    for test in tests:
        try:
            if test():
                passed_tests += 1
        except Exception as e:
            print(f"❌ 테스트 중 오류: {e}")
    
    # 메모리 요구사항 확인
    recommended_model = estimate_memory_requirements()
    
    # 테스트 스크립트 생성
    create_test_script()
    
    # 결과 요약
    print("\n" + "=" * 50)
    print(f"테스트 결과: {passed_tests}/{total_tests} 통과")
    
    if passed_tests == total_tests:
        print("🎉 모든 테스트 통과! 파인튜닝을 시작할 수 있습니다.")
        if recommended_model:
            print(f"권장 모델: Gemma3n-{recommended_model}")
    else:
        print("⚠️ 일부 테스트 실패. 환경 설정을 확인하세요.")
    
    print("\n다음 단계:")
    print("1. 블로그 포스트의 전체 가이드를 따라하세요")
    print("2. HuggingFace 토큰을 설정하세요")
    print("3. 필요한 패키지를 설치하세요")
    print("4. 메모리 용량에 맞는 모델을 선택하세요")

if __name__ == "__main__":
    main() 