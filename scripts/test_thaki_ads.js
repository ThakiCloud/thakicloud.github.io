#!/usr/bin/env node
// Section 7 of marketing's ad rules, plus the edge cases its prose spells out.
// Run: node scripts/test_thaki_ads.js
const assert = require('assert');
const { ADS, candidates, normalize } = require('../assets/js/thaki-ads.js');

const cases = [
  // Section 7 test cases
  ['agentops', 'mcp multi-agent', ['paxis', 'paxis-neo']],
  ['agentops', 'paxis agent-runtime', ['paxis']],
  ['agentops', 'paxis-neo paxis', ['paxis', 'paxis-neo']],
  ['llmops', 'vllm quantization', ['metis']],
  ['llmops', 'fine-tuning inference', ['maxis', 'metis']],
  ['research', 'lora dataset', ['maxis']],
  ['research', 'mcp inference', ['metis', 'paxis', 'paxis-neo']],
  ['dev', 'kubernetes', ['capsis']],
  ['dev', 'metis kubernetes', ['metis']],
  ['datasets', 'dataset benchmark', ['maxis']],
  ['tutorials', 'llm-serving', ['metis']],
  ['news', '', ['general']],
  ['careers', '', ['general']],
  ['research', 'aegis', ['general']],
  // Prose rules
  ['research', 'aegis paxis', ['paxis']],                    // a product with an ad beats one without
  ['research', 'thakicloud', ['maxis', 'metis', 'paxis', 'paxis-neo']], // company tag isn't a product
  ['research', 'gpu llm', ['maxis', 'metis', 'paxis', 'paxis-neo']],    // broad tags decide nothing
  ['agentops', 'kubernetes', ['paxis', 'paxis-neo']],        // no overlap → category default
  ['dev', 'mcp', ['capsis']],                                // product tags only on DevOps
  ['news', 'inference', ['general']],                        // product tags only on News
  ['agentops', 'on-prem-ai', ['paxis']],
  ['agentops', 'agent-saas', ['paxis-neo']],
  ['agentops', 'rag', ['paxis', 'paxis-neo']],
  ['llmops', 'rag', ['maxis', 'metis']],                     // rag only speaks for agent contexts
  ['tutorials', 'rag', ['general']],
  ['tutorials', 'agent-governance', ['general']],
  ['product', 'mcp', ['paxis', 'paxis-neo']],
  ['product', 'paxis', ['paxis']],
  ['', '', ['general']],                                     // uncategorised
  ['news research', '', ['maxis', 'metis', 'paxis', 'paxis-neo']], // general yields to specifics
];

for (const [cats, tags, expected] of cases) {
  const split = (s) => s.split(' ').filter(Boolean);
  const got = candidates(split(cats), split(tags)).ads.slice().sort();
  assert.deepStrictEqual(got, expected, `[${cats}] [${tags}]: got ${got}, want ${expected}`);
}

const rule = (c, t) => candidates(c, t).rule;
assert.strictEqual(rule(['agentops'], ['paxis']), 'product_tag');
assert.strictEqual(rule(['agentops'], ['mcp']), 'topic_tag');
assert.strictEqual(rule(['agentops'], ['gpu']), 'category');
assert.strictEqual(rule([], []), 'fallback');
assert.strictEqual(rule(['research'], ['aegis']), 'fallback');

// Section 6 normalisation
assert.strictEqual(normalize('#Agent Ops'), 'agent-ops');
assert.strictEqual(normalize('#agent_ops'), 'agent-ops');
assert.strictEqual(normalize('#vLLM'), 'vllm');
assert.strictEqual(normalize('#Fine Tuning'), 'fine-tuning');
assert.deepStrictEqual(candidates(['agentops'], ['#Agent Ops']).rule, 'topic_tag');

// Exact match only: paxis-neo must not read as paxis, and vice versa.
assert.deepStrictEqual(candidates(['agentops'], ['paxis-neo']).ads, ['paxis-neo']);
assert.deepStrictEqual(candidates(['agentops'], ['paxis-neo-extra']).rule, 'category');

// Every ad has both languages.
for (const id of Object.keys(ADS)) for (const lang of ['ko', 'en']) assert.ok(ADS[id][lang].href && ADS[id][lang].alt, `${id}/${lang}`);

console.log(`ok: ${cases.length} selection cases`);
