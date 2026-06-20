---
title: "LM Studio + DeepSeek-R1으로 구축하는 실전 Agent 시스템: Smolagents와 AGUIApp 완벽 가이드"
excerpt: "LM Studio에서 DeepSeek-R1 모델을 활용해 웹 스크래핑과 요약 기능을 가진 Agent 시스템을 구축하고, AGUIApp으로 웹 UI까지 제공하는 방법을 단계별로 소개합니다."
date: 2025-06-20
categories:
  - agentops
tags:
  - lm-studio
  - deepseek-r1
  - smolagents
  - agui-app
  - web-scraping
  - local-llm
  - agent-ui
  - python
author_profile: true
toc: true
toc_label: LM Studio Agent Tutorial
published: false
---

## 개요

이 튜토리얼에서는 **LM Studio**에서 **DeepSeek-R1 모델**을 활용해 웹 스크래핑과 텍스트 요약 기능을 가진 실전 Agent 시스템을 구축합니다. **Smolagents**로 Agent 로직을 구현하고, **AGUIApp**으로 사용자 친화적인 웹 인터페이스까지 제공하는 완전한 솔루션을 단계별로 만들어보겠습니다.

### 🎯 학습 목표

- LM Studio 설치 및 DeepSeek-R1 모델 설정
- Smolagents를 활용한 멀티 도구 Agent 구현
- 웹 스크래핑과 LLM 요약을 결합한 실용적 도구 개발
- AGUIApp을 통한 웹 UI 구축
- 로컬 환경에서의 완전한 Agent 시스템 운영

## 1. 환경 설정

### 1.1 LM Studio 설치

**macOS 설치:**

```bash
# Homebrew를 통한 설치
brew install --cask lm-studio

# 또는 공식 웹사이트에서 다운로드
# https://lmstudio.ai/
```

**Windows/Linux:**

1. [LM Studio 공식 사이트](https://lmstudio.ai/)에서 설치 파일 다운로드
2. 설치 후 실행

### 1.2 DeepSeek-R1 모델 다운로드

LM Studio를 실행한 후:

1. **Search** 탭에서 `deepseek-r1-0528-qwen3-8b-mlx` 검색
2. **Download** 버튼 클릭하여 모델 다운로드
3. **Chat** 탭에서 다운로드한 모델 로드
4. **Local Server** 탭에서 서버 시작 (포트: 1234)

### 1.3 Python 환경 설정

```bash
# 가상환경 생성
python -m venv agent_env
source agent_env/bin/activate  # Windows: agent_env\Scripts\activate

# 필수 패키지 설치
pip install smolagents requests beautifulsoup4 lxml
pip install agno ag-ui-protocol
pip install uvicorn fastapi
```

## 2. 핵심 Agent 시스템 구현

### 2.1 프로젝트 구조

```
agent_project/
├── main.py                 # 메인 Agent 로직
├── ui_app.py              # AGUIApp 웹 인터페이스
├── tools/
│   ├── __init__.py
│   ├── scraper.py         # 웹 스크래핑 도구
│   └── summarizer.py      # 텍스트 요약 도구
└── config.py              # 설정 파일
```

### 2.2 설정 파일 (config.py)

```python
# config.py
import os

# LM Studio 서버 설정
LM_STUDIO_BASE_URL = "http://localhost:1234/v1"
LM_STUDIO_API_KEY = "not-needed"
MODEL_ID = "deepseek-r1-0528-qwen3-8b-mlx"

# 스크래핑 대상 사이트 (예시)
TARGET_WEBSITES = {
    "tech_news": "https://techcrunch.com/",
    "ai_research": "https://arxiv.org/list/cs.AI/recent",
    "testing_catalog": "https://www.testingcatalog.com/"
}

# UI 설정
UI_PORT = 8000
UI_HOST = "0.0.0.0"
```

## 3. 도구 구현

### 3.1 웹 스크래핑 도구 (tools/scraper.py)

```python
# tools/scraper.py
import requests
import re
from bs4 import BeautifulSoup
from typing import List, Dict, Optional
from smolagents import tool

@tool
def get_latest_articles(
    website: str = "https://www.testingcatalog.com/", 
    n_articles: int = 3
) -> List[Dict]:
    """
    지정된 웹사이트에서 최신 기사를 스크래핑합니다.
    
    Args:
        website: 스크래핑할 웹사이트 URL
        n_articles: 가져올 기사 수 (기본값: 3)
    
    Returns:
        기사 정보가 담긴 딕셔너리 리스트
        - title: 기사 제목
        - url: 기사 URL  
        - content: 기사 본문
        - summary: 간단한 미리보기
    """
    try:
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        
        response = requests.get(website, headers=headers, timeout=15)
        response.raise_for_status()
        
        soup = BeautifulSoup(response.text, "html.parser")
        articles = []
        
        # 일반적인 기사 구조를 찾기 위한 셀렉터들
        article_selectors = [
            "article",
            ".post", 
            ".entry",
            ".article-item",
            "h2 a, h3 a"
        ]
        
        found_articles = []
        for selector in article_selectors:
            found_articles = soup.select(selector)[:n_articles]
            if found_articles:
                break
                
        for element in found_articles:
            try:
                # 링크와 제목 추출
                if element.name == 'a':
                    link_elem = element
                    title = element.get_text(strip=True)
                else:
                    link_elem = element.find('a', href=True)
                    title = link_elem.get_text(strip=True) if link_elem else "제목 없음"
                
                if not link_elem:
                    continue
                    
                url = link_elem.get('href', '')
                if url.startswith('/'):
                    url = website.rstrip('/') + url
                elif not url.startswith('http'):
                    continue
                
                # 기사 본문 가져오기
                article_response = requests.get(url, headers=headers, timeout=10)
                article_soup = BeautifulSoup(article_response.text, "html.parser")
                
                # 본문 추출 시도
                content_selectors = [
                    ".post-content", ".entry-content", ".article-content",
                    ".content", "main", ".main-content"
                ]
                
                content = ""
                for selector in content_selectors:
                    content_elem = article_soup.select_one(selector)
                    if content_elem:
                        content = content_elem.get_text(" ", strip=True)
                        break
                
                if not content:
                    # 모든 p 태그에서 텍스트 추출
                    paragraphs = article_soup.find_all('p')
                    content = " ".join([p.get_text(" ", strip=True) for p in paragraphs])
                
                # 내용이 너무 길면 잘라내기
                content = content[:2000] + "..." if len(content) > 2000 else content
                summary = content[:200] + "..." if len(content) > 200 else content
                
                articles.append({
                    "title": title,
                    "url": url,
                    "content": content,
                    "summary": summary
                })
                
            except Exception as e:
                print(f"기사 처리 중 오류: {e}")
                continue
                
        return articles[:n_articles]
        
    except Exception as e:
        return [{"error": f"스크래핑 실패: {str(e)}"}]

@tool 
def search_web_content(query: str, max_results: int = 5) -> List[Dict]:
    """
    검색 쿼리를 기반으로 웹 콘텐츠를 검색합니다.
    
    Args:
        query: 검색할 키워드
        max_results: 최대 결과 수
        
    Returns:
        검색 결과 리스트
    """
    # DuckDuckGo 검색 (간단한 구현)
    try:
        search_url = f"https://duckduckgo.com/html/?q={query}"
        headers = {
            'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
        
        response = requests.get(search_url, headers=headers, timeout=10)
        soup = BeautifulSoup(response.text, "html.parser")
        
        results = []
        result_elements = soup.select(".result")[:max_results]
        
        for element in result_elements:
            title_elem = element.select_one(".result__title a")
            snippet_elem = element.select_one(".result__snippet")
            
            if title_elem:
                title = title_elem.get_text(strip=True)
                url = title_elem.get('href', '')
                snippet = snippet_elem.get_text(strip=True) if snippet_elem else ""
                
                results.append({
                    "title": title,
                    "url": url,
                    "snippet": snippet
                })
                
        return results
        
    except Exception as e:
        return [{"error": f"검색 실패: {str(e)}"}]
```

### 3.2 텍스트 요약 도구 (tools/summarizer.py)

{% raw %}
```python
# tools/summarizer.py
from smolagents import tool, OpenAIServerModel
from config import LM_STUDIO_BASE_URL, LM_STUDIO_API_KEY, MODEL_ID

# LLM 모델 인스턴스
model = OpenAIServerModel(
    model_id=MODEL_ID,
    api_base=LM_STUDIO_BASE_URL,
    api_key=LM_STUDIO_API_KEY,
)

@tool
def summarize_article(text: str, max_words: int = 150, style: str = "balanced") -> str:
    """
    기사나 텍스트를 요약합니다.
    
    Args:
        text: 요약할 텍스트
        max_words: 최대 단어 수
        style: 요약 스타일 ("concise", "balanced", "detailed")
    
    Returns:
        요약된 텍스트
    """
    if len(text.strip()) < 50:
        return "텍스트가 너무 짧아서 요약할 수 없습니다."
    
    style_prompts = {
        "concise": "핵심 포인트만 간단명료하게",
        "balanced": "주요 내용을 균형있게", 
        "detailed": "중요한 세부사항을 포함하여 상세하게"
    }
    
    style_instruction = style_prompts.get(style, style_prompts["balanced"])
    
    prompt = f"""다음 텍스트를 {style_instruction} {max_words}단어 이내로 한국어로 요약해주세요.

텍스트:
{text}

요약:"""
    
    try:
        response = model(
            [{"role": "user", "content": [{"type": "text", "text": prompt}]}],
            stop_sequences=["\n\n", "---"],
            max_tokens=300
        )
        
        summary = response.content.strip()
        return summary if summary else "요약을 생성할 수 없습니다."
        
    except Exception as e:
        return f"요약 중 오류가 발생했습니다: {str(e)}"

@tool
def analyze_sentiment(text: str) -> Dict:
    """
    텍스트의 감정을 분석합니다.
    
    Args:
        text: 분석할 텍스트
        
    Returns:
        감정 분석 결과 딕셔너리
    """
    prompt = f"""다음 텍스트의 감정을 분석하고 JSON 형식으로 답변해주세요:

텍스트: {text}

답변 형식:
`
    "sentiment": "positive/negative/neutral",
    "confidence": 0.95,
    "keywords": ["키워드1", "키워드2"],
    "explanation": "분석 근거"
`
"""
    
    try:
        response = model(
            [{"role": "user", "content": [{"type": "text", "text": prompt}]}],
            max_tokens=200
        )
        
        # JSON 파싱 시도
        import json
        result = json.loads(response.content.strip())
        return result
        
    except Exception as e:
        return {
            "sentiment": "neutral",
            "confidence": 0.0,
            "keywords": [],
            "explanation": f"분석 실패: {str(e)}"
        }

@tool
def extract_keywords(text: str, max_keywords: int = 10) -> List[str]:
    """
    텍스트에서 키워드를 추출합니다.
    
    Args:
        text: 키워드를 추출할 텍스트
        max_keywords: 최대 키워드 수
        
    Returns:
        키워드 리스트
    """
    prompt = f"""다음 텍스트에서 가장 중요한 키워드 {max_keywords}개를 추출해주세요. JSON 배열 형태로 답변해주세요.

텍스트: {text}

답변 형식: ["키워드1", "키워드2", ...]
"""
    
    try:
        response = model(
            [{"role": "user", "content": [{"type": "text", "text": prompt}]}],
            max_tokens=150
        )
        
        import json
        keywords = json.loads(response.content.strip())
        return keywords if isinstance(keywords, list) else []
        
    except Exception as e:
        # 간단한 키워드 추출 폴백
        import re
        words = re.findall(r'\b[가-힣a-zA-Z]{2,}\b', text)
        return list(set(words))[:max_keywords]
```
{% endraw %}

## 4. 메인 Agent 시스템 (main.py)

```python
# main.py
import json
from smolagents import CodeAgent, OpenAIServerModel
from tools.scraper import get_latest_articles, search_web_content  
from tools.summarizer import summarize_article, analyze_sentiment, extract_keywords
from config import LM_STUDIO_BASE_URL, LM_STUDIO_API_KEY, MODEL_ID

class NewsAnalysisAgent:
    def __init__(self):
        """뉴스 분석 Agent 초기화"""
        self.model = OpenAIServerModel(
            model_id=MODEL_ID,
            api_base=LM_STUDIO_BASE_URL, 
            api_key=LM_STUDIO_API_KEY,
        )
        
        self.agent = CodeAgent(
            name="NewsAnalysisAgent",
            model=self.model,
            tools=[
                get_latest_articles,
                search_web_content, 
                summarize_article,
                analyze_sentiment,
                extract_keywords
            ],
            max_steps=15,
            verbose=True
        )
    
    def analyze_website_news(self, website_url: str, num_articles: int = 3) -> str:
        """웹사이트의 뉴스를 분석합니다."""
        task = f"""
다음 작업을 순서대로 수행해주세요:

1. get_latest_articles 도구를 사용해 '{website_url}'에서 최신 기사 {num_articles}개를 가져오세요.
2. 각 기사에 대해:
   - summarize_article 도구로 요약을 생성하세요
   - analyze_sentiment 도구로 감정을 분석하세요  
   - extract_keywords 도구로 키워드를 추출하세요
3. 모든 분석 결과를 마크다운 형식으로 정리해서 final_answer로 반환하세요.

마크다운 형식:
# 뉴스 분석 결과

## 기사 1: [제목]
- **URL**: [링크]
- **요약**: [요약 내용]
- **감정**: [감정 분석 결과]
- **키워드**: [키워드 리스트]

(다른 기사들도 동일한 형식으로...)

## 전체 분석 요약
- 주요 트렌드
- 전반적인 감정
- 공통 키워드
        """
        
        return self.agent.run(task)
    
    def search_and_analyze(self, query: str, max_results: int = 3) -> str:
        """검색하고 결과를 분석합니다."""
        task = f"""
다음 작업을 수행해주세요:

1. search_web_content 도구를 사용해 '{query}' 키워드로 검색하고 {max_results}개 결과를 가져오세요.
2. 각 검색 결과에 대해 감정 분석과 키워드 추출을 수행하세요.
3. 결과를 마크다운으로 정리해서 반환하세요.
        """
        
        return self.agent.run(task)

def main():
    """메인 실행 함수"""
    print("🤖 뉴스 분석 Agent를 시작합니다...")
    print("📡 LM Studio 서버 연결을 확인해주세요 (http://localhost:1234)")
    
    agent = NewsAnalysisAgent()
    
    while True:
        print("\n" + "="*50)
        print("1. 웹사이트 뉴스 분석")
        print("2. 키워드 검색 및 분석") 
        print("3. 종료")
        print("="*50)
        
        choice = input("선택하세요 (1-3): ").strip()
        
        if choice == "1":
            url = input("분석할 웹사이트 URL을 입력하세요: ").strip()
            if not url:
                url = "https://www.testingcatalog.com/"
            
            num_articles = input("분석할 기사 수 (기본값: 3): ").strip()
            num_articles = int(num_articles) if num_articles.isdigit() else 3
            
            print(f"\n🔍 {url}에서 최신 기사 {num_articles}개를 분석 중...")
            result = agent.analyze_website_news(url, num_articles)
            print("\n" + "="*70)
            print(result)
            print("="*70)
            
        elif choice == "2":
            query = input("검색할 키워드를 입력하세요: ").strip()
            if not query:
                print("키워드를 입력해주세요.")
                continue
                
            max_results = input("검색할 결과 수 (기본값: 3): ").strip()
            max_results = int(max_results) if max_results.isdigit() else 3
            
            print(f"\n🔍 '{query}' 키워드로 검색 중...")
            result = agent.search_and_analyze(query, max_results)
            print("\n" + "="*70)
            print(result)
            print("="*70)
            
        elif choice == "3":
            print("👋 프로그램을 종료합니다.")
            break
            
        else:
            print("❌ 잘못된 선택입니다. 1-3 중에서 선택해주세요.")

if __name__ == "__main__":
    main()
```

## 5. 웹 UI 구현 (ui_app.py)

### 5.1 AGUIApp 기반 웹 인터페이스

```python
# ui_app.py
import asyncio
from typing import Optional
from agno.agent.agent import Agent
from agno.app.agui.app import AGUIApp
from agno.models.openai import OpenAIChat
from smolagents import OpenAIServerModel
from tools.scraper import get_latest_articles, search_web_content
from tools.summarizer import summarize_article, analyze_sentiment, extract_keywords
from config import LM_STUDIO_BASE_URL, LM_STUDIO_API_KEY, MODEL_ID, UI_PORT, UI_HOST

class NewsAnalysisWebAgent:
    def __init__(self):
        """웹 기반 뉴스 분석 Agent"""
        # LM Studio 모델 설정
        self.model = OpenAIChat(
            id=MODEL_ID,
            api_base=LM_STUDIO_BASE_URL,
            api_key=LM_STUDIO_API_KEY
        )
        
        # Agno Agent 생성
        self.agent = Agent(
            name="NewsAnalysisWebAgent",
            model=self.model,
            instructions="""
당신은 뉴스 분석 전문가입니다. 다음 기능을 제공합니다:

1. **웹사이트 뉴스 분석**: 특정 웹사이트에서 최신 뉴스를 가져와 분석
2. **키워드 검색**: 검색 키워드로 관련 뉴스 찾기 및 분석  
3. **텍스트 요약**: 긴 텍스트를 간결하게 요약
4. **감정 분석**: 텍스트의 감정(긍정/부정/중립) 분석
5. **키워드 추출**: 텍스트에서 중요한 키워드 추출

사용자의 요청에 따라 적절한 분석을 수행하고 결과를 마크다운 형식으로 제공하세요.
            """,
            add_datetime_to_instructions=True,
            markdown=True,
        )

    async def analyze_website(self, website_url: str, num_articles: int = 3) -> str:
        """웹사이트 뉴스 분석"""
        try:
            # 뉴스 가져오기
            articles = get_latest_articles(website_url, num_articles)
            
            if not articles or (len(articles) == 1 and "error" in articles[0]):
                return f"❌ 웹사이트에서 뉴스를 가져올 수 없습니다: {website_url}"
            
            analysis_results = []
            
            for i, article in enumerate(articles, 1):
                if "error" in article:
                    continue
                    
                # 각 기사 분석
                summary = summarize_article(article["content"], max_words=100)
                sentiment = analyze_sentiment(article["content"])
                keywords = extract_keywords(article["content"], max_keywords=5)
                
                analysis_results.append({
                    "title": article["title"],
                    "url": article["url"],
                    "summary": summary,
                    "sentiment": sentiment,
                    "keywords": keywords
                })
            
            # 결과 포맷팅
            result = f"# 🔍 뉴스 분석 결과\n\n**분석 웹사이트**: {website_url}\n**분석 기사 수**: {len(analysis_results)}개\n\n"
            
            for i, analysis in enumerate(analysis_results, 1):
                result += f"## 📰 기사 {i}: {analysis['title']}\n\n"
                result += f"**🔗 URL**: [{analysis['url']}]({analysis['url']})\n\n"
                result += f"**📝 요약**: {analysis['summary']}\n\n"
                result += f"**😊 감정**: {analysis['sentiment'].get('sentiment', 'unknown')} "
                result += f"(신뢰도: {analysis['sentiment'].get('confidence', 0):.2f})\n\n"
                result += f"**🏷️ 키워드**: {', '.join(analysis['keywords'])}\n\n"
                result += "---\n\n"
            
            # 전체 요약
            all_keywords = []
            sentiments = []
            for analysis in analysis_results:
                all_keywords.extend(analysis['keywords'])
                sentiments.append(analysis['sentiment'].get('sentiment', 'neutral'))
            
            common_keywords = list(set(all_keywords))[:10]
            positive_count = sentiments.count('positive')
            negative_count = sentiments.count('negative')
            neutral_count = sentiments.count('neutral')
            
            result += "## 📊 전체 분석 요약\n\n"
            result += f"**주요 키워드**: {', '.join(common_keywords[:8])}\n\n"
            result += f"**감정 분포**: 긍정 {positive_count}개, 부정 {negative_count}개, 중립 {neutral_count}개\n\n"
            
            return result
            
        except Exception as e:
            return f"❌ 분석 중 오류가 발생했습니다: {str(e)}"

    async def search_and_analyze(self, query: str, max_results: int = 3) -> str:
        """검색 및 분석"""
        try:
            # 검색 수행
            search_results = search_web_content(query, max_results)
            
            if not search_results or (len(search_results) == 1 and "error" in search_results[0]):
                return f"❌ '{query}' 검색 결과가 없습니다."
            
            result = f"# 🔍 검색 분석 결과\n\n**검색 키워드**: {query}\n**검색 결과**: {len(search_results)}개\n\n"
            
            for i, item in enumerate(search_results, 1):
                if "error" in item:
                    continue
                    
                # 감정 분석 및 키워드 추출
                sentiment = analyze_sentiment(item.get("snippet", ""))
                keywords = extract_keywords(item.get("snippet", ""), max_keywords=3)
                
                result += f"## 🔗 결과 {i}: {item.get('title', '제목 없음')}\n\n"
                result += f"**URL**: [{item.get('url', '')}]({item.get('url', '')})\n\n"
                result += f"**스니펫**: {item.get('snippet', '')}\n\n"
                result += f"**감정**: {sentiment.get('sentiment', 'unknown')}\n\n"
                result += f"**키워드**: {', '.join(keywords)}\n\n"
                result += "---\n\n"
            
            return result
            
        except Exception as e:
            return f"❌ 검색 중 오류가 발생했습니다: {str(e)}"

# AGUI 앱 생성
def create_agui_app():
    """AGUI 앱 생성"""
    news_agent = NewsAnalysisWebAgent()
    
    # AGUI 앱 설정
    agui_app = AGUIApp(
        agent=news_agent.agent,
        name="🤖 뉴스 분석 Agent",
        app_id="news_analysis_agent",
        description="웹사이트 뉴스 분석, 검색, 요약, 감정 분석을 제공하는 AI Agent",
        host=UI_HOST,
        port=UI_PORT
    )
    
    return agui_app

def main():
    """웹 UI 실행"""
    print("🚀 뉴스 분석 Agent 웹 UI를 시작합니다...")
    print(f"📡 LM Studio 서버가 {LM_STUDIO_BASE_URL}에서 실행 중인지 확인하세요")
    print(f"🌐 웹 UI: http://{UI_HOST}:{UI_PORT}")
    
    app = create_agui_app()
    app.serve(reload=True)

if __name__ == "__main__":
    main()
```

## 6. 실행 및 테스트

### 6.1 단계별 실행

**1단계: LM Studio 서버 확인**

```bash
# LM Studio에서 DeepSeek-R1 모델이 로드되어 있는지 확인
curl http://localhost:1234/v1/models
```

**2단계: CLI 버전 실행**

```bash
# 가상환경 활성화
source agent_env/bin/activate

# CLI 버전 실행
python main.py
```

**3단계: 웹 UI 실행**

```bash
# 웹 UI 실행 (별도 터미널)
python ui_app.py
```

### 6.2 사용 예시

**CLI에서 뉴스 분석:**

```
선택하세요 (1-3): 1
분석할 웹사이트 URL을 입력하세요: https://techcrunch.com
분석할 기사 수 (기본값: 3): 5
```

**웹 UI에서 사용:**

```
웹사이트 https://www.testingcatalog.com/ 에서 최신 뉴스 3개를 분석해줘
```

## 7. 고급 기능 확장

### 7.1 스케줄링 기능 추가

```python
# scheduler.py
import schedule
import time
import json
from datetime import datetime
from main import NewsAnalysisAgent

class NewsScheduler:
    def __init__(self):
        self.agent = NewsAnalysisAgent()
        self.monitored_sites = [
            "https://techcrunch.com/",
            "https://www.testingcatalog.com/",
            "https://arxiv.org/list/cs.AI/recent"
        ]
    
    def daily_analysis(self):
        """일일 뉴스 분석"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        print(f"📅 일일 뉴스 분석 시작: {timestamp}")
        
        results = {}
        for site in self.monitored_sites:
            try:
                result = self.agent.analyze_website_news(site, 2)
                results[site] = result
                print(f"✅ {site} 분석 완료")
            except Exception as e:
                print(f"❌ {site} 분석 실패: {e}")
                results[site] = f"분석 실패: {e}"
        
        # 결과 저장
        filename = f"daily_analysis_{datetime.now().strftime('%Y%m%d')}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"📄 결과 저장: {filename}")

    def start_scheduler(self):
        """스케줄러 시작"""
        # 매일 오전 9시에 분석 실행
        schedule.every().day.at("09:00").do(self.daily_analysis)
        
        print("⏰ 스케줄러 시작 - 매일 오전 9시에 뉴스 분석")
        while True:
            schedule.run_pending()
            time.sleep(60)

if __name__ == "__main__":
    scheduler = NewsScheduler()
    scheduler.start_scheduler()
```

### 7.2 데이터베이스 연동

```python
# database.py
import sqlite3
import json
from datetime import datetime
from typing import List, Dict

class NewsDatabase:
    def __init__(self, db_path: str = "news_analysis.db"):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        """데이터베이스 초기화"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS articles (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                title TEXT NOT NULL,
                url TEXT UNIQUE NOT NULL,
                content TEXT,
                summary TEXT,
                sentiment TEXT,
                keywords TEXT,
                source_website TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS analysis_logs (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                website TEXT NOT NULL,
                analysis_type TEXT NOT NULL,
                result TEXT,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
        """)
        
        conn.commit()
        conn.close()
    
    def save_article(self, article_data: Dict):
        """기사 데이터 저장"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        try:
            cursor.execute("""
                INSERT OR REPLACE INTO articles 
                (title, url, content, summary, sentiment, keywords, source_website)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            """, (
                article_data.get('title'),
                article_data.get('url'),
                article_data.get('content'),
                article_data.get('summary'),
                json.dumps(article_data.get('sentiment', {})),
                json.dumps(article_data.get('keywords', [])),
                article_data.get('source_website')
            ))
            conn.commit()
        finally:
            conn.close()
    
    def get_recent_articles(self, limit: int = 10) -> List[Dict]:
        """최근 기사 조회"""
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT title, url, summary, sentiment, keywords, created_at
            FROM articles 
            ORDER BY created_at DESC 
            LIMIT ?
        """, (limit,))
        
        results = []
        for row in cursor.fetchall():
            results.append({
                'title': row[0],
                'url': row[1], 
                'summary': row[2],
                'sentiment': json.loads(row[3]) if row[3] else {},
                'keywords': json.loads(row[4]) if row[4] else [],
                'created_at': row[5]
            })
        
        conn.close()
        return results
```

## 8. 트러블슈팅

### 8.1 일반적인 문제와 해결책

**문제 1: LM Studio 연결 실패**

```bash
# 해결 방법
1. LM Studio가 실행 중인지 확인
2. 로컬 서버가 포트 1234에서 실행 중인지 확인
3. 모델이 올바르게 로드되었는지 확인

# 연결 테스트
curl -X POST http://localhost:1234/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"model": "deepseek-r1-0528-qwen3-8b-mlx", "messages": [{"role": "user", "content": "Hello"}]}'
```

**문제 2: 웹 스크래핑 실패**

```python
# 해결 방법: 더 견고한 스크래핑 로직
def robust_scraping(url):
    try:
        # User-Agent 설정
        headers = {
            'User-Agent': 'Mozilla/5.0 (compatible; NewsBot/1.0)'
        }
        response = requests.get(url, headers=headers, timeout=15)
        return response
    except requests.exceptions.RequestException as e:
        print(f"스크래핑 오류: {e}")
        return None
```

**문제 3: 메모리 부족**

```python
# 해결 방법: 배치 처리 및 메모리 관리
def process_articles_in_batches(articles, batch_size=2):
    for i in range(0, len(articles), batch_size):
        batch = articles[i:i+batch_size]
        yield batch
```

### 8.2 성능 최적화

**비동기 처리:**

```python
import asyncio
import aiohttp

async def async_scrape_articles(urls):
    async with aiohttp.ClientSession() as session:
        tasks = [scrape_single_article(session, url) for url in urls]
        return await asyncio.gather(*tasks)
```

**캐싱 구현:**

```python
from functools import lru_cache
import hashlib

@lru_cache(maxsize=100)
def cached_summarize(text_hash, text):
    return summarize_article(text)

def get_text_hash(text):
    return hashlib.md5(text.encode()).hexdigest()
```

## 9. 결론 및 확장 방향

### 9.1 구축한 시스템의 가치

이 튜토리얼을 통해 구축한 시스템의 주요 특징:

- **완전한 로컬 환경**: 외부 API 의존성 없이 LM Studio에서 실행
- **실용적인 기능**: 웹 스크래핑, 요약, 감정 분석, 키워드 추출
- **사용자 친화적 인터페이스**: CLI와 웹 UI 모두 제공
- **확장 가능한 아키텍처**: 새로운 도구와 기능을 쉽게 추가

### 9.2 향후 확장 계획

**멀티모달 기능 추가:**

- 이미지 분석 및 OCR
- 음성 인식 및 TTS
- PDF/문서 처리

**고급 분석 기능:**

- 트렌드 분석 및 예측
- 다국어 지원
- 실시간 모니터링 대시보드

**엔터프라이즈 기능:**

- 사용자 권한 관리
- API 키 관리
- 상세한 로깅 및 감사

### 9.3 최종 권장사항

1. **점진적 확장**: 기본 기능부터 시작해서 필요에 따라 확장
2. **안정성 우선**: 에러 핸들링과 폴백 메커니즘 구현
3. **사용자 피드백**: 실제 사용자의 피드백을 바탕으로 개선
4. **보안 고려**: 웹 스크래핑 시 Rate Limiting 및 Robot.txt 준수

이 시스템을 기반으로 더욱 정교하고 실용적인 AI Agent 솔루션을 구축하시길 바랍니다.

---

*이 튜토리얼의 전체 소스코드는 [GitHub](https://github.com/your-repo/lmstudio-agent-tutorial)에서 확인하실 수 있습니다.*

```

이 글은 너무 길어서 계속해서 UI 부분과 마지막 부분을 추가로 작성하겠습니다.
