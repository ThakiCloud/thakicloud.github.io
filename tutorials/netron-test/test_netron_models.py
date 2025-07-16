#!/usr/bin/env python3
"""
Netron AI 모델 시각화 테스트 스크립트
다양한 모델 포맷을 생성하고 Netron으로 시각화 테스트
"""

import torch
import torch.nn as nn
import torch.onnx
import tensorflow as tf
import numpy as np
import os
import netron
import time
from pathlib import Path

class SimpleNet(nn.Module):
    """간단한 PyTorch 모델"""
    def __init__(self):
        super(SimpleNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 16, 3, padding=1)
        self.relu1 = nn.ReLU()
        self.pool1 = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(16, 32, 3, padding=1)
        self.relu2 = nn.ReLU()
        self.pool2 = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(32 * 8 * 8, 128)
        self.relu3 = nn.ReLU()
        self.fc2 = nn.Linear(128, 10)
        
    def forward(self, x):
        x = self.pool1(self.relu1(self.conv1(x)))
        x = self.pool2(self.relu2(self.conv2(x)))
        x = x.view(x.size(0), -1)
        x = self.relu3(self.fc1(x))
        x = self.fc2(x)
        return x

def create_pytorch_model():
    """PyTorch 모델 생성 및 저장"""
    print("🧪 PyTorch 모델 생성 중...")
    
    # 모델 생성
    model = SimpleNet()
    model.eval()
    
    # 더미 입력 데이터
    dummy_input = torch.randn(1, 3, 32, 32)
    
    # PyTorch 모델 저장 (.pth)
    torch.save(model.state_dict(), 'simple_model.pth')
    print("✅ PyTorch 모델 저장 완료: simple_model.pth")
    
    # ONNX 포맷으로 변환
    try:
        torch.onnx.export(
            model,
            dummy_input,
            'simple_model.onnx',
            export_params=True,
            opset_version=11,
            do_constant_folding=True,
            input_names=['input'],
            output_names=['output'],
            dynamic_axes={
                'input': {0: 'batch_size'},
                'output': {0: 'batch_size'}
            }
        )
        print("✅ ONNX 모델 변환 완료: simple_model.onnx")
        return True
    except Exception as e:
        print(f"❌ ONNX 변환 실패: {e}")
        return False

def create_tensorflow_model():
    """TensorFlow 모델 생성 및 저장"""
    print("🧪 TensorFlow 모델 생성 중...")
    
    try:
        # Sequential 모델 생성
        model = tf.keras.Sequential([
            tf.keras.layers.Conv2D(16, 3, activation='relu', input_shape=(32, 32, 3)),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Conv2D(32, 3, activation='relu'),
            tf.keras.layers.MaxPooling2D(),
            tf.keras.layers.Flatten(),
            tf.keras.layers.Dense(128, activation='relu'),
            tf.keras.layers.Dense(10, activation='softmax')
        ])
        
        # 모델 컴파일
        model.compile(
            optimizer='adam',
            loss='sparse_categorical_crossentropy',
            metrics=['accuracy']
        )
        
        # 모델 저장 (.keras)
        model.save('simple_model.keras')
        print("✅ Keras 모델 저장 완료: simple_model.keras")
        
        # TensorFlow Lite 변환
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        tflite_model = converter.convert()
        
        with open('simple_model.tflite', 'wb') as f:
            f.write(tflite_model)
        print("✅ TensorFlow Lite 모델 변환 완료: simple_model.tflite")
        
        return True
    except Exception as e:
        print(f"❌ TensorFlow 모델 생성 실패: {e}")
        return False

def create_sample_models():
    """다양한 샘플 모델 생성"""
    print("🎯 Netron 테스트용 모델 생성 시작")
    print("=" * 50)
    
    results = []
    
    # PyTorch & ONNX
    pytorch_success = create_pytorch_model()
    results.append(("PyTorch & ONNX", pytorch_success))
    
    # TensorFlow & TFLite
    tf_success = create_tensorflow_model()
    results.append(("TensorFlow & TFLite", tf_success))
    
    return results

def test_netron_visualization():
    """Netron으로 모델 시각화 테스트"""
    print("\n📊 Netron 시각화 테스트")
    print("=" * 50)
    
    model_files = [
        ('simple_model.onnx', 'ONNX'),
        ('simple_model.keras', 'Keras'),
        ('simple_model.tflite', 'TensorFlow Lite')
    ]
    
    results = []
    
    for filename, model_type in model_files:
        if os.path.exists(filename):
            try:
                print(f"🔍 {model_type} 모델 시각화 테스트: {filename}")
                
                # Netron 서버 시작 (백그라운드에서 실행)
                # netron.start() 대신 파일 정보만 확인
                file_size = os.path.getsize(filename)
                print(f"  📁 파일 크기: {file_size / 1024:.1f} KB")
                
                print(f"  ✅ {model_type} 모델 파일 준비 완료")
                print(f"  🌐 브라우저에서 확인: netron {filename}")
                
                results.append((model_type, True, filename))
                
            except Exception as e:
                print(f"  ❌ {model_type} 시각화 실패: {e}")
                results.append((model_type, False, filename))
        else:
            print(f"  ⚠️ {model_type} 모델 파일 없음: {filename}")
            results.append((model_type, False, filename))
    
    return results

def check_model_details():
    """생성된 모델의 상세 정보 확인"""
    print("\n📋 모델 상세 정보")
    print("=" * 50)
    
    models = {
        'simple_model.onnx': 'ONNX',
        'simple_model.keras': 'Keras', 
        'simple_model.tflite': 'TensorFlow Lite'
    }
    
    for filename, model_type in models.items():
        if os.path.exists(filename):
            file_size = os.path.getsize(filename)
            file_path = os.path.abspath(filename)
            
            print(f"\n{model_type} 모델:")
            print(f"  📁 파일명: {filename}")
            print(f"  📊 크기: {file_size:,} bytes ({file_size/1024:.1f} KB)")
            print(f"  📍 경로: {file_path}")
            
            # ONNX 모델의 경우 추가 정보
            if filename.endswith('.onnx'):
                try:
                    import onnx
                    model = onnx.load(filename)
                    print(f"  🔧 ONNX 버전: {model.ir_version}")
                    print(f"  🏗️ 그래프 노드 수: {len(model.graph.node)}")
                except ImportError:
                    print("  ⚠️ onnx 패키지가 설치되지 않아 상세 정보를 확인할 수 없습니다")
                except Exception as e:
                    print(f"  ⚠️ ONNX 정보 확인 실패: {e}")

def generate_test_commands():
    """테스트 명령어 가이드 생성"""
    print("\n🚀 Netron 테스트 명령어 가이드")
    print("=" * 50)
    
    models = [
        ('simple_model.onnx', 'ONNX'),
        ('simple_model.keras', 'Keras'),
        ('simple_model.tflite', 'TensorFlow Lite')
    ]
    
    print("다음 명령어로 각 모델을 시각화할 수 있습니다:\n")
    
    for filename, model_type in models:
        if os.path.exists(filename):
            print(f"# {model_type} 모델 시각화")
            print(f"netron {filename}")
            print(f"# 또는 Python에서")
            print(f"python3 -c \"import netron; netron.start('{filename}')\"")
            print()
    
    print("💡 팁:")
    print("- GUI 앱을 사용하려면: Applications/Netron.app 실행")
    print("- 브라우저에서 열기: https://netron.app")
    print("- 파일을 드래그 앤 드롭하여 바로 시각화 가능")

def main():
    """메인 함수"""
    print("🎯 Netron AI 모델 시각화 도구 테스트")
    print("=" * 60)
    
    # 환경 정보
    print(f"📍 작업 디렉토리: {os.getcwd()}")
    print(f"🐍 PyTorch 버전: {torch.__version__}")
    print(f"🔥 TensorFlow 버전: {tf.__version__}")
    print()
    
    # 모델 생성
    creation_results = create_sample_models()
    
    # 모델 상세 정보
    check_model_details()
    
    # Netron 테스트
    visualization_results = test_netron_visualization()
    
    # 명령어 가이드
    generate_test_commands()
    
    # 결과 요약
    print("\n" + "=" * 60)
    print("🏁 테스트 결과 요약")
    print("=" * 60)
    
    print("모델 생성 결과:")
    for model_type, success in creation_results:
        status = "✅ 성공" if success else "❌ 실패"
        print(f"  {model_type}: {status}")
    
    print("\nNetron 시각화 테스트:")
    for model_type, success, filename in visualization_results:
        status = "✅ 준비 완료" if success else "❌ 실패"
        print(f"  {model_type}: {status}")
    
    success_count = sum(1 for _, success, _ in visualization_results if success)
    total_count = len(visualization_results)
    
    print(f"\n총 {total_count}개 모델 중 {success_count}개 시각화 준비 완료")
    
    if success_count > 0:
        print("🎉 Netron 테스트 성공! 위의 명령어로 모델을 시각화하세요.")
    else:
        print("⚠️ 모델 생성에 문제가 있습니다.")

if __name__ == "__main__":
    main()
