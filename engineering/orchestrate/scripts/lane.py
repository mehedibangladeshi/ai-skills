#!/usr/bin/env python3
"""Provider-neutral lane helper for /orchestrate. Stdlib only.

  lane.py host
  lane.py available
  lane.py model <claude|codex> <light|standard|deep> [--visual]
  lane.py budget [--only claude|codex]
  lane.py --self-test
"""
import json, os, re, shutil, subprocess, sys, time
from pathlib import Path

HOME = Path.home()
CLAUDE_USAGE = HOME / ".claude" / "usage.json"
CODEX_SESSIONS = HOME / ".codex" / "sessions"
CODEX_MODELS = HOME / ".codex" / "models_cache.json"

FIVE_H_MAX = 80     # tight when 5h window used% >= this
WEEK_SLACK = 10     # tight when weekly used% > elapsed-week% + this
TIERS = {
    "light": ("haiku", "luna", "low"),
    "standard": ("sonnet", "sol", "medium"),
    "deep": ("opus", "astra", "high"),
}
CODEX_VISUAL_FAMILIES = {"light": "terra"}
PROVIDERS = ("claude", "codex")


def host(env):
    if "CODEX_THREAD_ID" in env:
        return "codex"
    if "CLAUDE_CODE_ENTRYPOINT" in env or "CLAUDECODE" in env:
        return "claude"
    return "other"


def available(which=shutil.which, run=subprocess.run):
    claude = bool(which("claude"))
    codex = which("codex")
    if not codex:
        return claude, False
    try:
        help_text = run([codex, "exec", "--help"], capture_output=True, text=True, check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return claude, False
    flags = set(re.findall(r"(?<![\w-])--[\w-]+", help_text))
    return claude, {"--json", "--output-last-message", "--sandbox"} <= flags


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


def route(claude, codex, only=None):
    if only:
        selected = claude if only == "claude" else codex
        return "pause" if selected and selected["tight"] else "default"
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


def budget(now=None, only=None):
    now = now or time.time()
    readers = {"claude": read_claude, "codex": read_codex}
    sides = {p: side(*readers[p](), now) for p in ((only,) if only else PROVIDERS)}
    return [*(fmt(p, s) for p, s in sides.items()),
            f"route: {route(sides.get('claude'), sides.get('codex'), only)}"]


def model(provider, tier, *, visual=False, path=CODEX_MODELS):
    claude_model, family, effort = TIERS[tier]
    if provider == "claude":
        return f"--model {claude_model}"
    if visual:
        family = CODEX_VISUAL_FAMILIES.get(tier, family)
    flags = f"-c model_reasoning_effort={effort}"
    try:
        models = json.loads(path.read_text())
        models = models.get("models", models) if isinstance(models, dict) else models
        hits = [m for m in models if m.get("visibility") == "list" and family in m.get("slug", "").split("-")]

        def newest(m):
            # shortcut: infer release order from GPT slug versions, use release metadata if the cache adds it
            version = re.match(r"gpt-(\d+(?:\.\d+)*)-", m["slug"])
            numbers = tuple(map(int, version[1].split("."))) if version else ()
            return numbers, -m.get("priority", 999)

        best = max(hits, key=newest)
        return f"-m {best['slug']} {flags}"
    except Exception:
        return flags  # family not found: user's default model


def self_test():
    import tempfile
    from unittest.mock import patch

    assert host({"CODEX_THREAD_ID": "1"}) == "codex"
    assert host({"CLAUDE_CODE_ENTRYPOINT": "cli"}) == "claude"
    assert host({"CODEX_THREAD_ID": "1", "CLAUDE_CODE_ENTRYPOINT": "cli"}) == "codex"
    assert host({"CLAUDECODE": "1"}) == "claude"
    assert host({}) == "other"

    def help_output(command, **kwargs):
        assert command == ["/bin/codex", "exec", "--help"]
        return subprocess.CompletedProcess(command, 0, stdout="--json --output-last-message --sandbox")

    def incomplete_help(command, **kwargs):
        return subprocess.CompletedProcess(command, 0, stdout="--json --output-last-message --sandbox-mode")

    assert available(lambda name: f"/bin/{name}", help_output) == (True, True)
    assert available(lambda name: None, help_output) == (False, False)
    assert available(lambda name: f"/bin/{name}", incomplete_help) == (True, False)

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
    with patch(f"{__name__}.read_claude", return_value=((10, now + 60), (0, now + 86400))) as claude:
        with patch(f"{__name__}.read_codex", return_value=((90, now + 60), (0, now + 86400))) as codex:
            claude_budget = budget(now, only="claude")
            codex.assert_not_called()
            assert len(claude_budget) == 2 and claude_budget[0].startswith("claude: 5h ")
            assert claude_budget[0].endswith(" · ok") and claude_budget[1] == "route: default"
            claude.reset_mock()
            codex_budget = budget(now, only="codex")
            claude.assert_not_called()
            assert len(codex_budget) == 2 and codex_budget[0].startswith("codex: 5h ")
            assert codex_budget[0].endswith(" · TIGHT") and codex_budget[1] == "route: pause"
    assert route(None, None, "codex") == "default"
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
        # Pick the newest visible model even when an older model has higher priority.
        (d / "m.json").write_text(json.dumps({"models": [
            {"slug": "gpt-6.1-sol", "visibility": "list", "priority": 1},
            {"slug": "gpt-6.2-sol", "visibility": "list", "priority": 5},
            {"slug": "gpt-9-sol", "visibility": "hide", "priority": 0},
            {"slug": "gpt-6-luna", "visibility": "list", "priority": 8},
            {"slug": "gpt-6.1-terra", "visibility": "list", "priority": 8},
            {"slug": "gpt-6.2-astra", "visibility": "list", "priority": 8}]}))
        cache = d / "m.json"
        assert {tier: model("claude", tier) for tier in TIERS} == {
            "light": "--model haiku", "standard": "--model sonnet", "deep": "--model opus",
        }
        assert model("codex", "light", path=cache) == "-m gpt-6-luna -c model_reasoning_effort=low"
        assert model("codex", "standard", path=cache) == "-m gpt-6.2-sol -c model_reasoning_effort=medium"
        assert model("codex", "deep", path=cache) == "-m gpt-6.2-astra -c model_reasoning_effort=high"
        assert model("codex", "light", visual=True, path=cache) == "-m gpt-6.1-terra -c model_reasoning_effort=low"
        cache.write_text('{"models": []}')
        assert model("codex", "deep", path=cache) == "-c model_reasoning_effort=high"
    print("self-test ok")


if __name__ == "__main__":
    a = sys.argv[1:]
    if a == ["--self-test"]:
        self_test()
    elif a == ["host"]:
        print(host(os.environ))
    elif a == ["available"]:
        for provider, present in zip(PROVIDERS, available()):
            print(f"{provider}: {'yes' if present else 'no'}")
    elif a == ["budget"]:
        print("\n".join(budget()))
    elif len(a) == 3 and a[:2] == ["budget", "--only"] and a[2] in PROVIDERS:
        print("\n".join(budget(only=a[2])))
    elif (a[:1] == ["model"] and len(a) >= 3 and a[1] in PROVIDERS
          and a[2] in TIERS and a[3:] in ([], ["--visual"])):
        print(model(a[1], a[2], visual=len(a) == 4))
    else:
        sys.exit(__doc__)
