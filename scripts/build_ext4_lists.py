#!/usr/bin/env python3
"""S8-E4 frequency lists: ko, vi, zh-Hant-HK (TODO.sota-impl/11).

House shape: {"word", "rank"} entries, tiers top_50/200/1000, metadata
with provenance. Quality law (the ja counter-example): filters reject
symbols, bare combining marks, single ASCII letters; entries are
deduplicated first-wins and ranks run 1..N contiguously. Nothing is
interleaved into an existing list — every list is built whole.

- ko, vi: wordfreq top-N with a script filter (hangul presence /
  alphabetic-only), the same wordfreq-native shape as de.json.
- zh-Hant-HK: the committed zh-Hant list converted to Hong Kong
  vocabulary with OpenCC t2hk (ranks verbatim, dedup keep-first), then
  a wordfreq zh tail (s2hk-converted, script-filtered, head-exclusive).
"""
import json
import re
from pathlib import Path
import wordfreq
from opencc import OpenCC

REPO = Path(__file__).resolve().parent.parent
DATA = REPO / "data"

T2HK = OpenCC("t2hk")
S2HK = OpenCC("s2hk")

CJK_RE = re.compile(r"[㐀-鿿豈-﫿]")
HANGUL_RE = re.compile(r"[가-힣]")


def tiers_of(words):
    return {
        "top_50": {"words": words[:50]},
        "top_200": {"words": words[:200]},
        "top_1000": {"words": words[:1000]},
    }


def metadata(lang, name, source, citation, note):
    return {
        "language": lang,
        "language_name": name,
        "source": source,
        "source_url": "https://github.com/rspeer/wordfreq",
        "citation": citation,
        "license": "MIT",
        "note": note,
    }


def write(lang, name, entries, meta):
    words = [e["word"] for e in entries]
    doc = {
        "metadata": dict(meta, full_list_size=len(entries)),
        "tiers": tiers_of(words),
        "full_list": entries,
    }
    out = DATA / f"{lang}.json"
    out.write_text(json.dumps(doc, ensure_ascii=False, indent=1) + "\n")
    print(f"{lang}: {len(entries)} entries -> {out.name}")


def wordfreq_list(lang, limit, predicate):
    seen = set()
    entries = []
    for w in wordfreq.top_n_list(lang, limit):
        w = str(w)
        if not w or w in seen or not predicate(w):
            continue
        seen.add(w)
        entries.append({"word": w, "rank": len(entries) + 1})
    return entries


WF_CITATION = (
    "wordfreq (MIT); data compiled from OpenSubtitles 2018, Twitter, "
    "GlobalVoices, Wikipedia (CC BY-SA)"
)


def build_ko():
    def ok(w):
        return bool(HANGUL_RE.search(w)) and w.isalpha()

    write(
        "ko", "Korean",
        wordfreq_list("ko", 120_000, ok),
        metadata("ko", "Korean", "wordfreq ko top-100k (hangul-filtered)",
                 WF_CITATION,
                 "hangul-bearing alphabetic entries only; eojeol-unit caveat "
                 "recorded in TODO.sota-impl/11 (agglutinative bench note)"),
    )


def build_vi():
    def ok(w):
        if not w.isalpha():
            return False
        if len(w) == 1 and w.isascii():
            return False
        return True

    write(
        "vi", "Vietnamese",
        wordfreq_list("vi", 120_000, ok),
        metadata("vi", "Vietnamese", "wordfreq vi top-100k (alphabetic-filtered)",
                 WF_CITATION,
                 "alphabetic entries, single ASCII letters dropped; "
                 "TODO.sota-impl/11"),
    )


def build_hk():
    src = json.loads((DATA / "zh-Hant.json").read_text())
    head = []
    seen = set()
    for e in src["full_list"]:
        w = T2HK.convert(e["word"])
        if not w or w in seen or not CJK_RE.search(w):
            continue
        seen.add(w)
        head.append({"word": w, "rank": len(head) + 1})

    tail = []
    for e in wordfreq_list("zh", 200_000, lambda w: bool(CJK_RE.search(w))):
        w = S2HK.convert(e["word"])
        if w in seen:
            continue
        seen.add(w)
        tail.append({"word": w, "rank": len(head) + len(tail) + 1})
        if len(tail) >= max(10_000, len(head) // 6):
            break

    write(
        "zh-Hant-HK", "Chinese, Hong Kong Traditional",
        head + tail,
        metadata("zh-Hant-HK", "Chinese, Hong Kong Traditional",
                 "zh-Hant list converted with OpenCC t2hk + wordfreq zh tail (s2hk)",
                 "OpenCC (Apache-2.0); " + WF_CITATION,
                 "derivation disclosed: head = committed zh-Hant list "
                 "t2hk-converted (ranks verbatim, dedup keep-first); tail = "
                 "wordfreq zh s2hk-converted, head-exclusive; "
                 "TODO.sota-impl/11"),
    )


if __name__ == "__main__":
    build_ko()
    build_vi()
    build_hk()
