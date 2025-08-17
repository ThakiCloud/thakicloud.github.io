#!/usr/bin/env node

/**
 * GitHub 트렌딩 저장소 검색 예제
 * Browserable을 사용하여 GitHub의 트렌딩 저장소를 자동으로 찾는 스크립트
 */

import { Browserable } from 'browserable-js';
import dotenv from 'dotenv';

// 환경 변수 로드
dotenv.config();

class GitHubTrendingAgent {
  constructor() {
    this.browserable = new Browserable({
      apiKey: process.env.BROWSERABLE_API_KEY,
      baseUrl: process.env.BROWSERABLE_BASE_URL || 'http://localhost:2003',
      timeout: 90000,
      debug: process.env.DEBUG === 'true'
    });
  }

  async findTrendingRepos() {
    console.log('🔍 GitHub 트렌딩 저장소 검색 시작...');
    
    try {
      const task = await this.browserable.createTask({
        task: `Visit github.com/trending and extract the top 10 trending repositories today. 
               For each repository, get the name, description, programming language, 
               stars count, and link. Format the results as JSON.`,
        agent: 'BROWSER_AGENT',
        options: {
          headless: true,
          viewport: { width: 1920, height: 1080 },
          timeout: 120000
        }
      });
      
      console.log(`📝 작업 생성됨: ${task.taskId}`);
      console.log('⏳ 작업 완료 대기 중...');
      
      const result = await this.browserable.waitForRun(task.taskId, {
        pollInterval: 5000,
        maxWaitTime: 300000
      });
      
      return this.processResults(result);
      
    } catch (error) {
      console.error('❌ GitHub 트렌딩 검색 실패:', error.message);
      throw error;
    }
  }

  processResults(result) {
    if (!result.success) {
      throw new Error(`작업 실패: ${result.error}`);
    }
    
    console.log('✅ GitHub 트렌딩 저장소 검색 완료!');
    console.log('\n📊 결과:');
    
    if (result.data && result.data.repositories) {
      result.data.repositories.forEach((repo, index) => {
        console.log(`\n${index + 1}. ${repo.name}`);
        console.log(`   📝 설명: ${repo.description || 'N/A'}`);
        console.log(`   💻 언어: ${repo.language || 'N/A'}`);
        console.log(`   ⭐ 스타: ${repo.stars || 'N/A'}`);
        console.log(`   🔗 링크: ${repo.link || 'N/A'}`);
      });
    } else {
      console.log('📋 추출된 저장소 정보:');
      console.log(JSON.stringify(result.data, null, 2));
    }
    
    return result;
  }

  async validateEnvironment() {
    console.log('🔧 환경 설정 검증 중...');
    
    if (!process.env.BROWSERABLE_API_KEY) {
      throw new Error('BROWSERABLE_API_KEY 환경 변수가 설정되지 않았습니다.');
    }
    
    console.log('✅ 환경 설정 검증 완료');
  }
}

// 메인 실행 함수
async function main() {
  const agent = new GitHubTrendingAgent();
  
  try {
    await agent.validateEnvironment();
    const result = await agent.findTrendingRepos();
    
    console.log('\n🎉 GitHub 트렌딩 검색 완료!');
    process.exit(0);
    
  } catch (error) {
    console.error('\n💥 실행 중 오류 발생:', error.message);
    console.error('\n🔧 해결 방법:');
    console.error('1. .env 파일에 BROWSERABLE_API_KEY 설정');
    console.error('2. Browserable 서버가 실행 중인지 확인');
    console.error('3. 네트워크 연결 상태 확인');
    process.exit(1);
  }
}

// 스크립트가 직접 실행되는 경우에만 main 함수 호출
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export { GitHubTrendingAgent };
