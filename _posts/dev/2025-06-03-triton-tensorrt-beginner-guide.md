---
title: "Triton Server & TensorRT 신입 개발자 개발 가이드"
date: 2025-06-03
categories:
  - dev
  - ai-inference
  - nvidia
  - triton
  - tensorrt
tags:
  - tritonserver
  - tensorrt
  - ai서빙
  - 모델최적화
  - 신입개발자
  - inference
  - nvidia
  - 딥러닝
  - onnx
  - docker
author_profile: true
toc: true
toc_label: Triton & TensorRT 신입 개발자 가이드
---

## Triton Server & TensorRT 신입 개발자 개발 가이드 🚀

AI 모델 추론 성능 최적화 및 효율적인 서비스 배포를 위한 **NVIDIA Triton Inference Server**와 **TensorRT** 사용법을 신입 개발자 눈높이에 맞춰 상세히 안내합니다. 이 가이드를 통해 복잡한 AI 모델을 실제 서비스 환경에 빠르고 안정적으로 배포하는 기본 역량을 갖출 수 있습니다.

---

### 1. 시작하며: Triton Server와 TensorRT란?

AI 모델 개발 후, 실제 서비스에 적용하려면 '추론(inference)' 과정을 거칩니다. 이 추론 과정의 **속도와 효율성**은 서비스 품질에 직접적인 영향을 미칩니다.

- **TensorRT (Tensor Real-Time)** ⚡: NVIDIA GPU에서 딥러닝 모델의 **추론 성능을 극대화**하기 위한 SDK입니다. 학습된 모델을 최적화하여 더 낮은 지연 시간(latency)과 더 높은 처리량(throughput)을 달성하도록 도와줍니다. 핵심은 **모델 최적화**입니다.
- **Triton Inference Server** 🚢: 최적화된 모델을 실제 서비스 환경에서 **쉽고 유연하게 배포하고 관리**할 수 있도록 해주는 서버 소프트웨어입니다. 다양한 프레임워크(TensorFlow, PyTorch, TensorRT, ONNX Runtime 등)로 만들어진 여러 모델을 동시에 서비스할 수 있으며, HTTP/gRPC 통신, 동적 배치(dynamic batching) 등 다양한 기능을 제공합니다. 핵심은 **모델 서빙**입니다.

쉽게 말해, **TensorRT**로 모델을 다이어트시켜 날렵하게 만들고, **Triton Server**라는 만능 트럭에 실어 손님들에게 빠르고 정확하게 배달하는 것이죠.

---

### 2. 개발 환경 준비 🛠️

본격적으로 시작하기 전에 다음 환경이 준비되어 있어야 합니다.

- **NVIDIA GPU**: TensorRT와 Triton Server는 NVIDIA GPU 환경에서 최적의 성능을 발휘합니다.
- **NVIDIA 드라이버**: GPU 모델에 맞는 최신 드라이버를 설치합니다.
- **CUDA Toolkit**: TensorRT 및 GPU 가속 라이브러리가 의존하는 CUDA 버전을 설치합니다. (TensorRT, Triton 버전과 호환되는지 확인 필수!)
- **cuDNN**: CUDA 기반 딥러닝 라이브러리입니다.
- **Docker (권장)**: NVIDIA는 Triton Server와 필요한 종속성을 포함한 Docker 이미지를 제공합니다. Docker를 사용하면 복잡한 설치 과정을 간소화하고 환경 일관성을 유지할 수 있습니다. (NGC 카탈로그에서 `nvcr.io/nvidia/tritonserver` 이미지 활용)
- **Python**: 모델 변환 및 클라이언트 개발에 필요합니다.
- **딥러닝 프레임워크**: TensorFlow, PyTorch 등 원본 모델을 학습시킨 프레임워크가 설치되어 있어야 합니다.

**⭐ Tip:** 각 소프트웨어 버전 간 호환성이 매우 중요합니다! NVIDIA 공식 문서를 통해 TensorRT, Triton Server, CUDA, cuDNN, 드라이버 버전 호환성을 반드시 확인하세요.

---

### 3. TensorRT: 모델 최적화 마스터하기 🧠

TensorRT는 학습된 모델을 NVIDIA GPU에 최적화된 경량 엔진(.plan 또는 .engine 파일)으로 변환합니다.

#### 3.1. TensorRT 최적화의 마법 ✨

- **Layer & Tensor Fusion**: 여러 레이어를 하나로 병합하거나 불필요한 연산을 제거하여 계산 효율을 높입니다.
- **Precision Calibration**: FP32 모델을 FP16이나 INT8과 같은 더 낮은 정밀도로 변환하여 속도를 높이고 메모리 사용량을 줄입니다. (정확도 손실 최소화가 관건!)
- **Kernel Auto-Tuning**: 타겟 GPU 아키텍처에 가장 적합한 CUDA 커널을 자동으로 선택합니다.
- **Dynamic Tensor Memory**: 실행 시 필요한 메모리만 동적으로 할당하여 효율성을 높입니다.

#### 3.2. TensorRT 변환 기본 워크플로우 🔄

1.  **모델 준비**: TensorFlow, PyTorch 등으로 학습된 모델을 준비합니다.
2.  **ONNX로 변환 (권장)**:
    - 다양한 프레임워크 간 모델 호환성을 위해 **ONNX (Open Neural Network Exchange)** 형식으로 먼저 변환하는 것이 일반적입니다. 각 프레임워크는 ONNX 변환 도구를 제공합니다.
    - 예시 (PyTorch): `torch.onnx.export()` 함수 사용
3.  **ONNX 모델을 TensorRT 엔진으로 변환**:
    - NVIDIA에서 제공하는 `trtexec` 커맨드라인 도구나 TensorRT Python/C++ API를 사용합니다.
    - **`trtexec` 사용 예시:**
      ```bash
      trtexec --onnx=/path/to/your_model.onnx \
              --saveEngine=/path/to/your_model.plan \
              --explicitBatch \ # 명시적 배치 크기 사용 (최신 모델에서 권장)
              --minShapes=input_name:1x3x224x224 \ # 동적 입력 크기 사용 시 최소 크기
              --optShapes=input_name:8x3x224x224 \ # 최적 크기
              --maxShapes=input_name:16x3x224x224 \ # 최대 크기
              --fp16 # FP16 정밀도 사용 옵션
      ```
    - **Python API 사용 시 주요 단계:**
      1.  Logger, Builder, Network Definition 생성
      2.  ONNX Parser를 사용하여 ONNX 모델 로드
      3.  Builder Configuration 설정 (정밀도, 동적 입력 크기 등)
      4.  최적화된 엔진 빌드 (`builder.build_engine()`)
      5.  엔진 직렬화 및 파일로 저장 (`engine.serialize()`)

#### 3.3. 주요 개념 🔑

- **Builder (`IBuilder`)**: TensorRT 엔진을 생성하는 객체입니다.
- **Network Definition (`INetworkDefinition`)**: 모델의 구조를 정의합니다. ONNX 파서를 사용하면 이 과정이 자동화됩니다.
- **Builder Config (`IBuilderConfig`)**: 엔진 빌드 시 최적화 옵션(정밀도, 작업 공간 크기, 동적 shape 등)을 설정합니다.
- **Engine (`ICudaEngine`)**: 최적화된 모델입니다. 추론을 위해 직렬화/역직렬화 가능합니다.
- **Execution Context (`IExecutionContext`)**: 실제 추론을 실행하는 객체입니다. 엔진으로부터 생성됩니다.

**⭐ Tip:** 동적 입력 크기(Dynamic Shapes)를 지원하면 다양한 배치 크기나 입력 이미지 크기에 대응할 수 있어 유연성이 높아집니다. `--minShapes`, `--optShapes`, `--maxShapes` 옵션을 잘 활용하세요.

---

### 4. Triton Inference Server: 모델 서비스 전문가 🧑‍🍳

Triton Server는 최적화된 TensorRT 엔진을 포함한 다양한 모델들을 효율적으로 서비스할 수 있게 해줍니다.

#### 4.1. Triton Server의 강력한 기능 💪

- **다중 모델 서빙**: 하나의 서버에서 여러 모델 동시 서비스 가능.
- **다중 프레임워크 지원**: TensorRT, TensorFlow (SavedModel, GraphDef), PyTorch (TorchScript), ONNX Runtime 등 지원.
- **동시 실행 (Concurrent Execution)**: GPU 활용률을 높이기 위해 여러 추론 요청을 동시에 처리.
- **동적 배치 (Dynamic Batching)**: 실시간으로 들어오는 개별 요청들을 서버가 자동으로 묶어 배치 처리하여 GPU 효율 향상.
- **HTTP/gRPC 엔드포인트**: 표준 프로토콜을 통해 쉽게 서비스 접근 가능.
- **모델 관리 API**: 모델 로드/언로드, 버전 관리 등.
- **모니터링**: Prometheus와 연동하여 성능 지표(GPU 사용률, 지연 시간, 처리량 등) 모니터링 가능.

#### 4.2. Triton Server 기본 사용법 🚀

1.  **모델 저장소 (Model Repository) 준비**:
    - Triton이 모델을 인식하고 로드할 수 있도록 특정 디렉토리 구조로 모델을 배치해야 합니다.
    - 기본 구조:
      ```
      <model_repository_path>/
        <model_name>/
          config.pbtxt  # 모델 설정 파일 (필수)
          1/            # 버전 디렉토리 (숫자로 된 디렉토리)
            model.plan    # TensorRT 엔진 파일 (또는 model.onnx, model.pt 등)
          2/
            model.plan
          ...
      ```
    - `config.pbtxt` 예시 (TensorRT 모델):
      ```protobuf
      name: "my_tensorrt_model"
      platform: "tensorrt_plan" # 또는 "onnxruntime_onnx", "pytorch_libtorch" 등
      max_batch_size: 16        # 최대 배치 크기 (0으로 설정 시 동적 배치 비활성화)
      input [
        {
          name: "input__0"     # 모델 입력 텐서 이름 (ONNX 모델 기준)
          data_type: TYPE_FP32
          dims: [ 3, 224, 224 ] # -1을 사용하여 동적 차원 표시 가능 (예: [ -1, 3, -1, -1 ])
        }
      ]
      output [
        {
          name: "output__0"    # 모델 출력 텐서 이름
          data_type: TYPE_FP32
          dims: [ 1000 ]
        }
      ]
      # 동적 배치 설정 (선택 사항)
      dynamic_batching {
        preferred_batch_size: [4, 8]
        max_queue_delay_microseconds: 100
      }
      # 인스턴스 그룹 설정 (GPU 할당 등)
      instance_group [
        {
          count: 1
          kind: KIND_GPU
          gpus: [0] # 첫 번째 GPU 사용
        }
      ]
      ```

2.  **Triton Server 실행**:
    - Docker 사용 시 (권장):
      ```bash
      docker run --gpus all --rm -p 8000:8000 -p 8001:8001 -p 8002:8002 \
             -v /path/to/your/model_repository:/models \
             nvcr.io/nvidia/tritonserver:<yy.mm>-py3 tritonserver \
             --model-repository=/models \
             --model-control-mode=poll \ # 주기적으로 모델 저장소 변경 감지
             --repository-poll-secs=10   # 10초마다 감지
      ```
      - `<yy.mm>`: Triton 버전 (예: `23.10`)
      - `/path/to/your/model_repository`: 실제 모델 저장소 경로
      - 포트: `8000` (HTTP), `8001` (gRPC), `8002` (Metrics)

3.  **클라이언트로 추론 요청 보내기**:
    - Triton은 Python, C++, Java 등 다양한 언어의 클라이언트 라이브러리를 제공합니다.
    - **Python 클라이언트 예시 (HTTP):**
      ```python
      import numpy as np
      import tritonclient.http as httpclient

      # Triton 서버 주소
      TRITON_SERVER_URL = "localhost:8000"
      MODEL_NAME = "my_tensorrt_model"
      MODEL_VERSION = "1" # 생략 시 최신 버전 사용

      # 입력 데이터 준비 (모델 입력 스펙에 맞게)
      input_data = np.random.rand(1, 3, 224, 224).astype(np.float32) # 예시: 배치 1, 3채널, 224x224 이미지

      try:
          # Triton 클라이언트 생성
          triton_client = httpclient.InferenceServerClient(url=TRITON_SERVER_URL)

          # 입력 텐서 설정
          inputs = []
          inputs.append(httpclient.InferInput('input__0', input_data.shape, "FP32")) # config.pbtxt의 입력 이름과 일치
          inputs[0].set_data_from_numpy(input_data)

          # 출력 텐서 설정
          outputs = []
          outputs.append(httpclient.InferRequestedOutput('output__0')) # config.pbtxt의 출력 이름과 일치

          # 추론 요청
          results = triton_client.infer(
              model_name=MODEL_NAME,
              model_version=MODEL_VERSION,
              inputs=inputs,
              outputs=outputs
          )

          # 결과 처리
          output_data = results.as_numpy('output__0')
          print("Inference Result:", output_data)

      except Exception as e:
          print(f"Error: {e}")
      ```

#### 4.3. `config.pbtxt` 핵심 설정 ⚙️

- `name`: 모델 이름 (모델 저장소 디렉토리 이름과 일치).
- `platform`: 모델 타입 (`tensorrt_plan`, `onnxruntime_onnx`, `tensorflow_savedmodel`, `pytorch_libtorch` 등).
- `max_batch_size`: 모델이 한 번에 처리할 수 있는 최대 배치 크기. `0`으로 설정하면 동적 배치를 사용하지 않고, 각 요청을 개별 처리합니다. TensorRT 엔진 빌드 시 `explicitBatch`를 사용했다면 보통 `0`으로 설정하고, `dynamic_batching` 설정을 통해 배치 크기를 관리합니다.
- `input`, `output`: 모델의 입력 및 출력 텐서 정보 (이름, 데이터 타입, shape).
    - 텐서 이름은 원본 모델 또는 ONNX 모델의 텐서 이름과 일치해야 합니다. `Netron` 같은 도구로 ONNX 모델을 열어 확인 가능합니다.
    - `dims`: `[-1]`을 사용하여 동적 차원을 나타낼 수 있습니다. 예를 들어, 가변 배치 크기를 지원하려면 `dims: [-1, 3, 224, 224]` 와 같이 첫 번째 차원을 `-1`로 설정합니다.
- `dynamic_batching`: 서버가 요청을 모아 배치 처리하는 기능. `preferred_batch_size` (선호 배치 크기), `max_queue_delay_microseconds` (배치 구성을 위한 최대 대기 시간) 등을 설정합니다. TensorRT 엔진이 고정 배치 크기로 빌드되었다면 이 기능을 활용하기 어렵습니다. **동적 shape를 지원하는 TensorRT 엔진과 함께 사용할 때 가장 효과적**입니다.
- `instance_group`: 모델 인스턴스를 몇 개, 어떤 장치(CPU/GPU)에 띄울지 설정합니다. GPU 여러 개에 동일 모델 인스턴스를 띄워 병렬 처리 능력을 높일 수 있습니다.

---

### 5. TensorRT vs Triton Server: 심도 있는 비교 분석 ⚖️

#### 5.1. 역할과 적용 범위

- **TensorRT**는 모델 최적화에 특화된 라이브러리로, 모델을 GPU에 맞게 경량화하고 추론 속도를 극대화하는 데 집중합니다. 직접 엔진을 생성하고, C++/Python 등에서 로드하여 추론을 수행할 수 있습니다.
- **Triton Server**는 다양한 최적화 모델(ONNX, TensorRT, PyTorch 등)을 통합적으로 관리하고, HTTP/gRPC API로 서비스하는 데 초점을 둡니다. 실제 서비스 환경에서 운영, 모니터링, 배포 자동화 등 인프라 관점의 기능이 풍부합니다.

#### 5.2. 사용 시나리오

- **TensorRT 단독 사용**
  - 연구/개발 환경에서 빠른 추론 성능이 필요할 때.
  - 단일 모델, 단일 프로세스에서 직접 엔진을 로드해 추론할 때.
  - 배치 처리, 동적 배치, 멀티 모델 관리 등 인프라 기능이 불필요할 때.
- **Triton Server 사용**
  - 여러 모델을 동시에 서비스해야 할 때.
  - 다양한 프레임워크 모델을 통합적으로 관리하고 싶을 때.
  - HTTP/gRPC API로 외부 서비스와 연동해야 할 때.
  - 동적 배치, 모니터링, 버전 관리 등 운영 편의성이 중요할 때.

#### 5.3. 성능 및 확장성

- **TensorRT**는 최적화된 엔진을 직접 로드해 추론하므로, 오버헤드가 거의 없고 최대 성능을 낼 수 있습니다. 하지만 멀티 모델, 멀티 인스턴스, 동적 배치 등은 직접 구현해야 합니다.
- **Triton Server**는 약간의 오버헤드가 있지만, 동적 배치, 멀티 모델, 멀티 프레임워크, 모니터링 등 대규모 서비스에 필수적인 기능을 제공합니다. GPU 활용률을 극대화할 수 있습니다.

#### 5.4. 개발 및 운영 난이도

- **TensorRT**는 엔진 생성, 로드, 추론까지의 파이프라인을 직접 구현해야 하므로 코드 복잡도가 높아질 수 있습니다. 반면, 단일 모델/단일 환경에서는 단순하고 빠릅니다.
- **Triton Server**는 모델 저장소 구조, config 파일 작성, 서버 운영 등 추가 학습이 필요하지만, 일단 익히면 대규모 서비스에 매우 효율적입니다.

#### 5.5. 결론 및 추천

- **소규모/연구 환경**: TensorRT 단독 사용이 간편하고 빠릅니다.
- **실제 서비스/운영 환경**: Triton Server를 통한 모델 서빙이 확장성, 관리 편의성, 운영 자동화 측면에서 훨씬 유리합니다. TensorRT로 최적화한 엔진을 Triton에 올려 사용하는 것이 가장 이상적입니다.

---

### 6. 개발 팁 및 모범 사례 💡

- **버전 호환성 확인**: NVIDIA 드라이버, CUDA, cuDNN, TensorRT, Triton Server 간의 버전 호환성은 매우 중요합니다. 항상 공식 문서를 통해 권장 버전을 확인하세요.
- **작은 모델부터 시작**: 처음에는 간단한 모델로 TensorRT 변환 및 Triton 서빙 과정을 익히는 것이 좋습니다.
- **`trtexec` 적극 활용**: TensorRT 엔진 빌드 시 `trtexec`는 매우 유용한 도구입니다. 다양한 옵션(정밀도, 동적 shape, 프로파일링 등)을 테스트하며 최적의 설정을 찾을 수 있습니다.
- **프로파일링**: TensorRT는 레이어별 실행 시간을 프로파일링하는 기능을 제공합니다. (`trtexec --profilingVerbosity=detailed`) 이를 통해 병목 구간을 찾아 최적화할 수 있습니다. Triton에서도 모델 분석기(`perf_analyzer`)를 제공하여 서버의 처리량과 지연 시간을 측정할 수 있습니다.
- **정밀도 선택**: FP16 또는 INT8 양자화를 사용하면 성능을 크게 향상시킬 수 있지만, 약간의 정확도 손실이 발생할 수 있습니다. 서비스 요구사항에 맞는 정밀도를 선택하고 충분한 테스트를 거치세요. INT8 양자화는 보정(calibration) 과정이 필요합니다.
- **동적 Shape 활용**: 입력 데이터의 크기가 다양하거나, 배치 크기를 유동적으로 조절하고 싶다면 TensorRT 엔진 빌드 시 동적 shape를 반드시 고려하세요. Triton의 `dynamic_batching`과 함께 사용하면 시너지가 좋습니다.
- **모델 저장소 구조 숙지**: Triton의 모델 저장소 규칙을 정확히 따라야 모델이 정상적으로 로드됩니다.
- **Triton 로그 확인**: Triton 서버 실행 시 로그를 통해 모델 로딩 상태, 오류 등을 확인할 수 있습니다. (`--log-verbose=1` 옵션 등으로 로그 레벨 조절)
- **클라이언트 라이브러리 활용**: Triton이 제공하는 클라이언트 라이브러리를 사용하면 HTTP/gRPC 요청을 쉽게 구현할 수 있습니다.
- **보안 고려**: 실제 서비스 환경에서는 Triton 서버의 HTTP/gRPC 엔드포인트에 대한 접근 제어, 인증, 암호화 등을 고려해야 합니다.

---

### 7. 더 깊이 있는 학습을 위한 자료 📚

- **NVIDIA TensorRT 공식 문서**: [https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/index.html](https://docs.nvidia.com/deeplearning/tensorrt/developer-guide/index.html)
- **NVIDIA Triton Inference Server 공식 문서**: [https://github.com/triton-inference-server/server/tree/main/docs](https://github.com/triton-inference-server/server/tree/main/docs)
- **NVIDIA NGC (NVIDIA GPU Cloud) 카탈로그**: Triton Server Docker 이미지, 사전 학습된 모델 등 제공. [https://ngc.nvidia.com](https://ngc.nvidia.com)
- **TensorRT GitHub 예제**: [https://github.com/NVIDIA/TensorRT/tree/main/samples](https://github.com/NVIDIA/TensorRT/tree/main/samples)
- **Triton 튜토리얼**: [https://github.com/triton-inference-server/tutorials](https://github.com/triton-inference-server/tutorials) 