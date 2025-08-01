---
title: "Horilla 오픈소스 HRMS 완전 설치 가이드 - 무료 인사관리 시스템 구축하기"
excerpt: "Django 기반의 완전 무료 오픈소스 HRMS인 Horilla로 채용부터 급여관리까지 모든 HR 업무를 자동화하세요. Ubuntu, Windows, macOS 설치부터 프로덕션 배포까지 단계별로 완벽 가이드합니다."
seo_title: "Horilla 오픈소스 HRMS 설치 가이드 - 무료 인사관리 시스템 구축 튜토리얼 - Thaki Cloud"
seo_description: "Horilla 오픈소스 HRMS 완전 설치 및 설정 가이드. Django 기반 무료 인사관리 시스템으로 채용, 급여, 출근관리, 성과관리까지 HR 업무 자동화하는 방법을 상세히 설명합니다."
date: 2025-08-01
last_modified_at: 2025-08-01
categories:
  - tutorials
  - hrms
tags:
  - Horilla
  - Open-Source
  - HRMS
  - Human-Resource
  - Django
  - PostgreSQL
  - HR-Management
  - Employee-Management
  - Payroll
  - Attendance
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/horilla-open-source-hrms-complete-setup-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 21분

## 서론: 왜 Horilla 오픈소스 HRMS인가?

현대 기업에서 **인사관리(HR)의 디지털 전환**은 선택이 아닌 필수입니다. [Horilla](https://github.com/horilla-opensource/horilla)는 이러한 니즈를 완벽하게 충족하는 **완전 무료 오픈소스 HRMS(Human Resource Management System)**로, 기업의 모든 HR 업무를 효율적으로 자동화할 수 있게 해줍니다.

### Horilla의 핵심 장점

**완전한 무료 솔루션**:
- 🆓 **LGPL-2.1 라이선스**: 상업적 사용 포함 완전 무료
- 🌟 **커뮤니티 검증**: GitHub 662 stars, 441 forks의 신뢰성
- 🔧 **소스코드 공개**: 완전한 투명성과 커스터마이징 자유
- 💰 **라이선스 비용 Zero**: 고가의 상업용 HRMS 대비 완벽한 대안

**포괄적인 HR 기능**:
- 👥 **채용 관리**: 구인공고부터 면접, 입사까지 전 과정 관리
- 📋 **온보딩**: 신입사원 교육 및 적응 프로세스 자동화
- 👤 **직원 관리**: 개인정보, 조직도, 권한 관리
- ⏰ **출근 관리**: 출퇴근, 지각, 조퇴 실시간 추적
- 🏖️ **휴가 관리**: 연차, 병가, 특별휴가 신청 및 승인
- 💼 **자산 관리**: 회사 장비 및 자산 배정/회수 관리
- 💰 **급여 관리**: 급여 계산, 세금, 공제 자동화
- 📊 **성과 관리**: KPI 설정, 평가, 피드백 시스템
- 🚪 **퇴사 관리**: 퇴사 절차 및 업무 인수인계
- 🎫 **헬프데스크**: 직원 문의 및 지원 티케팅

**현대적인 기술 스택**:
- 🐍 **Django 프레임워크**: 견고하고 확장 가능한 웹 프레임워크
- 🐘 **PostgreSQL**: 엔터프라이즈급 데이터베이스
- 🎨 **Bootstrap UI**: 반응형 모던 인터페이스
- 📱 **모바일 호환**: 스마트폰에서도 완벽한 사용 경험
- 🔒 **보안 강화**: Django 보안 기능과 정기 업데이트

### 이 가이드에서 배울 내용

1. **Horilla 시스템 아키텍처 이해**
2. **운영체제별 설치 가이드 (Ubuntu, Windows, macOS)**
3. **PostgreSQL 데이터베이스 설정 및 최적화**
4. **Django 환경 구성 및 초기화**
5. **핵심 HR 모듈 설정 및 활용**
6. **사용자 권한 및 조직 구조 설계**
7. **프로덕션 환경 배포 및 보안 강화**
8. **성능 최적화 및 백업 전략**
9. **커스터마이징 및 확장 개발**

## Horilla 시스템 아키텍처 및 구성 요소

### 전체 시스템 구조

**Horilla HRMS Architecture**:

```
┌─────────────────────────────────────────────────────────────┐
│                    Web Interface                            │
│              (Bootstrap + HTMX)                            │
└─────────────────┬───────────────────────────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│                Django Application                           │
├─────────────────┬───────────────────────────────────────────┤
│ HR Modules      │ Core Modules       │ System Modules       │
├─────────────────┼───────────────────┼─────────────────────┤
│ • Recruitment   │ • Employee        │ • Authentication     │
│ • Onboarding    │ • Attendance      │ • Permissions        │
│ • Leave Mgmt    │ • Asset           │ • Audit Trail        │
│ • Payroll       │ • Performance     │ • API               │
│ • Helpdesk      │ • Offboarding     │ • Notifications      │
└─────────────────┴───────────────────┴─────────────────────┘
                  │
┌─────────────────▼───────────────────────────────────────────┐
│                PostgreSQL Database                          │
│           (Employee Data + Audit Logs)                     │
└─────────────────────────────────────────────────────────────┘
```

### 핵심 모듈 상세 분석

**1. Employee Management (직원 관리)**
- **개인정보 관리**: 기본정보, 연락처, 가족사항
- **조직 구조**: 부서, 직급, 보고 라인 설정
- **문서 관리**: 계약서, 증명서, 평가서 등 파일 관리
- **히스토리 추적**: 승진, 이동, 변경 이력 자동 기록

**2. Attendance Tracking (출근 관리)**
- **실시간 체크인/아웃**: 웹, 모바일 출퇴근 기록
- **생체 인식 연동**: 지문, 얼굴 인식 시스템 지원
- **지오펜싱**: GPS 기반 위치 제한 출근
- **근무 시간 분석**: 초과 근무, 부족 근무 자동 계산

**3. Leave Management (휴가 관리)**
- **휴가 정책**: 연차, 병가, 특별휴가 정책 설정
- **신청/승인 워크플로우**: 다단계 승인 프로세스
- **잔여 휴가 관리**: 자동 계산 및 이월 처리
- **캘린더 연동**: 팀 휴가 일정 시각화

**4. Recruitment (채용 관리)**
- **구인공고 관리**: 내부/외부 채용 공고 등록
- **지원자 관리**: 이력서, 면접 일정, 평가 기록
- **면접 프로세스**: 다단계 면접 및 평가 시스템
- **입사 관리**: 최종 합격자 온보딩 프로세스 연계

## 시스템 요구사항 및 사전 준비

### 하드웨어 요구사항

**최소 사양 (50명 이하 조직)**:
```bash
CPU: 2 Core (2.0GHz 이상)
RAM: 4GB
Storage: 20GB SSD
Network: 100Mbps
```

**권장 사양 (200명 이하 조직)**:
```bash
CPU: 4 Core (2.5GHz 이상)
RAM: 8GB
Storage: 50GB SSD
Network: 1Gbps
```

**엔터프라이즈 사양 (500명 이상 조직)**:
```bash
CPU: 8 Core (3.0GHz 이상)
RAM: 16GB
Storage: 100GB NVMe SSD
Network: 1Gbps
Database: 별도 서버 권장
```

### 소프트웨어 요구사항

**필수 구성 요소**:
- **Python**: 3.8 이상 (3.11 권장)
- **Django**: 4.2 LTS 이상
- **PostgreSQL**: 12 이상 (15 권장)
- **웹서버**: Nginx 또는 Apache
- **프로세스 관리**: Gunicorn, uWSGI

**선택적 구성 요소**:
- **Redis**: 세션 캐싱 및 성능 향상
- **Celery**: 백그라운드 작업 처리
- **Docker**: 컨테이너화 배포
- **SSL 인증서**: HTTPS 보안 연결

## Ubuntu 환경 완전 설치 가이드

### 1단계: 시스템 업데이트 및 의존성 설치

```bash
# 시스템 패키지 업데이트
sudo apt update && sudo apt upgrade -y

# 필수 패키지 설치
sudo apt install -y \
  python3 \
  python3-pip \
  python3-venv \
  python3-dev \
  git \
  curl \
  wget \
  build-essential \
  libpq-dev \
  libjpeg-dev \
  libpng-dev \
  libffi-dev \
  libssl-dev

# Python 버전 확인
python3 --version
```

### 2단계: PostgreSQL 설치 및 설정

```bash
# PostgreSQL 설치
sudo apt install -y postgresql postgresql-contrib

# PostgreSQL 서비스 시작 및 자동 시작 설정
sudo systemctl start postgresql
sudo systemctl enable postgresql

# PostgreSQL 상태 확인
sudo systemctl status postgresql

# PostgreSQL 버전 확인
psql --version
```

**PostgreSQL 데이터베이스 및 사용자 생성**:

```bash
# postgres 사용자로 전환
sudo su - postgres

# PostgreSQL 콘솔 접속
psql

# 데이터베이스 사용자 생성
CREATE USER horilla WITH PASSWORD 'horilla_secure_password_2024';

# 데이터베이스 생성
CREATE DATABASE horilla_main OWNER horilla;

# 사용자 권한 부여
GRANT ALL PRIVILEGES ON DATABASE horilla_main TO horilla;

# 추가 권한 설정 (Django 호환성)
ALTER USER horilla CREATEDB;

# 연결 테스트
\c horilla_main horilla

# PostgreSQL 종료
\q

# postgres 사용자에서 나가기
exit
```

**PostgreSQL 보안 설정**:

```bash
# pg_hba.conf 편집 (인증 방식 설정)
sudo nano /etc/postgresql/*/main/pg_hba.conf

# 다음 라인을 찾아서 md5로 변경
# local   all             all                                     peer
# 를 다음과 같이 변경:
# local   all             all                                     md5

# PostgreSQL 재시작
sudo systemctl restart postgresql

# 연결 테스트
psql -U horilla -d horilla_main -h localhost
```

### 3단계: Horilla 프로젝트 설정

```bash
# 프로젝트 디렉토리 생성 및 이동
sudo mkdir -p /opt/horilla
sudo chown $USER:$USER /opt/horilla
cd /opt/horilla

# Git 저장소 클론
git init
git remote add origin https://github.com/horilla-opensource/horilla.git
git pull origin master

# 프로젝트 구조 확인
ls -la
```

**Python 가상환경 설정**:

```bash
# 가상환경 생성
python3 -m venv horillavenv

# 가상환경 활성화
source horillavenv/bin/activate

# pip 업그레이드
pip install --upgrade pip

# 의존성 설치
pip install -r requirements.txt

# 설치된 패키지 확인
pip list
```

### 4단계: 환경 변수 설정

```bash
# 환경 설정 파일 생성
cp .env.dist .env

# 환경 설정 파일 편집
nano .env
```

**최적화된 .env 설정**:

```env
# 개발/프로덕션 설정
DEBUG=False
SECRET_KEY=horilla-super-secret-key-change-this-in-production-2024

# 시간대 설정
TIME_ZONE=Asia/Seoul

# 허용된 호스트 설정
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com,your-server-ip

# 데이터베이스 초기화 비밀번호
DB_INIT_PASSWORD=horilla-init-secure-password-2024

# PostgreSQL 데이터베이스 설정
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla_main
DB_USER=horilla
DB_PASSWORD=horilla_secure_password_2024
DB_HOST=localhost
DB_PORT=5432

# 이메일 설정 (SMTP)
EMAIL_BACKEND=django.core.mail.backends.smtp.EmailBackend
EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=your-email@company.com
EMAIL_HOST_PASSWORD=your-app-password

# 미디어 및 정적 파일 설정
MEDIA_ROOT=/opt/horilla/media
STATIC_ROOT=/opt/horilla/static

# 보안 설정
SECURE_SSL_REDIRECT=True
SECURE_BROWSER_XSS_FILTER=True
SECURE_CONTENT_TYPE_NOSNIFF=True
X_FRAME_OPTIONS=DENY

# 세션 보안
SESSION_COOKIE_SECURE=True
CSRF_COOKIE_SECURE=True
SESSION_COOKIE_HTTPONLY=True
```

### 5단계: Django 애플리케이션 초기화

```bash
# 가상환경 활성화 확인
source horillavenv/bin/activate

# 데이터베이스 마이그레이션 생성
python3 manage.py makemigrations

# 마이그레이션 적용
python3 manage.py migrate

# 정적 파일 수집
python3 manage.py collectstatic --noinput

# 번역 컴파일
python3 manage.py compilemessages

# 권한 설정
sudo chown -R $USER:$USER /opt/horilla
chmod -R 755 /opt/horilla
```

### 6단계: 개발 서버 테스트

```bash
# 개발 서버 시작
python3 manage.py runserver 0.0.0.0:8000

# 다른 터미널에서 연결 테스트
curl http://localhost:8000
```

**웹 브라우저에서 접속**:
1. **URL**: `http://your-server-ip:8000`
2. **초기화 옵션 선택**:
   - **Initialize Database**: 새로운 설치
   - **Load Demo Data**: 데모 데이터로 시작
3. **인증**: `DB_INIT_PASSWORD` 입력

## Windows 환경 설치 가이드

### 1단계: Python 설치

```powershell
# Python 공식 웹사이트에서 다운로드
# https://www.python.org/downloads/windows/

# PowerShell에서 설치 확인
python --version
pip --version

# 또는 Chocolatey를 사용한 설치
Set-ExecutionPolicy Bypass -Scope Process -Force
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install python

# Git 설치
choco install git
```

### 2단계: PostgreSQL 설치 (Windows)

```powershell
# PostgreSQL 공식 설치 프로그램 다운로드
# https://www.postgresql.org/download/windows/

# 또는 Chocolatey 사용
choco install postgresql

# 서비스 확인
Get-Service postgresql*

# SQL Shell (psql) 실행
psql -U postgres
```

**PostgreSQL 데이터베이스 설정 (Windows)**:

```sql
-- psql 콘솔에서 실행
CREATE USER horilla WITH PASSWORD 'horilla_secure_password_2024';
CREATE DATABASE horilla_main OWNER horilla;
GRANT ALL PRIVILEGES ON DATABASE horilla_main TO horilla;
ALTER USER horilla CREATEDB;
\q
```

### 3단계: Horilla 프로젝트 설정 (Windows)

```powershell
# 프로젝트 디렉토리 생성
mkdir C:\horilla
cd C:\horilla

# Git 저장소 클론
git init
git remote add origin https://github.com/horilla-opensource/horilla.git
git pull origin master

# Python 가상환경 생성
python -m venv horillavenv

# 가상환경 활성화
.\horillavenv\Scripts\Activate.ps1

# 의존성 설치
pip install -r requirements.txt
```

### 4단계: Windows 환경 변수 설정

```powershell
# 환경 설정 파일 생성
Copy-Item .env.dist .env

# 메모장으로 편집
notepad .env
```

**Windows용 .env 설정**:

```env
DEBUG=False
SECRET_KEY=horilla-windows-secret-key-2024
TIME_ZONE=Asia/Seoul
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

DB_INIT_PASSWORD=horilla-init-password-2024
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla_main
DB_USER=horilla
DB_PASSWORD=horilla_secure_password_2024
DB_HOST=localhost
DB_PORT=5432

# Windows 경로 설정
MEDIA_ROOT=C:\\horilla\\media
STATIC_ROOT=C:\\horilla\\static
```

### 5단계: Windows에서 Django 실행

```powershell
# 가상환경 활성화
.\horillavenv\Scripts\Activate.ps1

# 마이그레이션
python manage.py makemigrations
python manage.py migrate

# 정적 파일 수집
python manage.py collectstatic --noinput

# 번역 컴파일 (선택적)
python manage.py compilemessages

# 서버 실행
python manage.py runserver 0.0.0.0:8000
```

## macOS 환경 설치 가이드

### 1단계: Homebrew 및 Python 설치

```bash
# Homebrew 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Python 및 필수 도구 설치
brew install python@3.11 git postgresql

# Python 버전 확인
python3 --version
pip3 --version
```

### 2단계: PostgreSQL 설정 (macOS)

```bash
# PostgreSQL 서비스 시작
brew services start postgresql

# 데이터베이스 및 사용자 생성
psql postgres

-- PostgreSQL 콘솔에서
CREATE USER horilla WITH PASSWORD 'horilla_secure_password_2024';
CREATE DATABASE horilla_main OWNER horilla;
GRANT ALL PRIVILEGES ON DATABASE horilla_main TO horilla;
ALTER USER horilla CREATEDB;
\q
```

### 3단계: Horilla 설정 (macOS)

```bash
# 프로젝트 디렉토리 생성
sudo mkdir -p /usr/local/horilla
sudo chown $USER:staff /usr/local/horilla
cd /usr/local/horilla

# 프로젝트 클론
git init
git remote add origin https://github.com/horilla-opensource/horilla.git
git pull origin master

# 가상환경 생성 및 활성화
python3 -m venv horillavenv
source horillavenv/bin/activate

# 의존성 설치
pip install -r requirements.txt
```

### 4단계: macOS 환경 설정

```bash
# 환경 설정
cp .env.dist .env
nano .env
```

**macOS용 .env 설정**:

```env
DEBUG=False
SECRET_KEY=horilla-macos-secret-key-2024
TIME_ZONE=Asia/Seoul
ALLOWED_HOSTS=localhost,127.0.0.1,your-domain.com

DB_INIT_PASSWORD=horilla-init-password-2024
DB_ENGINE=django.db.backends.postgresql
DB_NAME=horilla_main
DB_USER=horilla
DB_PASSWORD=horilla_secure_password_2024
DB_HOST=localhost
DB_PORT=5432

MEDIA_ROOT=/usr/local/horilla/media
STATIC_ROOT=/usr/local/horilla/static
```

### 5단계: macOS에서 실행

```bash
# 가상환경 활성화
source horillavenv/bin/activate

# Django 설정
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py collectstatic --noinput
python3 manage.py compilemessages

# 개발 서버 실행
python3 manage.py runserver 0.0.0.0:8000
```

## 초기 설정 및 관리자 구성

### 데이터베이스 초기화

**웹 인터페이스를 통한 초기화**:

1. **브라우저 접속**: `http://your-server:8000`
2. **Initialize Database 선택**
3. **초기화 비밀번호 입력**: `.env`의 `DB_INIT_PASSWORD`
4. **관리자 정보 입력**:
   ```
   관리자 이메일: admin@company.com
   관리자 비밀번호: secure_admin_password_2024
   회사명: Your Company Name
   본사 주소: Seoul, South Korea
   ```

### 기본 조직 구조 설정

**회사 정보 설정**:

```python
# Django shell에서 실행
python3 manage.py shell

from employee.models import Company, Department, JobPosition

# 회사 정보 확인 및 수정
company = Company.objects.first()
company.company_name = "Your Company Ltd."
company.email = "info@yourcompany.com"
company.phone = "+82-2-1234-5678"
company.address = "Seoul, South Korea"
company.save()

# 부서 생성
departments = [
    "인사팀", "개발팀", "마케팅팀", "영업팀", "재무팀", "운영팀"
]

for dept_name in departments:
    Department.objects.get_or_create(
        department=dept_name,
        company=company
    )

# 직급 생성
positions = [
    "사원", "대리", "과장", "차장", "부장", "이사", "상무", "대표"
]

for pos_name in positions:
    JobPosition.objects.get_or_create(
        job_position=pos_name,
        company=company
    )
```

### 사용자 권한 및 그룹 설정

**Django 관리자에서 권한 설정**:

```python
# Django shell에서 그룹 및 권한 설정
from django.contrib.auth.models import Group, Permission
from django.contrib.contenttypes.models import ContentType

# HR 관리자 그룹 생성
hr_admin_group, created = Group.objects.get_or_create(name='HR_Admin')

# 부서 관리자 그룹 생성  
dept_manager_group, created = Group.objects.get_or_create(name='Department_Manager')

# 일반 직원 그룹 생성
employee_group, created = Group.objects.get_or_create(name='Employee')

# HR 관리자 권한 설정
hr_permissions = Permission.objects.filter(
    content_type__app_label__in=[
        'employee', 'attendance', 'leave', 'payroll', 'recruitment'
    ]
)
hr_admin_group.permissions.set(hr_permissions)

# 부서 관리자 권한 설정 (제한적)
manager_permissions = Permission.objects.filter(
    content_type__app_label__in=['attendance', 'leave'],
    codename__contains='view'
)
dept_manager_group.permissions.set(manager_permissions)

print("권한 그룹 설정 완료")
```

## 핵심 HR 모듈 설정 및 활용

### 직원 관리 모듈 설정

**직원 등록 및 관리**:

```python
# 웹 인터페이스: Employee > Add Employee
# 또는 Django shell에서 프로그래밍 방식으로:

from employee.models import Employee, EmployeeWorkInformation
from django.contrib.auth.models import User

# 새 직원 계정 생성
user = User.objects.create_user(
    username='john.doe',
    email='john.doe@company.com',
    password='temporary_password_2024',
    first_name='John',
    last_name='Doe'
)

# 직원 정보 생성
employee = Employee.objects.create(
    employee_user_id=user,
    employee_first_name='John',
    employee_last_name='Doe',
    email='john.doe@company.com',
    phone='+82-10-1234-5678',
    gender='male',
    dob='1990-01-15',
    badge_id='EMP001'
)

# 근무 정보 설정
work_info = EmployeeWorkInformation.objects.create(
    employee_id=employee,
    email='john.doe@company.com',
    mobile='+82-10-1234-5678',
    job_position_id=JobPosition.objects.get(job_position='사원'),
    department_id=Department.objects.get(department='개발팀'),
    work_type_id=None,  # 풀타임
    employee_type_id=None,  # 정규직
    reporting_manager_id=None,  # 추후 설정
    company_id=company,
    location='Seoul Office',
    date_joining='2024-08-01'
)

print(f"직원 {employee.get_full_name()} 등록 완료")
```

### 출근 관리 시스템 설정

**출근 정책 및 규칙 설정**:

```python
# Django shell에서 출근 정책 설정
from attendance.models import AttendanceGeneralSetting, WorkType

# 일반 출근 설정
attendance_setting = AttendanceGeneralSetting.objects.create(
    company_id=company,
    attendance_clock_in_out_request=True,  # 출퇴근 승인 필요
    attendance_validate_request=True,  # 출근 검증 필요
    attendance_clock_in_out_interval=True,  # 출퇴근 간격 제한
    clock_in_out_interval_time=300,  # 5분 간격
    minimum_hour_for_half_day=4,  # 반일 최소 시간
    minimum_hour_for_full_day=8,  # 전일 최소 시간
)

# 근무 유형 설정
work_types = [
    {"name": "풀타임", "hours": 8},
    {"name": "파트타임", "hours": 4},
    {"name": "플렉스타임", "hours": 8},
    {"name": "재택근무", "hours": 8}
]

for wt in work_types:
    WorkType.objects.get_or_create(
        work_type=wt["name"],
        company_id=company,
        defaults={"description": f"{wt['hours']}시간 근무"}
    )
```

**지오펜싱 설정 (위치 기반 출근)**:

```python
# 지오펜싱 설정 (선택적)
from geofencing.models import Geofencing

# 본사 지오펜스 설정
office_geofence = Geofencing.objects.create(
    title="본사 사무실",
    latitude=37.5665,  # 서울 좌표 예시
    longitude=126.9780,
    radius=100,  # 100미터 반경
    company_id=company,
    is_active=True
)

print("지오펜싱 설정 완료: 본사 100m 반경")
```

### 휴가 관리 시스템 구성

**휴가 정책 및 유형 설정**:

```python
# 휴가 관리 설정
from leave.models import LeaveType, LeaveAllocationRequest

# 휴가 유형 생성
leave_types_data = [
    {"name": "연차", "days": 15, "color": "#007bff"},
    {"name": "병가", "days": 5, "color": "#28a745"}, 
    {"name": "특별휴가", "days": 3, "color": "#ffc107"},
    {"name": "출산휴가", "days": 90, "color": "#e83e8c"},
    {"name": "육아휴직", "days": 365, "color": "#6f42c1"}
]

for lt_data in leave_types_data:
    leave_type = LeaveType.objects.create(
        leave_type=lt_data["name"],
        color=lt_data["color"],
        company_id=company,
        is_compensatory_leave=False,
        require_approval=True,
        require_attachment=False if lt_data["name"] != "병가" else True
    )
    
    # 모든 직원에게 기본 휴가 할당
    for employee in Employee.objects.filter(
        employee_work_info__company_id=company
    ):
        LeaveAllocationRequest.objects.create(
            leave_type_id=leave_type,
            employee_id=employee,
            requested_days=lt_data["days"],
            approved_available_days=lt_data["days"],
            status="approved",
            start_date="2024-01-01",
            end_date="2024-12-31"
        )

print("휴가 정책 및 할당 완료")
```

### 급여 관리 시스템 설정

**급여 구조 및 항목 설정**:

```python
# 급여 관리 설정
from payroll.models import PayrollGeneralSetting, Allowance, Deduction

# 급여 일반 설정
payroll_setting = PayrollGeneralSetting.objects.create(
    company_id=company,
    cut_off_date=25,  # 매월 25일 마감
    pay_day=28,  # 매월 28일 급여 지급
    overtime_after=8,  # 8시간 초과시 초과근무
    overtime_rate=1.5,  # 초과근무 수당율 150%
)

# 수당 항목 설정
allowances = [
    {"name": "식대", "amount": 200000, "type": "fixed"},
    {"name": "교통비", "amount": 100000, "type": "fixed"},
    {"name": "성과급", "amount": 0, "type": "variable"},
    {"name": "야근수당", "amount": 0, "type": "variable"}
]

for allowance_data in allowances:
    Allowance.objects.create(
        title=allowance_data["name"],
        include_active_employees=True,
        company_id=company,
        if_choice=allowance_data["type"],
        amount=allowance_data["amount"]
    )

# 공제 항목 설정
deductions = [
    {"name": "국민연금", "rate": 4.5, "type": "percentage"},
    {"name": "건강보험", "rate": 3.43, "type": "percentage"},
    {"name": "고용보험", "rate": 0.9, "type": "percentage"},
    {"name": "소득세", "rate": 10, "type": "percentage"}
]

for deduction_data in deductions:
    Deduction.objects.create(
        title=deduction_data["name"],
        include_active_employees=True,
        company_id=company,
        if_choice="percentage",
        rate=deduction_data["rate"]
    )

print("급여 구조 설정 완료")
```

## 프로덕션 환경 배포 가이드

### Nginx 웹서버 설정

**Nginx 설치 및 구성**:

```bash
# Nginx 설치
sudo apt install nginx

# Horilla용 Nginx 설정 파일 생성
sudo nano /etc/nginx/sites-available/horilla
```

**최적화된 Nginx 설정**:

```nginx
# /etc/nginx/sites-available/horilla
upstream horilla_app {
    server 127.0.0.1:8000 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;
    server_name your-domain.com www.your-domain.com;
    
    # HTTPS 리다이렉트
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name your-domain.com www.your-domain.com;
    
    # SSL 인증서 설정
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # SSL 보안 설정
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512;
    ssl_session_timeout 10m;
    ssl_session_cache shared:SSL:10m;
    ssl_session_tickets off;
    
    # 보안 헤더
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header X-XSS-Protection "1; mode=block";
    
    # 최대 업로드 크기 (이력서, 문서 등)
    client_max_body_size 50M;
    
    # 정적 파일 서빙
    location /static/ {
        alias /opt/horilla/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }
    
    # 미디어 파일 서빙
    location /media/ {
        alias /opt/horilla/media/;
        expires 1M;
        add_header Cache-Control "public";
    }
    
    # Django 애플리케이션
    location / {
        proxy_pass http://horilla_app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 타임아웃 설정
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
        
        # 버퍼링 설정
        proxy_buffering on;
        proxy_buffer_size 128k;
        proxy_buffers 4 256k;
        proxy_busy_buffers_size 256k;
    }
    
    # 헬스 체크
    location /health/ {
        proxy_pass http://horilla_app;
        access_log off;
    }
}
```

**Nginx 설정 활성화**:

```bash
# 설정 파일 활성화
sudo ln -s /etc/nginx/sites-available/horilla /etc/nginx/sites-enabled/

# 기본 설정 비활성화
sudo rm /etc/nginx/sites-enabled/default

# 설정 테스트
sudo nginx -t

# Nginx 재시작
sudo systemctl restart nginx
sudo systemctl enable nginx
```

### Gunicorn WSGI 서버 설정

**Gunicorn 설치 및 구성**:

```bash
# 가상환경에서 Gunicorn 설치
source /opt/horilla/horillavenv/bin/activate
pip install gunicorn

# Gunicorn 설정 파일 생성
nano /opt/horilla/gunicorn.conf.py
```

**최적화된 Gunicorn 설정**:

```python
# /opt/horilla/gunicorn.conf.py
import multiprocessing

# 서버 설정
bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1
worker_class = "sync"
worker_connections = 1000
max_requests = 1000
max_requests_jitter = 100
preload_app = True

# 타임아웃 설정
timeout = 60
keepalive = 2
graceful_timeout = 30

# 로깅 설정
accesslog = "/opt/horilla/logs/access.log"
errorlog = "/opt/horilla/logs/error.log"
loglevel = "info"
access_log_format = '%h %l %u %t "%r" %s %b "%{Referer}i" "%{User-agent}i" %D'

# 프로세스 설정
user = "horilla"
group = "horilla"
tmp_upload_dir = None
secure_scheme_headers = {
    'X-FORWARDED-PROTOCOL': 'ssl',
    'X-FORWARDED-PROTO': 'https',
    'X-FORWARDED-SSL': 'on'
}

# 성능 최적화
worker_tmp_dir = "/dev/shm"
```

### systemd 서비스 설정

**Horilla systemd 서비스 생성**:

```bash
# 로그 디렉토리 생성
sudo mkdir -p /opt/horilla/logs
sudo chown horilla:horilla /opt/horilla/logs

# systemd 서비스 파일 생성
sudo nano /etc/systemd/system/horilla.service
```

**systemd 서비스 설정**:

```ini
[Unit]
Description=Horilla HRMS Application
After=network.target postgresql.service

[Service]
Type=notify
User=horilla
Group=horilla
WorkingDirectory=/opt/horilla
Environment=PATH=/opt/horilla/horillavenv/bin
Environment=DJANGO_SETTINGS_MODULE=horilla.settings
ExecStart=/opt/horilla/horillavenv/bin/gunicorn -c gunicorn.conf.py horilla.wsgi:application
ExecReload=/bin/kill -s HUP $MAINPID
KillMode=mixed
TimeoutStopSec=5
PrivateTmp=true
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
```

**서비스 활성화 및 시작**:

```bash
# systemd 데몬 재로드
sudo systemctl daemon-reload

# 서비스 활성화
sudo systemctl enable horilla

# 서비스 시작
sudo systemctl start horilla

# 서비스 상태 확인
sudo systemctl status horilla

# 로그 확인
sudo journalctl -u horilla -f
```

### SSL 인증서 설정 (Let's Encrypt)

```bash
# Certbot 설치
sudo apt install certbot python3-certbot-nginx

# SSL 인증서 발급
sudo certbot --nginx -d your-domain.com -d www.your-domain.com

# 자동 갱신 설정
sudo crontab -e
# 다음 라인 추가:
# 0 12 * * * /usr/bin/certbot renew --quiet
```

## 성능 최적화 및 모니터링

### Redis 캐싱 설정

```bash
# Redis 설치
sudo apt install redis-server

# Redis 설정 최적화
sudo nano /etc/redis/redis.conf
```

**Django에서 Redis 캐시 설정**:

```python
# settings.py에 추가
CACHES = {
    'default': {
        'BACKEND': 'django_redis.cache.RedisCache',
        'LOCATION': 'redis://127.0.0.1:6379/1',
        'OPTIONS': {
            'CLIENT_CLASS': 'django_redis.client.DefaultClient',
        }
    }
}

# 세션 백엔드를 Redis로 변경
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'
SESSION_CACHE_ALIAS = 'default'
SESSION_COOKIE_AGE = 3600  # 1시간
```

### 데이터베이스 최적화

```sql
-- PostgreSQL 성능 최적화
-- postgresql.conf 설정 권장값

shared_buffers = 256MB                  # RAM의 25%
effective_cache_size = 1GB              # RAM의 75%
work_mem = 4MB                          # 정렬/해시 작업용
maintenance_work_mem = 64MB             # 유지보수 작업용
wal_buffers = 16MB                      # WAL 버퍼
checkpoint_completion_target = 0.9      # 체크포인트 완료 목표
max_connections = 100                   # 최대 연결 수

-- 인덱스 최적화
CREATE INDEX CONCURRENTLY idx_employee_badge ON employee_employee(badge_id);
CREATE INDEX CONCURRENTLY idx_attendance_date ON attendance_attendance(attendance_date);
CREATE INDEX CONCURRENTLY idx_leave_dates ON leave_leaverequest(start_date, end_date);

-- 테이블 통계 업데이트
ANALYZE;
```

### 모니터링 및 로깅 설정

```python
# Django 로깅 설정 (settings.py)
LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'formatters': {
        'verbose': {
            'format': '{levelname} {asctime} {module} {process:d} {thread:d} {message}',
            'style': '{',
        },
        'simple': {
            'format': '{levelname} {message}',
            'style': '{',
        },
    },
    'handlers': {
        'file_debug': {
            'level': 'DEBUG',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/opt/horilla/logs/debug.log',
            'maxBytes': 1024*1024*10,  # 10MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'file_error': {
            'level': 'ERROR',
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': '/opt/horilla/logs/error.log',
            'maxBytes': 1024*1024*10,  # 10MB
            'backupCount': 5,
            'formatter': 'verbose',
        },
        'console': {
            'level': 'INFO',
            'class': 'logging.StreamHandler',
            'formatter': 'simple'
        },
    },
    'root': {
        'handlers': ['console', 'file_debug', 'file_error'],
        'level': 'INFO',
    },
    'loggers': {
        'django': {
            'handlers': ['file_error'],
            'level': 'ERROR',
            'propagate': False,
        },
        'horilla': {
            'handlers': ['file_debug', 'file_error'],
            'level': 'DEBUG',
            'propagate': False,
        },
    },
}
```

## 백업 및 재해 복구 전략

### 자동화된 백업 스크립트

```bash
#!/bin/bash
# /opt/horilla/scripts/backup.sh

BACKUP_DIR="/opt/horilla/backups"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="horilla_main"
DB_USER="horilla"

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR

# 데이터베이스 백업
pg_dump -U $DB_USER -h localhost $DB_NAME | gzip > "$BACKUP_DIR/db_backup_$DATE.sql.gz"

# 미디어 파일 백업
tar -czf "$BACKUP_DIR/media_backup_$DATE.tar.gz" /opt/horilla/media/

# 설정 파일 백업
tar -czf "$BACKUP_DIR/config_backup_$DATE.tar.gz" /opt/horilla/.env /opt/horilla/gunicorn.conf.py

# 오래된 백업 파일 삭제 (30일 이상)
find $BACKUP_DIR -name "*.gz" -mtime +30 -delete

# 백업 결과 로깅
echo "$(date): Backup completed successfully" >> /opt/horilla/logs/backup.log

# 클라우드 스토리지 업로드 (선택적)
# aws s3 sync $BACKUP_DIR s3://your-backup-bucket/horilla/
```

**백업 스크립트 권한 설정 및 cron 등록**:

```bash
# 실행 권한 부여
chmod +x /opt/horilla/scripts/backup.sh

# cron 작업 등록
sudo crontab -e
# 매일 오전 2시에 백업 실행
0 2 * * * /opt/horilla/scripts/backup.sh
```

## 문제 해결 및 FAQ

### 일반적인 문제들

**1. 데이터베이스 연결 오류**

```bash
# PostgreSQL 서비스 상태 확인
sudo systemctl status postgresql

# 연결 테스트
psql -U horilla -d horilla_main -h localhost

# 로그 확인
sudo tail -f /var/log/postgresql/postgresql-*.log
```

**해결 방법**:
- PostgreSQL 서비스 재시작: `sudo systemctl restart postgresql`
- 방화벽 설정 확인: `sudo ufw status`
- 인증 설정 확인: `/etc/postgresql/*/main/pg_hba.conf`

**2. 정적 파일 서빙 문제**

```bash
# 정적 파일 재수집
python3 manage.py collectstatic --clear --noinput

# 권한 확인 및 수정
sudo chown -R horilla:horilla /opt/horilla/static/
chmod -R 755 /opt/horilla/static/

# Nginx 설정 확인
sudo nginx -t
```

**3. 출근 기록 문제**

```python
# Django shell에서 출근 데이터 확인
from attendance.models import Attendance
from employee.models import Employee

# 특정 직원의 출근 기록 확인
employee = Employee.objects.get(badge_id='EMP001')
attendances = Attendance.objects.filter(
    employee_id=employee
).order_by('-attendance_date')

for att in attendances[:5]:
    print(f"{att.attendance_date}: {att.attendance_clock_in_date} - {att.attendance_clock_out_date}")
```

### 성능 최적화 팁

**데이터베이스 쿼리 최적화**:

```python
# 효율적인 쿼리 사용
from django.db import connection
from django.db.models import Prefetch

# N+1 쿼리 문제 해결
employees = Employee.objects.select_related(
    'employee_work_info__department_id',
    'employee_work_info__job_position_id'
).prefetch_related(
    'employee_work_info'
)

# 쿼리 수행 시간 측정
print(f"쿼리 수: {len(connection.queries)}")
```

**캐싱 전략**:

```python
# 뷰에서 캐싱 사용
from django.views.decorators.cache import cache_page
from django.core.cache import cache

@cache_page(60 * 15)  # 15분 캐싱
def employee_list_view(request):
    employees = Employee.objects.all()
    return render(request, 'employee_list.html', {'employees': employees})

# 수동 캐싱
def get_employee_count():
    count = cache.get('employee_count')
    if count is None:
        count = Employee.objects.count()
        cache.set('employee_count', count, 60 * 60)  # 1시간 캐싱
    return count
```

## 결론: Horilla로 구축하는 미래의 HR 시스템

### Horilla 도입의 장점

**비용 효율성**:
- 💰 **Zero 라이선스 비용**: 연간 수천만원 절약 가능
- 🏠 **자체 호스팅**: 클라우드 비용 최적화
- 🔧 **무제한 커스터마이징**: 외부 업체 의존성 제거
- 📈 **확장성**: 기업 성장에 따른 유연한 확장

**기술적 우수성**:
- 🛡️ **보안**: Django 프레임워크의 검증된 보안 기능
- 📊 **성능**: PostgreSQL 기반 엔터프라이즈급 성능
- 🔄 **통합성**: 기존 시스템과의 API 연동 가능
- 📱 **접근성**: 웹/모바일 멀티 플랫폼 지원

### 다음 단계 및 확장 방향

**단기 목표** (1-3개월):
1. **기본 HR 프로세스 구축** 및 안정화
2. **직원 온보딩** 및 교육 완료
3. **출근 관리 시스템** 도입 및 정착
4. **휴가 관리 프로세스** 자동화

**중기 목표** (3-6개월):
1. **급여 시스템** 완전 자동화
2. **성과 관리 시스템** 도입
3. **모바일 앱** 개발 및 배포
4. **비즈니스 인텔리전스** 대시보드 구축

**장기 목표** (6개월+):
1. **AI 기반 HR 분석** 시스템 구축
2. **다국어 지원** 및 글로벌 확장
3. **외부 시스템 연동** (회계, ERP 등)
4. **고급 보고서** 및 예측 분석

### 커뮤니티 및 지원

**오픈소스 생태계 참여**:
- 📂 **GitHub**: [기여 및 이슈 리포트](https://github.com/horilla-opensource/horilla)
- 💬 **커뮤니티**: 사용자 그룹 및 포럼 참여
- 📖 **문서화**: 한국어 문서 개선에 기여
- 🐛 **버그 리포트**: 발견한 문제 공유

**지속적인 개선**:
- 📚 정기적인 업데이트 및 보안 패치 적용
- 🔄 새로운 기능 요청 및 제안
- 📊 성능 모니터링 및 최적화
- 🛡️ 보안 감사 및 침투 테스트

Horilla는 단순한 HRMS를 넘어서 **기업의 디지털 전환을 이끄는 핵심 플랫폼**입니다. 이 가이드를 통해 구축한 시스템을 바탕으로 더욱 효율적이고 체계적인 인사관리를 실현하시기 바랍니다.

🚀 **지금 바로 시작하세요**: [GitHub에서 Horilla를 다운로드](https://github.com/horilla-opensource/horilla)하고 무료 HRMS 시스템을 구축해보세요!

**"미래의 HR은 디지털과 함께합니다. Horilla로 그 미래를 지금 경험하세요."**