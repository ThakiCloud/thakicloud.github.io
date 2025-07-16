#!/usr/bin/env python3
"""
Jekyll Liquid Warning 종합 해결 스크립트
- post_url deprecation warning 해결
- Liquid syntax error 해결
- 특수 문자 및 한글 변수명 문제 해결
"""

import os
import re
import sys
from pathlib import Path

def fix_post_url_references(content):
    """존재하지 않는 post_url 참조를 제거하거나 수정"""
    
    # 존재하지 않는 포스트들의 목록
    non_existent_posts = [
        '2025-06-17-unsloth-korean-llm-training-guide',
        '2025-06-17-unsloth-korean-llm-kubernetes-automation', 
        '2025-06-17-unsloth-korean-llm-kubeflow-automation',
        '2025-06-17-unsloth-korean-llm-ray-kuberay-automation',
        '2025-07-01-plane-project-management-complete-guide',
        '2025-07-01-plane-github-integration-advanced-guide',
        '2025-07-01-plane-kubernetes-production-deployment-guide'
    ]
    
    changes = []
    
    for post_name in non_existent_posts:
        # post_url 참조를 찾아서 처리
        pattern = rf'\{{% post_url {re.escape(post_name)} %\}}\)'
        
        if post_name.startswith('2025-06-17-unsloth'):
            # unsloth 시리즈는 "준비 중" 링크로 변경
            replacement = '#)'
            content = re.sub(pattern, replacement, content)
            if pattern in content:
                changes.append(f"Unsloth 시리즈 {post_name} 링크를 준비 중으로 변경")
        
        elif post_name.startswith('2025-07-01-plane'):
            # plane 시리즈는 "준비 중" 링크로 변경
            replacement = '#)'
            content = re.sub(pattern, replacement, content)
            if pattern in content:
                changes.append(f"Plane 시리즈 {post_name} 링크를 준비 중으로 변경")
    
    # 개별 post_url 링크들을 찾아서 제거 (링크 텍스트는 유지하되 링크만 제거)
    for post_name in non_existent_posts:
        # [링크텍스트]({% post_url post-name %}) 패턴을 [링크텍스트](#) 로 변경
        pattern = rf'\[([^\]]+)\]\(\{{% post_url {re.escape(post_name)} %\}}\)'
        replacement = r'[\1](#)'
        old_content = content
        content = re.sub(pattern, replacement, content)
        if old_content != content:
            changes.append(f"링크 {post_name}를 준비 중으로 변경")
    
    return content, changes

def fix_liquid_syntax_errors(content):
    """Liquid syntax error 수정"""
    changes = []
    
    # 한글 변수명 문제 수정 (예: {{결과}} -> `결과`)
    pattern = r'\{\{([가-힣]+)\}\}'
    matches = re.findall(pattern, content)
    for match in matches:
        old = f'{{{{{match}}}}}'
        new = f'`{match}`'
        content = content.replace(old, new)
        changes.append(f"한글 변수 {match}를 백틱으로 감쌈")
    
    # JSON 형태의 잘못된 Liquid 문법 수정
    # {{ "key": "value" }} 패턴을 `{ "key": "value" }` 로 변경
    pattern = r'\{\{\s*"[^"]+"\s*:\s*"[^"]*"[^}]*\}\}'
    matches = re.findall(pattern, content)
    for match in matches:
        new_match = '`' + match[2:-2] + '`'  # {{ }} 제거하고 백틱으로 감싸기
        content = content.replace(match, new_match)
        changes.append(f"JSON 패턴을 백틱으로 수정: {match[:30]}...")
    
    # GitHub Actions 문법 수정
    # {{ github.event.inputs.something || 'default' }} 패턴 수정
    pattern = r'\{\{\s*github\.[^}]+\}\}'
    matches = re.findall(pattern, content)
    for match in matches:
        new_match = '`' + match[2:-2].strip() + '`'
        content = content.replace(match, new_match)
        changes.append(f"GitHub Actions 문법을 백틱으로 수정")
    
    return content, changes

def needs_raw_tags(content):
    """코드 블록이 raw 태그가 필요한지 확인 (Helm 템플릿 등)"""
    # 이미 raw 태그가 있는지 확인
    if '{%' in content and ('raw' in content or 'endraw' in content):
        return False
    
    # Helm 템플릿 패턴들
    helm_patterns = [
        r'\{\{-?\s*\.\w+',           # {{ .Values.something }}
        r'\{\{-?\s*include\s+',      # {{ include "template" }}
        r'\{\{-?\s*(if|with|range)', # {{ if }}, {{ with }}, {{ range }}
        r'\{\{-?\s*end\s*-?\}\}',    # {{ end }}
        r'\{\{-?\s*\$\w+',           # {{ $variable }}
    ]
    
    for pattern in helm_patterns:
        if re.search(pattern, content):
            return True
    
    return False

def wrap_yaml_blocks_with_raw(content):
    """Helm 템플릿이 포함된 YAML 블록을 raw 태그로 감싸기"""
    lines = content.split('\n')
    result_lines = []
    in_yaml_block = False
    yaml_block_lines = []
    yaml_block_start_idx = 0
    
    i = 0
    while i < len(lines):
        line = lines[i]
        
        if line.strip() == '```yaml' and not in_yaml_block:
            # YAML 블록 시작
            in_yaml_block = True
            yaml_block_lines = [line]
            yaml_block_start_idx = len(result_lines)
        elif line.strip() == '```' and in_yaml_block:
            # YAML 블록 끝
            yaml_block_lines.append(line)
            yaml_block_content = '\n'.join(yaml_block_lines[1:-1])  # ```yaml과 ``` 제외
            
            if needs_raw_tags(yaml_block_content):
                # raw 태그로 감싸기
                result_lines.append('{% raw %}')
                result_lines.extend(yaml_block_lines)
                result_lines.append('{% endraw %}')
            else:
                result_lines.extend(yaml_block_lines)
            
            in_yaml_block = False
            yaml_block_lines = []
        elif in_yaml_block:
            yaml_block_lines.append(line)
        else:
            result_lines.append(line)
        
        i += 1
    
    return '\n'.join(result_lines)

def process_file(file_path):
    """파일 처리"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        all_changes = []
        
        # 1. post_url 참조 수정
        content, changes = fix_post_url_references(content)
        all_changes.extend(changes)
        
        # 2. Liquid syntax error 수정
        content, changes = fix_liquid_syntax_errors(content)
        all_changes.extend(changes)
        
        # 3. YAML 블록을 raw 태그로 감싸기 (필요한 경우만)
        if needs_raw_tags(content):
            content = wrap_yaml_blocks_with_raw(content)
            all_changes.append("YAML 블록을 raw 태그로 감쌈")
        
        # 변경사항이 있으면 파일 저장
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            return all_changes
        
        return []
        
    except Exception as e:
        print(f"오류 처리 중 {file_path}: {e}")
        return []

def main():
    """메인 함수"""
    posts_dir = Path('_posts')
    
    if not posts_dir.exists():
        print("❌ _posts 디렉토리를 찾을 수 없습니다.")
        sys.exit(1)
    
    print("🔧 Liquid Warning 종합 해결 시작...")
    
    total_files = 0
    modified_files = 0
    
    # 모든 마크다운 파일 처리
    for md_file in posts_dir.rglob('*.md'):
        total_files += 1
        changes = process_file(md_file)
        
        if changes:
            modified_files += 1
            print(f"✅ 수정됨: {md_file}")
            for change in changes:
                print(f"   - {change}")
    
    print(f"\n📊 처리 완료:")
    print(f"   - 스캔된 파일: {total_files}개")
    print(f"   - 수정된 파일: {modified_files}개")
    
    if modified_files > 0:
        print(f"\n🎉 {modified_files}개 파일에서 Liquid warning 수정 완료!")
    else:
        print(f"\n✅ 수정할 warning이 없습니다.")

if __name__ == "__main__":
    main() 