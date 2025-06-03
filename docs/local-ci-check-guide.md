# GitHub Actions CI 사전 로컬 체크 가이드

이 문서는 GitHub Actions의 `.github/workflows/ci.yml` 파이프라인과 유사하게, **로컬 환경에서 미리 점검할 수 있는 체크리스트와 명령어**를 안내합니다. PR 제출 전 아래 항목을 점검하면 CI 실패를 줄이고, 빠른 리뷰와 배포가 가능합니다.

---

## 1. Ruby & Node.js 환경 준비

- Ruby (권장: 3.2 이상)
- Node.js (권장: 18.x)
- Bundler, npm, Python3, pip

### 설치 예시 (macOS)
```sh
brew install ruby node python3
# Ruby 버전 확인
yarn --version
ruby -v
node -v
python3 --version
```

---

## 2. 의존성 설치

### Ruby Gem & Bundler
```sh
gem install bundler
bundle install
```

### Node.js 패키지
```sh
npm install -g markdownlint-cli html-validate broken-link-checker @lhci/cli
```

### Python 패키지
```sh
pip install detect-secrets
```

---

## 3. Jekyll Doctor & Build

### Jekyll Doctor (설정 점검)
```sh
bundle exec jekyll doctor
```

### Jekyll Build (프로덕션 빌드)
```sh
JEKYLL_ENV=production bundle exec jekyll build --verbose --trace
```
- 빌드 결과는 `_site/` 폴더에 생성됩니다.

---

## 4. 마크다운 문법 검사 (Markdown Lint)

```sh
markdownlint '_posts/**/*.md' '_pages/**/*.md' 'README.md' --config .markdownlint.json
```
- `.markdownlint.json`이 없다면 워크플로우의 설정을 참고해 생성하세요.

---

## 5. HTML 유효성 검사 & 내부 링크 체크

### HTML Validate
```sh
find _site -name "*.html" -exec html-validate {} \;
```

### 내부 링크 체크 (broken-link-checker)
```sh
cd _site
python3 -m http.server 8080 &
SERVER_PID=$!
sleep 5
blc http://localhost:8080 --recursive --filter-level 3 --exclude-external --requests 10 --max-sockets 10
kill $SERVER_PID
cd ..
```

---

## 6. 시큐리티 & 시크릿 검사

### Trivy (로컬 폴더 취약점 검사)
- [Trivy 설치 가이드](https://aquasecurity.github.io/trivy/v0.18.3/installation/)
```sh
trivy fs .
```

### detect-secrets (시크릿 키 노출 검사)
```sh
detect-secrets scan > .secrets.baseline
```

---

## 7. Lighthouse 퍼포먼스 점검

```sh
lhci collect --staticDistDir=_site
```
- 또는
```sh
lhci autorun
```
- `lighthouserc.json` 설정이 필요할 수 있습니다.

---

## 8. 배포 시뮬레이션 체크

```sh
# 필수 파일 존재 여부 확인
for file in index.html search.json sitemap.xml; do
  if [ -f "_site/$file" ]; then
    echo "✅ $file exists"
  else
    echo "❌ $file missing"; exit 1
  fi
done
# 통계
find _site -type f | wc -l
find _site -name "*.html" | wc -l
du -sh _site
```

---

## 9. 체크리스트 요약

- [ ] Ruby, Node, Python 환경 및 버전 확인
- [ ] `bundle install`, `npm install`, `pip install` 완료
- [ ] Jekyll doctor/build 성공
- [ ] 마크다운 문법 오류 없음
- [ ] HTML 유효성 및 내부 링크 오류 없음
- [ ] Trivy, detect-secrets로 보안 점검 완료
- [ ] Lighthouse 퍼포먼스 점검
- [ ] `_site/` 내 필수 파일 존재 및 통계 확인

---

## 참고
- CI와 완전히 동일한 환경은 아닐 수 있으니, 의존성 버전/설정 차이에 주의하세요.
- 추가적인 워크플로우 스크립트나 설정이 있다면 그에 맞게 커맨드를 보완하세요.

---

이 가이드를 따라 로컬에서 미리 점검하면, GitHub Actions CI 실패를 크게 줄일 수 있습니다. 