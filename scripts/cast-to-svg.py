#!/usr/bin/env python3
"""Render an asciicast to an SVG terminal, still or playing.

Two outputs, because two places need different things.

A README on GitHub renders an SVG as an image and never runs scripts, so an
asciinema player cannot work there. CSS animation inside the SVG does, which is
what --animate produces: it plays inline, with no player, no click and no
JavaScript. The reveal follows the recorded timestamps, so the pause before the
model is swapped is the pause that was actually there.

Without --animate it renders the finished screen, which is the better artefact
where a reader wants to read and copy rather than watch.

Both keep real <text> elements, so the output stays selectable and searchable,
and both carry the whole transcript in <desc> rather than an alt attribute
announcing a picture of a terminal.

Derived from the cast rather than hand-drawn, so neither can drift from the
session that was recorded. Regenerate and any change shows up in the diff.

Usage:
    cast-to-svg.py <input.cast> <output.svg> [--animate] [--title "..."]
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path
from xml.sax.saxutils import escape

# The site palette, so the block sits inside a page rather than on top of it.
BG = "#1B1917"
CHROME = "#2A2725"
FG = "#E7E2DA"
MUTED = "#9C948A"
PROMPT = "#D9A441"
GREEN = "#7FB88A"
RED = "#E0798C"
HL = "#D9A441"  # the highlighter, at low opacity behind the text

# The grid the highlight rectangles sit on.
#
# A rendered monospace advance is not exactly this, and no amount of textLength
# fixes it: lengthAdjust="spacing" spreads the surplus across the gaps between
# glyphs, so a line of n characters is stretched over n-1 gaps and every column
# lands slightly right of where it was computed. It also visibly spaces the text
# out, which looks wrong before it looks inaccurate.
#
# So lines carrying a highlight are drawn one character at a time, each placed
# on this grid explicitly. Lines without one are drawn normally and laid out by
# the browser, because nothing has to line up with them.
CHAR_W = 7.8
LINE_H = 19
PAD_X = 18
PAD_Y = 14
CHROME_H = 30


# The recording draws its highlights by saving the cursor, moving up, redrawing
# a phrase with a yellow background, and restoring. Those blocks are decoration:
# they repaint text already on screen. The cell parser would have to implement
# cursor addressing to survive them, so they are lifted out first and replayed
# separately as highlight animations.
REDRAW = re.compile("\x1b7.*?\x1b8", re.S)
HIGHLIT = re.compile("\x1b\\[43;30m(.*?)\x1b\\[0m", re.S)


def cast_highlights(path: Path) -> dict[str, tuple[float, float]]:
    """Each highlighted phrase, with when the pen started and finished it.

    A sweep emits every prefix in turn, so the frames have to be grouped into
    runs rather than matched by prefix. Two numbers beginning "0." would
    otherwise be read as one sweep, and the highlight would appear to start
    thirteen seconds before the text it covers.
    """
    frames: list[tuple[str, float]] = []
    for line in path.read_text(encoding="utf-8").splitlines()[1:]:
        if not line.strip():
            continue
        at, _, chunk = json.loads(line)
        for block in REDRAW.findall(chunk):
            for phrase in HIGHLIT.findall(block):
                if phrase:
                    frames.append((phrase, float(at)))

    spans: dict[str, tuple[float, float]] = {}
    run: list[tuple[str, float]] = []

    def flush() -> None:
        if run:
            spans[run[-1][0]] = (run[0][1], run[-1][1])

    for phrase, at in frames:
        if run and phrase.startswith(run[-1][0]) and len(phrase) > len(run[-1][0]):
            run.append((phrase, at))
        else:
            flush()
            run = [(phrase, at)]
    flush()
    return spans


def cast_cells(path: Path) -> list[dict]:
    """Every character, where it sat, and when it came and went.

    Line-level parsing cannot represent a typo. The recording types a wrong
    letter, waits, deletes it and carries on, and a renderer that only knows the
    finished text can replay the result but not the mistake. Tracking cells lets
    the animation show the wrong character appear and disappear exactly when it
    did.

    Returns one dict per line: `cells` in column order, `end` when the line was
    complete, and `typed` for lines that arrived a keystroke at a time rather
    than as a block of output.
    """
    raw = path.read_text(encoding="utf-8").splitlines()
    lines: list[dict] = []
    cells: list[dict] = []
    col = 0

    def close(at: float) -> None:
        nonlocal cells, col
        visible = [c for c in cells if c["out"] is None]
        stamps = {round(c["in"], 3) for c in visible}
        lines.append(
            {
                "cells": sorted(cells, key=lambda c: c["col"]),
                "text": "".join(c["ch"] for c in sorted(visible, key=lambda c: c["col"])),
                "end": at,
                # Output arrives in chunks sharing one timestamp; typing does not.
                "typed": len(stamps) > 3,
            }
        )
        cells, col = [], 0

    for line in raw[1:]:
        if not line.strip():
            continue
        at, _, chunk = json.loads(line)
        at = float(at)
        chunk = REDRAW.sub("", chunk)
        chunk = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", chunk)
        chunk = chunk.replace("\r\n", "\n").replace("\r", "")
        for ch in chunk:
            if ch == "\b":
                for cell in reversed(cells):
                    if cell["out"] is None and cell["col"] == col - 1:
                        cell["out"] = at
                        col -= 1
                        break
                continue
            if ch == "\n":
                close(at)
                continue
            if ch == " " and col > 0:
                # A space typed over a deleted character just moves the cursor.
                existing = [c for c in cells if c["col"] == col and c["out"] is None]
                if not existing:
                    cells.append({"col": col, "ch": ch, "in": at, "out": None})
                col += 1
                continue
            cells.append({"col": col, "ch": ch, "in": at, "out": None})
            col += 1
    if any(c["out"] is None for c in cells):
        close(lines[-1]["end"] if lines else 0.0)

    while len(lines) > 1 and not lines[-1]["text"].strip():
        lines.pop()
    return lines


def cast_text(path: Path) -> list[str]:
    """The finished screen, as lines."""
    return [row["text"].rstrip() for row in cast_cells(path)]


def colour_for(line: str) -> str:
    stripped = line.strip()
    if stripped.startswith("$"):
        return PROMPT
    if stripped.startswith("PASS"):
        return GREEN
    if stripped.startswith("FAIL"):
        return RED
    if stripped.startswith(("http", "The rule that decided", "against params", "score we invented")):
        return MUTED
    return FG


def _chrome(width: int, height: int, title: str, lines: list[str]) -> list[str]:
    """Window furniture, shared by both renderers."""
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" role="img" aria-label="{escape(title)}">',
        f"<title>{escape(title)}</title>",
        # The transcript itself, so a screen reader reads the session rather
        # than being told there is a picture of a terminal.
        f"<desc>{escape(chr(10).join(lines))}</desc>",
    ]
    return out


def _frame(width: int, height: int, title: str) -> list[str]:
    out = [
        f'<rect width="{width}" height="{height}" rx="7" fill="{BG}"/>',
        f'<path d="M0 7a7 7 0 0 1 7-7h{width - 14}a7 7 0 0 1 7 7v{CHROME_H - 7}H0z" fill="{CHROME}"/>',
    ]
    for i, cx in enumerate((17, 35, 53)):
        out.append(
            f'<circle cx="{cx}" cy="15" r="5" fill="{("#E0798C", "#D9A441", "#7FB88A")[i]}" opacity="0.65"/>'
        )
    out.append(
        f'<text x="{width / 2}" y="19" fill="{MUTED}" font-size="11" text-anchor="middle" '
        f'font-family="ui-monospace,SFMono-Regular,Menlo,monospace">{escape(title)}</text>'
    )
    return out


def _line_svg(line: str, y: float, colour: str, on_grid: bool) -> list[str]:
    """One line of text, either laid out by the browser or placed per character.

    Per character only where something has to line up with it. Positioning every
    glyph of every line would be exact and would also quadruple the file for no
    benefit on lines nothing points at.
    """
    if not on_grid:
        return [f'<text x="{PAD_X}" y="{y}" fill="{colour}">{escape(line)}</text>']
    out = []
    for i, ch in enumerate(line):
        if ch == " ":
            continue
        out.append(
            f'<text x="{PAD_X + i * CHAR_W:.1f}" y="{y}" fill="{colour}">'
            f"{escape(ch)}</text>"
        )
    return out


def _dims(lines: list[str]) -> tuple[int, int]:
    cols = max((len(line) for line in lines), default=0)
    return (
        int(cols * CHAR_W + PAD_X * 2),
        int(len(lines) * LINE_H + PAD_Y * 2 + CHROME_H),
    )


def render(rows: list[dict], title: str, highlights: dict | None = None) -> str:
    """The finished screen, highlights already drawn.

    The still version is what a reader gets where reading is the point, so the
    pen has already been through it rather than being about to.
    """
    highlights = highlights or {}
    lines = [r["text"].rstrip() for r in rows]
    width, height = _dims(lines)
    out = _chrome(width, height, title, lines) + _frame(width, height, title)

    y = CHROME_H + PAD_Y + 12
    marks, text = [], []
    for line in lines:
        if line.strip():
            hit = [p for p in highlights if p in line]
            for phrase in hit:
                x = PAD_X + line.index(phrase) * CHAR_W
                marks.append(
                    f'<rect x="{x - 1.5:.1f}" y="{y - 11}" '
                    f'width="{len(phrase) * CHAR_W + 3:.1f}" height="15" rx="2" '
                    f'fill="{HL}" opacity="0.32"/>'
                )
            text.extend(_line_svg(line, y, colour_for(line), on_grid=bool(hit)))
        y += LINE_H

    out.extend(marks)  # behind the text, like a pen under the words
    out.append(
        '<g font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace" '
        'font-size="12.5" xml:space="preserve">'
    )
    out.extend(text)
    out.append("</g></svg>")
    return "\n".join(out) + "\n"


def render_animated(
    rows: list[dict], title: str, hold: float = 4.0, highlights: dict | None = None
) -> str:
    """The session replayed, mistakes included.

    CSS keyframes rather than SMIL or JavaScript, because a README on GitHub
    renders an SVG as an image: scripts never run there, and CSS animation does.
    The same file plays inline on GitHub and on a web page, with no player.

    Typed lines animate per character, so a wrong key appears and is deleted at
    the moments it actually was. Revealing the finished text behind a widening
    clip would be simpler and would quietly drop every correction.
    """
    highlights = highlights or {}
    lines = [r["text"].rstrip() for r in rows]
    width, height = _dims(lines)
    total = max(
        [r["end"] for r in rows] + [b for _, b in highlights.values()], default=1.0
    )
    span = total + hold

    def pct(t: float) -> float:
        return max(0.0, min(100.0, (t / span) * 100))

    css: list[str] = []
    body: list[str] = []
    y = CHROME_H + PAD_Y + 12

    for i, row in enumerate(rows):
        text = row["text"].rstrip()
        if not text.strip():
            y += LINE_H
            continue

        if row["typed"]:
            colour = colour_for(text)
            for j, cell in enumerate(row["cells"]):
                if cell["ch"] == " ":
                    continue
                appear = pct(cell["in"])
                name = f"c{i}_{j}"
                if cell["out"] is None:
                    frames = (
                        f"0%,{appear:.3f}%{{opacity:0}}"
                        f"{min(100, appear + 0.12):.3f}%,100%{{opacity:1}}"
                    )
                else:
                    gone = pct(cell["out"])
                    frames = (
                        f"0%,{appear:.3f}%{{opacity:0}}"
                        f"{min(100, appear + 0.12):.3f}%,{gone:.3f}%{{opacity:1}}"
                        f"{min(100, gone + 0.12):.3f}%,100%{{opacity:0}}"
                    )
                css.append(
                    f".{name}{{animation:{name} {span:.2f}s linear infinite}}"
                    f"@keyframes {name}{{{frames}}}"
                )
                x = PAD_X + cell["col"] * CHAR_W
                fill = PROMPT if cell["col"] < 2 else colour
                body.append(
                    f'<text class="{name}" x="{x:.1f}" y="{y}" fill="{fill}">'
                    f"{escape(cell['ch'])}</text>"
                )
        else:
            appear = pct(row["end"])
            css.append(
                f".l{i}{{animation:l{i} {span:.2f}s linear infinite}}"
                f"@keyframes l{i}{{0%,{appear:.3f}%{{opacity:0}}"
                f"{min(100, appear + 0.12):.3f}%,100%{{opacity:1}}}}"
            )
            on_grid = any(p in text for p in highlights)
            for frag in _line_svg(text, y, colour_for(text), on_grid):
                body.append(frag.replace("<text ", f'<text class="l{i}" ', 1))
        y += LINE_H

    # The pen, drawn behind the text and widening across the sweep. Scaling a
    # rect from the left is what a highlighter does; fading one in is what a
    # slide transition does, and reads as decoration rather than emphasis.
    marks: list[str] = []
    for i, row in enumerate(rows):
        text = row["text"].rstrip()
        row_y = CHROME_H + PAD_Y + 12 + i * LINE_H
        for phrase, (began, ended) in highlights.items():
            if phrase not in text:
                continue
            x = PAD_X + text.index(phrase) * CHAR_W
            w = len(phrase) * CHAR_W + 3
            name = f"h{i}_{abs(hash(phrase)) % 9973}"
            css.append(
                f".{name}{{transform-box:fill-box;transform-origin:left center;"
                f"animation:{name} {span:.2f}s linear infinite}}"
                f"@keyframes {name}{{0%,{pct(began):.3f}%{{transform:scaleX(0)}}"
                f"{pct(ended):.3f}%,100%{{transform:scaleX(1)}}}}"
            )
            marks.append(
                f'<rect class="{name}" x="{x - 1.5:.1f}" y="{row_y - 11}" '
                f'width="{w:.1f}" height="15" rx="2" fill="{HL}" opacity="0.32"/>'
            )

    # An idle cursor while the loop holds on the failure.
    cur_y = CHROME_H + PAD_Y + 12 + (len(rows) - 1) * LINE_H
    at = pct(total)
    css.append(
        f".cur{{animation:cur {span:.2f}s linear infinite}}"
        f"@keyframes cur{{0%,{at:.3f}%{{opacity:0}}"
        f"{min(100, at + 0.1):.3f}%,100%{{opacity:1}}}}"
    )
    css.append(
        ".blink{animation:blink 1.06s steps(1,end) infinite}"
        "@keyframes blink{0%,50%{opacity:1}50.01%,100%{opacity:0}}"
    )
    body.append(
        f'<text class="cur" x="{PAD_X}" y="{cur_y}" fill="{PROMPT}">$ '
        f'<tspan class="blink" fill="{FG}">\u2588</tspan></text>'
    )

    out = _chrome(width, height, title, lines)
    out.append("<style>" + "".join(css) + "</style>")
    out.extend(_frame(width, height, title))
    out.extend(marks)
    out.append(
        '<g font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace" '
        'font-size="12.5" xml:space="preserve">'
    )
    out.extend(body)
    out.append("</g></svg>")
    return "\n".join(out) + "\n"


def main() -> int:
    argv = sys.argv[1:]
    title = "a model change fails the build"
    args = []
    i = 0
    while i < len(argv):
        if argv[i] == "--animate":
            i += 1
            continue
        if argv[i] == "--title":
            title = argv[i + 1] if i + 1 < len(argv) else title
            i += 2
            continue
        args.append(argv[i])
        i += 1
    if len(args) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2

    src, dst = Path(args[0]), Path(args[1])
    rows = cast_cells(src)
    if not rows:
        print(f"{src} produced no output", file=sys.stderr)
        return 1
    marks = cast_highlights(src)
    body = (
        render_animated(rows, title, highlights=marks)
        if "--animate" in sys.argv
        else render(rows, title, highlights=marks)
    )
    dst.write_text(body, encoding="utf-8")
    print(f"Wrote {dst} ({len(rows)} lines, {dst.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
