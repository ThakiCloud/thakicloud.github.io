
# 🌍 Thaki Cloud Multilingual Technical Blog

> 🇰🇷 [한국어 README](README.md) | 🇸🇦 [العربية README](README-ar.md)

Welcome to the official multilingual technical blog repository of Thaki Cloud! This blog is served in **Korean, English, and Arabic**, providing a platform for sharing our expertise, insights, and innovations in private cloud solutions (IaaS, PaaS, SaaS), LLM Ops, and AI engineering with readers worldwide.

---

## ✨ Purpose

- **Global Talent Acquisition**: Attract top technical talent worldwide through multilingual content.
- **Knowledge Sharing**: Share insights, tutorials, research, and news in multiple languages to contribute to the global tech community.
- **Brand Building**: Establish Thaki Cloud as an international technology leader.
- **Cultural Accessibility**: Enable all users to access technical knowledge without language barriers.

---

## 🛠️ Tech Stack

- **Static Site Generator**: [Jekyll](https://jekyllrb.com/)
- **Theme**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)
- **Content Format**: Markdown
- **Multilingual Support**: Korean, English, Arabic (automatic browser language detection)
- **Hosting**: GitHub Pages
- **CI/CD**: GitHub Actions (automated multilingual builds)
- **Local Testing**: act (local GitHub Actions execution)

## 🌐 Website Access Guide

### Automatic Language Detection
When you visit [**thakicloud.github.io**](https://thakicloud.github.io), you'll be automatically redirected to the appropriate language page based on your browser language settings:

- **Korean Browser** → `/ko/` (Korean blog)
- **English Browser** → `/en/` (English blog)  
- **Arabic Browser** → `/ar/` (Arabic blog)

### Direct Language Selection
You can also access your preferred language directly:

- 🇰🇷 **한국어**: [thakicloud.github.io/ko/](https://thakicloud.github.io/ko/)
- 🇺🇸 **English**: [thakicloud.github.io/en/](https://thakicloud.github.io/en/)
- 🇸🇦 **العربية**: [thakicloud.github.io/ar/](https://thakicloud.github.io/ar/)

### Language Switching
You can freely switch languages using the navigation menu at the top of each page. Your selected language is saved in cookies and remembered for future visits.

---

## ✍️ How to Write Multilingual Blog Posts

This guide explains how to contribute content to the Thaki Cloud multilingual technical blog. All posts are written in **Korean, English, and Arabic**.

### 1. Automatic Multilingual Post Generation

Use the multilingual post generation script to create templates for all 3 languages at once:

```bash
# Usage: new-multilingual-post <title-slug> <category>
~/scripts/new-multilingual-post.sh "ai-tutorial-guide" "tutorials"
```

### 2. Choose a Category

Current supported categories:

- `agentops` (AI Agent Development and Operations)
- `careers` (Career and Growth)
- `culture` (Development Team Culture and Methodology)
- `datasets` (Data Analysis and Processing)
- `dev` (Programming and Development Tips)
- `devops` (Development Operations and Infrastructure)
- `llmops` (Large Language Model Operations)
- `news` (Latest Technology Trends)
- `owm` (Open Workflow Management)
- `research` (Technical Research and Paper Reviews)
- `tutorials` (Hands-on Guides)

Each language has its own directory structure:
- Korean: `_posts/ko/<category>/`
- English: `_posts/en/<category>/`
- Arabic: `_posts/ar/<category>/`

### 3. Language-specific Content Creation

After running the script, the following 3 files will be generated:

```
_posts/ko/tutorials/2025-01-28-ai-tutorial-guide.md  (Korean)
_posts/en/tutorials/2025-01-28-ai-tutorial-guide.md  (English)
_posts/ar/tutorials/2025-01-28-ai-tutorial-guide.md  (Arabic)
```

Write or translate each file in the respective language.

### 4. Front Matter Structure

The generated templates include multilingual-optimized front matter:

**Korean Example:**
```yaml
---
title: "AI 튜토리얼 가이드"
excerpt: "AI 기술의 기초부터 고급까지 다루는 완전 가이드"
seo_title: "AI 튜토리얼 완전 가이드 - Thaki Cloud"
seo_description: "AI 기술을 처음부터 배우고 싶은 개발자를 위한 단계별 튜토리얼"
date: 2025-01-28
lang: ko
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/ko/tutorials/ai-tutorial-guide/"
---
```

**English Example:**
```yaml
---
title: "Complete AI Tutorial Guide"
excerpt: "Comprehensive guide covering AI technology from basics to advanced"
seo_title: "Complete AI Tutorial Guide - Thaki Cloud"
seo_description: "Step-by-step tutorial for developers who want to learn AI technology from scratch"
date: 2025-01-28
lang: en
categories:
  - tutorials
tags:
  - ai
  - tutorial
  - guide
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/en/tutorials/ai-tutorial-guide/"
---
```

### 5. Content Writing Guide

Write content for each language considering the respective audience:

**Korean Content:**
```markdown
⏱️ **예상 읽기 시간**: 15분

## 서론

AI 기술이 급속도로 발전하면서...

## 주요 내용

### 1. 기초 개념
- 머신러닝의 기본 원리
- 딥러닝과의 차이점

### 2. 실습 예제
```python
import tensorflow as tf
# 한국어 주석으로 설명
```

## 결론
```

**English Content:**
```markdown
⏱️ **Estimated reading time**: 15 min read

## Introduction

As AI technology rapidly evolves...

## Main Content

### 1. Fundamental Concepts
- Basic principles of machine learning
- Differences from deep learning

### 2. Practical Examples
```python
import tensorflow as tf
# Explanations in English comments
```

## Conclusion
```

### 6. Adding Images and Media

Images can be organized by language:

```
assets/images/posts/
├── ko/ai-tutorial-guide/
│   ├── diagram-ko.png
│   └── screenshot-ko.png
├── en/ai-tutorial-guide/
│   ├── diagram-en.png
│   └── screenshot-en.png
└── ar/ai-tutorial-guide/
    ├── diagram-ar.png
    └── screenshot-ar.png
```

Link in Markdown:
```markdown
![AI Diagram](/assets/images/posts/en/ai-tutorial-guide/diagram-en.png)
```

### 7. Multilingual Build and Preview

#### Individual Language Preview:
```bash
# Korean site (port 4000)
bundle exec jekyll serve --config _config.yml,_config-ko.yml --port 4000

# English site (port 4001)  
bundle exec jekyll serve --config _config.yml,_config-en.yml --port 4001

# Arabic site (port 4002)
bundle exec jekyll serve --config _config.yml,_config-ar.yml --port 4002
```

#### Integrated Multilingual Build:
```bash
# Build complete multilingual site
./scripts/build-multilingual.sh

# Preview built site
cd _site && python3 -m http.server 4000
```

Access URLs:
- Korean: http://localhost:4000/ko/
- English: http://localhost:4000/en/
- Arabic: http://localhost:4000/ar/

### 8. Publishing Posts

#### Local Testing:
```bash
# CI/CD testing (using act)
act -j build -W .github/workflows/multilingual-deploy.yml --container-architecture linux/amd64

# Or run test script
~/scripts/test-multilingual-ci.sh
```

#### Deploy to GitHub:
```bash
# Commit all language files
git add _posts/ko/ _posts/en/ _posts/ar/
git commit -m "feat: Add multilingual AI tutorial guide"
git push origin main
```

GitHub Actions automatically builds and deploys the multilingual site:
1. Build Korean, English, and Arabic separately
2. Generate integrated site
3. Deploy to GitHub Pages

---

## 🎯 Multilingual Blog Management Commands

Useful commands for convenience:

```bash
# Check blog status
echo "📊 Multilingual Blog Status:"
echo "🇰🇷 Korean Posts: $(find _posts/ko -name '*.md' | wc -l)"
echo "🇺🇸 English Posts: $(find _posts/en -name '*.md' | wc -l)"  
echo "🇸🇦 Arabic Posts: $(find _posts/ar -name '*.md' | wc -l)"

# Navigate to language directories
cd _posts/ko/    # Korean posts
cd _posts/en/    # English posts  
cd _posts/ar/    # Arabic posts
```

---

That's it! We look forward to your contributions to the Thaki Cloud multilingual technical blog. If you have questions, please contact the project manager.

## 📝 Contribution & Local Dev Guide

This repo powers the Thaki Cloud blog and docs via Jekyll. Below is the guide to writing, testing, and submitting changes.

---

### 1. Local Development Workflow

```bash
git checkout main
git pull origin main
git checkout -b docs/update-local-ci-guide
```

Write your post or documentation in `_posts/`, `_pages/`, or `docs/`.

```bash
git add docs/local-ci-check-guide.md
git commit -m "docs: Add local CI check guide"
git push origin docs/update-local-ci-guide
```

Then open a Pull Request (PR) on GitHub and request review.

---

### 2. Local Pre-CI Checklist

> For full details, see `docs/local-ci-check-guide.md`

#### Required Environment

- Ruby 3.2+, Node.js 18+, Python3
- Bundler, npm, pip

#### Checks to Run

1. Dependency installation:
   ```bash
   bundle install
   npm install
   pip install -r requirements.txt
   ```
2. Jekyll build checks:
   ```bash
   bundle exec jekyll doctor
   JEKYLL_ENV=production bundle exec jekyll build --verbose --trace
   ```
3. Markdown linting:
   ```bash
   markdownlint '_posts/**/*.md'
   ```
4. HTML and link validation:
   ```bash
   html-validate .
   broken-link-checker http://localhost:4000
   ```
5. Security checks:
   ```bash
   trivy fs .
   detect-secrets scan
   ```
6. Performance (Lighthouse):
   ```bash
   lhci autorun
   ```

---

## ✅ CI Pre-Deployment Checklist

- [ ] Confirm Ruby, Node, Python version
- [ ] Dependencies installed
- [ ] `jekyll build` runs successfully
- [ ] Markdown/HTML/link checks pass
- [ ] No security issues
- [ ] Lighthouse audit passes
- [ ] `_site/` looks production-ready

---

## 🧠 Final Notes

- CI environment may differ slightly from local
- Adjust commands if you're using a custom CI/CD pipeline
- For more, see `docs/local-ci-check-guide.md`
