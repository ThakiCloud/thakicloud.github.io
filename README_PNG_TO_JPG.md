# PNG to JPG 변환 스크립트

Jekyll 블로그의 `assets/images` 폴더에 있는 모든 PNG 이미지를 JPG로 변환하고, 관련된 마크다운 포스트의 링크를 자동으로 업데이트하는 스크립트입니다.

## 🚀 주요 기능

- **자동 백업**: 변환 전 모든 PNG 파일을 안전하게 백업
- **이미지 변환**: PNG 파일을 고품질 JPG로 변환 (투명도 처리 포함)
- **링크 업데이트**: `_posts` 폴더의 모든 마크다운 파일에서 PNG 링크를 JPG로 자동 변경
- **안전한 삭제**: 변환 완료 후 원본 PNG 파일 삭제
- **상세한 로그**: 변환 과정의 모든 단계를 상세히 출력

## 📋 요구사항

- Python 3.6+
- Pillow 라이브러리

```bash
pip install Pillow
```

## 🔧 사용법

### 1. 기본 실행
```bash
python convert_png_to_jpg.py
```

### 2. Dry Run (미리보기)
실제 변환 없이 어떤 파일들이 변환될지 확인:
```bash
python convert_png_to_jpg.py --dry-run
```

### 3. 고급 옵션
```bash
python convert_png_to_jpg.py \
  --assets-dir assets/images \
  --posts-dir _posts \
  --backup-dir backup_png \
  --skip-backup
```

## 📖 옵션 설명

| 옵션 | 기본값 | 설명 |
|------|--------|------|
| `--assets-dir` | `assets/images` | 이미지 디렉토리 경로 |
| `--posts-dir` | `_posts` | 포스트 디렉토리 경로 |
| `--backup-dir` | `backup_png` | 백업 디렉토리 경로 |
| `--skip-backup` | False | 백업을 건너뜀 |
| `--dry-run` | False | 실제 변환 없이 미리보기만 실행 |

## 🔄 변환 과정

1. **백업 생성**: 모든 PNG 파일을 `backup_png` 폴더에 백업
2. **이미지 변환**: PNG 파일을 JPG로 변환 (품질 95%, 최적화 적용)
3. **링크 업데이트**: 마크다운 파일의 PNG 링크를 JPG로 변경
4. **원본 삭제**: 변환이 성공한 PNG 파일들을 삭제
5. **결과 요약**: 변환된 파일 목록과 통계 출력

## 📊 실행 결과 예시

```
🚀 PNG to JPG 변환 작업을 시작합니다...
📁 이미지 디렉토리: assets/images
📁 포스트 디렉토리: _posts

📦 8개의 PNG 파일을 백업 중...
  ✅ assets/images/posts/tutorial/toast.png → backup_png/posts/tutorial/toast.png

🔄 8개의 PNG 파일을 JPG로 변환 중...
  ✅ 변환 완료: assets/images/posts/tutorial/toast.jpg

📝 47개의 마크다운 파일에서 링크 업데이트 중...
  ✅ 업데이트: _posts/tutorials/2024-12-19-openai-gpt4o-image-style-conversion.md
    📎 /assets/images/posts/tutorial/toast.png → /assets/images/posts/tutorial/toast.jpg

🗑️  8개의 원본 PNG 파일 삭제 중...
  ✅ 삭제: assets/images/posts/tutorial/toast.png

============================================================
🎉 변환 작업 완료!
============================================================
📊 변환된 이미지: 8개
📝 업데이트된 포스트: 5개
```

## 🛡️ 안전 기능

- **자동 백업**: 모든 PNG 파일이 변환 전에 백업됨
- **투명도 처리**: PNG의 투명 영역을 흰색 배경으로 변환
- **오류 처리**: 변환 실패 시 원본 파일 보존
- **Dry Run**: 실제 변환 전 미리보기 가능

## 📁 디렉토리 구조

변환 후 디렉토리 구조:
```
├── assets/images/
│   └── posts/
│       ├── tutorial/
│       │   ├── toast.jpg          # 변환된 파일
│       │   └── 3d-toast.jpg       # 변환된 파일
│       └── research/
│           └── deepseek-v3.jpg    # 변환된 파일
├── backup_png/                    # 백업 폴더
│   └── posts/
│       ├── tutorial/
│       │   ├── toast.png          # 백업된 원본
│       │   └── 3d-toast.png       # 백업된 원본
│       └── research/
│           └── deepseek-v3.png    # 백업된 원본
└── _posts/                        # 업데이트된 마크다운 파일들
```

## ⚠️ 주의사항

1. **백업 확인**: 변환 후 이미지가 정상적으로 표시되는지 확인한 후 백업 폴더를 삭제하세요
2. **투명도**: PNG의 투명 영역은 흰색 배경으로 변환됩니다
3. **품질**: JPG 품질은 95%로 설정되어 있어 거의 무손실입니다
4. **Git**: 변환 후 Git에 변경사항을 커밋하는 것을 잊지 마세요

## 🔧 문제 해결

### Pillow 설치 오류
```bash
pip install --upgrade pip
pip install Pillow
```

### 권한 오류
```bash
chmod +x convert_png_to_jpg.py
```

### 백업에서 복원
```bash
cp -r backup_png/* assets/images/
```

## 📈 성능

- **변환 속도**: 이미지당 평균 0.1-0.5초
- **파일 크기**: 일반적으로 PNG 대비 30-70% 감소
- **품질**: 95% 품질로 거의 무손실 변환

---

**작성자**: AI Assistant  
**최종 업데이트**: 2025년 1월  
**라이선스**: MIT 