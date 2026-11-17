/* GPU 비용 진단 — Multi-LoRA 공유 서빙 vs 업무별 독립 인스턴스 추정기.
 * 계산식은 thakigov-safety-multilora/tools/multilora_tco.py 를 그대로 옮긴 것이다
 * (같은 입력이면 같은 GPU 수가 나와야 한다 — scripts/check_gpu_cost_js.cjs 가 대조).
 * 결과는 전부 MODELED_NOT_MEASURED: 입력 가정 아래의 계산값이지 실측 절감이 아니다.
 * 처리량·LoRA 효율은 측정한 적이 없어 범위(낮음·중간·높음)로 세 번 계산한다.
 */
(function (root) {
  'use strict';
  var HOURS_PER_MONTH = 730.0;
  var MEASURED = { gpu_hbm_gib: 179.06, base_load_gib: 30.51, kv_avail_gib: 104.33,
    adapter_gib: 0.435, max_loras: 8 };
  var DERIVED_OVERHEAD_GIB = Math.round((MEASURED.gpu_hbm_gib * 0.9 - MEASURED.base_load_gib
    - MEASURED.kv_avail_gib) * 100) / 100;
  var EPS = 1e-9;

  function defaults() {
    return { gpu_hbm_gib: MEASURED.gpu_hbm_gib, gpu_mem_util: 0.9, base_load_gib: MEASURED.base_load_gib,
      adapter_gib: MEASURED.adapter_gib, engine_overhead_gib: DERIVED_OVERHEAD_GIB, kv_gib_per_seq: 2.0,
      lora_throughput_factor: 1.0, target_util: 0.6, min_replicas: 1, max_loras_per_engine: MEASURED.max_loras,
      gpu_hourly_cost: 0 };
  }
  function ceil(x) { return Math.ceil(x - EPS); }
  function gpuLoad(t, inp, factor) {
    var perReq = t.in_tokens / inp.prefill_tok_s_per_gpu + t.out_tokens / inp.decode_tok_s_per_gpu;
    return t.peak_req_per_s * perReq / (factor || 1.0);
  }
  function usable(inp) { return inp.gpu_hbm_gib * inp.gpu_mem_util; }
  function engine(load, conc, inp, nAdapters) {
    var kv = usable(inp) - inp.base_load_gib - inp.engine_overhead_gib - nAdapters * inp.adapter_gib;
    if (kv <= 0) throw new Error('NO_FIT');
    var byCompute = load > 0 ? ceil(load / inp.target_util) : 0;
    var byMemory = conc > 0 ? ceil(conc * inp.kv_gib_per_seq / kv) : 0;
    var n = Math.max(inp.min_replicas, byCompute, byMemory);
    var bind = byCompute >= byMemory ? ['compute', byCompute] : ['kv_memory', byMemory];
    return { gpus: n, by_compute: byCompute, by_memory: byMemory, kv_gib_per_gpu: Math.round(kv * 100) / 100,
      binding: bind[1] > inp.min_replicas ? bind[0] : 'min_replicas' };
  }
  function packIndependent(inp) {
    var u = usable(inp), inst = [];
    inp.tasks.forEach(function (t) {
      var load = gpuLoad(t, inp, 1);
      var n = Math.max(inp.min_replicas, load > 0 ? ceil(load / inp.target_util) : 0);
      var mem = inp.base_load_gib + inp.engine_overhead_gib + Math.ceil(t.peak_concurrency / n) * inp.kv_gib_per_seq;
      if (mem > u) {
        var room = u - inp.base_load_gib - inp.engine_overhead_gib;
        if (room <= 0) throw new Error('NO_FIT');
        n = Math.max(n, ceil(t.peak_concurrency * inp.kv_gib_per_seq / room));
        mem = inp.base_load_gib + inp.engine_overhead_gib + Math.ceil(t.peak_concurrency / n) * inp.kv_gib_per_seq;
      }
      for (var i = 0; i < n; i++) inst.push([t.name, load / n, mem]);
    });
    // Python sort(reverse=True) is stable: equal keys keep insertion order.
    inst = inst.map(function (x, i) { return [x, i]; }).sort(function (a, b) {
      var ka = a[0][1] / inp.target_util + a[0][2] / u, kb = b[0][1] / inp.target_util + b[0][2] / u;
      return kb - ka || a[1] - b[1];
    }).map(function (x) { return x[0]; });
    var gpus = [];
    inst.forEach(function (x) {
      for (var j = 0; j < gpus.length; j++) {
        var g = gpus[j];
        if (g.tasks.indexOf(x[0]) < 0 && g.load + x[1] <= inp.target_util + EPS && g.mem + x[2] <= u) {
          g.tasks.push(x[0]); g.load += x[1]; g.mem += x[2]; return;
        }
      }
      gpus.push({ tasks: [x[0]], load: x[1], mem: x[2] });
    });
    return { gpus: gpus.length, instances: inst.length };
  }
  function compute(inp) {
    var indep = inp.tasks.map(function (t) { return engine(gpuLoad(t, inp, 1), t.peak_concurrency, inp, 0); });
    var gpusA = indep.reduce(function (s, x) { return s + x.gpus; }, 0);
    var packed = packIndependent(inp);
    var n = inp.tasks.length;
    var loadB = inp.tasks.reduce(function (s, t) { return s + gpuLoad(t, inp, inp.lora_throughput_factor); }, 0);
    var concB = inp.tasks.reduce(function (s, t) { return s + t.peak_concurrency; }, 0);
    var shared = engine(loadB, concB, inp, Math.min(n, inp.max_loras_per_engine));
    var unit = inp.gpu_hourly_cost * HOURS_PER_MONTH;
    return { independent: gpusA, packed: packed.gpus, multilora: shared.gpus, binding: shared.binding,
      kv_gib_per_gpu: shared.kv_gib_per_gpu,
      monthly: { independent: gpusA * unit, packed: packed.gpus * unit, multilora: shared.gpus * unit },
      over_slots: n > inp.max_loras_per_engine };
  }
  function merge(base, over) { var o = {}, k; for (k in base) o[k] = base[k]; for (k in over) o[k] = over[k]; return o; }

  root.GpuCostModel = { compute: compute, defaults: defaults, merge: merge, MEASURED: MEASURED,
    DERIVED_OVERHEAD_GIB: DERIVED_OVERHEAD_GIB, HOURS_PER_MONTH: HOURS_PER_MONTH };
  if (typeof module !== 'undefined' && module.exports) module.exports = root.GpuCostModel;
})(typeof window !== 'undefined' ? window : globalThis);
