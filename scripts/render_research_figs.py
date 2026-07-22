#!/usr/bin/env python3
"""Re-render the 5 missing research figures from the numbers/concepts stated in
the posts (nightly-paper generation had failed to emit them). Data figures use
the exact values quoted in the prose; conceptual figures match the captions
(which already state they are conceptual/illustrative). ThakiCloud brand palette.
"""
import os
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch
import numpy as np

NAVY = "#1B4F72"
SLATE = "#2E4057"
TEAL = "#17A2B8"
AMBER = "#E67E22"
GREEN = "#27AE60"
RED = "#C0392B"
GRID = "#D5DBDB"

plt.rcParams.update({
    "font.family": "DejaVu Sans",
    "font.size": 12,
    "axes.edgecolor": SLATE,
    "axes.labelcolor": SLATE,
    "text.color": SLATE,
    "xtick.color": SLATE,
    "ytick.color": SLATE,
    "figure.dpi": 150,
})

BASE = "assets/images/posts/research"
D1 = f"{BASE}/agent-dynamic-batch-tuning-vllm"
D2 = f"{BASE}/nvfp4-moe-selective-quant"
for d in (D1, D2):
    os.makedirs(d, exist_ok=True)


def save(fig, path):
    fig.savefig(path, bbox_inches="tight", facecolor="white")
    plt.close(fig)
    print("wrote", path)


# ---------- 1. Control loop architecture (conceptual) ----------
def fig_control_loop():
    fig, ax = plt.subplots(figsize=(10.5, 4.6))
    ax.set_xlim(0, 13); ax.set_ylim(0, 5); ax.axis("off")
    W, H, Y = 2.4, 1.2, 2.6
    xs = [0.4, 3.6, 6.8, 10.0]
    boxes = [
        (xs[0], "LLM Agent\n(observe)", NAVY),
        (xs[1], "Bounded\nconcurrency Δ", TEAL),
        (xs[2], "Per-tenant\nadmission", SLATE),
        (xs[3], "vLLM\nengine", AMBER),
    ]
    for x, label, c in boxes:
        ax.add_patch(FancyBboxPatch((x, Y), W, H, boxstyle="round,pad=0.08,rounding_size=0.12",
                                    linewidth=0, facecolor=c))
        ax.text(x + W/2, Y + H/2, label, ha="center", va="center", color="white",
                fontsize=11, fontweight="bold")
    for i in range(3):
        x0 = xs[i] + W
        ax.add_patch(FancyArrowPatch((x0, Y + H/2), (xs[i+1], Y + H/2), arrowstyle="-|>",
                                     mutation_scale=20, color=SLATE, linewidth=2))
    # feedback loop routed clearly BELOW the boxes
    start = (xs[3] + W/2, Y)
    end = (xs[0] + W/2, Y)
    ax.add_patch(FancyArrowPatch(start, end, arrowstyle="-|>", mutation_scale=20,
                                 color=GREEN, linewidth=2.2, connectionstyle="arc3,rad=0.42"))
    ax.text(6.5, 0.55, "feedback: GPU telemetry · per-tenant queue depth · p50/p95/p99 latency",
            ha="center", color=GREEN, fontsize=10.5, style="italic")
    ax.set_title("Control Loop: Agent-Driven Batch Tuning Architecture",
                 color=NAVY, fontsize=13, fontweight="bold", pad=8)
    save(fig, f"{D1}/fig-control-loop.png")


# ---------- 2. Throughput vs dropped requests by policy (data) ----------
def fig_throughput_dropped():
    policies = ["Static\n(cap=4)", "Naive\nDynamic", "Differentiated\nAgent"]
    thr = [0.686, 0.515, 0.601]
    drops = [1.9, 309.5, 154.7]
    x = np.arange(3)
    fig, (a1, a2) = plt.subplots(1, 2, figsize=(9.5, 4.2))
    b1 = a1.bar(x, thr, color=[GREEN, RED, AMBER], width=0.6)
    a1.set_title("Throughput (req/s)", color=NAVY, fontweight="bold")
    a1.set_xticks(x); a1.set_xticklabels(policies, fontsize=9)
    a1.set_ylim(0, 0.8); a1.yaxis.grid(True, color=GRID); a1.set_axisbelow(True)
    for r, v in zip(b1, thr):
        a1.text(r.get_x()+r.get_width()/2, v+0.02, f"{v:.3f}", ha="center", fontsize=10, fontweight="bold")
    b2 = a2.bar(x, drops, color=[GREEN, RED, AMBER], width=0.6)
    a2.set_title("Dropped requests (avg, log scale)", color=NAVY, fontweight="bold")
    a2.set_xticks(x); a2.set_xticklabels(policies, fontsize=9)
    a2.set_yscale("log"); a2.set_ylim(1, 1000); a2.yaxis.grid(True, color=GRID); a2.set_axisbelow(True)
    for r, v in zip(b2, drops):
        a2.text(r.get_x()+r.get_width()/2, v*1.15, f"{v:g}", ha="center", fontsize=10, fontweight="bold")
    fig.suptitle("Throughput vs. Dropped Requests by Policy  (20-seed queuing simulation)",
                 color=SLATE, fontsize=12, fontweight="bold", y=1.02)
    save(fig, f"{D1}/fig-throughput-dropped.png")


# ---------- 3. p99 latency by policy (data) ----------
def fig_p99_latency():
    policies = ["Static\n(cap=4)", "Naive\nDynamic", "Differentiated\nAgent"]
    p99 = [11.75, 12.79, 13.25]
    fig, ax = plt.subplots(figsize=(7.5, 4.2))
    bars = ax.bar(policies, p99, color=[GREEN, RED, AMBER], width=0.55)
    ax.axhline(11.5, color=SLATE, linestyle="--", linewidth=1.5)
    ax.text(2.4, 11.5, "intrinsic p99 ≈ 11.5s\n(service-time variance)", color=SLATE,
            fontsize=9, va="bottom", ha="right", style="italic")
    ax.set_ylabel("p99 latency (s)"); ax.set_ylim(0, 15)
    ax.yaxis.grid(True, color=GRID); ax.set_axisbelow(True)
    for r, v in zip(bars, p99):
        ax.text(r.get_x()+r.get_width()/2, v+0.2, f"{v:.2f}s", ha="center", fontsize=10, fontweight="bold")
    ax.set_title("p99 Latency by Policy  (simulation, 20 seeds)", color=NAVY, fontweight="bold", pad=10)
    save(fig, f"{D1}/fig-p99-latency.png")


# ---------- 4. MoE expert traffic distribution + median split (conceptual) ----------
def fig_expert_traffic():
    n = 16
    rank = np.arange(n)
    # conceptual heavy-tailed sorted traffic
    traffic = np.exp(-rank / 4.0)
    traffic = traffic / traffic.sum()
    colors = [TEAL if i < n/2 else SLATE for i in range(n)]
    fig, ax = plt.subplots(figsize=(9, 4.2))
    ax.bar(rank, traffic, color=colors, width=0.8)
    ax.axvline(n/2 - 0.5, color=AMBER, linestyle="--", linewidth=2)
    ax.text(n/2 - 0.6, traffic.max()*0.9, "per-layer median split", color=AMBER, fontsize=10,
            ha="right", fontweight="bold")
    ax.text(2.5, traffic.max()*0.55, "high-traffic experts\n→ NVFP4 (4-bit)", color=TEAL,
            fontsize=10, ha="center", fontweight="bold")
    ax.text(11.5, traffic.max()*0.25, "low-traffic 'rare' experts\n→ kept full precision (16-bit)",
            color=SLATE, fontsize=10, ha="center", fontweight="bold")
    ax.set_xlabel("Experts ranked by normalized traffic")
    ax.set_ylabel("Share of streamed traffic")
    ax.set_xticks([]); ax.yaxis.grid(True, color=GRID); ax.set_axisbelow(True)
    ax.set_title("MoE Expert Traffic Distribution & RASQ Precision Allocation  (conceptual, Switch-Base-8)",
                 color=NAVY, fontsize=11.5, fontweight="bold", pad=10)
    save(fig, f"{D2}/fig-expert-traffic-distribution.png")


# ---------- 5. Storage-cost breakdown: Uniform vs RASQ (conceptual) ----------
def fig_cost_model():
    cats = ["Router\nlinear", "High-traffic\nexperts", "Rare\nexperts"]
    # conceptual per-category storage bits (illustrative units)
    uniform = [4, 4, 4]      # uniform NVFP4: everything to 4-bit
    rasq = [16, 4, 16]       # RASQ: router 16, high-traffic 4, rare 16
    x = np.arange(3); w = 0.36
    fig, ax = plt.subplots(figsize=(8.2, 4.4))
    b1 = ax.bar(x - w/2, uniform, w, label="Uniform NVFP4", color=SLATE)
    b2 = ax.bar(x + w/2, rasq, w, label="RASQ (router-aware selective)", color=TEAL)
    for bars in (b1, b2):
        for r in bars:
            ax.text(r.get_x()+r.get_width()/2, r.get_height()+0.3, f"{int(r.get_height())}-bit",
                    ha="center", fontsize=9, fontweight="bold")
    ax.set_ylabel("Weight precision / storage bits (per category)")
    ax.set_xticks(x); ax.set_xticklabels(cats)
    ax.set_ylim(0, 19); ax.legend(frameon=False, loc="upper center")
    ax.yaxis.grid(True, color=GRID); ax.set_axisbelow(True)
    ax.set_title("Storage-Cost Breakdown: Uniform NVFP4 vs. RASQ  (conceptual, cost model)",
                 color=NAVY, fontsize=11.5, fontweight="bold", pad=10)
    save(fig, f"{D2}/fig-cost-model-comparison.png")


if __name__ == "__main__":
    fig_control_loop()
    fig_throughput_dropped()
    fig_p99_latency()
    fig_expert_traffic()
    fig_cost_model()
    print("done")
