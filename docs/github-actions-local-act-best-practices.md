# GitHub Act & GitHub Actions 운용 베스트 프랙티스

## 1. 두 플랫폼의 역할 구분
| 구분 | 목적 | 특징 |
|------|------|------|
| **GitHub Act (로컬)** | 빠른 피드백·디버깅 | Docker 러너로 동일한 환경을 에뮬레이션하여 *커밋·푸시 없이* 수 초 내 실행 |
| **GitHub Actions (원격)** | 공식 CI 게이트 | 팀 전체 품질·이력·권한을 보장하며 배포·알림 등 최종 단계를 수행 |

> **결론** : 로컬(Act)은 **개발 테스트**, 원격(Actions)은 **정식 CI/CD** 로 분리 운영하는 것이 일반적입니다.

---

## 2. 원격 실행을 생략해야 하는 상황
| 필요성 | 대표 사례 | 일반적 해결책 |
|--------|-----------|---------------|
| **비용·시간 절감** | README·주석·번역 커밋 | 커밋 메시지에 `[skip ci]` |
| **시크릿 노출 방지** | Slack 알림·배포 스텝 | `if: !env.ACT` 조건으로 로컬 시 스킵 |
| **중복 실행 방지** | 연속 푸시 | `concurrency.cancel-in-progress: true` |

---

## 3. 구현 기법

### 3.1 커밋 메시지 토큰 `[skip ci]`
```bash
git commit -m "docs: typo fix [skip ci]"
````

`[skip ci]`, `[ci skip]`, `[no ci]`, `[skip actions]`, `[actions skip]` 중 하나를 HEAD 커밋 메시지에 포함하면 **전체 워크플로**가 건너뜁니다.

### 3.2 Act 전용 플래그 감지

Act는 기본적으로 `ACT=true` 환경 변수를 주입합니다.

```yaml
if: ${{ !env.ACT }}   # 로컬(Act)에서는 스킵
```

*반대로 로컬 전용 스텝은* `if: env.ACT` 로 작성합니다.

### 3.3 브랜치·경로 필터

```yaml
on:
  push:
    branches: [ main ]           # 메인 브랜치만
    paths-ignore: [ '**.md' ]    # 문서 변경 무시
```

### 3.4 중복 실행 제거

```yaml
concurrency:
  group: ci-${{ github.ref }}
  cancel-in-progress: true
```

---

## 4. 비용·보안 고려

* **과금** : 퍼블릭 저장소는 무료이나 프라이빗은 분당 과금 → 사소한 커밋은 `[skip ci]` 전략으로 비용 절감
* **시크릿** : 배포 키·알림 토큰은 로컬에서 필요 없으므로 `if: !env.ACT` 로 스텝 자체를 건너뛰어 노출 위험 최소화

---

## 5. 추천 운영 흐름

1. **로컬 개발**

   * `.actrc` 구성 후 `act push -j lint-test` 등으로 수시 검증
2. **커밋 시점**

   * 문서·주석 변경 → `[skip ci]` 태그로 원격 CI 생략
3. **PR / 메인 브랜치**

   * GitHub Actions가 전체 테스트·배포 수행
4. **중복 방지**

   * `concurrency`로 “가장 최신 커밋 한 건만” 유지
5. **보안 단계**

   * 배포·알림 스텝에 `if: !env.ACT` 조건 추가

---

## 6. 핵심 메시지

> **로컬에서 빠르게 검증 → 원격에서 최종 확정**
> Act와 GitHub Actions를 적절히 분리하면 **피드백 속도·비용·보안**을 모두 최적화할 수 있습니다.