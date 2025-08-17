# Browserable SDK 테스트 예제

이 디렉토리는 [Browserable](https://github.com/browserable/browserable) JavaScript SDK를 테스트하기 위한 예제 코드들을 포함합니다.

## 📋 포함된 예제

### 1. 기본 연결 테스트 (`test-examples.js`)
- Browserable API 연결 확인
- Google 페이지 제목 추출
- arXiv 논문 검색
- TechCrunch 뉴스 검색
- HTTP 폼 작성 및 제출

### 2. GitHub 트렌딩 검색 (`github-trending.js`)
- GitHub 트렌딩 저장소 자동 검색
- 상위 10개 저장소 정보 추출
- 프로그래밍 언어, 스타 수, 설명 포함

### 3. Amazon 제품 검색 (`amazon-search.js`)
- 요가 매트 특정 조건 검색
- 제품명, 가격, 평점, 특징 추출
- 커스텀 검색 쿼리 지원

## 🚀 설치 및 실행

### 1. 의존성 설치

```bash
npm install
```

### 2. 환경 변수 설정

```bash
# .env 파일 생성
cp env-example.txt .env

# 필수 환경 변수 설정
echo "BROWSERABLE_API_KEY=your_actual_api_key" >> .env
```

### 3. 테스트 실행

```bash
# 기본 연결 테스트만 실행
npm test

# 전체 테스트 실행 (시간이 더 오래 걸림)
RUN_FULL_TESTS=true npm test

# 개별 예제 실행
npm run github-trending
npm run amazon-search

# 커스텀 Amazon 검색
node amazon-search.js "wireless headphones"
```

## 📖 사용법 가이드

### GitHub 트렌딩 검색

```javascript
import { GitHubTrendingAgent } from './github-trending.js';

const agent = new GitHubTrendingAgent();
const result = await agent.findTrendingRepos();
console.log(result.data.repositories);
```

### Amazon 제품 검색

```javascript
import { AmazonSearchAgent } from './amazon-search.js';

const agent = new AmazonSearchAgent();

// 기본 요가 매트 검색
const yogaMats = await agent.searchYogaMats();

// 커스텀 검색
const laptops = await agent.searchWithCustomQuery("gaming laptop");
```

### 종합 테스트

```javascript
import { BrowserableTestSuite } from './test-examples.js';

const testSuite = new BrowserableTestSuite();
await testSuite.runAllTests();
```

## 🔧 환경 변수

| 변수명 | 필수 | 설명 |
|--------|------|------|
| `BROWSERABLE_API_KEY` | ✅ | Browserable API 키 |
| `BROWSERABLE_BASE_URL` | ❌ | API 베이스 URL (기본값: http://localhost:2003) |
| `DEBUG` | ❌ | 디버그 모드 활성화 (true/false) |
| `RUN_FULL_TESTS` | ❌ | 전체 테스트 실행 (true/false) |

## 🚨 트러블슈팅

### 일반적인 문제

1. **API 키 오류**
   ```
   Error: BROWSERABLE_API_KEY 환경 변수가 설정되지 않았습니다.
   ```
   - `.env` 파일에 올바른 API 키 설정 확인

2. **연결 오류**
   ```
   Error: connect ECONNREFUSED 127.0.0.1:2003
   ```
   - Browserable 서버가 실행 중인지 확인
   - `docker-compose up` 또는 `npx browserable` 실행

3. **타임아웃 오류**
   ```
   Error: Task execution timeout
   ```
   - 복잡한 작업의 경우 정상적인 현상
   - 재시도 또는 타임아웃 시간 증가

### 성능 최적화

- **헤드리스 모드**: 성능 향상을 위해 `headless: true` 사용
- **뷰포트 크기**: 필요에 따라 뷰포트 크기 조정
- **타임아웃 설정**: 작업 복잡도에 따라 적절한 타임아웃 설정

## 📚 참고 자료

- [Browserable 공식 문서](https://browserable.ai/docs)
- [JavaScript SDK 가이드](https://browserable.ai/docs/sdk)  
- [GitHub 저장소](https://github.com/browserable/browserable)
- [Thaki Cloud 블로그 튜토리얼](https://thakicloud.github.io/tutorials/browserable-ai-browser-automation-complete-guide/)

## 🤝 기여하기

새로운 예제나 개선사항이 있으면 PR을 보내주세요!

1. 새로운 예제 스크립트 작성
2. README에 사용법 추가
3. 테스트 검증 후 제출

---

💡 **팁**: 이 예제들은 Browserable의 기본 기능을 보여줍니다. 더 복잡한 워크플로우는 여러 작업을 조합하여 구현할 수 있습니다.
