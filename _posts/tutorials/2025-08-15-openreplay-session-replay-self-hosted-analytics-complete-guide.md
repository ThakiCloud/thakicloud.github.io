---
title: "OpenReplay: 자체 호스팅 세션 리플레이 & 사용자 분석 플랫폼 완전 가이드"
excerpt: "오픈소스 세션 리플레이 도구 OpenReplay로 사용자 행동 분석하기. 설치부터 실전 활용까지 단계별 튜토리얼"
seo_title: "OpenReplay 자체 호스팅 세션 리플레이 플랫폼 튜토리얼 - Thaki Cloud"
seo_description: "OpenReplay를 활용한 웹 애플리케이션 사용자 행동 분석 가이드. Docker 배포, 세션 리플레이, 실시간 지원까지 포함한 완전 튜토리얼"
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - tutorials
  - devops
tags:
  - openreplay
  - session-replay
  - analytics
  - self-hosted
  - user-monitoring
  - devtools
  - javascript
  - docker
  - kubernetes
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/openreplay-session-replay-self-hosted-analytics-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 18분

## 서론

웹 애플리케이션에서 사용자가 어떻게 행동하는지, 어디서 문제를 겪는지 실시간으로 파악하고 싶다면 [OpenReplay](https://github.com/openreplay/openreplay)가 완벽한 선택입니다.

OpenReplay는 **자체 호스팅이 가능한 오픈소스 세션 리플레이 플랫폼**으로, 사용자의 웹 사이트 이용 과정을 영상으로 재생하며 네트워크 활동, 콘솔 로그, JavaScript 오류까지 모든 기술적 세부사항을 캡처합니다.

### 이 튜토리얼에서 배울 내용

- OpenReplay의 핵심 기능과 아키텍처
- Docker와 Kubernetes를 통한 자체 호스팅 배포
- JavaScript 트래커 설치 및 설정
- 세션 리플레이와 실시간 사용자 지원 활용
- 고급 분석 및 알림 설정
- 프라이버시 제어 및 보안 설정

### 개발환경

- **OS**: macOS/Linux/Windows
- **Docker**: 20.0+
- **Kubernetes**: 1.20+ (선택사항)
- **Node.js**: 16.0+
- **브라우저**: Chrome, Firefox, Safari, Edge

## OpenReplay 소개

### 핵심 특징

OpenReplay는 다음과 같은 강력한 기능들을 제공합니다:

1. **완전한 세션 리플레이**: 사용자 행동의 모든 것을 영상으로 재생
2. **낮은 성능 영향**: 26KB 압축 트래커로 최소한의 성능 오버헤드
3. **자체 호스팅**: 모든 데이터가 자신의 인프라에 저장
4. **프라이버시 제어**: 세밀한 데이터 보안 및 마스킹 기능
5. **실시간 지원**: 라이브 세션 모니터링 및 사용자 지원

### 주요 기능 상세

#### 1. 세션 리플레이
사용자의 웹 사이트 이용 과정을 영상으로 기록하고 재생합니다:

- 마우스 움직임, 클릭, 스크롤
- 키보드 입력 (보안 설정 가능)
- 페이지 로딩 및 전환
- 모바일 터치 제스처

#### 2. 개발자 도구
브라우저 개발자 도구와 유사한 디버깅 환경을 제공합니다:

- 네트워크 요청/응답 모니터링
- JavaScript 오류 및 콘솔 로그
- 성능 메트릭 (Core Web Vitals)
- 메모리 및 CPU 사용량

#### 3. Spot 브라우저 확장
Chrome 확장 프로그램으로 직접 버그를 기록할 수 있습니다:

- 원클릭 세션 리코딩
- 자동 기술 정보 수집
- 개발팀과의 직접 공유

#### 4. Assist 실시간 지원
사용자와 실시간으로 상호작용할 수 있습니다:

- 라이브 스크린 공유
- WebRTC 기반 음성/영상 통화
- 원격 제어 및 안내

### 아키텍처 구성요소

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │   Backend API   │    │   PostgreSQL    │
│   (React)       │────│   (Python)      │────│   Database      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Tracker       │    │   Storage       │    │   Redis Cache   │
│   (JavaScript)  │────│   (MinIO/S3)    │────│   & Queue       │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 빠른 시작하기

### 방법 1: Docker Compose 배포 (권장)

가장 빠른 배포 방법은 Docker Compose를 사용하는 것입니다:

#### 1단계: 저장소 클론

```bash
# OpenReplay 저장소 클론
git clone https://github.com/openreplay/openreplay.git
cd openreplay
```

#### 2단계: 환경 설정

```bash
# Docker Compose 디렉토리로 이동
cd scripts/docker-compose

# 환경 변수 파일 복사
cp .env.example .env
```

환경 변수 설정:

```bash
# .env 파일 편집
vim .env

# 필수 설정
DOMAIN_NAME=your-domain.com
POSTGRES_PASSWORD=your_secure_password
JWT_SECRET=your_jwt_secret_key_here
OPENREPLAY_LICENSE_KEY=your_license_key

# MinIO 설정
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=your_minio_password

# Redis 설정
REDIS_PASSWORD=your_redis_password
```

#### 3단계: 서비스 시작

```bash
# 모든 서비스 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f
```

설치가 완료되면 `http://localhost:9000`에서 OpenReplay 대시보드에 접속할 수 있습니다.

### 방법 2: Kubernetes 배포

프로덕션 환경에서는 Kubernetes 배포를 권장합니다:

#### 1단계: Helm 설치

```bash
# Helm 설치 (macOS)
brew install helm

# Helm 저장소 추가
helm repo add openreplay https://charts.openreplay.com
helm repo update
```

#### 2단계: 네임스페이스 생성

```bash
# OpenReplay 전용 네임스페이스 생성
kubectl create namespace openreplay
```

#### 3단계: 설정 값 준비

```yaml
# values.yaml 생성
global:
  domainName: "your-domain.com"
  postgresqlPassword: "your_secure_password"
  jwtSecret: "your_jwt_secret"
  
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
  tls:
    enabled: true

postgresql:
  auth:
    postgresPassword: "your_secure_password"
  primary:
    persistence:
      size: "100Gi"

minio:
  auth:
    rootPassword: "your_minio_password"
  persistence:
    size: "200Gi"

redis:
  auth:
    password: "your_redis_password"
```

#### 4단계: Helm 배포

```bash
# OpenReplay 설치
helm install openreplay openreplay/openreplay \
  --namespace openreplay \
  --values values.yaml \
  --wait

# 설치 상태 확인
kubectl get pods -n openreplay
kubectl get services -n openreplay
```

## JavaScript 트래커 설정

### 기본 설치

웹 애플리케이션에 OpenReplay 트래커를 설치합니다:

#### 1단계: NPM 패키지 설치

```bash
# npm 설치
npm install @openreplay/tracker

# 또는 yarn 설치
yarn add @openreplay/tracker
```

#### 2단계: 기본 트래커 설정

```javascript
// src/openreplay.js
import Tracker from '@openreplay/tracker';

const tracker = new Tracker({
  projectKey: "YOUR_PROJECT_KEY", // OpenReplay 대시보드에서 확인
  ingestPoint: "https://your-domain.com/ingest", // 자체 호스팅 URL
  __DISABLE_SECURE_MODE: false, // HTTPS 환경에서는 false
});

// 트래커 시작
tracker.start();

// 사용자 식별
tracker.setUserID("user-123");
tracker.setMetadata("name", "John Doe");
tracker.setMetadata("email", "john@example.com");

export default tracker;
```

#### 3단계: React 애플리케이션 통합

```javascript
// src/App.js
import React, { useEffect } from 'react';
import tracker from './openreplay';

function App() {
  useEffect(() => {
    // 트래커 초기화
    tracker.start();
    
    // 페이지 뷰 추적
    tracker.setMetadata('page', window.location.pathname);
    
    return () => {
      // 컴포넌트 언마운트 시 정리
      tracker.stop();
    };
  }, []);

  const handleButtonClick = () => {
    // 커스텀 이벤트 추적
    tracker.event('button_clicked', {
      component: 'header',
      action: 'navigation'
    });
  };

  return (
    <div className="App">
      <header>
        <button onClick={handleButtonClick}>
          메뉴 열기
        </button>
      </header>
      {/* 나머지 애플리케이션 */}
    </div>
  );
}

export default App;
```

### Vue.js 통합

```javascript
// src/plugins/openreplay.js
import Tracker from '@openreplay/tracker';
import { App } from 'vue';

const tracker = new Tracker({
  projectKey: "YOUR_PROJECT_KEY",
  ingestPoint: "https://your-domain.com/ingest",
});

export default {
  install(app: App) {
    tracker.start();
    
    app.config.globalProperties.$tracker = tracker;
    app.provide('tracker', tracker);
  }
};
```

```vue
<!-- components/UserProfile.vue -->
<template>
  <div class="user-profile">
    <button @click="updateProfile">프로필 업데이트</button>
  </div>
</template>

<script>
export default {
  inject: ['tracker'],
  methods: {
    updateProfile() {
      // 이벤트 추적
      this.tracker.event('profile_updated', {
        section: 'user_settings',
        timestamp: Date.now()
      });
      
      // 실제 프로필 업데이트 로직
      this.performUpdate();
    }
  }
}
</script>
```

### Angular 통합

```typescript
// src/app/services/openreplay.service.ts
import { Injectable } from '@angular/core';
import Tracker from '@openreplay/tracker';

@Injectable({
  providedIn: 'root'
})
export class OpenReplayService {
  private tracker: Tracker;

  constructor() {
    this.tracker = new Tracker({
      projectKey: "YOUR_PROJECT_KEY",
      ingestPoint: "https://your-domain.com/ingest",
    });
  }

  start(): void {
    this.tracker.start();
  }

  setUser(userId: string, metadata: Record<string, any>): void {
    this.tracker.setUserID(userId);
    Object.entries(metadata).forEach(([key, value]) => {
      this.tracker.setMetadata(key, value);
    });
  }

  trackEvent(name: string, payload?: Record<string, any>): void {
    this.tracker.event(name, payload);
  }

  stop(): void {
    this.tracker.stop();
  }
}
```

```typescript
// src/app/app.component.ts
import { Component, OnInit, OnDestroy } from '@angular/core';
import { OpenReplayService } from './services/openreplay.service';

@Component({
  selector: 'app-root',
  templateUrl: './app.component.html'
})
export class AppComponent implements OnInit, OnDestroy {
  
  constructor(private openReplay: OpenReplayService) {}

  ngOnInit(): void {
    this.openReplay.start();
    
    // 사용자 정보 설정
    this.openReplay.setUser('user-456', {
      role: 'admin',
      subscription: 'premium'
    });
  }

  ngOnDestroy(): void {
    this.openReplay.stop();
  }

  onFormSubmit(): void {
    this.openReplay.trackEvent('form_submitted', {
      form_type: 'contact',
      validation_passed: true
    });
  }
}
```

## 고급 플러그인 설정

### Redux 상태 추적

```javascript
// src/store/openreplay-middleware.js
import tracker from '../openreplay';

const openReplayMiddleware = (store) => (next) => (action) => {
  // Redux 액션 추적
  tracker.event('redux_action', {
    type: action.type,
    payload: action.payload,
    timestamp: Date.now()
  });
  
  const result = next(action);
  
  // 상태 변경 후 스냅샷
  const newState = store.getState();
  tracker.setMetadata('redux_state', JSON.stringify(newState));
  
  return result;
};

// store 설정
import { createStore, applyMiddleware } from 'redux';
import rootReducer from './reducers';

const store = createStore(
  rootReducer,
  applyMiddleware(openReplayMiddleware)
);

export default store;
```

### Apollo GraphQL 통합

```javascript
// src/apollo/openreplay-link.js
import { ApolloLink } from '@apollo/client';
import tracker from '../openreplay';

const openReplayLink = new ApolloLink((operation, forward) => {
  const startTime = Date.now();
  
  // GraphQL 쿼리 시작 추적
  tracker.event('graphql_query_start', {
    operationName: operation.operationName,
    query: operation.query.loc?.source.body,
    variables: operation.variables
  });
  
  return forward(operation).map(response => {
    const endTime = Date.now();
    
    // 쿼리 완료 추적
    tracker.event('graphql_query_complete', {
      operationName: operation.operationName,
      duration: endTime - startTime,
      hasErrors: !!response.errors,
      errorCount: response.errors?.length || 0
    });
    
    if (response.errors) {
      response.errors.forEach(error => {
        tracker.event('graphql_error', {
          operationName: operation.operationName,
          message: error.message,
          path: error.path
        });
      });
    }
    
    return response;
  });
});

// Apollo Client 설정
import { ApolloClient, InMemoryCache, from } from '@apollo/client';

const client = new ApolloClient({
  link: from([openReplayLink, httpLink]),
  cache: new InMemoryCache()
});
```

### Axios 요청 추적

```javascript
// src/api/axios-config.js
import axios from 'axios';
import tracker from '../openreplay';

// 요청 인터셉터
axios.interceptors.request.use(
  (config) => {
    const startTime = Date.now();
    config.metadata = { startTime };
    
    tracker.event('api_request_start', {
      url: config.url,
      method: config.method?.toUpperCase(),
      headers: config.headers,
      data: config.data
    });
    
    return config;
  },
  (error) => {
    tracker.event('api_request_error', {
      message: error.message,
      config: error.config
    });
    return Promise.reject(error);
  }
);

// 응답 인터셉터
axios.interceptors.response.use(
  (response) => {
    const endTime = Date.now();
    const duration = endTime - response.config.metadata.startTime;
    
    tracker.event('api_request_success', {
      url: response.config.url,
      method: response.config.method?.toUpperCase(),
      status: response.status,
      duration,
      responseSize: JSON.stringify(response.data).length
    });
    
    return response;
  },
  (error) => {
    const endTime = Date.now();
    const duration = error.config?.metadata ? 
      endTime - error.config.metadata.startTime : 0;
    
    tracker.event('api_request_failed', {
      url: error.config?.url,
      method: error.config?.method?.toUpperCase(),
      status: error.response?.status,
      duration,
      errorMessage: error.message
    });
    
    return Promise.reject(error);
  }
);

export default axios;
```

## 프라이버시 제어 설정

### 민감한 데이터 마스킹

```javascript
// 고급 프라이버시 설정
const tracker = new Tracker({
  projectKey: "YOUR_PROJECT_KEY",
  ingestPoint: "https://your-domain.com/ingest",
  
  // 입력 필드 마스킹
  obscureInputs: true,
  obscureInputNumbers: true,
  obscureInputEmails: true,
  
  // 클래스/ID 기반 마스킹
  obscureTextNumbers: true,
  obscureTextEmails: true,
  
  // 특정 요소 완전 숨김
  privacySuppressionLevel: 2, // 0: 없음, 1: 부분, 2: 완전
  
  // 커스텀 마스킹 규칙
  sanitize: (data) => {
    // 신용카드 번호 마스킹
    if (data.match(/\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}/)) {
      return '****-****-****-****';
    }
    
    // 주민등록번호 마스킹  
    if (data.match(/\d{6}-\d{7}/)) {
      return '******-*******';
    }
    
    return data;
  }
});

// HTML 속성으로 마스킹 지정
```

```html
<!-- 완전 숨김 -->
<div data-openreplay-hidden>
  민감한 정보가 포함된 섹션
</div>

<!-- 텍스트만 마스킹 -->
<div data-openreplay-masked>
  사용자 이름: John Doe
</div>

<!-- 입력 필드 마스킹 -->
<input type="password" data-openreplay-obscured />
<input type="text" class="or-mask" placeholder="신용카드 번호" />
```

### GDPR 준수 설정

```javascript
// GDPR 준수를 위한 동의 관리
class PrivacyManager {
  constructor(tracker) {
    this.tracker = tracker;
    this.consentGiven = this.getStoredConsent();
  }

  getStoredConsent() {
    return localStorage.getItem('openreplay-consent') === 'true';
  }

  requestConsent() {
    return new Promise((resolve) => {
      // 동의 팝업 표시
      const consentModal = this.createConsentModal();
      document.body.appendChild(consentModal);
      
      consentModal.addEventListener('consent-given', () => {
        this.giveConsent();
        resolve(true);
      });
      
      consentModal.addEventListener('consent-denied', () => {
        this.denyConsent();
        resolve(false);
      });
    });
  }

  giveConsent() {
    this.consentGiven = true;
    localStorage.setItem('openreplay-consent', 'true');
    
    // 트래커 시작
    this.tracker.start();
    
    // 동의 이벤트 기록
    this.tracker.event('privacy_consent_given', {
      timestamp: Date.now(),
      version: '1.0'
    });
  }

  denyConsent() {
    this.consentGiven = false;
    localStorage.setItem('openreplay-consent', 'false');
    
    // 트래커 중지
    this.tracker.stop();
  }

  revokeConsent() {
    this.denyConsent();
    
    // 서버에 데이터 삭제 요청
    fetch('/api/privacy/delete-user-data', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ 
        userId: this.tracker.getUserID(),
        requestType: 'data_deletion'
      })
    });
  }

  createConsentModal() {
    const modal = document.createElement('div');
    modal.innerHTML = `
      <div class="privacy-consent-modal">
        <h3>데이터 수집 동의</h3>
        <p>사용자 경험 개선을 위해 세션 데이터를 수집합니다.</p>
        <button id="consent-accept">동의</button>
        <button id="consent-deny">거부</button>
      </div>
    `;
    
    modal.querySelector('#consent-accept').onclick = () => {
      modal.dispatchEvent(new CustomEvent('consent-given'));
      modal.remove();
    };
    
    modal.querySelector('#consent-deny').onclick = () => {
      modal.dispatchEvent(new CustomEvent('consent-denied'));
      modal.remove();
    };
    
    return modal;
  }
}

// 사용법
const privacyManager = new PrivacyManager(tracker);

// 애플리케이션 시작 시 동의 확인
if (!privacyManager.consentGiven) {
  privacyManager.requestConsent();
} else {
  tracker.start();
}
```

## 세션 리플레이 활용하기

### 대시보드 접속 및 기본 사용

배포가 완료되면 웹 브라우저에서 OpenReplay 대시보드에 접속합니다:

```bash
# 로컬 Docker 배포의 경우
http://localhost:9000

# 도메인 설정한 경우  
https://your-domain.com
```

#### 1단계: 프로젝트 설정

1. 관리자 계정으로 로그인
2. 새 프로젝트 생성
3. 프로젝트 키 복사
4. JavaScript 트래커에 적용

#### 2단계: 세션 모니터링

대시보드에서 실시간 세션을 모니터링할 수 있습니다:

- **라이브 세션**: 현재 활성 사용자들의 실시간 활동
- **세션 기록**: 과거 세션들의 재생 및 분석
- **사용자 여정**: 사용자의 전체 탐색 경로
- **성능 메트릭**: 페이지 로딩 시간, 상호작용 지연

### 고급 필터링 및 검색

OpenReplay의 강력한 검색 기능을 활용합니다:

```javascript
// 커스텀 메타데이터로 세션 분류
tracker.setMetadata('user_type', 'premium');
tracker.setMetadata('feature_flags', JSON.stringify({
  newCheckout: true,
  betaFeatures: false
}));

// A/B 테스트 그룹 추적
tracker.setMetadata('ab_test_group', 'variant_b');

// 사용자 컨텍스트 정보
tracker.setMetadata('device_type', 'mobile');
tracker.setMetadata('browser_version', navigator.userAgent);
```

대시보드에서 이러한 메타데이터로 필터링할 수 있습니다:

- 특정 사용자 그룹의 세션만 조회
- 오류가 발생한 세션들만 필터링
- A/B 테스트 그룹별 비교 분석
- 디바이스 유형별 사용자 행동 분석

### 실시간 사용자 지원 (Assist)

Assist 기능으로 사용자에게 실시간 지원을 제공합니다:

#### 1단계: Assist 활성화

```javascript
// Assist 기능 활성화
import Assist from '@openreplay/tracker/assist';

const assist = new Assist({
  confirmText: "고객지원팀에서 화면을 공유하려고 합니다. 동의하시겠습니까?",
  config: {
    audio: true,
    video: false, // 화면 공유만, 카메라는 비활성화
    screen: true
  }
});

tracker.use(assist);
```

#### 2단계: 지원 세션 시작

대시보드에서 진행중인 세션을 선택하고 "Assist" 버튼을 클릭합니다:

1. 사용자에게 동의 팝업이 표시됩니다
2. 동의 시 실시간 화면 공유가 시작됩니다  
3. 필요시 음성/영상 통화를 추가할 수 있습니다
4. 원격으로 사용자를 안내할 수 있습니다

#### 3단계: 지원 이력 관리

```javascript
// 지원 세션 메타데이터 추가
assist.onSessionStart((session) => {
  tracker.setMetadata('support_session_id', session.id);
  tracker.setMetadata('support_agent', session.agentId);
  
  // 지원 시작 이벤트
  tracker.event('support_session_started', {
    sessionId: session.id,
    requestType: 'user_initiated',
    timestamp: Date.now()
  });
});

assist.onSessionEnd((session, summary) => {
  // 지원 완료 이벤트
  tracker.event('support_session_ended', {
    sessionId: session.id,
    duration: summary.duration,
    resolution: summary.resolution,
    satisfaction: summary.userRating
  });
});
```

## 분석 및 알림 설정

### 커스텀 대시보드 구성

OpenReplay에서 비즈니스에 특화된 대시보드를 구성합니다:

#### 1단계: 핵심 메트릭 정의

```javascript
// 비즈니스 이벤트 추적
class BusinessMetrics {
  constructor(tracker) {
    this.tracker = tracker;
  }

  // 전환률 추적
  trackConversion(type, value) {
    this.tracker.event('conversion', {
      type, // 'signup', 'purchase', 'subscription'
      value,
      timestamp: Date.now(),
      sessionId: this.tracker.getSessionToken()
    });
  }

  // 사용자 참여도 추적
  trackEngagement(action, duration) {
    this.tracker.event('engagement', {
      action, // 'page_view', 'scroll', 'click'
      duration,
      depth: this.calculateScrollDepth(),
      interactions: this.getInteractionCount()
    });
  }

  // 기능 사용률 추적
  trackFeatureUsage(feature, context) {
    this.tracker.event('feature_usage', {
      feature,
      context,
      userType: this.tracker.getMetadata('user_type'),
      timestamp: Date.now()
    });
  }

  calculateScrollDepth() {
    const scrollTop = window.pageYOffset;
    const docHeight = document.documentElement.scrollHeight;
    const windowHeight = window.innerHeight;
    return Math.round((scrollTop / (docHeight - windowHeight)) * 100);
  }

  getInteractionCount() {
    return parseInt(sessionStorage.getItem('interaction_count') || '0');
  }
}

// 사용법
const metrics = new BusinessMetrics(tracker);

// 결제 완료 시
metrics.trackConversion('purchase', 129.99);

// 기능 사용 시
metrics.trackFeatureUsage('advanced_search', { 
  page: 'product_catalog',
  filters_applied: 3 
});
```

#### 2단계: 알림 설정

대시보드에서 다음과 같은 알림을 설정할 수 있습니다:

- **오류 급증 알림**: JavaScript 오류가 임계치를 초과할 때
- **성능 저하 알림**: 페이지 로딩 시간이 늘어날 때  
- **전환율 하락 알림**: 주요 전환 이벤트가 감소할 때
- **사용자 이탈 패턴**: 특정 페이지에서 이탈률이 높아질 때

### A/B 테스트 분석

OpenReplay를 활용한 A/B 테스트 결과 분석:

```javascript
// A/B 테스트 통합
class ABTestTracker {
  constructor(tracker) {
    this.tracker = tracker;
    this.testVariant = this.getTestVariant();
  }

  getTestVariant() {
    // 외부 A/B 테스트 도구에서 가져오거나 자체 구현
    const userId = this.tracker.getUserID();
    const hash = this.hashUserId(userId);
    return hash % 2 === 0 ? 'variant_a' : 'variant_b';
  }

  trackVariantExposure(testName) {
    this.tracker.setMetadata(`test_${testName}`, this.testVariant);
    this.tracker.event('ab_test_exposure', {
      testName,
      variant: this.testVariant,
      timestamp: Date.now()
    });
  }

  trackVariantConversion(testName, goalType, value = null) {
    this.tracker.event('ab_test_conversion', {
      testName,
      variant: this.testVariant,
      goalType, // 'click', 'signup', 'purchase'
      value,
      timestamp: Date.now()
    });
  }

  hashUserId(userId) {
    let hash = 0;
    for (let i = 0; i < userId.length; i++) {
      const char = userId.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // 32비트 정수로 변환
    }
    return Math.abs(hash);
  }
}

// 사용 예제
const abTest = new ABTestTracker(tracker);

// 새로운 체크아웃 플로우 테스트
abTest.trackVariantExposure('checkout_redesign');

// 다른 버튼 디자인 표시
if (abTest.testVariant === 'variant_b') {
  document.querySelector('.cta-button').classList.add('new-design');
}

// 전환 추적
document.querySelector('.purchase-button').addEventListener('click', () => {
  abTest.trackVariantConversion('checkout_redesign', 'purchase_attempt');
});
```

## 실제 테스트 및 예제

이제 실제 테스트를 위한 예제 애플리케이션을 만들어보겠습니다:

### 간단한 React 테스트 앱

```javascript
// src/OpenReplayDemo.js
import React, { useEffect, useState } from 'react';
import tracker from './openreplay';

function OpenReplayDemo() {
  const [counter, setCounter] = useState(0);
  const [userInfo, setUserInfo] = useState({
    name: '',
    email: ''
  });

  useEffect(() => {
    // OpenReplay 트래커 시작
    tracker.start().then(() => {
      console.log('OpenReplay 트래커 시작됨');
      
      // 사용자 정보 설정
      tracker.setUserID('demo-user-123');
      tracker.setMetadata('demo_mode', 'enabled');
      tracker.setMetadata('app_version', '1.0.0');
      
      // 페이지 뷰 이벤트
      tracker.event('page_view', {
        page: 'demo',
        timestamp: Date.now()
      });
    });

    return () => {
      tracker.stop();
    };
  }, []);

  const handleCounterClick = () => {
    setCounter(prev => prev + 1);
    
    // 클릭 이벤트 추적
    tracker.event('counter_clicked', {
      current_value: counter,
      new_value: counter + 1
    });
  };

  const handleFormSubmit = (e) => {
    e.preventDefault();
    
    // 폼 제출 이벤트 추적
    tracker.event('demo_form_submitted', {
      has_name: !!userInfo.name,
      has_email: !!userInfo.email,
      timestamp: Date.now()
    });
    
    // 사용자 정보 업데이트
    tracker.setMetadata('demo_user_name', userInfo.name);
    tracker.setMetadata('demo_user_email', userInfo.email);
    
    alert('데모 폼이 제출되었습니다!');
  };

  const handleErrorTest = () => {
    // 의도적 오류 발생 (테스트용)
    tracker.event('demo_error_test', { 
      test_type: 'intentional_error' 
    });
    
    try {
      // 존재하지 않는 함수 호출
      nonExistentFunction();
    } catch (error) {
      console.error('데모 오류:', error);
      
      // 오류 이벤트 수동 추적
      tracker.event('demo_javascript_error', {
        error_message: error.message,
        error_stack: error.stack,
        user_triggered: true
      });
    }
  };

  return (
    <div style={% raw %}{{ padding: '20px', fontFamily: 'Arial, sans-serif' }}{% endraw %}>
      <h1>OpenReplay 데모 애플리케이션</h1>
      
      <div style={% raw %}{{ marginBottom: '30px', padding: '20px', border: '1px solid #ccc' }}{% endraw %}>
        <h2>카운터 테스트</h2>
        <p>현재 카운트: {counter}</p>
        <button onClick={handleCounterClick}>
          카운트 증가
        </button>
      </div>

      <div style={% raw %}{{ marginBottom: '30px', padding: '20px', border: '1px solid #ccc' }}{% endraw %}>
        <h2>폼 입력 테스트</h2>
        <form onSubmit={handleFormSubmit}>
          <div>
            <label>
              이름:
              <input
                type="text"
                value={userInfo.name}
                onChange={(e) => setUserInfo(prev => ({
                  ...prev,
                  name: e.target.value
                }))}
                placeholder="이름을 입력하세요"
                style={% raw %}{{ marginLeft: '10px', padding: '5px' }}
              />
            </label>
          </div>
          <div style={% raw %}{{ marginTop: '10px' }}{% endraw %}>
            <label>
              이메일:
              <input
                type="email"
                value={userInfo.email}
                onChange={(e) => setUserInfo(prev => ({
                  ...prev,
                  email: e.target.value
                }))}
                placeholder="이메일을 입력하세요"
                style={% raw %}{{ marginLeft: '10px', padding: '5px' }}
              />
            </label>
          </div>
          <button type="submit" style={% raw %}{{ marginTop: '10px' }}{% endraw %}>제출</button>
        </form>
      </div>

      <div style={% raw %}{{ marginBottom: '30px', padding: '20px', border: '1px solid #ccc' }}{% endraw %}>
        <h2>오류 테스트</h2>
        <button onClick={handleErrorTest}>
          의도적 오류 발생
        </button>
      </div>

      <div style={% raw %}{{ padding: '20px', border: '1px solid #ccc' }}{% endraw %}>
        <h2>개발자 도구</h2>
        <p>브라우저 개발자 도구를 열어 OpenReplay 로그를 확인하세요.</p>
        <button onClick={% raw %}{{() => {
          console.log('OpenReplay 콘솔 로그 테스트');
          console.warn('OpenReplay 경고 메시지 테스트');
          console.error('OpenReplay 오류 메시지 테스트');
        }}}{% endraw %}>
          콘솔 로그 생성
        </button>
      </div>
    </div>
  );
}

export default OpenReplayDemo;
```

### macOS 개발환경 스크립트

```bash
#!/bin/bash
# setup-openreplay-demo.sh

echo "🚀 OpenReplay 데모 환경 설정 시작..."

# 현재 디렉토리 확인
CURRENT_DIR=$(pwd)
echo "📁 작업 디렉토리: $CURRENT_DIR"

# Node.js 설치 확인
if ! command -v node &> /dev/null; then
    echo "❌ Node.js가 설치되어 있지 않습니다."
    echo "💡 Homebrew로 설치: brew install node"
    exit 1
fi

echo "✅ Node.js 버전: $(node --version)"

# Docker 설치 확인
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되어 있지 않습니다."
    echo "💡 Homebrew로 설치: brew install --cask docker"
    exit 1
fi

echo "✅ Docker 버전: $(docker --version)"

# OpenReplay 서버 디렉토리 생성
if [ ! -d "openreplay-server" ]; then
    echo "📦 OpenReplay 서버 클론 중..."
    git clone https://github.com/openreplay/openreplay.git openreplay-server
fi

# React 데모 앱 생성
if [ ! -d "openreplay-demo-app" ]; then
    echo "📦 React 데모 앱 생성 중..."
    npx create-react-app openreplay-demo-app
fi

cd openreplay-demo-app

# OpenReplay 트래커 설치
echo "📦 OpenReplay 트래커 설치 중..."
npm install @openreplay/tracker @openreplay/tracker-assist

# 환경 변수 파일 생성
if [ ! -f ".env.local" ]; then
    echo "🔧 환경 변수 파일 생성..."
    cat > .env.local << EOF
# OpenReplay 설정
REACT_APP_OPENREPLAY_PROJECT_KEY=your_project_key_here
REACT_APP_OPENREPLAY_INGEST_POINT=http://localhost:9000/ingest

# 데모 모드 활성화
REACT_APP_DEMO_MODE=true
EOF
    echo "📝 .env.local 파일을 편집하여 실제 프로젝트 키를 입력하세요."
fi

# 데모 시작 스크립트 생성
cat > start-demo.sh << 'EOF'
#!/bin/bash
echo "🔍 OpenReplay 데모 모드 시작..."

# OpenReplay 서버 시작 (백그라운드)
echo "🚀 OpenReplay 서버 시작 중..."
cd ../openreplay-server/scripts/docker-compose
docker-compose up -d
echo "⏳ 서버 초기화 대기 중 (30초)..."
sleep 30

# React 데모 앱 시작
echo "🌐 React 데모 앱 시작..."
cd ../../openreplay-demo-app
echo "💡 브라우저에서 http://localhost:3000 을 열어주세요."
echo "🎯 OpenReplay 대시보드는 http://localhost:9000 에서 확인할 수 있습니다."

npm start
EOF

chmod +x start-demo.sh

# 정리 스크립트 생성
cat > stop-demo.sh << 'EOF'
#!/bin/bash
echo "🛑 OpenReplay 데모 정리 중..."

# React 앱 중지 (별도 터미널에서 Ctrl+C)
echo "📝 React 앱은 별도 터미널에서 Ctrl+C로 중지하세요."

# OpenReplay 서버 중지
echo "🚀 OpenReplay 서버 중지 중..."
cd ../openreplay-server/scripts/docker-compose
docker-compose down

echo "✅ 데모 정리 완료!"
EOF

chmod +x stop-demo.sh

echo "✅ OpenReplay 데모 환경 설정 완료!"
echo ""
echo "🚀 다음 단계:"
echo "   1. .env.local 파일에 OpenReplay 프로젝트 키 입력"
echo "   2. ./start-demo.sh 실행"
echo "   3. http://localhost:3000 에서 데모 테스트"
echo "   4. http://localhost:9000 에서 OpenReplay 대시보드 확인"
echo "   5. 완료 후 ./stop-demo.sh 실행"
```

## 결론

OpenReplay는 자체 호스팅이 가능한 강력한 세션 리플레이 및 사용자 분석 플랫폼입니다. 이 튜토리얼을 통해 다음을 학습했습니다:

### 핵심 성과

- **포괄적인 사용자 추적**: 세션 리플레이부터 실시간 지원까지
- **완전한 데이터 제어**: 자체 호스팅으로 보안과 프라이버시 보장
- **개발자 친화적**: 다양한 프레임워크 지원과 풍부한 API
- **확장 가능한 아키텍처**: Docker와 Kubernetes를 통한 프로덕션 배포

### 다음 단계

1. **고급 분석 구현**: 비즈니스 메트릭과 연동한 커스텀 대시보드 구축
2. **AI 기반 인사이트**: 머신러닝을 활용한 사용자 행동 패턴 분석
3. **멀티 플랫폼 확장**: 모바일 앱과 데스크톱 애플리케이션 추적
4. **실시간 알림**: 중요한 이벤트에 대한 즉시 알림 시스템 구축

### 유용한 리소스

- [OpenReplay 공식 문서](https://docs.openreplay.com)
- [GitHub 저장소](https://github.com/openreplay/openreplay)
- [커뮤니티 Slack](https://slack.openreplay.com)
- [공식 웹사이트](https://openreplay.com)

OpenReplay로 사용자 경험을 한 단계 업그레이드하고 데이터 주권을 확보하세요! 🚀

---

_이 튜토리얼이 도움이 되었다면 [GitHub](https://github.com/openreplay/openreplay)에서 ⭐를 눌러주세요._