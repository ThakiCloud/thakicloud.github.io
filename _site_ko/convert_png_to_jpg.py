#!/usr/bin/env python3
"""
PNG to JPG Converter Script for Jekyll Blog

이 스크립트는 다음 작업을 수행합니다:
1. assets/images 폴더 하위의 모든 PNG 파일을 JPG로 변환
2. _posts 폴더의 마크다운 파일에서 PNG 링크를 JPG로 업데이트
3. 원본 PNG 파일 삭제 (백업 후)
"""

import os
import sys
import shutil
import re
from pathlib import Path
from PIL import Image
import argparse

class PngToJpgConverter:
    def __init__(self, assets_dir="assets/images", posts_dir="_posts", backup_dir="backup_png"):
        self.assets_dir = Path(assets_dir)
        self.posts_dir = Path(posts_dir)
        self.backup_dir = Path(backup_dir)
        self.converted_files = []
        self.updated_posts = []
        
    def create_backup(self):
        """PNG 파일들을 백업합니다."""
        if not self.backup_dir.exists():
            self.backup_dir.mkdir(parents=True)
            
        png_files = list(self.assets_dir.rglob("*.png"))
        if not png_files:
            print("❌ PNG 파일을 찾을 수 없습니다.")
            return False
            
        print(f"📦 {len(png_files)}개의 PNG 파일을 백업 중...")
        
        for png_file in png_files:
            # 상대 경로 유지하여 백업
            relative_path = png_file.relative_to(self.assets_dir)
            backup_path = self.backup_dir / relative_path
            backup_path.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(png_file, backup_path)
            print(f"  ✅ {png_file} → {backup_path}")
            
        return True
    
    def convert_png_to_jpg(self, png_path, quality=95):
        """PNG 파일을 JPG로 변환합니다."""
        jpg_path = png_path.with_suffix('.jpg')
        
        try:
            with Image.open(png_path) as img:
                # PNG가 투명도를 가지고 있다면 흰색 배경으로 변환
                if img.mode in ('RGBA', 'LA', 'P'):
                    # 새로운 RGB 이미지 생성 (흰색 배경)
                    rgb_img = Image.new('RGB', img.size, (255, 255, 255))
                    if img.mode == 'P':
                        img = img.convert('RGBA')
                    rgb_img.paste(img, mask=img.split()[-1] if img.mode in ('RGBA', 'LA') else None)
                    img = rgb_img
                elif img.mode != 'RGB':
                    img = img.convert('RGB')
                
                # JPG로 저장
                img.save(jpg_path, 'JPEG', quality=quality, optimize=True)
                
            return jpg_path
            
        except Exception as e:
            print(f"❌ {png_path} 변환 실패: {e}")
            return None
    
    def convert_all_png_files(self):
        """모든 PNG 파일을 JPG로 변환합니다."""
        png_files = list(self.assets_dir.rglob("*.png"))
        
        if not png_files:
            print("❌ 변환할 PNG 파일이 없습니다.")
            return
            
        print(f"🔄 {len(png_files)}개의 PNG 파일을 JPG로 변환 중...")
        
        for png_file in png_files:
            print(f"  🔄 변환 중: {png_file}")
            jpg_file = self.convert_png_to_jpg(png_file)
            
            if jpg_file:
                self.converted_files.append((png_file, jpg_file))
                print(f"  ✅ 변환 완료: {jpg_file}")
            else:
                print(f"  ❌ 변환 실패: {png_file}")
    
    def update_markdown_files(self):
        """마크다운 파일의 PNG 링크를 JPG로 업데이트합니다."""
        md_files = list(self.posts_dir.rglob("*.md"))
        
        if not md_files:
            print("❌ 마크다운 파일을 찾을 수 없습니다.")
            return
            
        print(f"📝 {len(md_files)}개의 마크다운 파일에서 링크 업데이트 중...")
        
        # PNG 링크를 찾는 정규식 패턴
        png_pattern = re.compile(r'(/assets/images/[^)\s]*\.png)', re.IGNORECASE)
        
        for md_file in md_files:
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                
                # PNG 링크를 JPG로 변경
                def replace_png_with_jpg(match):
                    png_path = match.group(1)
                    jpg_path = png_path.replace('.png', '.jpg').replace('.PNG', '.jpg')
                    return jpg_path
                
                content = png_pattern.sub(replace_png_with_jpg, content)
                
                # 변경사항이 있으면 파일 업데이트
                if content != original_content:
                    with open(md_file, 'w', encoding='utf-8') as f:
                        f.write(content)
                    
                    self.updated_posts.append(md_file)
                    print(f"  ✅ 업데이트: {md_file}")
                    
                    # 변경된 링크들 출력
                    matches = png_pattern.findall(original_content)
                    for match in matches:
                        jpg_link = match.replace('.png', '.jpg').replace('.PNG', '.jpg')
                        print(f"    📎 {match} → {jpg_link}")
                        
            except Exception as e:
                print(f"❌ {md_file} 업데이트 실패: {e}")
    
    def cleanup_png_files(self):
        """변환된 PNG 파일들을 삭제합니다."""
        if not self.converted_files:
            print("❌ 삭제할 PNG 파일이 없습니다.")
            return
            
        print(f"🗑️  {len(self.converted_files)}개의 원본 PNG 파일 삭제 중...")
        
        for png_file, jpg_file in self.converted_files:
            try:
                if jpg_file.exists():
                    png_file.unlink()
                    print(f"  ✅ 삭제: {png_file}")
                else:
                    print(f"  ❌ JPG 파일이 없어 PNG 삭제 건너뜀: {png_file}")
            except Exception as e:
                print(f"❌ {png_file} 삭제 실패: {e}")
    
    def print_summary(self):
        """변환 결과 요약을 출력합니다."""
        print("\n" + "="*60)
        print("🎉 변환 작업 완료!")
        print("="*60)
        print(f"📊 변환된 이미지: {len(self.converted_files)}개")
        print(f"📝 업데이트된 포스트: {len(self.updated_posts)}개")
        
        if self.converted_files:
            print("\n📸 변환된 이미지 목록:")
            for png_file, jpg_file in self.converted_files:
                print(f"  • {png_file.name} → {jpg_file.name}")
        
        if self.updated_posts:
            print("\n📄 업데이트된 포스트:")
            for post in self.updated_posts:
                print(f"  • {post}")
        
        if self.backup_dir.exists():
            print(f"\n💾 백업 위치: {self.backup_dir}")
            print("   (문제가 없다면 백업 폴더를 삭제해도 됩니다)")
    
    def run(self, skip_backup=False):
        """전체 변환 프로세스를 실행합니다."""
        print("🚀 PNG to JPG 변환 작업을 시작합니다...")
        print(f"📁 이미지 디렉토리: {self.assets_dir}")
        print(f"📁 포스트 디렉토리: {self.posts_dir}")
        
        # 1. 백업 생성
        if not skip_backup:
            if not self.create_backup():
                return
        else:
            print("⚠️  백업을 건너뜁니다.")
        
        # 2. PNG를 JPG로 변환
        self.convert_all_png_files()
        
        # 3. 마크다운 파일 업데이트
        self.update_markdown_files()
        
        # 4. 원본 PNG 파일 삭제
        self.cleanup_png_files()
        
        # 5. 결과 요약
        self.print_summary()

def main():
    parser = argparse.ArgumentParser(description='PNG 파일을 JPG로 변환하고 마크다운 링크를 업데이트합니다.')
    parser.add_argument('--assets-dir', default='assets/images', help='이미지 디렉토리 경로 (기본값: assets/images)')
    parser.add_argument('--posts-dir', default='_posts', help='포스트 디렉토리 경로 (기본값: _posts)')
    parser.add_argument('--backup-dir', default='backup_png', help='백업 디렉토리 경로 (기본값: backup_png)')
    parser.add_argument('--skip-backup', action='store_true', help='백업을 건너뜁니다')
    parser.add_argument('--dry-run', action='store_true', help='실제 변환 없이 미리보기만 실행합니다')
    
    args = parser.parse_args()
    
    # 필수 패키지 확인
    try:
        from PIL import Image
    except ImportError:
        print("❌ Pillow 패키지가 필요합니다. 다음 명령어로 설치하세요:")
        print("   pip install Pillow")
        sys.exit(1)
    
    # 디렉토리 존재 확인
    if not Path(args.assets_dir).exists():
        print(f"❌ 이미지 디렉토리를 찾을 수 없습니다: {args.assets_dir}")
        sys.exit(1)
    
    if not Path(args.posts_dir).exists():
        print(f"❌ 포스트 디렉토리를 찾을 수 없습니다: {args.posts_dir}")
        sys.exit(1)
    
    # Dry run 모드
    if args.dry_run:
        print("🔍 Dry Run 모드: 실제 변환 없이 미리보기를 실행합니다.")
        
        assets_dir = Path(args.assets_dir)
        png_files = list(assets_dir.rglob("*.png"))
        
        print(f"\n📸 발견된 PNG 파일 ({len(png_files)}개):")
        for png_file in png_files:
            jpg_file = png_file.with_suffix('.jpg')
            print(f"  • {png_file} → {jpg_file}")
        
        posts_dir = Path(args.posts_dir)
        md_files = list(posts_dir.rglob("*.md"))
        png_pattern = re.compile(r'(/assets/images/[^)\s]*\.png)', re.IGNORECASE)
        
        print(f"\n📝 PNG 링크가 포함된 마크다운 파일:")
        for md_file in md_files:
            try:
                with open(md_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                matches = png_pattern.findall(content)
                if matches:
                    print(f"  • {md_file}")
                    for match in matches:
                        jpg_link = match.replace('.png', '.jpg').replace('.PNG', '.jpg')
                        print(f"    📎 {match} → {jpg_link}")
            except Exception as e:
                print(f"❌ {md_file} 읽기 실패: {e}")
        
        print("\n✅ Dry run 완료. 실제 변환을 원한다면 --dry-run 옵션을 제거하고 다시 실행하세요.")
        return
    
    # 실제 변환 실행
    converter = PngToJpgConverter(
        assets_dir=args.assets_dir,
        posts_dir=args.posts_dir,
        backup_dir=args.backup_dir
    )
    
    try:
        converter.run(skip_backup=args.skip_backup)
    except KeyboardInterrupt:
        print("\n⚠️  사용자에 의해 중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ 오류가 발생했습니다: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main() 