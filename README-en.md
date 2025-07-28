
# Thaki Cloud Technical Blog

Welcome to the official technical blog repository of Thaki Cloud! This blog is a platform for sharing our expertise, insights, and innovations in private cloud solutions (IaaS, PaaS, SaaS), LLM Ops, and AI engineering.  
Our primary goal is to engage with top-tier tech professionals and showcase exciting opportunities at Thaki Cloud.

---

## ✨ Purpose

- **Talent Acquisition**: Attract top technical talent by demonstrating our technical depth and culture.
- **Knowledge Sharing**: Share insights, tutorials, research, and news to contribute to the tech community.
- **Brand Building**: Establish Thaki Cloud as a thought leader in our domain.

---

## 🛠️ Tech Stack

- **Static Site Generator**: [Jekyll](https://jekyllrb.com/)
- **Theme**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/)
- **Content Format**: Markdown
- **Hosting**: (e.g., GitHub Pages, Netlify, Vercel – *update based on actual usage*)

---

## ✍️ How to Write a Blog Post

Follow these steps to contribute content to the Thaki Cloud tech blog:

### 1. Choose a Category

Select the most appropriate category for your post. Current categories:

- `dev` (Development & Architecture)
- `llmops` (LLM Ops & AI Engineering)
- `tutorials` (Technical Insights & Tutorials)
- `careers` (Life at Thaki Cloud & Careers)
- `reviews` (Academic Paper Reviews)
- `news` (Tech News & Trends)
- `research` (Industry Research & Analysis)
- `science` (Science & Deep Tech)
- `misc` (Miscellaneous)

Each category has its own folder under `_posts/` (e.g., `_posts/dev/`, `_posts/llmops/`).

### 2. Create a Post File

- Navigate to the appropriate `_posts/<category>/` folder.
- Create a new Markdown file: `YYYY-MM-DD-your-post-title.md`
  - Example: `2024-07-30-optimizing-inference-speed.md`

### 3. Add Front Matter

Include metadata at the top of the file:

```yaml
---
title: "Optimizing LLM Inference Speed: A Practical Guide"
categories:
  - llmops
# Optional: tags:
#   - performance
#   - llm
#   - optimization
# Optional: author override (see _config.yml)
# author: "Your Name"
# Optional: excerpt for list previews
# excerpt: "Learn key techniques to dramatically improve LLM inference performance..."
---
```

### 4. Write Your Content

Write your content below the front matter using Markdown.  
Example:

```markdown
## Introduction

Welcome to our practical guide on optimizing LLM inference speed...

### Key Techniques

1. **Quantization**: ...
2. **Pruning**: ...
```

Use all standard Markdown features: headings, lists, code blocks, images, etc.

### 5. Add Images (Optional)

- Place images in a new folder under `assets/images/posts/` (e.g., `assets/images/posts/optimizing-inference-speed/`)
- Link images in Markdown:
  ```markdown
  ![Alt Text](/assets/images/posts/optimizing-inference-speed/image-name.png)
  ```

### 6. Preview Locally

If you have Jekyll set up locally:

```bash
bundle exec jekyll serve
```

Visit [http://localhost:4000](http://localhost:4000) to preview your post.

### 7. Publish the Post

Once satisfied:

1. Commit the new post (and images)
2. Push to the `main` branch on GitHub

The blog will auto-rebuild and publish via the configured hosting platform (e.g., GitHub Pages or CI/CD).

---

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
