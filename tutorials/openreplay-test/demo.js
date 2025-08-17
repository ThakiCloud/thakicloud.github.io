// OpenReplay 데모 JavaScript

// OpenReplay 트래커 초기화
let tracker;
let counter = 0;
let metricsLog = [];

// 설정 값 (실제 환경에서는 환경 변수에서 가져옴)
const OPENREPLAY_CONFIG = {
    projectKey: "YOUR_PROJECT_KEY", // 실제 프로젝트 키로 교체
    ingestPoint: "http://localhost:9000/ingest", // 로컬 OpenReplay 서버
    __debug_mode: true // 디버그 모드
};

// OpenReplay 트래커 초기화 함수
async function initializeOpenReplay() {
    try {
        // 동적 import (CDN 사용)
        const { default: Tracker } = await import('https://unpkg.com/@openreplay/tracker@latest/lib/index.js');
        
        tracker = new Tracker({
            projectKey: OPENREPLAY_CONFIG.projectKey,
            ingestPoint: OPENREPLAY_CONFIG.ingestPoint,
            __debug_mode: OPENREPLAY_CONFIG.__debug_mode,
            
            // 프라이버시 설정
            obscureInputs: false, // 데모를 위해 비활성화
            obscureTextNumbers: false,
            obscureTextEmails: false,
            
            // 성능 설정
            capturePerformance: true,
            captureResourceTimings: true
        });

        await tracker.start();
        
        // 사용자 정보 설정
        tracker.setUserID('demo-user-' + Date.now());
        tracker.setMetadata('demo_version', '1.0.0');
        tracker.setMetadata('test_mode', 'enabled');
        tracker.setMetadata('user_agent', navigator.userAgent);
        
        // 초기 페이지 뷰 이벤트
        tracker.event('demo_page_loaded', {
            page: 'index',
            timestamp: Date.now(),
            viewport: {
                width: window.innerWidth,
                height: window.innerHeight
            }
        });

        updateSessionStatus('✅ OpenReplay 연결됨', 'success');
        console.log('OpenReplay 트래커 초기화 완료');
        
        // 글로벌 오류 핸들러 설정
        setupGlobalErrorHandlers();
        
    } catch (error) {
        console.error('OpenReplay 초기화 실패:', error);
        updateSessionStatus('❌ OpenReplay 연결 실패', 'error');
        
        // 폴백: 로컬 트래커 시뮬레이션
        setupMockTracker();
    }
}

// 목업 트래커 설정 (OpenReplay 서버가 없는 경우)
function setupMockTracker() {
    tracker = {
        event: (name, data) => {
            console.log(`[Mock Tracker] Event: ${name}`, data);
            addMetricsLog(`Event: ${name}`, data);
        },
        setMetadata: (key, value) => {
            console.log(`[Mock Tracker] Metadata: ${key} = ${value}`);
        },
        setUserID: (id) => {
            console.log(`[Mock Tracker] User ID: ${id}`);
        },
        getUserID: () => 'mock-user-123',
        getSessionToken: () => 'mock-session-token'
    };
    
    updateSessionStatus('🔧 목업 모드로 실행 중', 'info');
}

// 세션 상태 업데이트
function updateSessionStatus(message, type) {
    const statusElement = document.getElementById('session-status');
    statusElement.textContent = message;
    statusElement.className = `status-indicator status-${type}`;
}

// 글로벌 오류 핸들러 설정
function setupGlobalErrorHandlers() {
    window.addEventListener('error', (event) => {
        tracker.event('javascript_error', {
            message: event.message,
            filename: event.filename,
            lineno: event.lineno,
            colno: event.colno,
            stack: event.error?.stack,
            timestamp: Date.now()
        });
    });

    window.addEventListener('unhandledrejection', (event) => {
        tracker.event('unhandled_promise_rejection', {
            reason: event.reason?.toString(),
            timestamp: Date.now()
        });
    });
}

// 카운터 기능
function incrementCounter() {
    counter++;
    document.getElementById('counter').textContent = counter;
    
    tracker.event('counter_incremented', {
        new_value: counter,
        timestamp: Date.now()
    });
}

function decrementCounter() {
    counter--;
    document.getElementById('counter').textContent = counter;
    
    tracker.event('counter_decremented', {
        new_value: counter,
        timestamp: Date.now()
    });
}

function resetCounter() {
    const oldValue = counter;
    counter = 0;
    document.getElementById('counter').textContent = counter;
    
    tracker.event('counter_reset', {
        old_value: oldValue,
        new_value: counter,
        timestamp: Date.now()
    });
}

// 폼 처리
document.getElementById('demo-form').addEventListener('submit', function(e) {
    e.preventDefault();
    
    const formData = new FormData(this);
    const formObject = Object.fromEntries(formData.entries());
    
    tracker.event('demo_form_submitted', {
        form_data: formObject,
        field_count: Object.keys(formObject).length,
        has_required_fields: !!(formObject.username && formObject.email),
        timestamp: Date.now()
    });
    
    // 사용자 메타데이터 업데이트
    if (formObject.username) {
        tracker.setMetadata('username', formObject.username);
    }
    if (formObject.email) {
        tracker.setMetadata('email', formObject.email);
    }
    
    alert('폼이 제출되었습니다! 세션 리플레이에서 확인할 수 있습니다.');
});

// API 호출 테스트
async function testApiCall() {
    const startTime = Date.now();
    
    tracker.event('api_test_started', {
        endpoint: '/test',
        timestamp: startTime
    });
    
    try {
        const response = await fetch('https://jsonplaceholder.typicode.com/posts/1');
        const data = await response.json();
        const duration = Date.now() - startTime;
        
        tracker.event('api_test_success', {
            endpoint: '/test',
            status: response.status,
            duration: duration,
            response_size: JSON.stringify(data).length,
            timestamp: Date.now()
        });
        
        document.getElementById('api-result').innerHTML = 
            `<div class="status-success">✅ API 호출 성공 (${duration}ms)</div>`;
            
    } catch (error) {
        const duration = Date.now() - startTime;
        
        tracker.event('api_test_failed', {
            endpoint: '/test',
            error_message: error.message,
            duration: duration,
            timestamp: Date.now()
        });
        
        document.getElementById('api-result').innerHTML = 
            `<div class="status-error">❌ API 호출 실패: ${error.message}</div>`;
    }
}

async function testFailedApi() {
    const startTime = Date.now();
    
    try {
        await fetch('https://nonexistent-api.invalid/data');
    } catch (error) {
        const duration = Date.now() - startTime;
        
        tracker.event('api_test_intentional_failure', {
            endpoint: '/invalid',
            error_message: error.message,
            duration: duration,
            timestamp: Date.now()
        });
        
        document.getElementById('api-result').innerHTML = 
            `<div class="status-error">⚠️ 의도적 API 실패 테스트 완료</div>`;
    }
}

// 오류 테스트 함수들
function triggerJSError() {
    tracker.event('intentional_error_triggered', {
        error_type: 'javascript',
        timestamp: Date.now()
    });
    
    try {
        // 의도적으로 오류 발생
        nonExistentFunction();
    } catch (error) {
        console.error('의도적 JavaScript 오류:', error);
    }
}

function triggerConsoleError() {
    tracker.event('intentional_error_triggered', {
        error_type: 'console',
        timestamp: Date.now()
    });
    
    console.error('이것은 의도적인 콘솔 오류입니다');
    console.warn('이것은 의도적인 경고 메시지입니다');
}

function triggerNetworkError() {
    tracker.event('intentional_error_triggered', {
        error_type: 'network',
        timestamp: Date.now()
    });
    
    fetch('https://invalid-domain-for-testing.invalid')
        .catch(error => {
            console.error('의도적 네트워크 오류:', error);
        });
}

// 성능 테스트
function testPerformance() {
    const startTime = performance.now();
    
    // CPU 집약적인 작업 시뮬레이션
    let result = 0;
    for (let i = 0; i < 1000000; i++) {
        result += Math.random();
    }
    
    const endTime = performance.now();
    const duration = endTime - startTime;
    
    tracker.event('performance_test_completed', {
        operation: 'cpu_intensive',
        duration: duration,
        result: result,
        timestamp: Date.now()
    });
    
    document.getElementById('performance-result').innerHTML = 
        `<div class="status-info">⚡ 성능 테스트 완료: ${duration.toFixed(2)}ms</div>`;
}

function simulateSlowOperation() {
    const startTime = Date.now();
    
    tracker.event('slow_operation_started', {
        operation: 'simulated_delay',
        timestamp: startTime
    });
    
    // 인위적 지연
    setTimeout(() => {
        const duration = Date.now() - startTime;
        
        tracker.event('slow_operation_completed', {
            operation: 'simulated_delay',
            duration: duration,
            timestamp: Date.now()
        });
        
        document.getElementById('performance-result').innerHTML = 
            `<div class="status-info">🐌 느린 작업 시뮬레이션 완료: ${duration}ms</div>`;
    }, 2000);
    
    document.getElementById('performance-result').innerHTML = 
        `<div class="status-info">⏳ 느린 작업 진행 중...</div>`;
}

// 호버 이벤트 처리
function handleHover(element) {
    element.style.transform = 'scale(1.1)';
    element.style.transition = 'transform 0.3s ease';
    
    tracker.event('button_hovered', {
        button_text: element.textContent,
        timestamp: Date.now()
    });
}

function handleHoverOut(element) {
    element.style.transform = 'scale(1)';
}

// 복잡한 상호작용 시뮬레이션
function simulateComplexInteraction() {
    tracker.event('complex_interaction_started', {
        timestamp: Date.now()
    });
    
    // 여러 DOM 조작 수행
    const elements = document.querySelectorAll('button');
    elements.forEach((button, index) => {
        setTimeout(() => {
            button.style.backgroundColor = '#e74c3c';
            setTimeout(() => {
                button.style.backgroundColor = '';
            }, 200);
        }, index * 100);
    });
    
    tracker.event('complex_interaction_completed', {
        affected_elements: elements.length,
        duration: elements.length * 100 + 200,
        timestamp: Date.now()
    });
}

// 실시간 지원 기능
function requestSupport() {
    tracker.event('support_requested', {
        request_type: 'general',
        timestamp: Date.now()
    });
    
    document.getElementById('support-status').innerHTML = 
        `<div class="status-info">📞 고객 지원이 요청되었습니다</div>`;
}

function startScreenShare() {
    tracker.event('screen_share_requested', {
        timestamp: Date.now()
    });
    
    // 실제 화면 공유는 Assist 플러그인을 통해 처리됨
    document.getElementById('support-status').innerHTML = 
        `<div class="status-info">🖥️ 화면 공유가 요청되었습니다</div>`;
}

// 분석 및 메트릭
function trackConversion() {
    const conversion = {
        type: 'demo_conversion',
        value: Math.floor(Math.random() * 100) + 1,
        currency: 'USD',
        timestamp: Date.now()
    };
    
    tracker.event('conversion_tracked', conversion);
    addMetricsLog('Conversion', conversion);
}

function trackEngagement() {
    const engagement = {
        action: 'demo_engagement',
        duration: Math.floor(Math.random() * 300) + 30,
        interactions: Math.floor(Math.random() * 20) + 1,
        scroll_depth: Math.floor(Math.random() * 100),
        timestamp: Date.now()
    };
    
    tracker.event('engagement_tracked', engagement);
    addMetricsLog('Engagement', engagement);
}

function trackFeatureUsage() {
    const feature = {
        feature_name: 'demo_feature_' + Math.floor(Math.random() * 5),
        usage_count: Math.floor(Math.random() * 10) + 1,
        user_type: 'demo_user',
        timestamp: Date.now()
    };
    
    tracker.event('feature_usage_tracked', feature);
    addMetricsLog('Feature Usage', feature);
}

// 메트릭 로그 추가
function addMetricsLog(type, data) {
    metricsLog.push({ type, data, timestamp: new Date().toLocaleTimeString() });
    
    const logElement = document.getElementById('metrics-log');
    const logEntry = `[${new Date().toLocaleTimeString()}] ${type}: ${JSON.stringify(data, null, 2)}\n`;
    logElement.textContent += logEntry;
    logElement.scrollTop = logElement.scrollHeight;
}

// 스크롤 이벤트 추적
let lastScrollTime = 0;
window.addEventListener('scroll', function() {
    const currentTime = Date.now();
    
    // 스크롤 이벤트 스로틀링 (100ms)
    if (currentTime - lastScrollTime > 100) {
        lastScrollTime = currentTime;
        
        const scrollPercentage = Math.round((window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100);
        
        tracker.event('page_scrolled', {
            scroll_percentage: scrollPercentage,
            scroll_position: window.scrollY,
            timestamp: currentTime
        });
    }
});

// 페이지 떠날 때 이벤트
window.addEventListener('beforeunload', function() {
    tracker.event('page_unload', {
        session_duration: Date.now() - sessionStartTime,
        timestamp: Date.now()
    });
});

// 페이지 로드 완료 시 초기화
const sessionStartTime = Date.now();
document.addEventListener('DOMContentLoaded', function() {
    console.log('OpenReplay 데모 페이지 로드됨');
    initializeOpenReplay();
});

// 유틸리티 함수: 랜덤 데이터 생성
function generateRandomData() {
    return {
        id: Math.random().toString(36).substr(2, 9),
        timestamp: Date.now(),
        value: Math.floor(Math.random() * 1000),
        category: ['A', 'B', 'C'][Math.floor(Math.random() * 3)]
    };
}

// 디버그 정보 표시
function showDebugInfo() {
    console.log('=== OpenReplay 데모 디버그 정보 ===');
    console.log('트래커 상태:', tracker ? '활성' : '비활성');
    console.log('카운터 값:', counter);
    console.log('세션 시작 시간:', new Date(sessionStartTime).toLocaleString());
    console.log('메트릭 로그 수:', metricsLog.length);
    console.log('사용자 에이전트:', navigator.userAgent);
    console.log('뷰포트 크기:', window.innerWidth + 'x' + window.innerHeight);
}

// 전역 디버그 함수 등록
window.showDebugInfo = showDebugInfo;
