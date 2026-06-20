---
title: "Apprise: 클라우드 기업을 위한 통합 알림 플랫폼 구축 완전 가이드"
excerpt: "13.9k 스타의 Apprise로 클라우드 인프라 모니터링부터 고객 알림까지, 엔터프라이즈급 통합 알림 시스템을 macOS에서 실습과 함께 구축해보세요."
seo_title: "Apprise 클라우드 알림 플랫폼 Python BSD 라이센스 완벽 가이드 - Thaki Cloud"
seo_description: "Python 기반 Apprise 프레임워크로 클라우드 기업의 인프라 모니터링, CI/CD, 보안 알림 시스템을 구축하는 방법을 BSD 라이센스 분석과 함께 상세히 알아봅니다."
date: 2025-07-06
last_modified_at: 2025-07-06
categories:
  - tutorials
tags:
  - apprise
  - notification
  - python
  - cloud
  - monitoring
  - alerts
  - enterprise
  - bsd-license
  - devops
  - infrastructure
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/apprise-cloud-notification-platform-tutorial/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 15분

## 서론

현대 클라우드 기업들은 복잡한 인프라와 서비스를 운영하면서 실시간 모니터링과 알림이 필수가 되었습니다. 서버 장애, CI/CD 파이프라인 상태, 보안 이벤트, 고객 서비스 이슈 등 다양한 상황에서 즉각적인 알림이 비즈니스 연속성을 좌우합니다.

[Apprise](https://github.com/caronc/apprise)는 이러한 요구를 해결하는 강력한 통합 알림 프레임워크입니다. 13.9k GitHub 스타를 받으며 검증된 이 Python 라이브러리는 70개 이상의 알림 서비스를 단일 API로 통합하여 제공합니다.

본 튜토리얼에서는 클라우드 기업이 Apprise를 활용하여 어떻게 엔터프라이즈급 알림 시스템을 구축할 수 있는지, 라이센스 고려사항부터 실제 구현까지 macOS 환경에서 실습과 함께 알아보겠습니다.

## Apprise란?

### 핵심 특징

**🔗 통합 알림 플랫폼**
- 70개 이상의 알림 서비스 지원
- Discord, Slack, Telegram, Teams, Email 등
- 단일 API로 모든 플랫폼 제어
- 플러그인 아키텍처로 확장 가능

**🏢 엔터프라이즈 친화적**
- BSD-2-Clause 라이센스 (상업적 사용 가능)
- Python 기반으로 높은 확장성
- CLI와 API 모두 지원
- Docker 컨테이너 제공

**⚡ 고성능 및 안정성**
- 비동기 처리 지원
- Persistent Storage로 안정성 보장
- 에러 핸들링 및 재시도 메커니즘
- 대용량 트래픽 처리 가능

**🔧 개발자 친화적**
- 직관적인 URL 기반 설정
- Configuration 파일 지원
- 커스텀 플러그인 개발 가능
- 풍부한 문서화

### 기술 스택

**언어**: Python 99.5%
**라이센스**: BSD-2-Clause
**아키텍처**: 플러그인 기반 모듈러
**배포**: PyPI, Docker Hub
**지원 플랫폼**: 크로스 플랫폼

## 라이센스 분석 및 상업적 활용

### BSD-2-Clause 라이센스 주요 내용

Apprise는 **BSD-2-Clause 라이센스**를 사용하여 상업적 활용에 매우 우호적입니다:

**✅ 허용사항**
- **상업적 사용**: 클라우드 서비스에서 자유롭게 사용 가능
- **수정 및 배포**: 소스코드 수정하여 재배포 가능
- **사적 사용**: 내부 도구로 활용 가능
- **특허 사용**: 관련 특허도 자유롭게 사용 가능

**📋 의무사항**
- **저작권 고지**: 라이센스 및 저작권 표시 포함
- **면책 조항**: "AS IS" 면책 조항 포함

**❌ 제한사항**
- **보증 없음**: 소프트웨어 품질에 대한 보증 없음
- **책임 제한**: 사용으로 인한 손해에 대해 책임 없음

### 클라우드 기업 활용 시 고려사항

```text
# 라이센스 컴플라이언스 체크리스트

1. ✅ SaaS 플랫폼에서 Apprise 사용 가능
2. ✅ 고객에게 알림 서비스 제공 가능
3. ✅ 내부 모니터링 시스템 구축 가능
4. ✅ 상용 제품에 통합 가능
5. ✅ 소스코드 수정하여 커스터마이징 가능
6. ⚠️ 법무팀과 라이센스 검토 권장
7. ⚠️ 제3자 서비스 연동 시 각 서비스 ToS 확인 필요
```

## 시스템 요구사항 및 설치

### macOS 환경 설정

```bash
# Python 환경 확인
python3 --version
pip3 --version

# 가상환경 생성 권장
python3 -m venv apprise-env
source apprise-env/bin/activate

# 시스템 패키지 업데이트
brew update
brew install python@3.11  # 최신 Python 사용 권장
```

### Apprise 설치 방법

#### 방법 1: pip 설치 (권장)

```bash
# 기본 설치
pip install apprise

# 모든 플러그인 포함 설치 (권장)
pip install apprise[all]

# 특정 서비스만 설치
pip install apprise[discord,slack,telegram]

# 설치 확인
apprise --version
python -c "import apprise; print(apprise.__version__)"
```

#### 방법 2: Docker 설치

```bash
# Docker 이미지 다운로드
docker pull caronc/apprise:latest

# Docker로 테스트 실행
docker run --rm caronc/apprise:latest apprise --version

# 설정 파일과 함께 실행용 디렉토리 생성
mkdir -p ~/apprise-config
cd ~/apprise-config
```

#### 방법 3: 소스코드 설치

```bash
# 소스코드 클론
git clone https://github.com/caronc/apprise.git
cd apprise

# 개발 모드로 설치
pip install -e .

# 의존성 설치
pip install -r all-plugin-requirements.txt

# 테스트 실행
python -m pytest test/
```

### 설치 검증 스크립트

```bash
#!/bin/bash
# 파일명: verify_apprise.sh

echo "🔍 Apprise 설치 검증 스크립트"

# Python 환경 확인
echo "📊 Python 환경:"
python3 --version
which python3

# Apprise 버전 확인
echo "📦 Apprise 버전:"
apprise --version 2>/dev/null || echo "CLI 설치 필요"
python3 -c "import apprise; print(f'Python 모듈: {apprise.__version__}')" 2>/dev/null || echo "Python 모듈 설치 필요"

# 지원 서비스 확인
echo "🔌 지원 서비스 목록:"
apprise --details 2>/dev/null | head -20 || echo "지원 서비스 목록 조회 실패"

# 테스트 알림 (로컬 파일)
echo "🧪 기본 기능 테스트:"
echo "Apprise 테스트 완료" > /tmp/apprise-test.log
apprise -t "테스트 제목" -b "Apprise 설치 및 설정이 완료되었습니다." \
  "file:///tmp/apprise-test.log" && echo "✅ 기본 테스트 성공" || echo "❌ 기본 테스트 실패"

echo "🎉 Apprise 검증 완료!"
```

## 클라우드 기업 활용 시나리오

### 1. 인프라 모니터링 알림

```python
#!/usr/bin/env python3
# 파일명: infrastructure_monitor.py

import apprise
import psutil
import time
from datetime import datetime

class InfrastructureMonitor:
    def __init__(self):
        self.apobj = apprise.Apprise()
        
        # 다양한 알림 채널 설정
        self.setup_notification_channels()
        
        # 임계값 설정
        self.thresholds = {
            'cpu_percent': 80.0,
            'memory_percent': 85.0,
            'disk_percent': 90.0,
            'load_average': 4.0
        }
    
    def setup_notification_channels(self):
        """알림 채널 설정"""
        # Slack - 인프라팀
        self.apobj.add('slack://token/channel')
        
        # Discord - DevOps팀
        self.apobj.add('discord://webhook_id/webhook_token')
        
        # Telegram - 긴급 알림
        self.apobj.add('tgram://bot_token/chat_id')
        
        # Email - 관리자
        self.apobj.add('mailto://user:pass@gmail.com')
        
        # Microsoft Teams - 경영진
        self.apobj.add('msteams://webhook_url')
    
    def check_cpu_usage(self):
        """CPU 사용량 모니터링"""
        cpu_percent = psutil.cpu_percent(interval=1)
        
        if cpu_percent > self.thresholds['cpu_percent']:
            return {
                'alert': True,
                'level': 'warning' if cpu_percent < 95 else 'critical',
                'metric': 'CPU 사용률',
                'value': f"{cpu_percent:.1f}%",
                'threshold': f"{self.thresholds['cpu_percent']:.1f}%"
            }
        return {'alert': False}
    
    def check_memory_usage(self):
        """메모리 사용량 모니터링"""
        memory = psutil.virtual_memory()
        
        if memory.percent > self.thresholds['memory_percent']:
            return {
                'alert': True,
                'level': 'warning' if memory.percent < 95 else 'critical',
                'metric': '메모리 사용률',
                'value': f"{memory.percent:.1f}%",
                'threshold': f"{self.thresholds['memory_percent']:.1f}%",
                'available': f"{memory.available / (1024**3):.1f}GB"
            }
        return {'alert': False}
    
    def check_disk_usage(self):
        """디스크 사용량 모니터링"""
        disk = psutil.disk_usage('/')
        disk_percent = (disk.used / disk.total) * 100
        
        if disk_percent > self.thresholds['disk_percent']:
            return {
                'alert': True,
                'level': 'warning' if disk_percent < 95 else 'critical',
                'metric': '디스크 사용률',
                'value': f"{disk_percent:.1f}%",
                'threshold': f"{self.thresholds['disk_percent']:.1f}%",
                'free': f"{disk.free / (1024**3):.1f}GB"
            }
        return {'alert': False}
    
    def send_alert(self, alert_data):
        """알림 발송"""
        level_emoji = {
            'warning': '⚠️',
            'critical': '🚨'
        }
        
        title = f"{level_emoji.get(alert_data['level'], '📊')} 인프라 알림 - {alert_data['level'].upper()}"
        
        message = f"""
**{alert_data['metric']} 임계값 초과**

• **현재 값**: {alert_data['value']}
• **임계값**: {alert_data['threshold']}
• **시간**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
• **서버**: {psutil.uname().node}

추가 정보가 있는 경우 메시지에 포함됩니다.
        """.strip()
        
        # 알림 발송
        success = self.apobj.notify(
            title=title,
            body=message,
            # 중요도에 따른 태그 설정
            tag=alert_data['level']
        )
        
        if success:
            print(f"✅ 알림 발송 성공: {alert_data['metric']}")
        else:
            print(f"❌ 알림 발송 실패: {alert_data['metric']}")
    
    def run_monitoring(self):
        """모니터링 실행"""
        print("🔍 인프라 모니터링 시작...")
        
        checks = [
            self.check_cpu_usage,
            self.check_memory_usage,
            self.check_disk_usage
        ]
        
        for check in checks:
            result = check()
            if result['alert']:
                self.send_alert(result)
                time.sleep(2)  # 알림 간격 조절

def main():
    monitor = InfrastructureMonitor()
    
    try:
        while True:
            monitor.run_monitoring()
            time.sleep(300)  # 5분마다 체크
    except KeyboardInterrupt:
        print("\n🛑 모니터링 중단")

if __name__ == "__main__":
    main()
```

### 2. CI/CD 파이프라인 알림

```python
#!/usr/bin/env python3
# 파일명: cicd_notifications.py

import apprise
import json
import subprocess
from datetime import datetime
from enum import Enum

class PipelineStatus(Enum):
    SUCCESS = "success"
    FAILURE = "failure"
    WARNING = "warning"
    STARTED = "started"

class CICDNotifier:
    def __init__(self):
        self.apobj = apprise.Apprise()
        self.setup_channels()
    
    def setup_channels(self):
        """CI/CD 알림 채널 설정"""
        # 개발팀 Slack
        self.apobj.add('slack://token/dev-channel')
        
        # GitHub/GitLab 연동
        self.apobj.add('mailto://ci-notifications@company.com')
        
        # Discord - 개발팀
        self.apobj.add('discord://webhook_id/webhook_token')
    
    def notify_pipeline_event(self, pipeline_data):
        """파이프라인 이벤트 알림"""
        status = PipelineStatus(pipeline_data['status'])
        
        emoji_map = {
            PipelineStatus.SUCCESS: '✅',
            PipelineStatus.FAILURE: '❌',
            PipelineStatus.WARNING: '⚠️',
            PipelineStatus.STARTED: '🚀'
        }
        
        color_map = {
            PipelineStatus.SUCCESS: '#36a64f',
            PipelineStatus.FAILURE: '#ff0000',
            PipelineStatus.WARNING: '#ffa500',
            PipelineStatus.STARTED: '#0080ff'
        }
        
        emoji = emoji_map.get(status, '📊')
        title = f"{emoji} CI/CD Pipeline - {pipeline_data['project']}"
        
        message = f"""
**Pipeline Status**: {status.value.upper()}
**Project**: {pipeline_data['project']}
**Branch**: {pipeline_data['branch']}
**Commit**: {pipeline_data['commit'][:8]}
**Author**: {pipeline_data['author']}
**Duration**: {pipeline_data.get('duration', 'N/A')}
**Build URL**: {pipeline_data['build_url']}

{pipeline_data.get('description', '')}
        """.strip()
        
        # 실패 시에만 중요 알림 발송
        if status == PipelineStatus.FAILURE:
            # 추가 긴급 채널 (SMS, 전화 등)
            urgent_apobj = apprise.Apprise()
            urgent_apobj.add('twilio://account_sid:auth_token@from_phone/to_phone')
            urgent_apobj.notify(
                title=f"🚨 긴급: {pipeline_data['project']} 빌드 실패",
                body=f"Branch: {pipeline_data['branch']}\nCommit: {pipeline_data['commit'][:8]}"
            )
        
        return self.apobj.notify(title=title, body=message)
    
    def notify_deployment_event(self, deployment_data):
        """배포 이벤트 알림"""
        if deployment_data['environment'] == 'production':
            # 프로덕션 배포는 모든 채널에 알림
            title = f"🚀 프로덕션 배포 - {deployment_data['service']}"
            message = f"""
**서비스**: {deployment_data['service']}
**버전**: {deployment_data['version']}
**환경**: {deployment_data['environment']}
**배포자**: {deployment_data['deployer']}
**시간**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

릴리즈 노트: {deployment_data.get('release_notes', 'N/A')}
            """.strip()
        else:
            # 스테이징 배포는 개발팀만
            title = f"📦 {deployment_data['environment']} 배포 - {deployment_data['service']}"
            message = f"버전 {deployment_data['version']} 배포 완료"
        
        return self.apobj.notify(title=title, body=message)

# 사용 예제
def example_usage():
    notifier = CICDNotifier()
    
    # 파이프라인 실패 알림
    pipeline_failure = {
        'status': 'failure',
        'project': 'main-api',
        'branch': 'main',
        'commit': 'a1b2c3d4e5f6',
        'author': 'john.doe',
        'duration': '3m 45s',
        'build_url': 'https://ci.company.com/builds/12345',
        'description': '단위 테스트 실패: UserServiceTest.testCreateUser'
    }
    
    notifier.notify_pipeline_event(pipeline_failure)
    
    # 프로덕션 배포 알림
    deployment_success = {
        'service': 'user-service',
        'version': 'v2.1.0',
        'environment': 'production',
        'deployer': 'jane.smith',
        'release_notes': 'https://github.com/company/user-service/releases/v2.1.0'
    }
    
    notifier.notify_deployment_event(deployment_success)

if __name__ == "__main__":
    example_usage()

### 3. 보안 이벤트 모니터링

```python
#!/usr/bin/env python3
# 파일명: security_monitor.py

import apprise
import re
import json
import hashlib
from datetime import datetime, timedelta
from collections import defaultdict

class SecurityEventMonitor:
    def __init__(self):
        self.apobj = apprise.Apprise()
        self.security_apobj = apprise.Apprise()  # 보안팀 전용
        self.setup_security_channels()
        
        # 보안 이벤트 분류
        self.threat_levels = {
            'low': {'emoji': '🟡', 'channels': ['security-team']},
            'medium': {'emoji': '🟠', 'channels': ['security-team', 'devops-team']},
            'high': {'emoji': '🔴', 'channels': ['security-team', 'devops-team', 'management']},
            'critical': {'emoji': '🚨', 'channels': ['all', 'sms', 'phone']}
        }
        
        # 이상 행위 패턴 저장
        self.suspicious_activities = defaultdict(list)
    
    def setup_security_channels(self):
        """보안 알림 채널 설정"""
        # 보안팀 전용 채널
        self.security_apobj.add('slack://token/security-alerts')
        self.security_apobj.add('msteams://security_webhook_url')
        
        # 일반 알림 채널
        self.apobj.add('slack://token/general-alerts')
        self.apobj.add('discord://webhook_id/webhook_token')
        
        # 긴급 알림 (SMS, 전화)
        self.apobj.add('twilio://account_sid:auth_token@from_phone/to_phone')
    
    def analyze_login_attempt(self, login_data):
        """로그인 시도 분석"""
        user_ip = login_data['ip_address']
        username = login_data['username']
        success = login_data['success']
        timestamp = datetime.fromisoformat(login_data['timestamp'])
        
        # 실패한 로그인 시도 추적
        if not success:
            key = f"{username}_{user_ip}"
            self.suspicious_activities[key].append(timestamp)
            
            # 최근 1시간 내 실패 시도 계산
            recent_failures = [
                t for t in self.suspicious_activities[key] 
                if timestamp - t < timedelta(hours=1)
            ]
            
            if len(recent_failures) >= 5:
                return {
                    'threat_level': 'high',
                    'event_type': 'brute_force_attempt',
                    'details': {
                        'username': username,
                        'ip_address': user_ip,
                        'failure_count': len(recent_failures),
                        'time_window': '1 hour'
                    }
                }
        
        # 비정상적인 로그인 위치 감지
        if success:
            # 지리적 위치 변화 감지 (예제)
            if self.is_unusual_location(username, user_ip):
                return {
                    'threat_level': 'medium',
                    'event_type': 'unusual_login_location',
                    'details': {
                        'username': username,
                        'ip_address': user_ip,
                        'location': self.get_location(user_ip)
                    }
                }
        
        return None
    
    def analyze_api_access(self, api_data):
        """API 접근 패턴 분석"""
        endpoint = api_data['endpoint']
        method = api_data['method']
        status_code = api_data['status_code']
        user_agent = api_data['user_agent']
        ip_address = api_data['ip_address']
        
        # SQL Injection 시도 감지
        if self.detect_sql_injection(endpoint):
            return {
                'threat_level': 'critical',
                'event_type': 'sql_injection_attempt',
                'details': {
                    'endpoint': endpoint,
                    'ip_address': ip_address,
                    'user_agent': user_agent,
                    'pattern': 'SQL injection keywords detected'
                }
            }
        
        # 과도한 API 호출 감지
        if self.detect_rate_limit_abuse(ip_address):
            return {
                'threat_level': 'medium',
                'event_type': 'rate_limit_abuse',
                'details': {
                    'ip_address': ip_address,
                    'request_count': self.get_request_count(ip_address),
                    'time_window': '5 minutes'
                }
            }
        
        return None
    
    def detect_sql_injection(self, endpoint):
        """SQL Injection 패턴 감지"""
        sql_patterns = [
            r"union\s+select",
            r"'\s*or\s*'1'\s*=\s*'1",
            r"drop\s+table",
            r"insert\s+into",
            r"delete\s+from"
        ]
        
        for pattern in sql_patterns:
            if re.search(pattern, endpoint.lower()):
                return True
        return False
    
    def send_security_alert(self, alert_data):
        """보안 알림 발송"""
        threat_level = alert_data['threat_level']
        event_type = alert_data['event_type']
        details = alert_data['details']
        
        emoji = self.threat_levels[threat_level]['emoji']
        title = f"{emoji} 보안 이벤트 감지 - {threat_level.upper()}"
        
        message = f"""
**이벤트 유형**: {event_type}
**위험도**: {threat_level.upper()}
**탐지 시간**: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

**상세 정보**:
        """.strip()
        
        for key, value in details.items():
            message += f"\n• **{key}**: {value}"
        
        # 위험도에 따른 채널 선택
        if threat_level in ['high', 'critical']:
            success = self.security_apobj.notify(title=title, body=message)
            
            # 최고 위험도는 즉시 SMS 발송
            if threat_level == 'critical':
                urgent_msg = f"CRITICAL SECURITY ALERT: {event_type} detected from {details.get('ip_address', 'unknown')}"
                self.apobj.notify(title="🚨 긴급 보안 알림", body=urgent_msg)
        else:
            success = self.apobj.notify(title=title, body=message)
        
        return success

def example_security_monitoring():
    """보안 모니터링 사용 예제"""
    monitor = SecurityEventMonitor()
    
    # 의심스러운 로그인 시도
    login_attempt = {
        'username': 'admin',
        'ip_address': '192.168.1.100',
        'success': False,
        'timestamp': datetime.now().isoformat()
    }
    
    alert = monitor.analyze_login_attempt(login_attempt)
    if alert:
        monitor.send_security_alert(alert)
    
    # SQL Injection 시도
    api_request = {
        'endpoint': "/users?id=1' OR '1'='1",
        'method': 'GET',
        'status_code': 403,
        'user_agent': 'sqlmap/1.4.7',
        'ip_address': '203.0.113.42'
    }
    
    alert = monitor.analyze_api_access(api_request)
    if alert:
        monitor.send_security_alert(alert)
```

### 4. 고객 서비스 알림 시스템

```python
#!/usr/bin/env python3
# 파일명: customer_service_notifications.py

import apprise
from enum import Enum
from datetime import datetime, timedelta

class TicketPriority(Enum):
    LOW = "low"
    NORMAL = "normal"
    HIGH = "high"
    URGENT = "urgent"

class CustomerServiceNotifier:
    def __init__(self):
        self.support_apobj = apprise.Apprise()
        self.management_apobj = apprise.Apprise()
        self.customer_apobj = apprise.Apprise()
        
        self.setup_notification_channels()
        
        # SLA 시간 설정 (시간 단위)
        self.sla_times = {
            TicketPriority.URGENT: 1,    # 1시간
            TicketPriority.HIGH: 4,      # 4시간
            TicketPriority.NORMAL: 24,   # 24시간
            TicketPriority.LOW: 72       # 72시간
        }
    
    def setup_notification_channels(self):
        """고객 서비스 알림 채널 설정"""
        # 고객 지원팀
        self.support_apobj.add('slack://token/support-team')
        self.support_apobj.add('msteams://support_webhook')
        
        # 경영진
        self.management_apobj.add('mailto://ceo@company.com')
        self.management_apobj.add('slack://token/management')
        
        # 고객 알림
        self.customer_apobj.add('mailto://smtp.company.com')
        self.customer_apobj.add('sms://twilio_account')
    
    def notify_new_ticket(self, ticket_data):
        """새 티켓 생성 알림"""
        priority = TicketPriority(ticket_data['priority'])
        
        priority_emojis = {
            TicketPriority.LOW: '🟢',
            TicketPriority.NORMAL: '🟡',
            TicketPriority.HIGH: '🟠',
            TicketPriority.URGENT: '🔴'
        }
        
        emoji = priority_emojis[priority]
        title = f"{emoji} 새 고객 지원 티켓 - {priority.value.upper()}"
        
        message = f"""
**티켓 ID**: {ticket_data['ticket_id']}
**고객**: {ticket_data['customer_name']} ({ticket_data['customer_email']})
**우선순위**: {priority.value.upper()}
**카테고리**: {ticket_data['category']}
**제목**: {ticket_data['subject']}

**내용**:
{ticket_data['description'][:200]}...

**SLA 응답 시간**: {self.sla_times[priority]}시간
**할당 예정**: {ticket_data.get('assignee', '미할당')}
        """.strip()
        
        # 긴급 티켓은 모든 채널에 알림
        if priority == TicketPriority.URGENT:
            self.support_apobj.notify(title=title, body=message)
            self.management_apobj.notify(
                title=f"🚨 긴급 고객 이슈 - {ticket_data['customer_name']}",
                body=f"티켓 ID: {ticket_data['ticket_id']}\n제목: {ticket_data['subject']}"
            )
        else:
            self.support_apobj.notify(title=title, body=message)
        
        # 고객에게 티켓 생성 확인 알림
        customer_message = f"""
안녕하세요 {ticket_data['customer_name']}님,

고객 지원 요청이 정상적으로 접수되었습니다.

• 티켓 번호: {ticket_data['ticket_id']}
• 접수 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
• 예상 응답 시간: {self.sla_times[priority]}시간 이내

담당자가 곧 연락드리겠습니다.

감사합니다.
고객 지원팀
        """.strip()
        
        self.customer_apobj.notify(
            title=f"티켓 접수 완료 - {ticket_data['ticket_id']}",
            body=customer_message
        )
    
    def notify_sla_breach(self, ticket_data):
        """SLA 위반 알림"""
        priority = TicketPriority(ticket_data['priority'])
        overdue_hours = ticket_data['overdue_hours']
        
        title = f"⏰ SLA 위반 알림 - 티켓 {ticket_data['ticket_id']}"
        
        message = f"""
**긴급**: SLA 응답 시간이 초과되었습니다!

**티켓 정보**:
• ID: {ticket_data['ticket_id']}
• 고객: {ticket_data['customer_name']}
• 우선순위: {priority.value.upper()}
• SLA 시간: {self.sla_times[priority]}시간
• 초과 시간: {overdue_hours:.1f}시간

**할당 담당자**: {ticket_data.get('assignee', '미할당')}

즉시 대응이 필요합니다!
        """.strip()
        
        # SLA 위반은 관리자에게 즉시 알림
        self.support_apobj.notify(title=title, body=message)
        self.management_apobj.notify(title=title, body=message)
        
        # 심각한 SLA 위반 시 고객에게도 사과 메시지
        if overdue_hours > self.sla_times[priority] * 2:
            apology_message = f"""
{ticket_data['customer_name']}님께,

티켓 {ticket_data['ticket_id']}에 대한 응답이 예상보다 지연되어 진심으로 사과드립니다.

현재 담당자가 우선 순위로 처리하고 있으며, 1시간 이내에 연락드리겠습니다.

불편을 끼쳐드려 죄송합니다.

고객 지원팀장
            """.strip()
            
            self.customer_apobj.notify(
                title=f"응답 지연 안내 - {ticket_data['ticket_id']}",
                body=apology_message
            )
    
    def notify_ticket_resolution(self, ticket_data):
        """티켓 해결 알림"""
        resolution_time = ticket_data['resolution_time_hours']
        priority = TicketPriority(ticket_data['priority'])
        sla_met = resolution_time <= self.sla_times[priority]
        
        # 고객에게 해결 알림
        customer_message = f"""
{ticket_data['customer_name']}님,

요청하신 지원 티켓이 해결되었습니다.

• 티켓 번호: {ticket_data['ticket_id']}
• 해결 시간: {resolution_time:.1f}시간
• 담당자: {ticket_data['assignee']}

**해결 내용**:
{ticket_data['resolution']}

서비스에 대한 피드백을 남겨주시면 큰 도움이 됩니다.
[피드백 링크: {ticket_data.get('feedback_url', 'N/A')}]

감사합니다.
        """.strip()
        
        self.customer_apobj.notify(
            title=f"티켓 해결 완료 - {ticket_data['ticket_id']}",
            body=customer_message
        )
        
        # 내부팀에 해결 보고
        internal_message = f"""
✅ 티켓 해결 완료

• ID: {ticket_data['ticket_id']}
• 고객: {ticket_data['customer_name']}
• 해결 시간: {resolution_time:.1f}시간
• SLA 준수: {'✅' if sla_met else '❌'}
• 담당자: {ticket_data['assignee']}
        """.strip()
        
        self.support_apobj.notify(
            title=f"티켓 해결 - {ticket_data['ticket_id']}",
            body=internal_message
        )

def example_customer_service():
    """고객 서비스 알림 예제"""
    notifier = CustomerServiceNotifier()
    
    # 새 긴급 티켓
    urgent_ticket = {
        'ticket_id': 'CS-2024-001',
        'customer_name': '김철수',
        'customer_email': 'kimcs@example.com',
        'priority': 'urgent',
        'category': '서비스 장애',
        'subject': '결제 시스템 오류',
        'description': '결제 진행 중 시스템 오류가 발생하여 거래가 중단되었습니다...',
        'assignee': '이영희'
    }
    
    notifier.notify_new_ticket(urgent_ticket)
    
    # SLA 위반 알림
    sla_breach = {
        'ticket_id': 'CS-2024-001',
        'customer_name': '김철수',
        'priority': 'urgent',
        'overdue_hours': 2.5,
        'assignee': '이영희'
    }
    
    notifier.notify_sla_breach(sla_breach)

if __name__ == "__main__":
    example_customer_service()

### 5. 비즈니스 메트릭 알림

```python
#!/usr/bin/env python3
# 파일명: business_metrics_alerts.py

import apprise
from datetime import datetime, timedelta
import json

class BusinessMetricsNotifier:
    def __init__(self):
        self.apobj = apprise.Apprise()
        self.exec_apobj = apprise.Apprise()  # 경영진 전용
        self.setup_channels()
        
        # 비즈니스 임계값 설정
        self.thresholds = {
            'revenue': {
                'daily_target': 100000,  # 일일 매출 목표
                'drop_threshold': 0.15   # 15% 이상 감소 시 알림
            },
            'conversion_rate': {
                'target': 0.05,          # 목표 전환율 5%
                'alert_threshold': 0.03  # 3% 이하 시 알림
            },
            'user_engagement': {
                'daily_active_users': 10000,
                'session_duration': 300  # 5분 이상
            }
        }
    
    def setup_channels(self):
        """비즈니스 메트릭 알림 채널 설정"""
        # 일반 채널
        self.apobj.add('slack://token/business-metrics')
        self.apobj.add('msteams://business_webhook')
        
        # 경영진 채널
        self.exec_apobj.add('mailto://ceo@company.com')
        self.exec_apobj.add('mailto://cfo@company.com')
        self.exec_apobj.add('slack://token/executive-alerts')
    
    def check_revenue_metrics(self, revenue_data):
        """매출 지표 확인"""
        current_revenue = revenue_data['daily_revenue']
        previous_revenue = revenue_data['previous_day_revenue']
        target_revenue = self.thresholds['revenue']['daily_target']
        
        # 목표 대비 달성률
        achievement_rate = current_revenue / target_revenue
        
        # 전일 대비 변화율
        if previous_revenue > 0:
            change_rate = (current_revenue - previous_revenue) / previous_revenue
        else:
            change_rate = 0
        
        alerts = []
        
        # 목표 미달성 알림
        if achievement_rate < 0.8:  # 80% 미만
            alerts.append({
                'type': 'revenue_target_miss',
                'severity': 'high' if achievement_rate < 0.6 else 'medium',
                'data': {
                    'current_revenue': current_revenue,
                    'target_revenue': target_revenue,
                    'achievement_rate': achievement_rate,
                    'shortfall': target_revenue - current_revenue
                }
            })
        
        # 급격한 매출 감소 알림
        if change_rate < -self.thresholds['revenue']['drop_threshold']:
            alerts.append({
                'type': 'revenue_drop',
                'severity': 'critical' if change_rate < -0.3 else 'high',
                'data': {
                    'current_revenue': current_revenue,
                    'previous_revenue': previous_revenue,
                    'change_rate': change_rate,
                    'drop_amount': previous_revenue - current_revenue
                }
            })
        
        # 목표 달성 축하 알림
        if achievement_rate >= 1.2:  # 120% 이상
            alerts.append({
                'type': 'revenue_success',
                'severity': 'positive',
                'data': {
                    'current_revenue': current_revenue,
                    'target_revenue': target_revenue,
                    'achievement_rate': achievement_rate,
                    'excess': current_revenue - target_revenue
                }
            })
        
        return alerts
    
    def send_business_alert(self, alert):
        """비즈니스 알림 발송"""
        alert_type = alert['type']
        severity = alert['severity']
        data = alert['data']
        
        severity_config = {
            'positive': {'emoji': '🎉', 'color': '#00ff00'},
            'low': {'emoji': '📊', 'color': '#ffff00'},
            'medium': {'emoji': '⚠️', 'color': '#ffa500'},
            'high': {'emoji': '🔴', 'color': '#ff0000'},
            'critical': {'emoji': '🚨', 'color': '#8b0000'}
        }
        
        config = severity_config.get(severity, severity_config['medium'])
        emoji = config['emoji']
        
        if alert_type == 'revenue_target_miss':
            title = f"{emoji} 매출 목표 미달성 알림"
            message = f"""
**일일 매출 목표 미달성**

• **현재 매출**: ${data['current_revenue']:,.2f}
• **목표 매출**: ${data['target_revenue']:,.2f}
• **달성률**: {data['achievement_rate']:.1%}
• **부족액**: ${data['shortfall']:,.2f}

마케팅 및 영업팀 긴급 대응이 필요합니다.
            """.strip()
            
        elif alert_type == 'revenue_drop':
            title = f"{emoji} 매출 급감 알림"
            message = f"""
**매출 급격한 감소 감지**

• **현재 매출**: ${data['current_revenue']:,.2f}
• **전일 매출**: ${data['previous_revenue']:,.2f}
• **변화율**: {data['change_rate']:.1%}
• **감소액**: ${data['drop_amount']:,.2f}

원인 분석 및 대응 방안 수립이 시급합니다.
            """.strip()
            
        elif alert_type == 'revenue_success':
            title = f"{emoji} 매출 목표 초과 달성!"
            message = f"""
**일일 매출 목표 초과 달성**

• **현재 매출**: ${data['current_revenue']:,.2f}
• **목표 매출**: ${data['target_revenue']:,.2f}
• **달성률**: {data['achievement_rate']:.1%}
• **초과액**: ${data['excess']:,.2f}

훌륭한 성과입니다! 🎊
            """.strip()
        
        # 심각한 수준은 경영진에게도 알림
        if severity in ['high', 'critical']:
            self.exec_apobj.notify(title=title, body=message)
        
        return self.apobj.notify(title=title, body=message)

def example_business_metrics():
    """비즈니스 메트릭 알림 예제"""
    notifier = BusinessMetricsNotifier()
    
    # 매출 급감 상황
    revenue_drop = {
        'daily_revenue': 65000,
        'previous_day_revenue': 95000
    }
    
    alerts = notifier.check_revenue_metrics(revenue_drop)
    for alert in alerts:
        notifier.send_business_alert(alert)
    
    # 목표 초과 달성 상황
    revenue_success = {
        'daily_revenue': 125000,
        'previous_day_revenue': 98000
    }
    
    alerts = notifier.check_revenue_metrics(revenue_success)
    for alert in alerts:
        notifier.send_business_alert(alert)

if __name__ == "__main__":
    example_business_metrics() 