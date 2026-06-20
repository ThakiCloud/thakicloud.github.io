---
title: "FantasyPortrait: 다중 캐릭터 초상화 애니메이션을 위한 표정 증강 확산 변환기 완전 가이드"
excerpt: "Alibaba AMAP CV Lab의 FantasyPortrait로 다중 인물 초상화 애니메이션 생성하기. Multi-Expr 데이터셋과 확산 변환기를 활용한 워크플로우 자동화"
seo_title: "FantasyPortrait 다중 캐릭터 애니메이션 가이드 - 확산 변환기 활용 - Thaki Cloud"
seo_description: "FantasyPortrait를 활용한 다중 인물 초상화 애니메이션 생성 워크플로우. 설치부터 Multi-Expr 데이터셋 활용까지 포함한 완전 가이드"
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - owm
  - research
tags:
  - fantasyportrait
  - multi-character-animation
  - diffusion-transformers
  - expression-augmented
  - portrait-animation
  - alibaba-amap
  - multi-expr-dataset
  - video-generation
  - face-animation
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/owm/fantasyportrait-multi-character-animation-diffusion-transformers-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 12분

## 서론

다중 인물의 초상화에 생동감 있는 표정과 움직임을 부여하는 것은 디지털 콘텐츠 제작에서 오랫동안 도전 과제였습니다. [FantasyPortrait](https://huggingface.co/acvlab/FantasyPortrait)는 Alibaba AMAP CV Lab에서 개발한 혁신적인 모델로, **표정 증강 확산 변환기(Expression-Augmented Diffusion Transformers)**를 활용하여 이 문제를 해결합니다.

이 모델은 단일 이미지에서 시작하여 다중 캐릭터의 자연스러운 표정 변화와 애니메이션을 생성할 수 있으며, 특히 **Multi-Expr Dataset**이라는 최초의 다중 초상화 표정 비디오 데이터셋을 공개하여 연구 커뮤니티에 큰 기여를 하고 있습니다.

### 이 가이드에서 배울 내용

- FantasyPortrait의 핵심 기술과 아키텍처
- Multi-Expr Dataset의 특징과 활용 방법
- 개발 환경 설정 및 모델 설치
- 단일 및 다중 인물 애니메이션 생성 워크플로우
- 성능 최적화 및 VRAM 효율적 사용법
- 실제 프로덕션 환경에서의 활용 사례

### 기술 요구사항

- **GPU**: NVIDIA A100 권장 (최소 5GB VRAM)
- **Python**: 3.8+
- **PyTorch**: 2.0.0+
- **CUDA**: 11.8+
- **메모리**: 최소 32GB RAM

## FantasyPortrait 기술 개요

### 핵심 혁신 사항

FantasyPortrait는 다음과 같은 기술적 혁신을 통해 기존 초상화 애니메이션의 한계를 극복합니다:

#### 1. 표정 증강 확산 변환기 (Expression-Augmented Diffusion Transformers)

```python
# 핵심 아키텍처 개념
class ExpressionAugmentedDiT:
    def __init__(self):
        self.expression_encoder = ExpressionEncoder()
        self.diffusion_transformer = DiffusionTransformer()
        self.multi_character_handler = MultiCharacterHandler()
    
    def forward(self, input_image, expression_guidance):
        # 표정 특징 추출
        expr_features = self.expression_encoder(expression_guidance)
        
        # 다중 캐릭터 처리
        char_features = self.multi_character_handler(input_image)
        
        # 확산 변환기를 통한 애니메이션 생성
        animation = self.diffusion_transformer(
            char_features, 
            expr_features
        )
        
        return animation
```

#### 2. Multi-Expr Dataset

FantasyPortrait는 최초의 다중 초상화 표정 비디오 데이터셋을 공개했습니다:

- **다양한 표정**: 기쁨, 슬픔, 분노, 놀라움 등 복잡한 감정 표현
- **다중 인물 지원**: 한 장면에서 여러 사람의 표정 변화 동시 처리
- **고품질 비디오**: 720p 해상도의 부드러운 애니메이션
- **풍부한 메타데이터**: 각 프레임별 표정 라벨과 강도 정보

#### 3. 계층적 처리 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Input Image    │    │  Expression     │    │  Multi-Character│
│  Processing     │────│  Guidance       │────│  Animation      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Face Detection │    │  Expression     │    │  Temporal       │
│  & Segmentation │    │  Encoding       │    │  Consistency    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 환경 설정 및 설치

### 1단계: 기본 환경 준비

```bash
# 시스템 요구사항 확인
nvidia-smi  # CUDA 지원 GPU 확인
python --version  # Python 3.8+ 확인

# 기본 패키지 설치 (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install -y ffmpeg git wget curl

# macOS의 경우
brew install ffmpeg git wget
```

### 2단계: FantasyPortrait 저장소 클론

```bash
# 프로젝트 디렉토리 생성
mkdir -p ~/ai-projects/fantasy-portrait
cd ~/ai-projects/fantasy-portrait

# 저장소 클론
git clone https://github.com/Fantasy-AMAP/fantasy-portrait.git
cd fantasy-portrait

# 브랜치 확인
git branch -a
git checkout main  # 또는 최신 release 브랜치
```

### 3단계: Python 가상환경 설정

```bash
# conda 환경 생성 (권장)
conda create -n fantasy-portrait python=3.9
conda activate fantasy-portrait

# 또는 venv 사용
python -m venv fantasy-portrait-env
source fantasy-portrait-env/bin/activate  # Linux/macOS
# fantasy-portrait-env\Scripts\activate  # Windows
```

### 4단계: 의존성 설치

```bash
# PyTorch 설치 (CUDA 버전에 맞게)
pip install torch==2.1.0 torchvision==0.16.0 torchaudio==2.1.0 --index-url https://download.pytorch.org/whl/cu118

# 프로젝트 의존성 설치
pip install -r requirements.txt

# Flash Attention 설치 (필수)
pip install flash-attn --no-build-isolation

# 추가 유틸리티
pip install accelerate transformers diffusers
```

### 5단계: 설치 검증

```python
# test_installation.py
import torch
import torch.nn.functional as F
from diffusers import AutoencoderKL
import flash_attn

def test_installation():
    print("🔍 설치 확인 중...")
    
    # CUDA 사용 가능 여부
    print(f"✅ CUDA available: {torch.cuda.is_available()}")
    if torch.cuda.is_available():
        print(f"   GPU 개수: {torch.cuda.device_count()}")
        print(f"   현재 GPU: {torch.cuda.get_device_name()}")
        print(f"   VRAM: {torch.cuda.get_device_properties(0).total_memory / 1e9:.1f}GB")
    
    # Flash Attention 확인
    try:
        import flash_attn
        print("✅ Flash Attention 설치됨")
    except ImportError:
        print("❌ Flash Attention 설치 실패")
        return False
    
    # Diffusers 확인
    try:
        from diffusers import AutoencoderKL
        print("✅ Diffusers 설치됨")
    except ImportError:
        print("❌ Diffusers 설치 실패")
        return False
    
    print("🎉 모든 의존성이 성공적으로 설치되었습니다!")
    return True

if __name__ == "__main__":
    test_installation()
```

## 모델 다운로드 및 설정

### 자동 다운로드 스크립트

```bash
#!/bin/bash
# download_models.sh

set -e

echo "🚀 FantasyPortrait 모델 다운로드 시작..."

# 모델 디렉토리 생성
mkdir -p ./models

# Hugging Face CLI 설치 확인
if ! command -v huggingface-cli &> /dev/null; then
    echo "📦 Hugging Face CLI 설치 중..."
    pip install "huggingface_hub[cli]"
fi

# 베이스 모델 다운로드 (Wan2.1-I2V-14B-720P)
echo "📥 베이스 모델 다운로드 중..."
huggingface-cli download Wan-AI/Wan2.1-I2V-14B-720P \
    --local-dir ./models/Wan2.1-I2V-14B-720P \
    --resume-download

# FantasyPortrait 가중치 다운로드
echo "📥 FantasyPortrait 가중치 다운로드 중..."
huggingface-cli download acvlab/FantasyPortrait \
    --local-dir ./models/FantasyPortrait \
    --resume-download

# 다운로드 확인
echo "✅ 모델 다운로드 완료!"
echo "📁 모델 위치:"
echo "   베이스 모델: ./models/Wan2.1-I2V-14B-720P"
echo "   FantasyPortrait: ./models/FantasyPortrait"

# 디스크 사용량 확인
echo "💾 디스크 사용량:"
du -sh ./models/*
```

### ModelScope를 통한 다운로드 (중국 사용자용)

```bash
#!/bin/bash
# download_models_modelscope.sh

echo "🚀 ModelScope를 통한 모델 다운로드..."

# ModelScope CLI 설치
pip install modelscope

# 모델 다운로드
modelscope download Wan-AI/Wan2.1-I2V-14B-720P \
    --local_dir ./models/Wan2.1-I2V-14B-720P

modelscope download amap_cvlab/FantasyPortrait \
    --local_dir ./models/FantasyPortrait

echo "✅ ModelScope 다운로드 완료!"
```

### 설정 파일 생성

```yaml
# config/fantasy_portrait.yaml
model:
  base_model_path: "./models/Wan2.1-I2V-14B-720P"
  fantasy_portrait_path: "./models/FantasyPortrait"
  
generation:
  resolution: [720, 1280]  # height, width
  num_frames: 16
  fps: 8
  guidance_scale: 7.5
  num_inference_steps: 20

optimization:
  torch_dtype: "bfloat16"  # bfloat16, float16, float32
  num_persistent_param_in_dit: 7000000000  # 7B for 20GB VRAM
  enable_model_offload: true
  enable_sequential_cpu_offload: false

output:
  output_dir: "./outputs"
  save_intermediate_frames: false
  video_codec: "libx264"
  video_quality: "high"
```

## Multi-Expr Dataset 활용

### 데이터셋 다운로드

```python
# download_dataset.py
import os
from huggingface_hub import snapshot_download

def download_multi_expr_dataset():
    """Multi-Expr Dataset 다운로드"""
    print("📊 Multi-Expr Dataset 다운로드 중...")
    
    # 데이터셋 다운로드
    dataset_path = snapshot_download(
        repo_id="acvlab/FantasyPortrait-Multi-Expr",
        repo_type="dataset",
        local_dir="./datasets/multi-expr",
        resume_download=True
    )
    
    print(f"✅ 데이터셋 다운로드 완료: {dataset_path}")
    
    # 데이터셋 구조 확인
    for root, dirs, files in os.walk(dataset_path):
        level = root.replace(dataset_path, '').count(os.sep)
        indent = ' ' * 2 * level
        print(f"{indent}{os.path.basename(root)}/")
        subindent = ' ' * 2 * (level + 1)
        for file in files[:5]:  # 처음 5개 파일만 표시
            print(f"{subindent}{file}")
        if len(files) > 5:
            print(f"{subindent}... 외 {len(files)-5}개 파일")

if __name__ == "__main__":
    download_multi_expr_dataset()
```

### 데이터셋 구조 분석

```python
# analyze_dataset.py
import json
import cv2
import numpy as np
from pathlib import Path

class MultiExprAnalyzer:
    def __init__(self, dataset_path="./datasets/multi-expr"):
        self.dataset_path = Path(dataset_path)
        self.metadata = self.load_metadata()
    
    def load_metadata(self):
        """메타데이터 로드"""
        metadata_file = self.dataset_path / "metadata.json"
        if metadata_file.exists():
            with open(metadata_file) as f:
                return json.load(f)
        return {}
    
    def analyze_videos(self):
        """비디오 파일 분석"""
        video_files = list(self.dataset_path.glob("**/*.mp4"))
        
        analysis = {
            "total_videos": len(video_files),
            "resolutions": {},
            "durations": [],
            "fps_values": [],
            "expression_types": {}
        }
        
        for video_file in video_files[:50]:  # 샘플 분석
            cap = cv2.VideoCapture(str(video_file))
            
            # 비디오 정보 추출
            width = int(cap.get(cv2.CAP_PROP_FRAME_WIDTH))
            height = int(cap.get(cv2.CAP_PROP_FRAME_HEIGHT))
            fps = cap.get(cv2.CAP_PROP_FPS)
            frame_count = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
            duration = frame_count / fps if fps > 0 else 0
            
            # 통계 수집
            resolution = f"{width}x{height}"
            analysis["resolutions"][resolution] = analysis["resolutions"].get(resolution, 0) + 1
            analysis["durations"].append(duration)
            analysis["fps_values"].append(fps)
            
            cap.release()
        
        # 통계 요약
        if analysis["durations"]:
            analysis["avg_duration"] = np.mean(analysis["durations"])
            analysis["avg_fps"] = np.mean(analysis["fps_values"])
        
        return analysis
    
    def get_expression_categories(self):
        """표정 카테고리 분석"""
        categories = {
            "happy": ["smile", "laugh", "joy", "cheerful"],
            "sad": ["cry", "tear", "sorrow", "melancholy"],
            "angry": ["frown", "rage", "mad", "furious"],
            "surprised": ["shock", "amazed", "astonished"],
            "neutral": ["calm", "normal", "default"],
            "fear": ["scared", "afraid", "worried"],
            "disgust": ["disgusted", "repulsed"]
        }
        
        return categories
    
    def print_analysis(self):
        """분석 결과 출력"""
        analysis = self.analyze_videos()
        
        print("📊 Multi-Expr Dataset 분석 결과")
        print("=" * 50)
        print(f"총 비디오 수: {analysis['total_videos']}")
        print(f"평균 길이: {analysis.get('avg_duration', 0):.2f}초")
        print(f"평균 FPS: {analysis.get('avg_fps', 0):.1f}")
        
        print("\n📐 해상도 분포:")
        for resolution, count in analysis['resolutions'].items():
            print(f"  {resolution}: {count}개")
        
        print(f"\n🎭 표정 카테고리: {len(self.get_expression_categories())}개")
        for category, expressions in self.get_expression_categories().items():
            print(f"  {category}: {', '.join(expressions[:3])}{'...' if len(expressions) > 3 else ''}")

# 사용 예제
if __name__ == "__main__":
    analyzer = MultiExprAnalyzer()
    analyzer.print_analysis()
```

## 단일 인물 애니메이션 생성

### 기본 워크플로우

```python
# single_portrait_inference.py
import torch
import cv2
import numpy as np
from PIL import Image
from pathlib import Path
import yaml

class SinglePortraitGenerator:
    def __init__(self, config_path="config/fantasy_portrait.yaml"):
        self.config = self.load_config(config_path)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.model = None
        
    def load_config(self, config_path):
        """설정 파일 로드"""
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    
    def load_model(self):
        """모델 로드"""
        print("🔄 FantasyPortrait 모델 로드 중...")
        
        # 여기서 실제 모델 로딩 로직 구현
        # (실제 구현은 FantasyPortrait의 공식 코드 참조)
        print("✅ 모델 로드 완료")
    
    def preprocess_image(self, image_path):
        """입력 이미지 전처리"""
        image = Image.open(image_path).convert("RGB")
        
        # 해상도 조정
        target_size = tuple(self.config['generation']['resolution'])
        image = image.resize(target_size[::-1], Image.LANCZOS)  # PIL은 (width, height)
        
        # 텐서 변환
        image_array = np.array(image) / 255.0
        image_tensor = torch.from_numpy(image_array).float()
        image_tensor = image_tensor.permute(2, 0, 1).unsqueeze(0)  # BCHW 형태
        
        return image_tensor.to(self.device)
    
    def generate_animation(self, image_path, expression_guidance=None, output_path=None):
        """단일 인물 애니메이션 생성"""
        if self.model is None:
            self.load_model()
        
        # 입력 이미지 처리
        input_tensor = self.preprocess_image(image_path)
        
        # 표정 가이던스 설정
        if expression_guidance is None:
            expression_guidance = {
                "expression_type": "happy",
                "intensity": 0.8,
                "transition_frames": 8
            }
        
        print(f"🎬 애니메이션 생성 중...")
        print(f"   입력 이미지: {image_path}")
        print(f"   표정 타입: {expression_guidance['expression_type']}")
        print(f"   강도: {expression_guidance['intensity']}")
        
        # 실제 추론 (구현 필요)
        # output_frames = self.model.generate(
        #     input_tensor, 
        #     expression_guidance,
        #     num_frames=self.config['generation']['num_frames'],
        #     guidance_scale=self.config['generation']['guidance_scale']
        # )
        
        # 임시 결과 생성 (데모용)
        output_frames = self.create_demo_frames(input_tensor)
        
        # 비디오 저장
        if output_path is None:
            output_path = f"./outputs/single_portrait_{Path(image_path).stem}.mp4"
        
        self.save_video(output_frames, output_path)
        
        return output_path
    
    def create_demo_frames(self, input_tensor):
        """데모용 프레임 생성"""
        num_frames = self.config['generation']['num_frames']
        frames = []
        
        # 간단한 애니메이션 효과 (실제로는 모델 출력 사용)
        base_frame = input_tensor.squeeze(0).permute(1, 2, 0).cpu().numpy()
        
        for i in range(num_frames):
            # 간단한 변형 효과
            frame = base_frame.copy()
            # 여기서 실제로는 모델이 생성한 프레임을 사용
            frames.append(frame)
        
        return np.stack(frames)
    
    def save_video(self, frames, output_path):
        """프레임을 비디오로 저장"""
        output_dir = Path(output_path).parent
        output_dir.mkdir(parents=True, exist_ok=True)
        
        height, width = frames.shape[1:3]
        fps = self.config['generation']['fps']
        
        # OpenCV 비디오 라이터 설정
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        writer = cv2.VideoWriter(str(output_path), fourcc, fps, (width, height))
        
        for frame in frames:
            # RGB to BGR 변환
            frame_bgr = cv2.cvtColor((frame * 255).astype(np.uint8), cv2.COLOR_RGB2BGR)
            writer.write(frame_bgr)
        
        writer.release()
        print(f"✅ 비디오 저장 완료: {output_path}")

# 사용 예제
def run_single_portrait_demo():
    generator = SinglePortraitGenerator()
    
    # 테스트 이미지들
    test_images = [
        "./samples/portrait1.jpg",
        "./samples/portrait2.jpg"
    ]
    
    expressions = [
        {"expression_type": "happy", "intensity": 0.8},
        {"expression_type": "surprised", "intensity": 0.6},
        {"expression_type": "sad", "intensity": 0.7}
    ]
    
    for image_path in test_images:
        if Path(image_path).exists():
            for expr in expressions:
                output_path = generator.generate_animation(
                    image_path, 
                    expression_guidance=expr
                )
                print(f"🎥 생성된 비디오: {output_path}")

if __name__ == "__main__":
    run_single_portrait_demo()
```

### 실제 실행 스크립트

```bash
#!/bin/bash
# infer_single.sh

echo "🎬 단일 인물 애니메이션 생성 시작..."

# 환경 변수 설정
export CUDA_VISIBLE_DEVICES=0
export TORCH_CUDA_ARCH_LIST="7.5;8.0;8.6"

# Python 스크립트 실행
python scripts/inference_single.py \
    --input_image "./samples/input_portrait.jpg" \
    --output_dir "./outputs/single" \
    --expression_type "happy" \
    --intensity 0.8 \
    --num_frames 16 \
    --guidance_scale 7.5 \
    --seed 42 \
    --torch_dtype "bfloat16"

echo "✅ 단일 인물 애니메이션 생성 완료!"
```

## 다중 인물 애니메이션 생성

### 다중 인물 처리 알고리즘

```python
# multi_portrait_inference.py
import torch
import numpy as np
from PIL import Image, ImageDraw
import cv2
import mediapipe as mp
from typing import List, Dict, Tuple

class MultiPortraitGenerator:
    def __init__(self, config_path="config/fantasy_portrait.yaml"):
        self.config = self.load_config(config_path)
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        
        # MediaPipe 얼굴 감지 초기화
        self.mp_face_detection = mp.solutions.face_detection
        self.mp_drawing = mp.solutions.drawing_utils
        self.face_detection = self.mp_face_detection.FaceDetection(
            model_selection=1, 
            min_detection_confidence=0.5
        )
        
    def load_config(self, config_path):
        """설정 파일 로드"""
        import yaml
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    
    def detect_faces(self, image_path):
        """이미지에서 얼굴 감지"""
        image = cv2.imread(image_path)
        image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
        
        results = self.face_detection.process(image_rgb)
        
        faces = []
        if results.detections:
            for i, detection in enumerate(results.detections):
                bbox = detection.location_data.relative_bounding_box
                h, w, _ = image.shape
                
                # 절대 좌표로 변환
                x = int(bbox.xmin * w)
                y = int(bbox.ymin * h)
                width = int(bbox.width * w)
                height = int(bbox.height * h)
                
                faces.append({
                    "id": i,
                    "bbox": [x, y, width, height],
                    "confidence": detection.score[0],
                    "center": [x + width//2, y + height//2]
                })
        
        return faces, image_rgb
    
    def extract_face_regions(self, image, faces):
        """얼굴 영역 추출"""
        face_regions = []
        
        for face in faces:
            x, y, w, h = face["bbox"]
            
            # 얼굴 영역 확장 (컨텍스트 포함)
            margin = 0.2
            x_margin = int(w * margin)
            y_margin = int(h * margin)
            
            x1 = max(0, x - x_margin)
            y1 = max(0, y - y_margin)
            x2 = min(image.shape[1], x + w + x_margin)
            y2 = min(image.shape[0], y + h + y_margin)
            
            face_region = image[y1:y2, x1:x2]
            
            face_regions.append({
                "id": face["id"],
                "region": face_region,
                "original_bbox": [x1, y1, x2-x1, y2-y1],
                "face_bbox": face["bbox"]
            })
        
        return face_regions
    
    def generate_multi_portrait_animation(
        self, 
        image_path: str, 
        expression_configs: List[Dict],
        output_path: str = None
    ):
        """다중 인물 애니메이션 생성"""
        print("🎭 다중 인물 애니메이션 생성 시작...")
        
        # 얼굴 감지
        faces, image = self.detect_faces(image_path)
        print(f"👥 감지된 얼굴 수: {len(faces)}")
        
        if len(faces) == 0:
            raise ValueError("이미지에서 얼굴을 찾을 수 없습니다")
        
        # 표정 설정 매칭
        if len(expression_configs) == 1:
            # 모든 얼굴에 같은 표정 적용
            expression_configs = expression_configs * len(faces)
        elif len(expression_configs) != len(faces):
            raise ValueError(f"표정 설정 수({len(expression_configs)})와 얼굴 수({len(faces)})가 일치하지 않습니다")
        
        # 얼굴 영역 추출
        face_regions = self.extract_face_regions(image, faces)
        
        # 각 얼굴에 대해 애니메이션 생성
        animated_faces = []
        for i, (face_region, expr_config) in enumerate(zip(face_regions, expression_configs)):
            print(f"🎬 얼굴 {i+1}/{len(faces)} 애니메이션 생성 중...")
            
            # 개별 얼굴 애니메이션 생성
            face_animation = self.generate_single_face_animation(
                face_region, 
                expr_config
            )
            
            animated_faces.append({
                "id": face_region["id"],
                "animation": face_animation,
                "bbox": face_region["original_bbox"]
            })
        
        # 애니메이션 합성
        final_animation = self.composite_animations(
            image, 
            animated_faces
        )
        
        # 비디오 저장
        if output_path is None:
            output_path = f"./outputs/multi_portrait_{Path(image_path).stem}.mp4"
        
        self.save_video(final_animation, output_path)
        
        return output_path
    
    def generate_single_face_animation(self, face_region, expression_config):
        """단일 얼굴 애니메이션 생성"""
        # 실제 구현에서는 FantasyPortrait 모델 사용
        # 여기서는 데모용 간단한 변형 적용
        
        region = face_region["region"]
        num_frames = self.config['generation']['num_frames']
        
        animation_frames = []
        for frame_idx in range(num_frames):
            # 간단한 애니메이션 효과 (실제로는 모델 출력)
            frame = region.copy()
            
            # 표정에 따른 변형 (데모용)
            if expression_config["expression_type"] == "happy":
                # 밝기 증가 효과
                frame = cv2.convertScaleAbs(frame, alpha=1.1, beta=10)
            elif expression_config["expression_type"] == "sad":
                # 채도 감소 효과
                frame = cv2.convertScaleAbs(frame, alpha=0.9, beta=-10)
            
            animation_frames.append(frame)
        
        return np.stack(animation_frames)
    
    def composite_animations(self, background_image, animated_faces):
        """애니메이션 합성"""
        num_frames = self.config['generation']['num_frames']
        h, w = background_image.shape[:2]
        
        composite_frames = []
        
        for frame_idx in range(num_frames):
            # 배경 이미지로 시작
            composite_frame = background_image.copy()
            
            # 각 얼굴 애니메이션 합성
            for animated_face in animated_faces:
                face_frame = animated_face["animation"][frame_idx]
                x, y, face_w, face_h = animated_face["bbox"]
                
                # 얼굴 영역 크기 조정
                face_frame_resized = cv2.resize(face_frame, (face_w, face_h))
                
                # 영역 확인 및 조정
                x2, y2 = x + face_w, y + face_h
                if x2 <= w and y2 <= h and x >= 0 and y >= 0:
                    composite_frame[y:y2, x:x2] = face_frame_resized
            
            composite_frames.append(composite_frame)
        
        return np.stack(composite_frames)
    
    def save_video(self, frames, output_path):
        """비디오 저장"""
        from pathlib import Path
        
        output_dir = Path(output_path).parent
        output_dir.mkdir(parents=True, exist_ok=True)
        
        height, width = frames.shape[1:3]
        fps = self.config['generation']['fps']
        
        fourcc = cv2.VideoWriter_fourcc(*'mp4v')
        writer = cv2.VideoWriter(str(output_path), fourcc, fps, (width, height))
        
        for frame in frames:
            # RGB to BGR 변환 (필요시)
            if frame.shape[2] == 3:  # RGB
                frame_bgr = cv2.cvtColor(frame, cv2.COLOR_RGB2BGR)
            else:
                frame_bgr = frame
            
            writer.write(frame_bgr)
        
        writer.release()
        print(f"✅ 다중 인물 비디오 저장 완료: {output_path}")

# 사용 예제
def run_multi_portrait_demo():
    generator = MultiPortraitGenerator()
    
    # 다중 인물 이미지 테스트
    image_path = "./samples/group_photo.jpg"
    
    # 각 인물별 표정 설정
    expression_configs = [
        {"expression_type": "happy", "intensity": 0.8},
        {"expression_type": "surprised", "intensity": 0.6},
        {"expression_type": "neutral", "intensity": 0.5}
    ]
    
    # 애니메이션 생성
    output_path = generator.generate_multi_portrait_animation(
        image_path, 
        expression_configs
    )
    
    print(f"🎥 다중 인물 애니메이션 생성 완료: {output_path}")

if __name__ == "__main__":
    run_multi_portrait_demo()
```

### 배치 처리 워크플로우

```python
# batch_processing.py
import os
import json
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor, ProcessPoolExecutor
import multiprocessing as mp

class BatchProcessor:
    def __init__(self, config_path="config/fantasy_portrait.yaml"):
        self.config = self.load_config(config_path)
        self.max_workers = min(mp.cpu_count(), 4)  # GPU 메모리 고려
        
    def load_config(self, config_path):
        import yaml
        with open(config_path, 'r') as f:
            return yaml.safe_load(f)
    
    def process_batch_job(self, job_config):
        """배치 작업 처리"""
        input_dir = Path(job_config["input_dir"])
        output_dir = Path(job_config["output_dir"])
        processing_type = job_config.get("type", "single")  # single or multi
        
        # 입력 이미지 수집
        image_extensions = [".jpg", ".jpeg", ".png", ".bmp"]
        image_files = []
        
        for ext in image_extensions:
            image_files.extend(input_dir.glob(f"*{ext}"))
            image_files.extend(input_dir.glob(f"*{ext.upper()}"))
        
        print(f"📁 발견된 이미지: {len(image_files)}개")
        
        # 출력 디렉토리 생성
        output_dir.mkdir(parents=True, exist_ok=True)
        
        # 작업 목록 생성
        tasks = []
        for image_file in image_files:
            task = {
                "input_path": str(image_file),
                "output_path": str(output_dir / f"{image_file.stem}_animated.mp4"),
                "type": processing_type,
                "expression_config": job_config.get("expression_config", {
                    "expression_type": "happy",
                    "intensity": 0.8
                })
            }
            tasks.append(task)
        
        # 병렬 처리
        if job_config.get("parallel", True):
            self.process_parallel(tasks)
        else:
            self.process_sequential(tasks)
        
        # 결과 보고서 생성
        self.generate_report(tasks, output_dir)
    
    def process_parallel(self, tasks):
        """병렬 처리"""
        print(f"🚀 병렬 처리 시작 (워커 수: {self.max_workers})")
        
        with ProcessPoolExecutor(max_workers=self.max_workers) as executor:
            futures = [executor.submit(self.process_single_task, task) for task in tasks]
            
            for i, future in enumerate(futures):
                try:
                    result = future.result(timeout=300)  # 5분 타임아웃
                    print(f"✅ 작업 {i+1}/{len(tasks)} 완료: {result}")
                except Exception as e:
                    print(f"❌ 작업 {i+1}/{len(tasks)} 실패: {e}")
    
    def process_sequential(self, tasks):
        """순차 처리"""
        print("🔄 순차 처리 시작")
        
        for i, task in enumerate(tasks):
            try:
                result = self.process_single_task(task)
                print(f"✅ 작업 {i+1}/{len(tasks)} 완료: {result}")
            except Exception as e:
                print(f"❌ 작업 {i+1}/{len(tasks)} 실패: {e}")
    
    def process_single_task(self, task):
        """단일 작업 처리"""
        import torch
        
        # GPU 메모리 관리
        torch.cuda.empty_cache()
        
        if task["type"] == "single":
            generator = SinglePortraitGenerator()
            return generator.generate_animation(
                task["input_path"],
                task["expression_config"],
                task["output_path"]
            )
        elif task["type"] == "multi":
            generator = MultiPortraitGenerator()
            return generator.generate_multi_portrait_animation(
                task["input_path"],
                [task["expression_config"]],
                task["output_path"]
            )
        else:
            raise ValueError(f"지원하지 않는 처리 타입: {task['type']}")
    
    def generate_report(self, tasks, output_dir):
        """처리 결과 보고서 생성"""
        report = {
            "total_tasks": len(tasks),
            "successful_tasks": 0,
            "failed_tasks": 0,
            "output_files": [],
            "processing_time": None
        }
        
        for task in tasks:
            output_path = Path(task["output_path"])
            if output_path.exists():
                report["successful_tasks"] += 1
                report["output_files"].append(str(output_path))
            else:
                report["failed_tasks"] += 1
        
        # 보고서 저장
        report_path = output_dir / "processing_report.json"
        with open(report_path, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📊 처리 완료 보고서:")
        print(f"   총 작업: {report['total_tasks']}")
        print(f"   성공: {report['successful_tasks']}")
        print(f"   실패: {report['failed_tasks']}")
        print(f"   보고서: {report_path}")

# 배치 처리 예제
def run_batch_processing():
    processor = BatchProcessor()
    
    job_config = {
        "input_dir": "./samples/batch_input",
        "output_dir": "./outputs/batch_output",
        "type": "single",  # 또는 "multi"
        "parallel": True,
        "expression_config": {
            "expression_type": "happy",
            "intensity": 0.8
        }
    }
    
    processor.process_batch_job(job_config)

if __name__ == "__main__":
    run_batch_processing()
```

## 성능 최적화 및 메모리 관리

### VRAM 최적화 전략

```python
# optimization.py
import torch
import gc
from contextlib import contextmanager

class MemoryOptimizer:
    def __init__(self):
        self.optimization_strategies = {
            "ultra_low": {
                "torch_dtype": torch.float16,
                "num_persistent_param_in_dit": 0,
                "enable_model_offload": True,
                "enable_sequential_cpu_offload": True,
                "enable_attention_slicing": True,
                "batch_size": 1
            },
            "balanced": {
                "torch_dtype": torch.bfloat16,
                "num_persistent_param_in_dit": 7e9,  # 7B
                "enable_model_offload": True,
                "enable_sequential_cpu_offload": False,
                "enable_attention_slicing": False,
                "batch_size": 2
            },
            "high_performance": {
                "torch_dtype": torch.bfloat16,
                "num_persistent_param_in_dit": None,  # 무제한
                "enable_model_offload": False,
                "enable_sequential_cpu_offload": False,
                "enable_attention_slicing": False,
                "batch_size": 4
            }
        }
    
    def get_optimization_config(self, available_vram_gb):
        """사용 가능한 VRAM에 따른 최적화 설정 반환"""
        if available_vram_gb < 8:
            return self.optimization_strategies["ultra_low"]
        elif available_vram_gb < 24:
            return self.optimization_strategies["balanced"]
        else:
            return self.optimization_strategies["high_performance"]
    
    @contextmanager
    def memory_efficient_inference(self):
        """메모리 효율적 추론 컨텍스트"""
        try:
            # 사전 정리
            torch.cuda.empty_cache()
            gc.collect()
            
            yield
            
        finally:
            # 사후 정리
            torch.cuda.empty_cache()
            gc.collect()
    
    def monitor_memory_usage(self):
        """VRAM 사용량 모니터링"""
        if torch.cuda.is_available():
            allocated = torch.cuda.memory_allocated() / 1e9
            reserved = torch.cuda.memory_reserved() / 1e9
            total = torch.cuda.get_device_properties(0).total_memory / 1e9
            
            print(f"💾 VRAM 사용량:")
            print(f"   할당됨: {allocated:.1f}GB")
            print(f"   예약됨: {reserved:.1f}GB")
            print(f"   전체: {total:.1f}GB")
            print(f"   사용률: {(allocated/total)*100:.1f}%")
            
            return {
                "allocated_gb": allocated,
                "reserved_gb": reserved,
                "total_gb": total,
                "usage_percent": (allocated/total)*100
            }
        
        return None

class OptimizedFantasyPortrait:
    def __init__(self, optimization_level="balanced"):
        self.optimizer = MemoryOptimizer()
        
        # 시스템 VRAM 확인
        if torch.cuda.is_available():
            vram_gb = torch.cuda.get_device_properties(0).total_memory / 1e9
        else:
            vram_gb = 0
        
        if optimization_level == "auto":
            self.config = self.optimizer.get_optimization_config(vram_gb)
        else:
            self.config = self.optimizer.optimization_strategies[optimization_level]
        
        print(f"🔧 최적화 레벨: {optimization_level}")
        print(f"   사용 가능 VRAM: {vram_gb:.1f}GB")
        print(f"   Torch dtype: {self.config['torch_dtype']}")
        print(f"   모델 오프로드: {self.config['enable_model_offload']}")
    
    def generate_with_optimization(self, input_data, **kwargs):
        """최적화된 추론 실행"""
        with self.optimizer.memory_efficient_inference():
            # 메모리 사용량 모니터링
            before_memory = self.optimizer.monitor_memory_usage()
            
            # 실제 추론 실행 (구현 필요)
            result = self.run_inference(input_data, **kwargs)
            
            # 후처리 메모리 확인
            after_memory = self.optimizer.monitor_memory_usage()
            
            if before_memory and after_memory:
                memory_diff = after_memory["allocated_gb"] - before_memory["allocated_gb"]
                print(f"📈 추론 중 메모리 증가: {memory_diff:.1f}GB")
            
            return result
    
    def run_inference(self, input_data, **kwargs):
        """실제 추론 로직 (구현 필요)"""
        # 여기서 FantasyPortrait 모델 실행
        pass

# 최적화된 배치 처리
class OptimizedBatchProcessor:
    def __init__(self, optimization_level="balanced"):
        self.optimizer = MemoryOptimizer()
        self.model = OptimizedFantasyPortrait(optimization_level)
        
    def process_batch_with_memory_management(self, image_paths, batch_size=None):
        """메모리 관리가 포함된 배치 처리"""
        if batch_size is None:
            batch_size = self.model.config["batch_size"]
        
        results = []
        
        for i in range(0, len(image_paths), batch_size):
            batch_paths = image_paths[i:i+batch_size]
            
            print(f"🔄 배치 {i//batch_size + 1} 처리 중 ({len(batch_paths)}개 이미지)")
            
            with self.optimizer.memory_efficient_inference():
                batch_results = []
                
                for image_path in batch_paths:
                    try:
                        result = self.model.generate_with_optimization(image_path)
                        batch_results.append(result)
                    except torch.cuda.OutOfMemoryError:
                        print("⚠️ CUDA OOM 발생, 메모리 정리 후 재시도")
                        torch.cuda.empty_cache()
                        gc.collect()
                        
                        # 더 작은 배치 크기로 재시도
                        result = self.model.generate_with_optimization(image_path)
                        batch_results.append(result)
                
                results.extend(batch_results)
        
        return results

# 사용 예제
if __name__ == "__main__":
    # 자동 최적화
    processor = OptimizedBatchProcessor("auto")
    
    # 배치 처리 실행
    image_paths = ["./samples/image1.jpg", "./samples/image2.jpg"]
    results = processor.process_batch_with_memory_management(image_paths)
    
    print(f"✅ 배치 처리 완료: {len(results)}개 결과")
```

## 실제 활용 사례 및 워크플로우

### 디지털 콘텐츠 제작 파이프라인

```python
# production_pipeline.py
import os
import json
from pathlib import Path
from datetime import datetime
import logging

class ContentProductionPipeline:
    def __init__(self, project_config):
        self.config = project_config
        self.setup_logging()
        self.setup_directories()
        
    def setup_logging(self):
        """로깅 설정"""
        log_dir = Path(self.config["output_dir"]) / "logs"
        log_dir.mkdir(parents=True, exist_ok=True)
        
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(log_dir / f"pipeline_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"),
                logging.StreamHandler()
            ]
        )
        
        self.logger = logging.getLogger(__name__)
    
    def setup_directories(self):
        """디렉토리 구조 설정"""
        base_dir = Path(self.config["output_dir"])
        
        self.directories = {
            "raw": base_dir / "01_raw",
            "processed": base_dir / "02_processed", 
            "animated": base_dir / "03_animated",
            "final": base_dir / "04_final",
            "metadata": base_dir / "metadata"
        }
        
        for dir_path in self.directories.values():
            dir_path.mkdir(parents=True, exist_ok=True)
    
    def process_character_batch(self, character_data):
        """캐릭터 배치 처리"""
        self.logger.info(f"🎭 캐릭터 배치 처리 시작: {len(character_data)}개")
        
        results = []
        
        for i, character in enumerate(character_data):
            try:
                self.logger.info(f"캐릭터 {i+1}/{len(character_data)} 처리 중: {character['name']}")
                
                # 1. 이미지 전처리
                processed_image = self.preprocess_character_image(character)
                
                # 2. 표정 애니메이션 생성
                animations = self.generate_character_animations(
                    processed_image, 
                    character["expressions"]
                )
                
                # 3. 후처리 및 품질 최적화
                final_animations = self.postprocess_animations(animations)
                
                # 4. 메타데이터 저장
                metadata = self.save_character_metadata(character, final_animations)
                
                results.append({
                    "character_id": character["id"],
                    "name": character["name"],
                    "animations": final_animations,
                    "metadata": metadata,
                    "status": "success"
                })
                
            except Exception as e:
                self.logger.error(f"캐릭터 {character['name']} 처리 실패: {e}")
                results.append({
                    "character_id": character["id"],
                    "name": character["name"],
                    "status": "failed",
                    "error": str(e)
                })
        
        return results
    
    def preprocess_character_image(self, character):
        """캐릭터 이미지 전처리"""
        from PIL import Image, ImageEnhance
        
        image_path = character["image_path"]
        image = Image.open(image_path).convert("RGB")
        
        # 품질 향상
        if character.get("enhance_quality", True):
            # 선명도 향상
            enhancer = ImageEnhance.Sharpness(image)
            image = enhancer.enhance(1.2)
            
            # 대비 향상
            enhancer = ImageEnhance.Contrast(image)
            image = enhancer.enhance(1.1)
        
        # 해상도 조정
        target_size = character.get("target_resolution", [720, 1280])
        image = image.resize(target_size[::-1], Image.LANCZOS)
        
        # 전처리된 이미지 저장
        processed_path = self.directories["processed"] / f"{character['id']}_processed.jpg"
        image.save(processed_path, quality=95)
        
        return processed_path
    
    def generate_character_animations(self, image_path, expressions):
        """캐릭터 애니메이션 생성"""
        from multi_portrait_inference import MultiPortraitGenerator
        
        generator = MultiPortraitGenerator()
        animations = {}
        
        for expr_name, expr_config in expressions.items():
            self.logger.info(f"  표정 '{expr_name}' 애니메이션 생성 중...")
            
            output_path = self.directories["animated"] / f"{Path(image_path).stem}_{expr_name}.mp4"
            
            try:
                result_path = generator.generate_multi_portrait_animation(
                    str(image_path),
                    [expr_config],
                    str(output_path)
                )
                
                animations[expr_name] = {
                    "path": result_path,
                    "config": expr_config,
                    "status": "success"
                }
                
            except Exception as e:
                self.logger.error(f"  표정 '{expr_name}' 생성 실패: {e}")
                animations[expr_name] = {
                    "status": "failed",
                    "error": str(e)
                }
        
        return animations
    
    def postprocess_animations(self, animations):
        """애니메이션 후처리"""
        import subprocess
        
        final_animations = {}
        
        for expr_name, animation in animations.items():
            if animation["status"] != "success":
                final_animations[expr_name] = animation
                continue
            
            input_path = animation["path"]
            output_path = self.directories["final"] / f"{Path(input_path).stem}_final.mp4"
            
            # FFmpeg를 사용한 품질 최적화
            ffmpeg_cmd = [
                "ffmpeg", "-i", input_path,
                "-c:v", "libx264",
                "-preset", "medium",
                "-crf", "23",
                "-pix_fmt", "yuv420p",
                "-movflags", "+faststart",
                "-y", str(output_path)
            ]
            
            try:
                subprocess.run(ffmpeg_cmd, check=True, capture_output=True)
                
                final_animations[expr_name] = {
                    **animation,
                    "final_path": str(output_path),
                    "file_size": os.path.getsize(output_path)
                }
                
                self.logger.info(f"  '{expr_name}' 후처리 완료: {output_path}")
                
            except subprocess.CalledProcessError as e:
                self.logger.error(f"  '{expr_name}' 후처리 실패: {e}")
                final_animations[expr_name] = animation
        
        return final_animations
    
    def save_character_metadata(self, character, animations):
        """캐릭터 메타데이터 저장"""
        metadata = {
            "character_id": character["id"],
            "name": character["name"],
            "original_image": character["image_path"],
            "processing_timestamp": datetime.now().isoformat(),
            "animations": {},
            "total_animations": len(animations),
            "successful_animations": len([a for a in animations.values() if a["status"] == "success"])
        }
        
        for expr_name, animation in animations.items():
            metadata["animations"][expr_name] = {
                "status": animation["status"],
                "config": animation.get("config", {}),
                "output_path": animation.get("final_path", animation.get("path")),
                "file_size_mb": animation.get("file_size", 0) / (1024 * 1024)
            }
        
        # 메타데이터 파일 저장
        metadata_path = self.directories["metadata"] / f"{character['id']}_metadata.json"
        with open(metadata_path, 'w', encoding='utf-8') as f:
            json.dump(metadata, f, indent=2, ensure_ascii=False)
        
        return metadata
    
    def generate_project_report(self, results):
        """프로젝트 보고서 생성"""
        total_characters = len(results)
        successful = len([r for r in results if r["status"] == "success"])
        failed = total_characters - successful
        
        report = {
            "project_summary": {
                "total_characters": total_characters,
                "successful": successful,
                "failed": failed,
                "success_rate": (successful / total_characters) * 100 if total_characters > 0 else 0
            },
            "processing_details": results,
            "output_directories": {k: str(v) for k, v in self.directories.items()},
            "generated_timestamp": datetime.now().isoformat()
        }
        
        # 보고서 저장
        report_path = self.directories["metadata"] / "project_report.json"
        with open(report_path, 'w', encoding='utf-8') as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        # 요약 출력
        print(f"\n📊 프로젝트 완료 보고서")
        print(f"=" * 50)
        print(f"총 캐릭터: {total_characters}")
        print(f"성공: {successful}")
        print(f"실패: {failed}")
        print(f"성공률: {report['project_summary']['success_rate']:.1f}%")
        print(f"보고서 위치: {report_path}")
        
        return report

# 프로덕션 파이프라인 사용 예제
def run_production_pipeline():
    # 프로젝트 설정
    project_config = {
        "project_name": "Fantasy_Portrait_Demo",
        "output_dir": "./production_output",
        "optimization_level": "balanced"
    }
    
    # 캐릭터 데이터 정의
    character_data = [
        {
            "id": "char_001",
            "name": "주인공",
            "image_path": "./samples/protagonist.jpg",
            "expressions": {
                "happy": {"expression_type": "happy", "intensity": 0.8},
                "sad": {"expression_type": "sad", "intensity": 0.7},
                "angry": {"expression_type": "angry", "intensity": 0.9}
            },
            "target_resolution": [720, 1280],
            "enhance_quality": True
        },
        {
            "id": "char_002", 
            "name": "조연",
            "image_path": "./samples/supporting.jpg",
            "expressions": {
                "surprised": {"expression_type": "surprised", "intensity": 0.8},
                "neutral": {"expression_type": "neutral", "intensity": 0.5}
            },
            "target_resolution": [720, 1280],
            "enhance_quality": True
        }
    ]
    
    # 파이프라인 실행
    pipeline = ContentProductionPipeline(project_config)
    results = pipeline.process_character_batch(character_data)
    report = pipeline.generate_project_report(results)
    
    return report

if __name__ == "__main__":
    run_production_pipeline()
```

## 커뮤니티 활용 및 확장

### 오픈소스 기여 가이드

FantasyPortrait는 활발한 오픈소스 커뮤니티를 가지고 있습니다. 다음과 같은 방법으로 기여할 수 있습니다:

```python
# community_extensions.py
class CommunityExtensions:
    def __init__(self):
        self.extension_registry = {}
    
    def register_extension(self, name, extension_class):
        """커뮤니티 확장 등록"""
        self.extension_registry[name] = extension_class
        print(f"✅ 확장 '{name}' 등록됨")
    
    def load_extension(self, name):
        """확장 로드"""
        if name in self.extension_registry:
            return self.extension_registry[name]()
        else:
            raise ValueError(f"확장 '{name}'을 찾을 수 없습니다")

# 커뮤니티 확장 예제
class EmotionIntensityController:
    """표정 강도 세밀 제어 확장"""
    
    def __init__(self):
        self.emotion_mappings = {
            "joy": {"base_intensity": 0.8, "variation_range": 0.3},
            "sorrow": {"base_intensity": 0.7, "variation_range": 0.4},
            "anger": {"base_intensity": 0.9, "variation_range": 0.2}
        }
    
    def apply_emotion_curve(self, base_config, curve_type="linear"):
        """표정 변화 곡선 적용"""
        curves = {
            "linear": lambda x: x,
            "ease_in": lambda x: x * x,
            "ease_out": lambda x: 1 - (1 - x) ** 2,
            "bounce": lambda x: 1 - abs(1 - 2 * x)
        }
        
        curve_func = curves.get(curve_type, curves["linear"])
        
        # 표정 강도 곡선 계산
        modified_config = base_config.copy()
        modified_config["intensity_curve"] = curve_func
        
        return modified_config

class StyleTransferExtension:
    """스타일 전이 확장"""
    
    def apply_artistic_style(self, animation_config, style="anime"):
        """예술적 스타일 적용"""
        style_configs = {
            "anime": {
                "color_saturation": 1.3,
                "contrast_boost": 1.2,
                "eye_enhancement": True
            },
            "realistic": {
                "color_saturation": 1.0,
                "contrast_boost": 1.0,
                "skin_smoothing": True
            },
            "cartoon": {
                "color_saturation": 1.5,
                "contrast_boost": 1.4,
                "edge_enhancement": True
            }
        }
        
        style_config = style_configs.get(style, style_configs["realistic"])
        
        modified_config = animation_config.copy()
        modified_config["style_transfer"] = style_config
        
        return modified_config

# 확장 사용 예제
def use_community_extensions():
    extensions = CommunityExtensions()
    
    # 확장 등록
    extensions.register_extension("emotion_controller", EmotionIntensityController)
    extensions.register_extension("style_transfer", StyleTransferExtension)
    
    # 확장 사용
    emotion_ctrl = extensions.load_extension("emotion_controller")
    style_transfer = extensions.load_extension("style_transfer")
    
    # 기본 설정
    base_config = {
        "expression_type": "happy",
        "intensity": 0.8
    }
    
    # 표정 곡선 적용
    emotion_config = emotion_ctrl.apply_emotion_curve(base_config, "ease_in")
    
    # 스타일 적용
    final_config = style_transfer.apply_artistic_style(emotion_config, "anime")
    
    print("🎨 확장이 적용된 최종 설정:")
    print(json.dumps(final_config, indent=2))

if __name__ == "__main__":
    use_community_extensions()
```

## 결론

FantasyPortrait는 다중 캐릭터 초상화 애니메이션 분야에서 혁신적인 돌파구를 제시하는 강력한 도구입니다. 이 가이드를 통해 다음을 학습했습니다:

### 핵심 성과

- **최첨단 기술**: 표정 증강 확산 변환기를 활용한 자연스러운 애니메이션 생성
- **포괄적 데이터셋**: 최초의 Multi-Expr Dataset으로 다양한 표정 표현 지원
- **실용적 워크플로우**: 단일/다중 인물 처리부터 배치 작업까지 완전 자동화
- **최적화된 성능**: VRAM 효율적 사용으로 다양한 하드웨어 환경 지원

### 향후 발전 방향

1. **실시간 처리**: 라이브 스트리밍 환경에서의 실시간 표정 애니메이션
2. **멀티모달 확장**: 음성, 텍스트와 연동한 통합 캐릭터 생성
3. **고해상도 지원**: 4K, 8K 해상도에서의 고품질 애니메이션 생성
4. **모바일 최적화**: 스마트폰에서 실행 가능한 경량화 모델 개발

### 활용 분야

- **엔터테인먼트**: 게임, 애니메이션, VR/AR 콘텐츠
- **교육**: 인터랙티브 학습 도구, 가상 강사
- **마케팅**: 개인화된 광고, 브랜드 캐릭터
- **소셜미디어**: 개인 아바타, 감정 표현 스티커

### 유용한 리소스

- [FantasyPortrait Hugging Face 모델](https://huggingface.co/acvlab/FantasyPortrait)
- [Multi-Expr Dataset](https://huggingface.co/datasets/acvlab/FantasyPortrait-Multi-Expr)
- [arXiv 논문](https://arxiv.org/abs/2507.12956)
- [GitHub 저장소](https://github.com/Fantasy-AMAP/fantasy-portrait)

FantasyPortrait로 창의적인 디지털 콘텐츠 제작의 새로운 지평을 열어보세요! 🎭✨

---

_이 가이드가 도움이 되었다면 [Hugging Face](https://huggingface.co/acvlab/FantasyPortrait)에서 ❤️을 눌러주세요._
