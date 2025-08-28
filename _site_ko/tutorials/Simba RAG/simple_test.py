#!/usr/bin/env python3
"""
Simba RAG 시스템 간단 검증 스크립트
이 스크립트는 Simba RAG 시스템의 기본 구성요소들이 올바르게 작동하는지 확인합니다.
"""

import sys
import os
import platform
from datetime import datetime

def print_header():
    """헤더 출력"""
    print("=" * 60)
    print("🤖 Simba RAG 시스템 간단 검증 스크립트")
    print("=" * 60)
    print(f"📅 테스트 시간: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"💻 운영체제: {platform.system()} {platform.release()}")
    print(f"🐍 Python 버전: {sys.version}")
    print("-" * 60)

def check_python_version():
    """Python 버전 확인"""
    print("1. Python 버전 확인...")
    
    version = sys.version_info
    if version.major == 3 and version.minor >= 8:
        print(f"   ✅ Python {version.major}.{version.minor}.{version.micro} (호환)")
        return True
    else:
        print(f"   ❌ Python {version.major}.{version.minor}.{version.micro} (Python 3.8+ 필요)")
        return False

def check_required_packages():
    """필수 패키지 확인"""
    print("2. 필수 패키지 확인...")
    
    required_packages = [
        'openai',
        'langchain',
        'chromadb',
        'sentence_transformers',
        'pandas',
        'numpy',
        'redis',
        'dotenv',
        'streamlit'
    ]
    
    missing_packages = []
    
    for package in required_packages:
        try:
            if package == 'dotenv':
                import python_dotenv
                print(f"   ✅ {package} (python-dotenv)")
            else:
                __import__(package)
                print(f"   ✅ {package}")
        except ImportError:
            print(f"   ❌ {package} (누락)")
            missing_packages.append(package)
    
    if missing_packages:
        print(f"\n   📦 설치 필요 패키지: {', '.join(missing_packages)}")
        print("   💡 설치 명령어:")
        if 'dotenv' in missing_packages:
            missing_packages.remove('dotenv')
            missing_packages.append('python-dotenv')
        print(f"   pip install {' '.join(missing_packages)}")
        return False
    
    return True

def check_environment_variables():
    """환경 변수 확인"""
    print("3. 환경 변수 확인...")
    
    env_vars = ['OPENAI_API_KEY']
    all_set = True
    
    for var in env_vars:
        value = os.getenv(var)
        if value:
            print(f"   ✅ {var}: 설정됨 ({'*' * 8}...)")
        else:
            print(f"   ❌ {var}: 설정되지 않음")
            all_set = False
    
    if not all_set:
        print("   💡 환경 변수 설정 방법:")
        print("   export OPENAI_API_KEY='your-api-key-here'")
        print("   또는 .env 파일 생성")
    
    return all_set

def test_basic_functionality():
    """기본 기능 테스트"""
    print("4. 기본 기능 테스트...")
    
    try:
        # OpenAI 설정 테스트
        import openai
        print("   ✅ OpenAI 패키지 로드")
        
        # LangChain 설정 테스트
        from langchain.embeddings import OpenAIEmbeddings
        print("   ✅ LangChain 임베딩 로드")
        
        # ChromaDB 설정 테스트
        import chromadb
        print("   ✅ ChromaDB 로드")
        
        # Redis 연결 테스트
        try:
            import redis
            r = redis.Redis(host='localhost', port=6379, db=0)
            r.ping()
            print("   ✅ Redis 연결 성공")
        except Exception as e:
            print(f"   ⚠️ Redis 연결 실패: {str(e)}")
            print("   💡 Redis 시작: brew services start redis")
        
        return True
        
    except Exception as e:
        print(f"   ❌ 기본 기능 테스트 실패: {str(e)}")
        return False

def create_sample_rag_test():
    """샘플 RAG 테스트 생성"""
    print("5. 샘플 RAG 테스트...")
    
    try:
        # 환경 변수 확인
        if not os.getenv('OPENAI_API_KEY'):
            print("   ⚠️ OPENAI_API_KEY가 설정되지 않아 실제 테스트 건너뜀")
            return True
        
        # 간단한 텍스트 처리 테스트
        from langchain.text_splitter import RecursiveCharacterTextSplitter
        
        sample_text = """
        인공지능(AI)은 컴퓨터 시스템이 인간의 지능을 모방하는 기술입니다.
        머신러닝은 데이터로부터 패턴을 학습하는 AI의 한 분야입니다.
        딥러닝은 신경망을 사용하는 머신러닝의 한 방법입니다.
        """
        
        text_splitter = RecursiveCharacterTextSplitter(
            chunk_size=100,
            chunk_overlap=20
        )
        
        chunks = text_splitter.split_text(sample_text)
        print(f"   ✅ 텍스트 분할 테스트 완료 ({len(chunks)} 청크)")
        
        # 임베딩 모델 테스트 (실제 API 호출 없이)
        from langchain.embeddings import OpenAIEmbeddings
        embeddings = OpenAIEmbeddings(openai_api_key=os.getenv('OPENAI_API_KEY'))
        print("   ✅ 임베딩 모델 초기화 완료")
        
        # ChromaDB 인메모리 테스트
        import chromadb
        chroma_client = chromadb.Client()
        collection = chroma_client.create_collection(name="test_collection")
        print("   ✅ ChromaDB 인메모리 테스트 완료")
        
        return True
        
    except Exception as e:
        print(f"   ❌ 샘플 RAG 테스트 실패: {str(e)}")
        return False

def generate_report(checks):
    """결과 리포트 생성"""
    print("-" * 60)
    print("📊 검증 결과 리포트")
    print("-" * 60)
    
    total_checks = len(checks)
    passed_checks = sum(checks.values())
    
    for check_name, result in checks.items():
        status = "✅ 통과" if result else "❌ 실패"
        print(f"{check_name}: {status}")
    
    print(f"\n🎯 전체 결과: {passed_checks}/{total_checks} 통과")
    
    if passed_checks == total_checks:
        print("🎉 모든 검증 통과! Simba RAG 시스템을 시작할 준비가 되었습니다.")
        return True
    else:
        print("⚠️ 일부 검증 실패. 위의 안내를 따라 문제를 해결하세요.")
        return False

def main():
    """메인 실행 함수"""
    print_header()
    
    # 각 검증 단계 실행
    checks = {
        "Python 버전": check_python_version(),
        "필수 패키지": check_required_packages(),
        "환경 변수": check_environment_variables(),
        "기본 기능": test_basic_functionality(),
        "샘플 RAG": create_sample_rag_test()
    }
    
    # 결과 리포트
    success = generate_report(checks)
    
    print("\n" + "=" * 60)
    
    if success:
        print("🚀 다음 단계:")
        print("1. 튜토리얼 문서의 '실행 및 테스트' 섹션 진행")
        print("2. 웹 인터페이스 실행: streamlit run app.py")
        print("3. 성능 테스트 실행: python scripts/performance_monitor.py")
    else:
        print("🔧 문제 해결 후 다시 실행하세요:")
        print("python3 simple_test.py")
    
    print("=" * 60)
    
    return success

if __name__ == "__main__":
    try:
        success = main()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print("\n\n⚠️ 사용자에 의해 중단되었습니다.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ 예상치 못한 오류 발생: {str(e)}")
        sys.exit(1) 