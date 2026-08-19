source "https://rubygems.org"

gem "jekyll", "~> 4.3"
# ⚠️ 이 gem 은 빌드에 쓰이지 않는다 (2026-08-19 확인). _config.yml 의 `theme:` 와
# `remote_theme:` 이 둘 다 주석 처리돼 있고, 테마 전체가 벤더링돼 있다
# (_sass/minimal-mistakes/, _layouts/, _includes/, assets/). 즉 jekyll 은 이
# gem 을 로드할 경로가 없다.
# 남겨 둔 이유는 **업스트림 대조**뿐이다 — 벤더 사본이 상류에서 얼마나 갈라졌는지
# 볼 수 있는 로컬 기준선. 대가는 dependabot 이 안 쓰는 gem 의 버전 범프 PR 을
# 계속 연다는 것이다(Gemfile 커밋 3건 중 2건이 그 범프).
# 지우려면 Gemfile.lock 도 같이 재생성해야 하고, 그 검증은 CI 빌드에서만 가능하다
# (이 맥은 rubygems egress 가 막혀 있어 bundle install 로 못 재현한다).
gem "minimal-mistakes-jekyll", "~> 4.28"
gem "faraday-retry", "~> 2.3"
gem 'tzinfo'
gem "tzinfo-data", platforms: [:mingw, :mswin, :x64_mingw, :jruby]

group :jekyll_plugins do
  gem "jekyll-seo-tag"
  gem "jekyll-paginate"
  gem "jekyll-sitemap"
  gem "jekyll-gist"
  gem "jekyll-feed"
  gem "jekyll-include-cache"
end
