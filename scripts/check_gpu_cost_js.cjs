// Parity check: assets/js/gpu-cost-assessment.js must reproduce multilora_tco.py
// on the reference scenarios (tools/tco_scenarios.json in thakigov-safety-multilora).
// Expected GPU counts below were produced by `multilora_tco.py --json` on 2026-11-17.
// Usage: node scripts/check_gpu_cost_js.cjs <path/to/tco_scenarios.json>
const fs = require('fs');
const M = require('../assets/js/gpu-cost-assessment.js');
const EXPECTED = {
  soc_8_low_traffic: [8, 4, 1, 'min_replicas'],
  mssp_8_ha: [16, 8, 3, 'compute'],
  soc_8_long_context: [8, 8, 3, 'kv_memory'],
  high_traffic_4: [8, 8, 9, 'compute'],
};
const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
let fail = 0;
for (const s of data.scenarios) {
  const d = Object.assign({}, data.defaults, s);
  delete d.sources; delete d.name; delete d.description;
  const r = M.compute(M.merge(M.defaults(), d));
  const got = [r.independent, r.packed, r.multilora, r.binding];
  const exp = EXPECTED[s.name];
  const ok = exp && JSON.stringify(got) === JSON.stringify(exp);
  if (!ok) fail++;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${s.name} got=${JSON.stringify(got)} exp=${JSON.stringify(exp)}`);
}
process.exit(fail ? 1 : 0);
