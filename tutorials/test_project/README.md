# Shotgun Test Project

이 프로젝트는 Shotgun Code 도구의 기능을 테스트하기 위한 간단한 Node.js 애플리케이션입니다.

## 구조

```
test_project/
├── package.json          # 프로젝트 설정
├── README.md             # 이 파일
└── src/
    ├── index.js          # 메인 애플리케이션
    └── utils/
        ├── calculator.js # 계산기 유틸리티
        └── logger.js     # 로거 유틸리티
```

## 실행 방법

```bash
npm start
```

## 기능

- **Calculator**: 기본적인 수학 연산 (더하기, 빼기, 곱하기, 나누기)
- **Logger**: 다양한 레벨의 로깅 기능
- **App**: 메인 애플리케이션 클래스

이 프로젝트는 Shotgun Code가 어떻게 코드베이스를 분석하고 LLM이 이해할 수 있는 형태로 변환하는지 보여주는 예제입니다. 