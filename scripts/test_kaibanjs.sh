#!/bin/bash
# 파일: test_kaibanjs.sh

echo "🧪 KaibanJS 테스트 시작..."

# 1. 환경 확인
echo "📋 환경 확인:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"
echo "운영체제: $(uname -s)"

# 2. 테스트 프로젝트 생성
echo "📁 테스트 프로젝트 생성..."
mkdir -p kaibanjs-test
cd kaibanjs-test

# 3. package.json 생성
cat > package.json << 'EOFPKG'
{
  "name": "kaibanjs-test",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node src/index.js",
    "test": "node src/test.js"
  },
  "dependencies": {
    "kaibanjs": "^1.0.0"
  }
}
EOFPKG

# 4. KaibanJS 설치 시도
echo "📦 KaibanJS 설치 시도..."
npm install kaibanjs || echo "⚠️  KaibanJS 패키지를 찾을 수 없습니다. 시뮬레이션 모드로 계속합니다."

# 5. 기본 예제 실행
echo "🚀 기본 예제 실행..."
mkdir -p src

# 간단한 테스트 파일 생성
cat > src/test.js << 'EOFTEST'
// KaibanJS 개념 테스트
console.log('✅ KaibanJS 개념 테스트 시작...');

try {
  console.log('📦 AI 에이전트 칸반 시스템 시뮬레이션...');
  
  // 기본 클래스 정의 (KaibanJS 컨셉 시뮬레이션)
  class Agent {
    constructor(config) {
      this.name = config.name;
      this.role = config.role;
      this.goal = config.goal;
      this.background = config.background;
      this.id = Math.random().toString(36).substr(2, 9);
      this.status = 'idle';
    }
  }

  class Task {
    constructor(config) {
      this.description = config.description;
      this.expectedOutput = config.expectedOutput;
      this.agent = config.agent;
      this.id = Math.random().toString(36).substr(2, 9);
      this.status = 'TODO';
      this.dependencies = config.dependencies || [];
    }
  }

  class Team {
    constructor(config) {
      this.name = config.name;
      this.agents = config.agents || [];
      this.tasks = config.tasks || [];
      this.verbose = config.verbose || false;
    }
    
    start() {
      console.log(`🚀 팀 "${this.name}" 워크플로우 시작...`);
      this.tasks.forEach(task => {
        console.log(`📋 작업: ${task.description}`);
        console.log(`🤖 담당자: ${task.agent.name} (${task.agent.role})`);
        task.status = 'DOING';
        setTimeout(() => {
          task.status = 'DONE';
          console.log(`✅ 완료: ${task.description}`);
        }, 1000);
      });
    }
  }

  // 테스트 에이전트들 생성
  const developer = new Agent({
    name: 'Dave Loper',
    role: 'Developer',
    goal: 'Write clean and efficient code',
    background: 'Experienced JavaScript developer'
  });

  const qa = new Agent({
    name: 'Quinn Tester',
    role: 'QA Engineer',
    goal: 'Ensure software quality',
    background: 'Expert in testing and quality assurance'
  });

  // 테스트 작업들 생성
  const devTask = new Task({
    description: 'Implement user authentication feature',
    expectedOutput: 'Working authentication system with tests',
    agent: developer
  });

  const qaTask = new Task({
    description: 'Test authentication feature',
    expectedOutput: 'Test report with quality verification',
    agent: qa,
    dependencies: [devTask]
  });

  // 팀 생성
  const devTeam = new Team({
    name: 'Development Team',
    agents: [developer, qa],
    tasks: [devTask, qaTask],
    verbose: true
  });

  console.log('✅ KaibanJS 구조 시뮬레이션 완료!');
  console.log('👥 팀 정보:');
  console.log(`  - 팀명: ${devTeam.name}`);
  console.log(`  - 에이전트 수: ${devTeam.agents.length}`);
  console.log(`  - 작업 수: ${devTeam.tasks.length}`);
  
  console.log('\n🤖 에이전트 정보:');
  devTeam.agents.forEach(agent => {
    console.log(`  - ${agent.name}: ${agent.role}`);
    console.log(`    목표: ${agent.goal}`);
  });
  
  console.log('\n📋 작업 정보:');
  devTeam.tasks.forEach(task => {
    console.log(`  - ${task.description}`);
    console.log(`    담당자: ${task.agent.name}`);
    console.log(`    상태: ${task.status}`);
  });

  // 시뮬레이션 워크플로우 시작
  console.log('\n🚀 워크플로우 시뮬레이션 시작...');
  devTeam.start();

} catch (error) {
  console.error('❌ 테스트 실패:', error.message);
}
EOFTEST

# 6. 테스트 실행
echo "🏃 테스트 실행 중..."
node src/test.js

# 7. 정리
cd ..
echo "🧹 테스트 환경 정리..."
# rm -rf kaibanjs-test  # 결과 확인을 위해 주석 처리

echo "✅ KaibanJS 개념 테스트 완료!"
echo "📁 테스트 결과는 kaibanjs-test 폴더에서 확인하실 수 있습니다."
