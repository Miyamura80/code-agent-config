from __future__ import annotations

import pathlib
import re
from collections.abc import Iterable, Sequence

REPO_ROOT = pathlib.Path(__file__).resolve().parent.parent
EM_DASH = chr(0x2014)
SELF = pathlib.Path(__file__).resolve()  # don't flag this script's own patterns

ROOT_SKIP_DIRS = {
    ".git", ".venv", ".uv_cache", ".uv-cache", ".cache", "node_modules",
    ".next", "vendor", "dist", "build", "target",
}
RECURSIVE_SKIP_DIRS = {"__pycache__", ".pytest_cache", "node_modules", "dist", "target"}
SKIP_SUFFIXES = {
    ".png", ".jpg", ".jpeg", ".gif", ".webp", ".ico", ".svg", ".mp4", ".mov",
    ".mp3", ".woff", ".woff2", ".ttf", ".otf", ".eot", ".pdf", ".zip", ".tar",
    ".gz", ".bz2", ".7z", ".ckpt", ".bin", ".pyc", ".pyo", ".class", ".o",
    ".so", ".dylib", ".db", ".lock",
}
# Files with reviewed, legitimate uses of the flagged characters (repo-relative).
# The opencode plugin matches en/em dash literals in a separator regex, so the
# em dash there is functional, not prose.
SKIP_FILES = {
    "opencode/plugins/ghostty-osc9-notify.js",
}


def iter_text_files(root: pathlib.Path) -> Iterable[pathlib.Path]:
    for path in root.rglob("*"):
        if not path.is_file():
            continue
        if path.resolve() == SELF:
            continue
        rel = path.relative_to(root)
        if rel.as_posix() in SKIP_FILES:
            continue
        rel_parts = rel.parts
        if rel_parts and rel_parts[0] in ROOT_SKIP_DIRS:
            continue
        if any(part in RECURSIVE_SKIP_DIRS for part in rel_parts[:-1]):
            continue
        if path.suffix.lower() in SKIP_SUFFIXES:
            continue
        yield path


# --- Detector 1: em dash ---
def find_em_dashes(text: str) -> Sequence[tuple[int, str]]:
    return [(n, line) for n, line in enumerate(text.splitlines(), 1) if EM_DASH in line]


# --- Detector 2: contrastive parallelism ("not just X, but Y" AI tell) ---
# Keep conservative to avoid false positives on ordinary prose.
CONTRASTIVE_PATTERNS = [
    r"\bnot just\b[^.?!\n]*?\bbut\b",
    r"\bnot only\b[^.?!\n]*?\bbut\b",
    r"\bnot merely\b[^.?!\n]*?\bbut\b",
    r"\b(?:isn't|aren't|wasn't) (?:just|only|merely)\b",
    r"\bit's not (?:just|only|about)\b[^.?!\n]*?\bit's\b",
    r"\bmore than just\b",
]
CONTRASTIVE_RE = re.compile("|".join(CONTRASTIVE_PATTERNS), re.IGNORECASE)


def find_contrastive(text: str) -> Sequence[tuple[int, str]]:
    return [(n, line) for n, line in enumerate(text.splitlines(), 1) if CONTRASTIVE_RE.search(line)]


def main() -> int:
    em: list[tuple[pathlib.Path, int, str]] = []
    contrastive: list[tuple[pathlib.Path, int, str]] = []
    for path in iter_text_files(REPO_ROOT):
        try:
            text = path.read_text(encoding="utf-8", errors="ignore")
        except OSError:
            continue
        rel = path.relative_to(REPO_ROOT)
        for n, line in find_em_dashes(text):
            em.append((rel, n, line.strip()))
        for n, line in find_contrastive(text):
            contrastive.append((rel, n, line.strip()))

    if em or contrastive:
        if em:
            print(f"AI writing check failed: {EM_DASH!r} (em dash) detected")
            for rel, n, snip in em:
                print(f"{rel}:{n}: {snip}")
        if contrastive:
            print("AI writing check failed: contrastive parallelism ('not just X, but Y') detected")
            for rel, n, snip in contrastive:
                print(f"{rel}:{n}: {snip}")
        print("Remove the flagged construction or explain why it is acceptable.")
        return 1

    print("AI writing check passed (no em dash or contrastive parallelism found).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
