---
title: "Carbon ERP/MES 완벽 가이드: 오픈소스 제조업 관리 시스템"
excerpt: "복잡한 조립, HMLV, 주문제작 제조업에 최적화된 강력한 오픈소스 ERP/MES/QMS 시스템인 Carbon의 설치와 사용법을 완벽하게 학습해보세요."
seo_title: "Carbon ERP/MES 완벽 튜토리얼: 제조업 관리 시스템 설치 가이드 - 타키 클라우드"
seo_description: "Carbon ERP/MES 시스템을 마스터하세요. 제조업, 복잡한 조립, HMLV 운영, 주문제작 프로세스에 완벽한 종합 튜토리얼입니다."
date: 2025-09-09
lang: ko
permalink: /ko/tutorials/carbon-erp-mes-complete-setup-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/carbon-erp-mes-complete-setup-tutorial/"
categories:
  - tutorials
tags:
  - carbon
  - erp
  - mes
  - 제조업
  - 오픈소스
  - typescript
  - supabase
author_profile: true
toc: true
toc_label: "목차"
---

⏱️ **예상 읽기 시간**: 15분

## 소개

Carbon은 현대 제조업 환경을 위해 특별히 설계된 혁신적인 오픈소스 ERP(전사적 자원 관리), MES(제조 실행 시스템), QMS(품질 관리 시스템)입니다. TypeScript로 구축되고 Supabase로 구동되는 Carbon은 복잡한 조립 작업, HMLV(High Mix Low Volume) 제조, 주문제작 시나리오에서 탁월한 성능을 발휘합니다.

## Carbon ERP/MES란 무엇인가?

Carbon은 차세대 제조업 관리 시스템으로 다음과 같은 특징을 제공합니다:

- **완전한 제조업 패키지**: ERP, MES, QMS를 단일 플랫폼에서 제공
- **오픈소스 장점**: 완전한 투명성과 맞춤 설정 기능
- **최신 아키텍처**: TypeScript, React, Supabase로 구축
- **확장 가능한 설계**: 성장하는 제조업체에 완벽한 솔루션
- **산업 특화**: 복잡한 조립 및 주문제작 운영에 최적화

### 주요 기능

1. **전사적 자원 관리(ERP)**
   - 재고 관리
   - 주문 처리
   - 재무 추적
   - 고객 관계 관리

2. **제조 실행 시스템(MES)**
   - 생산 일정 계획
   - 작업 지시 관리
   - 실시간 현장 모니터링
   - 품질 관리 통합

3. **품질 관리 시스템(QMS)**
   - 품질 관리 워크플로우
   - 규정 준수 추적
   - 문서 관리
   - 감사 추적

## 사전 요구사항

Carbon을 시작하기 전에 다음 사항을 준비해주세요:

- **Node.js v20** (nvm 사용)
- **Docker** 설치 및 실행
- **Git** 저장소 관리용
- TypeScript/JavaScript 기본 지식
- 제조업 프로세스에 대한 이해

### 필수 외부 서비스

Carbon은 최적의 기능을 위해 여러 클라우드 서비스와 통합됩니다:

| 서비스 | 용도 | 무료 플랜 |
|---------|---------|-------------------|
| [Upstash](https://console.upstash.com/login) | 서버리스 Redis | ✅ 제공 |
| [Trigger.dev](https://cloud.trigger.dev/login) | 작업 실행기 | ✅ 제공 |
| [PostHog](https://us.posthog.com/signup) | 분석 도구 | ✅ 제공 |

## 설치 및 설정

### 1단계: 저장소 설정

Carbon 저장소를 복제하고 프로젝트 디렉토리로 이동합니다:

```bash
# 저장소 복제
git clone https://github.com/crbnos/carbon.git
cd carbon

# Node.js v20 사용
nvm use

# 의존성 설치
npm install
```

### 2단계: 데이터베이스 초기화

데이터베이스 서비스용 Docker 컨테이너를 시작합니다:

```bash
# 데이터베이스 컨테이너 실행
npm run db:start
```

이 명령어는 다음을 시작합니다:
- PostgreSQL 데이터베이스
- Supabase 로컬 인스턴스
- Redis 캐시
- 이메일 테스팅용 Mailpit

### 3단계: 환경 설정

환경 설정 파일을 생성합니다:

```bash
# 환경 템플릿 복사
cp ./.env.example ./.env
```

`.env` 파일에서 다음 환경 변수를 설정합니다:

#### 데이터베이스 설정
```env
# Supabase 설정 (db:start 출력에서 확인)
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_URL=http://localhost:54321
```

#### Redis 설정
Upstash에서 Redis 데이터베이스를 생성하고 추가:
```env
UPSTASH_REDIS_REST_URL=your_upstash_url
UPSTASH_REDIS_REST_TOKEN=your_upstash_token
```

#### 작업 실행기 설정
백그라운드 작업을 위한 Trigger.dev 설정:
```env
TRIGGER_PUBLIC_API_KEY=pk_dev_your_public_key
TRIGGER_API_KEY=tr_dev_your_server_key
TRIGGER_PROJECT_ID=proj_your_project_id
```

#### 분석 설정
제품 분석을 위한 PostHog 설정:
```env
POSTHOG_API_HOST=https://[region].posthog.com
POSTHOG_PROJECT_PUBLIC_KEY=phc_your_project_key
```

#### 결제 처리
결제 처리를 위한 Stripe 설정:
```env
STRIPE_SECRET_KEY=sk_test_your_stripe_key
```

Stripe 웹훅 등록:
```bash
npm run -w @carbon/stripe register:stripe
```

#### 인증 설정

다음 인증 방법 중 하나를 선택하세요:

**옵션 1: 이메일 인증 (Resend)**
```env
RESEND_API_KEY=re_your_resend_key
RESEND_DOMAIN=carbon.ms
```

**옵션 2: Google OAuth**
```env
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_ID=your_client_id.apps.googleusercontent.com
SUPABASE_AUTH_EXTERNAL_GOOGLE_CLIENT_SECRET=GOCSPX-your_client_secret
SUPABASE_AUTH_EXTERNAL_GOOGLE_REDIRECT_URI=http://127.0.0.1:54321/auth/v1/callback
```

### 4단계: 데이터베이스 설정 및 빌드

데이터베이스를 초기화하고 애플리케이션을 빌드합니다:

```bash
# 데이터베이스 마이그레이션 및 시드 데이터 실행
npm run db:build

# 모든 패키지 빌드
npm run build
```

### 5단계: 개발 환경 시작

모든 Carbon 애플리케이션을 실행합니다:

```bash
# 모든 애플리케이션 시작
npm run dev

# 또는 특정 애플리케이션만 시작
npm run dev:mes  # 제조 실행 시스템만
```

## 애플리케이션 개요

설치 성공 후 여러 애플리케이션에 액세스할 수 있습니다:

| 애플리케이션 | URL | 용도 |
|-------------|-----|---------|
| **ERP** | http://localhost:3000 | 전사적 자원 관리 |
| **MES** | http://localhost:3001 | 제조 실행 시스템 |
| **아카데미** | http://localhost:4111 | 교육 및 문서 |
| **스타터** | http://localhost:4000 | 시작 가이드 |

### 개발 도구

| 도구 | URL | 용도 |
|------|-----|---------|
| **Postgres** | postgresql://postgres:postgres@localhost:54322/postgres | 데이터베이스 접근 |
| **Supabase Studio** | http://localhost:54323/project/default | 데이터베이스 관리 |
| **Mailpit** | http://localhost:54324 | 이메일 테스팅 |
| **Edge Functions** | http://localhost:54321/functions/v1/ | 서버리스 함수 |

## Carbon ERP/MES 사용하기

### 1. 초기 설정 및 구성

1. **ERP 애플리케이션 접속**: http://localhost:3000으로 이동
2. **초기 설정 완료**: 설정 마법사를 따라 조직 구성
3. **사용자 관리**: 사용자 계정 생성 및 역할 할당
4. **기본 구성**: 위치, 부서, 기본 설정 구성

### 2. 재고 관리

재고 시스템을 구성합니다:

- **제품 마스터**: 제품, 원자재, 부품 정의
- **위치**: 창고 및 보관 위치 설정
- **재고 수준**: 최소 및 최대 재고 수준 구성
- **공급업체**: 공급업체 정보 및 가격 관리

### 3. 제조업 설정

제조 운영을 구성합니다:

- **부품 명세서(BOM)**: 제품 구조 정의
- **라우팅**: 제조 프로세스 설정
- **작업 센터**: 생산 자원 구성
- **품질 기준**: 품질 관리 매개변수 정의

### 4. 생산 계획

생산 워크플로우를 구현합니다:

- **생산 주문**: 작업 지시서 생성 및 관리
- **일정 계획**: 생산 활동 계획
- **자원 할당**: 작업자 및 장비 배정
- **진행 상황 추적**: 생산 상태 모니터링

## API 통합

Carbon은 외부 시스템과의 통합을 위한 포괄적인 API 접근을 제공합니다.

### API 인증

ERP 설정에서 API 키를 생성하고 구성합니다:

```javascript
import { Database } from "@carbon/database";
import { createClient } from "@supabase/supabase-js";

const apiKey = process.env.CARBON_API_KEY;
const apiUrl = process.env.CARBON_API_URL;
const publicKey = process.env.CARBON_PUBLIC_KEY;

const carbon = createClient<Database>(apiUrl, publicKey, {
  global: {
    headers: {
      "carbon-key": apiKey,
    },
  },
});

// 재고 항목 가져오기
const { data, error } = await carbon.from("item").select("*");
```

### 내부 API 사용

모노레포 개발용:

```javascript
import { getCarbonServiceRole } from "@carbon/auth";

const carbon = getCarbonServiceRole();

// 회사별 데이터 접근
const companyId = "your-company-id";
const { data, error } = await carbon
  .from("item")
  .select("*")
  .eq("companyId", companyId);
```

## 아키텍처 심화 분석

Carbon의 아키텍처는 여러 핵심 패키지로 구성됩니다:

### 핵심 패키지

- **@carbon/database**: 스키마, 마이그레이션, 타입 정의
- **@carbon/documents**: PDF 생성 및 이메일 템플릿
- **@carbon/jobs**: 백그라운드 작업 처리
- **@carbon/react**: 공유 UI 컴포넌트
- **@carbon/utils**: 공통 유틸리티 함수

### 통합 패키지

- **@carbon/ee**: 엔터프라이즈 통합
- **@carbon/stripe**: 결제 처리
- **@carbon/lib**: 서드파티 서비스 클라이언트
- **@carbon/kv**: Redis 캐싱 계층

## 문제 해결

### 일반적인 문제 및 해결책

**데이터베이스 연결 문제**
```bash
# 데이터베이스 컨테이너 재설정
npm run db:kill
npm run db:build
```

**포트 충돌**
- 포트 3000, 3001, 54321-54324가 사용 가능한지 확인
- 충돌하는 서비스 중지 또는 포트 구성 수정

**인증 문제**
- 모든 인증 환경 변수 확인
- Supabase 구성 점검
- 리디렉션 URL이 설정과 일치하는지 확인

**빌드 실패**
```bash
# 정리 및 재빌드
npm run clean
npm install
npm run build
```

## 모범 사례

### 개발 워크플로우

1. **환경 관리**: 개발, 스테이징, 프로덕션에 대한 별도 구성 사용
2. **데이터 백업**: 개발 중 정기적인 데이터베이스 백업
3. **버전 관리**: 협업을 위한 적절한 Git 워크플로우 사용
4. **테스팅**: 맞춤 수정에 대한 포괄적인 테스트 구현

### 프로덕션 배포

1. **보안 구성**: 기본 비밀번호 및 API 키 업데이트
2. **SSL/TLS**: 프로덕션 환경에 HTTPS 구현
3. **데이터베이스 최적화**: 적절한 데이터베이스 설정 구성
4. **모니터링**: 모니터링 및 알림 시스템 설정

### 성능 최적화

1. **데이터베이스 인덱싱**: 적절한 인덱싱으로 데이터베이스 쿼리 최적화
2. **캐싱 전략**: Redis를 사용한 효과적인 캐싱 구현
3. **자산 최적화**: 프론트엔드 자산 최소화 및 압축
4. **백그라운드 작업**: 무거운 작업에 백그라운드 처리 사용

## 고급 구성

### 맞춤 통합

Carbon의 모듈식 아키텍처는 외부 시스템과의 쉬운 통합을 가능하게 합니다:

- **ERP 시스템**: 기존 ERP 플랫폼과 연결
- **IoT 장치**: 현장 센서 및 장비 통합
- **품질 시스템**: 검사 및 테스트 장비 연결
- **보고 도구**: 비즈니스 인텔리전스 플랫폼과 통합

### 확장 고려사항

대규모 배포의 경우:

- **데이터베이스 클러스터링**: PostgreSQL 클러스터링 구현
- **로드 밸런싱**: 트래픽 분산을 위한 리버스 프록시 사용
- **마이크로서비스**: 더 작은 서비스로 분해 고려
- **클라우드 배포**: 클라우드 네이티브 확장 기능 활용

## 결론

Carbon ERP/MES는 현대 제조업 환경을 위한 강력한 솔루션을 제공합니다. 오픈소스 특성과 최신 기술 스택, 포괄적인 기능 세트가 결합되어 제조업 관리 시스템을 구현하거나 업그레이드하려는 조직에게 탁월한 선택이 됩니다.

이 시스템의 유연성은 특정 산업 요구사항에 맞는 맞춤 설정을 가능하게 하며, API 우선 접근 방식은 기존 비즈니스 시스템과의 원활한 통합을 보장합니다. 복잡한 조립 작업을 관리하든, HMLV 제조 프로세스를 구현하든, 주문제작 시나리오를 처리하든, Carbon은 성공에 필요한 도구와 기능을 제공합니다.

## 다음 단계

1. **애플리케이션 탐색**: 각 Carbon 애플리케이션에 익숙해지기
2. **환경 구성**: 특정 사용 사례에 맞는 설정 맞춤화
3. **데이터 가져오기**: 기존 데이터를 Carbon으로 마이그레이션
4. **팀 교육**: 사용자 교육을 위한 아카데미 애플리케이션 활용
5. **맞춤화 및 확장**: 고유한 요구사항에 맞게 Carbon 수정

추가 자료와 커뮤니티 지원을 위해 [Carbon GitHub 저장소](https://github.com/crbnos/carbon)를 방문하고 아카데미 애플리케이션에서 제공하는 포괄적인 문서를 탐색해보세요.

---

*Carbon으로 제조업 운영을 혁신할 준비가 되셨나요? 오늘 여정을 시작하고 오픈소스 제조업 관리의 힘을 경험해보세요.*
