---
name: clawhip
description: Configure and manage clawhip — the event-to-channel notification router that whips your clawdbot into shape
---

# clawhip 🦞🔥

**claw + whip** — Standalone event-to-channel notification router for Discord.

clawhip receives events (GitHub, tmux, custom) via CLI or webhook and routes them to Discord channels based on configurable rules — bypassing gateway sessions entirely.

## Prerequisites

```bash
# Install clawhip (Rust binary)
cargo install --git https://github.com/Yeachan-Heo/clawhip

# Or build from local clone
cd ~/Workspace/clawhip && cargo install --path .
```

## Setup

### 1. Initialize config

```bash
# Interactive setup
clawhip config

# Or manually set essentials
clawhip config set token <DISCORD_BOT_TOKEN>
clawhip config set default-channel <CHANNEL_ID>
```

Config lives at `~/.clawhip/config.toml`.

### 2. Add routes

Routes map events to channels with optional filters:

```toml
# ~/.clawhip/config.toml

[discord]
token = "your-bot-token"
default_channel = "1468539002985644084"

[[routes]]
event = "github.*"
filter = { repo = "oh-my-claudecode" }
channel = "1468539002985644084"
format = "compact"

[[routes]]
event = "github.ci-failed"
filter = { repo = "oh-my-claudecode" }
channel = "1468539002985644084"
format = "alert"
mention = "<@1465264645320474637>"

[[routes]]
event = "tmux.*"
filter = { session = "issue-*" }
channel = "1468539002985644084"
format = "inline"
```

### 3. Test it

```bash
# Send a test notification
clawhip custom --channel 1468539002985644084 --message "clawhip is alive! 🦞🔥"
```

## Usage

### Send events via CLI (gateway)

```bash
# Custom notification
clawhip custom --channel <id> --message "Build complete!"

# GitHub events
clawhip github issue-opened --repo oh-my-claudecode --number 1460 --title "Bug in setup"

# tmux keyword detection
clawhip tmux keyword --session issue-123 --keyword "error" --line "Error: build failed"

# Pipe JSON events
echo '{"type":"custom","channel":"1468539002985644084","message":"Hello!"}' | clawhip stdin
```

### tmux wrapper (auto-monitoring)

Launch tmux sessions with built-in monitoring:

```bash
clawhip tmux new -s issue-123 \
  --channel 1468539002985644084 \
  --mention "<@1465264645320474637>" \
  --keywords "error,PR created,FAILED,complete" \
  --stale-minutes 10 \
  -- omx --madmax
```

This wraps tmux and automatically:
- Monitors pane output for configured keywords
- Detects staleness (no output for N minutes)
- Fires events to Discord when patterns match

### HTTP webhook server

```bash
# Start webhook receiver (for GitHub webhooks etc)
clawhip serve --port 8765
```

### Git integration

Install git hooks that auto-notify on commits:

```bash
# In any git repo
~/Workspace/clawhip/integrations/git/install-hooks.sh
```

### tmux integration (cron)

```bash
# Add to crontab for periodic keyword/stale checks
*/5 * * * * ~/Workspace/clawhip/integrations/tmux/scan-keywords.sh
*/10 * * * * ~/Workspace/clawhip/integrations/tmux/stale-check.sh
```

## Route Filtering

Same event type → different channels based on payload:

```toml
[[routes]]
event = "github.*"
filter = { repo = "oh-my-claudecode" }
channel = "1468539002985644084"  # #omc-dev

[[routes]]
event = "github.*"
filter = { repo = "clawhip" }
channel = "1468539002985644084"  # same or different channel
```

Glob patterns supported: `issue-*`, `feat/*`, etc.

## Message Formats

| Format | Use Case | Example |
|--------|----------|---------|
| `compact` | Routine updates | **[PR merged]** fix: dedupe notifications |
| `alert` | Failures/urgent | 🚨 **CI Failed** — oh-my-claudecode#1453 |
| `inline` | tmux events | `issue-1440` → PR created |
| `raw` | Custom messages | Whatever you send |

## Config management

```bash
clawhip config show        # Show current config
clawhip config             # Interactive editor
clawhip config path        # Show config file path
```

## Architecture

```
[Git hook / tmux hook / cron / script]
        ↓
  clawhip CLI or HTTP webhook
        ↓
  Route engine (event + filter matching)
        ↓
  Discord REST API → Channel
```

No gateway. No session pollution. Just events in, messages out.

## Repo

- GitHub: <https://github.com/Yeachan-Heo/clawhip> (private)
- Local: `~/Workspace/clawhip`
- Binary: `~/.cargo/bin/clawhip` (after cargo install)
