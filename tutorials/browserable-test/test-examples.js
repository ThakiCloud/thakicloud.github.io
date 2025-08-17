#!/usr/bin/env node

/**
 * Browserable SDK 테스트 예제 모음
 * 다양한 웹사이트에서의 자동화 작업을 테스트합니다.
 */

import { Browserable } from 'browserable-js';
import dotenv from 'dotenv';

dotenv.config();

class BrowserableTestSuite {
  constructor() {
    this.browserable = new Browserable({
      apiKey: process.env.BROWSERABLE_API_KEY,
      baseUrl: process.env.BROWSERABLE_BASE_URL || 'http://localhost:2003',
      timeout: 60000,
      debug: process.env.DEBUG === 'true'
    });
    
    this.testResults = [];
  }

  async runConnectionTest() {
    console.log('🔗 Browserable 연결 테스트...');
    
    try {
      const task = await this.browserable.createTask({
        task: 'Visit google.com and extract the page title. This is a simple connection test.',
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1280, height: 720 },
          timeout: 30000
        }
      });
      
      console.log(`📝 연결 테스트 작업 생성됨: ${task.taskId}`);
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 3000,
        maxWaitTime: 60000
      });
      
      if (result.success) {
        console.log('✅ 연결 테스트 성공!');
        console.log(`📋 결과: ${JSON.stringify(result.data, null, 2)}`);
        this.testResults.push({ test: 'connection', status: 'passed', data: result.data });
      } else {
        throw new Error(result.error);
      }
      
    } catch (error) {
      console.error('❌ 연결 테스트 실패:', error.message);
      this.testResults.push({ test: 'connection', status: 'failed', error: error.message });
      throw error;
    }
  }

  async runArxivTest() {
    console.log('\n📚 arXiv 논문 검색 테스트...');
    
    try {
      const task = await this.browserable.createTask({
        task: `Visit arxiv.org and find a recent paper in the 'Computer Science - Machine Learning' category. 
               Extract the paper title, authors, submission date, and abstract summary (first 2 sentences).
               Return as structured JSON.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 90000
        }
      });
      
      console.log(`📝 arXiv 테스트 작업 생성됨: ${task.taskId}`);
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 5000,
        maxWaitTime: 120000
      });
      
      if (result.success) {
        console.log('✅ arXiv 테스트 성공!');
        if (result.data && result.data.paper) {
          const paper = result.data.paper;
          console.log(`📄 제목: ${paper.title}`);
          console.log(`👥 저자: ${paper.authors}`);
          console.log(`📅 제출일: ${paper.submissionDate}`);
          console.log(`📝 초록 요약: ${paper.abstractSummary}`);
        } else {
          console.log(`📋 결과: ${JSON.stringify(result.data, null, 2)}`);
        }
        this.testResults.push({ test: 'arxiv', status: 'passed', data: result.data });
      } else {
        throw new Error(result.error);
      }
      
    } catch (error) {
      console.error('❌ arXiv 테스트 실패:', error.message);
      this.testResults.push({ test: 'arxiv', status: 'failed', error: error.message });
    }
  }

  async runNewsTest() {
    console.log('\n📰 기술 뉴스 검색 테스트...');
    
    try {
      const task = await this.browserable.createTask({
        task: `Visit techcrunch.com and find the latest 3 articles about artificial intelligence or machine learning.
               Extract article titles, publication dates, and brief summaries.
               Return as structured JSON array.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 90000
        }
      });
      
      console.log(`📝 뉴스 테스트 작업 생성됨: ${task.taskId}`);
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 5000,
        maxWaitTime: 120000
      });
      
      if (result.success) {
        console.log('✅ 뉴스 테스트 성공!');
        if (result.data && result.data.articles) {
          result.data.articles.forEach((article, index) => {
            console.log(`\n${index + 1}. ${article.title}`);
            console.log(`   📅 발행일: ${article.date}`);
            console.log(`   📝 요약: ${article.summary}`);
          });
        } else {
          console.log(`📋 결과: ${JSON.stringify(result.data, null, 2)}`);
        }
        this.testResults.push({ test: 'news', status: 'passed', data: result.data });
      } else {
        throw new Error(result.error);
      }
      
    } catch (error) {
      console.error('❌ 뉴스 테스트 실패:', error.message);
      this.testResults.push({ test: 'news', status: 'failed', error: error.message });
    }
  }

  async runFormTest() {
    console.log('\n📝 폼 작성 테스트...');
    
    try {
      const task = await this.browserable.createTask({
        task: `Visit httpbin.org/forms/post and fill out the form with test data:
               - Customer name: "John Doe"  
               - Telephone: "555-1234"
               - Email: "john@example.com"
               - Size: select "Medium"
               - Pizza topping: select "bacon"
               - Comments: "This is a test form submission"
               
               Submit the form and capture the response. Return the submission result.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 60000
        }
      });
      
      console.log(`📝 폼 테스트 작업 생성됨: ${task.taskId}`);
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 3000,
        maxWaitTime: 90000
      });
      
      if (result.success) {
        console.log('✅ 폼 테스트 성공!');
        console.log(`📋 폼 제출 결과: ${JSON.stringify(result.data, null, 2)}`);
        this.testResults.push({ test: 'form', status: 'passed', data: result.data });
      } else {
        throw new Error(result.error);
      }
      
    } catch (error) {
      console.error('❌ 폼 테스트 실패:', error.message);
      this.testResults.push({ test: 'form', status: 'failed', error: error.message });
    }
  }

  async runAllTests() {
    console.log('🚀 Browserable SDK 종합 테스트 시작...\n');
    
    const startTime = Date.now();
    
    try {
      // 환경 검증
      await this.validateEnvironment();
      
      // 연결 테스트 (필수)
      await this.runConnectionTest();
      
      // 다른 테스트들 (선택적)
      if (process.env.RUN_FULL_TESTS === 'true') {
        await this.runArxivTest();
        await this.runNewsTest();
        await this.runFormTest();
      }
      
    } catch (error) {
      console.error('\n💥 치명적 오류로 테스트 중단:', error.message);
    }
    
    // 결과 요약
    this.printTestSummary(startTime);
  }

  printTestSummary(startTime) {
    const totalTime = Date.now() - startTime;
    const passed = this.testResults.filter(r => r.status === 'passed').length;
    const failed = this.testResults.filter(r => r.status === 'failed').length;
    
    console.log('\n' + '='.repeat(50));
    console.log('📊 테스트 결과 요약');
    console.log('='.repeat(50));
    console.log(`⏱️  총 실행 시간: ${(totalTime / 1000).toFixed(2)}초`);
    console.log(`✅ 성공: ${passed}개`);
    console.log(`❌ 실패: ${failed}개`);
    console.log(`📈 성공률: ${((passed / (passed + failed)) * 100).toFixed(1)}%`);
    
    console.log('\n📋 상세 결과:');
    this.testResults.forEach(result => {
      const status = result.status === 'passed' ? '✅' : '❌';
      console.log(`${status} ${result.test}: ${result.status}`);
      if (result.error) {
        console.log(`   오류: ${result.error}`);
      }
    });
    
    console.log('\n' + '='.repeat(50));
    
    if (failed === 0) {
      console.log('🎉 모든 테스트가 성공했습니다!');
    } else {
      console.log('⚠️  일부 테스트가 실패했습니다. 위의 오류 메시지를 확인하세요.');
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
  const testSuite = new BrowserableTestSuite();
  
  try {
    await testSuite.runAllTests();
    process.exit(0);
  } catch (error) {
    console.error('\n💥 테스트 실행 중 오류 발생:', error.message);
    console.error('\n🔧 해결 방법:');
    console.error('1. .env 파일에 BROWSERABLE_API_KEY 설정');
    console.error('2. Browserable 서버가 실행 중인지 확인 (http://localhost:2001)');
    console.error('3. 인터넷 연결 상태 확인');
    console.error('\n💡 팁:');
    console.error('- 전체 테스트 실행: RUN_FULL_TESTS=true npm test');
    console.error('- 기본 연결 테스트만: npm test');
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { BrowserableTestSuite };
