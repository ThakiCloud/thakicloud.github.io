# 호스트러너 연결 끊김 문제 해결 가이드

## 🚨 문제 증상
```
The self-hosted runner lost communication with the server. 
Verify the machine is running and has a healthy network connection. 
Anything in your workflow that terminates the runner process, 
starves it for CPU/Memory, or blocks its network access can cause this error.
```

**상황**: 빌드는 정상적으로 완료되었지만, 시간이 너무 오래 걸려서 runner와 GitHub 서버의 연결이 끊김

## 🎯 근본 원인

### 1. 리소스 부족
**현재 호스트러너 사양**:
- CPU: 1.6 코어
- 메모리: 4GB

**실제 워크로드**:
- 포스트 수: 1,032개 (ko: 666, en: 186, ar: 180)
- Jekyll 빌드: 메모리 집약적 작업
- Native gem 컴파일: CPU 집약적 작업

### 2. Heartbeat 타임아웃
- GitHub Actions runner는 주기적으로 서버에 heartbeat 전송
- CPU/메모리 부족 시 runner 프로세스가 응답 불가
- 일정 시간 응답 없으면 연결 끊김 처리

### 3. 빌드 시간
- 리소스 부족 환경에서 대규모 빌드는 10분+ 소요 가능
- Runner heartbeat가 제때 전송되지 않음

---

## ✅ 해결 방법 (권장 순서)

### 방법 1: GitHub-hosted Runner 사용 (가장 안정적) ⭐

**장점**:
- ✅ 안정적인 빌드 (CPU 2코어, 메모리 7GB)
- ✅ 빠른 빌드 속도 (5-8분)
- ✅ 연결 끊김 없음
- ✅ 유지보수 불필요

**단점**:
- ⚠️ 무료 제한: 월 2,000분 (public repo는 무료)
- ⚠️ 호스트러너보다 느릴 수 있음 (하지만 안정적)

**적용 방법**:
```bash
# 현재 jekyll.yml 백업
cp .github/workflows/jekyll.yml .github/workflows/jekyll-self-hosted-backup.yml

# GitHub-hosted runner로 전환
cp .github/workflows/jekyll-backup-ubuntu.yml.disabled .github/workflows/jekyll.yml

# 커밋 및 푸시
git add .github/workflows/
git commit -m "fix: GitHub-hosted runner로 전환 (연결 안정성)"
git push
```

**Public Repository의 경우**: 무료 무제한 사용 가능! 💰

---

### 방법 2: 호스트러너 리소스 증가 (권장)

**최소 권장 사양**:
```yaml
CPU: 2 코어 이상
메모리: 8GB 이상
디스크: 20GB 이상 SSD
```

**호스트러너 설정 변경 방법**:

#### 클라우드 플랫폼별 가이드

##### AWS EC2
```bash
# 현재 인스턴스 타입 확인
aws ec2 describe-instances --instance-ids <INSTANCE_ID>

# 인스턴스 중지
aws ec2 stop-instances --instance-ids <INSTANCE_ID>

# 인스턴스 타입 변경 (예: t3.medium)
aws ec2 modify-instance-attribute \
  --instance-id <INSTANCE_ID> \
  --instance-type "{\"Value\": \"t3.medium\"}"

# 인스턴스 재시작
aws ec2 start-instances --instance-ids <INSTANCE_ID>
```

**추천 인스턴스**:
- `t3.medium`: 2 vCPU, 4GB RAM (최소)
- `t3.large`: 2 vCPU, 8GB RAM (권장)

##### Azure Virtual Machines
```bash
# VM 크기 변경
az vm resize \
  --resource-group <RESOURCE_GROUP> \
  --name <VM_NAME> \
  --size Standard_B2s
```

**추천 크기**:
- `Standard_B2s`: 2 vCPU, 4GB RAM (최소)
- `Standard_B2ms`: 2 vCPU, 8GB RAM (권장)

##### Google Cloud Platform
```bash
# 인스턴스 중지
gcloud compute instances stop <INSTANCE_NAME>

# 머신 타입 변경
gcloud compute instances set-machine-type <INSTANCE_NAME> \
  --machine-type e2-medium

# 인스턴스 시작
gcloud compute instances start <INSTANCE_NAME>
```

**추천 머신 타입**:
- `e2-medium`: 2 vCPU, 4GB RAM (최소)
- `e2-standard-2`: 2 vCPU, 8GB RAM (권장)

##### Docker Container
```bash
# docker-compose.yml 수정
services:
  github-runner:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 8G
        reservations:
          cpus: '1.0'
          memory: 4G
```

##### 로컬 머신
- 시스템 설정에서 VM 또는 Container 리소스 제한 증가

---

### 방법 3: Runner Heartbeat 간격 조정

**호스트러너 설정 파일 수정**:
```bash
# Runner 디렉토리로 이동
cd /path/to/runner

# .env 파일 생성 또는 수정
cat > .env << 'EOF'
# Heartbeat 간격 증가 (초 단위, 기본값: 60)
RUNNER_HEARTBEAT_INTERVAL=120

# Job 완료 대기 시간 증가 (초 단위, 기본값: 30)
RUNNER_JOB_COMPLETION_TIMEOUT=300
EOF

# Runner 재시작
sudo ./svc.sh stop
sudo ./svc.sh start
```

⚠️ **주의**: 이 방법은 임시 해결책이며, 근본적인 리소스 부족 문제는 해결하지 못합니다.

---

### 방법 4: 빌드 최적화 (이미 적용됨)

✅ **현재 워크플로우에 적용된 최적화**:
- 빌드 도구 캐싱 (이미 설치된 경우 스킵)
- Jekyll 빌드 타임아웃 60분 설정
- 빌드 시간 측정 및 로깅
- Symlink 정리 자동화

**추가 최적화 가능한 옵션**:

#### 옵션 A: Jekyll 증분 빌드 (experimental)
```yaml
- name: Build with Jekyll
  run: bundle exec jekyll build --incremental
```
⚠️ 주의: 증분 빌드는 때때로 오래된 파일을 남길 수 있음

#### 옵션 B: 병렬 빌드 (Jekyll 4.x)
```yaml
env:
  JEKYLL_ENV: production
  JEKYLL_BUILD_PARALLEL: true
```

#### 옵션 C: 불필요한 플러그인 비활성화
`_config.yml`에서 사용하지 않는 플러그인 제거

---

## 📊 빌드 시간 비교 (예상)

| 환경 | CPU | 메모리 | 예상 빌드 시간 |
|------|-----|--------|---------------|
| 호스트러너 (현재) | 1.6 | 4GB | 10-15분 ⚠️ |
| 호스트러너 (권장) | 2.0 | 8GB | 5-8분 ✅ |
| GitHub-hosted | 2.0 | 7GB | 5-8분 ✅ |
| 호스트러너 (고사양) | 4.0 | 16GB | 3-5분 🚀 |

---

## 🔍 문제 진단 체크리스트

### 호스트러너에서 실행할 명령어

```bash
# 1. 현재 리소스 사용량 확인
echo "=== CPU 정보 ==="
nproc
cat /proc/cpuinfo | grep "model name" | head -1

echo -e "\n=== 메모리 정보 ==="
free -h

echo -e "\n=== 디스크 정보 ==="
df -h

# 2. 실시간 리소스 모니터링 (빌드 중 실행)
top -b -n 1 | head -20

# 3. Runner 로그 확인
tail -f /path/to/runner/_diag/Runner_*.log
```

### 예상 출력 분석

**메모리 부족 신호**:
```
Mem:   3.9Gi  3.8Gi  100Mi  # 메모리 거의 다 사용
Swap:  2.0Gi  1.9Gi  100Mi  # Swap도 거의 다 사용
```

**CPU 과부하 신호**:
```
%Cpu(s): 95.0 us,  5.0 sy  # CPU 사용률 95%+
load average: 3.50, 2.80, 2.10  # 1분 평균 부하가 CPU 코어 수보다 높음
```

---

## 🚀 즉시 적용 가능한 해결책

### 빠른 해결 (5분 소요)
```bash
# GitHub-hosted runner로 전환
cd /Users/hanhyojung/thaki/thakicloud.github.io
cp .github/workflows/jekyll-backup-ubuntu.yml.disabled .github/workflows/jekyll.yml
git add .github/workflows/jekyll.yml
git commit -m "fix: 호스트러너 연결 문제로 GitHub-hosted runner로 전환"
git push
```

### 중기 해결 (호스트러너 리소스 증가)
1. 클라우드 플랫폼 콘솔 접속
2. Runner VM 인스턴스 선택
3. 중지 → 인스턴스 타입 변경 → 시작
4. 소요 시간: 5-10분

### 장기 해결 (하이브리드 전략)
- **빌드**: GitHub-hosted runner (안정성)
- **배포**: Self-hosted runner (특정 네트워크 요구사항)
- **비용 효율적이면서 안정적**

---

## 💡 최종 추천

### Public Repository의 경우 (현재 상황)
✅ **GitHub-hosted runner 사용 강력 추천**
- 무료 무제한
- 안정적
- 연결 끊김 없음
- 유지보수 불필요

### Private Repository의 경우
✅ **호스트러너 리소스 증가 권장**
- 비용: 월 $10-20 (클라우드 기준)
- CPU 2코어, 메모리 8GB로 업그레이드

---

## 📞 추가 도움

문제가 계속되면:
1. GitHub Actions 로그 전체 다운로드
2. 호스트러너 로그 확인: `_diag/Runner_*.log`
3. 시스템 리소스 모니터링 결과 공유

---

## 🎓 참고 자료

- [GitHub Actions Runner 공식 문서](https://docs.github.com/en/actions/hosting-your-own-runners)
- [Runner 하드웨어 요구사항](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#requirements-for-self-hosted-runner-machines)
- [GitHub Actions 무료 사용량](https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions)

