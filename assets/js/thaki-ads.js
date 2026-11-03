/*
 * Tech Blog sidebar ads — picks one product ad for a post from its categories and tags.
 * Spec: marketing's "Tech Blog 사이드바 제품 광고 운영 규칙 및 태그 매핑" (Notion, 2026-10-27).
 * The rule tables below are that document's sections 3–5; adjust them here when marketing
 * revises the mapping. Tests: node scripts/test_thaki_ads.js
 *
 * Priority: 1) explicit product tag  2) category candidates ∩ topic tags
 *           3) category candidates   4) the general ad.
 * Tags match exactly after normalising, so `paxis` never matches `paxis-neo`.
 */
(function () {
  'use strict';

  var ADS = {
    paxis: {
      ko: { href: 'https://thakicloud.com/paxis', alt: 'Paxis: 기업용 AI 에이전트, 자체 인프라에서 운영하세요. 사내 시스템, 내부 지식, 업무 워크플로를 연결하는 엔터프라이즈 AI 에이전트 플랫폼. Paxis 자세히 보기' },
      en: { href: 'https://thakicloud.com/en/paxis', alt: 'Paxis: Your AI Agents. Your Infrastructure. Build agent workflows around your systems, permissions, and policies. Explore Paxis' }
    },
    'paxis-neo': {
      ko: { href: 'https://thakicloud.com/paxis-neo', alt: 'Paxis Neo: 기업용 AI 에이전트, 플랫폼 구축 없이. SaaS로 에이전트 워크플로를 설계하고 관리하세요. Paxis Neo 알아보기' },
      en: { href: 'https://thakicloud.com/en/paxis-neo', alt: 'Paxis Neo: Enterprise AI Agents. No Platform to Deploy. Design and manage agent workflows through SaaS. Explore Paxis Neo' }
    },
    metis: {
      ko: { href: 'https://thakicloud.com/metis', alt: 'Metis: 학습한 AI 모델, 이제 서비스로. 모델 배포와 추론 엔드포인트 운영을 연결하세요. Metis 알아보기' },
      en: { href: 'https://thakicloud.com/en/metis', alt: 'Metis: From Trained Model to Live Inference. Deploy models and operate inference endpoints for your applications. Explore Metis' }
    },
    maxis: {
      ko: { href: 'https://thakicloud.com/maxis', alt: 'Maxis: AI 모델 학습, 실행부터 결과 관리까지. 학습·파인튜닝 작업을 구성하고 실행 현황을 관리하세요. Maxis 알아보기' },
      en: { href: 'https://thakicloud.com/en/maxis', alt: 'Maxis: Train Models. Manage Every Run. Configure and monitor training and fine-tuning workloads. Explore Maxis' }
    },
    capsis: {
      ko: { href: 'https://thakicloud.com/capsis', alt: 'Capsis: 쿠버네티스 운영, AI 워크로드에 맞게. 클러스터와 컨테이너 자원을 한곳에서 관리하세요. Capsis 알아보기' },
      en: { href: 'https://thakicloud.com/en/capsis', alt: 'Capsis: Kubernetes Operations for AI Workloads. Manage clusters and container resources in one environment. Explore Capsis' }
    },
    general: {
      ko: { href: 'https://thakicloud.com/', alt: 'Thaki Cloud: AI 인프라, GPU 그 이상. GPU 클라우드 서비스부터 기업용 AI 플랫폼까지. Thaki Cloud 살펴보기' },
      en: { href: 'https://thakicloud.com/en', alt: 'Thaki Cloud: AI Infrastructure. Beyond Compute. Explore GPU cloud services and enterprise AI platforms. Explore Thaki Cloud' }
    }
  };

  // Section 4. Products without their own ad yet (aegis, signum, …) fall through to general.
  var PRODUCT_TAGS = {
    paxis: 'paxis', praxis: 'paxis',
    'paxis-neo': 'paxis-neo', paxisneo: 'paxis-neo', 'paxis-cloud': 'paxis-neo',
    metis: 'metis', maxis: 'maxis', capsis: 'capsis',
    aegis: 'general', signum: 'general', signium: 'general', velox: 'general', telox: 'general',
    'neocloud-os': 'general', 'thaki-neocloud-os': 'general'
  };

  // Section 3. `topics`: whether topic tags may narrow this category at all.
  // The site's DevOps category is the `dev` path segment.
  var CATEGORIES = {
    agentops: { ads: ['paxis', 'paxis-neo'], topics: true },
    llmops: { ads: ['metis', 'maxis'], topics: true },
    owm: { ads: ['metis', 'maxis'], topics: true },
    research: { ads: ['paxis', 'paxis-neo', 'metis', 'maxis'], topics: true },
    dev: { ads: ['capsis'], topics: false },
    datasets: { ads: ['maxis'], topics: false },
    tutorials: { ads: ['general'], topics: true },
    product: { ads: ['general'], topics: true },
    news: { ads: ['general'], topics: false },
    careers: { ads: ['general'], topics: false },
    culture: { ads: ['general'], topics: false },
    comics: { ads: ['general'], topics: false }
  };

  // Section 5. Broad tags (gpu, ai, llm, on-prem, dataset, benchmark, …) are deliberately absent.
  // `narrow`: the document only applies these inside AgentOps/Research candidates, so they can
  // narrow a category's candidates but don't count as a strong tag on Tutorials/Product posts.
  var TOPIC_GROUPS = [
    { ads: ['paxis', 'paxis-neo'], tags: 'agentops agent-ops ai-agent ai-agents agentic-ai multi-agent multiagent agent-orchestration agent-runtime agent-workflow workflow-automation tool-calling function-calling mcp model-context-protocol agent-skills skill-router skill-harness agentic-rag' },
    { ads: ['paxis', 'paxis-neo'], narrow: true, tags: 'rag' },
    { ads: ['paxis'], narrow: true, tags: 'on-prem-ai self-hosted-agent private-agent policy-enforcement human-in-the-loop agent-governance agent-security autonomous-agents approval-workflow' },
    { ads: ['paxis-neo'], narrow: true, tags: 'agent-saas ai-agent-saas managed-agents agent-as-a-service saas-agents no-code-agent business-automation' },
    { ads: ['metis'], tags: 'inference model-serving llm-serving serving inference-engine inference-optimization vllm sglang tensorrt-llm triton-inference-server ollama kv-cache prefix-caching pagedattention continuous-batching speculative-decoding batching latency throughput tokens-per-second ttft tpot quantization awq gptq fp8 nvfp4 mxfp4 gguf' },
    { ads: ['maxis'], tags: 'training model-training fine-tuning finetuning fine-tune sft supervised-fine-tuning lora qlora peft unsloth trl distributed-training pretraining pytorch deepspeed fsdp experiment-tracking mlops training-pipeline dataset-curation instruction-tuning synthetic-data distillation' },
    { ads: ['capsis'], tags: 'kubernetes k8s containers container helm kueue clusterqueue gpu-scheduling pod-scheduling multi-cluster cni network-policy kubeflow operator container-orchestration cluster-management' }
  ];

  var TOPIC_TAGS = {};
  TOPIC_GROUPS.forEach(function (group) {
    group.tags.split(' ').forEach(function (tag) { TOPIC_TAGS[tag] = group; });
  });

  function normalize(value) {
    return String(value).normalize('NFKC').trim().replace(/^#+/, '').trim().toLowerCase()
      .replace(/[\s_]+/g, '-').replace(/-+/g, '-');
  }

  function add(list, items) {
    items.forEach(function (item) { if (list.indexOf(item) === -1) list.push(item); });
    return list;
  }

  /** Returns { rule, ads }: the matched rule and the ads to pick from uniformly. */
  function candidates(categories, tags) {
    var cats = categories.map(normalize).filter(function (c) { return CATEGORIES[c]; });
    var normTags = tags.map(normalize);

    var products = [];
    var otherProduct = false;
    normTags.forEach(function (tag) {
      if (!PRODUCT_TAGS[tag]) return;
      if (PRODUCT_TAGS[tag] === 'general') otherProduct = true;
      else add(products, [PRODUCT_TAGS[tag]]);
    });
    if (products.length) return { rule: 'product_tag', ads: products };
    if (otherProduct) return { rule: 'fallback', ads: ['general'] };

    var catAds = [];
    var topicsAllowed = false;
    cats.forEach(function (c) {
      add(catAds, CATEGORIES[c].ads);
      topicsAllowed = topicsAllowed || CATEGORIES[c].topics;
    });
    var specific = catAds.filter(function (ad) { return ad !== 'general'; });

    if (topicsAllowed) {
      var topicAds = [];
      normTags.forEach(function (tag) {
        var group = TOPIC_TAGS[tag];
        if (group && (specific.length || !group.narrow)) add(topicAds, group.ads);
      });
      var matched = specific.length
        ? topicAds.filter(function (ad) { return specific.indexOf(ad) !== -1; })
        : topicAds;
      if (matched.length) return { rule: 'topic_tag', ads: matched };
    }

    if (specific.length) return { rule: 'category', ads: specific };
    if (catAds.length) return { rule: 'category', ads: ['general'] };
    return { rule: 'fallback', ads: ['general'] };
  }

  function track(name, params) {
    if (typeof window.gtag === 'function') window.gtag('event', name, params);
  }

  function render(slot, ad, lang, base, onClick) {
    var creative = ADS[ad][lang];
    var link = document.createElement('a');
    link.className = 'thaki-ad__link';
    link.href = creative.href;
    // Inside the homepage's /blog iframe shell the product page must replace the whole shell.
    if (window.top !== window.self) link.target = '_top';
    link.addEventListener('click', onClick);
    var img = document.createElement('img');
    img.src = base + 'ad-' + ad + '-' + lang + '-square.webp';
    img.alt = creative.alt;
    img.width = 640;
    img.height = 640;
    img.loading = 'lazy';
    img.decoding = 'async';
    link.appendChild(img);
    slot.appendChild(link);
    slot.hidden = false;
  }

  function init() {
    var slots = document.querySelectorAll('[data-thaki-ad]');
    if (!slots.length) return;
    var data = slots[0].dataset;
    var lang = data.adLang;
    if (lang !== 'ko' && lang !== 'en') return;

    var split = function (value) { return value ? value.split('|') : []; };
    var categories = split(data.adCategories);
    var result = candidates(categories, split(data.adTags));
    // One pick per page view: nothing re-rolls or rotates while the post is being read.
    var ad = result.ads[Math.floor(Math.random() * result.ads.length)];
    var params = {
      product_id: ad,
      article_slug: data.adSlug,
      article_category: categories.join(','),
      matching_rule: result.rule,
      locale: lang,
      creative_id: 'ad-' + ad + '-' + lang + '-square'
    };
    var onClick = function () { track('ad_click', params); };
    slots.forEach(function (slot) { render(slot, ad, lang, data.adBase, onClick); });

    // Only the slot this viewport shows ever intersects (the other is display:none), and the
    // bottom one on phones may never be reached — so count an impression when it's really seen.
    var seen = false;
    var seenOnce = function () {
      if (seen) return;
      seen = true;
      track('ad_impression', params);
    };
    if (!('IntersectionObserver' in window)) { seenOnce(); return; }
    var observer = new IntersectionObserver(function (entries) {
      if (!entries.some(function (e) { return e.isIntersecting; })) return;
      observer.disconnect();
      seenOnce();
    }, { threshold: 0.5 });
    slots.forEach(function (slot) { observer.observe(slot); });
  }

  if (typeof module !== 'undefined' && module.exports) {
    module.exports = { ADS: ADS, candidates: candidates, normalize: normalize };
  } else if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
