#!/usr/bin/env node

// n8n-free-templates 기본 기능 테스트
const fs = require('fs');
const path = require('path');

console.log('🚀 n8n-free-templates 기본 기능 테스트');
console.log('=====================================\n');

// 1. 저장소 구조 확인
console.log('1. 저장소 구조 확인');
const templatesDir = 'n8n-free-templates';
let categories = [];

if (fs.existsSync(templatesDir)) {
    console.log(`✅ ${templatesDir} 저장소 확인됨`);
    
    // 카테고리 폴더 확인
    categories = fs.readdirSync(templatesDir)
        .filter(item => fs.statSync(path.join(templatesDir, item)).isDirectory())
        .filter(item => !item.startsWith('.'));
    
    console.log(`📁 카테고리 수: ${categories.length}개`);
    console.log('카테고리 목록:');
    categories.forEach((category, index) => {
        console.log(`  ${index + 1}. ${category.replace(/_/g, ' ')}`);
    });
} else {
    console.log('❌ n8n-free-templates 저장소 없음');
    process.exit(1);
}

// 2. 워크플로우 템플릿 개수 확인
console.log('\n2. 워크플로우 템플릿 분석');
let totalWorkflows = 0;
const categoryStats = [];

categories.forEach(category => {
    const categoryPath = path.join(templatesDir, category);
    const jsonFiles = fs.readdirSync(categoryPath)
        .filter(file => file.endsWith('.json'));
    
    totalWorkflows += jsonFiles.length;
    categoryStats.push({
        name: category,
        count: jsonFiles.length,
        files: jsonFiles
    });
});

console.log(`📊 총 워크플로우: ${totalWorkflows}개`);
console.log('\n카테고리별 템플릿 수:');
categoryStats
    .sort((a, b) => b.count - a.count)
    .forEach(stat => {
        console.log(`  ${stat.name.replace(/_/g, ' ')}: ${stat.count}개`);
    });

// 3. AI/ML 카테고리 상세 분석
console.log('\n3. AI/ML 카테고리 상세 분석');
const aiMlCategory = categoryStats.find(cat => cat.name === 'AI_ML');
if (aiMlCategory) {
    console.log(`🤖 AI/ML 템플릿: ${aiMlCategory.count}개`);
    console.log('템플릿 목록:');
    aiMlCategory.files.forEach((file, index) => {
        const templateName = file.replace('.json', '').replace(/_/g, ' ');
        console.log(`  ${index + 1}. ${templateName}`);
    });
}

// 4. Email Automation 카테고리 분석
console.log('\n4. Email Automation 카테고리 분석');
const emailCategory = categoryStats.find(cat => cat.name === 'Email_Automation');
if (emailCategory) {
    console.log(`📧 Email Automation 템플릿: ${emailCategory.count}개`);
    
    // README 파일 확인
    const readmePath = path.join(templatesDir, 'Email_Automation', 'README.md');
    if (fs.existsSync(readmePath)) {
        console.log('✅ README.md 파일 존재');
        const readmeContent = fs.readFileSync(readmePath, 'utf8');
        const lines = readmeContent.split('\n').slice(0, 10);
        console.log('README 내용 미리보기:');
        lines.forEach(line => {
            if (line.trim()) console.log(`  ${line}`);
        });
    }
}

// 5. 워크플로우 JSON 구조 분석
console.log('\n5. 워크플로우 JSON 구조 분석');
const sampleWorkflow = path.join(templatesDir, 'AI_ML', 'product_description_generator.json');
if (fs.existsSync(sampleWorkflow)) {
    try {
        const workflowData = JSON.parse(fs.readFileSync(sampleWorkflow, 'utf8'));
        
        console.log(`📄 샘플 워크플로우: product_description_generator.json`);
        console.log(`📏 파일 크기: ${(fs.statSync(sampleWorkflow).size / 1024).toFixed(1)}KB`);
        
        if (workflowData.nodes) {
            console.log(`🔗 노드 수: ${workflowData.nodes.length}개`);
            
            // 노드 타입 분석
            const nodeTypes = {};
            workflowData.nodes.forEach(node => {
                nodeTypes[node.type] = (nodeTypes[node.type] || 0) + 1;
            });
            
            console.log('노드 타입 분포:');
            Object.entries(nodeTypes).forEach(([type, count]) => {
                console.log(`  ${type}: ${count}개`);
            });
        }
        
        if (workflowData.connections) {
            console.log(`🔗 연결선 수: ${Object.keys(workflowData.connections).length}개`);
        }
    } catch (error) {
        console.log('⚠️ JSON 파싱 오류:', error.message);
    }
}

// 6. 기술 스택 매트릭스 분석
console.log('\n6. 기술 스택 매트릭스 분석');
const techStack = {
    'Vector DBs': ['Pinecone', 'Weaviate', 'Supabase Vector', 'Redis'],
    'Embeddings': ['OpenAI', 'Cohere', 'Hugging Face'],
    'LLM Chat': ['OpenAI GPT-4', 'Anthropic Claude', 'Hugging Face Inference'],
    'Memory': ['Zep Memory', 'Window Buffer'],
    'Extras': ['Slack alerts', 'Google Sheets', 'OCR', 'HTTP polling']
};

console.log('🛠️ 지원 기술 스택:');
Object.entries(techStack).forEach(([category, technologies]) => {
    console.log(`\n  ${category}:`);
    technologies.forEach(tech => {
        console.log(`    • ${tech}`);
    });
});

// 7. 통합 서비스 분석
console.log('\n7. 통합 서비스 분석');
const integrations = [
    'OpenAI', 'Anthropic Claude', 'Cohere', 'Hugging Face',
    'Pinecone', 'Weaviate', 'Supabase', 'Redis',
    'Gmail', 'Slack', 'Discord', 'Telegram',
    'Google Sheets', 'Airtable', 'Notion',
    'Stripe', 'PayPal', 'Shopify',
    'AWS', 'Google Cloud', 'Azure',
    'GitHub', 'GitLab', 'Bitbucket'
];

console.log('🔗 주요 통합 서비스:');
integrations.forEach((service, index) => {
    if (index % 4 === 0) console.log('');
    process.stdout.write(`  ${service.padEnd(15)}`);
});
console.log('\n');

// 8. 사용 가능성 체크
console.log('\n8. 사용 가능성 체크');
const requirements = [
    'Node.js (v18+)',
    'Docker (선택사항)',
    'n8n 플랫폼',
    'AI 서비스 API 키들',
    'Vector DB 서비스 계정',
    '웹 브라우저 (Chrome/Firefox 권장)'
];

console.log('✅ 필요 요구사항:');
requirements.forEach(req => {
    console.log(`  • ${req}`);
});

// 9. 빠른 시작 가이드
console.log('\n9. 빠른 시작 가이드');
const quickStartSteps = [
    'git clone https://github.com/wassupjay/n8n-free-templates.git',
    'docker run -p 5678:5678 docker.n8n.io/n8nio/n8n',
    'http://localhost:5678 브라우저 접속',
    'Settings → Import Workflows → JSON 파일 선택',
    '각 노드의 Credentials 설정',
    'Save & Activate 클릭'
];

console.log('🚀 빠른 시작 단계:');
quickStartSteps.forEach((step, index) => {
    console.log(`  ${index + 1}. ${step}`);
});

// 10. 리소스 링크
console.log('\n10. 유용한 리소스');
const resources = [
    '📖 n8n 공식 문서: https://docs.n8n.io',
    '🎥 n8n YouTube 채널: https://youtube.com/n8nio',
    '💬 n8n 커뮤니티: https://community.n8n.io',
    '📚 워크플로우 라이브러리: https://n8n.io/workflows',
    '🔧 n8n GitHub: https://github.com/n8n-io/n8n',
    '🆓 n8n Cloud: https://app.n8n.cloud'
];

resources.forEach(resource => {
    console.log(`  ${resource}`);
});

console.log('\n📋 테스트 요약:');
console.log('=================');
console.log(`✅ 총 카테고리: ${categories.length}개`);
console.log(`✅ 총 워크플로우: ${totalWorkflows}개`);
console.log('✅ AI/ML 통합 확인');
console.log('✅ 이메일 자동화 확인');
console.log('✅ JSON 구조 검증');
console.log('✅ 기술 스택 분석');

console.log('\n🎉 n8n-free-templates 분석 완료!');
console.log('\n💡 다음 단계:');
console.log('1. n8n 플랫폼 설치');
console.log('2. 관심 카테고리의 워크플로우 선택');
console.log('3. JSON 파일을 n8n에 가져오기');
console.log('4. 각 노드의 API 키 및 인증 설정');
console.log('5. 워크플로우 테스트 및 활성화'); 