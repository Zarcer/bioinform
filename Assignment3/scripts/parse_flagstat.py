#!/usr/bin/env python3
"""Extract mapped reads percent from `samtools flagstat` output."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


MAPPED_RE = re.compile(r"^\s*\d+\s+\+\s+\d+\s+mapped\s+\(([\d.]+)%")


def parse_mapped_percent(flagstat_text: str) -> float:
    """Return the percent of mapped reads from a flagstat report."""
    for line in flagstat_text.splitlines():
        match = MAPPED_RE.search(line)
        if match:
            return float(match.group(1))
    raise ValueError("Cannot find the 'mapped' line in samtools flagstat output")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Parse samtools flagstat output and print mapped reads percent."
    )
    parser.add_argument("flagstat", type=Path, help="Path to samtools flagstat text file")
    parser.add_argument(
        "--threshold",
        type=float,
        default=None,
        help="Optional threshold. If set, also print OK/not OK.",
    )
    args = parser.parse_args()

    try:
        mapped_percent = parse_mapped_percent(args.flagstat.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001 - CLI should print a clear error.
        print(f"ERROR: {exc}", file=sys.stderr)
        return 1

    print(f"{mapped_percent:.2f}")
    if args.threshold is not None:
        print("OK" if mapped_percent >= args.threshold else "not OK")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
