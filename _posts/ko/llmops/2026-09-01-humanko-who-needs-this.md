---
title: "자기 모델을 가질 차례인 회사들: 톰슨 로이터가 증명한 공식"
excerpt: "톰슨 로이터는 오픈 가중치에 175년 치 자사 데이터를 학습시켜 자기 모델을 만들었습니다. 전체 예산은 4천만 달러였지만 최종 학습 실행은 약 45만 달러였습니다. 같은 공식이 훨씬 작은 규모에서도 돈다는 것을 저희가 확인했고, 이 글은 그 공식이 어떤 회사에 필요한지 정리합니다."
seo_title: "오픈 가중치 + 자사 데이터: 자기 모델이 필요한 회사들"
seo_description: "Thomson Reuters의 자체 LLM 발표와 Human-KO 27B 공개가 가리키는 같은 공식. 보험 콜센터, 증권 컴플라이언스, 브랜드 보이스, 공공 폐쇄망까지 자기 모델이 맞는 자리를 세그먼트별로 분석합니다."
date: 2026-09-01
published: true
categories:
  - llmops
tags:
  - korean
  - open-weights
  - domain-llm
  - human-ko
  - enterprise-ai
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/humanko-who-needs-this/"
audiobook: "https://drive.google.com/file/d/1FJLWi-4QLilauqZE-LTi-YjTISQaYlwF/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

요즘 어느 회사든 비슷한 고민을 합니다. 바깥의 범용 모델을 빌려 쓰자니 우리 일과 말투에 안 맞고, 직접 만들자니 엄두가 안 난다는 고민입니다. 지난주에 그 셈법을 바꾸는 발표가 하나 나왔고, 저희도 훨씬 작은 규모에서 같은 결론에 도달했습니다. 이 글은 그 공식이 어떤 회사의 어떤 자리에 필요한지 정리합니다.

![자기 모델을 가질 차례인 회사들: 톰슨 로이터가 증명한 공식 개념을 형상화한 이미지](/assets/images/humanko-who-needs-this-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 쉽게 말하면

기성복과 맞춤 정장의 차이입니다. 지금까지 기업은 몸에 안 맞아도 기성복(범용 모델)을 입거나, 옷 공장을 통째로 지어야(모델을 처음부터 학습) 한다고 생각했습니다. 그런데 재봉 비용이 뚝 떨어졌습니다. 좋은 원단만 있으면 맞춤 정장을 지을 수 있게 됐고, 그 원단(자기 데이터)은 이미 회사 장롱 안에 있습니다. 이 정장 비유를 글 끝까지 쓰겠습니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/humanko-who-needs-this/nlm-infographic-1.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 지난주에 증명된 공식

법률 정보 회사 톰슨 로이터가 자체 모델 톰슨(Thomson)을 발표했습니다. 처음부터 만든 것이 아니라 공개된 오픈 가중치 모델 위에, 175년간 쌓인 자사의 법률·세무·회계 데이터를 이어서 학습시킨 모델입니다. 발표된 벤치마크에서 최상위 상용 모델들과 겨루는 수준이라고 밝혔습니다.

돈의 구조가 핵심입니다. 프로젝트 전체에는 2년간 4천만 달러가 들었지만, 최종 학습 실행 자체는 약 45만 달러였습니다. 즉, 사람 말로는: 비용의 대부분은 재봉틀 돌리는 값이 아니라 원단을 고르고 다듬고 치수를 재는 데 들어갔습니다. 어떤 데이터를 먹일지 정하는 일과 측정이 본체이고, 학습은 마지막의 짧은 공정입니다.

한 가지는 분명히 해 둡니다. 톰슨 로이터가 공개한 축소판 모델은 학술·비상업 전용이라, 그 모델을 가져다 상업 서비스에 쓰는 길은 막혀 있습니다. 가져올 것은 모델이 아니라 공식입니다.

![humanko-who-needs-this 슬라이드 1](/assets/images/humanko-who-needs-this-slide-01.webp)

## 작은 규모에서도 같은 공식이 돕니다

저희는 어제 같은 공식의 축소판을 공개했습니다. 오픈 가중치 27B의 한국어 답변 버릇을 가중치 수준에서 바꿨고, 불릿 도배 비율이 97.5%에서 2.0%로 내려갔습니다. 사람다움 블라인드 대결에서는 원본과 국내 대표 모델 양쪽을 상대로 95% 수준의 승률이 나왔습니다. 최종 학습 실행은 한 시간이 걸리지 않았습니다.

규모는 다르지만 결론은 톰슨과 같습니다. 시간의 대부분은 교재(학습 데이터)를 설계하고 저울(평가)을 세우는 데 들어갔고, 그 두 가지가 준비된 팀에게 학습 자체는 싼 공정이었습니다. 상세한 수치와 한계는 [가중치 공개 글](https://thakicloud.com/tech-blog/ko/llmops/humanko-27b-release/)과 [비교 측정 글](https://thakicloud.com/tech-blog/ko/llmops/humanko-27b-vs-exaone/)에 있습니다.

![humanko-who-needs-this 슬라이드 2](/assets/images/humanko-who-needs-this-slide-02.webp)

## 어떤 회사의 어떤 자리에 맞나

**보험사의 콜센터가 가장 선명한 자리입니다.** 음성봇의 답은 화면이 아니라 목소리로 나갑니다. 불릿 여덟 개짜리 답은 읽어 줄 방법이 없고, 천 자짜리 답은 통화를 붙잡습니다. 짧은 존댓말 산문이 기본값인 모델은 이 자리에 정확히 맞고, 답이 짧아지는 만큼 토큰 비용도 함께 내려갑니다. 설계사 훈련용 가상 고객처럼 특정 말투의 상대가 필요한 자리도 이미 열려 있습니다. 한화생명은 가상대화 훈련 시스템을 공개적으로 운영하고 있습니다.

**증권사는 이미 선례가 있습니다.** 미래에셋증권은 온프레미스 환경에 금융 특화 소형 모델을 구축했습니다. 여기서 한 걸음 더 나갈 수 있는 자리가 말투입니다. 투자 권유 문구나 고지 의무 같은 규정 준수 표현을 매번 프롬프트로 지시하는 대신, 가중치의 기본값으로 만들어 두는 접근입니다. 지시를 잊어서 생기는 사고 한 건의 비용을 생각하면 계산이 서는 자리입니다.

**자기 말투가 자산인 회사도 있습니다.** 브랜드 보이스를 모델에 담고 싶다는 요구는 흔한데, 여기서 순서가 중요합니다. 남의 글을 긁어 학습시키는 길은 저작권 문제로 막혀 있고, 맞는 길은 회사가 이미 가진 자산으로 짓는 것입니다. 사보, 공식 블로그, 상담 기록, 브랜드 가이드라인이 전부 원단입니다. 원문이 적어도 방법이 있습니다. 저희 학습 데이터는 전량 합성이었고, 그 경로가 실제로 동작한다는 것이 이번 공개의 확인 사항 중 하나입니다. 같은 파이프라인에 다른 교재를 넣으면 다른 회사의 모델이 나옵니다.

**공공 부문은 조건이 가장 잘 맞습니다.** 우편 업무 특화 모델을 추진하는 우체국물류지원단처럼, 폐쇄망 안에서 도는 자체 모델 수요가 확산되고 있습니다. 공공 문서는 저작권 부담이 가장 낮은 원단이고, 필요한 방향도 뚜렷합니다. 규정 문서의 말투를 그대로 민원 답변에 내보내는 대신, 쉬운 한국어로 답하는 기본값을 가중치에 담는 것입니다.

![humanko-who-needs-this 슬라이드 3](/assets/images/humanko-who-needs-this-slide-03.webp)

## 왜 지금인가

금융권을 막고 있던 문이 열리는 중입니다. 13년 만에 망분리 규제가 단계적으로 풀리고 있고, 당국은 생성형 인공지능에 대한 예외 적용을 추진하겠다고 밝혔습니다. 다만 완화가 완성되기 전까지 현실의 수요는 내부망 안에서 도는 모델이고, 그래서 자기 모델과 폐쇄망 인프라는 당분간 한 몸으로 움직입니다.

저희가 이번 작업을 돌린 방식이 그 조합의 실례입니다. 학습과 병합은 Maxis 경로로, 평가 서빙은 Metis 위에서 돌았고, 같은 구성은 Aegis 온프레미스 환경에도 그대로 올라갑니다. 결국 모델은 업무 자동화의 실행 비용과 품질을 정하는 부품이고, 부품이 몸에 맞을수록 그 위의 자동화 전체가 좋아집니다.

![humanko-who-needs-this 슬라이드 4](/assets/images/humanko-who-needs-this-slide-04.webp)

## 못 믿을 부분

이 글의 한계도 그대로 적습니다. 톰슨의 성능 수치는 자사 발표이고 아직 독립 검증 전입니다. 세그먼트 분석은 공개 보도를 근거로 한 저희의 해석이지, 해당 회사들과의 계약이나 협업 사실이 아닙니다. 그리고 저희가 증명한 것은 말투를 가중치에 담는 축입니다. 톰슨처럼 도메인 지식을 대규모로 주입하는 일은 데이터 규모가 다른 문제이고, 그 축의 실측은 저희도 아직 갖고 있지 않습니다.

원단이 장롱에 있는 회사라면, 이제 견적을 내 볼 때입니다. 재봉 값은 생각보다 쌉니다.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/humanko-who-needs-this/nlm-infographic-2.webp)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## 참고

- [톰슨 로이터 자체 모델 발표 (LawSites)](https://www.lawnext.com/2026/08/thomson-reuters-launches-thomson-its-own-proprietary-llm-trained-on-westlaw-and-practical-law-content.html)
- [발표 비용 구조 (SiliconANGLE)](https://siliconangle.com/2026/08/24/thomson-reuters-launches-proprietary-ai-model-for-legal-work/)
- [Human-KO 가중치 공개 글](https://thakicloud.com/tech-blog/ko/llmops/humanko-27b-release/)
- [Human-KO 비교 측정 글](https://thakicloud.com/tech-blog/ko/llmops/humanko-27b-vs-exaone/)
- [Human-KO 모델 (Hugging Face)](https://huggingface.co/ThakiCloud/Qwen3.8-27B-Human-KO)
- [한화생명 가상대화 훈련 (한화그룹 뉴스룸)](https://www.hanwha.co.kr/newsroom/media_center/news/news_view.do?seq=14095)
- [미래에셋증권 온프레미스 소형 모델 (데이터넷)](https://www.datanet.co.kr/news/articleView.html?idxno=196443)
- [우체국물류지원단 특화 모델 (파이낸셜뉴스)](https://www.fnnews.com/news/202607131447199698)
- [망분리 규제 완화 (이코노믹리뷰)](https://www.econovill.com/news/articleView.html?idxno=742108)
- [생성형 AI 예외 적용 추진 (ZDNet Korea)](https://zdnet.co.kr/view/?no=20260420161504)
