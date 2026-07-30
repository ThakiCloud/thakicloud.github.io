# Thaki Cloud Tech Blog

> Read this in another language: [한국어 README](README-ko.md)

The source for the **Thaki Cloud Tech Blog**, a bilingual (Korean and English) engineering blog covering AI/ML engineering, LLMOps, DevOps, Kubernetes, and private-cloud infrastructure.

Live site: **https://thakicloud.com/tech-blog/**

- Korean: https://thakicloud.com/tech-blog/ko/
- English: https://thakicloud.com/tech-blog/en/

Visiting the site root redirects to the language that matches the visitor's browser, with a previously chosen language taking priority.

## Tech stack

- **Static site generator**: [Jekyll](https://jekyllrb.com/) 4.x
- **Theme**: [Minimal Mistakes](https://mmistakes.github.io/minimal-mistakes/) with a custom `thaki` skin
- **Appearance**: dark-only, tuned to embed inside the dark thakicloud.com shell
- **Content**: Markdown, one post per language under `_posts/<lang>/<category>/`
- **Search**: client-side Lunr, per language
- **Hosting**: Amazon S3 behind CloudFront
- **CI/CD**: GitHub Actions (build on push to `main`, deploy to S3, invalidate CloudFront)

## Repository layout

```
_posts/ko/<category>/   Korean posts
_posts/en/<category>/   English posts
_pages/{ko,en}/         Per-language home + search pages
_config.yml             Base site config (permalinks, defaults, excludes)
_data/navigation.yml    Language switcher
_includes/ _layouts/    Theme overrides (masthead, SEO, hreflang, etc.)
assets/css/main.scss    Design tokens and dark theme
.github/workflows/      jekyll.yml is the active build-and-deploy pipeline
```

Categories in use: `agentops`, `llmops`, `dev`, `research`, `tutorials`, `owm`, `datasets`, `news`, `culture`, `careers`, and comics (`comics` in English, `만화` in Korean).

## Local development

Requires Ruby 3.2+ and Bundler.

```bash
bundle install
bundle exec jekyll serve
```

Then open:

- http://localhost:4000/tech-blog/ko/
- http://localhost:4000/tech-blog/en/

## Writing a post

Posts are Markdown with YAML front matter. Place a post under the category folder for its language:

```
_posts/ko/tutorials/2026-07-27-my-post.md
_posts/en/tutorials/2026-07-27-my-post.md
```

A Korean post is the source of record; its English sibling shares the same `slug`, `categories`, `date`, and `tags`, and only the title, excerpt, SEO fields, and body are translated. Publish state is kept in parity: an English translation is published only when its Korean sibling is published, and each language is capped at 250 published posts (older posts stay in the repo with `published: false`).

Front matter sets `lang` (`ko` or `en`) and a `canonical_url`; the build derives the permalink (`/ko/<category>/<slug>/`, `/en/<category>/<slug>/`) from the folder.

## Deployment

Pushing to `main` triggers `.github/workflows/jekyll.yml`, which builds the site with Jekyll, syncs `_site/` to S3 (with `--delete`), and invalidates the CloudFront distribution. No manual step is needed; the change is live within a few minutes.

## Language support

The blog ships in **Korean and English**. Arabic was retired in July 2026 and is no longer built, deployed, or linked.

## License

Content is © Thaki Cloud. The Minimal Mistakes theme is distributed under the MIT License.
