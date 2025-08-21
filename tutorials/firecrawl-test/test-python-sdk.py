#!/usr/bin/env python3
"""
Firecrawl Python SDK 테스트 스크립트
작성자: Thaki Cloud
날짜: 2025-08-21
"""

import os
import json
from pydantic import BaseModel, Field
from typing import List, Optional
from firecrawl import Firecrawl

# 환경 변수에서 API 키 로드
def load_api_key():
    try:
        with open('.env', 'r') as f:
            for line in f:
                if line.startswith('FIRECRAWL_API_KEY='):
                    return line.split('=', 1)[1].strip()
    except FileNotFoundError:
        pass
    
    # 환경 변수에서 시도
    api_key = os.getenv('FIRECRAWL_API_KEY')
    if not api_key:
        print("❌ API 키를 찾을 수 없습니다. .env 파일에 FIRECRAWL_API_KEY를 설정하세요.")
        return None
    return api_key

# Pydantic 스키마 정의
class Article(BaseModel):
    title: str
    points: int
    by: str
    commentsURL: str

class TopArticles(BaseModel):
    top: List[Article] = Field(..., description="상위 5개 기사")

class CompanyInfo(BaseModel):
    company_name: Optional[str] = Field(description="회사명")
    mission: Optional[str] = Field(description="회사 미션")
    website: Optional[str] = Field(description="웹사이트 URL")

def test_basic_scraping(firecrawl):
    """기본 스크래핑 테스트"""
    print("\n🔍 1. 기본 스크래핑 테스트")
    print("-" * 40)
    
    try:
        doc = firecrawl.scrape(
            "https://firecrawl.dev",
            formats=["markdown", "html"],
        )
        
        print(f"✅ 스크래핑 성공!")
        print(f"📄 마크다운 길이: {len(doc.markdown)} 문자")
        print(f"🏷️ HTML 길이: {len(doc.html)} 문자")
        print(f"📝 제목: {doc.metadata.get('title', 'N/A')}")
        
        # 마크다운 일부 출력
        markdown_preview = doc.markdown[:200] + "..." if len(doc.markdown) > 200 else doc.markdown
        print(f"📖 마크다운 미리보기:\n{markdown_preview}")
        
        return True
    except Exception as e:
        print(f"❌ 스크래핑 실패: {e}")
        return False

def test_structured_extraction(firecrawl):
    """구조화된 데이터 추출 테스트"""
    print("\n📊 2. 구조화된 데이터 추출 테스트")
    print("-" * 40)
    
    try:
        # Hacker News에서 상위 기사 추출
        doc = firecrawl.scrape(
            "https://news.ycombinator.com",
            formats=[{"type": "json", "schema": TopArticles}],
        )
        
        print(f"✅ 구조화된 데이터 추출 성공!")
        
        if doc.json and 'top' in doc.json:
            articles = doc.json['top']
            print(f"📰 추출된 기사 수: {len(articles)}")
            
            for i, article in enumerate(articles[:3], 1):
                print(f"{i}. {article.get('title', 'N/A')} ({article.get('points', 0)} points)")
        
        return True
    except Exception as e:
        print(f"❌ 구조화된 데이터 추출 실패: {e}")
        return False

def test_batch_scraping(firecrawl):
    """배치 스크래핑 테스트"""
    print("\n⚡ 3. 배치 스크래핑 테스트")
    print("-" * 40)
    
    try:
        # 여러 URL 동시 스크래핑
        urls = [
            "https://firecrawl.dev",
            "https://docs.firecrawl.dev"
        ]
        
        response = firecrawl.batch_scrape(
            urls=urls,
            formats=["markdown"]
        )
        
        print(f"✅ 배치 스크래핑 작업 시작!")
        print(f"🆔 작업 ID: {response.get('jobId', 'N/A')}")
        print(f"📋 상태: {response.get('status', 'N/A')}")
        
        return True
    except Exception as e:
        print(f"❌ 배치 스크래핑 실패: {e}")
        return False

def test_crawling(firecrawl):
    """웹사이트 크롤링 테스트"""
    print("\n🕷️ 4. 웹사이트 크롤링 테스트")
    print("-" * 40)
    
    try:
        # 제한된 크롤링 (비용 절약을 위해 5페이지로 제한)
        response = firecrawl.crawl(
            "https://docs.firecrawl.dev",
            limit=5,
            scrape_options={"formats": ["markdown"]},
        )
        
        print(f"✅ 크롤링 성공!")
        print(f"📄 크롤링된 페이지 수: {len(response.get('data', []))}")
        
        for i, page in enumerate(response.get('data', [])[:3], 1):
            title = page.get('metadata', {}).get('title', 'N/A')
            url = page.get('metadata', {}).get('url', 'N/A')
            print(f"{i}. {title} - {url}")
        
        return True
    except Exception as e:
        print(f"❌ 크롤링 실패: {e}")
        return False

def main():
    """메인 테스트 함수"""
    print("🔥 Firecrawl Python SDK 테스트 시작")
    print("=" * 50)
    
    # API 키 로드
    api_key = load_api_key()
    if not api_key:
        return
    
    # Firecrawl 클라이언트 초기화
    try:
        firecrawl = Firecrawl(api_key=api_key)
        print(f"✅ Firecrawl 클라이언트 초기화 성공")
    except Exception as e:
        print(f"❌ Firecrawl 클라이언트 초기화 실패: {e}")
        return
    
    # 테스트 실행
    tests = [
        test_basic_scraping,
        test_structured_extraction,
        test_batch_scraping,
        test_crawling
    ]
    
    passed = 0
    total = len(tests)
    
    for test_func in tests:
        try:
            if test_func(firecrawl):
                passed += 1
        except Exception as e:
            print(f"❌ 테스트 중 오류 발생: {e}")
    
    # 결과 요약
    print(f"\n📊 테스트 결과")
    print("=" * 50)
    print(f"✅ 통과: {passed}/{total}")
    print(f"❌ 실패: {total - passed}/{total}")
    
    if passed == total:
        print("🎉 모든 테스트가 성공했습니다!")
    else:
        print("⚠️ 일부 테스트가 실패했습니다. API 키와 네트워크 연결을 확인하세요.")

if __name__ == "__main__":
    main()
