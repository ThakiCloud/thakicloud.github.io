#!/bin/bash

# PDF Arranger 관련 zshrc Aliases 설정
# 작성일: 2025-08-20

echo "🔧 PDF Arranger 관련 zshrc aliases 설정"
echo "====================================="

# .zshrc에 추가할 내용
cat << 'EOF' >> ~/.zshrc

# =============================================================================
# PDF Arranger 관련 Aliases (2025-08-20 추가)
# =============================================================================

# PDF Arranger 관련 디렉토리
export PDFARRANGER_TEST_DIR="$HOME/tutorials/pdfarranger-test"

# PDF Arranger 기본 명령어
alias pdfgui="pdfarranger"                    # PDF Arranger GUI 실행
alias pdfmerge="python3 -c 'import pikepdf, sys; merged=pikepdf.new(); [merged.pages.extend(pikepdf.open(f).pages) for f in sys.argv[1:]]; merged.save(\"merged.pdf\"); print(\"✅ PDF 병합 완료: merged.pdf\")'"
alias pdfinfo="python3 -c 'import pikepdf, sys; pdf=pikepdf.open(sys.argv[1]); print(f\"📄 {sys.argv[1]}: {len(pdf.pages)}페이지\"); pdf.close()'"

# PDF 조작 함수들
pdfextract() {
    if [ $# -lt 3 ]; then
        echo "사용법: pdfextract <입력파일> <시작페이지> <끝페이지> [출력파일]"
        echo "예시: pdfextract document.pdf 1 3 extracted.pdf"
        return 1
    fi
    
    local input=$1
    local start=$2
    local end=$3
    local output=${4:-"extracted.pdf"}
    
    python3 -c "
import pikepdf
import sys

try:
    pdf = pikepdf.open('$input')
    new_pdf = pikepdf.new()
    
    start_idx = max(0, $start - 1)  # 1-based to 0-based
    end_idx = min(len(pdf.pages), $end)
    
    for i in range(start_idx, end_idx):
        new_pdf.pages.append(pdf.pages[i])
    
    new_pdf.save('$output')
    print(f'✅ 페이지 {$start}-{$end} 추출 완료: $output')
    
    pdf.close()
    new_pdf.close()
except Exception as e:
    print(f'❌ 오류: {e}')
"
}

pdfsplit() {
    if [ $# -lt 1 ]; then
        echo "사용법: pdfsplit <입력파일> [접두어]"
        echo "예시: pdfsplit document.pdf page"
        return 1
    fi
    
    local input=$1
    local prefix=${2:-"page"}
    
    python3 -c "
import pikepdf
import sys

try:
    pdf = pikepdf.open('$input')
    total_pages = len(pdf.pages)
    
    for i, page in enumerate(pdf.pages):
        new_pdf = pikepdf.new()
        new_pdf.pages.append(page)
        filename = f'${prefix}_{i+1:03d}.pdf'
        new_pdf.save(filename)
        new_pdf.close()
        print(f'페이지 {i+1}/{total_pages}: {filename}')
    
    pdf.close()
    print(f'✅ PDF 분할 완료: {total_pages}개 파일 생성')
except Exception as e:
    print(f'❌ 오류: {e}')
"
}

pdfrotate() {
    if [ $# -lt 3 ]; then
        echo "사용법: pdfrotate <입력파일> <각도> <출력파일>"
        echo "각도: 90, 180, 270 (시계방향)"
        echo "예시: pdfrotate document.pdf 90 rotated.pdf"
        return 1
    fi
    
    local input=$1
    local angle=$2
    local output=$3
    
    python3 -c "
import pikepdf

try:
    pdf = pikepdf.open('$input')
    
    for page in pdf.pages:
        page.rotate($angle, relative=True)
    
    pdf.save('$output')
    print(f'✅ {$angle}도 회전 완료: $output')
    pdf.close()
except Exception as e:
    print(f'❌ 오류: {e}')
"
}

# 개발 및 테스트 관련
alias pdftest="cd \$PDFARRANGER_TEST_DIR"
alias pdfsetup="\$PDFARRANGER_TEST_DIR/test-pdfarranger-setup.sh"
alias pdfcreate="python3 -c 'from reportlab.pdfgen import canvas; from reportlab.lib.pagesizes import letter; import sys; c=canvas.Canvas(sys.argv[1], pagesize=letter); c.drawString(100, 750, \"Test PDF\"); c.save(); print(f\"✅ 테스트 PDF 생성: {sys.argv[1]}\")'"

# 유용한 단축 명령어
alias ll="ls -la"
alias pdfls="ls -la *.pdf 2>/dev/null || echo '📄 PDF 파일이 없습니다.'"
alias pdfclean="rm -f *.pdf && echo '🗑️  PDF 파일들을 삭제했습니다.'"

EOF

echo ""
echo "✅ ~/.zshrc에 PDF Arranger aliases 추가 완료!"
echo ""
echo "📝 추가된 aliases:"
echo "  pdfgui      - PDF Arranger GUI 실행"
echo "  pdfmerge    - 여러 PDF 병합"
echo "  pdfinfo     - PDF 정보 확인"
echo "  pdfextract  - PDF 페이지 추출"
echo "  pdfsplit    - PDF 페이지별 분할"
echo "  pdfrotate   - PDF 회전"
echo "  pdftest     - 테스트 디렉토리로 이동"
echo "  pdfsetup    - PDF Arranger 설치 스크립트 실행"
echo "  pdfcreate   - 테스트 PDF 생성"
echo "  pdfls       - PDF 파일 목록"
echo "  pdfclean    - PDF 파일들 삭제"
echo ""
echo "🔄 변경사항 적용: source ~/.zshrc"
echo ""
