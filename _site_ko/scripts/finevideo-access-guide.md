# FineVideo 데이터셋 접근 권한 요청 가이드

## 📋 개요

FineVideo는 HuggingFace에서 제공하는 gated dataset으로, 사용하기 위해서는 별도의 접근 권한이 필요합니다. 이 가이드는 접근 권한을 요청하고 승인받는 과정을 설명합니다.

## 🔐 접근 권한 요청 과정

### 1단계: HuggingFace 계정 확인

```bash
# 현재 로그인된 계정 확인
huggingface-cli whoami
```

### 2단계: FineVideo 데이터셋 페이지 방문

브라우저에서 다음 URL로 이동하세요:
```
https://huggingface.co/datasets/HuggingFaceFV/finevideo
```

### 3단계: 약관 동의 및 접근 요청

1. **"Access repository" 버튼 클릭**
2. **Terms of Use 읽기**:
   - FineVideo는 43,000개 이상의 YouTube 비디오 컬렉션
   - Creative Commons 라이선스 준수 필요
   - 연구 목적으로만 사용 가능
   - 데이터 제거 요청 정책 준수

3. **필수 조건 동의**:
   ```
   ✅ Terms of Use 동의
   ✅ 연락처 정보 공유 동의
   ✅ 최신 버전 업데이트 동의
   ```

### 4단계: 승인 대기

- **승인 시간**: 일반적으로 1-3일 소요
- **알림 방법**: 등록된 이메일로 승인 알림 발송
- **상태 확인**: 데이터셋 페이지에서 접근 상태 확인 가능

## 📧 승인 후 확인 방법

### 접근 권한 테스트

```python
from datasets import load_dataset

try:
    # 스트리밍 방식으로 데이터셋 로드 테스트
    dataset = load_dataset(
        "HuggingFaceFV/finevideo", 
        split="train", 
        streaming=True
    )
    
    # 첫 번째 샘플 확인
    sample = next(iter(dataset))
    print("✅ FineVideo 접근 성공!")
    print(f"샘플 키: {list(sample.keys())}")
    
except Exception as e:
    print(f"❌ 접근 실패: {e}")
```

### 환경 변수 설정 (선택사항)

```bash
# HuggingFace 토큰을 환경 변수로 설정
export HUGGINGFACE_HUB_TOKEN="your_token_here"

# 또는 .env 파일에 저장
echo "HUGGINGFACE_HUB_TOKEN=your_token_here" >> .env
```

## 🚨 일반적인 문제 해결

### 문제 1: "Dataset is gated" 오류

```
Dataset 'HuggingFaceFV/finevideo' is a gated dataset on the Hub.
```

**해결책**:
1. 데이터셋 페이지에서 접근 권한 요청
2. 승인 이메일 대기
3. 브라우저에서 재로그인 후 확인

### 문제 2: 토큰 인증 오류

```
You are not authenticated. Please login using `huggingface-cli login`
```

**해결책**:
```bash
# HuggingFace 재로그인
huggingface-cli login

# 토큰 입력 (write 권한 필요)
# https://huggingface.co/settings/tokens 에서 토큰 생성
```

### 문제 3: 네트워크 연결 오류

**해결책**:
```bash
# 캐시 초기화
rm -rf ~/.cache/huggingface/

# DNS 확인
nslookup huggingface.co

# 방화벽/VPN 설정 확인
```

## 📊 데이터셋 사용 예제

### 기본 사용법

```python
from datasets import load_dataset
import json

# 데이터셋 로드
dataset = load_dataset("HuggingFaceFV/finevideo", split="train", streaming=True)

# 샘플 데이터 확인
for i, sample in enumerate(dataset):
    if i >= 3:  # 3개 샘플만 확인
        break
    
    # 메타데이터 파싱
    metadata = json.loads(sample['json'])
    
    print(f"=== 샘플 {i+1} ===")
    print(f"제목: {metadata.get('youtube_title', 'N/A')}")
    print(f"길이: {metadata.get('duration_seconds', 0)}초")
    print(f"해상도: {metadata.get('resolution', 'N/A')}")
    print(f"카테고리: {metadata.get('content_parent_category', 'N/A')}")
    print()
```

### 필터링된 데이터 로드

```python
def filter_by_category(dataset, target_category="Education", max_samples=100):
    """특정 카테고리의 샘플만 필터링"""
    filtered_samples = []
    
    for sample in dataset:
        if len(filtered_samples) >= max_samples:
            break
            
        try:
            metadata = json.loads(sample['json'])
            category = metadata.get('content_parent_category', '')
            
            if category == target_category:
                filtered_samples.append(sample)
                print(f"필터링된 샘플: {len(filtered_samples)}/{max_samples}")
                
        except Exception as e:
            print(f"샘플 처리 오류: {e}")
            continue
    
    return filtered_samples

# 교육 카테고리 데이터만 로드
education_samples = filter_by_category(dataset, "Education", 50)
```

## 📝 사용 시 주의사항

### 1. 라이선스 준수

- Creative Commons 라이선스 조건 준수
- 원본 출처 표기 필수
- 상업적 사용 제한 확인

### 2. 데이터 관리

- 정기적인 데이터셋 업데이트 확인
- 제거 요청된 비디오 확인
- 백업 및 버전 관리

### 3. 윤리적 사용

- 연구 목적으로만 사용
- 개인정보 보호 준수
- 해로운 콘텐츠 필터링

## 🔗 유용한 링크

- [FineVideo 데이터셋 페이지](https://huggingface.co/datasets/HuggingFaceFV/finevideo)
- [FineVideo 논문](https://huggingface.co/papers/2409.12290)
- [HuggingFace 토큰 생성](https://huggingface.co/settings/tokens)
- [Datasets 라이브러리 문서](https://huggingface.co/docs/datasets/)

## 💬 지원 및 문의

접근 권한 관련 문제가 지속되는 경우:

1. **HuggingFace 커뮤니티**: 데이터셋 페이지의 Discussions 탭 활용
2. **이메일 문의**: FineVideo 팀에 직접 연락
3. **GitHub Issues**: 관련 기술적 이슈 보고

---

**참고**: 이 가이드는 2025년 7월 기준으로 작성되었으며, HuggingFace 정책 변경에 따라 절차가 달라질 수 있습니다. 