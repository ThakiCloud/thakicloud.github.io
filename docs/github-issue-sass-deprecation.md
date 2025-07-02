# 🚨 Sass Deprecation Warnings 해결 필요

## 문제 상황

Jekyll 빌드 시 multiple Sass deprecation warnings가 발생하고 있습니다. 이는 **Dart Sass 2.0.0**에서 제거될 예정인 deprecated 함수들과 문법을 사용하고 있기 때문입니다.

## 발생하는 경고들

### 1. Color Functions Deprecation
```
Deprecation Warning [color-functions]: green() is deprecated. Suggestion:
color.channel($color, "green", $space: rgb)

Deprecation Warning [color-functions]: blue() is deprecated. Suggestion:
color.channel($color, "blue", $space: rgb)
```

**영향 파일**: `_sass/minimal-mistakes/_mixins.scss` (line 65-66)

### 2. Slash Division Deprecation
```
Deprecation Warning [slash-div]: Using / for division outside of calc() is deprecated and will be removed in Dart Sass 2.0.0.
Recommendation: math.div(($red * 299) + ($green * 587) + ($blue * 114), 1000) or calc((($red * 299) + ($green * 587) + ($blue * 114)) / 1000)
```

**영향 파일들**:
- `_sass/minimal-mistakes/_mixins.scss` (line 68)
- `_sass/minimal-mistakes/vendor/susy/susy/_su-math.scss` (line 93)

### 3. 추가 반복 경고
```
Warning: 212 repetitive deprecation warnings omitted.
```

## 영향도 분석

### 현재 상황
- ⚠️ **빌드는 성공**하지만 대량의 경고 메시지 출력
- 🔄 **개발 중 로그 가독성** 저하
- ⏰ **미래 호환성** 문제 (Dart Sass 2.0.0 출시 시 빌드 실패 가능)

### 예상 리스크
- Dart Sass 2.0.0 출시 시 빌드 중단
- CI/CD 파이프라인에서의 경고 누적
- 새로운 Sass 기능 활용 제한

## 해결 방안

### Phase 1: Color Functions 마이그레이션
```scss
// Before (Deprecated)
$red: red($color);
$green: green($color);
$blue: blue($color);

// After (Recommended)
@use "sass:color";
$red: color.channel($color, "red", $space: rgb);
$green: color.channel($color, "green", $space: rgb);
$blue: color.channel($color, "blue", $space: rgb);
```

### Phase 2: Division Operations 마이그레이션
```scss
// Before (Deprecated)
$yiq: (($red*299)+($green*587)+($blue*114))/1000;

// After (Option 1 - math.div)
@use "sass:math";
$yiq: math.div(($red*299)+($green*587)+($blue*114), 1000);

// After (Option 2 - calc)
$yiq: calc((($red * 299) + ($green * 587) + ($blue * 114)) / 1000);
```

### Phase 3: Vendor Libraries 업데이트
- **Susy Grid System**: 최신 버전으로 업데이트 또는 CSS Grid로 마이그레이션 검토
- **Breakpoint**: 최신 버전 확인 및 업데이트

## 실행 계획

### 1단계: 파일 수정
- [x] `_sass/minimal-mistakes/_mixins.scss` 수정
  - [x] `yiq-is-light()` 함수 업데이트
  - [x] color functions → `color.channel()` 마이그레이션
  - [x] division operator → `math.div()` 마이그레이션

### 2단계: Vendor 라이브러리 검토
- [ ] Susy grid system 최신 버전 확인
- [ ] Breakpoint library 업데이트 가능성 검토
- [ ] 필요 시 대체 솔루션 검토

### 3단계: 테스트 및 검증
- [ ] 로컬 빌드 테스트
- [ ] 스타일링 회귀 테스트
- [ ] 다양한 브라우저에서 렌더링 검증
- [ ] CI/CD 파이프라인 확인

### 4단계: 문서화
- [ ] 변경사항 문서화
- [ ] Sass 업그레이드 가이드 작성
- [ ] 향후 유지보수 가이드 업데이트

## 관련 리소스

- [Sass Color Functions Deprecation](https://sass-lang.com/d/color-functions)
- [Sass Slash Division Deprecation](https://sass-lang.com/d/slash-div)
- [Sass Math Module](https://sass-lang.com/documentation/modules/math)
- [Automated Sass Migrator](https://sass-lang.com/documentation/cli/migrator)

## 우선순위

**High Priority** 🔴
- Color functions 마이그레이션 (즉시 적용 가능)
- Division operations 마이그레이션 (핵심 기능 영향)

**Medium Priority** 🟡  
- Vendor libraries 업데이트 검토
- 자동화된 마이그레이션 도구 적용

**Low Priority** 🟢
- 성능 최적화
- 추가 Sass 기능 활용

---

## 예상 작업 시간
- **Phase 1-2**: 2-3시간 (핵심 파일 수정)
- **Phase 3**: 1-2시간 (테스트 및 검증)
- **총 예상 시간**: 4-5시간

## 담당자
- **개발**: @hanhyojung
- **리뷰**: TBD
- **QA**: TBD 