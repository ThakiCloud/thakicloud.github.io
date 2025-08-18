#!/bin/bash

# RAG-Anything 자동 설치 및 테스트 스크립트
# macOS 환경에서 RAG-Anything 멀티모달 RAG 시스템 설치

set -e

echo "🤖 RAG-Anything 설치 스크립트"
echo "============================="

# 기본 변수 설정
RAG_DIR="$HOME/rag-anything"
BACKUP_DIR="$HOME/rag-anything-backup-$(date +%Y%m%d-%H%M%S)"
VENV_DIR="$HOME/rag-anything-env"

# Python 버전 확인
echo "📋 Python 환경 확인 중..."
python3 --version || { echo "❌ Python 3.8+ 필요"; exit 1; }
pip3 --version || { echo "❌ pip3 필요"; exit 1; }

echo "✅ Python 환경: $(python3 --version)"

# 기존 설치 백업
if [ -d "$RAG_DIR" ]; then
    echo "📦 기존 RAG-Anything 설치 발견 - 백업 중..."
    mv "$RAG_DIR" "$BACKUP_DIR"
    echo "✅ 백업 완료: $BACKUP_DIR"
fi

if [ -d "$VENV_DIR" ]; then
    echo "📦 기존 가상환경 백업 중..."
    mv "$VENV_DIR" "${VENV_DIR}-backup-$(date +%Y%m%d-%H%M%S)"
fi

# 가상환경 생성
echo "🐍 Python 가상환경 생성 중..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"

echo "✅ 가상환경 생성됨: $VENV_DIR"

# RAG-Anything 클론
echo "📥 RAG-Anything 리포지토리 클론 중..."
git clone https://github.com/HKUDS/RAG-Anything.git "$RAG_DIR"
cd "$RAG_DIR"

# pip 업그레이드
echo "⬆️ pip 업그레이드 중..."
pip install --upgrade pip

# RAG-Anything 설치
echo "🔧 RAG-Anything 설치 중..."
echo "⚠️  패키지 설치에 시간이 소요될 수 있습니다..."
pip install -e .

# 추가 기능 설치
echo "🎁 추가 기능 설치 중..."
pip install raganything[all]

# LibreOffice 설치 확인 (macOS)
echo ""
echo "📄 LibreOffice 설치 확인 중..."
if command -v brew &> /dev/null; then
    if brew list --cask libreoffice &> /dev/null; then
        echo "✅ LibreOffice 이미 설치됨"
    else
        read -p "LibreOffice를 설치하시겠습니까? (Office 문서 처리용) [y/N]: " install_libre
        if [[ $install_libre =~ ^[Yy]$ ]]; then
            echo "💡 LibreOffice 설치 중..."
            brew install --cask libreoffice
        else
            echo "⚠️  LibreOffice 미설치 - Office 문서 처리 제한"
        fi
    fi
else
    echo "⚠️  Homebrew 미설치 - LibreOffice 수동 설치 필요"
    echo "💡 LibreOffice 다운로드: https://www.libreoffice.org/download/"
fi

# 의존성 확인
echo ""
echo "🧪 의존성 테스트 중..."

echo "   ReportLab 확인..."
python3 examples/text_format_test.py --check-reportlab --file dummy

echo "   PIL/Pillow 확인..."
python3 examples/image_format_test.py --check-pillow --file dummy

# 버전 확인
echo ""
echo "📊 설치 확인 중..."
RAG_VERSION=$(python3 -c "import raganything; print(getattr(raganything, '__version__', '1.2.7'))" 2>/dev/null || echo "설치됨")
echo "✅ RAG-Anything 버전: $RAG_VERSION"

# 테스트 파일 생성 및 테스트
echo ""
echo "🧪 기능 테스트 실행 중..."

# 테스트 마크다운 문서 생성
cat > test_document.md << 'EOF'
# RAG-Anything 테스트 문서

## 개요
이 문서는 RAG-Anything의 멀티모달 기능을 테스트합니다.

## 주요 기능
- **텍스트 처리**: 자연어 처리 및 임베딩
- **이미지 처리**: Vision Language Model 통합
- **테이블 처리**: 구조화된 데이터 추출
- **수식 처리**: LaTeX 형식 변환

## 테스트 데이터
| 항목 | 값 | 상태 |
|------|----|----- |
| 정확도 | 95.2% | 우수 |
| 처리속도 | 1.2초 | 양호 |
| 메모리 | 2.1GB | 정상 |

## 수식 예제
E = mc²

## 결론
RAG-Anything은 멀티모달 RAG의 혁신적 솔루션입니다.
EOF

# 테스트 이미지 생성
python3 << 'EOF'
try:
    from PIL import Image, ImageDraw
    img = Image.new('RGB', (800, 600), color='white')
    draw = ImageDraw.Draw(img)
    
    # 테스트 콘텐츠 그리기
    draw.rectangle([50, 50, 750, 550], outline='black', width=3)
    draw.text((100, 100), 'RAG-Anything Test Image', fill='black')
    draw.text((100, 150), 'Multimodal Features:', fill='blue')
    draw.text((120, 180), '• Text Processing', fill='green')
    draw.text((120, 210), '• Image Analysis', fill='red')
    draw.text((120, 240), '• Table Extraction', fill='purple')
    draw.text((120, 270), '• Formula Recognition', fill='orange')
    
    # 간단한 차트
    draw.rectangle([100, 350, 200, 450], fill='lightblue')
    draw.rectangle([220, 320, 320, 450], fill='lightgreen')
    draw.rectangle([340, 380, 440, 450], fill='lightcoral')
    draw.text((150, 470), 'Performance Chart', fill='black')
    
    img.save('test_image.png')
    print("✅ 테스트 이미지 생성 완료")
except Exception as e:
    print(f"⚠️  이미지 생성 실패: {e}")
EOF

# 텍스트 파싱 테스트
echo ""
echo "📝 텍스트 파싱 테스트..."
python3 examples/text_format_test.py --file test_document.md

# 이미지 파싱 테스트
if [ -f "test_image.png" ]; then
    echo ""
    echo "🖼️  이미지 파싱 테스트..."
    python3 examples/image_format_test.py --file test_image.png
fi

# 환경 설정 파일 생성
echo ""
echo "⚙️  환경 설정 파일 생성 중..."
cat > .env.example << 'EOF'
# RAG-Anything 환경 설정 예제
# 실제 사용시 .env로 복사하고 값을 설정하세요

### API 키 설정 (하나 이상 필요)
OPENAI_API_KEY=sk-your-openai-key-here
ANTHROPIC_API_KEY=sk-ant-your-anthropic-key-here
GEMINI_API_KEY=your-gemini-key-here

### 파서 설정
PARSER=mineru                    # mineru 또는 docling
PARSE_METHOD=auto               # auto, ocr, txt
OUTPUT_DIR=./output

### 멀티모달 기능 설정
ENABLE_IMAGE_PROCESSING=true
ENABLE_TABLE_PROCESSING=true
ENABLE_EQUATION_PROCESSING=true

### 배치 처리 설정
MAX_CONCURRENT_FILES=2
RECURSIVE_FOLDER_PROCESSING=true

### LLM 설정
LLM_MODEL=gpt-4o
TEMPERATURE=0
MAX_TOKENS=32768
TIMEOUT=240

### 성능 설정
CHUNK_SIZE=1200
CHUNK_OVERLAP_SIZE=100
MAX_PARALLEL_INSERT=2
EOF

# 실행 스크립트 생성
cat > start_rag_anything.sh << 'EOF'
#!/bin/bash
# RAG-Anything 실행 스크립트

echo "🚀 RAG-Anything 시작"
source "$HOME/rag-anything-env/bin/activate"
cd "$HOME/rag-anything"

echo "📍 현재 위치: $(pwd)"
echo "🐍 Python 환경: $(which python3)"
echo "📦 RAG-Anything 버전: $(python3 -c 'import raganything; print(getattr(raganything, "__version__", "1.2.7"))' 2>/dev/null || echo '설치됨')"

echo ""
echo "💡 사용 예시:"
echo "   python3 examples/raganything_example.py --help"
echo "   python3 examples/modalprocessors_example.py --help"
echo ""
EOF

chmod +x start_rag_anything.sh

# 설치 완료 메시지
echo ""
echo "🎉 RAG-Anything 설치 완료!"
echo "========================"
echo "📍 설치 위치: $RAG_DIR"
echo "🐍 가상환경: $VENV_DIR"
echo "📁 테스트 출력: $RAG_DIR/test_output"
echo ""
echo "🚀 시작 방법:"
echo "   source $VENV_DIR/bin/activate"
echo "   cd $RAG_DIR"
echo "   # 또는"
echo "   ./start_rag_anything.sh"
echo ""
echo "📚 주요 명령어:"
echo "   python3 examples/raganything_example.py <file> --api-key <key>"
echo "   python3 examples/modalprocessors_example.py --api-key <key>"
echo "   python3 examples/batch_processing_example.py <directory>"
echo ""
echo "⚙️  설정 파일:"
echo "   cp .env.example .env  # 환경 변수 설정"
echo "   nano .env             # API 키 입력"
echo ""
echo "🔧 테스트 명령어:"
echo "   python3 examples/text_format_test.py --file test_document.md"
echo "   python3 examples/image_format_test.py --file test_image.png"
echo ""
echo "📖 문서 및 예제:"
echo "   ls examples/          # 예제 파일 목록"
echo "   cat README.md         # 상세 사용법"
echo ""
echo "💡 문제 해결:"
echo "   python3 examples/text_format_test.py --check-reportlab --file dummy"
echo "   python3 examples/image_format_test.py --check-pillow --file dummy"

# 정리
echo ""
echo "🧹 테스트 파일 정리 중..."
rm -f test_document.md test_image.png

echo ""
echo "✅ 설치 스크립트 완료!"
