#!/usr/bin/env bash

set -euo pipefail

TARGET_PATH="${1:-$PWD}"
CLAUDE_SETTINGS="${CLAUDE_SETTINGS:-$HOME/.claude/settings.json}"

if ! command -v code >/dev/null 2>&1; then
  echo "error: VS Code CLI 'code' was not found in PATH." >&2
  echo "hint: In VS Code, run 'Shell Command: Install 'code' command in PATH'." >&2
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "error: python3 is required to read Claude settings." >&2
  exit 1
fi

if [ ! -f "$CLAUDE_SETTINGS" ]; then
  echo "error: Claude settings file not found: $CLAUDE_SETTINGS" >&2
  echo "hint: Run 'npx aihezu@2.8.8 config claude' first, or set CLAUDE_SETTINGS." >&2
  exit 1
fi

if [ ! -e "$TARGET_PATH" ]; then
  echo "error: target path does not exist: $TARGET_PATH" >&2
  exit 1
fi

mapfile -t CLAUDE_VALUES < <(
  python3 - "$CLAUDE_SETTINGS" <<'PY'
import json
import sys

settings_path = sys.argv[1]
with open(settings_path, "r", encoding="utf-8") as f:
    data = json.load(f)

env = data.get("env") or {}
base_url = env.get("ANTHROPIC_BASE_URL", "")
auth_token = env.get("ANTHROPIC_AUTH_TOKEN", "")
model = data.get("model", "")

print(base_url)
print(auth_token)
print(model)
PY
)

BASE_URL="${CLAUDE_VALUES[0]:-}"
AUTH_TOKEN="${CLAUDE_VALUES[1]:-}"
DEFAULT_MODEL_FROM_SETTINGS="${CLAUDE_VALUES[2]:-}"

if [ -z "$BASE_URL" ] || [ -z "$AUTH_TOKEN" ]; then
  echo "error: missing ANTHROPIC_BASE_URL or ANTHROPIC_AUTH_TOKEN in $CLAUDE_SETTINGS" >&2
  exit 1
fi

MODEL_TO_USE="${ANTHROPIC_MODEL:-$DEFAULT_MODEL_FROM_SETTINGS}"

mask_token() {
  local token="$1"
  local len="${#token}"
  if [ "$len" -le 8 ]; then
    printf '***'
  else
    printf '***%s' "${token: -8}"
  fi
}

echo "Starting VS Code with Claude proxy env"
echo "  target: $TARGET_PATH"
echo "  base_url: $BASE_URL"
echo "  auth_token: $(mask_token "$AUTH_TOKEN")"
if [ -n "$MODEL_TO_USE" ]; then
  echo "  model: $MODEL_TO_USE"
fi

if [ -n "$MODEL_TO_USE" ]; then
  ANTHROPIC_BASE_URL="$BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$AUTH_TOKEN" \
  ANTHROPIC_MODEL="$MODEL_TO_USE" \
  code "$TARGET_PATH"
else
  ANTHROPIC_BASE_URL="$BASE_URL" \
  ANTHROPIC_AUTH_TOKEN="$AUTH_TOKEN" \
  code "$TARGET_PATH"
fi
