#!/usr/bin/env python3
"""
MarkItDown vs Docling 테스트 스크립트
"""

import subprocess
import sys
import os

def check_python_version():
    """Python 버전 체크"""
    if sys.version_info < (3, 8):
        print("❌ Python 3.8 이상이 필요합니다.")
        return False
    print(f"✅ Python {sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}")
    return True

def install_package(package_name):
    """패키지 설치"""
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", package_name])
        return True
    except subprocess.CalledProcessError:
        print(f"❌ {package_name} 설치 실패")
        return False

def test_markitdown():
    """MarkItDown 테스트"""
    print("\n=== MarkItDown 테스트 ===")
    
    try:
        # MarkItDown 설치 확인
        import markitdown
        print("✅ MarkItDown 설치됨")
        
        # 테스트 파일 생성
        test_content = """# 테스트 문서
        
이것은 MarkItDown 테스트를 위한 간단한 HTML 문서입니다.

## 주요 특징
- 빠른 처리 속도
- 간단한 API
- 다양한 형식 지원
"""
        
        with open("test_markitdown.html", "w", encoding="utf-8") as f:
            f.write(f"<html><body>{test_content}</body></html>")
        
        # 변환 테스트
        md = markitdown.MarkItDown()
        result = md.convert("test_markitdown.html")
        
        print(f"✅ 변환 성공: {len(result.text_content)} 문자")
        print(f"결과 미리보기: {result.text_content[:100]}...")
        
        # 테스트 파일 삭제
        os.remove("test_markitdown.html")
        
        return True
        
    except ImportError:
        print("❌ MarkItDown 미설치")
        print("설치 명령어: pip install markitdown")
        return False
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")
        return False

def test_docling():
    """Docling 테스트"""
    print("\n=== Docling 테스트 ===")
    
    try:
        # Docling 설치 확인
        from docling.document_converter import DocumentConverter
        print("✅ Docling 설치됨")
        
        # 테스트 파일 생성
        test_content = """# 테스트 문서
        
이것은 Docling 테스트를 위한 간단한 HTML 문서입니다.

## 주요 특징
- 고품질 변환
- 구조 보존
- 다양한 출력 형식
"""
        
        with open("test_docling.html", "w", encoding="utf-8") as f:
            f.write(f"<html><body>{test_content}</body></html>")
        
        # 변환 테스트
        converter = DocumentConverter()
        result = converter.convert("test_docling.html")
        
        markdown_output = result.document.export_to_markdown()
        
        print(f"✅ 변환 성공: {len(markdown_output)} 문자")
        print(f"결과 미리보기: {markdown_output[:100]}...")
        
        # 테스트 파일 삭제
        os.remove("test_docling.html")
        
        return True
        
    except ImportError:
        print("❌ Docling 미설치")
        print("설치 명령어: pip install docling")
        return False
    except Exception as e:
        print(f"❌ 테스트 실패: {e}")
        return False

def performance_comparison():
    """성능 비교 테스트"""
    print("\n=== 성능 비교 테스트 ===")
    
    try:
        import time
        import markitdown
        from docling.document_converter import DocumentConverter
        
        # 테스트 파일 생성
        large_content = """
        <html>
        <body>
        <h1>성능 테스트 문서</h1>
        """ + "<p>테스트 문단입니다. " * 1000 + """
        <h2>섹션 1</h2>
        """ + "<p>더 많은 내용입니다. " * 500 + """
        <h2>섹션 2</h2>
        """ + "<p>추가 내용입니다. " * 500 + """
        </body>
        </html>
        """
        
        with open("performance_test.html", "w", encoding="utf-8") as f:
            f.write(large_content)
        
        # MarkItDown 성능 테스트
        md = markitdown.MarkItDown()
        start_time = time.time()
        result1 = md.convert("performance_test.html")
        markitdown_time = time.time() - start_time
        
        # Docling 성능 테스트
        converter = DocumentConverter()
        start_time = time.time()
        result2 = converter.convert("performance_test.html")
        docling_time = time.time() - start_time
        
        print(f"MarkItDown 처리 시간: {markitdown_time:.2f}초")
        print(f"Docling 처리 시간: {docling_time:.2f}초")
        
        if markitdown_time < docling_time:
            print("✅ MarkItDown이 더 빠름")
        else:
            print("✅ Docling이 더 빠름")
        
        # 테스트 파일 삭제
        os.remove("performance_test.html")
        
        return True
        
    except Exception as e:
        print(f"❌ 성능 테스트 실패: {e}")
        return False

def main():
    """메인 함수"""
    print("📋 MarkItDown vs Docling 테스트 도구")
    print("=" * 50)
    
    if not check_python_version():
        return
    
    # 테스트 실행
    test_markitdown()
    test_docling()
    performance_comparison()
    
    print("\n🎉 테스트 완료!")
    print("\n💡 추가 테스트 방법:")
    print("1. PDF 파일로 테스트: python test_markitdown_docling.py --pdf sample.pdf")
    print("2. 성능 벤치마크: python test_markitdown_docling.py --benchmark")

if __name__ == "__main__":
    main() 