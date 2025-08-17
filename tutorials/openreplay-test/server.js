#!/usr/bin/env node

/**
 * OpenReplay 데모 서버
 * 간단한 Express 서버로 데모 페이지를 제공합니다.
 */

const express = require('express');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

// 정적 파일 제공
app.use(express.static(__dirname));

// CORS 헤더 추가
app.use((req, res, next) => {
    res.header('Access-Control-Allow-Origin', '*');
    res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
    next();
});

// 메인 페이지
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// API 엔드포인트들
app.get('/api/health', (req, res) => {
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        uptime: process.uptime()
    });
});

app.get('/api/demo-data', (req, res) => {
    const demoData = {
        message: 'OpenReplay 데모 API 응답',
        timestamp: new Date().toISOString(),
        data: {
            users: Math.floor(Math.random() * 1000),
            sessions: Math.floor(Math.random() * 500),
            events: Math.floor(Math.random() * 10000)
        }
    };
    
    res.json(demoData);
});

// 의도적으로 느린 API (성능 테스트용)
app.get('/api/slow', (req, res) => {
    const delay = parseInt(req.query.delay) || 2000;
    
    setTimeout(() => {
        res.json({
            message: '느린 API 응답',
            delay: delay,
            timestamp: new Date().toISOString()
        });
    }, delay);
});

// 오류 API (오류 테스트용)
app.get('/api/error', (req, res) => {
    const errorType = req.query.type || 'generic';
    
    const errors = {
        generic: { status: 500, message: '일반적인 서버 오류' },
        notfound: { status: 404, message: '리소스를 찾을 수 없음' },
        unauthorized: { status: 401, message: '인증이 필요함' },
        badrequest: { status: 400, message: '잘못된 요청' }
    };
    
    const error = errors[errorType] || errors.generic;
    res.status(error.status).json({
        error: error.message,
        timestamp: new Date().toISOString(),
        type: errorType
    });
});

// 404 핸들러
app.use((req, res) => {
    res.status(404).json({
        error: 'Page not found',
        path: req.path,
        timestamp: new Date().toISOString()
    });
});

// 에러 핸들러
app.use((err, req, res, next) => {
    console.error('서버 오류:', err);
    res.status(500).json({
        error: 'Internal server error',
        message: err.message,
        timestamp: new Date().toISOString()
    });
});

// 서버 시작
app.listen(PORT, () => {
    console.log(`
🚀 OpenReplay 데모 서버가 시작되었습니다!

📍 접속 URL: http://localhost:${PORT}
📋 사용 가능한 엔드포인트:
   • /                    - 메인 데모 페이지
   • /api/health          - 서버 상태 확인
   • /api/demo-data       - 데모 데이터 API
   • /api/slow?delay=ms   - 느린 API (성능 테스트용)
   • /api/error?type=X    - 오류 API (오류 테스트용)

💡 OpenReplay 서버가 실행 중인지 확인하세요:
   • 대시보드: http://localhost:9000
   • 인제스트: http://localhost:9000/ingest

🔧 디버그 정보는 브라우저 콘솔에서 showDebugInfo() 함수를 호출하세요.
    `);
});

// Graceful shutdown
process.on('SIGTERM', () => {
    console.log('SIGTERM 신호 수신, 서버 종료 중...');
    process.exit(0);
});

process.on('SIGINT', () => {
    console.log('\nSIGINT 신호 수신, 서버 종료 중...');
    process.exit(0);
});
