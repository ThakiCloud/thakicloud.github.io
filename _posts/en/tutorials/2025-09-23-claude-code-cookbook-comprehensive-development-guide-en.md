---
title: "Claude Code Cookbook: The Ultimate Development Productivity Enhancer Guide"
excerpt: "A comprehensive tutorial on leveraging Claude Code Cookbook's 60+ commands, roles, and hooks to revolutionize your development workflow with AI-powered automation."
seo_title: "Claude Code Cookbook Complete Guide - AI Development Tools Tutorial"
seo_description: "Master Claude Code Cookbook: 60+ commands for PR automation, code review, refactoring, multi-role agents, and development hooks. Transform your coding workflow with AI."
date: 2025-09-23
tags:
  - claude-code
  - development-tools
  - ai-automation
  - github-workflows
  - code-review
  - productivity
  - cli-tools
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/claude-code-cookbook-comprehensive-guide/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/claude-code-cookbook-comprehensive-guide/"
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 18 minutes

## Introduction

The [Claude Code Cookbook](https://github.com/foreveryh/claude-code-cookbook) represents a groundbreaking collection of over 60 commands, specialized roles, and automation hooks designed to supercharge your development workflow with AI-powered capabilities. This comprehensive toolkit transforms how developers interact with code, manage projects, and collaborate through intelligent automation.

In an era where AI is reshaping software development, Claude Code Cookbook stands out as a practical, battle-tested solution that bridges the gap between advanced AI capabilities and everyday development tasks. Whether you're handling complex refactoring, managing GitHub workflows, or conducting thorough code reviews, this toolkit provides structured, reliable patterns for leveraging AI in your development process.

## What is Claude Code Cookbook?

### Overview

Claude Code Cookbook is a curated collection of commands, roles, and automation scripts designed to enhance Claude Code's capabilities for software development. Originally forked from wasabeef's repository and enhanced by the community, it provides a systematic approach to integrating AI into your development workflow.

### Key Components

The toolkit consists of three main components:

1. **Commands**: Over 60 specialized commands for specific development tasks
2. **Roles**: Expert personas that provide specialized perspectives and analysis
3. **Hooks**: Automation scripts that integrate seamlessly into your development workflow

### Core Philosophy

The cookbook follows a principle of "structured AI assistance" - instead of generic prompts, it provides specific, contextual commands that produce consistent, high-quality results for common development scenarios.

## Command Categories and Usage

### 1. GitHub Workflow Commands

The cookbook excels in GitHub workflow automation with commands that streamline common Git operations:

#### Pull Request Management
```bash
# List and prioritize open PRs
/pr-list

# Create PR with automatic analysis
/pr-create

# Comprehensive PR review
/pr-review

# Automatically update PR content
/pr-auto-update

# Merge PRs with quality verification
/pr-merge
```

#### Issue Management
```bash
# Display prioritized issues
/pr-issue

# Generate detailed bug reports
/bug-report

# Create comprehensive feature specifications
/feature-request
```

#### Advanced Git Operations
```bash
# Semantic commit with meaningful units
/semantic-commit

# Check CI/CD status
/check-github-ci

# Handle merge conflicts intelligently
/merge-conflict
```

### 2. Code Quality and Analysis Commands

These commands focus on maintaining and improving code quality:

#### Code Review and Analysis
```bash
# Advanced code quality review
/smart-review

# Safe step-by-step refactoring
/refactor

# Technical debt analysis
/tech-debt

# Comprehensive error analysis
/fix-error
```

#### Architecture and Design
```bash
# Create detailed specifications
/spec

# Generate comprehensive documentation
/generate-docs

# Performance optimization analysis
/optimize
```

### 3. Development Workflow Commands

Commands that enhance daily development activities:

#### Project Management
```bash
# Create implementation plans
/plan

# Track execution progress
/show-plan

# Multi-language documentation updates
/update-doc-string
```

#### Dependency Management
```bash
# Safe Flutter dependency updates
/update-flutter-deps

# Node.js dependency management
/update-node-deps

# Rust dependency updates
/update-rust-deps
```

## Role-Based Expert Analysis

### Available Roles

The cookbook includes specialized roles that provide expert perspectives:

| Role | Expertise | Use Cases |
|------|-----------|-----------|
| `/role analyzer` | System analysis expert | Architecture review, system design |
| `/role architect` | Software architecture | Design patterns, scalability |
| `/role frontend` | UI/UX and performance | Frontend optimization, user experience |
| `/role mobile` | iOS/Android development | Mobile best practices, platform-specific advice |
| `/role performance` | Performance optimization | Speed and memory improvements |
| `/role qa` | Quality assurance | Test planning, quality metrics |
| `/role reviewer` | Code review specialist | Code quality, maintainability |
| `/role security` | Security expert | Vulnerability assessment, security best practices |

### Sub-Agent Execution

Roles can be executed as independent sub-agents for parallel analysis:

```bash
# Normal mode (execute in main context)
/role security
"Security check for this project"

# Sub-agent mode (execute in independent context)
/role security --agent
"Perform a comprehensive security audit of the project"

# Parallel analysis with multiple roles
/multi-role security,performance --agent
"Comprehensively analyze the system's security and performance"
```

### Role Debate Feature

The `/role-debate` command enables multiple expert perspectives to collaborate:

```bash
/role-debate
"Should we use microservices or monolithic architecture for this project?"
```

This command orchestrates discussions between different roles, providing balanced analysis from multiple expert viewpoints.

## Automation Hooks

### Development Automation

The cookbook includes sophisticated hooks that automate common development tasks:

#### File Management Hooks
- **preserve-file-permissions.sh**: Maintains file permissions during edits
- **ja-space-format.sh**: Automatically formats Japanese text spacing
- **auto-comment.sh**: Prompts for documentation when creating new files

#### Safety and Quality Hooks
- **deny-check.sh**: Prevents execution of dangerous commands
- **check-ai-commit.sh**: Validates commit message quality
- **check-continue.sh**: Identifies continuable tasks

#### Notification Hooks
- **notify-waiting**: macOS notifications for user confirmations
- **osascript**: Completion notifications

### Hook Configuration

Hooks are configured in `settings.json` and execute automatically at specific points:

- **PreToolUse**: Execute before tool operations
- **PostToolUse**: Execute after tool operations
- **Notification**: Handle user notifications
- **Stop**: Execute when tasks complete

## Advanced Features

### Multi-Language Support

The cookbook supports comprehensive documentation in multiple languages:

```bash
# Update documentation strings in multiple languages
/update-doc-string

# Dart-specific documentation management
/update-dart-doc
```

### Search and Analysis

Advanced search capabilities for comprehensive code analysis:

```bash
# Web search integration
/search-gemini

# Sequential thinking for complex problems
/sequential-thinking

# Ultra-structured thinking processes
/ultrathink
```

### AI Writing Enhancement

Tools for improving AI-generated content:

```bash
# Detect and correct AI-generated text patterns
/style-ai-writing

# Task delegation to specialized agents
/task
```

## Development Workflow Integration

### Typical Development Flow

The cookbook enables a streamlined development workflow:

{% raw %}
<!--
  animated-architecture-diagram — self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="ensivedevelopmentguideen-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent — swap for #1B4F72 etc. */
    position: relative;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
    color: var(--text-color);
  }
  @media (prefers-color-scheme: dark) {
    .d3-arch {
      --page-bg: #0f1115;
      --surface-bg: #171a21;
      --text-color: #e6e8eb;
      --muted-color: #9aa3af;
      --border-color: #2a2f3a;
      --primary-color: hsl(217 91% 62%);
    }
  }
  .d3-arch[data-theme="light"] { --page-bg:#fff; --surface-bg:#f7f8fa; --text-color:#1a1d21; --muted-color:#6b7280; --border-color:#d5d9e0; --primary-color:hsl(217 91% 55%); }
  .d3-arch[data-theme="dark"]  { --page-bg:#0f1115; --surface-bg:#171a21; --text-color:#e6e8eb; --muted-color:#9aa3af; --border-color:#2a2f3a; --primary-color:hsl(217 91% 62%); }

  .d3-arch .diagram-scroll { overflow-x: auto; }
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
  .d3-arch svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }

  /* Group boxes */
  .d3-arch .group rect { fill: none; stroke: var(--border-color); stroke-dasharray: 3 3; rx: 12px; }
  .d3-arch .group text { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; fill: var(--muted-color); }

  /* Nodes */
  .d3-arch .node rect { fill: var(--surface-bg); stroke: var(--border-color); stroke-width: 1; transition: stroke 0.15s ease, opacity 0.15s ease; }
  .d3-arch .node .node-title { font-size: 12px; font-weight: 600; fill: var(--text-color); }
  .d3-arch .node .node-sub { font-size: 9.5px; fill: var(--muted-color); }
  .d3-arch .node { cursor: default; transition: opacity 0.15s ease; }

  /* Edges */
  .d3-arch .edge { transition: opacity 0.15s ease; }
  .d3-arch .edge path.main { fill: none; stroke-width: 1.5; }
  .d3-arch .edge.data path.main { stroke: var(--primary-color); }
  .d3-arch .edge.event path.main { stroke: var(--muted-color); stroke-dasharray: 5 4; }
  .d3-arch .edge text { font-size: 9.5px; fill: var(--muted-color); paint-order: stroke; stroke: var(--page-bg); stroke-width: 3px; stroke-linejoin: round; }

  /* Hover highlighting */
  .d3-arch.hovering .edge:not(.hl) { opacity: 0.12; }
  .d3-arch.hovering .node:not(.hl):not(.nb) { opacity: 0.25; }
  .d3-arch .node.hl rect { stroke: var(--primary-color); stroke-width: 1.5; }

  /* Flow animation */
  .d3-arch .flow-dot.data { fill: var(--primary-color); stroke: var(--page-bg); stroke-width: 1.5; }
  .d3-arch .flow-dot.event { fill: var(--page-bg); stroke: var(--muted-color); stroke-width: 1.5; }
  .d3-arch .node.anim-hl rect { stroke: var(--primary-color); stroke-width: 1.5; }
  .d3-arch .replay-btn { font: inherit; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--surface-bg); color: var(--text-color); cursor: pointer; transition: border-color 0.15s ease, opacity 0.15s ease; }
  .d3-arch .replay-btn:hover:not(:disabled) { border-color: var(--primary-color); }
  .d3-arch .replay-btn:disabled { opacity: 0.45; cursor: default; }
  .d3-arch .replay-btn:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }

  /* Legend */
  .d3-arch .legend { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; }
  .d3-arch .legend-title { font-size: 12px; font-weight: 700; color: var(--text-color); }
  .d3-arch .legend .items { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; }
  .d3-arch .legend .item { display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; font-size: 12px; color: var(--text-color); }
  .d3-arch .legend .swatch { width: 22px; height: 0; }
  .d3-arch .legend .swatch.data-line { border-top: 2.5px solid var(--primary-color); }
  .d3-arch .legend .swatch.event-line { border-top: 2.5px dashed var(--muted-color); }
  .d3-arch .legend .hint { font-size: 11px; font-style: italic; color: var(--muted-color); }
</style>
<script>
  (() => {
    const SPEC = ({"title": "", "ariaLabel": "", "width": 773, "height": 1682, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Start", "x": 342, "y": 24, "w": 149, "h": 46, "title": "Task Confirmation"}, {"id": "PRList", "x": 265, "y": 148, "w": 120, "h": 62, "title": ["/pr-list", "Open PR List"]}, {"id": "PRIssue", "x": 440, "y": 148, "w": 135, "h": 62, "title": ["/pr-issue", "Open Issue List"]}, {"id": "TaskType", "x": 348, "y": 288, "w": 138, "h": 52, "title": "Type?"}, {"id": "Plan", "x": 24, "y": 432, "w": 205, "h": 78, "title": ["/spec", "Requirements Definition &", "Design"]}, {"id": "Fix", "x": 263, "y": 596, "w": 128, "h": 62, "title": ["/fix-error", "Error Analysis"]}, {"id": "Refactor", "x": 446, "y": 596, "w": 120, "h": 62, "title": ["/refactor", "Improvement"]}, {"id": "Review", "x": 621, "y": 596, "w": 120, "h": 62, "title": ["/pr-review", "Review"]}, {"id": "Design", "x": 45, "y": 588, "w": 163, "h": 78, "title": ["/role architect", "/role-debate", "Design Consultation"]}, {"id": "Implementation", "x": 318, "y": 744, "w": 198, "h": 46, "title": "Implementation & Testing"}, {"id": "Check", "x": 287, "y": 868, "w": 121, "h": 62, "title": ["/smart-review", "Quality Check"]}, {"id": "Commit", "x": 273, "y": 1008, "w": 149, "h": 62, "title": ["/semantic-commit", "Commit by Purpose"]}, {"id": "PR", "x": 259, "y": 1148, "w": 177, "h": 62, "title": ["/pr-create", "Automatic PR Creation"]}, {"id": "CI", "x": 276, "y": 1288, "w": 142, "h": 62, "title": ["/check-github-ci", "CI Status Check"]}, {"id": "Status", "x": 278, "y": 1428, "w": 138, "h": 52, "title": "Any Issues?"}, {"id": "Feedback", "x": 444, "y": 1572, "w": 120, "h": 78, "title": ["Fix Response", "/pr-feedback", "/fix-error"]}, {"id": "End", "x": 269, "y": 1588, "w": 120, "h": 46, "title": "Completion"}], "edges": [{"src": "Start", "dst": "PRList", "kind": "data", "curve": [[383, 70], [325, 109], [325, 109], [325, 148]]}, {"src": "Start", "dst": "PRIssue", "kind": "data", "curve": [[450, 70], [508, 109], [508, 109], [508, 148]]}, {"src": "PRList", "dst": "TaskType", "kind": "data", "curve": [[325, 210], [325, 249], [325, 249], [380, 288]]}, {"src": "PRIssue", "dst": "TaskType", "kind": "data", "curve": [[508, 210], [508, 249], [508, 249], [453, 288]]}, {"src": "TaskType", "dst": "Plan", "kind": "data", "label": "New Feature", "curve": [[348, 331], [127, 386], [127, 386], [127, 432]], "off": "50%"}, {"src": "TaskType", "dst": "Fix", "kind": "data", "label": "Bug Fix", "curve": [[384, 340], [327, 386], [327, 549], [327, 596]], "off": "50%"}, {"src": "TaskType", "dst": "Refactor", "kind": "data", "label": "Refactoring", "curve": [[449, 340], [506, 386], [506, 549], [506, 596]], "off": "50%"}, {"src": "TaskType", "dst": "Review", "kind": "data", "label": "Review", "curve": [[486, 333], [681, 386], [681, 549], [681, 596]], "off": "50%"}, {"src": "Plan", "dst": "Design", "kind": "data", "line": [127, 510, 127, 588]}, {"src": "Design", "dst": "Implementation", "kind": "data", "curve": [[127, 666], [127, 705], [127, 705], [318, 746]]}, {"src": "Fix", "dst": "Implementation", "kind": "data", "curve": [[327, 658], [327, 705], [327, 705], [383, 744]]}, {"src": "Refactor", "dst": "Implementation", "kind": "data", "curve": [[506, 658], [506, 705], [506, 705], [450, 744]]}, {"src": "Review", "dst": "Implementation", "kind": "data", "curve": [[681, 658], [681, 705], [681, 705], [515, 744]]}, {"src": "Implementation", "dst": "Check", "kind": "data", "curve": [[391, 790], [347, 829], [347, 829], [347, 868]]}, {"src": "Check", "dst": "Commit", "kind": "data", "line": [347, 930, 347, 1008]}, {"src": "Commit", "dst": "PR", "kind": "data", "line": [347, 1070, 347, 1148]}, {"src": "PR", "dst": "CI", "kind": "data", "line": [347, 1210, 347, 1288]}, {"src": "CI", "dst": "Status", "kind": "data", "line": [347, 1350, 347, 1428]}, {"src": "Status", "dst": "Feedback", "kind": "data", "label": "Yes", "curve": [[379, 1480], [435, 1526], [435, 1526], [472, 1572]], "off": "50%"}, {"src": "Status", "dst": "End", "kind": "data", "label": "No", "curve": [[341, 1480], [329, 1526], [329, 1526], [329, 1588]], "off": "50%"}, {"src": "Feedback", "dst": "Implementation", "kind": "data", "curve": [[511, 1572], [519, 1319], [519, 1039], [454, 790]]}]});
    const ensureD3 = (cb) => {
      if (window.d3 && typeof window.d3.select === 'function') return cb();
      let s = document.getElementById('d3-cdn-script');
      if (!s) {
        s = document.createElement('script');
        s.id = 'd3-cdn-script';
        s.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
        document.head.appendChild(s);
      }
      const onReady = () => { if (window.d3 && typeof window.d3.select === 'function') cb(); };
      s.addEventListener('load', onReady, { once: true });
      if (window.d3) onReady();
    };

    const bootstrap = () => {
      const container = document.getElementById('ensivedevelopmentguideen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ensivedevelopmentguideen-1';
        const NODES = SPEC.nodes || [];
        const EDGES = SPEC.edges || [];
        const GROUPS = SPEC.groups || [];
        const HOP = SPEC.hop || 800;
        const legendCfg = SPEC.legend || {};
        const dataLabel = legendCfg.data || 'Data path';
        const eventLabel = legendCfg.event || 'Event side-channel';

        const byId = Object.fromEntries(NODES.map((n) => [n.id, n]));
        const cx = (n) => n.x + n.w / 2;
        const asTitle = (t) => Array.isArray(t) ? t : [t];

        // Canvas: explicit, else auto from node/group extents + padding
        let W = SPEC.width, H = SPEC.height;
        if (!W || !H) {
          const xs = [], ys = [];
          NODES.forEach((n) => { xs.push(n.x + n.w); ys.push(n.y + n.h); });
          GROUPS.forEach((g) => { xs.push(g.x + g.w); ys.push(g.y + g.h); });
          W = W || Math.max(760, Math.ceil(Math.max(...xs, 0) + 24));
          H = H || Math.ceil(Math.max(...ys, 0) + 20);
        }

        // Tooltip
        container.style.position = container.style.position || 'relative';
        const tip = document.createElement('div');
        Object.assign(tip.style, {
          position: 'absolute', top: '0px', left: '0px',
          transform: 'translate(-9999px, -9999px)', pointerEvents: 'none',
          padding: '8px 10px', borderRadius: '8px', fontSize: '12px', lineHeight: '1.4',
          border: '1px solid var(--border-color)', background: 'var(--surface-bg)',
          color: 'var(--text-color)', boxShadow: '0 4px 24px rgba(0,0,0,.18)',
          opacity: '0', transition: 'opacity .12s ease', maxWidth: '260px', zIndex: '3'
        });
        const tipInner = document.createElement('div');
        tip.appendChild(tipInner);

        const scroll = document.createElement('div');
        scroll.className = 'diagram-scroll';
        container.appendChild(scroll);

        const svg = d3.select(scroll).append('svg')
          .attr('viewBox', `0 0 ${W} ${H}`)
          .attr('preserveAspectRatio', 'xMidYMid meet')
          .attr('role', 'img')
          .attr('aria-label', SPEC.ariaLabel || SPEC.title || 'Architecture diagram');
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
        svg.style('max-width', W + 'px').style('min-width', Math.min(W, 760) + 'px').style('margin', '0 auto');

        const defs = svg.append('defs');
        const mkMarker = (id, color) => {
          defs.append('marker')
            .attr('id', id).attr('viewBox', '0 0 10 10')
            .attr('refX', 9).attr('refY', 5)
            .attr('markerWidth', 6.5).attr('markerHeight', 6.5)
            .attr('orient', 'auto-start-reverse')
            .append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z').style('fill', color);
        };
        mkMarker(`${uid}-arrow-data`, 'var(--primary-color)');
        mkMarker(`${uid}-arrow-event`, 'var(--muted-color)');

        // Groups
        const groups = svg.append('g');
        GROUPS.forEach((gr) => {
          const g = groups.append('g').attr('class', 'group');
          g.append('rect').attr('x', gr.x).attr('y', gr.y).attr('width', gr.w).attr('height', gr.h).attr('rx', 12);
          if (gr.label) g.append('text').attr('x', gr.lx != null ? gr.lx : gr.x + 12).attr('y', gr.ly != null ? gr.ly : gr.y + 18).text(gr.label);
        });

        // Edges (under nodes)
        const edgeLayer = svg.append('g');
        const curvePath = (p) => `M ${p[0][0]} ${p[0][1]} C ${p[1][0]} ${p[1][1]}, ${p[2][0]} ${p[2][1]}, ${p[3][0]} ${p[3][1]}`;
        EDGES.forEach((e, i) => {
          const kind = e.kind === 'event' ? 'event' : 'data';
          const g = edgeLayer.append('g').attr('class', `edge ${kind}`).attr('data-src', e.src).attr('data-dst', e.dst);
          const marker = `url(#${uid}-arrow-${kind})`;
          if (e.line) {
            const [x1, y1, x2, y2] = e.line;
            e.pathEl = g.append('path').attr('class', 'main').attr('d', `M ${x1} ${y1} L ${x2} ${y2}`).attr('marker-end', marker).node();
            if (e.label) g.append('text').attr('x', e.lx != null ? e.lx : (x1 + x2) / 2).attr('y', e.ly != null ? e.ly : (y1 + y2) / 2 - 6).attr('text-anchor', e.anchor || 'middle').text(e.label);
          } else if (e.curve) {
            e.pathEl = g.append('path').attr('class', 'main').attr('d', curvePath(e.curve)).attr('marker-end', marker).node();
            if (e.label && e.off) {
              const p = e.curve;
              const lp = p[3][0] < p[0][0] ? [p[3], p[2], p[1], p[0]] : p;
              const lpId = `${uid}-lbl-${i}`;
              g.append('path').attr('id', lpId).attr('d', curvePath(lp)).attr('fill', 'none').attr('stroke', 'none');
              g.append('text').attr('dy', -5).append('textPath').attr('href', `#${lpId}`).attr('startOffset', e.off).attr('text-anchor', 'middle').text(e.label);
            } else if (e.label) {
              g.append('text').attr('x', e.lx).attr('y', e.ly).attr('text-anchor', e.anchor || 'start').text(e.label);
            }
          }
        });

        // Nodes (over edges)
        const nodeLayer = svg.append('g');
        NODES.forEach((n) => {
          const g = nodeLayer.append('g').attr('class', 'node').attr('data-id', n.id);
          g.append('rect').attr('x', n.x).attr('y', n.y).attr('width', n.w).attr('height', n.h).attr('rx', 9);
          const title = asTitle(n.title);
          const lines = title.length;
          const baseY = n.y + n.h / 2 - (lines - 1) * 7 - (n.sub ? 5 : -4);
          title.forEach((t, li) => {
            g.append('text').attr('class', 'node-title').attr('x', cx(n)).attr('y', baseY + li * 14).attr('text-anchor', 'middle').text(t);
          });
          if (n.sub) g.append('text').attr('class', 'node-sub').attr('x', cx(n)).attr('y', baseY + (lines - 1) * 14 + 15).attr('text-anchor', 'middle').text(n.sub);
        });

        // Hover highlighting
        const edgeSel = svg.selectAll('.edge');
        const nodeSel = svg.selectAll('.node');
        nodeSel
          .on('mouseenter', function () {
            const id = this.getAttribute('data-id');
            const n = byId[id];
            container.classList.add('hovering');
            const nb = new Set([id]);
            edgeSel.classed('hl', function () {
              const hit = this.getAttribute('data-src') === id || this.getAttribute('data-dst') === id;
              if (hit) { nb.add(this.getAttribute('data-src')); nb.add(this.getAttribute('data-dst')); }
              return hit;
            });
            nodeSel.classed('hl', function () { return this.getAttribute('data-id') === id; })
                   .classed('nb', function () { return nb.has(this.getAttribute('data-id')); });
            if (n && n.desc) { tipInner.innerHTML = `<strong>${asTitle(n.title).join('')}</strong><br>${n.desc}`; tip.style.opacity = '1'; }
          })
          .on('mousemove', function (event) {
            const [mx, my] = d3.pointer(event, container);
            const flip = mx > container.clientWidth - 280;
            tip.style.transform = `translate(${flip ? mx - 270 : mx + 14}px, ${my + 14}px)`;
          })
          .on('mouseleave', function () {
            container.classList.remove('hovering');
            edgeSel.classed('hl', false);
            nodeSel.classed('hl', false).classed('nb', false);
            tip.style.opacity = '0';
            tip.style.transform = 'translate(-9999px, -9999px)';
          });

        // Flow animation sequence: explicit SEQ, else auto forward-cascade of data edges
        const resolveEdge = (s) => {
          if (typeof s.e === 'number') return s.e;
          if (s.from && s.to) return EDGES.findIndex((e) => e.src === s.from && e.dst === s.to);
          return -1;
        };
        let SEQ = (SPEC.seq || []).map((s) => ({ e: resolveEdge(s), t0: s.t0 })).filter((s) => s.e >= 0);
        if (!SEQ.length) {
          let t = 0;
          EDGES.forEach((e, i) => { if ((e.kind || 'data') === 'data') { SEQ.push({ e: i, t0: t }); t += HOP; } });
        }
        const TOTAL = SPEC.total || (Math.max(0, ...SEQ.map((s) => s.t0)) + HOP + 800);

        let playing = false, replayBtn = null;
        const pulseNode = (id) => {
          const sel = nodeSel.filter(function () { return this.getAttribute('data-id') === id; });
          sel.classed('anim-hl', true);
          setTimeout(() => sel.classed('anim-hl', false), 550);
        };
        const play = () => {
          if (playing) return;
          playing = true;
          if (replayBtn) replayBtn.disabled = true;
          const layer = svg.append('g');
          const steps = SEQ.map((s) => {
            const edge = EDGES[s.e];
            return { ...s, edge, len: edge.pathEl.getTotalLength(), dot: null, arrived: false };
          });
          const start = performance.now();
          const frame = (now) => {
            const t = now - start;
            steps.forEach((s) => {
              if (t < s.t0) return;
              const f = Math.min(1, (t - s.t0) / HOP);
              if (f >= 1) { if (s.dot) { s.dot.remove(); s.dot = null; } if (!s.arrived) { s.arrived = true; pulseNode(s.edge.dst); } return; }
              if (!s.dot) s.dot = layer.append('circle').attr('class', `flow-dot ${s.edge.kind || 'data'}`).attr('r', (s.edge.kind === 'event') ? 4 : 5);
              const p = s.edge.pathEl.getPointAtLength(d3.easeCubicInOut(f) * s.len);
              s.dot.attr('cx', p.x).attr('cy', p.y);
            });
            if (t < TOTAL) requestAnimationFrame(frame);
            else { layer.remove(); playing = false; if (replayBtn) replayBtn.disabled = false; }
          };
          requestAnimationFrame(frame);
        };

        // Legend
        const legend = document.createElement('div');
        legend.className = 'legend';
        legend.innerHTML = `
          <div class="legend-title">${SPEC.legendTitle || 'Legend'}</div>
          <div class="items">
            <span class="item"><span class="swatch data-line"></span><span>${dataLabel}</span></span>
            <span class="item"><span class="swatch event-line"></span><span>${eventLabel}</span></span>
            <button class="replay-btn" type="button" aria-label="Replay the flow animation">&#9654; Replay</button>
            <span class="hint">${SPEC.hint || 'Hover a component to trace its connections.'}</span>
          </div>`;
        container.appendChild(legend);
        container.appendChild(tip);
        replayBtn = legend.querySelector('.replay-btn');
        replayBtn.addEventListener('click', play);

        const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!prefersReduced && window.IntersectionObserver) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((en) => { if (en.isIntersecting) { io.disconnect(); play(); } });
          }, { threshold: 0.5 });
          io.observe(container);
        }
      } catch (err) {
        const pre = document.createElement('pre');
        pre.style.color = '#c0392b';
        pre.style.fontSize = '12px';
        pre.textContent = 'Failed to render architecture diagram: ' + (err && err.message ? err.message : err);
        container.appendChild(pre);
      }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ensureD3(bootstrap), { once: true });
    else ensureD3(bootstrap);
  })();
</script>
{% endraw %}

### Best Practices

1. **Start with Planning**: Use `/spec` for feature planning and `/show-plan` for tracking
2. **Leverage Roles**: Employ specialized roles for domain-specific analysis
3. **Automate Reviews**: Integrate `/smart-review` and `/pr-review` into your workflow
4. **Maintain Quality**: Use hooks for consistent code quality and safety
5. **Parallel Analysis**: Utilize sub-agents for comprehensive multi-perspective analysis

## Installation and Setup

### Prerequisites

- Claude Code (latest version)
- Git configured with appropriate permissions
- Node.js (for certain dependency management commands)

### Installation Steps

1. **Clone the Repository**:
```bash
git clone https://github.com/foreveryh/claude-code-cookbook.git
cd claude-code-cookbook
```

2. **Configure Claude Code**:
Add the cookbook commands to your Claude Code configuration:
```json
{
  "commands_directory": "./commands",
  "roles_directory": "./agents/roles",
  "hooks_directory": "./.claude/hooks"
}
```

3. **Set Up Hooks**:
Configure automatic hooks in your `settings.json`:
```json
{
  "hooks": {
    "PreToolUse": ["deny-check.sh", "preserve-file-permissions.sh"],
    "PostToolUse": ["auto-comment.sh", "ja-space-format.sh"],
    "Notification": ["notify-waiting"],
    "Stop": ["check-continue.sh"]
  }
}
```

### Verification

Test the installation by running:
```bash
/role-help  # Should list available roles
/pr-list    # Should show current PRs (if in a git repository)
```

## Use Cases and Examples

### 1. Comprehensive Code Review

Scenario: Reviewing a complex pull request with multiple components.

```bash
# Step 1: Get PR overview
/pr-list

# Step 2: Multi-role analysis
/multi-role security,performance,reviewer --agent
"Analyze PR #123 for security vulnerabilities, performance issues, and code quality"

# Step 3: Detailed review
/pr-review

# Step 4: Provide structured feedback
/pr-feedback
```

### 2. Feature Development Workflow

Scenario: Developing a new user authentication system.

```bash
# Step 1: Create specification
/spec
"User authentication system with OAuth integration"

# Step 2: Architecture consultation
/role-debate
"OAuth vs JWT vs session-based authentication for our use case"

# Step 3: Implementation planning
/plan

# Step 4: Track progress
/show-plan

# Step 5: Quality assurance
/role qa --agent
"Create comprehensive test strategy for authentication system"
```

### 3. Technical Debt Management

Scenario: Addressing accumulated technical debt in a legacy codebase.

```bash
# Step 1: Analyze technical debt
/tech-debt

# Step 2: Prioritize improvements
/role architect --agent
"Create prioritized technical debt reduction plan"

# Step 3: Safe refactoring
/refactor

# Step 4: Validate changes
/smart-review
```

## Advanced Configuration

### Custom Commands

You can extend the cookbook with custom commands by following the template structure:

```markdown
# Custom Command Template
## Purpose
Brief description of what the command does

## Usage
/custom-command [parameters]

## Implementation
Detailed implementation logic
```

### Environment-Specific Hooks

Configure hooks for different development environments:

```bash
# Development environment
export CLAUDE_ENV="development"

# Production safety hooks
export CLAUDE_ENV="production"
```

### Multi-Project Configuration

For teams working across multiple projects:

```json
{
  "projects": {
    "project1": {
      "commands": ["./project1-commands"],
      "roles": ["./project1-roles"]
    },
    "project2": {
      "commands": ["./project2-commands"],
      "roles": ["./project2-roles"]
    }
  }
}
```

## Performance and Optimization

### Command Execution Optimization

1. **Parallel Execution**: Use sub-agents for independent analysis
2. **Context Management**: Maintain appropriate context scope for commands
3. **Caching**: Leverage Claude Code's built-in caching for repeated operations

### Memory and Resource Management

- **Token Optimization**: Commands are designed to use tokens efficiently
- **Context Preservation**: Hooks maintain context across operations
- **Resource Cleanup**: Automatic cleanup of temporary resources

## Troubleshooting

### Common Issues

1. **Command Not Found**: Ensure proper installation and configuration
2. **Permission Errors**: Check file permissions and Git configuration
3. **Hook Failures**: Verify hook scripts have execute permissions

### Debug Mode

Enable debug mode for detailed execution information:
```bash
export CLAUDE_DEBUG=true
```

### Community Support

- **GitHub Issues**: Report bugs and feature requests
- **Documentation**: Comprehensive docs available in the repository
- **Community**: Active community for support and contributions

## Security Considerations

### Safe Command Execution

The cookbook includes several security features:

- **Command Validation**: `deny-check.sh` prevents dangerous operations
- **Permission Preservation**: Maintains original file permissions
- **Audit Trail**: Comprehensive logging of all operations

### Best Practices

1. **Review Commands**: Always review generated commands before execution
2. **Use Hooks**: Implement safety hooks for your environment
3. **Access Control**: Configure appropriate access controls for team usage
4. **Regular Updates**: Keep the cookbook updated for security patches

## Future Developments

### Roadmap

The Claude Code Cookbook continues to evolve with:

- **New Commands**: Regular addition of community-requested commands
- **Enhanced Roles**: More specialized expert roles
- **Integration Improvements**: Better IDE and platform integrations
- **Performance Optimizations**: Continued optimization for speed and efficiency

### Community Contributions

The project welcomes contributions:

- **Command Development**: Create new commands for specific use cases
- **Role Enhancement**: Develop specialized expert roles
- **Documentation**: Improve and translate documentation
- **Bug Fixes**: Address issues and improve stability

## Conclusion

The Claude Code Cookbook represents a significant advancement in AI-powered development tools. By providing structured, reliable patterns for common development tasks, it enables developers to harness the full power of AI while maintaining code quality and development best practices.

Whether you're a solo developer looking to enhance productivity or a team seeking to standardize AI-assisted development practices, the cookbook provides the tools and patterns necessary for success. Its comprehensive command set, expert roles, and automation hooks create a development environment where AI augments human expertise rather than replacing it.

The future of software development lies in the intelligent collaboration between human creativity and AI capabilities. Claude Code Cookbook provides the framework for this collaboration, ensuring that AI assistance is not just powerful, but also reliable, safe, and aligned with software engineering best practices.

Start exploring the cookbook today, and transform your development workflow with the power of structured AI assistance. The investment in learning these patterns will pay dividends in increased productivity, improved code quality, and enhanced collaboration across your development team.

---

*Ready to revolutionize your development workflow? Clone the [Claude Code Cookbook](https://github.com/foreveryh/claude-code-cookbook) and start experiencing the future of AI-powered development today.*
