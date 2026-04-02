# Changelog

## 0.5.1 - 2026-04-02

### Highlights

- made native OMX hook envelopes a first-class clawhip integration surface
- added tmux watch audit trail and active watch listing
- made the CI batch window configurable
- fixed route-channel handling for tmux session startup events

### Upgrade notes

- crate version is now `0.5.1`
- no config migration is required for this patch release

## 0.3.0 - 2026-03-09

### Highlights

- introduced the typed internal event model used by the dispatcher pipeline
- generalized routing so one event can fan out to multiple deliveries
- extracted git, GitHub, and tmux monitoring into explicit event sources
- split rendering from transport and shipped the Discord sink on top of that boundary
- kept existing CLI and HTTP event ingress compatible while normalizing into the new architecture

### Upgrade notes

- crate version is now `0.3.0`
- `[providers.discord]` is the preferred config surface; legacy `[discord]` remains compatible
- routes may set `sink = "discord"`; omitting it still defaults to Discord in this release
