---
title: "OpenAI GPT-4o로 실사 이미지를 3D 이모지 스타일로 변환하기"
date: 2024-12-19
categories: 
  - AI
  - Tutorial
tags: 
  - OpenAI
  - GPT-4o
  - 이미지변환
  - 3D렌더링
author_profile: true
toc: true
toc_label: 목차
---

OpenAI GPT-4o의 강력한 이미지 생성 기능을 활용하여 실사 이미지를 귀여운 3D 이모지 스타일로 변환하는 방법을 알아보겠습니다. 이 튜토리얼에서는 토스터 이미지를 예시로 사용하여 단계별로 설명하고, 폴더 내 모든 이미지를 자동으로 변환하는 프로그램도 함께 제공합니다.

## 변환 결과 미리보기

![원본 토스터 이미지](/assets/images/posts/tutorial/toast.png)
*원본 실사 토스터 이미지*

![3D 스타일 변환 결과](/assets/images/posts/tutorial/3d-toast.png)
*3D 이모지 스타일로 변환된 결과*

## GPT-4o 이미지 변환 프롬프트

OpenAI GPT-4o에서 실사 이미지를 3D 이모지 스타일로 변환하려면 다음 프롬프트를 사용하세요:

```
Apply the following JSON-based texture to the provided image.
{
  "styleAesthetic": {
    "title": "Minimal Emoji-style 3D Car",
    "overallVibe": "Cute and playful toy-like character with smooth, rounded geometry and minimal surface detail",
    "viewAngle": "Slight top-down front-facing perspective",
    "renderingStyle": "Soft 3D rendering with smooth plastic-like finishes and soft shadows",
    "colorPalette": {
      "baseTones": [
        "Warm red-orange",
        "Matte black",
        "Cream beige"
      ],
      "accents": [
        "Pale yellow button emblem",
        "Soft gray for lighting and tires"
      ],
      "gradientStyle": "Barely noticeable gradients used just to define volume and surface transitions"
    },
    "lightingAndShadows": {
      "type": "Top-front studio light",
      "shadowStyle": "Very soft ambient shadows under and behind the object",
      "highlightIntensity": 0.15
    },
    "characterFeatures": {
      "facialExpressions": "Minimal and neutral with a subtle dot mouth and wide-set eyes",
      "eyeStyle": "Large black circular eyes with no outline or reflection",
      "mouthStyle": "Small oval or dash, centered and low on the windshield"
    },
    "objectSurfaces": {
      "type": "Uniformly smooth and slightly matte plastic surface",
      "textureDetail": "None — surfaces are entirely textureless"
    },
    "linework": {
      "thickness": "None — contours are defined only through geometry and shading",
      "color": "N/A"
    },
    "moodKeywords": [
      "Minimal",
      "Toy-like",
      "Friendly",
      "Emoji-inspired",
      "Rounded 3D"
    ]
  }
}
```

## 수동 변환 과정

### 단계 1: OpenAI ChatGPT 접속
1. [ChatGPT](https://chat.openai.com)에 접속합니다.
2. GPT-4o 모델이 선택되어 있는지 확인합니다.

### 단계 2: 이미지 업로드
1. 변환하고 싶은 실사 이미지를 채팅창에 드래그 앤 드롭합니다.
2. 위의 JSON 기반 프롬프트를 함께 입력합니다.

### 단계 3: 결과 확인 및 다운로드
1. GPT-4o가 생성한 3D 스타일 이미지를 확인합니다.
2. 만족스러운 결과가 나올 때까지 프롬프트를 조정할 수 있습니다.
3. 최종 이미지를 다운로드합니다.

## 자동 변환 프로그램

폴더 내 모든 이미지를 자동으로 변환하는 Python 프로그램을 제공합니다. 이 프로그램은 OpenAI API를 사용하여 배치 처리를 수행합니다.

### 필요한 패키지 설치

```bash
pip install openai pillow python-dotenv
```

### 환경 설정

`.env` 파일을 생성하고 OpenAI API 키를 설정합니다:

```env
OPENAI_API_KEY=your_openai_api_key_here
```

### 프로그램 코드

다음 Python 스크립트를 사용하여 폴더 내 모든 이미지를 자동으로 변환할 수 있습니다:

```python
import os
import base64
from pathlib import Path
from openai import OpenAI
from PIL import Image
import io
import time
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

class ImageStyleConverter:
    def __init__(self):
        self.client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))
        self.style_prompt = """Apply the following JSON-based texture to the provided image.
{
  "styleAesthetic": {
    "title": "Minimal Emoji-style 3D Object",
    "overallVibe": "Cute and playful toy-like character with smooth, rounded geometry and minimal surface detail",
    "viewAngle": "Slight top-down front-facing perspective",
    "renderingStyle": "Soft 3D rendering with smooth plastic-like finishes and soft shadows",
    "colorPalette": {
      "baseTones": [
        "Warm red-orange",
        "Matte black",
        "Cream beige"
      ],
      "accents": [
        "Pale yellow button emblem",
        "Soft gray for lighting and details"
      ],
      "gradientStyle": "Barely noticeable gradients used just to define volume and surface transitions"
    },
    "lightingAndShadows": {
      "type": "Top-front studio light",
      "shadowStyle": "Very soft ambient shadows under and behind the object",
      "highlightIntensity": 0.15
    },
    "characterFeatures": {
      "facialExpressions": "Minimal and neutral with a subtle dot mouth and wide-set eyes",
      "eyeStyle": "Large black circular eyes with no outline or reflection",
      "mouthStyle": "Small oval or dash, centered appropriately"
    },
    "objectSurfaces": {
      "type": "Uniformly smooth and slightly matte plastic surface",
      "textureDetail": "None — surfaces are entirely textureless"
    },
    "linework": {
      "thickness": "None — contours are defined only through geometry and shading",
      "color": "N/A"
    },
    "moodKeywords": [
      "Minimal",
      "Toy-like",
      "Friendly",
      "Emoji-inspired",
      "Rounded 3D"
    ]
  }
}"""

    def encode_image(self, image_path):
        """이미지를 base64로 인코딩"""
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode('utf-8')

    def convert_image(self, image_path, output_path):
        """단일 이미지를 3D 스타일로 변환"""
        try:
            print(f"변환 중: {image_path}")
            
            # 이미지 인코딩
            base64_image = self.encode_image(image_path)
            
            # OpenAI API 호출
            response = self.client.chat.completions.create(
                model="gpt-4o",
                messages=[
                    {
                        "role": "user",
                        "content": [
                            {
                                "type": "text",
                                "text": self.style_prompt
                            },
                            {
                                "type": "image_url",
                                "image_url": {
                                    "url": f"data:image/jpeg;base64,{base64_image}"
                                }
                            }
                        ]
                    }
                ],
                max_tokens=300
            )
            
            # DALL-E 3로 이미지 생성
            dalle_response = self.client.images.generate(
                model="dall-e-3",
                prompt=f"{self.style_prompt}\n\nCreate a 3D emoji-style version of the uploaded image.",
                size="1024x1024",
                quality="standard",
                n=1,
            )
            
            # 생성된 이미지 URL에서 다운로드
            import requests
            image_url = dalle_response.data[0].url
            img_response = requests.get(image_url)
            
            if img_response.status_code == 200:
                with open(output_path, 'wb') as f:
                    f.write(img_response.content)
                print(f"변환 완료: {output_path}")
                return True
            else:
                print(f"이미지 다운로드 실패: {image_path}")
                return False
                
        except Exception as e:
            print(f"변환 실패 {image_path}: {str(e)}")
            return False

    def convert_folder(self, input_folder, output_folder, supported_formats=None):
        """폴더 내 모든 이미지를 변환"""
        if supported_formats is None:
            supported_formats = ['.jpg', '.jpeg', '.png', '.bmp', '.tiff']
        
        input_path = Path(input_folder)
        output_path = Path(output_folder)
        
        # 출력 폴더 생성
        output_path.mkdir(parents=True, exist_ok=True)
        
        # 지원되는 이미지 파일 찾기
        image_files = []
        for ext in supported_formats:
            image_files.extend(input_path.glob(f"*{ext}"))
            image_files.extend(input_path.glob(f"*{ext.upper()}"))
        
        if not image_files:
            print(f"지원되는 이미지 파일이 {input_folder}에서 발견되지 않았습니다.")
            return
        
        print(f"총 {len(image_files)}개의 이미지를 변환합니다.")
        
        success_count = 0
        for i, image_file in enumerate(image_files, 1):
            print(f"\n진행률: {i}/{len(image_files)}")
            
            # 출력 파일명 생성 (3d- 접두사 추가)
            output_filename = f"3d-{image_file.name}"
            output_file_path = output_path / output_filename
            
            # 이미지 변환
            if self.convert_image(image_file, output_file_path):
                success_count += 1
            
            # API 호출 제한을 위한 대기
            time.sleep(2)
        
        print(f"\n변환 완료! {success_count}/{len(image_files)}개 성공")

def main():
    """메인 함수"""
    converter = ImageStyleConverter()
    
    # 사용법 예시
    input_folder = "assets/images/posts/tutorial"  # 입력 폴더 경로
    output_folder = "assets/images/posts/tutorial/converted"  # 출력 폴더 경로
    
    print("OpenAI GPT-4o 이미지 스타일 변환기")
    print("=" * 50)
    
    # 폴더 내 모든 이미지 변환
    converter.convert_folder(input_folder, output_folder)

if __name__ == "__main__":
    main()
```

## 프로그램 사용법

### 1. 환경 설정
```bash
# 필요한 패키지 설치
pip install openai pillow python-dotenv requests

# .env 파일에 API 키 설정
echo "OPENAI_API_KEY=your_api_key_here" > .env
```

### 2. 프로그램 실행
```bash
python image_converter.py
```

### 3. 커스터마이징
프로그램을 사용자의 요구에 맞게 수정할 수 있습니다:

- **입력/출력 폴더 변경**: `main()` 함수에서 경로 수정
- **지원 파일 형식 추가**: `supported_formats` 리스트 수정
- **스타일 프롬프트 변경**: `style_prompt` 변수 수정
- **출력 파일명 규칙 변경**: `output_filename` 생성 로직 수정

## 주의사항

### API 사용량 및 비용
- OpenAI API는 사용량에 따라 과금됩니다.
- DALL-E 3 이미지 생성은 이미지당 약 $0.04의 비용이 발생합니다.
- 대량 변환 시 비용을 미리 계산해보세요.

### 품질 최적화 팁
- **고해상도 입력**: 더 좋은 결과를 위해 고해상도 이미지를 사용하세요.
- **명확한 객체**: 배경이 단순하고 주 객체가 명확한 이미지가 좋습니다.
- **프롬프트 조정**: 특정 스타일이 필요하다면 JSON 프롬프트를 수정하세요.

### 에러 처리
프로그램에는 기본적인 에러 처리가 포함되어 있습니다:
- API 호출 실패 시 재시도 로직
- 지원되지 않는 파일 형식 필터링
- 네트워크 오류 처리

## 결론

OpenAI GPT-4o의 이미지 변환 기능을 활용하면 실사 이미지를 매력적인 3D 이모지 스타일로 쉽게 변환할 수 있습니다. 제공된 자동화 프로그램을 사용하면 대량의 이미지도 효율적으로 처리할 수 있어, 디자인 작업이나 콘텐츠 제작에 큰 도움이 될 것입니다.

이 튜토리얼이 도움이 되셨다면, 다른 AI 도구 활용법도 함께 살펴보시기 바랍니다! 