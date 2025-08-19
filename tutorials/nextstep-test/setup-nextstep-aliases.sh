#!/bin/bash
# NextStep-1 테스트용 편의 alias 및 함수 설정
# 작성일: 2025-08-19

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔧 NextStep-1 편의 명령어 설정 중...${NC}"

# 기본 환경 관리
alias nextstep-env="conda activate nextstep && echo '✅ NextStep-1 환경 활성화됨'"
alias nextstep-deenv="conda deactivate && echo '✅ NextStep-1 환경 비활성화됨'"

# 디렉토리 이동
alias nextstep-dir="cd ~/work/thakicloud/thakicloud.github.io/tutorials/nextstep-test && echo '📁 NextStep-1 테스트 디렉토리로 이동'"
alias nextstep-model="cd ~/work/thakicloud/thakicloud.github.io/tutorials/nextstep-test/NextStep-1-Large-Pretrain 2>/dev/null || echo '⚠️ 모델 디렉토리가 없습니다. 먼저 설치를 진행하세요.'"

# 테스트 및 실행
alias nextstep-test="nextstep-model && python test_nextstep.py"
alias nextstep-quick="nextstep-model && python -c \"
import torch
print('PyTorch:', torch.__version__)
print('CUDA Available:', torch.cuda.is_available())
if torch.cuda.is_available():
    print('CUDA Device:', torch.cuda.get_device_name(0))
elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
    print('MPS Available: True')
else:
    print('CPU Only Mode')
\""

# 시스템 모니터링
alias nextstep-gpu="if command -v nvidia-smi &> /dev/null; then watch -n 1 nvidia-smi; else echo '⚠️ NVIDIA GPU가 없습니다'; fi"
alias nextstep-mem="echo '💾 메모리 사용량:' && ps aux | grep -E 'python.*nextstep|python.*NextStep' | grep -v grep || echo '실행 중인 NextStep 프로세스가 없습니다'"
alias nextstep-disk="echo '💿 디스크 사용량:' && du -sh ~/work/thakicloud/thakicloud.github.io/tutorials/nextstep-test/* 2>/dev/null || echo '테스트 디렉토리가 없습니다'"

# 로그 및 출력 관리
alias nextstep-log="nextstep-model && tail -f nextstep_generation.log 2>/dev/null || echo '⚠️ 로그 파일이 없습니다'"
alias nextstep-outputs="nextstep-model && ls -la *.jpg *.png 2>/dev/null || echo '생성된 이미지가 없습니다'"

# 설정 및 정보
alias nextstep-info="echo -e \"
${BLUE}🤖 NextStep-1 정보${NC}
모델: StepFun NextStep-1 (14B + 157M)
아키텍처: Autoregressive + Flow Matching
토큰 타입: Discrete Text + Continuous Image

${GREEN}📋 사용 가능한 명령어:${NC}
nextstep-env       : 환경 활성화
nextstep-dir       : 테스트 디렉토리 이동  
nextstep-test      : 기본 테스트 실행
nextstep-quick     : 빠른 환경 점검
nextstep-gpu       : GPU 모니터링
nextstep-mem       : 메모리 사용량 확인
nextstep-outputs   : 생성된 이미지 목록
nextstep-clean     : 임시 파일 정리
\""

# 정리 및 유지보수
alias nextstep-clean="nextstep-model && echo '🧹 임시 파일 정리 중...' && rm -f *.log __pycache__/* .pytest_cache/* 2>/dev/null && echo '✅ 정리 완료'"

# 고급 함수들
nextstep-generate() {
    local prompt="$1"
    local size="${2:-512}"
    local steps="${3:-28}"
    
    if [ -z "$prompt" ]; then
        echo -e "${RED}❌ 사용법: nextstep-generate \"프롬프트\" [크기] [단계수]${NC}"
        echo "예시: nextstep-generate \"A beautiful sunset over mountains\" 1024 35"
        return 1
    fi
    
    nextstep-model
    
    cat > quick_generate.py << EOF
import torch
from transformers import AutoTokenizer, AutoModel
from datetime import datetime
import sys

try:
    from models.gen_pipeline import NextStepPipeline
    
    print("🤖 모델 로딩 중...")
    tokenizer = AutoTokenizer.from_pretrained(".", local_files_only=True, trust_remote_code=True)
    model = AutoModel.from_pretrained(".", local_files_only=True, trust_remote_code=True)
    
    pipeline = NextStepPipeline(tokenizer=tokenizer, model=model)
    device = "cuda" if torch.cuda.is_available() else ("mps" if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available() else "cpu")
    pipeline = pipeline.to(device=device, dtype=torch.bfloat16)
    
    print(f"🎨 이미지 생성 중... (디바이스: {device})")
    print(f"프롬프트: ${prompt}")
    
    image = pipeline.generate_image(
        "${prompt}",
        hw=(${size}, ${size}),
        num_images_per_caption=1,
        positive_prompt="masterpiece, best quality, highly detailed",
        negative_prompt="lowres, bad quality, blurry, artifacts",
        cfg=7.5,
        num_sampling_steps=${steps},
        seed=None
    )[0]
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    filename = f"nextstep_generated_{timestamp}.jpg"
    image.save(filename)
    
    print(f"✅ 이미지 생성 완료: {filename}")
    print(f"크기: {image.size}")
    
except Exception as e:
    print(f"❌ 생성 실패: {e}")
    sys.exit(1)
EOF
    
    python quick_generate.py
    rm quick_generate.py
}

nextstep-batch() {
    local config_file="$1"
    
    if [ -z "$config_file" ] || [ ! -f "$config_file" ]; then
        echo -e "${RED}❌ 설정 파일이 필요합니다.${NC}"
        echo "예시 설정 파일 생성:"
        
        cat > batch_config.json << 'EOF'
{
    "prompts": [
        "A serene mountain landscape at sunset",
        "Modern architecture with glass and steel",
        "Abstract art with flowing colors",
        "Peaceful garden with cherry blossoms"
    ],
    "settings": {
        "size": 1024,
        "steps": 28,
        "guidance": 7.5,
        "quality": "premium"
    }
}
EOF
        echo "✅ batch_config.json 생성됨"
        echo "사용법: nextstep-batch batch_config.json"
        return 1
    fi
    
    nextstep-model
    
    cat > batch_generate.py << 'EOF'
import json
import torch
from transformers import AutoTokenizer, AutoModel
from datetime import datetime
import sys

config_file = sys.argv[1] if len(sys.argv) > 1 else "batch_config.json"

try:
    with open(config_file, 'r') as f:
        config = json.load(f)
    
    prompts = config['prompts']
    settings = config['settings']
    
    print(f"🤖 배치 생성 시작 - {len(prompts)}개 이미지")
    
    from models.gen_pipeline import NextStepPipeline
    
    tokenizer = AutoTokenizer.from_pretrained(".", local_files_only=True, trust_remote_code=True)
    model = AutoModel.from_pretrained(".", local_files_only=True, trust_remote_code=True)
    
    pipeline = NextStepPipeline(tokenizer=tokenizer, model=model)
    device = "cuda" if torch.cuda.is_available() else ("mps" if hasattr(torch.backends, 'mps') and torch.backends.mps.is_available() else "cpu")
    pipeline = pipeline.to(device=device, dtype=torch.bfloat16)
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    for i, prompt in enumerate(prompts):
        print(f"🎨 {i+1}/{len(prompts)}: {prompt[:50]}...")
        
        image = pipeline.generate_image(
            prompt,
            hw=(settings['size'], settings['size']),
            num_images_per_caption=1,
            positive_prompt="masterpiece, best quality, highly detailed",
            negative_prompt="lowres, bad quality, blurry",
            cfg=settings['guidance'],
            num_sampling_steps=settings['steps'],
            seed=None
        )[0]
        
        filename = f"batch_{timestamp}_{i+1:03d}.jpg"
        image.save(filename)
        print(f"✅ 저장: {filename}")
        
        # 메모리 정리
        if torch.cuda.is_available():
            torch.cuda.empty_cache()
    
    print(f"🎉 배치 생성 완료! {len(prompts)}개 이미지 생성됨")
    
except Exception as e:
    print(f"❌ 배치 생성 실패: {e}")
    sys.exit(1)
EOF
    
    python batch_generate.py "$config_file"
    rm batch_generate.py
}

nextstep-status() {
    echo -e "${BLUE}📊 NextStep-1 시스템 상태${NC}"
    echo ""
    
    # Conda 환경 확인
    if conda env list | grep -q "nextstep.*\*"; then
        echo -e "${GREEN}✅ Conda 환경: nextstep (활성화됨)${NC}"
    else
        echo -e "${YELLOW}⚠️ Conda 환경: nextstep (비활성화됨)${NC}"
    fi
    
    # 모델 디렉토리 확인
    if [ -d "NextStep-1-Large-Pretrain" ]; then
        echo -e "${GREEN}✅ 모델 디렉토리: 존재함${NC}"
        
        # VAE 모델 확인
        if [ -f "NextStep-1-Large-Pretrain/vae/checkpoint.pt" ]; then
            echo -e "${GREEN}✅ VAE 모델: 설치됨${NC}"
        else
            echo -e "${RED}❌ VAE 모델: 누락됨${NC}"
        fi
    else
        echo -e "${RED}❌ 모델 디렉토리: 없음${NC}"
    fi
    
    # PyTorch 및 디바이스 상태
    if python -c "import torch; print('PyTorch OK')" 2>/dev/null; then
        echo -e "${GREEN}✅ PyTorch: 사용 가능${NC}"
        
        # GPU 상태 확인
        if python -c "import torch; print('CUDA:', torch.cuda.is_available())" 2>/dev/null | grep -q "True"; then
            echo -e "${GREEN}✅ CUDA GPU: 사용 가능${NC}"
        elif python -c "import torch; print('MPS:', hasattr(torch.backends, 'mps') and torch.backends.mps.is_available())" 2>/dev/null | grep -q "True"; then
            echo -e "${GREEN}✅ Apple MPS: 사용 가능${NC}"
        else
            echo -e "${YELLOW}⚠️ GPU: CPU 전용 모드${NC}"
        fi
    else
        echo -e "${RED}❌ PyTorch: 설치되지 않음${NC}"
    fi
    
    # 디스크 사용량
    if [ -d "NextStep-1-Large-Pretrain" ]; then
        local disk_usage=$(du -sh NextStep-1-Large-Pretrain 2>/dev/null | cut -f1)
        echo -e "${BLUE}💿 디스크 사용량: ${disk_usage}${NC}"
    fi
    
    # 생성된 이미지 개수
    local image_count=$(ls NextStep-1-Large-Pretrain/*.jpg NextStep-1-Large-Pretrain/*.png 2>/dev/null | wc -l)
    echo -e "${BLUE}🖼️  생성된 이미지: ${image_count}개${NC}"
}

# 자동 완성 설정
if command -v complete &> /dev/null; then
    complete -W "quick test info status clean" nextstep-
fi

echo -e "${GREEN}✅ NextStep-1 편의 명령어 설정 완료${NC}"
echo ""
echo -e "${BLUE}🚀 주요 명령어:${NC}"
echo "  nextstep-info                          : 명령어 도움말"
echo "  nextstep-env                           : 환경 활성화"
echo "  nextstep-test                          : 기본 테스트"
echo "  nextstep-generate \"프롬프트\" [크기] [단계]  : 빠른 이미지 생성"
echo "  nextstep-status                        : 시스템 상태 확인"
echo ""
echo -e "${YELLOW}💡 팁: 'nextstep-info' 명령으로 전체 도움말을 확인하세요${NC}"
