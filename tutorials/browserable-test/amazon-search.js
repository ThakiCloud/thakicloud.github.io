#!/usr/bin/env node

/**
 * Amazon 제품 검색 예제
 * Browserable을 사용하여 Amazon에서 특정 조건의 제품을 검색하는 스크립트
 */

import { Browserable } from 'browserable-js';
import dotenv from 'dotenv';

dotenv.config();

class AmazonSearchAgent {
  constructor() {
    this.browserable = new Browserable({
      apiKey: process.env.BROWSERABLE_API_KEY,
      baseUrl: process.env.BROWSERABLE_BASE_URL || 'http://localhost:2003',
      timeout: 120000,
      debug: process.env.DEBUG === 'true'
    });
  }

  async searchYogaMats() {
    console.log('🧘‍♀️ Amazon 요가 매트 검색 시작...');
    
    try {
      const task = await this.browserable.createTask({
        task: `Go to amazon.com and search for yoga mats. Apply these filters:
               - At least 6mm thick
               - Non-slip surface
               - Eco-friendly materials
               - Price under $50
               
               Extract the top 5 products with: name, price, rating, key features, 
               and product link. Return results as structured JSON.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 180000,
          userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36'
        }
      });
      
      console.log(`📝 작업 생성됨: ${task.taskId}`);
      console.log('⏳ Amazon 검색 진행 중... (최대 3분 소요)');
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 10000,
        maxWaitTime: 300000
      });
      
      return this.processSearchResults(result);
      
    } catch (error) {
      console.error('❌ Amazon 검색 실패:', error.message);
      throw error;
    }
  }

  processSearchResults(result) {
    if (!result.success) {
      throw new Error(`검색 실패: ${result.error}`);
    }
    
    console.log('✅ Amazon 요가 매트 검색 완료!');
    console.log('\n🛍️ 검색 결과:');
    
    if (result.data && result.data.products) {
      result.data.products.forEach((product, index) => {
        console.log(`\n${index + 1}. ${product.name || '제품명 정보 없음'}`);
        console.log(`   💰 가격: ${product.price || 'N/A'}`);
        console.log(`   ⭐ 평점: ${product.rating || 'N/A'}`);
        console.log(`   ✨ 주요 특징: ${product.features || 'N/A'}`);
        console.log(`   🔗 링크: ${product.link || 'N/A'}`);
      });
    } else {
      console.log('📋 검색 결과 원본 데이터:');
      console.log(JSON.stringify(result.data, null, 2));
    }
    
    return result;
  }

  async searchWithCustomQuery(searchQuery) {
    console.log(`🔍 커스텀 검색 시작: ${searchQuery}`);
    
    try {
      const task = await this.browserable.createTask({
        task: `Go to amazon.com and search for "${searchQuery}". 
               Extract the top 3 search results with product name, price, 
               rating, and brief description. Return as JSON.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 120000
        }
      });
      
      console.log(`📝 작업 생성됨: ${task.taskId}`);
      
      const result = await this.browserable.waitForRun(task.taskId);
      return this.processSearchResults(result);
      
    } catch (error) {
      console.error('❌ 커스텀 검색 실패:', error.message);
      throw error;
    }
  }

  async validateEnvironment() {
    console.log('🔧 환경 설정 검증 중...');
    
    if (!process.env.BROWSERABLE_API_KEY) {
      throw new Error('BROWSERABLE_API_KEY 환경 변수가 설정되지 않았습니다.');
    }
    
    console.log('✅ 환경 설정 검증 완료');
  }
}

async function main() {
  const agent = new AmazonSearchAgent();
  
  try {
    await agent.validateEnvironment();
    
    // 커맨드 라인 인수가 있으면 커스텀 검색, 없으면 기본 요가 매트 검색
    const customQuery = process.argv[2];
    
    let result;
    if (customQuery) {
      result = await agent.searchWithCustomQuery(customQuery);
    } else {
      result = await agent.searchYogaMats();
    }
    
    console.log('\n🎉 Amazon 검색 완료!');
    process.exit(0);
    
  } catch (error) {
    console.error('\n💥 실행 중 오류 발생:', error.message);
    console.error('\n🔧 해결 방법:');
    console.error('1. .env 파일에 BROWSERABLE_API_KEY 설정');
    console.error('2. Browserable 서버가 실행 중인지 확인');
    console.error('3. Amazon 접속 가능한지 확인');
    console.error('\n사용법:');
    console.error('  npm run amazon-search           # 기본 요가 매트 검색');
    console.error('  node amazon-search.js "laptop"  # 커스텀 검색');
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { AmazonSearchAgent };
