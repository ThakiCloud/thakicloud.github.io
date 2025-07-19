#!/usr/bin/env python3
"""
Seed-X-Instruct-7B 모델 변환 및 테스트 스크립트
macOS Apple Silicon 환경용
"""

import os
import sys
import subprocess
import time
import platform
from pathlib import Path
import shutil

class SeedXModelTester:
    def __init__(self):
        self.home_dir = Path.home()
        self.models_dir = self.home_dir / "Models"
        self.downloads_dir = self.home_dir / "Downloads"
        self.llama_cpp_dir = self.downloads_dir / "llama.cpp"
        self.model_name = "ByteDance-Seed/Seed-X-Instruct-7B"
        
        # 결과 저장용
        self.results = {}
        
    def check_system_requirements(self):
        """시스템 요구사항 확인"""
        print("🔍 시스템 요구사항 확인 중...")
        
        # macOS 확인
        if platform.system() != "Darwin":
            print("❌ 이 스크립트는 macOS 전용입니다.")
            return False
            
        # Apple Silicon 확인
        try:
            result = subprocess.run(['uname', '-m'], capture_output=True, text=True)
            if 'arm64' not in result.stdout:
                print("❌ Apple Silicon이 필요합니다.")
                return False
        except:
            print("❌ 시스템 아키텍처 확인 실패")
            return False
            
        # RAM 확인 (최소 16GB)
        try:
            result = subprocess.run(['sysctl', 'hw.memsize'], capture_output=True, text=True)
            mem_bytes = int(result.stdout.split(': ')[1])
            mem_gb = mem_bytes / (1024**3)
            
            if mem_gb < 16:
                print(f"⚠️  RAM이 부족합니다: {mem_gb:.1f}GB (최소 16GB 권장)")
            else:
                print(f"✅ RAM: {mem_gb:.1f}GB")
        except:
            print("⚠️  RAM 확인 실패")
            
        # 저장 공간 확인
        try:
            result = subprocess.run(['df', '-h', str(self.home_dir)], capture_output=True, text=True)
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 2:
                available = lines[1].split()[3]
                print(f"✅ 사용 가능 공간: {available}")
        except:
            print("⚠️  저장 공간 확인 실패")
            
        return True
    
    def setup_directories(self):
        """필요한 디렉토리 생성"""
        print("📁 디렉토리 설정 중...")
        self.models_dir.mkdir(exist_ok=True)
        self.downloads_dir.mkdir(exist_ok=True)
        print(f"✅ 모델 디렉토리: {self.models_dir}")
        print(f"✅ 다운로드 디렉토리: {self.downloads_dir}")
    
    def check_dependencies(self):
        """의존성 확인"""
        print("🔧 의존성 확인 중...")
        
        dependencies = {
            'python3': 'python3 --version',
            'git': 'git --version',
            'cmake': 'cmake --version',
            'brew': 'brew --version'
        }
        
        missing_deps = []
        for dep, check_cmd in dependencies.items():
            try:
                result = subprocess.run(check_cmd.split(), 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    version = result.stdout.split('\n')[0]
                    print(f"✅ {dep}: {version}")
                else:
                    missing_deps.append(dep)
            except FileNotFoundError:
                missing_deps.append(dep)
                
        if missing_deps:
            print(f"❌ 누락된 의존성: {', '.join(missing_deps)}")
            print("📝 설치 명령어:")
            for dep in missing_deps:
                if dep == 'brew':
                    print("   /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"")
                else:
                    print(f"   brew install {dep}")
            return False
            
        return True
    
    def setup_python_environment(self):
        """Python 가상환경 설정"""
        print("🐍 Python 환경 설정 중...")
        
        # 가상환경 디렉토리
        venv_seed = self.home_dir / "venv_seed_x"
        venv_mlx = self.home_dir / "venv_mlx"
        
        # 기존 가상환경이 있으면 건너뛰기
        if venv_seed.exists():
            print(f"✅ 기존 가상환경 발견: {venv_seed}")
        else:
            print("📦 Seed-X 가상환경 생성 중...")
            try:
                subprocess.run([
                    'python3', '-m', 'venv', str(venv_seed)
                ], check=True)
                print(f"✅ 가상환경 생성: {venv_seed}")
            except subprocess.CalledProcessError:
                print("❌ 가상환경 생성 실패")
                return False
                
        if venv_mlx.exists():
            print(f"✅ 기존 MLX 환경 발견: {venv_mlx}")
        else:
            print("📦 MLX 가상환경 생성 중...")
            try:
                subprocess.run([
                    'python3', '-m', 'venv', str(venv_mlx)
                ], check=True)
                print(f"✅ MLX 환경 생성: {venv_mlx}")
            except subprocess.CalledProcessError:
                print("❌ MLX 환경 생성 실패")
                return False
        
        return True
    
    def install_huggingface_deps(self):
        """Hugging Face 라이브러리 설치"""
        print("🤗 Hugging Face 라이브러리 설치 중...")
        
        venv_path = self.home_dir / "venv_seed_x" / "bin" / "pip"
        
        packages = [
            "huggingface_hub[cli]",
            "transformers",
            "torch",
            "safetensors"
        ]
        
        for package in packages:
            try:
                print(f"📦 설치 중: {package}")
                subprocess.run([
                    str(venv_path), "install", "--upgrade", package
                ], check=True, capture_output=True)
                print(f"✅ 설치 완료: {package}")
            except subprocess.CalledProcessError as e:
                print(f"❌ 설치 실패: {package}")
                return False
                
        return True
    
    def check_huggingface_auth(self):
        """Hugging Face 인증 확인"""
        print("🔑 Hugging Face 인증 확인 중...")
        
        try:
            venv_python = self.home_dir / "venv_seed_x" / "bin" / "python"
            result = subprocess.run([
                str(venv_python), "-c", 
                "from huggingface_hub import whoami; print(whoami())"
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0 and "username" in result.stdout:
                print("✅ Hugging Face 인증 확인됨")
                return True
            else:
                print("❌ Hugging Face 인증이 필요합니다.")
                print("📝 다음 명령어로 로그인하세요:")
                print(f"   source {self.home_dir}/venv_seed_x/bin/activate")
                print("   huggingface-cli login")
                return False
                
        except (subprocess.CalledProcessError, subprocess.TimeoutExpired):
            print("❌ Hugging Face 인증 확인 실패")
            return False
    
    def build_llama_cpp(self):
        """llama.cpp 빌드"""
        print("🔨 llama.cpp 빌드 중...")
        
        if self.llama_cpp_dir.exists():
            print(f"✅ 기존 llama.cpp 발견: {self.llama_cpp_dir}")
            # 최신 업데이트 확인
            try:
                subprocess.run(
                    ['git', 'pull'], 
                    cwd=self.llama_cpp_dir, 
                    check=True, 
                    capture_output=True
                )
                print("✅ llama.cpp 업데이트 완료")
            except subprocess.CalledProcessError:
                print("⚠️  업데이트 실패, 기존 버전 사용")
        else:
            print("📥 llama.cpp 클론 중...")
            try:
                subprocess.run([
                    'git', 'clone', 
                    'https://github.com/ggerganov/llama.cpp.git',
                    str(self.llama_cpp_dir)
                ], check=True)
                print("✅ llama.cpp 클론 완료")
            except subprocess.CalledProcessError:
                print("❌ llama.cpp 클론 실패")
                return False
        
        # Metal 지원으로 빌드
        print("⚙️  Apple Silicon 최적화 빌드 중...")
        try:
            # CPU 코어 수 확인
            result = subprocess.run(
                ['sysctl', '-n', 'hw.ncpu'], 
                capture_output=True, text=True
            )
            cpu_count = int(result.stdout.strip())
            
            # 빌드 실행
            subprocess.run([
                'make', 'LLAMA_METAL=1', f'-j{cpu_count}'
            ], cwd=self.llama_cpp_dir, check=True)
            
            print("✅ llama.cpp 빌드 완료")
            
            # 빌드 결과 확인
            main_binary = self.llama_cpp_dir / "main"
            quantize_binary = self.llama_cpp_dir / "quantize"
            
            if main_binary.exists() and quantize_binary.exists():
                print("✅ 바이너리 확인 완료")
                return True
            else:
                print("❌ 바이너리 생성 실패")
                return False
                
        except subprocess.CalledProcessError:
            print("❌ llama.cpp 빌드 실패")
            return False
    
    def download_model(self):
        """모델 다운로드 (작은 샘플만)"""
        print("📥 모델 정보 확인 중...")
        
        # 실제 다운로드는 용량이 크므로 정보만 확인
        try:
            venv_python = self.home_dir / "venv_seed_x" / "bin" / "python"
            test_script = f"""
from huggingface_hub import model_info
info = model_info("{self.model_name}")
print(f"모델명: {{info.modelId}}")
print(f"다운로드 수: {{info.downloads}}")
print(f"좋아요 수: {{info.likes}}")
print(f"아키텍처: {{info.config.get('architectures', 'N/A') if info.config else 'N/A'}}")
"""
            
            result = subprocess.run([
                str(venv_python), "-c", test_script
            ], capture_output=True, text=True, timeout=30)
            
            if result.returncode == 0:
                print("✅ 모델 정보 확인:")
                print(result.stdout)
                return True
            else:
                print("❌ 모델 정보 확인 실패")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ 모델 정보 확인 시간 초과")
            return False
    
    def install_mlx(self):
        """MLX 라이브러리 설치"""
        print("🚀 MLX 라이브러리 설치 중...")
        
        venv_pip = self.home_dir / "venv_mlx" / "bin" / "pip"
        
        packages = ["mlx", "mlx-lm"]
        
        for package in packages:
            try:
                print(f"📦 설치 중: {package}")
                subprocess.run([
                    str(venv_pip), "install", "--upgrade", package
                ], check=True, capture_output=True)
                print(f"✅ 설치 완료: {package}")
            except subprocess.CalledProcessError:
                print(f"❌ 설치 실패: {package}")
                return False
                
        return True
    
    def test_mlx_installation(self):
        """MLX 설치 테스트"""
        print("🧪 MLX 설치 테스트 중...")
        
        try:
            venv_python = self.home_dir / "venv_mlx" / "bin" / "python"
            test_script = """
import mlx.core as mx
import mlx_lm
print(f"MLX 버전: {mx.__version__}")
print(f"MLX-LM 버전: {mlx_lm.__version__}")
print("✅ MLX 정상 작동")
"""
            
            result = subprocess.run([
                str(venv_python), "-c", test_script
            ], capture_output=True, text=True, timeout=10)
            
            if result.returncode == 0:
                print("✅ MLX 테스트 성공:")
                print(result.stdout)
                return True
            else:
                print("❌ MLX 테스트 실패")
                print(result.stderr)
                return False
                
        except subprocess.TimeoutExpired:
            print("❌ MLX 테스트 시간 초과")
            return False
    
    def create_test_scripts(self):
        """테스트 스크립트 생성"""
        print("📝 테스트 스크립트 생성 중...")
        
        # 벤치마크 스크립트
        benchmark_script = self.models_dir / "benchmark_seed_x.sh"
        benchmark_content = f"""#!/bin/bash

echo "🔥 Seed-X-Instruct-7B 성능 벤치마크"
echo "======================================"

# 시스템 정보
echo "💻 시스템 정보:"
echo "   - macOS: $(sw_vers -productVersion)"
echo "   - 칩셋: $(sysctl -n machdep.cpu.brand_string)"
echo "   - RAM: $(sysctl -n hw.memsize | awk '{{printf "%.1f GB", $1/1024/1024/1024}}')"
echo ""

# llama.cpp 테스트 (모델이 있는 경우)
if [ -f "{self.models_dir}/seed-x-instruct-7b-q4_k_m.gguf" ]; then
    echo "📊 llama.cpp (GGUF Q4_K_M) 테스트"
    time {self.llama_cpp_dir}/main \\
      -m {self.models_dir}/seed-x-instruct-7b-q4_k_m.gguf \\
      -p "Python의 장점을 설명해주세요." \\
      -n 100 \\
      -ngl 35 \\
      --simple-io
else
    echo "⚠️  GGUF 모델 파일을 찾을 수 없습니다."
fi

echo ""
echo "✅ 벤치마크 완료"
"""
        
        with open(benchmark_script, 'w') as f:
            f.write(benchmark_content)
        benchmark_script.chmod(0o755)
        
        # MLX 테스트 스크립트
        mlx_test_script = self.models_dir / "test_mlx_seed_x.py"
        mlx_test_content = f"""#!/usr/bin/env python3
import time
import platform

def test_mlx_environment():
    print("🚀 MLX 환경 테스트")
    print("==================")
    
    print(f"🖥️  시스템: {{platform.system()}} {{platform.release()}}")
    print(f"⚙️  아키텍처: {{platform.machine()}}")
    
    try:
        import mlx.core as mx
        import mlx_lm
        
        print(f"✅ MLX Core: {{mx.__version__}}")
        print(f"✅ MLX-LM: {{mlx_lm.__version__}}")
        
        # 간단한 텐서 연산 테스트
        start_time = time.time()
        a = mx.random.normal((1000, 1000))
        b = mx.random.normal((1000, 1000))
        c = mx.matmul(a, b)
        mx.eval(c)
        elapsed = time.time() - start_time
        
        print(f"⚡ 매트릭스 연산 (1000x1000): {{elapsed:.3f}}초")
        print("✅ MLX 기본 기능 정상 작동")
        
        return True
        
    except ImportError as e:
        print(f"❌ MLX 가져오기 실패: {{e}}")
        return False
    except Exception as e:
        print(f"❌ MLX 테스트 실패: {{e}}")
        return False

if __name__ == "__main__":
    test_mlx_environment()
"""
        
        with open(mlx_test_script, 'w') as f:
            f.write(mlx_test_content)
        mlx_test_script.chmod(0o755)
        
        print(f"✅ 벤치마크 스크립트: {benchmark_script}")
        print(f"✅ MLX 테스트 스크립트: {mlx_test_script}")
        
        return True
    
    def create_aliases_guide(self):
        """zshrc aliases 가이드 생성"""
        print("🔧 zshrc aliases 가이드 생성 중...")
        
        aliases_file = self.models_dir / "seed_x_aliases.sh"
        aliases_content = f"""#!/bin/bash

# Seed-X-Instruct-7B 편의 기능 aliases
# ~/.zshrc에 추가하거나 source로 실행

# ===================
# Seed-X-Instruct-7B Aliases
# ===================

# 환경 변수
export SEED_X_MODELS="{self.models_dir}"
export LLAMA_CPP_DIR="{self.llama_cpp_dir}"

# 가상환경 활성화
alias activate-seed="source {self.home_dir}/venv_seed_x/bin/activate"
alias activate-mlx="source {self.home_dir}/venv_mlx/bin/activate"

# llama.cpp 관련
alias llama-seed="$LLAMA_CPP_DIR/main -m $SEED_X_MODELS/seed-x-instruct-7b-q4_k_m.gguf"
alias llama-chat="$LLAMA_CPP_DIR/main -m $SEED_X_MODELS/seed-x-instruct-7b-q4_k_m.gguf -i -ngl 35"

# MLX 관련
alias mlx-test="python $SEED_X_MODELS/test_mlx_seed_x.py"

# 벤치마크 및 모니터링
alias benchmark-seed="$SEED_X_MODELS/benchmark_seed_x.sh"

# 모델 디렉토리 이동
alias cdmodels="cd $SEED_X_MODELS"

# 사용법 출력
alias seed-help="echo '
🤖 Seed-X-Instruct-7B 사용법
========================

가상환경 활성화:
  activate-seed    # Seed-X 환경
  activate-mlx     # MLX 환경

테스트 실행:
  mlx-test        # MLX 환경 테스트
  benchmark-seed  # 성능 벤치마크

디렉토리 이동:
  cdmodels        # 모델 디렉토리로 이동

llama.cpp 사용 (모델 다운로드 후):
  llama-seed      # 단일 추론
  llama-chat      # 대화형 모드
'"

echo "✅ aliases 파일 생성 완료: {aliases_file}"
echo ""
echo "📝 사용법:"
echo "   source {aliases_file}"
echo "   또는 ~/.zshrc에 다음 라인 추가:"
echo "   source {aliases_file}"
"""
        
        with open(aliases_file, 'w') as f:
            f.write(aliases_content)
        aliases_file.chmod(0o755)
        
        print(f"✅ Aliases 파일: {aliases_file}")
        return True
    
    def run_comprehensive_test(self):
        """종합 테스트 실행"""
        print("🧪 종합 테스트 시작")
        print("=" * 50)
        
        test_results = {}
        
        # 1. 시스템 요구사항
        test_results['system'] = self.check_system_requirements()
        
        # 2. 디렉토리 설정
        test_results['directories'] = True
        self.setup_directories()
        
        # 3. 의존성 확인
        test_results['dependencies'] = self.check_dependencies()
        
        # 4. Python 환경
        test_results['python_env'] = self.setup_python_environment()
        
        # 5. Hugging Face 라이브러리
        if test_results['python_env']:
            test_results['hf_libs'] = self.install_huggingface_deps()
        else:
            test_results['hf_libs'] = False
        
        # 6. llama.cpp 빌드
        if test_results['dependencies']:
            test_results['llama_cpp'] = self.build_llama_cpp()
        else:
            test_results['llama_cpp'] = False
            
        # 7. 모델 정보 확인 (다운로드 대신)
        if test_results['hf_libs']:
            test_results['model_info'] = self.download_model()
        else:
            test_results['model_info'] = False
            
        # 8. MLX 설치
        test_results['mlx_install'] = self.install_mlx()
        
        # 9. MLX 테스트
        if test_results['mlx_install']:
            test_results['mlx_test'] = self.test_mlx_installation()
        else:
            test_results['mlx_test'] = False
            
        # 10. 테스트 스크립트 생성
        test_results['test_scripts'] = self.create_test_scripts()
        
        # 11. Aliases 가이드 생성
        test_results['aliases'] = self.create_aliases_guide()
        
        # 결과 출력
        self.print_test_results(test_results)
        
        return test_results
    
    def print_test_results(self, results):
        """테스트 결과 출력"""
        print("\n" + "=" * 50)
        print("📊 테스트 결과 요약")
        print("=" * 50)
        
        status_map = {True: "✅", False: "❌", None: "⚠️"}
        
        test_names = {
            'system': '시스템 요구사항',
            'directories': '디렉토리 설정',
            'dependencies': '의존성 확인',
            'python_env': 'Python 환경',
            'hf_libs': 'Hugging Face 라이브러리',
            'llama_cpp': 'llama.cpp 빌드',
            'model_info': '모델 정보 확인',
            'mlx_install': 'MLX 설치',
            'mlx_test': 'MLX 테스트',
            'test_scripts': '테스트 스크립트',
            'aliases': 'Aliases 가이드'
        }
        
        success_count = 0
        total_count = len(results)
        
        for key, result in results.items():
            status = status_map.get(result, "❓")
            name = test_names.get(key, key)
            print(f"{status} {name}")
            
            if result is True:
                success_count += 1
        
        print("\n" + "=" * 50)
        print(f"📈 성공률: {success_count}/{total_count} ({success_count/total_count*100:.1f}%)")
        
        if success_count == total_count:
            print("🎉 모든 테스트 통과! 환경 설정이 완료되었습니다.")
        else:
            print("⚠️  일부 테스트 실패. 상세 로그를 확인하세요.")
            
        print("\n📝 다음 단계:")
        print("1. 실제 모델 다운로드 (용량 주의)")
        print("2. GGUF 변환 및 양자화")
        print("3. MLX 변환")
        print("4. 성능 벤치마크 실행")


def main():
    """메인 함수"""
    print("🚀 Seed-X-Instruct-7B 변환 환경 테스트")
    print("=" * 50)
    print("📋 이 스크립트는 다음을 수행합니다:")
    print("   - 시스템 요구사항 확인")
    print("   - 필요한 도구 설치 확인")
    print("   - Python 환경 설정")
    print("   - llama.cpp 빌드")
    print("   - MLX 환경 설정")
    print("   - 테스트 스크립트 생성")
    print("=" * 50)
    
    tester = SeedXModelTester()
    
    try:
        results = tester.run_comprehensive_test()
        
        # 결과에 따른 종료 코드
        if all(results.values()):
            sys.exit(0)  # 성공
        else:
            sys.exit(1)  # 실패
            
    except KeyboardInterrupt:
        print("\n⚠️  테스트가 중단되었습니다.")
        sys.exit(130)
    except Exception as e:
        print(f"\n❌ 예상치 못한 오류: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main() 