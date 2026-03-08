#!/bin/bash
# clawhip × OMC — Create a monitored OMC tmux session
# Usage: create.sh <session-name> <worktree-path> [channel-id] [mention]

set -euo pipefail

SESSION="${1:?Usage: $0 <session-name> <worktree-path> [channel-id] [mention]}"
WORKDIR="${2:?Usage: $0 <session-name> <worktree-path> [channel-id] [mention]}"
CHANNEL="${3:-}"
MENTION="${4:-}"

KEYWORDS="${CLAWHIP_OMC_KEYWORDS:-error,Error,FAILED,PR created,panic,complete}"
STALE_MIN="${CLAWHIP_OMC_STALE_MIN:-30}"
OMC_FLAGS="${CLAWHIP_OMC_FLAGS:---openclaw --madmax}"
OMC_ENV="${CLAWHIP_OMC_ENV:-}"

if [ ! -d "$WORKDIR" ]; then
  echo "❌ Directory not found: $WORKDIR"
  exit 1
fi

# Build clawhip tmux new args
ARGS=(
  tmux new
  -s "$SESSION"
  -c "$WORKDIR"
  --keywords "$KEYWORDS"
  --stale-minutes "$STALE_MIN"
)

[ -n "$CHANNEL" ] && ARGS+=(--channel "$CHANNEL")
[ -n "$MENTION" ] && ARGS+=(--mention "$MENTION")

# Build the omc command
OMC_CMD="source ~/.zshrc"
[ -n "$OMC_ENV" ] && OMC_CMD="$OMC_CMD && $OMC_ENV"
OMC_CMD="$OMC_CMD && omc $OMC_FLAGS --worktree $WORKDIR"

ARGS+=(-- "$OMC_CMD")

# Launch
nohup clawhip "${ARGS[@]}" &>/dev/null &

echo "✓ Created session: $SESSION in $WORKDIR (clawhip monitored)"
echo "  Monitor: tmux attach -t $SESSION"
echo "  Tail:    $(dirname "$0")/tail.sh $SESSION"
