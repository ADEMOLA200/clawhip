#!/bin/bash
# clawhip × OMC — Send a prompt to an existing OMC session
# Usage: prompt.sh <session-name> "<prompt-text>"

set -euo pipefail

SESSION="${1:?Usage: $0 <session-name> \"<prompt-text>\"}"
PROMPT="${2:?Usage: $0 <session-name> \"<prompt-text>\"}"

if ! tmux has-session -t "$SESSION" 2>/dev/null; then
  echo "❌ Session not found: $SESSION"
  exit 1
fi

# Send the prompt text followed by Enter
tmux send-keys -t "$SESSION" "$PROMPT" Enter

echo "✓ Sent to $SESSION (unverified): ${PROMPT:0:80}..."
