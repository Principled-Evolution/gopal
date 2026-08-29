#!/usr/bin/env python3
"""Render an asciicast to a static SVG terminal.

An animated player is the wrong tool for a three-second recording. It puts a
play button in front of nine lines of text, and what a reader wants is to read
them, select them, and copy the command. This renders the finished session
instead: real <text> elements, so the output is selectable, searchable, and
legible to a screen reader, with no JavaScript and nothing fetched at runtime.

Derived from the cast rather than hand-drawn, so it cannot drift from the
session that was actually recorded. Regenerate it and any change to the demo
shows up in the diff.

Usage:
    cast-to-svg.py <input.cast> <output.svg> [--title "..."]
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


def cast_text(path: Path) -> list[str]:
    """The finished screen, as lines."""
    raw = path.read_text(encoding="utf-8").splitlines()
    body = "".join(json.loads(line)[2] for line in raw[1:] if line.strip())
    body = body.replace("\r\n", "\n").replace("\r", "")
    body = re.sub(r"\x1b\[[0-9;]*[A-Za-z]", "", body)  # strip any ANSI
    lines = body.split("\n")
    while lines and not lines[-1].strip():
        lines.pop()
    return lines


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


def main() -> int:
    argv = sys.argv[1:]
    title = "a model change fails the build"
    args = []
    i = 0
    while i < len(argv):
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
    lines = cast_text(src)
    if not lines:
        print(f"{src} produced no output", file=sys.stderr)
        return 1
    dst.write_text(render(lines, title), encoding="utf-8")
    print(f"Wrote {dst} ({len(lines)} lines, {dst.stat().st_size:,} bytes)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
