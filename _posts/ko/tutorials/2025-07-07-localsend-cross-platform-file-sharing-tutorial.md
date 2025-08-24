---
title: "LocalSend 완전 가이드 - 크로스플랫폼 파일 공유의 모든 것"
excerpt: "AirDrop의 오픈소스 대안 LocalSend로 모든 플랫폼에서 안전하게 파일을 공유하는 방법을 알아보세요. 설치부터 고급 설정까지 완벽 가이드입니다."
seo_title: "LocalSend 튜토리얼 - 크로스플랫폼 파일 공유 완전 가이드 - Thaki Cloud"
seo_description: "LocalSend 오픈소스 파일 공유 앱 설치부터 사용법까지 완벽 가이드. macOS, Windows, Linux, Android, iOS 모든 플랫폼 지원. AirDrop 대안 솔루션."
date: 2025-07-07
last_modified_at: 2025-07-07
categories:
  - tutorials
tags:
  - localsend
  - file-sharing
  - cross-platform
  - macos
  - windows
  - linux
  - android
  - ios
  - airdrop
  - flutter
  - privacy
  - security
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/localsend-cross-platform-file-sharing-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 서론

**LocalSend**는 로컬 네트워크를 통해 안전하게 파일과 메시지를 공유할 수 있는 오픈소스 크로스플랫폼 앱입니다. Apple의 AirDrop과 유사한 기능을 제공하지만, 모든 플랫폼에서 사용 가능하며 인터넷 연결이 필요 없습니다.

이 가이드에서는 LocalSend의 설치부터 고급 사용법까지 실습 중심으로 설명하며, macOS 환경에서 실제로 테스트 가능한 스크립트를 제공합니다.

## LocalSend 특징

### 핵심 기능

- **크로스플랫폼 지원**: Windows, macOS, Linux, Android, iOS
- **로컬 네트워크**: 인터넷 연결 없이 동일 네트워크에서 작동
- **보안**: REST API와 HTTPS 암호화 사용
- **오픈소스**: Apache 2.0 라이선스
- **빠른 속도**: 로컬 네트워크 기반으로 빠른 파일 전송

### 지원 플랫폼 및 요구사항

| 플랫폼 | 최소 버전 | 비고 |
|--------|-----------|------|
| Android | 5.0 | - |
| iOS | 12.0 | - |
| macOS | 11 Big Sur | OpenCore Legacy Patcher 2.0.2 사용 가능 |
| Windows | 10 | Windows 7 지원은 v1.15.4까지 |
| Linux | N.A. | - |

## 설치 가이드

### macOS 설치

#### Homebrew 설치 (권장)

```bash
# Homebrew가 없다면 먼저 설치
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# LocalSend 설치
brew install --cask localsend
```

#### 직접 다운로드

[LocalSend GitHub 릴리즈 페이지](https://github.com/localsend/localsend/releases/latest)에서 최신 DMG 파일을 다운로드하여 설치할 수 있습니다.

### Windows 설치

```powershell
# Chocolatey 설치
choco install localsend

# 또는 Scoop 사용
scoop install localsend
```

### Linux 설치

```bash
# Snap으로 설치
sudo snap install localsend

# 또는 AppImage 다운로드
wget https://github.com/localsend/localsend/releases/latest/download/LocalSend-*-linux-x86_64.AppImage
chmod +x LocalSend-*-linux-x86_64.AppImage
./LocalSend-*-linux-x86_64.AppImage
```

### Android/iOS 설치

- **Android**: [Google Play Store](https://play.google.com/store/apps/details?id=org.localsend.localsend_app) 또는 [F-Droid](https://f-droid.org/packages/org.localsend.localsend_app)
- **iOS**: [App Store](https://apps.apple.com/us/app/localsend/id1661733229)

## 초기 설정

### 네트워크 설정

LocalSend가 제대로 작동하려면 방화벽 설정이 필요할 수 있습니다:

| 트래픽 유형 | 프로토콜 | 포트 | 액션 |
|-------------|----------|------|------|
| 수신 | TCP, UDP | 53317 | 허용 |
| 송신 | TCP, UDP | 모든 포트 | 허용 |

### macOS 방화벽 설정

```bash
# 방화벽 상태 확인
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate

# LocalSend 앱 허용
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/LocalSend.app
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock /Applications/LocalSend.app
```

### 라우터 설정

**AP 격리 비활성화**가 중요합니다. 대부분의 라우터에서 기본적으로 비활성화되어 있지만, 일부 라우터(특히 게스트 네트워크)에서는 활성화되어 있을 수 있습니다.

## 기본 사용법

### 첫 번째 파일 전송

#### 1. 앱 실행 및 설정

```bash
# macOS에서 LocalSend 실행
open -a LocalSend

# 또는 터미널에서 백그라운드 실행
open -a LocalSend --hide
```

#### 2. 장치 이름 설정

1. LocalSend 앱 실행
2. 설정(⚙️) 클릭
3. 장치 이름 변경 (예: "MacBook Pro", "iPhone 15")

#### 3. 파일 전송 과정

**보내는 쪽:**
1. "+" 버튼 클릭
2. 파일 선택 또는 드래그 앤 드롭
3. 수신 장치 선택
4. "전송" 버튼 클릭

**받는 쪽:**
1. 전송 요청 알림 확인
2. "수락" 버튼 클릭
3. 파일 저장 위치 선택

### 실습 테스트 스크립트

```bash
#!/bin/bash
# LocalSend 테스트 스크립트

echo "=== LocalSend 설치 및 테스트 스크립트 ==="

# 1. 설치 확인
echo "1. LocalSend 설치 확인..."
if [ -d "/Applications/LocalSend.app" ]; then
    echo "✅ LocalSend가 설치되어 있습니다."
else
    echo "❌ LocalSend가 설치되어 있지 않습니다."
    echo "Homebrew로 설치하시겠습니까? (y/n)"
    read -r answer
    if [ "$answer" = "y" ]; then
        brew install --cask localsend
    else
        echo "수동으로 설치하세요: https://github.com/localsend/localsend/releases/latest"
        exit 1
    fi
fi

# 2. 네트워크 연결 확인
echo "2. 네트워크 연결 확인..."
if ping -c 1 google.com &> /dev/null; then
    echo "✅ 인터넷 연결이 활성화되어 있습니다."
else
    echo "⚠️ 인터넷 연결이 없습니다. (LocalSend는 로컬 네트워크만 사용)"
fi

# 3. 로컬 네트워크 정보 확인
echo "3. 로컬 네트워크 정보 확인..."
LOCAL_IP=$(ipconfig getifaddr en0)
if [ -n "$LOCAL_IP" ]; then
    echo "✅ 로컬 IP: $LOCAL_IP"
else
    echo "❌ 로컬 네트워크에 연결되어 있지 않습니다."
fi

# 4. 포트 53317 확인
echo "4. LocalSend 포트 확인..."
if lsof -i :53317 &> /dev/null; then
    echo "✅ 포트 53317이 사용 중입니다 (LocalSend 실행 중)"
else
    echo "ℹ️ 포트 53317이 사용되지 않습니다 (LocalSend 실행 안됨)"
fi

# 5. 테스트 파일 생성
echo "5. 테스트 파일 생성..."
TEST_DIR="$HOME/Desktop/LocalSend_Test"
mkdir -p "$TEST_DIR"
echo "LocalSend 테스트 파일 - $(date)" > "$TEST_DIR/test_file.txt"
echo "Hello, LocalSend!" > "$TEST_DIR/hello.txt"
echo "✅ 테스트 파일이 생성되었습니다: $TEST_DIR"

# 6. LocalSend 실행
echo "6. LocalSend 실행..."
open -a LocalSend
sleep 2

echo "=== 테스트 완료 ==="
echo "다음 단계:"
echo "1. 다른 장치에서도 LocalSend 설치"
echo "2. 두 장치가 같은 WiFi 네트워크에 연결되어 있는지 확인"
echo "3. $TEST_DIR 폴더의 파일을 다른 장치로 전송 테스트"
echo "4. 파일 전송이 완료되면 'rm -rf $TEST_DIR' 명령으로 테스트 폴더 삭제"
```

### 스크립트 실행 방법

```bash
# 스크립트 파일 생성
cat > ~/localsend_test.sh << 'EOF'
[위의 스크립트 내용 복사]
EOF

# 실행 권한 부여
chmod +x ~/localsend_test.sh

# 스크립트 실행
~/localsend_test.sh
```

## 고급 사용법

### 휴대용 모드 (Portable Mode)

v1.13.0부터 지원되는 휴대용 모드는 앱과 같은 디렉토리에 `settings.json` 파일을 생성하여 설정을 해당 파일에 저장합니다.

```bash
# macOS에서 휴대용 모드 설정
cd /Applications/LocalSend.app/Contents/MacOS
echo '{}' > settings.json
```

### 숨겨진 시작 (Hidden Start)

```bash
# 시스템 트레이에만 표시되도록 시작
/Applications/LocalSend.app/Contents/MacOS/LocalSend --hidden
```

### 자동 시작 설정

```bash
# macOS에서 자동 시작 설정
osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/LocalSend.app", hidden:false}'
```

## 성능 최적화

### 전송 속도 향상

1. **5GHz WiFi 사용**: 2.4GHz보다 빠른 전송 속도
2. **암호화 비활성화**: 보안이 중요하지 않은 경우 (설정에서 변경 가능)
3. **가까운 거리**: 장치 간 거리가 가까울수록 빠른 전송

### 네트워크 최적화

```bash
# macOS 네트워크 최적화 스크립트
#!/bin/bash

echo "=== 네트워크 최적화 스크립트 ==="

# 현재 WiFi 정보 확인
WIFI_INFO=$(networksetup -getairportnetwork en0)
echo "현재 WiFi: $WIFI_INFO"

# 5GHz 네트워크 확인
if [[ $WIFI_INFO == *"5G"* ]] || [[ $WIFI_INFO == *"5g"* ]]; then
    echo "✅ 5GHz 네트워크에 연결되어 있습니다."
else
    echo "⚠️ 5GHz 네트워크 사용을 권장합니다."
fi

# 네트워크 속도 테스트
echo "네트워크 속도 테스트 중..."
ping -c 5 8.8.8.8 | tail -1 | awk '{print $4}' | cut -d'/' -f2
```

## 문제 해결

### 일반적인 문제 및 해결방법

#### 1. 장치가 보이지 않는 경우

**모든 플랫폼:**
- 라우터의 AP 격리 설정 확인 및 비활성화
- 같은 WiFi 네트워크에 연결되어 있는지 확인

**Windows:**
- 네트워크를 "개인" 네트워크로 설정

**macOS/iOS:**
- 설정 > 개인정보 보호 > 로컬 네트워크에서 LocalSend 권한 허용

#### 2. 전송 속도가 느린 경우

```bash
# 네트워크 진단 스크립트
#!/bin/bash

echo "=== 네트워크 진단 스크립트 ==="

# WiFi 신호 강도 확인
WIFI_SIGNAL=$(networksetup -getairportnetwork en0)
echo "WiFi 신호: $WIFI_SIGNAL"

# 대역폭 확인
echo "대역폭 테스트 중..."
curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -

# 로컬 네트워크 지연 시간 확인
LOCAL_GATEWAY=$(route -n get default | grep gateway | awk '{print $2}')
echo "게이트웨이 핑 테스트: $LOCAL_GATEWAY"
ping -c 5 "$LOCAL_GATEWAY"
```

#### 3. Android 전송 속도 문제

Android에서 전송 속도가 느린 것은 알려진 문제입니다. 이는 Flutter의 SAF(Storage Access Framework) 스트림 관련 이슈입니다.

**해결 방법:**
- 작은 파일부터 테스트
- 가능하면 Android에서 받기보다는 보내기 우선

### 고급 문제 해결

#### 방화벽 설정 확인

```bash
# macOS 방화벽 설정 확인 및 수정
#!/bin/bash

echo "=== 방화벽 설정 확인 ==="

# 방화벽 상태 확인
FIREWALL_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getglobalstate)
echo "방화벽 상태: $FIREWALL_STATUS"

# LocalSend 앱 상태 확인
LOCALSEND_STATUS=$(sudo /usr/libexec/ApplicationFirewall/socketfilterfw --getappblocked /Applications/LocalSend.app)
echo "LocalSend 차단 상태: $LOCALSEND_STATUS"

# LocalSend 허용 설정
echo "LocalSend 방화벽 허용 설정 중..."
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --add /Applications/LocalSend.app
sudo /usr/libexec/ApplicationFirewall/socketfilterfw --unblock /Applications/LocalSend.app

echo "✅ 방화벽 설정이 완료되었습니다."
```

#### 포트 충돌 해결

```bash
# 포트 53317 사용 프로세스 확인
lsof -i :53317

# 포트 사용 중인 프로세스 종료 (필요시)
sudo kill -9 $(lsof -t -i :53317)
```

## 개발자 정보

### 소스 코드 빌드

LocalSend는 Flutter로 개발되었으며, 소스 코드에서 직접 빌드할 수 있습니다.

```bash
# 개발 환경 설정
git clone https://github.com/localsend/localsend.git
cd localsend

# Flutter 설치 (fvm 사용 권장)
dart pub global activate fvm
fvm install

# 의존성 설치
cd app
fvm flutter pub get

# 앱 실행
fvm flutter run
```

### 기여하기

LocalSend는 오픈소스 프로젝트로, 다음 방법으로 기여할 수 있습니다:

1. **번역**: [Weblate 플랫폼](https://hosted.weblate.org/projects/localsend/)을 통한 번역
2. **버그 리포트**: [GitHub 이슈](https://github.com/localsend/localsend/issues)
3. **기능 개선**: Pull Request 제출

## 보안 고려사항

### 암호화 및 보안

LocalSend는 다음과 같은 보안 기능을 제공합니다:

- **TLS/SSL 암호화**: 모든 데이터 전송 시 암호화
- **동적 인증서**: 각 장치에서 실시간 인증서 생성
- **로컬 네트워크 한정**: 인터넷을 통하지 않는 전송

### 보안 모범 사례

```bash
# 보안 설정 확인 스크립트
#!/bin/bash

echo "=== LocalSend 보안 설정 확인 ==="

# 현재 네트워크 확인
CURRENT_NETWORK=$(networksetup -getairportnetwork en0)
echo "현재 네트워크: $CURRENT_NETWORK"

# 게스트 네트워크 경고
if [[ $CURRENT_NETWORK == *"Guest"* ]] || [[ $CURRENT_NETWORK == *"guest"* ]]; then
    echo "⚠️ 게스트 네트워크에 연결되어 있습니다."
    echo "보안을 위해 개인 네트워크 사용을 권장합니다."
fi

# 공용 네트워크 경고
if [[ $CURRENT_NETWORK == *"Public"* ]] || [[ $CURRENT_NETWORK == *"public"* ]]; then
    echo "⚠️ 공용 네트워크에 연결되어 있습니다."
    echo "민감한 파일 전송을 피하세요."
fi

echo "✅ 보안 설정 확인이 완료되었습니다."
```

## 사용 시나리오

### 비즈니스 환경

```bash
# 회사 환경 설정 스크립트
#!/bin/bash

echo "=== 비즈니스 환경 LocalSend 설정 ==="

# 회사 네트워크 설정 확인
echo "회사 네트워크 환경에서 LocalSend 사용 시 주의사항:"
echo "1. IT 부서의 네트워크 정책 확인"
echo "2. 방화벽 설정 승인 필요"
echo "3. 민감한 데이터 전송 시 추가 보안 조치"

# 배치 전송을 위한 폴더 생성
BUSINESS_DIR="$HOME/Desktop/LocalSend_Business"
mkdir -p "$BUSINESS_DIR"/{incoming,outgoing,archive}

echo "✅ 비즈니스 폴더 구조 생성:"
echo "- 수신: $BUSINESS_DIR/incoming"
echo "- 송신: $BUSINESS_DIR/outgoing"
echo "- 보관: $BUSINESS_DIR/archive"
```

### 개인 사용

```bash
# 개인 사용 최적화 스크립트
#!/bin/bash

echo "=== 개인 사용 LocalSend 최적화 ==="

# 자주 사용하는 폴더 생성
PERSONAL_DIR="$HOME/Documents/LocalSend_Personal"
mkdir -p "$PERSONAL_DIR"/{photos,documents,music,videos}

echo "✅ 개인 폴더 구조 생성:"
echo "- 사진: $PERSONAL_DIR/photos"
echo "- 문서: $PERSONAL_DIR/documents"
echo "- 음악: $PERSONAL_DIR/music"
echo "- 비디오: $PERSONAL_DIR/videos"

# 바탕화면 바로가기 생성
ln -sf "$PERSONAL_DIR" "$HOME/Desktop/LocalSend_Personal"
echo "✅ 바탕화면 바로가기 생성됨"
```

## 대안 도구 비교

### LocalSend vs 다른 파일 공유 도구

| 기능 | LocalSend | AirDrop | Nearby Share | SHAREit |
|------|-----------|---------|--------------|---------|
| 크로스플랫폼 | ✅ | ❌ (Apple만) | ❌ (Android만) | ✅ |
| 오픈소스 | ✅ | ❌ | ❌ | ❌ |
| 인터넷 불필요 | ✅ | ✅ | ✅ | ❌ |
| 암호화 | ✅ | ✅ | ✅ | ❌ |
| 무료 | ✅ | ✅ | ✅ | ❌ (광고) |

## 자주 묻는 질문 (FAQ)

### Q1: LocalSend를 사용하기 위해 계정 생성이 필요한가요?

**A:** 아니요. LocalSend는 계정 생성이 필요 없으며, 로컬 네트워크에서 직접 장치 간 연결됩니다.

### Q2: 파일 크기 제한이 있나요?

**A:** 이론적으로 파일 크기 제한은 없지만, 매우 큰 파일의 경우 네트워크 성능에 따라 전송 시간이 오래 걸릴 수 있습니다.

### Q3: 전송 중 연결이 끊어지면 어떻게 되나요?

**A:** 전송이 중단되며, 부분 전송된 파일은 삭제됩니다. 전송을 다시 시작해야 합니다.

## 결론

LocalSend는 크로스플랫폼 파일 공유의 강력한 솔루션입니다. 오픈소스이면서도 높은 보안성을 제공하며, 인터넷 연결 없이도 빠른 파일 전송이 가능합니다.

특히 다음과 같은 경우에 LocalSend를 강력히 추천합니다:

1. **다양한 플랫폼 사용**: iPhone, Android, Windows, macOS, Linux를 혼용하는 환경
2. **보안 중시**: 클라우드 서비스 없이 직접 전송이 필요한 경우
3. **빠른 전송**: 로컬 네트워크의 고속 전송이 필요한 경우
4. **오픈소스 선호**: 투명한 소스 코드와 커뮤니티 지원을 원하는 경우

### 다음 단계

1. **모든 장치에 설치**: 사용하는 모든 장치에 LocalSend 설치
2. **네트워크 최적화**: 5GHz WiFi 사용 및 방화벽 설정
3. **워크플로우 구축**: 정기적인 파일 백업 및 동기화 루틴 생성
4. **보안 정책 수립**: 민감한 데이터 처리 방법 정의

LocalSend를 통해 더 효율적이고 안전한 파일 공유 환경을 구축하세요!

### 추가 자료

- [LocalSend 공식 웹사이트](https://localsend.org)
- [GitHub 저장소](https://github.com/localsend/localsend)
- [Discord 커뮤니티](https://discord.gg/GSRWmQNP87)
- [번역 기여](https://hosted.weblate.org/projects/localsend/)

---

*이 튜토리얼은 LocalSend v1.17.0을 기준으로 작성되었습니다. 최신 버전에서는 일부 기능이 변경될 수 있습니다.* 