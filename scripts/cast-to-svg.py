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

CHAR_W = 7.8
LINE_H = 19
PAD_X = 18
PAD_Y = 14
CHROME_H = 30


def cast_lines(path: Path) -> list[tuple[str, float]]:
    """Each finished line with the moment it appeared.

    Timestamps come from the recording rather than being spaced evenly, so an
    animation built from them keeps the real pauses: the gap where the model is
    swapped is the gap that was actually there.
    """
    raw = path.read_text(encoding="utf-8").splitlines()
    out: list[tuple[str, float]] = []
    buf = ""
    for line in raw[1:]:
        if not line.strip():
            continue
        at, _, chunk = json.loads(line)
        chunk = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", chunk)
        buf += chunk.replace("\r\n", "\n").replace("\r", "")
        while "\n" in buf:
            done, buf = buf.split("\n", 1)
            out.append((done, float(at)))
    if buf.strip():
        out.append((buf, out[-1][1] if out else 0.0))
    while out and not out[-1][0].strip():
        out.pop()
    return out


def cast_text(path: Path) -> list[str]:
    """The finished screen, as lines."""
    return [text for text, _ in cast_lines(path)]


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


def render(lines: list[str], title: str) -> str:
    cols = max((len(line) for line in lines), default=0)
    width = int(cols * CHAR_W + PAD_X * 2)
    height = int(len(lines) * LINE_H + PAD_Y * 2 + CHROME_H)

    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" role="img" aria-label="{escape(title)}">',
        f"<title>{escape(title)}</title>",
        # The whole transcript as one description, so a screen reader gets the
        # content rather than being told there is a picture of a terminal.
        f"<desc>{escape(chr(10).join(lines))}</desc>",
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

    y = CHROME_H + PAD_Y + 12
    out.append(
        f'<g font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace" '
        f'font-size="12.5" xml:space="preserve">'
    )
    for line in lines:
        if line.strip():
            out.append(
                f'<text x="{PAD_X}" y="{y}" fill="{colour_for(line)}">{escape(line)}</text>'
            )
        y += LINE_H
    out.append("</g></svg>")
    return "\n".join(out) + "\n"


def render_animated(rows: list[tuple[str, float]], title: str) -> str:
    """The same terminal, revealed in the order and pacing it was recorded.

    CSS keyframes rather than SMIL or JavaScript, because a README on GitHub
    renders an SVG as an image: scripts never run there, and CSS animation does.
    The same file therefore plays inline on GitHub and on a web page without
    either needing a player.

    Each line holds at opacity 0 until its own moment, so nothing is spaced
    evenly and the pause before the model is swapped is the real one.
    """
    lines = [r[0] for r in rows]
    cols = max((len(line) for line in lines), default=0)
    width = int(cols * CHAR_W + PAD_X * 2)
    height = int(len(lines) * LINE_H + PAD_Y * 2 + CHROME_H)
    total = max((t for _, t in rows), default=1.0)
    # A beat at the end so the failure stays readable before it loops.
    span = total + 4.0

    css = [
        "text.l{opacity:0;animation:r var(--d) linear infinite}",
        "@keyframes r{0%{opacity:0}100%{opacity:1}}",
    ]
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
        f'viewBox="0 0 {width} {height}" role="img" aria-label="{escape(title)}">',
        f"<title>{escape(title)}</title>",
        f"<desc>{escape(chr(10).join(lines))}</desc>",
        "<style>",
    ]
    for i, (_, at) in enumerate(rows):
        # Hold invisible, then appear. A near-zero fade keeps it a terminal
        # rather than a slideshow.
        pct = max(0.01, min(99.0, (at / span) * 100))
        css.append(
            f".l{i}{{animation-duration:{span:.2f}s;"
            f"animation-name:l{i}}}"
            f"@keyframes l{i}{{0%,{pct:.3f}%{{opacity:0}}"
            f"{min(99.5, pct + 0.4):.3f}%,100%{{opacity:1}}}}"
        )
    out.extend(css)
    out.append("</style>")
    out.append(f'<rect width="{width}" height="{height}" rx="7" fill="{BG}"/>')
    out.append(
        f'<path d="M0 7a7 7 0 0 1 7-7h{width - 14}a7 7 0 0 1 7 7v{CHROME_H - 7}H0z" fill="{CHROME}"/>'
    )
    for i, cx in enumerate((17, 35, 53)):
        out.append(
            f'<circle cx="{cx}" cy="15" r="5" fill="{("#E0798C", "#D9A441", "#7FB88A")[i]}" opacity="0.65"/>'
        )
    out.append(
        f'<text x="{width / 2}" y="19" fill="{MUTED}" font-size="11" text-anchor="middle" '
        f'font-family="ui-monospace,SFMono-Regular,Menlo,monospace">{escape(title)}</text>'
    )
    y = CHROME_H + PAD_Y + 12
    out.append(
        '<g font-family="ui-monospace,SFMono-Regular,Menlo,Consolas,monospace" '
        'font-size="12.5" xml:space="preserve">'
    )
    for i, (line, _) in enumerate(rows):
        if line.strip():
            out.append(
                f'<text class="l l{i}" x="{PAD_X}" y="{y}" '
                f'fill="{colour_for(line)}">{escape(line)}</text>'
            )
        y += LINE_H
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
    rows = cast_lines(src)
    if not rows:
        print(f"{src} produced no output", file=sys.stderr)
        return 1
    body = (
        render_animated(rows, title)
        if "--animate" in sys.argv
        else render([r[0] for r in rows], title)
    )
    dst.write_text(body, encoding="utf-8")
    print(f"Wrote {dst} ({len(rows)} lines, {dst.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
