# AGENTS.md

## 프로젝트 개요
Express.js를 사용한 간단한 웹 API 서버입니다.

## 개발 환경 설정
- Node.js 18+ 필요
- npm install로 종속성 설치
- npm run dev로 개발 서버 시작

## 빌드 및 테스트 명령어
- `npm run dev` - 개발 서버 시작 (포트 3000)
- `npm run test` - Jest 테스트 실행
- `npm run lint` - ESLint 코드 검사
- `npm run build` - 프로덕션 빌드

## 코딩 컨벤션
- JavaScript ES6+ 사용
- 2스페이스 들여쓰기
- 세미콜론 사용
- camelCase 변수명
- 함수는 async/await 패턴 선호

## 테스트 지침
- 모든 API 엔드포인트에 대한 테스트 작성 필수
- __tests__ 폴더에 테스트 파일 위치
- 테스트 파일명: *.test.js 형식
- 커버리지 80% 이상 유지

## API 엔드포인트
- GET /api/health - 헬스체크
- GET /api/users - 사용자 목록 조회
- POST /api/users - 사용자 생성
- GET /api/users/:id - 특정 사용자 조회

## 보안 고려사항
- 입력 검증 필수 (express-validator 사용)
- API 키는 환경변수로 관리
- CORS 설정 확인
- Rate limiting 적용

## PR 가이드라인
- 브랜치명: feature/기능명 또는 fix/버그명
- 커밋 메시지: type(scope): description 형식
- 테스트 통과 후 PR 생성
- 코드 리뷰 2명 이상 승인 필요
