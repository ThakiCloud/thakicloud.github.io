---
title: "Cloud Run GPU 튜토리얼: 서버리스 AI 워크로드 실행하기"
date: 2025-06-04
categories:
  - Tutorials
  - Cloud
tags:
  - cloud-run
  - gpu
  - serverless
  - ai
  - google-cloud
author_profile: true
toc: true
toc_label: "목차"
---

# Cloud Run GPU 튜토리얼: 서버리스 AI 워크로드 실행하기

Google Cloud의 서버리스 런타임인 Cloud Run이 이제 NVIDIA GPU를 지원하게 되었습니다. 이 튜토리얼에서는 Cloud Run에서 GPU를 활용하여 AI 워크로드를 실행하는 방법을 단계별로 알아보겠습니다.

## 목차
- [소개](#소개)
- [사전 요구사항](#사전-요구사항)
- [Cloud Run GPU의 주요 특징](#cloud-run-gpu의-주요-특징)
- [실습: Ollama를 Cloud Run에 배포하기](#실습-ollama를-cloud-run에-배포하기)
- [비용 최적화 팁](#비용-최적화-팁)
- [결론](#결론)

## 소개

Cloud Run은 개발자들이 인프라 관리 없이 컨테이너를 실행할 수 있게 해주는 서버리스 플랫폼입니다. 이제 NVIDIA L4 GPU 지원이 추가되어 AI 워크로드를 더욱 효율적으로 실행할 수 있게 되었습니다.

## 사전 요구사항

- Google Cloud 계정
- Google Cloud CLI (gcloud) 설치
- Docker 설치
- 기본적인 컨테이너 및 Dockerfile 이해

## Cloud Run GPU의 주요 특징

1. **초당 과금**
   - 실제 사용한 GPU 리소스에 대해서만 초 단위로 과금
   - 사용하지 않을 때는 비용이 발생하지 않음

2. **제로 스케일링**
   - 요청이 없을 때 자동으로 인스턴스를 0으로 스케일링
   - 유휴 비용 제거

3. **빠른 시작과 스케일링**
   - GPU와 드라이버가 설치된 인스턴스로 5초 이내 시작
   - gemma3:4b 모델 기준 약 19초의 Time-to-First-Token

4. **스트리밍 지원**
   - HTTP 및 WebSocket 스트리밍 기본 지원
   - 실시간 LLM 응답 생성 가능

## 실습: Ollama를 Cloud Run에 배포하기

### 1. 프로젝트 설정

```bash
# 프로젝트 ID 설정
export PROJECT_ID=your-project-id
gcloud config set project $PROJECT_ID

# 필요한 API 활성화
gcloud services enable run.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### 2. Dockerfile 생성

```dockerfile
FROM ollama/ollama:latest

# 필요한 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# 포트 노출
EXPOSE 11434

# Ollama 서버 실행
CMD ["serve"]
```

### 3. 이미지 빌드 및 푸시

```bash
# Artifact Registry 저장소 생성
gcloud artifacts repositories create ollama-repo \
    --repository-format=docker \
    --location=us-central1

# 이미지 빌드 및 푸시
docker build -t us-central1-docker.pkg.dev/$PROJECT_ID/ollama-repo/ollama:latest .
docker push us-central1-docker.pkg.dev/$PROJECT_ID/ollama-repo/ollama:latest
```

### 4. Cloud Run 서비스 배포

```bash
gcloud run deploy ollama-service \
  --image us-central1-docker.pkg.dev/$PROJECT_ID/ollama-repo/ollama:latest \
  --port 11434 \
  --gpu 1 \
  --region us-central1 \
  --platform managed \
  --allow-unauthenticated
```

### 5. 모델 다운로드 및 테스트

```bash
# 서비스 URL 가져오기
SERVICE_URL=$(gcloud run services describe ollama-service \
  --platform managed \
  --region us-central1 \
  --format 'value(status.url)')

# 모델 다운로드
curl -X POST $SERVICE_URL/api/pull -d '{"name": "gemma:7b"}'

# 테스트 요청
curl -X POST $SERVICE_URL/api/generate -d '{
  "model": "gemma:7b",
  "prompt": "Hello, how are you?"
}'
```

## 비용 최적화 팁

1. **자동 스케일링 설정**
   - 최소 인스턴스를 0으로 설정하여 비용 절감
   - 필요할 때만 인스턴스 시작

2. **리전 선택**
   - 사용자와 가까운 리전 선택으로 지연 시간 최소화
   - 현재 지원 리전: us-central1, europe-west1, europe-west4, asia-southeast1, asia-south1

3. **리소스 제한**
   - 필요한 만큼의 GPU만 할당
   - 메모리와 CPU 리소스도 적절히 설정

## 결론

Cloud Run의 GPU 지원은 AI 워크로드를 실행하는 새로운 방식을 제시합니다. 서버리스의 장점과 GPU의 성능을 결합하여, 개발자들은 인프라 관리에 대한 부담 없이 AI 애플리케이션을 배포하고 운영할 수 있게 되었습니다.

이 튜토리얼에서 다룬 내용을 바탕으로, 여러분만의 AI 서비스를 Cloud Run에 배포해보세요. 추가적인 도움이 필요하시다면 [Google Cloud 문서](https://cloud.google.com/run/docs)를 참고하시기 바랍니다.

--- 