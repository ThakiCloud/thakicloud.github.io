# 🧱 파일 및 폴더 구조 설명

(폴더 및 주요 파일의 구조와 목적을 설명하세요.)

# Blog Architecture Overview

This document outlines the technical architecture of the Thaki Cloud recruitment blog, which is built upon the Jekyll static site generator and the "Minimal Mistakes" theme.

## Core Components:

*   **Jekyll Core:** The fundamental static site generation engine. It processes Markdown files, Liquid templates, and data files to produce a complete, static HTML website.
    *   **Key Configuration:** `_config.yml` (handles site-wide settings, navigation, author details, social links, and build parameters).
    *   **Ruby Environment:** Managed by `Gemfile` and `Gemfile.lock`, ensuring consistent Ruby gem dependencies (including Jekyll and its plugins) across development and deployment environments.

*   **Minimal Mistakes Theme:** Provides the foundational UI, layouts, and features.
    *   **Layouts (`_layouts/`):** Defines the HTML structure for different types of content (e.g., `default`, `home`, `posts`, `page`, `category`, `tag-archive`). These layouts typically include common elements like headers, footers, and navigation.
    *   **Includes (`_includes/`):** Contains reusable HTML snippets for UI components such as author profiles (`author-profile.html`), navigation bars, comments sections, and social sharing buttons. These are invoked within layouts and posts using Liquid tags.
    *   **Sass Styling (`_sass/`):** The theme's styling is implemented using Sass, allowing for modular and customizable CSS. Key files here define variables, mixins, and styles for theme components.
    *   **Assets (`assets/`):** Stores static assets like images, fonts, and compiled CSS/JavaScript. Custom branding assets (logos, favicons) and post-specific images should be managed here.

## Content Management & Structure:

*   **Blog Posts (`_posts/`):**
    *   The primary content resides here as Markdown files (`.md`).
    *   **Filename Convention:** `YYYY-MM-DD-title.md` is standard for Jekyll posts.
    *   **Directory Structure:** Organized into subdirectories representing distinct content categories (e.g., `iaas`, `paas`, `saas`, `llmops`, `tutorials`, `careers`, `reviews`, `news`, `research`, `misc`, `science`). This aids in content organization and can be leveraged for category-specific pages or navigation.
    *   **Front Matter:** Each post begins with YAML front matter, defining metadata like `title`, `excerpt`, `date`, `categories`, `tags`, `author_profile`, etc. This metadata is crucial for how Jekyll processes and displays content.
    *   **Placeholder Guides:** Each category subdirectory contains a placeholder guide (e.g., `_posts/iaas/placeholder-iaas-guide.md`) to assist authors in creating content aligned with Thaki Cloud's recruitment goals and technical focus.

*   **Static Pages (`_pages/`):** For content that isn't part of the chronological blog feed, such as an "About Thaki Cloud" or "Join Our Team" page. These also use Markdown and front matter.

*   **Data Files (`_data/`):**
    *   Stores structured data (YAML, JSON, CSV) used site-wide.
    *   Examples: Navigation links (`navigation.yml`), UI text strings, author details if not managed solely in `_config.yml`. This allows for separation of content/configuration from presentation.

## Build & Deployment Process (Typical Jekyll Flow):

1.  **Local Development:**
    *   Developers write posts in Markdown, modify theme files, or update configurations.
    *   Jekyll's development server (`bundle exec jekyll serve`) compiles the site in memory and serves it locally, allowing for live previews and iteration.

2.  **Build:**
    *   Running `bundle exec jekyll build` processes all content, applies layouts and includes, and generates the static HTML site into the `_site/` directory (by default).

3.  **Deployment:**
    *   The contents of the `_site/` directory are deployed to a web server or a static hosting service (e.g., GitHub Pages, Netlify, AWS S3).
    *   For this project, GitHub Pages is the likely deployment target, often configured to build and deploy automatically on pushes to a specific branch.

## Key Technologies & Concepts:

*   **Markdown:** Lightweight markup language for content creation.
*   **Liquid:** Templating language used by Jekyll to inject dynamic content and logic into HTML.
*   **Ruby & Bundler:** Core platform and dependency management for Jekyll.
*   **Sass/SCSS:** CSS preprocessor for advanced and maintainable stylesheets.
*   **Git & GitHub:** Version control and (likely) hosting/CI/CD via GitHub Actions.
*   **Static Site Generation:** Benefits include speed, security, and simple hosting.

## Customization Points for Thaki Cloud:

*   **Branding:** `_config.yml` (site title, URL, logo), `assets/` (images, favicon), `_sass/` (colors, fonts).
*   **Content Strategy:** `_posts/` structure and placeholder guides.
*   **Author Profiles:** `_config.yml` (default author), `_includes/author-profile.html`, and front matter in posts.
*   **Navigation:** `_data/navigation.yml` or directly in `_includes/` theme files.
*   **SEO:** `_config.yml` (metadata), `robots.txt`, `sitemap.xml`, and front matter in posts/pages.
*   **Recruitment Focus:** Tailoring content in all categories, especially "Thaki Cloud Life & Careers," and ensuring clear calls-to-action for potential applicants.
