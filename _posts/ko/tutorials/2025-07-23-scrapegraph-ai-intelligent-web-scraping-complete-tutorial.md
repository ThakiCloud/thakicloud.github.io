---
title: "ScrapeGraphAI 완전 가이드: AI 기반 지능형 웹 스크래핑으로 데이터 수집 혁신하기"
excerpt: "LLM을 활용한 혁신적인 웹 스크래핑 라이브러리 ScrapeGraphAI로 복잡한 웹사이트에서 정확한 데이터를 추출하는 방법을 단계별로 학습하는 완전한 실전 가이드"
seo_title: "ScrapeGraphAI AI 웹 스크래핑 튜토리얼 - LLM 기반 데이터 추출 완전 가이드 - Thaki Cloud"
seo_description: "ScrapeGraphAI를 사용한 AI 기반 웹 스크래핑 방법을 실전 예제와 함께 상세히 알아보세요. OpenAI, Ollama 연동부터 고급 파이프라인까지 포함된 완전한 가이드입니다."
date: 2025-07-23
last_modified_at: 2025-07-23
categories:
  - tutorials
  - dev
tags:
  - ScrapeGraphAI
  - AI스크래핑
  - 웹크롤링
  - LLM데이터추출
  - Python스크래핑
  - OpenAI
  - Ollama
  - 자동화
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/scrapegraph-ai-intelligent-web-scraping-complete-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 18분

## 서론

전통적인 웹 스크래핑은 CSS 선택자나 XPath를 수동으로 작성하고 웹사이트 구조 변경에 대응하기 어려운 문제가 있었습니다. 하지만 이제 AI의 시대가 왔습니다. [ScrapeGraphAI](https://github.com/ScrapeGraphAI/Scrapegraph-ai)는 대규모 언어 모델(LLM)을 활용하여 자연어 프롬프트만으로 웹사이트에서 원하는 정보를 정확하게 추출할 수 있는 혁신적인 Python 라이브러리입니다.

이 튜토리얼에서는 ScrapeGraphAI의 핵심 기능부터 고급 활용법까지, 실무에서 바로 적용할 수 있는 완전한 가이드를 제공합니다. 20.5k 스타를 받으며 급성장하고 있는 이 도구로 데이터 수집의 새로운 패러다임을 경험해보세요.

## ScrapeGraphAI 개요

### 핵심 특징

**🤖 AI 기반 스크래핑**: CSS 선택자 대신 자연어로 스크래핑 로직 정의  
**🔄 적응형 파싱**: 웹사이트 구조 변경에 자동 적응  
**🎯 정확한 추출**: LLM의 컨텍스트 이해 능력으로 높은 정확도  
**🌐 다양한 소스**: 웹페이지, 로컬 파일, API 응답 처리  
**🔧 유연한 설정**: 다양한 LLM 모델과 설정 지원

### 지원 기능

```yaml
features:
  scraping_types:
    - single_page: "SmartScraperGraph"
    - multi_page: "SmartScraperMultiGraph"
    - search_results: "SearchGraph"
    - script_generation: "ScriptCreatorGraph"
    - audio_generation: "SpeechGraph"
  
  llm_support:
    - cloud: ["OpenAI", "Google Gemini", "Anthropic Claude", "Groq"]
    - local: ["Ollama", "Hugging Face"]
    - azure: ["Azure OpenAI"]
  
  integrations:
    - apis: "Official REST API"
    - sdks: ["Python SDK", "Node.js SDK"]
    - frameworks: ["LangChain", "LlamaIndex", "CrewAI"]
    - no_code: ["Zapier", "n8n", "Pipedream"]
```

## 환경 설정

### 1. 기본 설치

```bash
# 가상환경 생성 (권장)
python -m venv scrapegraph_env
source scrapegraph_env/bin/activate  # Windows: scrapegraph_env\Scripts\activate

# ScrapeGraphAI 설치
pip install scrapegraphai

# 브라우저 엔진 설치 (웹사이트 콘텐츠 가져오기용)
playwright install

# 추가 의존성 (필요시)
pip install torch torchvision torchaudio  # 로컬 모델용
pip install ollama  # Ollama 사용시
```

### 2. 환경 변수 설정

```bash
# .env 파일 생성
cat > .env << EOF
# OpenAI 설정
OPENAI_API_KEY="your_openai_api_key"

# Google Gemini 설정
GOOGLE_API_KEY="your_google_api_key"

# Groq 설정
GROQ_API_KEY="your_groq_api_key"

# Azure OpenAI 설정
AZURE_OPENAI_ENDPOINT="https://your-resource.openai.azure.com/"
AZURE_OPENAI_API_KEY="your_azure_api_key"
AZURE_OPENAI_API_VERSION="2023-05-15"

# 프록시 설정 (필요시)
HTTP_PROXY="http://proxy.company.com:8080"
HTTPS_PROXY="http://proxy.company.com:8080"
EOF
```

### 3. Ollama 로컬 모델 설정

```bash
# Ollama 설치 (macOS)
brew install ollama

# Ollama 서비스 시작
ollama serve

# 모델 다운로드
ollama pull llama3.2        # 8B 모델
ollama pull llama3.2:70b    # 70B 모델 (더 정확하지만 느림)
ollama pull codellama       # 코드 생성 특화
ollama pull mistral         # 경량 모델

# 설치된 모델 확인
ollama list
```

## 기본 사용법

### 1. SmartScraperGraph 기본 예제

```python
# basic_scraping.py
import json
from scrapegraphai.graphs import SmartScraperGraph

def basic_scraping_example():
    """기본 스크래핑 예제"""
    
    # Ollama를 사용한 설정
    graph_config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192,
            "base_url": "http://localhost:11434"
        },
        "verbose": True,
        "headless": True,  # 브라우저 창 숨김
    }
    
    # 스크래퍼 인스턴스 생성
    smart_scraper = SmartScraperGraph(
        prompt="회사 소개, 창립자 정보, 소셜 미디어 링크를 추출해주세요",
        source="https://scrapegraphai.com/",
        config=graph_config
    )
    
    # 스크래핑 실행
    result = smart_scraper.run()
    
    print(json.dumps(result, indent=2, ensure_ascii=False))
    return result

if __name__ == "__main__":
    basic_scraping_example()
```

### 2. 다양한 LLM 설정 예제

```python
# llm_configurations.py
from scrapegraphai.graphs import SmartScraperGraph

class LLMConfigurations:
    @staticmethod
    def openai_config():
        """OpenAI GPT 설정"""
        return {
            "llm": {
                "api_key": "your_openai_api_key",
                "model": "openai/gpt-4o-mini",
                "temperature": 0.1,
                "max_tokens": 2048
            },
            "verbose": True,
            "headless": True
        }
    
    @staticmethod
    def groq_config():
        """Groq 설정 (빠른 추론)"""
        return {
            "llm": {
                "api_key": "your_groq_api_key",
                "model": "groq/llama-3.1-70b-versatile",
                "temperature": 0
            },
            "verbose": True,
            "headless": True
        }
    
    @staticmethod
    def gemini_config():
        """Google Gemini 설정"""
        return {
            "llm": {
                "api_key": "your_google_api_key",
                "model": "google/gemini-1.5-flash",
                "temperature": 0.1
            },
            "verbose": True,
            "headless": True
        }
    
    @staticmethod
    def ollama_config(model_name="llama3.2"):
        """Ollama 로컬 모델 설정"""
        return {
            "llm": {
                "model": f"ollama/{model_name}",
                "model_tokens": 8192,
                "base_url": "http://localhost:11434"
            },
            "verbose": True,
            "headless": True,
            "loader_kwargs": {
                "requests_per_second": 1,  # 요청 제한
                "load_timeout": 30
            }
        }

def test_different_llms():
    """다양한 LLM 테스트"""
    configs = LLMConfigurations()
    
    test_cases = [
        ("Ollama", configs.ollama_config()),
        ("OpenAI", configs.openai_config()),
        ("Groq", configs.groq_config()),
        ("Gemini", configs.gemini_config())
    ]
    
    prompt = "이 웹사이트의 주요 제품이나 서비스를 3개 이내로 요약해주세요"
    url = "https://openai.com"
    
    for name, config in test_cases:
        try:
            print(f"\n=== {name} 테스트 ===")
            scraper = SmartScraperGraph(
                prompt=prompt,
                source=url,
                config=config
            )
            result = scraper.run()
            print(f"결과: {result}")
        except Exception as e:
            print(f"{name} 오류: {e}")

if __name__ == "__main__":
    test_different_llms()
```

## 고급 스크래핑 파이프라인

### 1. MultiGraph로 여러 페이지 처리

```python
# multi_page_scraping.py
import json
from scrapegraphai.graphs import SmartScraperMultiGraph

def multi_page_scraping():
    """여러 페이지에서 일관된 정보 추출"""
    
    graph_config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True,
        "max_concurrent": 3  # 동시 처리 페이지 수
    }
    
    # AI 관련 기업들의 정보 수집
    sources = [
        "https://openai.com",
        "https://anthropic.com", 
        "https://huggingface.co",
        "https://cohere.ai",
        "https://stability.ai"
    ]
    
    # 통일된 프롬프트로 정보 추출
    prompt = """
    다음 정보를 JSON 형태로 추출해주세요:
    - company_name: 회사명
    - main_product: 주요 제품/서비스
    - founded_year: 설립연도 (가능한 경우)
    - headquarters: 본사 위치
    - key_technology: 핵심 기술
    """
    
    multi_scraper = SmartScraperMultiGraph(
        prompt=prompt,
        source=sources,
        config=graph_config
    )
    
    results = multi_scraper.run()
    
    # 결과 정리 및 저장
    formatted_results = []
    for i, result in enumerate(results):
        formatted_results.append({
            "url": sources[i],
            "data": result
        })
    
    # JSON 파일로 저장
    with open("ai_companies_data.json", "w", encoding="utf-8") as f:
        json.dump(formatted_results, f, indent=2, ensure_ascii=False)
    
    print("다중 페이지 스크래핑 완료. 결과: ai_companies_data.json")
    return formatted_results

if __name__ == "__main__":
    multi_page_scraping()
```

### 2. SearchGraph로 검색 결과 처리

```python
# search_scraping.py
from scrapegraphai.graphs import SearchGraph

def search_based_scraping():
    """검색 결과 기반 정보 수집"""
    
    graph_config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True,
        "max_results": 5  # 상위 5개 검색 결과만 처리
    }
    
    # 검색 기반 스크래핑
    search_scraper = SearchGraph(
        prompt="""
        최신 AI 트렌드와 관련된 다음 정보를 추출해주세요:
        - trend_name: 트렌드 이름
        - description: 간단한 설명
        - key_companies: 관련 주요 기업들
        - impact_level: 영향도 (High/Medium/Low)
        """,
        config=graph_config
    )
    
    # 검색어로 스크래핑 실행
    search_query = "AI trends 2024 artificial intelligence latest"
    results = search_scraper.run(search_query)
    
    print(json.dumps(results, indent=2, ensure_ascii=False))
    return results

def news_monitoring():
    """뉴스 모니터링 예제"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True,
        "max_results": 3
    }
    
    news_scraper = SearchGraph(
        prompt="""
        뉴스 기사에서 다음 정보를 추출해주세요:
        - headline: 제목
        - summary: 3줄 요약
        - date: 발행일
        - sentiment: 긍정/부정/중립
        - key_points: 핵심 포인트 3개
        """,
        config=config
    )
    
    search_queries = [
        "OpenAI GPT-5 news latest",
        "Google Gemini updates 2024",
        "Claude AI Anthropic developments"
    ]
    
    all_results = {}
    for query in search_queries:
        print(f"\n검색 중: {query}")
        results = news_scraper.run(query)
        all_results[query] = results
    
    return all_results

if __name__ == "__main__":
    print("=== 검색 기반 스크래핑 ===")
    search_based_scraping()
    
    print("\n=== 뉴스 모니터링 ===")
    news_monitoring()
```

### 3. ScriptCreatorGraph로 코드 생성

```python
# script_generator.py
from scrapegraphai.graphs import ScriptCreatorGraph

def generate_scraping_script():
    """스크래핑 스크립트 자동 생성"""
    
    graph_config = {
        "llm": {
            "model": "ollama/codellama",  # 코드 생성 특화 모델
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True
    }
    
    script_creator = ScriptCreatorGraph(
        prompt="""
        이 웹사이트에서 제품 정보를 스크래핑하는 Python 스크립트를 생성해주세요.
        추출할 정보:
        - 제품명
        - 가격
        - 설명
        - 평점
        - 리뷰 수
        
        BeautifulSoup과 requests를 사용해서 작성해주세요.
        """,
        source="https://example-ecommerce.com/products",
        config=graph_config
    )
    
    generated_script = script_creator.run()
    
    # 생성된 스크립트 저장
    with open("generated_scraper.py", "w", encoding="utf-8") as f:
        f.write(generated_script)
    
    print("스크래핑 스크립트가 generated_scraper.py로 저장되었습니다.")
    print(f"생성된 스크립트:\n{generated_script}")
    
    return generated_script

def generate_multiple_scripts():
    """여러 용도의 스크립트 생성"""
    
    config = {
        "llm": {
            "model": "ollama/codellama",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True
    }
    
    script_requests = [
        {
            "name": "job_scraper",
            "prompt": "채용 정보 사이트에서 직무, 회사명, 연봉, 지역을 추출하는 스크립트",
            "url": "https://jobs.example.com"
        },
        {
            "name": "news_scraper", 
            "prompt": "뉴스 사이트에서 헤드라인, 본문, 작성자, 날짜를 추출하는 스크립트",
            "url": "https://news.example.com"
        },
        {
            "name": "social_scraper",
            "prompt": "소셜 미디어에서 게시물, 좋아요 수, 댓글 수를 추출하는 스크립트",
            "url": "https://social.example.com"
        }
    ]
    
    for request in script_requests:
        try:
            creator = ScriptCreatorGraph(
                prompt=request["prompt"],
                source=request["url"],
                config=config
            )
            
            script = creator.run()
            
            filename = f"{request['name']}.py"
            with open(filename, "w", encoding="utf-8") as f:
                f.write(script)
            
            print(f"✅ {filename} 생성 완료")
            
        except Exception as e:
            print(f"❌ {request['name']} 생성 실패: {e}")

if __name__ == "__main__":
    generate_scraping_script()
    generate_multiple_scripts()
```

## 실전 활용 사례

### 1. 경쟁사 분석 자동화

```python
# competitor_analysis.py
import json
import pandas as pd
from datetime import datetime
from scrapegraphai.graphs import SmartScraperMultiGraph

class CompetitorAnalyzer:
    def __init__(self, config):
        self.config = config
        self.results = []
    
    def analyze_competitors(self, competitor_urls):
        """경쟁사 웹사이트 분석"""
        
        analysis_prompt = """
        이 회사의 다음 정보를 분석해서 JSON 형태로 제공해주세요:
        
        {
            "company_info": {
                "name": "회사명",
                "tagline": "슬로건/태그라인",
                "founding_year": "설립연도",
                "employee_count": "직원 수 (추정)"
            },
            "products_services": [
                {
                    "name": "제품/서비스명",
                    "category": "카테고리",
                    "description": "간단한 설명",
                    "target_market": "타겟 시장"
                }
            ],
            "pricing": {
                "model": "가격 모델 (구독/일회성/프리미엄 등)",
                "starting_price": "시작 가격",
                "enterprise_available": "기업용 플랜 여부"
            },
            "technology": {
                "stack": ["사용 기술 스택"],
                "ai_integration": "AI 기술 활용 여부",
                "api_available": "API 제공 여부"
            },
            "marketing": {
                "value_propositions": ["핵심 가치 제안들"],
                "customer_testimonials": "고객 후기 유무",
                "case_studies": "사례 연구 유무"
            },
            "social_presence": {
                "linkedin": "LinkedIn URL",
                "twitter": "Twitter URL", 
                "github": "GitHub URL",
                "blog": "블로그 URL"
            }
        }
        """
        
        multi_scraper = SmartScraperMultiGraph(
            prompt=analysis_prompt,
            source=competitor_urls,
            config=self.config
        )
        
        results = multi_scraper.run()
        
        # 결과 정리
        for i, result in enumerate(results):
            self.results.append({
                "url": competitor_urls[i],
                "timestamp": datetime.now().isoformat(),
                "analysis": result
            })
        
        return self.results
    
    def save_analysis(self, filename="competitor_analysis.json"):
        """분석 결과 저장"""
        with open(filename, "w", encoding="utf-8") as f:
            json.dump(self.results, f, indent=2, ensure_ascii=False)
        
        print(f"분석 결과가 {filename}에 저장되었습니다.")
    
    def generate_comparison_report(self):
        """비교 리포트 생성"""
        if not self.results:
            print("분석 결과가 없습니다.")
            return
        
        # 비교 데이터 추출
        comparison_data = []
        for result in self.results:
            analysis = result.get("analysis", {})
            company_info = analysis.get("company_info", {})
            pricing = analysis.get("pricing", {})
            
            comparison_data.append({
                "URL": result["url"],
                "회사명": company_info.get("name", "N/A"),
                "슬로건": company_info.get("tagline", "N/A"),
                "설립연도": company_info.get("founding_year", "N/A"),
                "가격모델": pricing.get("model", "N/A"),
                "시작가격": pricing.get("starting_price", "N/A"),
                "AI활용": analysis.get("technology", {}).get("ai_integration", "N/A")
            })
        
        # DataFrame 생성 및 저장
        df = pd.DataFrame(comparison_data)
        df.to_excel("competitor_comparison.xlsx", index=False, engine='openpyxl')
        
        print("비교 리포트가 competitor_comparison.xlsx에 저장되었습니다.")
        print(df.to_string(index=False))

def run_competitor_analysis():
    """경쟁사 분석 실행"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True,
        "max_concurrent": 2
    }
    
    # AI 도구 경쟁사들
    competitors = [
        "https://openai.com",
        "https://anthropic.com",
        "https://cohere.ai",
        "https://huggingface.co",
        "https://replicate.com"
    ]
    
    analyzer = CompetitorAnalyzer(config)
    analyzer.analyze_competitors(competitors)
    analyzer.save_analysis()
    analyzer.generate_comparison_report()

if __name__ == "__main__":
    run_competitor_analysis()
```

### 2. 실시간 뉴스 모니터링

```python
# news_monitor.py
import json
import time
from datetime import datetime, timedelta
from scrapegraphai.graphs import SearchGraph

class NewsMonitor:
    def __init__(self, config):
        self.config = config
        self.monitored_keywords = []
        self.alerts = []
    
    def add_keywords(self, keywords):
        """모니터링할 키워드 추가"""
        self.monitored_keywords.extend(keywords)
    
    def monitor_news(self, interval_minutes=30):
        """뉴스 모니터링 시작"""
        
        news_prompt = """
        뉴스 기사에서 다음 정보를 추출해주세요:
        
        {
            "articles": [
                {
                    "title": "기사 제목",
                    "summary": "3줄 요약",
                    "published_date": "발행일",
                    "source": "출처",
                    "sentiment": "긍정/부정/중립",
                    "importance": "높음/보통/낮음",
                    "key_points": ["핵심 포인트 1", "핵심 포인트 2"],
                    "companies_mentioned": ["언급된 회사들"],
                    "technologies_mentioned": ["언급된 기술들"]
                }
            ],
            "trend_analysis": "전반적인 트렌드 분석"
        }
        """
        
        search_graph = SearchGraph(
            prompt=news_prompt,
            config=self.config
        )
        
        print(f"뉴스 모니터링 시작 (간격: {interval_minutes}분)")
        
        while True:
            try:
                current_time = datetime.now()
                print(f"\n[{current_time}] 뉴스 수집 중...")
                
                for keyword in self.monitored_keywords:
                    # 최근 24시간 뉴스로 검색 쿼리 구성
                    search_query = f"{keyword} news latest 24 hours"
                    results = search_graph.run(search_query)
                    
                    # 중요한 뉴스 필터링
                    important_news = self._filter_important_news(results, keyword)
                    
                    if important_news:
                        self._send_alert(keyword, important_news)
                
                print(f"다음 수집까지 {interval_minutes}분 대기...")
                time.sleep(interval_minutes * 60)
                
            except KeyboardInterrupt:
                print("\n모니터링을 중단합니다.")
                break
            except Exception as e:
                print(f"모니터링 오류: {e}")
                time.sleep(60)  # 오류 시 1분 대기
    
    def _filter_important_news(self, results, keyword):
        """중요한 뉴스 필터링"""
        if not isinstance(results, dict) or 'articles' not in results:
            return []
        
        important_articles = []
        for article in results['articles']:
            # 중요도가 '높음'이거나 부정적 뉴스인 경우
            importance = article.get('importance', '').lower()
            sentiment = article.get('sentiment', '').lower()
            
            if importance == '높음' or sentiment == '부정':
                article['keyword'] = keyword
                article['detected_at'] = datetime.now().isoformat()
                important_articles.append(article)
        
        return important_articles
    
    def _send_alert(self, keyword, articles):
        """알림 발송"""
        alert = {
            "timestamp": datetime.now().isoformat(),
            "keyword": keyword,
            "article_count": len(articles),
            "articles": articles
        }
        
        self.alerts.append(alert)
        
        # 콘솔 알림
        print(f"\n🚨 알림: '{keyword}' 관련 중요 뉴스 {len(articles)}건 발견!")
        for article in articles:
            print(f"  📰 {article['title']}")
            print(f"     중요도: {article['importance']}, 감정: {article['sentiment']}")
        
        # 파일로 저장
        self._save_alerts()
    
    def _save_alerts(self):
        """알림 내역 저장"""
        with open("news_alerts.json", "w", encoding="utf-8") as f:
            json.dump(self.alerts, f, indent=2, ensure_ascii=False)
    
    def get_daily_summary(self):
        """일일 요약 생성"""
        today = datetime.now().date()
        today_alerts = [
            alert for alert in self.alerts 
            if datetime.fromisoformat(alert['timestamp']).date() == today
        ]
        
        if not today_alerts:
            print("오늘 알림이 없습니다.")
            return
        
        print(f"\n📊 {today} 뉴스 요약")
        print("=" * 50)
        
        for alert in today_alerts:
            print(f"키워드: {alert['keyword']}")
            print(f"기사 수: {alert['article_count']}")
            print("-" * 30)

def setup_news_monitoring():
    """뉴스 모니터링 설정"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": False,  # 로그 최소화
        "headless": True,
        "max_results": 5
    }
    
    monitor = NewsMonitor(config)
    
    # 모니터링할 키워드 설정
    ai_keywords = [
        "OpenAI GPT-5",
        "Google Gemini Advanced", 
        "Anthropic Claude",
        "AI regulation",
        "artificial general intelligence AGI"
    ]
    
    monitor.add_keywords(ai_keywords)
    
    try:
        # 30분 간격으로 모니터링
        monitor.monitor_news(interval_minutes=30)
    except KeyboardInterrupt:
        print("\n모니터링을 종료합니다.")
        monitor.get_daily_summary()

if __name__ == "__main__":
    setup_news_monitoring()
```

### 3. 가격 모니터링 시스템

```python
# price_monitor.py
import json
import pandas as pd
from datetime import datetime
from scrapegraphai.graphs import SmartScraperMultiGraph
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class PriceMonitor:
    def __init__(self, config):
        self.config = config
        self.products = []
        self.price_history = []
    
    def add_product(self, name, url, target_price=None):
        """모니터링할 제품 추가"""
        product = {
            "name": name,
            "url": url,
            "target_price": target_price,
            "added_date": datetime.now().isoformat()
        }
        self.products.append(product)
    
    def check_prices(self):
        """가격 확인"""
        
        price_prompt = """
        이 쇼핑몰 상품 페이지에서 다음 정보를 추출해주세요:
        
        {
            "product_name": "상품명",
            "current_price": "현재 가격 (숫자만)",
            "original_price": "정가 (숫자만, 할인 전 가격)",
            "discount_rate": "할인율 (%)",
            "availability": "재고 상태 (재고있음/품절/예약주문)",
            "seller": "판매자",
            "rating": "평점",
            "review_count": "리뷰 수",
            "shipping_cost": "배송비",
            "estimated_delivery": "배송 예상일"
        }
        
        가격은 숫자만 추출해주세요. 통화 기호나 콤마는 제외하고요.
        """
        
        urls = [product["url"] for product in self.products]
        
        multi_scraper = SmartScraperMultiGraph(
            prompt=price_prompt,
            source=urls,
            config=self.config
        )
        
        results = multi_scraper.run()
        
        # 결과 처리
        timestamp = datetime.now().isoformat()
        
        for i, result in enumerate(results):
            product = self.products[i]
            
            price_data = {
                "timestamp": timestamp,
                "product_name": product["name"],
                "url": product["url"],
                "target_price": product["target_price"],
                "scraped_data": result
            }
            
            self.price_history.append(price_data)
            
            # 가격 알림 확인
            self._check_price_alert(product, result)
        
        self._save_price_history()
        return results
    
    def _check_price_alert(self, product, scraped_data):
        """가격 알림 확인"""
        if not product["target_price"]:
            return
        
        current_price_str = scraped_data.get("current_price", "")
        
        try:
            # 문자열에서 숫자만 추출
            current_price = float(''.join(filter(str.isdigit, str(current_price_str))))
            target_price = float(product["target_price"])
            
            if current_price <= target_price:
                self._send_price_alert(product, current_price, scraped_data)
                
        except (ValueError, TypeError):
            print(f"가격 파싱 오류: {current_price_str}")
    
    def _send_price_alert(self, product, current_price, scraped_data):
        """가격 알림 발송"""
        print(f"\n🎯 가격 알림!")
        print(f"상품: {product['name']}")
        print(f"목표 가격: {product['target_price']:,}원")
        print(f"현재 가격: {current_price:,}원")
        print(f"URL: {product['url']}")
        
        # 이메일 알림 (선택사항)
        # self._send_email_alert(product, current_price, scraped_data)
    
    def _send_email_alert(self, product, current_price, scraped_data):
        """이메일 알림 발송"""
        # 이메일 설정 (실제 사용시 환경변수로 관리)
        smtp_server = "smtp.gmail.com"
        smtp_port = 587
        sender_email = "your_email@gmail.com"
        sender_password = "your_app_password"
        recipient_email = "recipient@gmail.com"
        
        try:
            msg = MIMEMultipart()
            msg['From'] = sender_email
            msg['To'] = recipient_email
            msg['Subject'] = f"가격 알림: {product['name']}"
            
            body = f"""
            목표 가격에 도달했습니다!
            
            상품명: {product['name']}
            목표 가격: {product['target_price']:,}원
            현재 가격: {current_price:,}원
            
            상품 페이지: {product['url']}
            
            재고 상태: {scraped_data.get('availability', 'N/A')}
            평점: {scraped_data.get('rating', 'N/A')}
            """
            
            msg.attach(MIMEText(body, 'plain'))
            
            server = smtplib.SMTP(smtp_server, smtp_port)
            server.starttls()
            server.login(sender_email, sender_password)
            server.send_message(msg)
            server.quit()
            
            print("📧 이메일 알림 발송 완료")
            
        except Exception as e:
            print(f"이메일 발송 오류: {e}")
    
    def _save_price_history(self):
        """가격 히스토리 저장"""
        with open("price_history.json", "w", encoding="utf-8") as f:
            json.dump(self.price_history, f, indent=2, ensure_ascii=False)
    
    def generate_price_report(self):
        """가격 리포트 생성"""
        if not self.price_history:
            print("가격 히스토리가 없습니다.")
            return
        
        # 최신 가격 정보만 추출
        latest_prices = {}
        for entry in self.price_history:
            product_name = entry["product_name"]
            if product_name not in latest_prices or entry["timestamp"] > latest_prices[product_name]["timestamp"]:
                latest_prices[product_name] = entry
        
        # 데이터프레임 생성
        report_data = []
        for product_name, entry in latest_prices.items():
            scraped = entry["scraped_data"]
            
            report_data.append({
                "상품명": product_name,
                "현재가격": scraped.get("current_price", "N/A"),
                "정가": scraped.get("original_price", "N/A"),
                "할인율": scraped.get("discount_rate", "N/A"),
                "재고상태": scraped.get("availability", "N/A"),
                "평점": scraped.get("rating", "N/A"),
                "리뷰수": scraped.get("review_count", "N/A"),
                "목표가격": entry["target_price"],
                "확인시각": entry["timestamp"]
            })
        
        df = pd.DataFrame(report_data)
        df.to_excel("price_report.xlsx", index=False, engine='openpyxl')
        
        print("가격 리포트가 price_report.xlsx에 저장되었습니다.")
        print(df.to_string(index=False))

def setup_price_monitoring():
    """가격 모니터링 설정"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True
    }
    
    monitor = PriceMonitor(config)
    
    # 모니터링할 제품들 추가
    products = [
        {
            "name": "MacBook Pro 14인치",
            "url": "https://www.apple.com/kr/macbook-pro-14-and-16/",
            "target_price": 2500000
        },
        {
            "name": "iPhone 15 Pro",
            "url": "https://www.apple.com/kr/iphone-15-pro/",
            "target_price": 1200000
        }
    ]
    
    for product in products:
        monitor.add_product(
            name=product["name"],
            url=product["url"],
            target_price=product["target_price"]
        )
    
    # 가격 확인 실행
    monitor.check_prices()
    monitor.generate_price_report()

if __name__ == "__main__":
    setup_price_monitoring()
```

## API 및 SDK 활용

### 1. ScrapeGraph API 사용

```python
# api_usage.py
import requests
import json

class ScrapeGraphAPI:
    def __init__(self, api_key):
        self.api_key = api_key
        self.base_url = "https://api.scrapegraphai.com/v1"
        self.headers = {
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json"
        }
    
    def scrape_single_page(self, url, prompt, config=None):
        """단일 페이지 스크래핑"""
        
        payload = {
            "url": url,
            "prompt": prompt,
            "config": config or {
                "llm_model": "gpt-4o-mini",
                "temperature": 0.1
            }
        }
        
        response = requests.post(
            f"{self.base_url}/scrape",
            headers=self.headers,
            json=payload
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"API 오류: {response.status_code} - {response.text}")
    
    def scrape_multiple_pages(self, urls, prompt, config=None):
        """다중 페이지 스크래핑"""
        
        payload = {
            "urls": urls,
            "prompt": prompt,
            "config": config or {
                "llm_model": "gpt-4o-mini",
                "temperature": 0.1,
                "max_concurrent": 3
            }
        }
        
        response = requests.post(
            f"{self.base_url}/scrape/multi",
            headers=self.headers,
            json=payload
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"API 오류: {response.status_code} - {response.text}")
    
    def get_usage_stats(self):
        """사용량 통계 조회"""
        
        response = requests.get(
            f"{self.base_url}/usage",
            headers=self.headers
        )
        
        if response.status_code == 200:
            return response.json()
        else:
            raise Exception(f"API 오류: {response.status_code} - {response.text}")

def api_example():
    """API 사용 예제"""
    
    # API 키 설정 (실제 키로 교체 필요)
    api_key = "your_scrapegraph_api_key"
    api = ScrapeGraphAPI(api_key)
    
    try:
        # 단일 페이지 스크래핑
        result = api.scrape_single_page(
            url="https://openai.com",
            prompt="회사 정보와 주요 제품을 JSON 형태로 추출해주세요",
            config={
                "llm_model": "gpt-4o-mini",
                "temperature": 0.1,
                "max_tokens": 2048
            }
        )
        
        print("단일 페이지 결과:")
        print(json.dumps(result, indent=2, ensure_ascii=False))
        
        # 다중 페이지 스크래핑
        urls = [
            "https://openai.com",
            "https://anthropic.com",
            "https://cohere.ai"
        ]
        
        multi_result = api.scrape_multiple_pages(
            urls=urls,
            prompt="회사명, 주요 제품, 설립연도를 추출해주세요",
            config={
                "llm_model": "gpt-4o-mini",
                "temperature": 0.1,
                "max_concurrent": 2
            }
        )
        
        print("\n다중 페이지 결과:")
        print(json.dumps(multi_result, indent=2, ensure_ascii=False))
        
        # 사용량 확인
        usage = api.get_usage_stats()
        print(f"\n사용량 통계: {usage}")
        
    except Exception as e:
        print(f"API 사용 오류: {e}")

if __name__ == "__main__":
    api_example()
```

### 2. Python SDK 활용

```python
# sdk_usage.py
from scrapegraph_py import Client

def sdk_example():
    """Python SDK 사용 예제"""
    
    # 클라이언트 초기화
    client = Client(api_key="your_api_key")
    
    # 간단한 스크래핑
    result = client.smartscraper(
        website_url="https://scrapegraphai.com/",
        user_prompt="Extract company information and founder details"
    )
    
    print(f"SDK 결과: {result}")
    
    # 설정이 있는 스크래핑
    advanced_result = client.smartscraper(
        website_url="https://openai.com",
        user_prompt="Extract product information and pricing details",
        llm_config={
            "model": "gpt-4o-mini",
            "temperature": 0.1,
            "max_tokens": 1500
        }
    )
    
    print(f"고급 설정 결과: {advanced_result}")

if __name__ == "__main__":
    sdk_example()
```

## 성능 최적화 및 모범 사례

### 1. 성능 최적화 기법

```python
# optimization_tips.py
import asyncio
import time
from concurrent.futures import ThreadPoolExecutor
from scrapegraphai.graphs import SmartScraperGraph

class OptimizedScraper:
    def __init__(self, config):
        self.config = config
        self.scrapers = {}
    
    def get_optimized_config(self, use_case="general"):
        """용도별 최적화된 설정"""
        
        base_config = self.config.copy()
        
        optimizations = {
            "speed": {
                "llm": {
                    "model": "groq/llama-3.1-70b-versatile",  # 빠른 모델
                    "temperature": 0,
                    "max_tokens": 1024
                },
                "loader_kwargs": {
                    "requests_per_second": 5,
                    "load_timeout": 10
                },
                "headless": True,
                "verbose": False
            },
            "accuracy": {
                "llm": {
                    "model": "openai/gpt-4o",  # 정확한 모델
                    "temperature": 0.1,
                    "max_tokens": 4096
                },
                "loader_kwargs": {
                    "requests_per_second": 1,
                    "load_timeout": 30
                },
                "headless": True,
                "verbose": True
            },
            "cost": {
                "llm": {
                    "model": "ollama/llama3.2",  # 로컬 모델
                    "model_tokens": 8192
                },
                "loader_kwargs": {
                    "requests_per_second": 2,
                    "load_timeout": 20
                },
                "headless": True,
                "verbose": False
            }
        }
        
        if use_case in optimizations:
            base_config.update(optimizations[use_case])
        
        return base_config
    
    def batch_scrape_with_pooling(self, url_prompt_pairs, max_workers=3):
        """스레드 풀을 사용한 배치 스크래핑"""
        
        def scrape_single(url_prompt):
            url, prompt = url_prompt
            scraper = SmartScraperGraph(
                prompt=prompt,
                source=url,
                config=self.get_optimized_config("speed")
            )
            return scraper.run()
        
        start_time = time.time()
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            results = list(executor.map(scrape_single, url_prompt_pairs))
        
        end_time = time.time()
        print(f"배치 스크래핑 완료: {len(url_prompt_pairs)}개 URL, {end_time - start_time:.2f}초")
        
        return results
    
    def cached_scraper(self, url, prompt, cache_duration_minutes=60):
        """캐시를 활용한 스크래핑"""
        import hashlib
        import pickle
        import os
        from datetime import datetime, timedelta
        
        # 캐시 키 생성
        cache_key = hashlib.md5(f"{url}_{prompt}".encode()).hexdigest()
        cache_file = f"cache/{cache_key}.pkl"
        
        # 캐시 디렉토리 생성
        os.makedirs("cache", exist_ok=True)
        
        # 캐시 확인
        if os.path.exists(cache_file):
            cache_time = datetime.fromtimestamp(os.path.getmtime(cache_file))
            if datetime.now() - cache_time < timedelta(minutes=cache_duration_minutes):
                print(f"캐시에서 결과 반환: {url}")
                with open(cache_file, "rb") as f:
                    return pickle.load(f)
        
        # 새로 스크래핑
        print(f"새로 스크래핑: {url}")
        scraper = SmartScraperGraph(
            prompt=prompt,
            source=url,
            config=self.get_optimized_config("speed")
        )
        result = scraper.run()
        
        # 캐시에 저장
        with open(cache_file, "wb") as f:
            pickle.dump(result, f)
        
        return result
    
    def adaptive_retry_scraper(self, url, prompt, max_retries=3):
        """적응형 재시도 스크래핑"""
        
        configs = [
            self.get_optimized_config("speed"),
            self.get_optimized_config("general"),
            self.get_optimized_config("accuracy")
        ]
        
        for attempt in range(max_retries):
            try:
                config = configs[min(attempt, len(configs) - 1)]
                
                scraper = SmartScraperGraph(
                    prompt=prompt,
                    source=url,
                    config=config
                )
                
                result = scraper.run()
                
                if result and len(str(result)) > 50:  # 결과가 충분한지 확인
                    return result
                
            except Exception as e:
                print(f"시도 {attempt + 1} 실패: {e}")
                if attempt == max_retries - 1:
                    raise
                
                time.sleep(2 ** attempt)  # 지수 백오프
        
        return None

def performance_comparison():
    """성능 비교 테스트"""
    
    base_config = {
        "verbose": False,
        "headless": True
    }
    
    optimizer = OptimizedScraper(base_config)
    
    test_urls = [
        "https://openai.com",
        "https://anthropic.com", 
        "https://huggingface.co"
    ]
    
    prompt = "Extract company name and main product information"
    
    # 순차 처리
    start_time = time.time()
    sequential_results = []
    for url in test_urls:
        scraper = SmartScraperGraph(
            prompt=prompt,
            source=url,
            config=base_config
        )
        result = scraper.run()
        sequential_results.append(result)
    sequential_time = time.time() - start_time
    
    # 병렬 처리
    url_prompt_pairs = [(url, prompt) for url in test_urls]
    start_time = time.time()
    parallel_results = optimizer.batch_scrape_with_pooling(url_prompt_pairs)
    parallel_time = time.time() - start_time
    
    print(f"순차 처리: {sequential_time:.2f}초")
    print(f"병렬 처리: {parallel_time:.2f}초")
    print(f"성능 향상: {sequential_time/parallel_time:.2f}배")

if __name__ == "__main__":
    performance_comparison()
```

### 2. 오류 처리 및 로깅

```python
# error_handling.py
import logging
import traceback
from datetime import datetime
from scrapegraphai.graphs import SmartScraperGraph

class RobustScraper:
    def __init__(self, config):
        self.config = config
        self.setup_logging()
    
    def setup_logging(self):
        """로깅 설정"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('scraping.log'),
                logging.StreamHandler()
            ]
        )
        self.logger = logging.getLogger(__name__)
    
    def safe_scrape(self, url, prompt, timeout=60):
        """안전한 스크래핑 (오류 처리 포함)"""
        
        try:
            self.logger.info(f"스크래핑 시작: {url}")
            
            # 타임아웃 설정
            config = self.config.copy()
            config.setdefault('loader_kwargs', {})['load_timeout'] = timeout
            
            scraper = SmartScraperGraph(
                prompt=prompt,
                source=url,
                config=config
            )
            
            result = scraper.run()
            
            # 결과 검증
            if not result or len(str(result)) < 10:
                raise ValueError("스크래핑 결과가 너무 짧습니다")
            
            self.logger.info(f"스크래핑 성공: {url}")
            return {
                "success": True,
                "url": url,
                "result": result,
                "timestamp": datetime.now().isoformat()
            }
            
        except Exception as e:
            error_msg = f"스크래핑 오류 ({url}): {str(e)}"
            self.logger.error(error_msg)
            self.logger.error(traceback.format_exc())
            
            return {
                "success": False,
                "url": url,
                "error": str(e),
                "error_type": type(e).__name__,
                "timestamp": datetime.now().isoformat()
            }
    
    def scrape_with_fallback(self, url, prompt):
        """대체 전략을 사용한 스크래핑"""
        
        strategies = [
            {
                "name": "Primary (Ollama)",
                "config": {
                    "llm": {"model": "ollama/llama3.2"},
                    "headless": True
                }
            },
            {
                "name": "Fallback (OpenAI)",
                "config": {
                    "llm": {
                        "model": "openai/gpt-4o-mini",
                        "api_key": "your_api_key"
                    },
                    "headless": True
                }
            },
            {
                "name": "Emergency (Groq)",
                "config": {
                    "llm": {
                        "model": "groq/llama-3.1-70b-versatile",
                        "api_key": "your_groq_key"
                    },
                    "headless": True
                }
            }
        ]
        
        for strategy in strategies:
            try:
                self.logger.info(f"시도 중: {strategy['name']}")
                
                updated_config = self.config.copy()
                updated_config.update(strategy['config'])
                
                scraper = SmartScraperGraph(
                    prompt=prompt,
                    source=url,
                    config=updated_config
                )
                
                result = scraper.run()
                
                if result and len(str(result)) > 10:
                    self.logger.info(f"성공: {strategy['name']}")
                    return result
                
            except Exception as e:
                self.logger.warning(f"{strategy['name']} 실패: {e}")
                continue
        
        raise Exception("모든 대체 전략이 실패했습니다")

def error_handling_example():
    """오류 처리 예제"""
    
    config = {
        "verbose": True,
        "headless": True
    }
    
    robust_scraper = RobustScraper(config)
    
    # 문제가 있을 수 있는 URL들 테스트
    test_cases = [
        {
            "url": "https://httpbin.org/delay/5",  # 느린 응답
            "prompt": "Extract any data from this page"
        },
        {
            "url": "https://httpbin.org/status/404",  # 404 오류
            "prompt": "Extract content"
        },
        {
            "url": "https://httpbin.org/status/500",  # 서버 오류
            "prompt": "Extract information"
        },
        {
            "url": "https://scrapegraphai.com/",  # 정상 사이트
            "prompt": "Extract company information"
        }
    ]
    
    results = []
    for test_case in test_cases:
        result = robust_scraper.safe_scrape(
            url=test_case["url"],
            prompt=test_case["prompt"],
            timeout=10
        )
        results.append(result)
    
    # 결과 요약
    successful = [r for r in results if r["success"]]
    failed = [r for r in results if not r["success"]]
    
    print(f"\n결과 요약:")
    print(f"성공: {len(successful)}개")
    print(f"실패: {len(failed)}개")
    
    if failed:
        print("\n실패한 케이스:")
        for fail in failed:
            print(f"  - {fail['url']}: {fail['error']}")

if __name__ == "__main__":
    error_handling_example()
```

## 고급 기능 및 확장

### 1. 커스텀 파이프라인 구축

```python
# custom_pipeline.py
from scrapegraphai.graphs.base_graph import BaseGraph
from scrapegraphai.nodes import FetchNode, ParseNode, GenerateAnswerNode

class CustomAnalysisGraph(BaseGraph):
    """커스텀 분석 파이프라인"""
    
    def __init__(self, prompt, source, config):
        super().__init__(prompt, source, config)
        
        # 노드 정의
        self.input_key = "url"
        self.output_key = "answer"
        
        # 그래프 구성
        self.graph = self._create_graph()
    
    def _create_graph(self):
        """커스텀 그래프 생성"""
        
        # 1. 웹페이지 가져오기
        fetch_node = FetchNode(
            input="url",
            output=["doc"],
            node_config={
                "loader_kwargs": self.config.get("loader_kwargs", {}),
                "headless": self.config.get("headless", True)
            }
        )
        
        # 2. 구조화된 파싱
        parse_node = ParseNode(
            input="doc",
            output=["parsed_doc"],
            node_config={
                "llm_model": self.config["llm"],
                "chunk_size": 1000,
                "parse_instructions": """
                웹페이지를 다음 섹션으로 구분해서 파싱하세요:
                - header: 헤더 정보
                - navigation: 네비게이션 메뉴
                - main_content: 주요 콘텐츠
                - sidebar: 사이드바 내용
                - footer: 푸터 정보
                """
            }
        )
        
        # 3. 고급 분석 및 답변 생성
        analysis_node = GenerateAnswerNode(
            input="parsed_doc",
            output=["answer"],
            node_config={
                "llm_model": self.config["llm"],
                "analysis_prompt": """
                파싱된 웹페이지 데이터를 기반으로 다음 분석을 수행하세요:
                
                1. 콘텐츠 분석:
                   - 주요 주제와 키워드
                   - 콘텐츠의 품질과 깊이
                   - 타겟 오디언스
                
                2. 구조 분석:
                   - 웹사이트 구조의 복잡성
                   - 사용자 경험 요소
                   - 접근성 고려사항
                
                3. 기술 분석:
                   - 사용된 기술 스택 (추정)
                   - 성능 관련 요소
                   - SEO 최적화 수준
                
                4. 비즈니스 분석:
                   - 비즈니스 모델 추정
                   - 수익화 방식
                   - 경쟁력 요소
                
                JSON 형태로 구조화된 분석 결과를 제공하세요.
                """
            }
        )
        
        # 그래프 연결
        return fetch_node >> parse_node >> analysis_node

def custom_pipeline_example():
    """커스텀 파이프라인 사용 예제"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True
    }
    
    # 커스텀 분석 실행
    analyzer = CustomAnalysisGraph(
        prompt="웹사이트를 종합적으로 분석해주세요",
        source="https://scrapegraphai.com/",
        config=config
    )
    
    result = analyzer.run()
    
    print("커스텀 분석 결과:")
    print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    custom_pipeline_example()
```

### 2. 플러그인 시스템

```python
# plugin_system.py
import json
from abc import ABC, abstractmethod
from scrapegraphai.graphs import SmartScraperGraph

class ScrapePlugin(ABC):
    """스크래핑 플러그인 베이스 클래스"""
    
    @abstractmethod
    def preprocess(self, url, prompt):
        """전처리"""
        pass
    
    @abstractmethod
    def postprocess(self, result):
        """후처리"""
        pass
    
    @abstractmethod
    def get_name(self):
        """플러그인 이름"""
        pass

class DataValidationPlugin(ScrapePlugin):
    """데이터 검증 플러그인"""
    
    def get_name(self):
        return "DataValidation"
    
    def preprocess(self, url, prompt):
        """URL 유효성 검사"""
        if not url.startswith(('http://', 'https://')):
            raise ValueError(f"유효하지 않은 URL: {url}")
        return url, prompt
    
    def postprocess(self, result):
        """결과 검증"""
        if not result:
            raise ValueError("스크래핑 결과가 비어있습니다")
        
        if isinstance(result, str) and len(result) < 10:
            raise ValueError("스크래핑 결과가 너무 짧습니다")
        
        return result

class DataEnrichmentPlugin(ScrapePlugin):
    """데이터 보강 플러그인"""
    
    def get_name(self):
        return "DataEnrichment"
    
    def preprocess(self, url, prompt):
        """프롬프트 보강"""
        enhanced_prompt = f"""
        {prompt}
        
        추가로 다음 메타데이터도 포함해주세요:
        - 스크래핑 시간: 현재 시간
        - 페이지 언어: 추정 언어
        - 콘텐츠 길이: 대략적인 단어 수
        - 구조화 수준: 얼마나 잘 구조화되어 있는지
        """
        return url, enhanced_prompt
    
    def postprocess(self, result):
        """결과 보강"""
        if isinstance(result, dict):
            result['_metadata'] = {
                'processed_by': 'ScrapeGraphAI',
                'enriched': True,
                'plugin_version': '1.0'
            }
        return result

class TranslationPlugin(ScrapePlugin):
    """번역 플러그인"""
    
    def __init__(self, target_language="ko"):
        self.target_language = target_language
    
    def get_name(self):
        return f"Translation_{self.target_language}"
    
    def preprocess(self, url, prompt):
        """번역 요청 추가"""
        if self.target_language != "en":
            prompt += f"\n\n결과를 {self.target_language}로 번역해서 제공해주세요."
        return url, prompt
    
    def postprocess(self, result):
        """번역 후처리"""
        # 실제로는 여기서 추가 번역 검증을 할 수 있음
        return result

class PluginManager:
    """플러그인 관리자"""
    
    def __init__(self):
        self.plugins = []
    
    def register_plugin(self, plugin):
        """플러그인 등록"""
        if not isinstance(plugin, ScrapePlugin):
            raise TypeError("ScrapePlugin을 상속받은 클래스여야 합니다")
        
        self.plugins.append(plugin)
        print(f"플러그인 등록됨: {plugin.get_name()}")
    
    def execute_scraping(self, url, prompt, config):
        """플러그인을 적용한 스크래핑 실행"""
        
        # 전처리 단계
        processed_url, processed_prompt = url, prompt
        for plugin in self.plugins:
            try:
                processed_url, processed_prompt = plugin.preprocess(processed_url, processed_prompt)
                print(f"전처리 완료: {plugin.get_name()}")
            except Exception as e:
                print(f"전처리 오류 ({plugin.get_name()}): {e}")
                raise
        
        # 실제 스크래핑
        scraper = SmartScraperGraph(
            prompt=processed_prompt,
            source=processed_url,
            config=config
        )
        
        result = scraper.run()
        
        # 후처리 단계
        for plugin in reversed(self.plugins):  # 역순으로 처리
            try:
                result = plugin.postprocess(result)
                print(f"후처리 완료: {plugin.get_name()}")
            except Exception as e:
                print(f"후처리 오류 ({plugin.get_name()}): {e}")
                raise
        
        return result

def plugin_system_example():
    """플러그인 시스템 사용 예제"""
    
    config = {
        "llm": {
            "model": "ollama/llama3.2",
            "model_tokens": 8192
        },
        "verbose": True,
        "headless": True
    }
    
    # 플러그인 매니저 생성
    manager = PluginManager()
    
    # 플러그인들 등록
    manager.register_plugin(DataValidationPlugin())
    manager.register_plugin(DataEnrichmentPlugin())
    manager.register_plugin(TranslationPlugin("ko"))
    
    # 플러그인이 적용된 스크래핑 실행
    result = manager.execute_scraping(
        url="https://openai.com",
        prompt="Extract company information and main products",
        config=config
    )
    
    print("\n플러그인 적용 결과:")
    print(json.dumps(result, indent=2, ensure_ascii=False))

if __name__ == "__main__":
    plugin_system_example()
```

## 결론

ScrapeGraphAI는 전통적인 웹 스크래핑의 한계를 뛰어넘는 혁신적인 도구입니다. 이 가이드를 통해 다음과 같은 역량을 얻을 수 있습니다:

### 핵심 성과

1. **AI 기반 데이터 추출**: CSS 선택자 없이도 정확한 데이터 수집
2. **확장 가능한 아키텍처**: 다양한 LLM과 파이프라인 지원
3. **실무 적용**: 경쟁사 분석, 가격 모니터링, 뉴스 수집 등
4. **성능 최적화**: 캐싱, 병렬 처리, 오류 복구 전략

### 기술적 장점

- **자연어 프롬프트**: 복잡한 코드 없이 직관적인 데이터 추출
- **적응성**: 웹사이트 구조 변경에 자동 대응
- **다양성**: 단일/다중 페이지, 검색, 스크립트 생성 등 다양한 파이프라인
- **통합성**: API, SDK, 노코드 플랫폼과의 완벽한 연동

### 실무 가치

이 튜토리얼에서 다룬 예제들은 실제 비즈니스 환경에서 바로 활용할 수 있습니다:

- **마케팅 팀**: 경쟁사 모니터링 및 시장 동향 분석
- **개발 팀**: 자동화된 데이터 수집 파이프라인 구축
- **분석가**: 다양한 소스에서 구조화된 데이터 추출
- **연구자**: 대규모 웹 데이터 수집 및 분석

### 미래 발전 방향

```python
future_enhancements = {
    "multimodal_support": "이미지, 비디오 콘텐츠 분석",
    "real_time_streaming": "실시간 웹 데이터 스트리밍",
    "advanced_ai": "더 정교한 AI 모델 통합",
    "enterprise_features": "기업급 보안 및 관리 기능",
    "collaborative_tools": "팀 협업 및 워크플로우 관리"
}
```

ScrapeGraphAI의 20.5k GitHub 스타는 단순한 인기가 아닌, 실제 개발자들이 체감하는 혁신의 증거입니다. [공식 레포지토리](https://github.com/ScrapeGraphAI/Scrapegraph-ai)에서 최신 업데이트를 확인하고, 커뮤니티와 함께 AI 기반 데이터 수집의 새로운 가능성을 탐험해보세요!

---

**관련 리소스**:
- [ScrapeGraphAI GitHub](https://github.com/ScrapeGraphAI/Scrapegraph-ai)
- [공식 API 문서](https://docs.scrapegraphai.com/)
- [Python SDK](https://github.com/ScrapeGraphAI/scrapegraph-sdk/tree/main/scrapegraph-py)
- [Node.js SDK](https://github.com/ScrapeGraphAI/scrapegraph-sdk/tree/main/scrapegraph-js) 