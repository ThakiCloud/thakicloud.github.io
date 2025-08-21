#!/usr/bin/env node

/**
 * Firecrawl Node.js SDK 테스트 스크립트
 * 작성자: Thaki Cloud
 * 날짜: 2025-08-21
 */

const Firecrawl = require('@mendable/firecrawl-js');
const { z } = require('zod');
const fs = require('fs');

// 환경 변수에서 API 키 로드
function loadApiKey() {
    try {
        // .env 파일에서 로드
        if (fs.existsSync('.env')) {
            const envContent = fs.readFileSync('.env', 'utf8');
            const lines = envContent.split('\n');
            for (const line of lines) {
                if (line.startsWith('FIRECRAWL_API_KEY=')) {
                    return line.split('=')[1].trim();
                }
            }
        }
    } catch (error) {
        // 환경 변수에서 시도
    }
    
    const apiKey = process.env.FIRECRAWL_API_KEY;
    if (!apiKey) {
        console.log('❌ API 키를 찾을 수 없습니다. .env 파일에 FIRECRAWL_API_KEY를 설정하세요.');
        return null;
    }
    return apiKey;
}

// Zod 스키마 정의
const ArticleSchema = z.object({
    title: z.string(),
    points: z.number(),
    by: z.string(),
    commentsURL: z.string(),
});

const TopArticlesSchema = z.object({
    top: z.array(ArticleSchema)
        .length(5)
        .describe('상위 5개 기사'),
});

async function testBasicScraping(firecrawl) {
    console.log('\n🔍 1. 기본 스크래핑 테스트');
    console.log('-'.repeat(40));
    
    try {
        const doc = await firecrawl.scrape('https://firecrawl.dev', {
            formats: ['markdown', 'html'],
        });
        
        console.log('✅ 스크래핑 성공!');
        console.log(`📄 마크다운 길이: ${doc.markdown?.length || 0} 문자`);
        console.log(`🏷️ HTML 길이: ${doc.html?.length || 0} 문자`);
        console.log(`📝 제목: ${doc.metadata?.title || 'N/A'}`);
        
        // 마크다운 일부 출력
        if (doc.markdown) {
            const preview = doc.markdown.length > 200 
                ? doc.markdown.substring(0, 200) + '...'
                : doc.markdown;
            console.log(`📖 마크다운 미리보기:\n${preview}`);
        }
        
        return true;
    } catch (error) {
        console.log(`❌ 스크래핑 실패: ${error.message}`);
        return false;
    }
}

async function testStructuredExtraction(firecrawl) {
    console.log('\n📊 2. 구조화된 데이터 추출 테스트');
    console.log('-'.repeat(40));
    
    try {
        // Extract API 사용
        const extractRes = await firecrawl.extract({
            urls: ['https://news.ycombinator.com'],
            schema: TopArticlesSchema,
            prompt: '상위 5개 기사를 추출하세요',
        });
        
        console.log('✅ 구조화된 데이터 추출 성공!');
        
        if (extractRes?.data?.[0]?.extract?.top) {
            const articles = extractRes.data[0].extract.top;
            console.log(`📰 추출된 기사 수: ${articles.length}`);
            
            articles.slice(0, 3).forEach((article, index) => {
                console.log(`${index + 1}. ${article.title || 'N/A'} (${article.points || 0} points)`);
            });
        }
        
        return true;
    } catch (error) {
        console.log(`❌ 구조화된 데이터 추출 실패: ${error.message}`);
        return false;
    }
}

async function testBatchScraping(firecrawl) {
    console.log('\n⚡ 3. 배치 스크래핑 테스트');
    console.log('-'.repeat(40));
    
    try {
        // 여러 URL 동시 스크래핑
        const urls = [
            'https://firecrawl.dev',
            'https://docs.firecrawl.dev'
        ];
        
        const response = await firecrawl.batchScrape(urls, {
            formats: ['markdown']
        });
        
        console.log('✅ 배치 스크래핑 작업 시작!');
        console.log(`🆔 작업 ID: ${response.jobId || 'N/A'}`);
        console.log(`📋 상태: ${response.status || 'N/A'}`);
        
        return true;
    } catch (error) {
        console.log(`❌ 배치 스크래핑 실패: ${error.message}`);
        return false;
    }
}

async function testCrawling(firecrawl) {
    console.log('\n🕷️ 4. 웹사이트 크롤링 테스트');
    console.log('-'.repeat(40));
    
    try {
        // 제한된 크롤링 (비용 절약을 위해 5페이지로 제한)
        const response = await firecrawl.crawl('https://docs.firecrawl.dev', {
            limit: 5,
            scrapeOptions: { formats: ['markdown'] },
        });
        
        console.log('✅ 크롤링 성공!');
        console.log(`📄 크롤링된 페이지 수: ${response.data?.length || 0}`);
        
        if (response.data) {
            response.data.slice(0, 3).forEach((page, index) => {
                const title = page.metadata?.title || 'N/A';
                const url = page.metadata?.url || 'N/A';
                console.log(`${index + 1}. ${title} - ${url}`);
            });
        }
        
        return true;
    } catch (error) {
        console.log(`❌ 크롤링 실패: ${error.message}`);
        return false;
    }
}

async function main() {
    console.log('🔥 Firecrawl Node.js SDK 테스트 시작');
    console.log('='.repeat(50));
    
    // API 키 로드
    const apiKey = loadApiKey();
    if (!apiKey) {
        return;
    }
    
    // Firecrawl 클라이언트 초기화
    let firecrawl;
    try {
        firecrawl = new Firecrawl({ apiKey });
        console.log('✅ Firecrawl 클라이언트 초기화 성공');
    } catch (error) {
        console.log(`❌ Firecrawl 클라이언트 초기화 실패: ${error.message}`);
        return;
    }
    
    // 테스트 실행
    const tests = [
        testBasicScraping,
        testStructuredExtraction,
        testBatchScraping,
        testCrawling
    ];
    
    let passed = 0;
    const total = tests.length;
    
    for (const testFunc of tests) {
        try {
            if (await testFunc(firecrawl)) {
                passed++;
            }
        } catch (error) {
            console.log(`❌ 테스트 중 오류 발생: ${error.message}`);
        }
    }
    
    // 결과 요약
    console.log('\n📊 테스트 결과');
    console.log('='.repeat(50));
    console.log(`✅ 통과: ${passed}/${total}`);
    console.log(`❌ 실패: ${total - passed}/${total}`);
    
    if (passed === total) {
        console.log('🎉 모든 테스트가 성공했습니다!');
    } else {
        console.log('⚠️ 일부 테스트가 실패했습니다. API 키와 네트워크 연결을 확인하세요.');
    }
}

// 스크립트 실행
if (require.main === module) {
    main().catch(console.error);
}
