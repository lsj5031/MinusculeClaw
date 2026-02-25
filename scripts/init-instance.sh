#!/usr/bin/env bash
set -euo pipefail

CODE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <instance-dir>"
  echo ""
  echo "Scaffold a new ShellClaw instance directory."
  echo "Then run:  $CODE_DIR/agent.sh --instance-dir <instance-dir>"
  exit 1
fi

instance_dir="$1"
[[ "$instance_dir" != /* ]] && instance_dir="$(pwd)/$instance_dir"

if [[ -f "$instance_dir/.env" ]]; then
  echo "instance already exists: $instance_dir" >&2
  exit 1
fi

mkdir -p "$instance_dir"/{LOGS,runtime,tmp,TASKS,config}

cp "$CODE_DIR/.env.example" "$instance_dir/.env"
cp "$CODE_DIR/SOUL.md" "$instance_dir/SOUL.md"
if [[ -f "$CODE_DIR/USER.md.example" ]]; then
  cp "$CODE_DIR/USER.md.example" "$instance_dir/USER.md"
else
  touch "$instance_dir/USER.md"
fi
touch "$instance_dir/MEMORY.md"
touch "$instance_dir/TASKS/pending.md"
if [[ -f "$CODE_DIR/config/allowlist.txt" ]]; then
  cp "$CODE_DIR/config/allowlist.txt" "$instance_dir/config/allowlist.txt"
else
  touch "$instance_dir/config/allowlist.txt"
fi

# Initialize SQLite database
sqlite3 "$instance_dir/state.db" < "$CODE_DIR/sql/schema.sql"

echo "✓ Instance created at: $instance_dir"
echo ""
echo "Next steps:"
echo "  1. Edit $instance_dir/.env  (set TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID, etc.)"
echo "  2. Edit $instance_dir/SOUL.md  (customize personality)"
echo "  3. Run:  $CODE_DIR/agent.sh --instance-dir $instance_dir"
