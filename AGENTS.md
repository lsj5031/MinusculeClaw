# AGENTS.md — MinusculeClaw

## What this is
Bash-powered personal voice agent: Telegram ↔ ASR ↔ Codex CLI ↔ TTS. No test suite; verify manually with `./agent.sh --once` or `./agent.sh --inject-text "hello"`. Lint bash with `shellcheck agent.sh asr.sh send_telegram.sh heartbeat.sh tts_to_voice.sh lib/common.sh`.

## Architecture
- **agent.sh** — main loop: polls Telegram (or reads webhook queue), calls Codex CLI, parses marker output, sends reply.
- **lib/common.sh** — shared helpers (env loading, SQLite wrappers, logging). Sourced by all scripts via `source "$ROOT_DIR/lib/common.sh"; load_env`.
- **webhook_server.py / dashboard.py** — minimal stdlib-only Python (no deps). Webhook appends JSONL to `runtime/webhook_updates.jsonl`.
- **SQLite (`state.db`)** — schema in `sql/schema.sql`. Tables: `kv`, `turns`, `tasks`, `summaries`. Always use `sql_quote()` for values.
- **Personality/memory layer** — `SOUL.md` (system prompt), `USER.md` (user prefs), `MEMORY.md` (append-only facts), `TASKS/pending.md`.

## Codex output contract
Scripts parse Codex output for marker lines: `TELEGRAM_REPLY:`, `VOICE_REPLY:`, `MEMORY_APPEND:`, `TASK_APPEND:`. Extract with `extract_marker` / `extract_all_markers` in agent.sh.

## Code style
- Bash: `set -euo pipefail`, quote all variables, use `local` for function vars, log via `log_info`/`log_warn`/`log_debug`.
- Python: stdlib only, no third-party imports. Minimal scripts, no frameworks.
- Config: all tunables live in `.env` (see `.env.example`); scripts use `${VAR:-default}` pattern.
- Paths: resolve relative to `$ROOT_DIR`; convert with `[[ "$X" != /* ]] && X="$ROOT_DIR/$X"`.
- No markdown/code-fences in agent output — plain marker lines only.
