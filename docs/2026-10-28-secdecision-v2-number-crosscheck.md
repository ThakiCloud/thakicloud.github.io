---
published: false
---
# Thaki-SecDecision-27B-V2 글 — PR #145 추가 수치 원장 대조 기록

- 날짜: 2026-10-28
- 대상: PR #145 (`sylvanus4/thakicloud.github.io`), `_posts/{ko,en}/research/2026-10-28-secdecision-27b-v2-evidence-sufficiency.md`
- 대조 범위: **추가 수치 10건** = 커밋 `7375bc2a`("docs: enrich SecDecision post with V1 rule lesson")가 ko·en 본문에 각각 5줄(총 10줄) 추가한 문단의 수치 항목 5개 × ko/en
- 대조 정본: `secembed/pair_factory/AUDIT_DECISION_RECORD.jsonl`(원장) + 결과 파일(아래 §4)

## 1. 수치별 대조 테이블

| # | 본문 수치 (ko·en 각 1회) | 본문 맥락 | 원장 정본 | 실제값 | 판정 |
|---|---|---|---|---|---|
| 1 | 0.627 | 이전 회귀 실험 스톡 매크로 F1 | seq 238 (`secdecision_13h_prime_final_verdict`, 2026-10-24T15:33:54Z) `point_primary_8023.stock_tau05.macro_f1` | 0.6273 | ✅ |
| 2 | 0.731 | 13h′ 매크로 F1 | seq 238 `point_primary_8023.13h_tau090.macro_f1` | 0.731 | ✅ 정확 |
| 3 | 1.79% | 스톡 오결론률(False-ENOUGH) | seq 238 `stock_tau05.false_enough` | 0.0179 | ✅ |
| 4 | 3.19% | 13h′ 오결론률 | seq 238 `13h_tau090.false_enough` | 0.031877846236271094 | ✅ 정확(반올림) |
| 5 | 0.48 | 개정 전 규칙(v0) 교정 split 결론 회수율 | seq 279 (`SEC_DECISION_V2_RULE_EVAL_HOST`) `rules.v0_original.enough_recall`(calib n=2004, ckpt 1000, τ 0.5037888038268661) | 0.4865 | ✅ — 범위 귀속 정정(§2) |
| 6 | 0.048 | 반증 방향(REFUTE_COVERAGE 변형, n=334) 회수율 | seq 279 `rules.v0_original.refute_coverage_recall` | 0.0479 | ✅ |
| 7 | 0.9985 | 봉인 TEST REFUTE_COVERAGE 회수율 | `secembed/decision/v2/results/SEC_DECISION_V2_TEST_EVAL.json` `.v2.metrics.by_variant.REFUTE_COVERAGE.recall`(n=667) | 0.9985 | ✅ 정확 |

게이트 서술("사전등록 게이트를 통과하지 못했습니다")도 원장과 일치: seq 238
`verdict = NO-GO (judge FAIL — 모델 FAIL, INFRA 아님)`, `failed_gates = [G-S1, G-S2]`
(G-S1: FE 0.0319 > cap 0.0216 · G-S2: FE≤cap 매칭 recall 0.451 < canary 0.507).

## 2. 대조 소견과 처리

### 소견 1 (해결): 초기 오대조
1–4번 수치를 E1 경쟁 회귀·TF 진단(seq 177/179, 0.6273→0.7273 · 1.79%→1.85%)과 대조해
"원장 불일치"로 오판정했다. 그 실험은 본문 맥락의 **V1 13h′ 최종 회귀**(seq 238)가 다른
독립 실험이다. "사전등록 게이트" 서사는 seq 238 의 G-S1/G-S2 FAIL → NO-GO 와 정확히 일치하고,
4개 수치 전부 seq 238 실측과 대조 일치. 교훈: "회귀 실험"은 원장에서 실험 이름
(`secdecision_13h_prime_final_verdict`)으로 정하고 대조한다.

### 소견 2 (정정): 0.48 의 범위 귀속
원문은 0.48 을 "증거가 클레임을 뒤집는 케이스에서 결론 회수율"이라 서술했다. 원장 정의에
따면(`secdecision_v2_model.decision_metrics`):

- 0.4865 = **전체** calib enough_recall — gold can_conclude=True 668건(FULL 334 + REFUTE_COVERAGE 334)
  회수율, (FULL 0.9251 + REFUTE_COVERAGE 0.0479) / 2
- 0.0479 = **반증 subset**(REFUTE_COVERAGE 변형, n=334) 회수율

즉 0.48 은 전체 값이고 반증 케이스 회수율은 0.048 이다. 수치 자체는 원장에 존재하나
범위 귀속이 어긋나 ko·en 양본 문장을 정정(수치 전량 보존, 귀속만 교정):

- ko 정정 전: "…증거가 클레임을 뒤집는 케이스에서 결론 회수율이 0.48 부근에서 머물렀고 교정 split의 반증 방향 회수율은 0.048이었습니다."
- ko 정정 후: "개정 전의 판정 규칙은 반증 방향에서 보수적이었습니다. 교정 split 전체의 결론 회수율은 0.48 부근에 그쳤고, 그중 증거가 클레임을 뒤집는 케이스(REFUTE_COVERAGE)의 회수율은 0.048이었습니다."
- en 정정 후: "overall conclusion recall on the calibration split stayed around 0.48, and on the cases where the evidence overturns the claim (REFUTE_COVERAGE) it was 0.048."

## 3. 판정

- 추가 수치 10건(5 항목 × ko/en) 원장 대조: **PASS (10/10)** — 개별 수치 7개 전부 원장·결과파일
  근거 확보. 범위 귀속 오류 1건(0.48)은 본문 정정으로 폐기.
- Humanize 게이트 WARN 예외 근거: 본문 신규 수치(7375bc2a 추가분)는 **원장 검증 완료**이며
  이 기록이 그 대조 증거다. 예외는 이 수치에만 적용하고 본문 나머지에 확장하지 않는다.

## 4. 정본 provenance (해시 검증 완료 2026-10-28)

| 항목 | 값 |
|---|---|
| 원장 | `secembed/pair_factory/AUDIT_DECISION_RECORD.jsonl` |
| seq 238 해시 | judge `d051cf60ee9a1f8e` · data `04cbb02f2335291d` · result_file `c684e5cc232c8065` |
| V1 13h 결과 파일 | `secembed/decision/results/SEC_DECISION_V1_13H_REGRESSION_RESULT.json` — sha16 `c684e5cc232c8065` ✅ |
| seq 279 결과 파일 | `secembed/decision/v2/results/SEC_DECISION_V2_RULE_EVAL.json` — sha16 `c0f0bac15331eaba` ✅ (원장 기재와 일치) |
| TEST_EVAL | `secembed/decision/v2/results/SEC_DECISION_V2_TEST_EVAL.json` (REFUTE_COVERAGE.recall 0.9985, n=667) |
| 봉인 상태 | sealed TEST 미개봉 · τ 0.9995245433226797 는 calib 에서 TEST 개봉 전 고정(미조절) |
