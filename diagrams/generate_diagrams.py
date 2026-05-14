"""Generate marketing diagrams for the GOPAL README.

Run from repo root:
    python diagrams/generate_diagrams.py

Outputs 5 PNGs (1600x900) into diagrams/.
"""

from __future__ import annotations

import os
from pathlib import Path

import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from matplotlib.patches import FancyBboxPatch, FancyArrowPatch, Rectangle
from matplotlib.lines import Line2D

# --- Palette ----------------------------------------------------------------
PURPLE = "#7D4698"
BLUE = "#1971c2"
GREEN = "#2f9e44"
ORANGE = "#e8590c"
TEXT = "#495057"
LIGHT_BG = "#dee2e6"
WHITE = "#ffffff"
CODE_BG = "#f1f3f5"
CODE_BORDER = "#ced4da"

# Figure dimensions: 1600x900 at dpi=100 -> figsize = (16, 9)
FIGSIZE = (16, 9)
DPI = 100

OUT_DIR = Path(__file__).parent


# --- Helpers ----------------------------------------------------------------
def new_canvas():
    """Create a 16:9 white canvas with a 0-1600 x 0-900 coord system."""
    fig, ax = plt.subplots(figsize=FIGSIZE, dpi=DPI)
    ax.set_xlim(0, 1600)
    ax.set_ylim(0, 900)
    ax.set_aspect("equal")
    ax.set_facecolor(WHITE)
    fig.patch.set_facecolor(WHITE)
    ax.axis("off")
    return fig, ax


def save(fig, name: str):
    out = OUT_DIR / name
    fig.savefig(
        out,
        dpi=DPI,
        bbox_inches="tight",
        facecolor=WHITE,
        edgecolor="none",
        pad_inches=0.15,
    )
    plt.close(fig)
    size_kb = out.stat().st_size / 1024
    print(f"  -> {name}  ({size_kb:,.1f} KB)")
    return out


def draw_title(ax, text: str, y: float = 830, fontsize: int = 32, color: str = TEXT):
    ax.text(
        800, y, text,
        ha="center", va="center",
        fontsize=fontsize, fontweight="bold", color=color,
        family="DejaVu Sans",
    )


def draw_subtitle(ax, text: str, y: float = 790, fontsize: int = 18, color: str = TEXT):
    ax.text(
        800, y, text,
        ha="center", va="center",
        fontsize=fontsize, color=color,
        family="DejaVu Sans",
    )


def rounded_box(ax, x, y, w, h, *, facecolor, edgecolor=None, lw=1.5, radius=0.025, zorder=2):
    """Draw a rounded rectangle. (x, y) is bottom-left."""
    box = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0,rounding_size={radius * min(w, h) * 8}",
        facecolor=facecolor,
        edgecolor=edgecolor if edgecolor else facecolor,
        linewidth=lw,
        zorder=zorder,
    )
    ax.add_patch(box)
    return box


def card(ax, x, y, w, h, *, fill=PURPLE, edge=None, radius=14):
    """Simpler rounded card with absolute corner radius."""
    box = FancyBboxPatch(
        (x, y), w, h,
        boxstyle=f"round,pad=0,rounding_size={radius}",
        facecolor=fill,
        edgecolor=edge if edge else fill,
        linewidth=1.5,
        zorder=2,
    )
    ax.add_patch(box)
    return box


def text(ax, x, y, s, *, size=18, color=TEXT, weight="normal", ha="center", va="center", family="DejaVu Sans"):
    ax.text(x, y, s, fontsize=size, color=color, fontweight=weight, ha=ha, va=va, family=family, zorder=5)


def arrow(ax, x1, y1, x2, y2, *, color=TEXT, lw=2.0, style="-|>", mutation=20):
    a = FancyArrowPatch(
        (x1, y1), (x2, y2),
        arrowstyle=style,
        mutation_scale=mutation,
        linewidth=lw,
        color=color,
        zorder=4,
    )
    ax.add_patch(a)


# === Diagram 1: Hero Numbers ================================================
def diagram1_hero_numbers():
    fig, ax = new_canvas()

    draw_title(ax, "GOPAL — the Rego policy library for AI compliance",
               y=830, fontsize=30)
    draw_subtitle(ax, "Policy-as-code your auditor can read",
                  y=780, fontsize=20, color=PURPLE)

    # Three big number cards
    cards = [
        ("94", "Production", "Policies"),
        ("15+", "Regulatory", "Frameworks"),
        ("5", "Industry", "Verticals"),
    ]
    card_w, card_h = 460, 400
    gap = 40
    total_w = 3 * card_w + 2 * gap
    start_x = (1600 - total_w) / 2
    y0 = 300

    for i, (num, label1, label2) in enumerate(cards):
        x = start_x + i * (card_w + gap)
        # Outer card
        card(ax, x, y0, card_w, card_h, fill=PURPLE, radius=24)
        # Big number
        text(ax, x + card_w / 2, y0 + card_h / 2 + 50, num,
             size=140, weight="bold", color=WHITE)
        # Divider
        ax.plot([x + 80, x + card_w - 80], [y0 + 110, y0 + 110],
                color="#a577c0", lw=1.5, zorder=4)
        # Label (two lines)
        text(ax, x + card_w / 2, y0 + 75, label1,
             size=22, weight="bold", color=WHITE)
        text(ax, x + card_w / 2, y0 + 40, label2,
             size=22, weight="bold", color=WHITE)

    # Verticals strip
    text(ax, 800, 240,
         "Aviation  ·  Education  ·  Healthcare  ·  BFS  ·  Automotive",
         size=22, weight="bold", color=BLUE)

    # Footer pill
    footer = "Apache 2.0   ·   OPA-native   ·   Versioned (v1, v2, …)"
    pill_w, pill_h = 880, 64
    px = (1600 - pill_w) / 2
    py = 120
    card(ax, px, py, pill_w, pill_h, fill=LIGHT_BG, radius=32)
    text(ax, 800, py + pill_h / 2, footer, size=20, weight="bold", color=TEXT)

    save(fig, "diagram1_hero_numbers.png")


# === Diagram 2: Directory Tree ==============================================
def diagram2_directory_tree():
    fig, ax = new_canvas()

    draw_title(ax, "What's inside", y=850, fontsize=34)
    draw_subtitle(ax, "94 production policies, organized by jurisdiction and vertical",
                  y=805, fontsize=18)

    # Root box
    root_x, root_y, root_w, root_h = 700, 720, 200, 56
    card(ax, root_x, root_y, root_w, root_h, fill=TEXT, radius=10)
    text(ax, root_x + root_w / 2, root_y + root_h / 2, "gopal/",
         size=22, weight="bold", color=WHITE)

    # 5 branch group headers
    branches = [
        # (label, color, x_center, [leaves])
        ("international/", PURPLE, 175,
         [("eu_ai_act/v1", "29"),
          ("nist/v1", "5"),
          ("india/v1", "1"),
          ("brazil/v1", "1"),
          ("icao/faa/easa", "5"),
          ("standards/v1", "4")]),
        ("industry/", BLUE, 500,
         [("aviation/v1", "17"),
          ("education/v1", "12"),
          ("healthcare/v1", "2"),
          ("bfs/v1", "2"),
          ("automotive/v1", "1")]),
        ("global/v1", GREEN, 820,
         [("accountability", ""),
          ("fairness", ""),
          ("transparency", ""),
          ("explainability", ""),
          ("content_safety", "9")]),
        ("operational/", ORANGE, 1140,
         [("aiops/v1", "1"),
          ("cost/v1", "1"),
          ("corporate/v1", "2")]),
        ("helpers/", TEXT, 1420,
         [("reporting.rego", ""),
          ("validation.rego", "")]),
    ]

    # Branch headers (under root)
    branch_y = 605
    branch_h = 52
    branch_w = 280

    for label, color, cx, leaves in branches:
        # Branch header card
        bx = cx - branch_w / 2
        card(ax, bx, branch_y, branch_w, branch_h, fill=color, radius=10)
        text(ax, cx, branch_y + branch_h / 2, label,
             size=16, weight="bold", color=WHITE)

        # Line from root to branch header
        root_cx = root_x + root_w / 2
        root_bottom = root_y
        # Trunk drops to a horizontal bus
        bus_y = 690
        ax.plot([root_cx, root_cx], [root_bottom, bus_y], color=TEXT, lw=1.5, zorder=1)
        ax.plot([root_cx, cx], [bus_y, bus_y], color=TEXT, lw=1.5, zorder=1)
        ax.plot([cx, cx], [bus_y, branch_y + branch_h], color=color, lw=2.0, zorder=1)

        # Leaves
        leaf_w = 280
        leaf_h = 44
        leaf_gap = 12
        leaf_x = cx - leaf_w / 2
        for i, (lbl, count) in enumerate(leaves):
            ly = branch_y - 30 - i * (leaf_h + leaf_gap)
            card(ax, leaf_x, ly, leaf_w, leaf_h, fill=WHITE, edge=color, radius=8)
            # Left coloured stripe
            stripe = Rectangle((leaf_x, ly), 6, leaf_h, facecolor=color, edgecolor=color, zorder=3)
            ax.add_patch(stripe)

            if count:
                # label left, count right (in colored pill)
                # Use smaller font and shift label slightly left to avoid pill overlap
                text(ax, leaf_x + 18, ly + leaf_h / 2, lbl, size=13, color=TEXT,
                     ha="left", weight="bold")
                # count pill
                pill_w = 42
                px = leaf_x + leaf_w - pill_w - 8
                py = ly + (leaf_h - 26) / 2
                card(ax, px, py, pill_w, 26, fill=color, radius=8)
                text(ax, px + pill_w / 2, py + 13, count, size=14, color=WHITE, weight="bold")
            else:
                text(ax, leaf_x + 18, ly + leaf_h / 2, lbl, size=13, color=TEXT,
                     ha="left")

            # connecting tick from branch
            ax.plot([cx, cx], [branch_y, ly + leaf_h / 2], color=color, lw=1.2,
                    alpha=0.35, zorder=0)

    # Legend at bottom
    legend_y = 60
    legend_items = [
        ("International", PURPLE),
        ("Industry", BLUE),
        ("Global", GREEN),
        ("Operational", ORANGE),
        ("Helpers", TEXT),
    ]
    total = len(legend_items)
    spacing = 240
    start = 800 - (total - 1) * spacing / 2
    for i, (lbl, col) in enumerate(legend_items):
        x = start + i * spacing
        # swatch
        sw = Rectangle((x - 80, legend_y), 18, 18, facecolor=col, edgecolor=col, zorder=3)
        ax.add_patch(sw)
        text(ax, x - 55, legend_y + 9, lbl, size=15, color=TEXT, ha="left", weight="bold")

    save(fig, "diagram2_directory_tree.png")


# === Diagram 3: Policy Anatomy ==============================================
def diagram3_policy_anatomy():
    fig, ax = new_canvas()

    draw_title(ax, "Anatomy of a GOPAL policy", y=840, fontsize=34)
    draw_subtitle(ax, "Every rule is a small, readable Rego file", y=795, fontsize=18)

    # Code block background
    code_x, code_y, code_w, code_h = 70, 130, 820, 600
    rounded_box(ax, code_x, code_y, code_w, code_h, facecolor=CODE_BG,
                edgecolor=CODE_BORDER, lw=1.5, radius=0.04)

    # Window dots (terminal/editor chrome)
    for i, c in enumerate(["#ff5f57", "#febc2e", "#28c840"]):
        circ = mpatches.Circle((code_x + 26 + i * 22, code_y + code_h - 22), 8,
                               facecolor=c, edgecolor=c, zorder=4)
        ax.add_patch(circ)
    text(ax, code_x + code_w / 2, code_y + code_h - 22,
         "transparency.rego", size=14, color=TEXT, family="DejaVu Sans Mono")

    # Header bar separator
    ax.plot([code_x, code_x + code_w],
            [code_y + code_h - 44, code_y + code_h - 44],
            color=CODE_BORDER, lw=1.2)

    # Code lines with anchor points (x_anchor at right side of code box for callouts)
    # Each: (text, color, y, has_callout)
    code_lines = [
        ("package international.eu_ai_act.v1.transparency", PURPLE, 640, True),
        ("", TEXT, 615, False),
        ("import data.helper_functions.reporting", BLUE, 590, True),
        ("", TEXT, 565, False),
        ("# METADATA", "#868e96", 540, True),
        ("# title: GPAI transparency obligations", "#868e96", 515, False),
        ("# source: https://eur-lex.europa.eu/...", "#868e96", 490, False),
        ("", TEXT, 465, False),
        ("default allow := false", ORANGE, 440, True),
        ("", TEXT, 415, False),
        ("allow if {", GREEN, 390, True),
        ("    input.system.documentation_published == true", TEXT, 365, False),
        ("}", GREEN, 340, False),
        ("", TEXT, 315, False),
        ("report := reporting.compose_report(...)", BLUE, 290, True),
    ]

    code_left = code_x + 30
    for line, color, y, _ in code_lines:
        text(ax, code_left, y, line,
             size=15, color=color, ha="left",
             family="DejaVu Sans Mono",
             weight="bold" if color in (PURPLE, ORANGE, GREEN) and line else "normal")

    # Callouts on the right side
    callouts = [
        (640, "Mirrors directory path", PURPLE),
        (590, "Shared utilities", BLUE),
        (540, "Tooling + auditor metadata", "#495057"),
        (440, "Safe default — fail closed", ORANGE),
        (390, "The rule itself", GREEN),
        (290, "Uniform report shape", BLUE),
    ]

    callout_x = 980  # left edge of callout column
    callout_w = 540
    callout_h = 56

    for y, msg, col in callouts:
        cy = y - callout_h / 2
        # Callout pill
        card(ax, callout_x, cy, callout_w, callout_h, fill=WHITE, edge=col, radius=14)
        # Left stripe
        stripe = Rectangle((callout_x, cy), 6, callout_h, facecolor=col, edgecolor=col, zorder=3)
        ax.add_patch(stripe)
        text(ax, callout_x + 22, cy + callout_h / 2, msg,
             size=17, weight="bold", color=col, ha="left")

        # Arrow from code line to callout
        arrow(ax, code_x + code_w - 10, y, callout_x - 4, y,
              color=col, lw=1.8, mutation=14)

    # Footer caption
    text(ax, 800, 80,
         "package path = directory path  ·  default deny  ·  compose_report() everywhere",
         size=18, weight="bold", color=TEXT)

    save(fig, "diagram3_policy_anatomy.png")


# === Diagram 4: Framework Grid ==============================================
def diagram4_framework_grid():
    fig, ax = new_canvas()

    draw_title(ax, "Frameworks covered", y=850, fontsize=34)
    draw_subtitle(ax, "15+ named regulations across 5 verticals — every rule open and readable",
                  y=807, fontsize=17)

    rows = [
        ("INTERNATIONAL", [("EU AI Act", "29"), ("NIST AI RMF", "5"),
                            ("India DPDP", "1"), ("Brazil AI", "1")]),
        ("AVIATION SAFETY", [("RTCA DO-365", "1"), ("RTCA DO-366", "1"),
                              ("FAA Part 107", "1"), ("EASA SORA", "1")]),
        ("INDUSTRY", [("Aviation", "17"), ("Education", "12"),
                       ("Healthcare", "2"), ("BFS", "2")]),
        ("CROSS-CUTTING", [("Global", "9"), ("AIOps", "1"),
                            ("Corporate", "2"), ("Automotive", "1")]),
    ]

    # Grid layout
    n_cols = 4
    cell_w = 290
    cell_h = 115
    gap_x = 24
    gap_y = 28

    total_grid_w = n_cols * cell_w + (n_cols - 1) * gap_x
    # Reserve room on the left for row labels
    label_col_w = 175
    grid_left = (1600 - total_grid_w - label_col_w) / 2 + label_col_w
    start_x = grid_left
    # Top of first row
    top_y = 640

    for r, (row_label, cells) in enumerate(rows):
        y = top_y - r * (cell_h + gap_y)

        # Row label on the left
        text(ax, start_x - 28, y + cell_h / 2, row_label,
             size=14, weight="bold", color=TEXT, ha="right", family="DejaVu Sans")

        for c, (name, count) in enumerate(cells):
            x = start_x + c * (cell_w + gap_x)
            card(ax, x, y, cell_w, cell_h, fill=PURPLE, radius=14)
            # Framework name
            text(ax, x + cell_w / 2, y + cell_h / 2 + 18,
                 name, size=21, weight="bold", color=WHITE)
            # Divider
            ax.plot([x + 60, x + cell_w - 60], [y + cell_h / 2 - 3, y + cell_h / 2 - 3],
                    color="#a577c0", lw=1.2, zorder=4)
            # Count line
            text(ax, x + cell_w / 2, y + cell_h / 2 - 24,
                 f"{count} polic{'y' if count == '1' else 'ies'}",
                 size=15, color="#e9d8f4")

    # Footer
    text(ax, 800, 90,
         "All policies in this library are Apache-2.0 and live under  /v1/  paths",
         size=18, weight="bold", color=TEXT)

    save(fig, "diagram4_framework_grid.png")


# === Diagram 5: Evaluation Flow =============================================
def diagram5_evaluation_flow():
    fig, ax = new_canvas()

    draw_title(ax, "How evaluation works", y=840, fontsize=34)
    draw_subtitle(ax, "From your AI system metadata to a structured compliance verdict",
                  y=795, fontsize=18)

    # 4 stages, horizontal flow
    stage_w = 320
    stage_h = 420
    gap = 50
    total_w = 4 * stage_w + 3 * gap
    start_x = (1600 - total_w) / 2
    y0 = 230

    stages = [
        {
            "title": "Your input.json",
            "color": BLUE,
            "lines": [
                "{",
                '  "system": {',
                '    "name":',
                '      "GPT-Risk-Bot",',
                '    "docs":',
                '      "published",',
                '    "training":',
                '      "summarized"',
                "  }",
                "}",
            ],
            "tag": "INPUT",
        },
        {
            "title": "OPA Engine",
            "color": TEXT,
            "lines": [
                "$ opa eval \\",
                "  -d international/ \\",
                "  --input sys.json \\",
                '  "data.intl.',
                '   eu_ai_act.v1.',
                '   transparency',
                '   .allow"',
            ],
            "tag": "ENGINE",
        },
        {
            "title": "GOPAL Policy",
            "color": PURPLE,
            "lines": [
                "package",
                "  international",
                "  .eu_ai_act.v1",
                "  .transparency",
                "",
                "default allow",
                "  := false",
                "",
                "allow if {",
                '  input.docs ==',
                '    "published"',
                "}",
            ],
            "tag": "POLICY",
        },
        {
            "title": "Verdict",
            "color": GREEN,
            "lines": [
                "{",
                '  "allow": false,',
                '  "report": {',
                '    "rule":',
                '      "transparency",',
                '    "metrics": [',
                '      { "passed":',
                '          false }',
                "    ]",
                "  }",
                "}",
            ],
            "tag": "OUTPUT",
        },
    ]

    for i, s in enumerate(stages):
        x = start_x + i * (stage_w + gap)
        col = s["color"]

        # Card body (white with coloured border)
        card(ax, x, y0, stage_w, stage_h, fill=WHITE, edge=col, radius=18)
        # Coloured header band
        header_h = 60
        card(ax, x, y0 + stage_h - header_h, stage_w, header_h, fill=col, radius=18)
        # Cover bottom of header so it looks like only the top is rounded
        rect = Rectangle((x, y0 + stage_h - header_h),
                         stage_w, header_h / 2, facecolor=col, edgecolor=col, zorder=3)
        ax.add_patch(rect)

        # Tag (small uppercase, top of header)
        text(ax, x + stage_w / 2, y0 + stage_h - 18,
             s["tag"], size=12, color="#ffffffcc", weight="bold")
        # Title
        text(ax, x + stage_w / 2, y0 + stage_h - 42,
             s["title"], size=20, color=WHITE, weight="bold")

        # Code/text body
        line_y0 = y0 + stage_h - header_h - 36
        line_step = 24
        for j, line in enumerate(s["lines"]):
            text(ax, x + 22, line_y0 - j * line_step, line,
                 size=12.5, color=TEXT, ha="left",
                 family="DejaVu Sans Mono")

        # Arrow to next stage
        if i < len(stages) - 1:
            ax1 = x + stage_w + 6
            ax2 = x + stage_w + gap - 6
            ay = y0 + stage_h / 2
            arrow(ax, ax1, ay, ax2, ay, color=TEXT, lw=3.0, mutation=26)

    # Sub-caption
    pill_w, pill_h = 1040, 70
    px = (1600 - pill_w) / 2
    py = 100
    card(ax, px, py, pill_w, pill_h, fill=LIGHT_BG, radius=35)
    text(ax, 800, py + pill_h / 2,
         "Pure functions of input and data.   No I/O.   Reproducible.",
         size=22, weight="bold", color=TEXT)

    save(fig, "diagram5_evaluation_flow.png")


# === Main ===================================================================
def main():
    print(f"Generating diagrams into: {OUT_DIR}")
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    diagram1_hero_numbers()
    diagram2_directory_tree()
    diagram3_policy_anatomy()
    diagram4_framework_grid()
    diagram5_evaluation_flow()
    print("Done.")


if __name__ == "__main__":
    main()
