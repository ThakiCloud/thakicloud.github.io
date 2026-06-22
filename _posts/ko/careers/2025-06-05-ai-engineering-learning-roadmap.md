---
title: "AI Engineering Learning Roadmap"
date: 2025-06-05
last_modified_at: 2026-06-20
categories: 
  - careers
  - ai
tags: 
  - ai
  - engineering
  - roadmap
  - learning
author_profile: true
toc: true
toc_label: "AI Engineering Roadmap"
---

AI 엔지니어링을 시작하려는 분들을 위한 학습 로드맵입니다. 순서대로 따라가도 되고, 관심 있는 영역부터 먼저 파도 됩니다.

## 코딩 & ML 기초

### Python

- [Python for Data Science (freeCodeCamp)](https://www.youtube.com/watch?v=LHBE6Q9XlzI)
- 기본 문법과 데이터 구조부터 시작합니다.
- NumPy, Pandas, Matplotlib 같은 데이터 사이언스 라이브러리를 함께 익힙니다.

### Bash

- [Bash Scripting Crash Course](https://linuxconfig.org/bash-scripting-tutorial-for-beginners)
- 기본 쉘 명령어와 스크립팅을 다룹니다.
- 자동화와 시스템 관리에 바로 쓸 수 있습니다.

### TypeScript (선택)

- [TypeScript Handbook](https://www.typescriptlang.org/docs/handbook/intro.html)
- 정적 타입 시스템과 객체지향 프로그래밍을 다룹니다.

### 통계학 & ML 모델 유형

- [Khan Academy - Statistics and Probability](https://www.khanacademy.org/math/statistics-probability)
- [Google's Machine Learning Crash Course](https://developers.google.com/machine-learning/crash-course)
- [The Hundred-Page Machine Learning Book - Andriy Burkov](http://themlbook.com/)

---

## LLM APIs

- [OpenAI Cookbook](https://github.com/openai/openai-cookbook)
- [LangChain Documentation](https://docs.langchain.com/docs/)
- [Anthropic API Guide](https://docs.anthropic.com/)
- [Multi-modal with OpenAI (vision & audio)](https://platform.openai.com/docs/guides/vision)

---

## 모델 적응 (Model Adaptation)

- [Prompt Engineering Guide](https://www.promptingguide.ai/)
- [Hugging Face - Transformers Fine-tuning Course](https://huggingface.co/course/chapter3)
- [Toolformer: Language Models Can Teach Themselves to Use Tools](https://arxiv.org/abs/2302.04761)

---

## 검색을 위한 스토리지

- [Pinecone Docs (Vector DB)](https://docs.pinecone.io/)
- [Weaviate RAG Starter](https://weaviate.io/developers/weaviate)
- [Redis + LangChain Hybrid Retrieval Tutorial](https://python.langchain.com/docs/modules/data_connection/retrievers/hybrid)

---

## RAG & Agentic RAG

- [RAG with LangChain and OpenAI](https://python.langchain.com/docs/use_cases/question_answering/)
- [Haystack RAG Pipeline](https://haystack.deepset.ai/)
- [Meta's original RAG paper](https://arxiv.org/abs/2005.11401)
- [LLM Orchestration with LangGraph](https://www.langchain.com/langgraph)

---

## AI 에이전트

- [LangChain Agents](https://python.langchain.com/docs/modules/agents/)
- [Auto-GPT](https://github.com/Torantulino/Auto-GPT)
- [OpenAgents (OpenAI DevDay Demo)](https://github.com/openai/openagents)
- [ReAct Paper](https://arxiv.org/abs/2210.03629)

---

## 인프라

- [MLOps Zoomcamp (무료)](https://github.com/DataTalksClub/mlops-zoomcamp)
- [Deploy LLM with Kubernetes (by Pinecone)](https://www.pinecone.io/learn/kubernetes/)
- [CI/CD with GitHub Actions](https://docs.github.com/en/actions)

---

## 관측 가능성 & 평가

- [WhyLogs (WhyLabs)](https://whylabs.ai/whylogs)
- [TruLens for LLM Eval](https://www.trulens.org/)
- [LangSmith (by LangChain)](https://docs.langchain.com/docs/guides/debugging/langsmith)

---

## 보안

- [AI Red Teaming Guide (Microsoft)](https://github.com/microsoft/AI-Red-Team)
- [Ethical Considerations from DeepMind](https://www.deepmind.com/ethics)
- [Llama Guard & Prompt Guardrails](https://github.com/meta-llama/llama-guard)

---

## 앞으로의 영역

- [AI Agents for Robotics - Stanford CS327G](https://cs327g.stanford.edu/)
- [Voice Cloning & TTS (coqui.ai)](https://coqui.ai/)
- [CLI AI Agents (Auto-GPT, gpt-engineer)](https://github.com/Significant-Gravitas/Auto-GPT)

---

## 학습 순서 추천

순서는 있지만 강제는 아닙니다. 다만 처음 시작한다면 이 흐름이 무리 없습니다.

1. **코딩 & ML 기초**: Python과 통계학부터 잡습니다. 나머지는 이 위에 쌓입니다.
2. **LLM APIs**: 모델을 직접 쓰는 법을 익힙니다. 결과를 빠르게 볼 수 있어 동기 부여가 됩니다.
3. **모델 적응**: 프롬프트 엔지니어링, 파인튜닝으로 모델을 원하는 방향으로 조정합니다.
4. **스토리지 & RAG**: 데이터를 연결하고 검색 시스템을 붙이는 방법을 익힙니다.
5. **AI 에이전트**: 자율적으로 판단하고 행동하는 에이전트를 설계합니다.
6. **인프라 & 보안**: 실제 서비스로 올리기 전에 필요한 것들입니다.

실습 예제는 직접 구현해보는 게 중요합니다. 읽는 것과 손으로 치는 것은 다릅니다. 관련 커뮤니티에 참여하면 혼자 보이지 않던 것들이 보이기 시작합니다.

---

ThakiCloud의 미션 "AI Compute & Software for Everyone"에 공감한다면, 메일로 바로 문의해주세요.

📧 info@thakicloud.co.kr
