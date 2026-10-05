# Architecture

```text
Client -> Iran VPS:service_port -> selected driver -> Foreign VPS -> destination_host:destination_port -> Xray/TCP service

H3: Iran health listener -> same driver/transport -> authenticated Foreign echo -> exact bytes returned
```

`service_port` and `destination_port` are separate concepts. The old prototype incorrectly assumed they were always the same and could report a false H3 merely because a local listener accepted a socket.

## Runtime paths
`/etc/tunnelforge/config.toml`, `/etc/tunnelforge/secrets/`, `/var/lib/tunnelforge/state.json`, `/var/lib/tunnelforge/history.jsonl`, `/var/log/tunnelforge/`.

## Driver contract
Each Stable driver provides `preflight`, `install`, `configure`, `start`, `stop`, `status`, `health`, `cleanup`, and `metrics` functions. Core loads the contract rather than containing a large transport switch.

## Transaction
Load/validate -> clean previous TunnelForge-owned deployment -> preflight -> install -> configure -> start -> health -> commit state. Any failure before commit invokes driver cleanup and clears state.

The v0.1 CLI remains modular Bash because privileged work is predominantly systemd/network/package operations. Boundaries are intentionally designed so command/config/state orchestration can later migrate to Go without rewriting all drivers.
