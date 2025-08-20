#!/bin/bash

# PDF Arranger macOS 설치 및 테스트 스크립트
# 작성일: 2025-08-20
# 테스트 환경: macOS, Python 3.12.8

set -e

echo "🔍 PDF Arranger macOS 설치 및 테스트 시작"
echo "====================================="

# 현재 환경 정보 출력
echo "📋 시스템 정보:"
echo "- OS: $(uname -s) $(uname -r)"
echo "- Python: $(python3 --version)"
echo "- pip: $(pip3 --version)"
echo ""

# 필요한 시스템 라이브러리 확인
echo "🔍 필요한 시스템 라이브러리 확인:"
required_libs=("gtk+3" "poppler" "cairo" "gobject-introspection" "libhandy")

for lib in "${required_libs[@]}"; do
    if brew list | grep -q "^${lib}$"; then
        echo "✅ $lib 설치됨"
    else
        echo "❌ $lib 설치 필요"
        echo "   설치 명령어: brew install $lib"
    fi
done
echo ""

# GTK+3 및 관련 라이브러리 설치
echo "📦 필요한 라이브러리 설치:"
echo "brew install gtk+3 gobject-introspection libhandy"
if ! brew list | grep -q "^gtk+3$"; then
    brew install gtk+3
fi

if ! brew list | grep -q "^gobject-introspection$"; then
    brew install gobject-introspection
fi

if ! brew list | grep -q "^libhandy$"; then
    brew install libhandy
fi

# Python 패키지 설치
echo ""
echo "🐍 Python 패키지 설치:"
echo "pip3 install --user pycairo PyGObject"
pip3 install --user pycairo PyGObject

echo ""
echo "📦 pikepdf 및 img2pdf 설치:"
pip3 install --user pikepdf img2pdf python-dateutil

echo ""
echo "🚀 PDF Arranger 설치:"
echo "pip3 install --user pdfarranger"
pip3 install --user pdfarranger

# 환경 변수 설정 확인
echo ""
echo "🔧 환경 변수 설정:"
echo "export GI_TYPELIB_PATH=/opt/homebrew/lib/girepository-1.0"
export GI_TYPELIB_PATH="/opt/homebrew/lib/girepository-1.0"

echo "export PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig"
export PKG_CONFIG_PATH="/opt/homebrew/lib/pkgconfig"

# 설치 확인
echo ""
echo "✅ 설치 확인:"
if command -v pdfarranger &> /dev/null; then
    echo "PDF Arranger 설치 성공!"
    echo "버전: $(pdfarranger --version 2>/dev/null || echo '버전 정보 확인 실패')"
else
    echo "❌ PDF Arranger 설치 실패"
    echo "PATH에 추가 필요: export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# 테스트 PDF 생성
echo ""
echo "📄 테스트 PDF 생성:"
python3 -c "
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
import os

# 간단한 테스트 PDF 생성
c = canvas.Canvas('test1.pdf', pagesize=letter)
c.drawString(100, 750, 'Test PDF 1 - Page 1')
c.showPage()
c.drawString(100, 750, 'Test PDF 1 - Page 2')
c.save()

c = canvas.Canvas('test2.pdf', pagesize=letter)
c.drawString(100, 750, 'Test PDF 2 - Page 1')
c.save()

print('✅ 테스트 PDF 파일 생성 완료: test1.pdf, test2.pdf')
" 2>/dev/null || echo "⚠️  reportlab이 설치되지 않아 테스트 PDF 생성 건너뛰기"

echo ""
echo "🎉 PDF Arranger 설치 완료!"
echo ""
echo "📝 사용법:"
echo "1. GUI 실행: pdfarranger"
echo "2. 커맨드라인으로 파일 열기: pdfarranger file1.pdf file2.pdf"
echo ""
echo "💡 문제 해결:"
echo "- PATH 오류시: export PATH=\"\$HOME/.local/bin:\$PATH\""
echo "- GTK 오류시: export GI_TYPELIB_PATH=\"/opt/homebrew/lib/girepository-1.0\""
echo ""
