#!/usr/bin/env python3
"""
Jekyll Liquid Warning 자동 수정 스크립트 (v2)
- Helm 템플릿, JSON 템플릿 등 Liquid와 충돌하는 코드 블록을 {% raw %} 태그로 감쌉니다.
- 중첩된 raw 태그 문제를 해결합니다.
"""

import os
import re
import sys
from pathlib import Path

def has_liquid_template_syntax(content):
    """코드 블록이 Liquid와 충돌하는 문법을 포함하는지 확인"""
    patterns = [
        r'\{\{\s*include\s+["\'][\w.-]+["\']',  # {{ include "name" }}
        r'\{\{\s*\.[\w.]+\s*\}\}',             # {{ .Values.something }}
        r'\{\{\s*["\'][^"\']*["\']:\s*["\'][^"\']*["\']',  # {{ "key": "value" }}
        r'\{\{\s*if\s+',                       # {{ if condition }}
        r'\{\{\s*range\s+',                    # {{ range $var := .Values }}
        r'\{\{\s*with\s+',                     # {{ with .Values }}
        r'\{\{\s*end\s*\}\}',                  # {{ end }}
        r'\{\{\s*\$\w+',                       # {{ $variable }}
        r'\{\{\s*toYaml\s+',                   # {{ toYaml . }}
        r'\{\{\s*nindent\s+',                  # {{ nindent 4 }}
        r'\{\{\s*printf\s+',                   # {{ printf "%s" }}
        r'\{\{\s*default\s+',                  # {{ default .Chart.Name }}
        r'\{\{\s*trunc\s+',                    # {{ trunc 63 }}
        r'\{\{\s*trimSuffix\s+',               # {{ trimSuffix "-" }}
        r'\{\{\s*contains\s+',                 # {{ contains $name }}
        r'\{\{\s*quote\s*\}\}',                # {{ quote }}
        r'\{\{\s*sha256sum\s*\}\}',            # {{ sha256sum }}
        r'\{\{\/\*.*?\*\/\}\}',                # {{/* comment */}}
        r'\{\{-.*?-\}\}',                      # {{- template syntax -}}
    ]
    
    for pattern in patterns:
        if re.search(pattern, content, re.DOTALL | re.IGNORECASE):
            return True
    
    return False

def has_raw_tags_inside(content):
    """코드 블록 내에 raw 태그가 있는지 확인"""
    return '{% raw %}' in content or '{% endraw %}' in content

def is_already_wrapped(lines, start_idx, end_idx):
    """이미 {% raw %} 태그로 감싸져 있는지 확인"""
    # 코드 블록 이전에 {% raw %}가 있는지 확인
    for i in range(max(0, start_idx - 3), start_idx):
        if '{% raw %}' in lines[i]:
            # 해당 {% raw %}에 대응하는 {% endraw %}가 코드 블록 이후에 있는지 확인
            for j in range(end_idx + 1, min(len(lines), end_idx + 4)):
                if '{% endraw %}' in lines[j]:
                    return True
    return False

def process_markdown_file(file_path):
    """마크다운 파일을 처리하여 Liquid warning을 수정"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        modified = False
        i = 0
        
        while i < len(lines):
            line = lines[i].strip()
            
            # 코드 블록 시작 찾기 (yaml, json, bash, shell 등)
            if line.startswith('```') and len(line) > 3:
                code_type = line[3:].strip().lower()
                start_idx = i
                
                # 코드 블록 끝 찾기
                end_idx = None
                code_content = []
                
                for j in range(i + 1, len(lines)):
                    if lines[j].strip() == '```':
                        end_idx = j
                        break
                    code_content.append(lines[j])
                
                if end_idx is not None:
                    # 코드 블록 내용 확인
                    full_content = ''.join(code_content)
                    
                    # 이미 raw 태그로 감싸져 있는지 확인
                    if not is_already_wrapped(lines, start_idx, end_idx):
                        # 코드 블록 내에 raw 태그가 있는지 확인
                        if has_raw_tags_inside(full_content):
                            print(f"  ⚠️  건너뜀: {code_type} 코드 블록 (이미 raw 태그 포함, 라인 {start_idx + 1}-{end_idx + 1})")
                        elif has_liquid_template_syntax(full_content):
                            print(f"  🔧 수정: {code_type} 코드 블록 (라인 {start_idx + 1}-{end_idx + 1})")
                            
                            # {% raw %} 태그 추가
                            lines.insert(start_idx, '{% raw %}\n')
                            lines.insert(end_idx + 2, '{% endraw %}\n')  # +2 because we inserted one line above
                            
                            modified = True
                            i = end_idx + 3  # 새로 추가된 라인들을 고려하여 인덱스 조정
                            continue
                
                i = end_idx + 1 if end_idx else i + 1
            else:
                i += 1
        
        if modified:
            # 파일 백업
            backup_path = f"{file_path}.backup"
            if not os.path.exists(backup_path):
                # 원본 파일을 백업 (이미 백업이 있으면 덮어쓰지 않음)
                import shutil
                shutil.copy2(file_path, backup_path)
            
            # 수정된 내용 저장
            with open(file_path, 'w', encoding='utf-8') as f:
                f.writelines(lines)
            
            print(f"  ✅ 수정 완료")
            return True
        else:
            print(f"  ⏩ 수정 불필요")
            return False
            
    except Exception as e:
        print(f"  ❌ 에러: {e}")
        return False

def main():
    """메인 실행 함수"""
    print("🚀 Liquid Warning 자동 수정 스크립트 v2 시작")
    print("=" * 50)
    
    # _posts 디렉토리에서 모든 .md 파일 찾기
    posts_dir = Path('_posts')
    if not posts_dir.exists():
        print("❌ _posts 디렉토리를 찾을 수 없습니다.")
        sys.exit(1)
    
    md_files = list(posts_dir.rglob('*.md'))
    print(f"📁 발견된 마크다운 파일: {len(md_files)}개")
    print()
    
    modified_count = 0
    
    for md_file in md_files:
        print(f"📄 처리 중: {md_file}")
        
        if process_markdown_file(md_file):
            modified_count += 1
        
        print()
    
    print("=" * 50)
    print(f"🎉 완료! 수정된 파일: {modified_count}개")
    
    if modified_count > 0:
        print("\n📝 백업 파일이 생성되었습니다.")
        print("   문제가 없다면 다음 명령으로 백업 파일을 제거할 수 있습니다:")
        print("   find _posts -name '*.backup' -delete")

if __name__ == "__main__":
    main() 