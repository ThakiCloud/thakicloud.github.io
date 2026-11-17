/* GPU 비용 진단 페이지 UI. 계산은 gpu-cost-assessment.js(GpuCostModel)가 한다.
 * 이 파일은 입력 → 업무 목록 변환, 처리량 범위 3회 계산, 결과 표시, 신청서 전송, GA4 이벤트만 맡는다.
 * 개인정보(이름·이메일 등)는 GA4 로 보내지 않는다. GA4 에는 워크로드 모양(업무 수 등)만 보낸다.
 */
(function () {
  'use strict';
  var root = document.getElementById('gca');
  if (!root || !window.GpuCostModel) return;
  var M = window.GpuCostModel;
  var LANG = root.getAttribute('data-lang') === 'en' ? 'en' : 'ko';
  var ENDPOINT = 'https://api.thakicloud.com/api/v1/notifications/inbound';
  var SEC = 3600 * M.HOURS_PER_MONTH;

  var T = {
    ko: {
      cases: ['처리량 낮음', '처리량 중간', '처리량 높음'],
      cols: ['가정', 'A 업무별 전용 GPU', "A' 업무별 인스턴스를 GPU에 모아 배치", 'B Multi-LoRA 공유'],
      gpus: function (n) { return 'GPU ' + n + '장'; },
      perMonth: '월',
      bind: { compute: '연산량이 GPU 수를 정합니다.', kv_memory: '동시 요청의 KV 캐시 메모리가 GPU 수를 정합니다.',
        min_replicas: '최소 복제 수(상시 1벌 또는 이중화)가 GPU 수를 정합니다.' },
      better: '중간 가정에서 공유 구성(B)이 가장 강한 비교 기준(A′)보다 GPU를 적게 씁니다. 적용 후보입니다.',
      equal: '중간 가정에서 공유 구성(B)과 비교 기준(A′)의 GPU 수가 같습니다. 비용 이점보다 운영 단순화가 판단 기준이 됩니다.',
      worse: '중간 가정에서 공유 구성(B)이 오히려 GPU를 더 씁니다. 업무별 트래픽이 GPU를 채울 만큼 크면 공유로 아낄 바닥 비용이 없고 LoRA 처리 오버헤드만 남습니다.',
      slots: '업무가 8개를 넘습니다. 우리가 검증한 구성은 엔진 하나에 어댑터 8개이며, 그 이상은 어댑터 교체 지연이 생길 수 있습니다.',
      noFit: '이 GPU 메모리에는 Base 모델과 엔진이 들어가지 않습니다. GPU 종류나 모델 크기를 다시 확인해 주세요.',
      noPrice: '시간당 단가를 넣으면 월 비용도 함께 계산합니다.',
      ok: '신청이 접수됐습니다. 담당자가 입력하신 조건을 확인한 뒤 연락드립니다.',
      fail: '전송에 실패했습니다. 잠시 뒤 다시 시도하시거나 info@thakicloud.com 으로 보내 주세요.',
      needConsent: '필수 동의 항목에 동의해 주세요.',
      needCalc: '먼저 위에서 추정을 계산해 주세요.',
      requestType: '견적 요청'
    },
    en: {
      cases: ['Low throughput', 'Mid throughput', 'High throughput'],
      cols: ['Assumption', 'A Dedicated GPUs per task', "A' Per-task instances packed onto GPUs", 'B Shared Multi-LoRA'],
      gpus: function (n) { return n + (n === 1 ? ' GPU' : ' GPUs'); },
      perMonth: 'per month',
      bind: { compute: 'Compute sets the GPU count.', kv_memory: 'KV-cache memory for concurrent requests sets the GPU count.',
        min_replicas: 'The minimum replica count (one always-on copy, or two for redundancy) sets the GPU count.' },
      better: 'Under the mid assumption, the shared setup (B) uses fewer GPUs than the strongest baseline (A′). It is a candidate.',
      equal: 'Under the mid assumption, the shared setup (B) and the baseline (A′) need the same number of GPUs. Operational simplicity, not cost, would be the deciding factor.',
      worse: 'Under the mid assumption, the shared setup (B) needs more GPUs. When each task has enough traffic to fill GPUs on its own, sharing saves no idle floor and only adds LoRA overhead.',
      slots: 'You have more than 8 tasks. The configuration we validated loads 8 adapters per engine; beyond that, adapter swapping can add latency.',
      noFit: 'The base model and engine do not fit in this GPU memory. Please check the GPU type or model size.',
      noPrice: 'Add an hourly price to see monthly cost as well.',
      ok: 'Your request has been received. We will review your inputs and get back to you.',
      fail: 'Sending failed. Please try again shortly or email info@thakicloud.com.',
      needConsent: 'Please accept the required consent.',
      needCalc: 'Please run the estimate above first.',
      requestType: 'Quotes'
    }
  }[LANG];

  // 처리량은 측정하지 않았다(D3 HOLD). B200 기준 예시 범위이며, 고객 환경 실측으로 바꿔야 한다.
  var CASES = [
    { prefill_tok_s_per_gpu: 10000, decode_tok_s_per_gpu: 1250 },
    { prefill_tok_s_per_gpu: 20000, decode_tok_s_per_gpu: 2500 },
    { prefill_tok_s_per_gpu: 40000, decode_tok_s_per_gpu: 5000 }
  ];
  // HBM 은 공개 사양(GB → GiB). B200 만 우리 실행에서 잰 값이다.
  var GPU = { b200: M.MEASURED.gpu_hbm_gib, h200: 131.31, h100: 74.51 };
  var SLA = { strict: 0.5, normal: 0.6, relaxed: 0.8 };
  var CTX = { short: 1.0, mid: 2.0, long: 6.0 };

  function $(id) { return document.getElementById(id); }
  function num(id, dflt) { var v = parseFloat(($(id) || {}).value); return isFinite(v) && v >= 0 ? v : dflt; }
  function val(id) { return ($(id) || {}).value || ''; }
  function fmt(x) { return Math.round(x).toLocaleString(LANG === 'ko' ? 'ko-KR' : 'en-US'); }
  function ga(name, params) { try { if (window.gtag) window.gtag('event', name, params || {}); } catch (e) { /* no-op */ } }

  var utm = {};
  (function () {
    var q = new URLSearchParams(location.search);
    ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content'].forEach(function (k) { if (q.get(k)) utm[k] = q.get(k).slice(0, 100); });
    try {
      if (Object.keys(utm).length) sessionStorage.setItem('gca_utm', JSON.stringify(utm));
      else utm = JSON.parse(sessionStorage.getItem('gca_utm') || '{}');
    } catch (e) { /* storage blocked */ }
  })();

  function buildInputs() {
    var n = Math.max(1, Math.min(32, Math.round(num('gca-models', 8))));
    var monthly = num('gca-requests', 300000);
    var peakX = Math.max(1, num('gca-peak', 3));
    var conc = Math.max(1, Math.round(num('gca-concurrency', 32)));
    var shares = [], i;
    if (val('gca-dist') === 'skewed' && n > 2) {
      shares = [0.35, 0.35];
      for (i = 2; i < n; i++) shares.push(0.3 / (n - 2));
    } else { for (i = 0; i < n; i++) shares.push(1 / n); }
    var tasks = shares.map(function (s, k) {
      var avg = monthly * s / SEC;
      return { name: 't' + k, req_per_s: avg, peak_req_per_s: avg * peakX, in_tokens: num('gca-in', 1500),
        out_tokens: num('gca-out', 300), peak_concurrency: Math.max(1, Math.ceil(conc * s)) };
    });
    var gpu = val('gca-gpu') || 'b200';
    return { n: n, gpu: gpu, base: M.merge(M.defaults(), {
      tasks: tasks, gpu_hbm_gib: GPU[gpu] || GPU.b200, target_util: SLA[val('gca-sla')] || 0.6,
      min_replicas: val('gca-ha') === 'yes' ? 2 : 1, kv_gib_per_seq: CTX[val('gca-ctx')] || 2.0,
      lora_throughput_factor: 0.85, gpu_hourly_cost: num('gca-price', 0) }) };
  }

  var last = null;
  function calc() {
    var built = buildInputs(), out = $('gca-result'), rows = [], res = [];
    try {
      CASES.forEach(function (c) { res.push(M.compute(M.merge(built.base, c))); });
    } catch (e) {
      out.innerHTML = '<p class="gca-warn">' + T.noFit + '</p>'; out.hidden = false; last = null; return;
    }
    var price = built.base.gpu_hourly_cost > 0;
    res.forEach(function (r, i) {
      function cell(g, m) { return T.gpus(g) + (price ? '<br><small>' + T.perMonth + ' ' + fmt(m) + '</small>' : ''); }
      rows.push('<tr><th scope="row">' + T.cases[i] + '</th><td>' + cell(r.independent, r.monthly.independent) +
        '</td><td>' + cell(r.packed, r.monthly.packed) + '</td><td>' + cell(r.multilora, r.monthly.multilora) + '</td></tr>');
    });
    var mid = res[1];
    var verdict = mid.multilora < mid.packed ? 'better' : (mid.multilora === mid.packed ? 'equal' : 'worse');
    var html = '<p class="gca-label">MODELED_NOT_MEASURED</p>' +
      '<div class="gca-table-wrap"><table class="gca-table"><thead><tr><th>' + T.cols.join('</th><th>') +
      '</th></tr></thead><tbody>' + rows.join('') + '</tbody></table></div>' +
      '<p class="gca-verdict gca-' + verdict + '">' + T[verdict] + '</p>' +
      '<p>' + T.bind[mid.binding] + '</p>' +
      (mid.over_slots ? '<p class="gca-warn">' + T.slots + '</p>' : '') +
      (price ? '' : '<p class="gca-muted">' + T.noPrice + '</p>');
    out.innerHTML = html; out.hidden = false;
    last = { models: built.n, gpu: built.gpu, sla: val('gca-sla'), ha: val('gca-ha'), ctx: val('gca-ctx'),
      dist: val('gca-dist'), monthly_requests: num('gca-requests', 0), peak_factor: num('gca-peak', 0),
      concurrency: num('gca-concurrency', 0), in_tokens: num('gca-in', 0), out_tokens: num('gca-out', 0),
      hourly_price: num('gca-price', 0), verdict: verdict,
      gpus_mid: { independent: mid.independent, packed: mid.packed, multilora: mid.multilora },
      label: 'MODELED_NOT_MEASURED' };
    ga('assessment_calculate', { assessment_models: built.n, gpu_type: built.gpu, assessment_verdict: verdict });
  }

  function clientId(cb) {
    var done = false; function fin(v) { if (!done) { done = true; cb(v || ''); } }
    try { if (window.gtag) window.gtag('get', 'G-78BFTNGGJX', 'client_id', fin); } catch (e) { /* no-op */ }
    setTimeout(fin, 800);
  }

  function submit(ev) {
    ev.preventDefault();
    var msg = $('gca-form-msg'), btn = $('gca-submit');
    if (!last) { msg.textContent = T.needCalc; return; }
    if (!$('gca-privacy').checked) { msg.textContent = T.needConsent; return; }
    if (!ev.target.reportValidity()) return;
    btn.disabled = true; msg.textContent = '';
    clientId(function (cid) {
      var payload = {
        name: val('gca-name').trim(), email: val('gca-email').trim(), company: val('gca-company').trim(),
        department: val('gca-dept').trim(), job_title: val('gca-title').trim(), contact_number: val('gca-phone').trim(),
        country: val('gca-country'), request_type: T.requestType,
        privacy_consent: true, marketing_consent: $('gca-marketing').checked,
        // 아래는 기존 문의 스키마 밖의 필드다. 백엔드가 저장·전달하는지 확인 전까지는 GA4·상담에서 재확인한다.
        source: 'gpu-cost-assessment', lang: LANG, segment: val('gca-segment'),
        assessment: last, utm: utm, ga_client_id: cid
      };
      function post(body) {
        return fetch(ENDPOINT, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
      }
      var CORE = ['name', 'email', 'company', 'department', 'job_title', 'contact_number', 'country', 'request_type',
        'privacy_consent', 'marketing_consent'];
      post(payload)
        .then(function (r) {
          // 백엔드가 모르는 필드를 거부하면(4xx) 홈페이지 문의 폼과 같은 스키마로 한 번 더 보낸다.
          if (r.ok || r.status < 400 || r.status >= 500) return r;
          var core = {}; CORE.forEach(function (k) { core[k] = payload[k]; });
          return post(core);
        })
        .then(function (r) {
          if (!r.ok) throw new Error(String(r.status));
          msg.textContent = T.ok; ev.target.reset(); ga('generate_lead', { lead_source: 'gpu-cost-assessment',
            assessment_models: last.models, gpu_type: last.gpu, assessment_verdict: last.verdict,
            lead_segment: payload.segment || 'unspecified' });
        })
        .catch(function () { msg.textContent = T.fail; })
        .then(function () { btn.disabled = false; });
    });
  }

  $('gca-calc').addEventListener('click', calc);
  $('gca-form').addEventListener('submit', submit);
  ga('assessment_view', { lead_source: 'gpu-cost-assessment' });
})();
