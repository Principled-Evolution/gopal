#!/usr/bin/env python3
"""Compose the demo asciicast: real output, typed at a human pace.

The commands are actually run and their output captured, so nothing shown here
is written by hand. What is synthesised is the *timing*: keystrokes, the beat
before a command returns, and the pause afterwards long enough to read what
happened. A `script` capture of a shell script has no typing in it at all, and
output that materialises instantly reads as a screenshot rather than a session.

Being explicit about which half is real matters. The numbers, the verdicts and
the exit codes come from running `check.sh`. The rhythm is invented, the way any
screencast's rhythm is invented by the person recording it.

Usage:
    record-demo.py <output.cast>
"""

from __future__ import annotations

import json
import random
import subprocess
import sys
from pathlib import Path

HERE = Path(__file__).resolve().parent
EXAMPLE = HERE.parent / "examples" / "model-switch"

# Deterministic jitter. The keystrokes look uneven, and they are the same
# uneven every time, so regenerating does not churn the file in review.
RNG = random.Random(20260829)

CPS_MIN, CPS_MAX = 0.038, 0.092  # seconds per keystroke
REACH_FOR_ENTER = 0.42  # hand leaves the letters, finds the return key
ENTER_SETTLES = 0.16  # and the press registers before anything happens
FIRST_BYTE = 0.28  # a command does not answer instantly
READ_PASS = 2.4  # long enough to see it passed
READ_FAIL = 6.4  # long enough to read why it failed
BLINK = 0.53  # cursor half-period
BLINKS = 6  # idle at the prompt before the loop starts over
CURSOR = "█"

# What a presenter would put a highlighter through. Matched against the output
# rather than hard-coded positions, so editing check.sh cannot leave a highlight
# sweeping across the wrong words. A phrase that stops appearing is an error,
# not something to skip quietly.
HIGHLIGHTS = [
    ("aggregate:    0.0056", "0.0056"),
    ("PASS  global.v1.toxicity.allow", "PASS"),
    ("aggregate:    0.1373", "0.1373"),
    ("worst output: 0.8106", "0.8106"),
    ("FAIL  global.v1.toxicity.allow", "FAIL"),
    ("0.8106  #4  respond to abusive language", "respond to abusive language"),
]
SWEEP = 0.028  # per character, the pace of a pen moving
HL_ON = "\x1b[43;30m"
HL_OFF = "\x1b[0m"
SAVE, RESTORE = "\x1b7", "\x1b8"

TYPO_CHANCE = 0.8  # per command, not per character
NOTICE_TYPO = (0.22, 0.46)  # the beat before the hand goes back
AFTER_FIX = (0.08, 0.19)  # and after the correction, before carrying on

# Where a finger actually lands when it misses. A random letter reads as noise;
# the key next door reads as a person typing too fast.
NEIGHBOURS = {
    "a": "sq", "b": "vn", "c": "xv", "d": "sf", "e": "wr", "f": "dg",
    "g": "fh", "h": "gj", "i": "uo", "j": "hk", "k": "jl", "l": "k",
    "m": "n", "n": "bm", "o": "ip", "p": "o", "q": "wa", "r": "et",
    "s": "ad", "t": "ry", "u": "yi", "v": "cb", "w": "qe", "x": "zc",
    "y": "tu", "z": "x", ".": "/", "/": ".", "-": "0", "_": "-",
}


class Cast:
    def __init__(self) -> None:
        self.t = 0.0
        self.events: list[list] = []

    def wait(self, seconds: float) -> None:
        self.t += seconds

    def out(self, text: str) -> None:
        self.events.append([round(self.t, 4), "o", text])

    def type(self, text: str, typo_at: int | None = None) -> None:
        """One keystroke at a time, with the pauses and the mistakes.

        A typo is the neighbouring key, noticed a moment later, backspaced and
        retyped. It is the single thing that separates a recording of somebody
        working from a recording of text being replayed at a plausible speed.
        """
        for i, ch in enumerate(text):
            if i == typo_at:
                wrong = NEIGHBOURS.get(ch.lower())
                if wrong:
                    self.wait(RNG.uniform(CPS_MIN, CPS_MAX))
                    self.out(RNG.choice(wrong))
                    self.wait(RNG.uniform(*NOTICE_TYPO))
                    self.out("\b \b")
                    self.wait(RNG.uniform(*AFTER_FIX))
            self.wait(RNG.uniform(CPS_MIN, CPS_MAX))
            # A space is where people hesitate, so lean on it slightly.
            if ch == " " and RNG.random() < 0.35:
                self.wait(RNG.uniform(0.05, 0.16))
            self.out(ch)

    def prompt(self) -> None:
        self.out("$ ")

    def command(self, text: str) -> None:
        self.prompt()
        # Somewhere past the first few characters, so the mistake lands mid-word
        # rather than on the very first key.
        typo_at = None
        if len(text) > 12 and RNG.random() < TYPO_CHANCE:
            typo_at = RNG.randrange(4, len(text) - 2)
        self.type(text, typo_at)
        # Pressing return is two beats: reaching for the key, and the press
        # landing. Without them a command line ends and output begins in the
        # same instant, which nothing on a real keyboard does.
        self.wait(REACH_FOR_ENTER)
        self.out("\r\n")
        self.wait(ENTER_SETTLES)

    def block(self, text: str, chunk_pause: float = 0.09) -> None:
        """Output arriving in a couple of pieces, as a real command does."""
        self.wait(FIRST_BYTE)
        lines = text.rstrip("\n").split("\n")
        for i in range(0, len(lines), 3):
            self.out("\r\n".join(lines[i : i + 3]) + "\r\n")
            self.wait(chunk_pause)

    def blink(self, times: int = BLINKS) -> None:
        """A cursor sitting at an empty prompt, waiting."""
        self.prompt()
        for _ in range(times):
            self.out(CURSOR)
            self.wait(BLINK)
            self.out("\b \b")
            self.wait(BLINK)


    def highlight(self, rows_up: int, col: int, text: str) -> None:
        """Draw a highlighter left to right over text already on screen.

        The cursor is saved, moved up to the line, the phrase redrawn one
        character wider each frame, and the cursor put back. Everything happens
        inside a save/restore pair so nothing downstream has to reason about
        where the cursor ended up.
        """
        # CSI 0 C moves the cursor forward one column, not zero: ANSI reads a
        # zero parameter as one. Emitting it for a phrase at column 0 drew the
        # highlight one place right and left the original first letter behind
        # it, which is where the PPASS and FFAIL came from.
        forward = f"\x1b[{col}C" if col > 0 else ""
        for i in range(1, len(text) + 1):
            self.out(
                f"{SAVE}\x1b[{rows_up}A\r{forward}"
                f"{HL_ON}{text[:i]}{HL_OFF}{RESTORE}"
            )
            self.wait(SWEEP)

    def sweep(self, block: str, pairs: list[tuple[str, str]]) -> None:
        """Highlight each phrase in a block of output just written."""
        lines = block.rstrip("\n").split("\n")
        for needle, phrase in pairs:
            for idx, line in enumerate(lines):
                if needle in line and phrase in line:
                    self.highlight(len(lines) - idx, line.index(phrase), phrase)
                    self.wait(0.34)
                    break


def run(args: list[str]) -> str:
    done = subprocess.run(
        args, cwd=EXAMPLE, capture_output=True, text=True, timeout=180
    )
    return (done.stdout or "") + (done.stderr or "")


def main() -> int:
    if len(sys.argv) != 2:
        print(__doc__.strip(), file=sys.stderr)
        return 2
    dst = Path(sys.argv[1])

    baseline = run(["./check.sh", "outputs-baseline.json"])
    candidate = run(["./check.sh", "outputs-candidate.json"])
    missing = [
        phrase
        for needle, phrase in HIGHLIGHTS
        if not any(needle in line and phrase in line
                   for line in (baseline + candidate).split("\n"))
    ]
    if missing:
        print(
            f"refusing to record: nothing to highlight for {missing}. The output "
            "changed and the highlights now point at text that is not there.",
            file=sys.stderr,
        )
        return 1
    if "PASS" not in baseline or "FAIL" not in candidate:
        print(
            "refusing to record: the baseline must pass and the candidate must "
            "fail, and right now they do not. Fix the example, not the recording.",
            file=sys.stderr,
        )
        return 1

    cast = Cast()
    cast.wait(0.6)
    cast.command("./check.sh outputs-baseline.json")
    cast.block(baseline)
    cast.wait(0.8)
    cast.sweep(baseline, HIGHLIGHTS)
    cast.wait(READ_PASS)

    cast.command("# same prompts, same classifier. swap the model.")
    cast.wait(0.5)
    cast.command("./check.sh outputs-candidate.json")
    cast.block(candidate)
    cast.wait(0.8)
    cast.sweep(candidate, HIGHLIGHTS)
    # A silent hold first. The failure is the thing worth reading, and a cursor
    # flashing through it is movement competing with the text. Blink afterwards,
    # to say the session is idle rather than finished.
    cast.wait(READ_FAIL)
    cast.blink()

    header = {
        "version": 2,
        "width": 96,
        "height": 34,
        "idle_time_limit": 3.0,
        "title": "a model change fails the build",
    }
    with dst.open("w", encoding="utf-8") as fh:
        fh.write(json.dumps(header) + "\n")
        for event in cast.events:
            fh.write(json.dumps(event) + "\n")

    print(f"Wrote {dst} ({len(cast.events)} events, {cast.t:.1f}s)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
