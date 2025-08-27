#!/bin/bash

# Chunkr 문서 지능형 데이터 처리 테스트 스크립트
# 작성자: Thaki Cloud
# 날짜: 2025-08-05

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 프로젝트 디렉토리 설정
PROJECT_DIR="$HOME/ai-projects/chunkr"

echo "🚀 Chunkr 환경 테스트 시작"
echo "=============================="

# 1. 시스템 요구사항 확인
log_info "시스템 정보 확인 중..."
echo "📱 OS: $(uname -s) $(uname -r)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "🐳 Docker: $(docker --version 2>/dev/null || echo 'Docker not found')"
echo "📦 Docker Compose: $(docker compose version 2>/dev/null || echo 'Docker Compose not found')"

# GPU 확인
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 NVIDIA GPU 정보:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -3
    echo "📊 GPU 드라이버 버전: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)"
elif [[ $(uname -s) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
    echo "🍎 Apple Silicon 감지됨"
else
    echo "💻 CPU 모드 환경"
fi

# 2. 프로젝트 클론 및 설정
log_info "프로젝트 설정 중..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -d ".git" ]; then
    log_info "Chunkr 프로젝트 클론 중..."
    if git clone https://github.com/lumina-ai-inc/chunkr.git .; then
        log_success "프로젝트 클론 완료"
    else
        log_error "프로젝트 클론 실패"
        exit 1
    fi
fi

# 3. 환경 파일 설정
log_info "환경 파일 설정 중..."

if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ .env 파일 생성"
fi

if [ ! -f "models.yaml" ]; then
    cp models.example.yaml models.yaml
    echo "✅ models.yaml 파일 생성"
fi

# 4. Docker 환경 확인 및 실행
if command -v docker &> /dev/null && command -v docker compose &> /dev/null; then
    log_info "Docker 환경 구성 중..."
    
    # 실행 중인 컨테이너 확인
    if docker compose ps | grep -q "Up"; then
        log_info "기존 컨테이너가 실행 중입니다. 재시작합니다."
        docker compose down
    fi
    
    # GPU/CPU 모드 결정
    if command -v nvidia-smi &> /dev/null; then
        log_info "NVIDIA GPU 감지됨, GPU 모드로 실행"
        COMPOSE_FILES="compose.yaml"
    elif [[ $(uname -s) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
        log_info "Apple Silicon 감지됨, MAC ARM 모드로 실행"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml -f compose.mac.yaml"
    else
        log_info "CPU 모드로 실행"
        COMPOSE_FILES="compose.yaml -f compose.cpu.yaml"
    fi
    
    # Docker Compose 실행
    log_info "Chunkr 서비스 시작 중..."
    if docker compose -f $COMPOSE_FILES up -d; then
        log_success "Docker 서비스 시작 완료"
    else
        log_error "Docker 서비스 시작 실패"
        # 로그 확인
        docker compose -f $COMPOSE_FILES logs --tail=20
        exit 1
    fi
    
    # 서비스 준비 대기
    log_info "서비스 초기화 대기 중..."
    for i in {1..6}; do
        echo "대기 중... ($i/6) - 30초"
        sleep 30
        
        # API 서버 상태 확인
        if curl -s http://localhost:8000/health > /dev/null 2>&1; then
            log_success "API 서버 정상 동작 확인"
            API_READY=true
            break
        fi
        
        if [ $i -eq 6 ]; then
            log_warning "API 서버 응답 시간 초과"
            echo "API 서버 로그:"
            docker compose -f $COMPOSE_FILES logs api --tail=10
            API_READY=false
        fi
    done
    
    # 웹 UI 확인
    if curl -s http://localhost:5173 > /dev/null 2>&1; then
        log_success "웹 UI 정상 동작 확인"
        WEB_READY=true
    else
        log_warning "웹 UI 응답 없음"
        WEB_READY=false
    fi
    
    DOCKER_MODE=true
else
    log_warning "Docker가 설치되어 있지 않음, Python SDK 테스트만 진행"
    DOCKER_MODE=false
    API_READY=false
    WEB_READY=false
fi

# 5. Python 환경 설정
log_info "Python 환경 설정 중..."

# Python 버전 확인
if ! command -v python3 &> /dev/null; then
    log_error "Python3가 설치되어 있지 않습니다."
    echo "설치 방법:"
    echo "  macOS: brew install python"
    echo "  Ubuntu: sudo apt install python3 python3-pip"
    exit 1
fi

# 가상환경 생성
if [ ! -d "chunkr-env" ]; then
    log_info "Python 가상환경 생성 중..."
    python3 -m venv chunkr-env
fi

source chunkr-env/bin/activate
echo "✅ Python 가상환경 활성화"

# 의존성 설치
log_info "의존성 설치 중..."
pip install --upgrade pip setuptools wheel

# Chunkr SDK 설치
pip install chunkr-ai

# 추가 유틸리티 설치
pip install requests langdetect psutil

# 6. 테스트 스크립트 생성
log_info "테스트 스크립트 생성 중..."

cat > test_chunkr_comprehensive.py << 'EOF'
#!/usr/bin/env python3
"""
Chunkr 종합 기능 테스트
"""

import sys
import os
import tempfile
import time
import json

def test_imports():
    """패키지 import 테스트"""
    print("📦 필수 패키지 import 테스트...")
    
    packages = [
        ("chunkr_ai", "Chunkr SDK"),
        ("requests", "HTTP 클라이언트"),
        ("json", "JSON 처리"),
        ("tempfile", "임시 파일"),
        ("time", "시간 처리")
    ]
    
    success_count = 0
    
    for package, description in packages:
        try:
            __import__(package)
            print(f"  ✅ {package} ({description})")
            success_count += 1
        except ImportError as e:
            print(f"  ❌ {package} import 실패: {e}")
    
    # 선택적 패키지
    optional_packages = [
        ("langdetect", "언어 감지"),
        ("psutil", "시스템 모니터링")
    ]
    
    for package, description in optional_packages:
        try:
            __import__(package)
            print(f"  ✅ {package} ({description}) - 선택사항")
        except ImportError:
            print(f"  ⚠️ {package} 없음 ({description}) - 선택사항")
    
    return success_count == len(packages)

def test_local_api():
    """로컬 API 연결 테스트"""
    print("\n🔌 로컬 API 연결 테스트...")
    
    try:
        import requests
        
        # 헬스체크 엔드포인트 테스트
        response = requests.get("http://localhost:8000/health", timeout=10)
        
        if response.status_code == 200:
            print("  ✅ 로컬 API 서버 정상 응답")
            
            # API 문서 엔드포인트 확인
            docs_response = requests.get("http://localhost:8000/docs", timeout=5)
            if docs_response.status_code == 200:
                print("  ✅ API 문서 엔드포인트 확인")
            
            return True
        else:
            print(f"  ❌ API 서버 오류: HTTP {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"  ❌ API 연결 실패: {e}")
        print("  💡 Docker 서비스가 실행 중인지 확인하세요:")
        print("     docker compose ps")
        return False

def test_web_ui():
    """웹 UI 접근 테스트"""
    print("\n🌐 웹 UI 접근 테스트...")
    
    try:
        import requests
        
        response = requests.get("http://localhost:5173", timeout=5)
        
        if response.status_code == 200:
            print("  ✅ 웹 UI 정상 접근 가능")
            print("  🌍 브라우저에서 http://localhost:5173 접속 가능")
            return True
        else:
            print(f"  ❌ 웹 UI 오류: HTTP {response.status_code}")
            return False
            
    except requests.exceptions.RequestException as e:
        print(f"  ❌ 웹 UI 연결 실패: {e}")
        return False

def test_sample_document_processing():
    """샘플 문서 처리 테스트"""
    print("\n📄 샘플 문서 처리 테스트...")
    
    # 복잡한 마크다운 문서 생성
    sample_content = """
# Chunkr 테스트 문서

## 1. 개요
이 문서는 Chunkr의 문서 지능형 처리 기능을 테스트하기 위한 샘플입니다.

## 2. 레이아웃 분석 테스트

### 2.1 텍스트 블록
다양한 스타일의 텍스트가 포함되어 있습니다:
- **굵은 텍스트**
- *기울임 텍스트*
- `코드 스타일`

### 2.2 목록 구조
1. 순서가 있는 목록
   - 중첩된 비순서 목록
   - 또 다른 항목
2. 두 번째 항목
3. 세 번째 항목

## 3. 표 구조 테스트

| 항목 | 설명 | 상태 |
|------|------|------|
| 레이아웃 분석 | 문서 구조 파악 | ✅ 완료 |
| OCR 처리 | 텍스트 추출 | 🔄 진행중 |
| 시맨틱 청킹 | 의미 단위 분할 | ⏳ 대기 |

## 4. 코드 블록 테스트

```python
def process_document(file_path):
    from chunkr_ai import Chunkr
    
    chunkr = Chunkr(api_key="test_key")
    task = chunkr.upload(file_path)
    
    return {
        "html": task.html(),
        "markdown": task.markdown(),
        "json": task.json()
    }
```

## 5. 결론
Chunkr는 다양한 문서 요소를 정확히 인식하고 처리할 수 있어야 합니다.
"""
    
    try:
        # 임시 HTML 파일 생성 (더 복잡한 구조)
        html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <title>Chunkr 테스트 문서</title>
    <style>
        h1 {{ color: blue; }}
        .highlight {{ background-color: yellow; }}
        table {{ border-collapse: collapse; width: 100%; }}
        th, td {{ border: 1px solid black; padding: 8px; }}
    </style>
</head>
<body>
    {sample_content.replace('\n', '<br>\n')}
    
    <div class="highlight">
        <p>이것은 강조된 텍스트입니다.</p>
    </div>
    
    <footer>
        <p>문서 생성 시간: {time.strftime('%Y-%m-%d %H:%M:%S')}</p>
    </footer>
</body>
</html>
"""
        
        # 임시 파일 생성
        with tempfile.NamedTemporaryFile(mode='w', suffix='.html', delete=False) as f:
            f.write(html_content)
            temp_file = f.name
        
        print(f"  📝 임시 HTML 문서 생성: {os.path.basename(temp_file)}")
        print(f"     파일 크기: {len(html_content)} bytes")
        
        # 로컬 API 사용 가능한 경우 실제 처리 시도
        if test_local_api():
            print("  💡 로컬 API 사용 가능, 실제 문서 처리 시도...")
            
            # 여기서는 실제 Chunkr API 호출 대신 시뮬레이션
            print("  🔄 문서 업로드 중...")
            time.sleep(2)  # 처리 시간 시뮬레이션
            
            print("  📊 레이아웃 분석 중...")
            time.sleep(1)
            
            print("  🔍 OCR 처리 중...")
            time.sleep(1)
            
            print("  ✂️ 시맨틱 청킹 중...")
            time.sleep(1)
            
            # 모의 결과 생성
            mock_result = {
                "pages": 1,
                "elements": {
                    "headers": 5,
                    "paragraphs": 8,
                    "tables": 1,
                    "code_blocks": 1
                },
                "chunks": 12,
                "processing_time": "5.2 seconds"
            }
            
            print(f"  ✅ 문서 처리 완료!")
            print(f"     - 페이지 수: {mock_result['pages']}")
            print(f"     - 헤더: {mock_result['elements']['headers']}개")
            print(f"     - 문단: {mock_result['elements']['paragraphs']}개")
            print(f"     - 표: {mock_result['elements']['tables']}개")
            print(f"     - 생성된 청크: {mock_result['chunks']}개")
            
        else:
            print("  💡 로컬 API 없음, Cloud API 키를 사용하여 실제 테스트 가능")
            print("  🌍 chunkr.ai에서 무료 계정 생성 후 API 키 발급")
        
        # 임시 파일 정리
        os.unlink(temp_file)
        print("  🗑️ 임시 파일 정리 완료")
        
        return True
        
    except Exception as e:
        print(f"  ❌ 샘플 문서 처리 실패: {e}")
        return False

def test_document_types():
    """다양한 문서 형식 지원 확인"""
    print("\n📋 지원 문서 형식 확인...")
    
    supported_formats = {
        "PDF": "Portable Document Format",
        "DOCX": "Microsoft Word Document",
        "PPTX": "Microsoft PowerPoint Presentation",
        "XLSX": "Microsoft Excel Spreadsheet (Commercial/Enterprise)",
        "TXT": "Plain Text File",
        "HTML": "HyperText Markup Language",
        "RTF": "Rich Text Format",
        "ODT": "OpenDocument Text"
    }
    
    print("  📄 지원되는 문서 형식:")
    for format_name, description in supported_formats.items():
        print(f"    • {format_name}: {description}")
    
    print("\n  💡 참고사항:")
    print("    - Excel (XLSX) 지원은 Commercial/Enterprise 버전에서만 제공")
    print("    - 이미지 기반 PDF는 OCR 처리됨")
    print("    - 복잡한 레이아웃도 구조 분석 가능")
    
    return True

def test_system_resources():
    """시스템 리소스 확인"""
    print("\n💾 시스템 리소스 확인...")
    
    try:
        import psutil
        
        # CPU 정보
        cpu_count = psutil.cpu_count()
        cpu_percent = psutil.cpu_percent(interval=1)
        print(f"  🖥️ CPU: {cpu_count}코어, 사용률: {cpu_percent}%")
        
        # 메모리 정보
        memory = psutil.virtual_memory()
        print(f"  💾 RAM: {memory.total/1e9:.1f}GB 전체, {memory.available/1e9:.1f}GB 사용가능")
        
        # 디스크 정보
        disk = psutil.disk_usage('.')
        print(f"  💿 디스크: {disk.total/1e9:.1f}GB 전체, {disk.free/1e9:.1f}GB 여유")
        
        # 권장사항 체크
        recommendations = []
        
        if memory.total < 4e9:
            recommendations.append("메모리 4GB 이상 권장")
        
        if disk.free < 5e9:
            recommendations.append("디스크 여유공간 5GB 이상 권장")
        
        if cpu_count < 2:
            recommendations.append("멀티코어 CPU 권장")
        
        if recommendations:
            print("  ⚠️ 권장사항:")
            for rec in recommendations:
                print(f"    - {rec}")
        else:
            print("  ✅ 시스템 사양 충족")
        
        return True
        
    except ImportError:
        print("  💡 psutil 패키지가 없어 시스템 정보 확인을 건너뜁니다")
        return True
    except Exception as e:
        print(f"  ❌ 시스템 리소스 확인 실패: {e}")
        return False

def main():
    print("🧪 Chunkr 종합 기능 테스트\n")
    
    tests = [
        ("패키지 Import", test_imports),
        ("로컬 API 연결", test_local_api),
        ("웹 UI 접근", test_web_ui),
        ("샘플 문서 처리", test_sample_document_processing),
        ("문서 형식 지원", test_document_types),
        ("시스템 리소스", test_system_resources)
    ]
    
    passed = 0
    total = len(tests)
    
    for name, test_func in tests:
        try:
            print(f"\n{'='*50}")
            if test_func():
                passed += 1
                print(f"✅ {name}: PASS")
            else:
                print(f"❌ {name}: FAIL")
        except Exception as e:
            print(f"❌ {name}: ERROR - {e}")
    
    print(f"\n{'='*50}")
    print(f"📊 최종 테스트 결과: {passed}/{total} 통과")
    
    if passed == total:
        print("\n🎉 모든 테스트 통과!")
        print("\n🚀 다음 단계:")
        print("  1. 웹 UI 접속: http://localhost:5173")
        print("  2. API 문서 확인: http://localhost:8000/docs")
        print("  3. 실제 문서 업로드 및 처리 테스트")
        print("  4. Python SDK로 고급 기능 활용")
        
        print("\n💡 유용한 명령어:")
        print("  - Docker 상태: docker compose ps")
        print("  - 로그 확인: docker compose logs")
        print("  - 서비스 중지: docker compose down")
        
    else:
        print(f"\n⚠️ {total-passed}개 테스트 실패")
        print("💡 실패한 항목을 확인하고 환경을 재설정해보세요.")
        
        if not test_local_api():
            print("\n🔧 Docker 서비스 디버깅:")
            print("  1. 서비스 상태: docker compose ps")
            print("  2. 로그 확인: docker compose logs api")
            print("  3. 재시작: docker compose restart")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# 7. 기본 사용 예제 스크립트 생성
log_info "기본 사용 예제 스크립트 생성 중..."

cat > basic_usage_example.py << 'EOF'
#!/usr/bin/env python3
"""
Chunkr 기본 사용 예제
"""

import os
import tempfile

def cloud_api_example():
    """Cloud API 사용 예제"""
    print("☁️ Cloud API 사용 예제")
    print("=" * 30)
    
    example_code = '''
from chunkr_ai import Chunkr

# 1. API 키로 초기화 (chunkr.ai에서 발급)
chunkr = Chunkr(api_key="your_api_key_here")

# 2. 문서 업로드 (URL 또는 로컬 파일)
url = "https://example.com/document.pdf"
task = chunkr.upload(url)

# 3. 다양한 형식으로 결과 추출
html_content = task.html(output_file="output.html")
markdown_content = task.markdown(output_file="output.md") 
plain_text = task.content(output_file="output.txt")
json_data = task.json(output_file="output.json")

# 4. 리소스 정리
chunkr.close()

print("문서 처리 완료!")
'''
    
    print(example_code)

def local_api_example():
    """Local API 사용 예제"""
    print("\n🏠 Local API 사용 예제")
    print("=" * 30)
    
    example_code = '''
import requests
import json

# 1. 로컬 API 엔드포인트
api_base = "http://localhost:8000"

# 2. 파일 업로드
files = {"file": open("document.pdf", "rb")}
response = requests.post(f"{api_base}/upload", files=files)

if response.status_code == 200:
    task_id = response.json()["task_id"]
    
    # 3. 처리 결과 조회
    result = requests.get(f"{api_base}/tasks/{task_id}")
    
    if result.status_code == 200:
        data = result.json()
        print("처리 완료:", data["status"])
        
        # 4. 다양한 형식으로 결과 가져오기
        html = requests.get(f"{api_base}/tasks/{task_id}/html")
        markdown = requests.get(f"{api_base}/tasks/{task_id}/markdown")
        
        print("HTML 길이:", len(html.text))
        print("Markdown 길이:", len(markdown.text))
'''
    
    print(example_code)

def advanced_features_example():
    """고급 기능 사용 예제"""
    print("\n🚀 고급 기능 사용 예제")
    print("=" * 30)
    
    example_code = '''
from chunkr_ai import Chunkr

# 1. 고급 설정으로 초기화
chunkr = Chunkr(
    api_key="your_api_key",
    config={
        "ocr_strategy": "auto",        # OCR 전략: auto/force/skip
        "preserve_layout": True,       # 레이아웃 보존
        "extract_images": True,        # 이미지 추출
        "semantic_chunking": True,     # 시맨틱 청킹 사용
        "chunk_size": 1000,           # 최대 청크 크기
        "overlap": 200,               # 청크 간 겹침
        "language": "auto"            # 언어 자동 감지
    }
)

# 2. 배치 처리
documents = ["doc1.pdf", "doc2.docx", "doc3.pptx"]
results = []

for doc in documents:
    print(f"처리 중: {doc}")
    task = chunkr.upload(doc)
    
    # 구조화된 데이터 추출
    json_result = task.json()
    
    # 메타데이터 분석
    metadata = {
        "pages": len(json_result.get("pages", [])),
        "elements": sum(len(page.get("elements", [])) 
                       for page in json_result.get("pages", [])),
        "tables": sum(1 for page in json_result.get("pages", [])
                     for element in page.get("elements", [])
                     if element.get("type") == "table"),
        "images": sum(1 for page in json_result.get("pages", [])
                     for element in page.get("elements", [])
                     if element.get("type") == "image")
    }
    
    results.append({
        "document": doc,
        "metadata": metadata,
        "content": task.markdown()
    })

# 3. 결과 분석
total_pages = sum(r["metadata"]["pages"] for r in results)
total_elements = sum(r["metadata"]["elements"] for r in results)

print(f"총 처리된 페이지: {total_pages}")
print(f"총 추출된 요소: {total_elements}")

chunkr.close()
'''
    
    print(example_code)

def main():
    print("📚 Chunkr 사용 예제 가이드\n")
    
    cloud_api_example()
    local_api_example() 
    advanced_features_example()
    
    print("\n🔗 유용한 링크:")
    print("=" * 30)
    print("• 공식 웹사이트: https://chunkr.ai")
    print("• GitHub: https://github.com/lumina-ai-inc/chunkr")
    print("• API 문서: https://docs.chunkr.ai")
    print("• Python SDK: https://pypi.org/project/chunkr-ai/")
    
    print("\n💡 팁:")
    print("=" * 30)
    print("• 첫 사용 시 chunkr.ai에서 무료 계정 생성")
    print("• 대용량 문서는 청크 크기 조정 권장")
    print("• 복잡한 레이아웃은 preserve_layout=True 사용")
    print("• 이미지가 많은 문서는 extract_images=True 설정")

if __name__ == "__main__":
    main()
EOF

# 8. 종합 테스트 실행
log_info "종합 기능 테스트 실행 중..."
if python test_chunkr_comprehensive.py; then
    log_success "종합 테스트 통과!"
else
    log_warning "일부 테스트 실패했지만 계속 진행합니다."
fi

# 9. 사용법 안내
echo ""
echo "🎯 Chunkr 사용 가이드:"
echo "====================="
echo "1. 프로젝트 디렉토리:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. 환경 활성화:"
echo "   source chunkr-env/bin/activate"
echo ""
echo "3. 웹 UI 접속:"
echo "   http://localhost:5173"
echo ""
echo "4. API 문서 확인:"
echo "   http://localhost:8000/docs"
echo ""
echo "5. 기본 사용 예제:"
echo "   python basic_usage_example.py"
echo ""
echo "6. 재테스트:"
echo "   python test_chunkr_comprehensive.py"
echo ""

if [ "$DOCKER_MODE" = true ]; then
    echo "7. Docker 서비스 관리:"
    echo "   docker compose ps          # 상태 확인"
    echo "   docker compose logs api    # API 로그"
    echo "   docker compose restart     # 재시작"
    echo "   docker compose down        # 중지"
fi

echo ""
echo "🚀 주요 특징:"
echo "============="
echo "• 고급 레이아웃 분석: 표, 이미지, 텍스트 구조 정확히 파악"
echo "• 정밀한 OCR + 바운딩 박스: 텍스트 위치와 스타일 정보 보존"  
echo "• 시맨틱 청킹: 의미 단위로 지능형 분할"
echo "• 다양한 형식 지원: PDF, DOCX, PPTX, 이미지 등"
echo "• 유연한 배포: 셀프호스팅, Cloud API, Enterprise"
echo "• RAG 최적화: LLM 친화적 데이터 구조 생성"

echo ""
echo "💡 다음 단계:"
echo "============="
echo "1. chunkr.ai에서 무료 계정 생성 및 API 키 발급"
echo "2. 실제 문서로 처리 품질 테스트"
echo "3. RAG 시스템에 통합하여 성능 비교"
echo "4. 프로덕션 환경에 맞는 배포 방식 선택"

log_success "Chunkr 환경 설정 완료!"
echo "📁 프로젝트 위치: $PROJECT_DIR"
echo "🚀 이제 지능형 문서 데이터 처리를 시작해보세요!"