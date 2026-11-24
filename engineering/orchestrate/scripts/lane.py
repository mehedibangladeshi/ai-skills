#!/usr/bin/env python3
"""Codex lane helper for /orchestrate. Stdlib only.

  lane.py budget        -> one line per side + a route line
  lane.py model <tier>  -> codex flags for a tier (haiku|sonnet|opus)
  lane.py --self-test
"""
import json, sys, time
from pathlib import Path

HOME = Path.home()
CLAUDE_USAGE = HOME / ".claude" / "usage.json"
CODEX_SESSIONS = HOME / ".codex" / "sessions"
CODEX_MODELS = HOME / ".codex" / "models_cache.json"

FIVE_H_MAX = 80     # tight when 5h window used% >= this
WEEK_SLACK = 10     # tight when weekly used% > elapsed-week% + this
TIERS = {"haiku": ("luna", "low"), "sonnet": ("sol", "medium"), "opus": ("astra", "high")}


def window(used, resets_at, minutes, now):
    """-> (used%, elapsed%) ; a window past its reset counts as fresh."""
    if resets_at and resets_at <= now:
        return 0.0, 0.0
    left = max(0.0, (resets_at - now) / 60) if resets_at else 0.0
    return float(used), max(0.0, min(100.0, 100 * (minutes - left) / minutes))


def side(five, week, now):
    """five/week: (used%, resets_at) or None -> dict, or None when unknown."""
    if not five or not week:
        return None
    u5, _ = window(five[0], five[1], 300, now)
    uw, ew = window(week[0], week[1], 10080, now)
    return {"5h": u5, "wk": uw, "wk_elapsed": ew, "resets_5h": five[1], "resets_wk": week[1],
            "tight": u5 >= FIVE_H_MAX or uw > ew + WEEK_SLACK}


def read_claude(path=CLAUDE_USAGE):
    try:
        d = json.loads(path.read_text())
        f, w = d["five_hour"], d["seven_day"]
        return (f["used_percentage"], f["resets_at"]), (w["used_percentage"], w["resets_at"])
    except Exception:
        return None, None


def read_codex(root=CODEX_SESSIONS):
    try:
        files = sorted(root.rglob("*.jsonl"), key=lambda p: p.stat().st_mtime, reverse=True)
    except Exception:
        return None, None
    for f in files[:5]:
        try:
            lines = f.read_text().splitlines()
        except Exception:
            continue
        for line in reversed(lines):
            if '"rate_limits"' not in line:
                continue
            try:
                rl = json.loads(line)["payload"]["rate_limits"]
                p, s = rl["primary"], rl["secondary"]
                return (p["used_percent"], p["resets_at"]), (s["used_percent"], s["resets_at"])
            except Exception:
                continue
    return None, None


def route(claude, codex):
    known = [s for s in (claude, codex) if s]
    if not known or not any(s["tight"] for s in known):
        return "default"
    if claude and codex and claude["tight"] and codex["tight"]:
        return "pause"
    if codex and codex["tight"]:
        return "claude"
    return "codex"


def fmt(name, s):
    if not s:
        return f"{name}: unknown"
    t = lambda e: f"resets {time.strftime('%a %H:%M', time.localtime(e))}" if e and e > time.time() else "window reset"
    return (f"{name}: 5h {s['5h']:.0f}% ({t(s['resets_5h'])}) · week {s['wk']:.0f}% "
            f"vs {s['wk_elapsed']:.0f}% elapsed ({t(s['resets_wk'])}) · {'TIGHT' if s['tight'] else 'ok'}")


def budget(now=None):
    now = now or time.time()
    c, x = side(*read_claude(), now), side(*read_codex(), now)
    return [fmt("claude", c), fmt("codex", x), f"route: {route(c, x)}"]


def model(tier, path=CODEX_MODELS):
    family, effort = TIERS[tier]
    flags = f"-c model_reasoning_effort={effort}"
    try:
        models = json.loads(path.read_text())
        models = models.get("models", models) if isinstance(models, dict) else models
        # ponytail: family = substring of slug (luna/sol/astra); update TIERS if OpenAI renames families
        hits = [m for m in models if m.get("visibility") == "list" and family in m.get("slug", "")]
        best = min(hits, key=lambda m: m.get("priority", 999))
        return f"-m {best['slug']} {flags}"
    except Exception:
        return flags  # family not found: user's default model


def self_test():
    import tempfile
    now = 1_000_000_000
    # side/route
    ok = side((10, now + 3600), (20, now + 3 * 86400), now)
    assert not ok["tight"], ok
    assert side((85, now + 60), (0, now + 86400), now)["tight"]
    # week: 4 days elapsed of 7 (~57%), used 70% -> tight
    assert side((0, now + 60), (70, now + 3 * 86400), now)["tight"]
    assert side((95, now - 1), (0, now + 86400), now)["5h"] == 0  # past reset = fresh
    assert route(None, None) == "default"
    assert route(ok, ok) == "default"
    tight = side((90, now + 60), (0, now + 86400), now)
    assert route(ok, tight) == "claude" and route(tight, ok) == "codex"
    assert route(tight, tight) == "pause" and route(None, tight) == "claude"
    with tempfile.TemporaryDirectory() as d:
        d = Path(d)
        # codex session parsing
        (d / "s" / "2026").mkdir(parents=True)
        ev = {"type": "event_msg", "payload": {"type": "token_count", "rate_limits": {
            "primary": {"used_percent": 42.0, "window_minutes": 300, "resets_at": now + 600},
            "secondary": {"used_percent": 7.5, "window_minutes": 10080, "resets_at": now + 86400}}}}
        (d / "s" / "2026" / "r.jsonl").write_text('{"type":"other"}\n' + json.dumps(ev) + "\n")
        assert read_codex(d / "s") == ((42.0, now + 600), (7.5, now + 86400))
        assert read_codex(d / "missing") == (None, None)
        # claude usage.json
        (d / "u.json").write_text(json.dumps({"five_hour": {"used_percentage": 5, "resets_at": 1},
                                              "seven_day": {"used_percentage": 6, "resets_at": 2}}))
        assert read_claude(d / "u.json") == ((5, 1), (6, 2))
        assert read_claude(d / "nope.json") == (None, None)
        # model pick: highest priority (lowest number) listed slug of the family
        (d / "m.json").write_text(json.dumps({"models": [
            {"slug": "gpt-6.1-sol", "visibility": "list", "priority": 5},
            {"slug": "gpt-6.2-sol", "visibility": "list", "priority": 1},
            {"slug": "gpt-9-sol", "visibility": "hide", "priority": 0},
            {"slug": "gpt-6-luna", "visibility": "list", "priority": 8}]}))
        assert model("sonnet", d / "m.json") == "-m gpt-6.2-sol -c model_reasoning_effort=medium"
        assert model("haiku", d / "m.json") == "-m gpt-6-luna -c model_reasoning_effort=low"
        assert model("opus", d / "m.json") == "-c model_reasoning_effort=high"  # no astra -> default model
    print("self-test ok")


if __name__ == "__main__":
    a = sys.argv[1:]
    if a == ["--self-test"]:
        self_test()
    elif a == ["budget"]:
        print("\n".join(budget()))
    elif len(a) == 2 and a[0] == "model" and a[1] in TIERS:
        print(model(a[1]))
    else:
        sys.exit(__doc__)
