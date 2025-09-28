---
title: "ERPNext 완벽 설치 및 사용 가이드: 오픈소스 ERP 시스템 튜토리얼"
excerpt: "강력한 오픈소스 ERP 시스템인 ERPNext의 설치, 설정, 핵심 기능 사용법을 완벽하게 안내하는 종합 가이드입니다."
seo_title: "ERPNext 튜토리얼: 오픈소스 ERP 완벽 설치 가이드 - Thaki Cloud"
seo_description: "무료 오픈소스 ERP 시스템 ERPNext 설치, 설정, 사용법을 배워보세요. Docker 설치부터 기본 설정, 비즈니스 기능까지 완벽 튜토리얼."
date: 2025-09-28
categories:
  - tutorials
tags:
  - ERPNext
  - ERP
  - 오픈소스
  - 비즈니스관리
  - Docker
  - Frappe프레임워크
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/erpnext-complete-setup-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/erpnext-complete-setup-tutorial/"
---

⏱️ **예상 읽기 시간**: 15분

## 소개

ERPNext는 강력하고 직관적이며 완전히 오픈소스인 전사적 자원 관리(ERP) 시스템으로, 기업이 운영을 효율적으로 관리할 수 있도록 도와줍니다. Frappe 프레임워크를 기반으로 구축된 ERPNext는 회계, 재고 관리, 제조, 프로젝트 관리 등 포괄적인 솔루션을 무료로 제공합니다.

이 종합 튜토리얼에서는 ERPNext 설치부터 기본 설정 및 사용법까지 전체 과정을 단계별로 안내합니다. 소규모 사업체 운영자든 비용 효율적인 ERP 솔루션을 찾는 기업이든, 이 가이드를 통해 ERPNext를 시작할 수 있습니다.

## ERPNext란 무엇인가?

ERPNext는 Frappe Technologies에서 개발한 100% 오픈소스 ERP 시스템입니다. 다양한 비즈니스 프로세스에 대한 통합 솔루션을 제공하여 기업이 운영을 더욱 효율적으로 수행할 수 있도록 설계되었습니다.

### 주요 기능

**회계 및 재무**
- 총계정원장, 매입채무/매출채권을 포함한 완전한 회계 시스템
- 재무 보고 및 분석 도구
- 다중 통화 지원
- 세금 관리 및 컴플라이언스

**재고 및 주문 관리**
- 실시간 재고 추적
- 구매 및 판매 주문 관리
- 공급업체 및 고객 관계 관리
- 다중 위치 창고 관리

**제조**
- 자재 명세서(BOM) 관리
- 생산 계획 및 일정 관리
- 작업 지시서 추적
- 하청 관리

**프로젝트 관리**
- 작업 및 마일스톤 추적
- 타임시트 관리
- 프로젝트 수익성 분석
- 이슈 추적 및 해결

**인사 관리**
- 직원 관리 및 급여
- 휴가 및 출근 추적
- 성과 관리
- 채용 및 온보딩

## 사전 요구사항

설치를 시작하기 전에 다음 사전 요구사항을 확인하세요:

### 시스템 요구사항
- **운영체제**: Linux (Ubuntu 18.04+), macOS, 또는 WSL2가 있는 Windows
- **RAM**: 최소 4GB (8GB 권장)
- **저장공간**: 최소 10GB 여유 공간
- **네트워크**: 안정적인 인터넷 연결

### 필수 소프트웨어
- Docker 및 Docker Compose
- Git
- 웹 브라우저 (Chrome, Firefox, Safari, 또는 Edge)

## 설치 방법

ERPNext는 여러 방법으로 설치할 수 있습니다. 가장 인기 있는 방법들을 다루겠습니다:

### 방법 1: Docker 설치 (권장)

Docker 설치는 ERPNext를 시작하는 가장 쉽고 신뢰할 수 있는 방법입니다.

#### 1단계: Docker 및 Docker Compose 설치

**Ubuntu/Debian에서:**
```bash
# 패키지 인덱스 업데이트
sudo apt update

# Docker 설치
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Docker Compose 설치
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 사용자를 docker 그룹에 추가
sudo usermod -aG docker $USER
```

**macOS에서:**
```bash
# https://docker.com/products/docker-desktop에서 Docker Desktop 설치
# 또는 Homebrew 사용
brew install --cask docker
```

#### 2단계: ERPNext Docker 저장소 클론

```bash
# 공식 ERPNext Docker 저장소 클론
git clone https://github.com/frappe/frappe_docker
cd frappe_docker

# 환경 파일 생성
cp example.env .env
```

#### 3단계: 환경 변수 설정

설치를 사용자 정의하기 위해 `.env` 파일을 편집합니다:

```bash
# 환경 파일 편집
nano .env
```

수정할 주요 설정:
```env
# 사이트 설정
SITES=erpnext.localhost
ERPNEXT_SITE_NAME=erpnext.localhost

# 데이터베이스 설정
DB_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_root_password

# 관리자 비밀번호
ADMIN_PASSWORD=your_admin_password
```

#### 4단계: ERPNext 서비스 시작

```bash
# Docker Compose로 ERPNext 시작
docker compose -f pwd.yml up -d

# 서비스가 실행 중인지 확인
docker compose -f pwd.yml ps
```

#### 5단계: ERPNext 접속

몇 분 후 ERPNext에 접속할 수 있습니다:
- **URL**: `http://localhost:8080`
- **사용자명**: `Administrator`
- **비밀번호**: `admin` (또는 .env에서 설정한 비밀번호)

### 방법 2: Bench를 사용한 수동 설치

개발이나 사용자 정의 설정을 위해 Bench 도구를 사용하여 ERPNext를 수동으로 설치할 수 있습니다.

#### 1단계: 시스템 의존성 설치

**Ubuntu/Debian에서:**
```bash
# 시스템 의존성 설치
sudo apt update
sudo apt install -y python3-dev python3-pip python3-venv
sudo apt install -y software-properties-common
sudo apt install -y mariadb-server mariadb-client
sudo apt install -y redis-server
sudo apt install -y curl
sudo apt install -y nodejs npm
```

#### 2단계: Bench 설치

```bash
# Bench CLI 설치
pip3 install frappe-bench

# 새 bench 디렉토리 생성
bench init frappe-bench --frappe-branch version-14
cd frappe-bench

# bench 서비스 시작
bench start
```

#### 3단계: 새 사이트 생성 및 ERPNext 설치

```bash
# 새 사이트 생성
bench new-site erpnext.localhost

# ERPNext 앱 가져오기
bench get-app https://github.com/frappe/erpnext

# 사이트에 ERPNext 설치
bench --site erpnext.localhost install-app erpnext

# 사이트를 기본값으로 설정
bench use erpnext.localhost
```

## 초기 설정

ERPNext가 설치되고 실행되면 초기 설정 마법사를 완료해야 합니다.

### 설정 마법사 단계

#### 1단계: 언어 및 지역
- 선호하는 언어 선택
- 국가 및 시간대 선택
- 통화 및 날짜 형식 설정

#### 2단계: 회사 정보
```
회사명: 귀하의 회사명
회사 약어: YCN
기본 통화: KRW (또는 현지 통화)
국가: 대한민국
시간대: Asia/Seoul
```

#### 3단계: 사용자 정보
- 관리자 계정 생성
- 프로필 정보 설정
- 이메일 설정 구성

#### 4단계: 비즈니스 도메인
비즈니스와 관련된 도메인 선택:
- 제조업
- 유통업
- 소매업
- 서비스업
- 비영리
- 교육

#### 5단계: 계정과목표
- 표준 계정과목표 템플릿 선택
- 또는 필요에 따라 사용자 정의 계정과목표 생성

## 핵심 모듈 개요

ERPNext의 주요 모듈과 기본 사용법을 살펴보겠습니다:

### 1. 회계 모듈

회계 모듈은 ERPNext 재무 관리의 핵심입니다.

**주요 기능:**
- 계정과목표 관리
- 분개 및 전표
- 매입채무 및 매출채권
- 재무 보고 및 분석

**기본 사용법:**
```
이동: 회계 > 계정과목표
- 비즈니스용 계정 항목 생성
- 세금 템플릿 설정
- 지불 조건 구성
```

### 2. 판매 모듈

리드부터 결제까지 판매 프로세스를 관리합니다.

**주요 구성요소:**
- 고객 관리
- 판매 주문 및 송장
- 견적서 및 제안서
- 판매 분석

**판매 주문 생성:**
1. `판매 > 판매 주문 > 신규`로 이동
2. 고객 선택 또는 신규 생성
3. 수량 및 단가와 함께 항목 추가
4. 배송 날짜 및 조건 설정
5. 주문 제출

### 3. 구매 모듈

조달 프로세스를 간소화합니다.

**기능:**
- 공급업체 관리
- 구매 주문 및 입고
- 구매 송장
- 공급업체 분석

**구매 주문 생성:**
1. `구매 > 구매 주문 > 신규`로 이동
2. 공급업체 선택
3. 구매할 항목 추가
4. 배송 일정 설정
5. 승인을 위해 제출

### 4. 재고 모듈

포괄적인 재고 관리 시스템입니다.

**기능:**
- 다중 창고 재고 추적
- 재고 이동 및 이전
- 일련번호 및 배치번호 추적
- 재고 평가

**재고 입력 프로세스:**
1. `재고 > 재고 입력 > 신규`로 이동
2. 입력 유형 선택 (자재 입고, 이전 등)
3. 출발지 및 목적지 창고 선택
4. 수량과 함께 항목 추가
5. 입력 제출

### 5. 제조 모듈

생산 프로세스를 계획하고 추적합니다.

**구성요소:**
- 자재 명세서(BOM)
- 작업 지시서
- 생산 계획
- 작업 카드

**BOM 생성:**
1. `제조 > BOM > 신규`로 이동
2. 제조할 항목 선택
3. 수량과 함께 원자재 추가
4. 작업 및 작업장 설정
5. 비용 계산 및 저장

## 고급 설정

### 이메일 설정

자동 알림을 위한 이메일 통합 설정:

```
설정 > 이메일 도메인
- SMTP 설정 구성
- 이메일 계정 설정
- 이메일 템플릿 생성
```

**SMTP 설정 예시:**
```
이메일 서버: smtp.gmail.com
포트: 587
TLS 사용: 예
사용자명: your-email@gmail.com
비밀번호: your-app-password
```

### 인쇄 형식

비즈니스 문서 사용자 정의:

```
설정 > 인쇄 설정
- 사용자 정의 레터헤드 생성
- 송장 템플릿 디자인
- 다양한 문서에 대한 인쇄 형식 설정
```

### 사용자 정의 필드

기존 문서 유형에 사용자 정의 필드 추가:

```
설정 > 양식 사용자 정의
- 사용자 정의할 문서 유형 선택
- 사용자 정의 필드 추가
- 필드 속성 및 권한 설정
```

### 워크플로우 설정

승인 워크플로우 설정:

```
설정 > 워크플로우
- 워크플로우 상태 생성
- 전환 및 조건 정의
- 역할 및 권한 할당
```

## 사용자 관리 및 권한

### 사용자 생성

1. `설정 > 사용자 > 신규`로 이동
2. 사용자 세부정보 및 이메일 입력
3. 역할 및 권한 할당
4. 사용자 기본 설정 설정

### 역할 기반 권한

ERPNext는 포괄적인 역할 기반 권한 시스템을 사용합니다:

**표준 역할:**
- 시스템 관리자: 전체 시스템 접근
- 회계 관리자: 재무 운영
- 판매 관리자: 판매 운영
- 구매 관리자: 조달 운영
- 재고 관리자: 재고 운영

**권한 설정:**
```
설정 > 역할 권한 관리자
- 문서 유형 및 역할 선택
- 읽기, 쓰기, 생성, 삭제 권한 설정
- 필드 수준 권한 구성
```

## 보고 및 분석

ERPNext는 강력한 보고 기능을 제공합니다:

### 표준 보고서

사전 구축된 보고서 접근:
```
회계 > 보고서
- 손익계산서
- 대차대조표
- 현금흐름표
- 매출채권 요약
```

### 사용자 정의 보고서

보고서 빌더를 사용하여 사용자 정의 보고서 생성:
```
설정 > 보고서 빌더
- 소스 문서 유형 선택
- 필드 및 필터 선택
- 그룹화 및 정렬 설정
- 보고서 저장 및 공유
```

### 대시보드 분석

대시보드로 주요 지표 모니터링:
```
홈 > 대시보드
- 주요 성과 지표 보기
- 판매 및 구매 동향 추적
- 재고 수준 모니터링
- 재무 성과 분석
```

## 모바일 접근

ERPNext는 다음을 통해 모바일 접근을 제공합니다:

### 웹 모바일 인터페이스
- 반응형 웹 인터페이스
- 터치 친화적 탐색
- 기본 작업을 위한 오프라인 기능

### ERPNext 모바일 앱
- iOS 및 Android용 제공
- 실시간 동기화
- 중요한 업데이트에 대한 푸시 알림

## 백업 및 유지보수

### 자동 백업

정기 백업 설정:
```bash
# Docker 설치의 경우
docker compose exec backend bench --site erpnext.localhost backup

# 수동 설치의 경우
bench --site erpnext.localhost backup
```

### 시스템 유지보수

정기 유지보수 작업:
- ERPNext를 최신 버전으로 업데이트
- 시스템 성능 모니터링
- 오래된 파일 및 로그 정리
- 사용자 접근 및 권한 검토

### 업데이트 프로세스

**Docker 설치:**
```bash
# 최신 이미지 가져오기
docker compose pull

# 서비스 재시작
docker compose down
docker compose up -d
```

**수동 설치:**
```bash
# bench 및 앱 업데이트
bench update

# 사이트 마이그레이션
bench --site erpnext.localhost migrate
```

## 일반적인 문제 해결

### 설치 문제

**Docker 컨테이너가 시작되지 않음:**
```bash
# 컨테이너 로그 확인
docker compose logs

# 서비스 재시작
docker compose restart

# 시스템 리소스 확인
docker system df
```

**데이터베이스 연결 문제:**
- 설정에서 데이터베이스 자격 증명 확인
- MariaDB 서비스가 실행 중인지 확인
- 적절한 네트워크 연결 확인

### 성능 문제

**느린 로딩 시간:**
- 시스템 리소스(RAM, CPU) 확인
- 데이터베이스 쿼리 최적화
- 캐싱 활성화
- 사용자 정의 스크립트 및 커스터마이제이션 검토

**높은 메모리 사용량:**
- 백그라운드 작업 모니터링
- 대용량 보고서 최적화
- 오래된 로그 및 파일 정리

### 접근 문제

**로그인 문제:**
- bench 명령을 사용하여 비밀번호 재설정
- 사용자 권한 및 역할 확인
- 이메일 설정 확인

**권한 오류:**
- 역할 할당 검토
- 문서 유형 권한 확인
- 사용자 그룹 멤버십 확인

## 모범 사례

### 데이터 관리
1. **정기 백업**: 자동 일일 백업 설정
2. **데이터 검증**: 데이터 품질 보장을 위한 검증 규칙 사용
3. **명명 규칙**: 일관된 명명 표준 수립
4. **오래된 데이터 보관**: 정기적으로 과거 기록 보관

### 보안
1. **강력한 비밀번호**: 강력한 비밀번호 정책 시행
2. **이중 인증**: 관리자 사용자에 대해 2FA 활성화
3. **정기 업데이트**: ERPNext를 최신 버전으로 유지
4. **접근 제어**: 최소 권한 원칙 구현

### 성능 최적화
1. **데이터베이스 인덱싱**: 적절한 인덱스로 데이터베이스 쿼리 최적화
2. **캐싱**: 더 나은 성능을 위해 Redis 캐싱 활성화
3. **리소스 모니터링**: 시스템 리소스 정기 모니터링
4. **사용자 정의 스크립트**: 사용자 정의 Python 및 JavaScript 코드 최적화

## 통합 기능

ERPNext는 다양한 타사 서비스와 통합할 수 있습니다:

### 전자상거래 통합
- Shopify 커넥터
- WooCommerce 통합
- Magento 동기화

### 결제 게이트웨이
- PayPal 통합
- Stripe 결제 처리
- 한국 비즈니스를 위한 Razorpay

### 커뮤니케이션 도구
- WhatsApp Business API
- Slack 알림
- 이메일 마케팅 플랫폼

### 회계 소프트웨어
- QuickBooks 마이그레이션
- Tally 데이터 가져오기
- Excel/CSV 데이터 가져오기

## 결론

ERPNext는 비즈니스 운영을 크게 개선할 수 있는 포괄적이고 기능이 풍부한 ERP 솔루션입니다. 오픈소스 특성과 강력한 기능 및 유연성이 결합되어 모든 규모의 비즈니스에 탁월한 선택이 됩니다.

이 튜토리얼의 주요 요점:

1. **쉬운 설치**: Docker 기반 설정으로 설치가 간단함
2. **포괄적인 기능**: 모든 주요 비즈니스 프로세스 커버
3. **사용자 정의 가능**: 특정 요구사항에 맞게 높은 유연성과 사용자 정의 가능
4. **비용 효율적**: 라이선스 비용 없이 무료 오픈소스
5. **활발한 커뮤니티**: 강력한 커뮤니티 지원 및 정기 업데이트

### 다음 단계

이 튜토리얼을 완료한 후 고려사항:

1. **고급 기능 탐색**: 제조, 프로젝트 관리 또는 HR 모듈에 더 깊이 들어가기
2. **비즈니스에 맞게 사용자 정의**: 사용자 정의 필드, 워크플로우 및 보고서 추가
3. **팀 교육**: 직원에게 포괄적인 교육 제공
4. **커뮤니티 참여**: ERPNext 포럼 및 토론에 참여
5. **전문 지원 고려**: 관리형 호스팅을 위한 Frappe Cloud 탐색

### 추가 학습 리소스

- **공식 문서**: [https://docs.erpnext.com](https://docs.erpnext.com)
- **Frappe School**: [https://frappe.school](https://frappe.school)
- **커뮤니티 포럼**: [https://discuss.erpnext.com](https://discuss.erpnext.com)
- **GitHub 저장소**: [https://github.com/frappe/erpnext](https://github.com/frappe/erpnext)
- **YouTube 채널**: ERPNext 공식 튜토리얼

ERPNext의 단순한 회계 도구에서 포괄적인 ERP 시스템으로의 여정은 오픈소스 개발의 힘을 보여줍니다. 지속적인 발전과 성장하는 커뮤니티를 통해 ERPNext는 현대 비즈니스의 변화하는 요구사항을 충족할 수 있는 좋은 위치에 있습니다.

오늘 ERPNext 여정을 시작하고 진정으로 통합된 비즈니스 관리 시스템의 이점을 경험해보세요!
