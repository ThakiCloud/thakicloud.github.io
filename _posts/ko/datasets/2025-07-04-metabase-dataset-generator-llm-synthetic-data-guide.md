---
title: "Metabase Dataset Generator: LLM 기반 현실적인 합성 데이터 생성 완벽 가이드"
excerpt: "OpenAI GPT-4o를 활용한 Metabase Dataset Generator로 데모, 학습, 대시보드를 위한 현실적인 합성 데이터셋을 생성하는 방법을 알아보세요."
seo_title: "Metabase Dataset Generator - LLM 합성 데이터 생성 도구 - Thaki Cloud"
seo_description: "OpenAI GPT-4o와 Faker를 활용한 Metabase Dataset Generator로 현실적인 합성 데이터를 생성하는 방법. CSV/SQL 내보내기, 실시간 미리보기, 스키마 설계까지 완벽 가이드."
date: 2025-07-04
last_modified_at: 2025-07-04
categories:
  - datasets
tags:
  - Metabase
  - Dataset Generator
  - LLM
  - OpenAI
  - 합성데이터
  - GPT-4o
  - Faker
  - 데이터생성
  - 데이터시각화
  - 대시보드
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/datasets/metabase-dataset-generator-llm-synthetic-data-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 10분

## 서론

데이터 분석과 시각화 프로젝트를 시작할 때 가장 큰 걸림돌 중 하나는 적절한 데이터셋을 확보하는 것입니다. 실제 프로덕션 데이터는 민감한 정보를 포함하고 있어 쉽게 사용할 수 없고, 공개 데이터셋은 특정 비즈니스 시나리오를 반영하지 못하는 경우가 많습니다.

[Metabase Dataset Generator](https://github.com/metabase/dataset-generator)는 이러한 문제를 해결하기 위해 개발된 혁신적인 도구입니다. OpenAI GPT-4o를 활용하여 현실적이고 일관성 있는 합성 데이터를 생성하며, 데모, 학습, 대시보드 구축 등 다양한 목적으로 활용할 수 있습니다.

## Metabase Dataset Generator란?

### 핵심 특징

Metabase Dataset Generator는 MIT 라이선스로 제공되는 오픈소스 프로젝트로, 다음과 같은 주요 기능을 제공합니다:

- **🤖 대화형 프롬프트 빌더**: 비즈니스 타입, 스키마, 행 수 등을 직관적으로 설정
- **⚡ 실시간 데이터 미리보기**: 브라우저에서 즉시 데이터 샘플 확인
- **📊 다양한 내보내기 형식**: CSV(단일 파일 또는 다중 테이블 ZIP), SQL 인서트문 지원
- **🔍 원클릭 Metabase 통합**: 생성된 데이터를 Metabase에서 바로 탐색

### 기술 스택

- **Frontend**: Next.js (App Router, TypeScript)
- **UI/UX**: Tailwind CSS + ShadCN UI (모던한 다크 테마)
- **AI Engine**: OpenAI API (GPT-4o)
- **데이터 생성**: Faker.js
- **데이터 탐색**: Metabase (Docker 컨테이너)

## LLM 기반 데이터 생성 원리

### 하이브리드 접근 방식

Metabase Dataset Generator는 LLM과 전통적인 데이터 생성 라이브러리를 결합한 하이브리드 접근 방식을 사용합니다:

1. **LLM 단계 (OpenAI GPT-4o)**:
   - 비즈니스 컨텍스트 이해
   - 데이터 스키마 설계
   - 비즈니스 규칙 정의
   - 데이터 간 관계 모델링

2. **Faker 단계 (로컬 생성)**:
   - LLM이 생성한 스펙 기반으로 실제 데이터 생성
   - 일관성 있는 대용량 데이터 생성
   - 비용 효율적인 확장성

### 비용 구조

| 작업 | OpenAI 호출 | 비용 | LLM 사용 | Faker 사용 | 행 수 |
|------|-------------|------|----------|------------|-------|
| 미리보기 | 예 | ~$0.05 | 예 | 예 | 10 |
| CSV 다운로드 | 아니오 | $0 | 아니오 | 예 | 100+ |
| SQL 다운로드 | 아니오 | $0 | 아니오 | 예 | 100+ |

**핵심 포인트**:
- 미리보기/스펙 생성 시에만 OpenAI 비용 발생 (~$0.05)
- 모든 다운로드는 동일한 스키마/스펙을 사용하며 무료

## 설치 및 설정

### 사전 요구사항

```bash
# Docker 및 Docker Compose 설치 확인
docker --version
docker-compose --version

# OpenAI API 키 준비
# https://platform.openai.com/ 에서 발급
```

### 설치 과정

```bash
# 1. 저장소 클론
git clone https://github.com/metabase/dataset-generator.git
cd dataset-generator

# 2. 환경 변수 설정
cp .env.example .env.local

# 3. OpenAI API 키 설정
# .env.local 파일에 다음 내용 추가
OPENAI_API_KEY=your-openai-api-key

# 4. 의존성 설치
npm install

# 5. 개발 서버 실행
npm run dev
```

서버는 `http://localhost:3000`에서 실행됩니다.

## 사용법 상세 가이드

### 1. 데이터셋 생성 프로세스

#### 단계 1: 비즈니스 타입 선택

```javascript
// 지원되는 비즈니스 타입 예시
const businessTypes = [
  'E-commerce',
  'SaaS Application',
  'Financial Services',
  'Healthcare',
  'Educational Platform',
  'Real Estate',
  'Manufacturing',
  'Retail Chain',
  'Logistics & Supply Chain',
  'Digital Marketing Agency'
];
```

#### 단계 2: 스키마 구조 설정

**One Big Table (OBT)**:
```sql
-- 모든 관련 정보가 하나의 테이블에 비정규화된 형태
CREATE TABLE ecommerce_orders (
  order_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  customer_email VARCHAR(100),
  product_name VARCHAR(200),
  category VARCHAR(50),
  price DECIMAL(10,2),
  quantity INT,
  order_date DATE,
  shipping_address TEXT,
  payment_method VARCHAR(50)
);
```

**Star Schema**:
```sql
-- 팩트 테이블과 차원 테이블로 정규화된 형태
CREATE TABLE fact_orders (
  order_id INT PRIMARY KEY,
  customer_id INT,
  product_id INT,
  date_id INT,
  quantity INT,
  unit_price DECIMAL(10,2),
  total_amount DECIMAL(10,2)
);

CREATE TABLE dim_customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(100),
  email VARCHAR(100),
  registration_date DATE,
  customer_segment VARCHAR(50)
);

CREATE TABLE dim_products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(200),
  category VARCHAR(50),
  subcategory VARCHAR(50),
  brand VARCHAR(100),
  unit_price DECIMAL(10,2)
);
```

#### 단계 3: 매개변수 설정

```typescript
interface DatasetConfig {
  businessType: string;
  schemaType: 'obt' | 'star';
  rowCount: number;
  includeTrends: boolean;
  seasonality: boolean;
  anomalies: boolean;
  timeRange: {
    start: Date;
    end: Date;
  };
}
```

### 2. 고급 데이터 생성 기능

#### 시간 시리즈 트렌드

```javascript
// 계절성 패턴을 포함한 판매 데이터
const generateSeasonalSales = (baseValue, date) => {
  const month = date.getMonth();
  const seasonalMultiplier = {
    0: 0.7,   // 1월 - 낮음
    1: 0.8,   // 2월 - 낮음
    2: 0.9,   // 3월 - 보통
    // ... 연말 쇼핑 시즌
    10: 1.3,  // 11월 - 높음
    11: 1.5   // 12월 - 매우 높음
  };
  
  return baseValue * seasonalMultiplier[month];
};
```

#### 비즈니스 규칙 적용

```javascript
// 전자상거래 비즈니스 규칙 예시
const ecommerceRules = {
  // 고객 세그먼트별 구매 행동
  customerSegments: {
    'premium': {
      avgOrderValue: 150,
      purchaseFrequency: 'high',
      preferredCategories: ['electronics', 'luxury']
    },
    'regular': {
      avgOrderValue: 75,
      purchaseFrequency: 'medium',
      preferredCategories: ['clothing', 'home']
    },
    'budget': {
      avgOrderValue: 35,
      purchaseFrequency: 'low',
      preferredCategories: ['books', 'accessories']
    }
  },
  
  // 재고 제약
  inventory: {
    'popular_items': { stockLevel: 'high', availability: 0.95 },
    'seasonal_items': { stockLevel: 'variable', availability: 0.8 },
    'discontinued': { stockLevel: 'low', availability: 0.3 }
  }
};
```

### 3. 데이터 내보내기 옵션

#### CSV 내보내기

```bash
# 단일 테이블 CSV
GET /api/export/csv?format=single&rows=1000

# 다중 테이블 ZIP
GET /api/export/csv?format=zip&rows=10000
```

#### SQL 내보내기

```sql
-- 생성되는 SQL 인서트문 예시
INSERT INTO customers (customer_id, name, email, segment) VALUES
(1, 'John Doe', 'john.doe@email.com', 'premium'),
(2, 'Jane Smith', 'jane.smith@email.com', 'regular'),
-- ... 추가 데이터
```

## 실제 활용 사례

### 1. 전자상거래 데이터 분석

```javascript
// 프롬프트 예시
const ecommercePrompt = `
Create an e-commerce dataset with:
- 50,000 orders over 2 years
- 5,000 unique customers
- 500 products across 20 categories
- Seasonal trends (holiday shopping spikes)
- Customer lifetime value progression
- Product recommendation correlations
- Geographic distribution (US states)
- Multiple payment methods and shipping options
`;
```

**생성되는 데이터 특징**:
- 고객 세그먼트별 구매 패턴
- 계절성 반영 (블랙 프라이데이, 크리스마스 등)
- 상품 카테고리별 성능 차이
- 지역별 선호도 분석
- 리턴 고객 vs 신규 고객 비율

### 2. SaaS 메트릭 대시보드

```javascript
const saasPrompt = `
Generate SaaS metrics dataset:
- User acquisition funnel (10,000 trials → 2,000 conversions)
- Monthly recurring revenue (MRR) growth
- Churn analysis by cohort
- Feature usage patterns
- Support ticket correlation
- Pricing tier performance
- Geographic expansion metrics
`;
```

**주요 메트릭**:
- Customer Acquisition Cost (CAC)
- Customer Lifetime Value (CLV)
- Monthly/Annual Recurring Revenue (MRR/ARR)
- Churn Rate & Retention Curves
- Net Promoter Score (NPS)
- Feature Adoption Rates

### 3. 금융 서비스 데이터

```javascript
const financePrompt = `
Create financial services dataset:
- 100,000 transactions over 18 months
- Account types: checking, savings, credit cards
- Transaction categories: dining, shopping, utilities
- Fraud detection scenarios (0.1% fraud rate)
- Credit score impact modeling
- Seasonal spending patterns
- Merchant categorization
`;
```

**분석 가능한 인사이트**:
- 사기 거래 패턴 분석
- 고객 신용도 변화 추이
- 소비 패턴 세분화
- 리스크 평가 모델링
- 상품 교차 판매 기회

## Metabase 통합 및 시각화

### 1. Metabase 실행

```bash
# Metabase 컨테이너 시작
curl -X POST http://localhost:3000/api/metabase/start

# 상태 확인
curl http://localhost:3000/api/metabase/status

# Metabase 접근 (준비 완료 후)
open http://localhost:3001
```

### 2. 데이터 업로드 및 연결

```javascript
// CSV 업로드를 통한 데이터 연결
const uploadProcess = {
  1: '생성된 CSV 파일 다운로드',
  2: 'Metabase에서 "Upload Data" 기능 사용',
  3: '파일 선택 및 스키마 매핑 확인',
  4: '데이터 타입 및 관계 설정',
  5: '대시보드 생성 시작'
};
```

### 3. 자동 대시보드 생성

Metabase의 Auto-Dashboard 기능을 활용하여 생성된 데이터에 대한 즉시 인사이트를 얻을 수 있습니다:

```sql
-- 자동 생성되는 쿼리 예시
SELECT 
  DATE_TRUNC('month', order_date) as month,
  SUM(total_amount) as revenue,
  COUNT(*) as order_count,
  AVG(total_amount) as avg_order_value
FROM orders 
GROUP BY month 
ORDER BY month;
```

## 고급 활용 기법

### 1. 커스텀 비즈니스 규칙 정의

```typescript
// lib/spec-prompts.ts 확장
export const customBusinessRules = {
  healthcare: {
    patientAgeDistribution: 'normal(45, 15)',
    appointmentTypes: ['routine', 'emergency', 'follow-up'],
    seasonalPatterns: {
      flu: 'peak in winter months',
      allergies: 'peak in spring/fall'
    }
  },
  
  education: {
    enrollmentPeriods: ['fall', 'spring', 'summer'],
    gradeDistribution: 'normal distribution with slight grade inflation',
    courseCompletionRates: 'vary by subject difficulty'
  }
};
```

### 2. 대용량 데이터 생성 최적화

```javascript
// 메모리 효율적인 스트림 생성
const generateLargeDataset = async (rows = 1000000) => {
  const batchSize = 10000;
  const totalBatches = Math.ceil(rows / batchSize);
  
  for (let i = 0; i < totalBatches; i++) {
    const batch = generateDataBatch(batchSize);
    await writeToFile(batch, `batch_${i}.csv`);
  }
  
  // 모든 배치 파일을 하나로 합치기
  await mergeBatchFiles();
};
```

### 3. 데이터 품질 검증

```javascript
const validateDataQuality = (dataset) => {
  const checks = {
    // 중복 키 검사
    uniqueKeys: validateUniqueConstraints(dataset),
    
    // 참조 무결성 검사
    foreignKeys: validateForeignKeys(dataset),
    
    // 비즈니스 규칙 검사
    businessRules: validateBusinessLogic(dataset),
    
    // 통계적 분포 검사
    distributions: validateStatisticalDistributions(dataset)
  };
  
  return checks;
};
```

## 성능 최적화 및 모범 사례

### 1. 메모리 사용량 최적화

```javascript
// 스트림 기반 데이터 생성
const generateStreamingData = (spec, rowCount) => {
  return new ReadableStream({
    start(controller) {
      let generated = 0;
      
      const generateBatch = () => {
        const batchSize = Math.min(1000, rowCount - generated);
        const batch = faker.generateBatch(spec, batchSize);
        
        controller.enqueue(batch);
        generated += batchSize;
        
        if (generated < rowCount) {
          setTimeout(generateBatch, 0);
        } else {
          controller.close();
        }
      };
      
      generateBatch();
    }
  });
};
```

### 2. 캐싱 전략

```javascript
// 스펙 캐싱으로 재생성 비용 절약
const specCache = new Map();

const getCachedSpec = (promptHash) => {
  if (specCache.has(promptHash)) {
    return specCache.get(promptHash);
  }
  
  // LLM 호출 후 캐시 저장
  const spec = generateSpecFromLLM(prompt);
  specCache.set(promptHash, spec);
  
  return spec;
};
```

### 3. 에러 처리 및 복구

```javascript
const robustDataGeneration = async (spec, rows) => {
  const maxRetries = 3;
  let attempt = 0;
  
  while (attempt < maxRetries) {
    try {
      return await generateData(spec, rows);
    } catch (error) {
      attempt++;
      
      if (attempt >= maxRetries) {
        // 기본 스펙으로 폴백
        return await generateData(getDefaultSpec(), rows);
      }
      
      // 지수 백오프
      await sleep(Math.pow(2, attempt) * 1000);
    }
  }
};
```

## 프로젝트 구조 및 확장

### 디렉토리 구조

```
dataset-generator/
├── app/
│   ├── page.tsx              # 메인 UI 및 프롬프트 빌더
│   ├── api/
│   │   ├── generate/route.ts # 합성 데이터 생성 (OpenAI)
│   │   └── metabase/
│   │       ├── start/route.ts
│   │       ├── stop/route.ts
│   │       └── status/route.ts
├── lib/
│   ├── export/               # CSV/SQL 내보내기 로직
│   ├── spec-prompts.ts       # 비즈니스 타입별 프롬프트
│   └── data-generator.ts     # Faker 기반 데이터 생성
├── components/               # UI 컴포넌트
└── docker-compose.yml        # Metabase 컨테이너 설정
```

### 새로운 비즈니스 타입 추가

```typescript
// lib/spec-prompts.ts 확장
export const newBusinessType = {
  name: 'Smart City',
  description: 'IoT sensors and urban infrastructure data',
  
  schema: {
    sensors: {
      sensor_id: 'unique identifier',
      sensor_type: 'temperature, humidity, air_quality, noise',
      location: 'GPS coordinates',
      installation_date: 'timestamp'
    },
    
    readings: {
      reading_id: 'unique identifier',
      sensor_id: 'foreign key',
      timestamp: 'datetime',
      value: 'numeric measurement',
      unit: 'measurement unit'
    }
  },
  
  businessRules: [
    'Sensor readings follow circadian patterns',
    'Air quality correlates with traffic patterns',
    'Weather affects multiple sensor types',
    'Maintenance events create data gaps'
  ]
};
```

## 문제 해결 및 FAQ

### 자주 발생하는 문제들

1. **OpenAI API 키 오류**
   ```bash
   # 환경 변수 확인
   echo $OPENAI_API_KEY
   
   # .env.local 파일 확인
   cat .env.local
   ```

2. **Metabase 컨테이너 실행 오류**
   ```bash
   # Docker 서비스 상태 확인
   docker ps
   
   # 컨테이너 로그 확인
   docker logs metabase-container
   
   # 포트 충돌 확인
   lsof -i :3001
   ```

3. **메모리 부족 오류**
   ```javascript
   // 배치 크기 조정
   const BATCH_SIZE = process.env.NODE_ENV === 'production' ? 5000 : 1000;
   ```

### 성능 튜닝 가이드

```javascript
// 대용량 데이터 생성 시 권장 설정
const optimizedConfig = {
  batchSize: 10000,
  maxConcurrency: 4,
  memoryLimit: '4GB',
  
  // 스트리밍 활성화
  streaming: true,
  
  // 압축 활성화
  compression: true,
  
  // 진행률 표시
  progressReporting: true
};
```

## 결론

Metabase Dataset Generator는 LLM의 지능적인 데이터 모델링 능력과 전통적인 데이터 생성 도구의 확장성을 결합한 혁신적인 솔루션입니다. 

### 주요 장점

- **비용 효율성**: 스펙 생성 시에만 LLM 비용 발생
- **현실적인 데이터**: 비즈니스 컨텍스트를 반영한 일관성 있는 데이터
- **즉시 활용**: Metabase 통합으로 생성 즉시 시각화 가능
- **유연한 스키마**: OBT와 Star Schema 모두 지원
- **확장성**: 수십만 행의 데이터도 로컬에서 빠르게 생성

### 활용 시나리오

- **데모 및 프레젠테이션**: 실제와 유사한 데이터로 설득력 있는 시연
- **교육 및 학습**: 안전한 환경에서 데이터 분석 기술 습득
- **프로토타이핑**: 신제품 개발 시 데이터 기반 의사결정 시뮬레이션
- **테스트 데이터**: 시스템 성능 및 알고리즘 검증

지금 바로 [Metabase Dataset Generator](https://github.com/metabase/dataset-generator)를 시도해보세요. 여러분의 데이터 분석 프로젝트가 한 단계 더 발전할 것입니다.

### 추가 리소스

- **GitHub 저장소**: [metabase/dataset-generator](https://github.com/metabase/dataset-generator)
- **Metabase 공식 사이트**: [www.metabase.com](https://www.metabase.com)
- **기여 가이드**: [CONTRIBUTING.md](https://github.com/metabase/dataset-generator/blob/main/CONTRIBUTING.md)
- **행동 강령**: [CODE_OF_CONDUCT.md](https://github.com/metabase/dataset-generator/blob/main/CODE_OF_CONDUCT.md)

---

*이 포스트는 Metabase Dataset Generator의 공식 문서와 소스 코드를 바탕으로 작성되었습니다. 최신 정보는 GitHub 저장소를 참조해주세요.* 