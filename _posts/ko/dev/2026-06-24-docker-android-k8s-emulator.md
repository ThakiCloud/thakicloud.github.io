---
title: "Android 에뮬레이터를 컨테이너로 - docker-android로 K8s 위에 재현 가능한 디바이스 팜 만들기"
excerpt: "docker-android는 Android 에뮬레이터를 단일 컨테이너로 패키징해 헤드리스로 띄우는 오픈소스 프로젝트입니다. 이미지 크기와 KVM 요구사항을 실제 문서 기준으로 확인하고, ThakiCloud K8s 플랫폼에서 디바이스 패스스루 워크로드를 운용하는 관점을 정리합니다."
seo_title: "docker-android K8s 에뮬레이터 - 컨테이너 Android 디바이스 팜 구축 - Thaki Cloud"
seo_description: "docker-android로 Android 에뮬레이터를 헤드리스 컨테이너로 띄우는 방법. KVM 패스스루, GPU 가속, scrcpy 원격 제어, CI/CD 테스트 자동화를 ThakiCloud Kubernetes 기반으로 운용하는 실전 가이드."
date: 2026-06-24
last_modified_at: 2026-06-24
categories:
  - dev
tags:
  - docker
  - android
  - kubernetes
  - kvm
  - ci-cd
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ko/dev/docker-android-k8s-emulator/"
reading_time: true
---

![Android 에뮬레이터 컨테이너를 K8s에 배치한 구조](/assets/images/docker-android-k8s-emulator-diagram.png)

## 개요

모바일 앱을 테스트하려면 Android 디바이스가 필요합니다. 실제 단말을 여러 대 두는 방식은 관리가 번거롭고, 로컬에 무거운 에뮬레이터를 까는 방식은 환경이 사람마다 달라져 재현성이 떨어집니다. CI 파이프라인에 Android 테스트를 넣으려고 하면 이 문제는 더 커집니다. 빌드 노드마다 에뮬레이터를 일관되게 깔아야 하기 때문입니다.

`docker-android`(HQarroum 버전)는 이 문제를 컨테이너로 풉니다. Android 에뮬레이터를 최소 구성으로 패키징해 헤드리스로 띄우고, ADB와 화면 제어를 네트워크 너머로 노출합니다. 컨테이너 한 개로 깨끗하고 일관된 Android 환경을 초 단위로 만들 수 있으므로, CI/CD와 자동화 테스트에 잘 맞습니다.

이 글에서는 docker-android의 구조와 실제 요구사항을 문서 기준으로 확인하고, ThakiCloud의 Kubernetes 플랫폼 관점에서 이런 디바이스 클래스 워크로드를 어떻게 다룰 수 있는지를 정리합니다. AI/ML이 주제인 우리 플랫폼에서 모바일 에뮬레이터가 곧장 핵심은 아니지만, KVM 디바이스 패스스루와 GPU 가속이 필요한 컨테이너 워크로드를 어떻게 격리해 운용하는가라는 질문은 우리 인프라 역량과 직접 닿아 있습니다.

---

## docker-android는 무엇인가

HQarroum의 docker-android는 Alpine 기반의 작은 이미지에 Android 에뮬레이터와 KVM 지원, 그리고 JRE 11을 묶은 프로젝트입니다(현재 버전 1.1.0). 설계 초점은 분명합니다. 네트워크로 원격 제어 가능한 완전한 Android 에뮬레이터를, 최소한의 소프트웨어만으로 노출하는 것입니다. 이미지 안에는 에뮬레이터, 외부에서 접속하기 위한 ADB 서버, 그리고 libvirt를 갖춘 QEMU만 들어갑니다.

주요 특징은 다음과 같습니다.

- **최소 구성**: Alpine 기반으로 크기를 최적화했습니다. SDK와 에뮬레이터를 빼고 빌드하면 이미지가 훨씬 작아집니다.
- **커스터마이즈**: Android 버전, 디바이스 타입, 이미지 종류를 선택할 수 있습니다.
- **포트 포워딩 내장**: 에뮬레이터와 ADB를 컨테이너 네트워크 인터페이스로 노출합니다.
- **헤드리스**: GUI 없이 동작하므로 CI 팜에 적합합니다. [scrcpy](https://github.com/Genymobile/scrcpy)로 화면을 원격 제어할 수 있습니다.
- **재현성**: 에뮬레이터 이미지는 재시작할 때마다 초기화됩니다. 매번 같은 상태에서 시작한다는 뜻입니다.

위 다이어그램은 이 컨테이너를 ThakiCloud Kubernetes에 배치한 가정 구성입니다. KVM이 활성화된 노드의 파드에 에뮬레이터를 띄우고, `/dev/kvm`을 패스스루하며, GPU 가속이 필요하면 cuda 변형을 사용합니다. ADB는 Service로 노출해 CI 팜과 scrcpy가 접근합니다.

---

## 설치 및 통합

기본 빌드는 Android SDK, 플랫폼 도구, 에뮬레이터를 이미지에 함께 묶습니다. docker-compose로 띄우는 방법은 아래와 같습니다.

```bash
# 기본 에뮬레이터
docker compose up android-emulator

# GPU 가속
docker compose up android-emulator-cuda

# GPU 가속 + Google Play Store
docker compose up android-emulator-cuda-store
```

docker만 사용해 직접 빌드할 수도 있습니다.

```bash
docker build -t android-emulator .
```

이미지를 빌드한 뒤에는 KVM 드라이브를 마운트해 컨테이너를 실행합니다. Play Store 이미지를 쓰려면 에뮬레이터와 클라이언트가 같은 adbkey를 공유해야 하며, `adb keygen adbkey`로 키를 생성해 `./keys` 디렉터리에 넣습니다.

이미지 크기는 빌드 변형에 따라 크게 달라집니다. 저장소 문서에 명시된 비교표는 다음과 같습니다.

| 빌드 변형 | 압축 해제 | 압축 |
|---|---|---|
| API 33 + 에뮬레이터 | 5.84 GB | 1.97 GB |
| API 32 + 에뮬레이터 | 5.89 GB | 1.93 GB |
| API 28 + 에뮬레이터 | 4.29 GB | 1.46 GB |
| SDK·에뮬레이터 제외 | 414 MB | 138 MB |

에뮬레이터를 포함한 이미지는 압축 기준으로도 1.5GB 이상입니다. 다수의 노드에 분산 배포할 때는 레지스트리 대역폭과 노드 디스크를 함께 고려해야 합니다.

---

## 실제 동작 확인

이번 글에서는 컨테이너의 실제 부팅까지는 검증하지 못했습니다. 정직하게 기록합니다. 재현 시도 중 실패: 작업 호스트에 Docker 데몬이 없고, macOS는 `/dev/kvm`을 제공하지 않아 에뮬레이터 컨테이너가 부팅되지 않습니다. docker-android는 KVM 하드웨어 가속을 요구하므로, 실제 구동은 Linux 호스트 또는 중첩 가상화를 지원하는 KVM 노드에서만 가능합니다.

대신 검증 가능한 사실은 저장소 문서에서 직접 확인했습니다. 위 이미지 크기 비교표는 문서에 명시된 실제 수치이며, 빌드 변형과 compose 서비스 이름, KVM 마운트 요구사항도 문서 기준입니다. 측정하지 못한 부팅 시간이나 테스트 처리량 같은 수치는 만들어 넣지 않았습니다. 실제 도입 단계에서는 KVM 노드를 확보한 뒤 컨테이너 부팅 시간, ADB 연결 지연, 동시 실행 가능한 에뮬레이터 수를 직접 측정하는 절차가 필요합니다.

---

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

docker-android 자체는 AI/ML 도구가 아닙니다. 그러나 이 프로젝트가 드러내는 운영 요구사항은 ThakiCloud가 잘하는 영역과 정확히 겹칩니다.

첫째, **디바이스 패스스루 워크로드의 격리**입니다. 에뮬레이터는 `/dev/kvm`을 요구하는 특권 컨테이너에 가깝습니다. K8s에서 이런 디바이스 클래스 워크로드를 멀티테넌트 환경에서 안전하게 격리하려면, 노드 선택, 디바이스 플러그인, 보안 컨텍스트를 신중히 다뤄야 합니다. ThakiCloud는 이미 GPU를 device plugin과 Kueue로 큐잉하고 있으며, KVM 패스스루도 같은 패턴으로 다룰 수 있습니다.

둘째, **재현 가능한 테스트 팜**입니다. 헤드리스 에뮬레이터를 컨테이너로 묶으면, 깨끗한 환경을 노드 수만큼 수평 확장할 수 있습니다. CI/CD에서 Appium UI 테스트를 다수 병렬로 돌리는 구성은 K8s 잡 스케줄링의 전형적인 사용처입니다.

셋째, 더 멀리 보면 **온디바이스 AI 검증**으로 확장할 수 있습니다. 모바일에서 동작하는 경량 모델이나 에이전트의 동작을 자동화로 검증하려면, 격리된 Android 환경을 다수 띄워 회귀 테스트를 돌리는 디바이스 팜이 유용합니다. 현재 우리 플랫폼의 핵심은 아니지만, 멀티테넌트 GPU·디바이스 오케스트레이션 역량이 성숙해지면 이런 모바일 AI QA 팜도 같은 인프라 위에서 제공 가능한 형태로 확장할 수 있습니다.

요약하면, docker-android는 그 자체로 우리 제품은 아니지만 "특권·디바이스·GPU 가속이 얽힌 무거운 컨테이너 워크로드를 K8s에서 어떻게 길들이는가"라는 좋은 사례입니다. 이는 ThakiCloud가 강조하는 범용 K8s 오케스트레이션 역량을 보여 주는 구체적인 그림입니다.

---

## 한계 및 반론

- **무거운 의존성**: KVM 하드웨어 가속은 협상 대상이 아닙니다. 중첩 가상화를 지원하지 않는 환경에서는 성능이 급격히 떨어지거나 아예 부팅되지 않습니다. 클라우드 노드 선택이 곧 제약이 됩니다.
- **이미지 비대**: 에뮬레이터 포함 이미지는 압축해도 수 GB입니다. 노드 다수에 분산하면 레지스트리와 디스크 비용이 누적됩니다.
- **AI/ML 적합성의 거리**: 솔직히 이 도구는 우리 플랫폼의 핵심 워크로드인 학습·추론과는 거리가 있습니다. 모바일 테스트 수요가 없는 조직에는 직접적인 가치가 작습니다. 이 글의 가치는 "에뮬레이터 그 자체"가 아니라 "디바이스 패스스루 컨테이너의 운영 패턴"에 있습니다.
- **특권 컨테이너의 보안**: `/dev/kvm` 접근과 특권 설정은 멀티테넌트 보안 경계를 복잡하게 만듭니다. 테넌트 격리를 깨지 않으려면 전용 노드 풀과 엄격한 정책이 필요합니다.

결론적으로 docker-android는 모바일 테스트 자동화에 강력한 도구이며, 동시에 K8s에서 디바이스 클래스 워크로드를 다루는 방법을 보여 주는 교본입니다. 우리에게 직접 필요한 순간이 오기 전이라도, 그 운영 패턴은 미리 익혀 둘 가치가 있습니다.

---

## 출처

- docker-android (HQarroum): [https://github.com/HQarroum/docker-android](https://github.com/HQarroum/docker-android)
- Docker Hub 이미지: `halimqarroum/docker-android`
- scrcpy (원격 화면 제어): [https://github.com/Genymobile/scrcpy](https://github.com/Genymobile/scrcpy)
- 원 트윗(RT): [https://x.com/hjguyhan/status/2069427245295493446](https://x.com/hjguyhan/status/2069427245295493446)
