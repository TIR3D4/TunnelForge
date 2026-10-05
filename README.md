# TunnelForge

**Tunnel Experimentation & Deployment Platform for two-VPS paths.**

TunnelForge deploys, validates, benchmarks and cleans up tunnel/relay methods between an Iran VPS and a Foreign VPS without confusing an active process with a working data path.

## Core path
```text
Client -> Iran VPS : service_port -> Selected Tunnel -> Foreign VPS -> destination_host:destination_port -> Xray/TCP service
```

TunnelForge never manages Xray. `service_port` is the client-facing Iran port; `destination_host:destination_port` is the existing Foreign service; `transport_port` is internal to relay drivers.

## Health model
H0 Process -> H1 Listener -> H2 Transport -> **H3 authenticated real byte path** -> H4 application TCP -> H5 explicit user verification.

## Stable drivers
`gre`, `haproxy`, `rinetd`, `socat`, `gost`, and `wstunnel` are Stable because the supplied lab history recorded real client success. WireGuard, FRP, Chisel, Rathole and Backhaul TCPMUX remain in `experimental/` instead of being deleted.

## Install
```bash
git clone https://github.com/TIR3D4/TunnelForge.git
cd TunnelForge
sudo bash install.sh
sudo tunnelforge init
```

Generate safe Manual Mode commands:
```bash
sudo tunnelforge commands wstunnel
```
Run the **Foreign Command first**, then the **Iran Command**. The generated commands contain a shared H3 health token, so do not publish them.

Check the actual path:
```bash
tunnelforge status
sudo tunnelforge test
```
Only after the real client/Xray configuration works:
```bash
sudo tunnelforge verify yes
```

## SSH orchestration
After configuring `ssh_user`, `ssh_port`, and optional local `ssh_key` path in `/etc/tunnelforge/config.toml`, and installing TunnelForge on both VPSs:
```bash
sudo tunnelforge orchestrate wstunnel
```
Foreign is deployed first. If the Iran transaction fails, both nodes are cleaned.

## Commands
```text
tunnelforge init
tunnelforge drivers
tunnelforge commands DRIVER
tunnelforge deploy DRIVER iran|foreign
tunnelforge orchestrate DRIVER
tunnelforge status
tunnelforge test
tunnelforge verify yes|no
tunnelforge benchmark L1|L2|L3|L4 [--yes]
tunnelforge next
tunnelforge auto
tunnelforge history
tunnelforge down
```

## Benchmark safety
L1=1, L2=50, L3=250, L4=1000 concurrent authenticated echo paths. L3+ requires `--yes`; L2+ requires H5=yes. The benchmark avoids mutating Xray payloads.

## Security
No unknown installer scripts, broad `pkill`, global firewall flush, or Xray modification. GOST/wstunnel official release assets are pinned and SHA256 verified. Custom units use `tunnelforge-*`.

See `docs/ARCHITECTURE.md`, `docs/HEALTH_MODEL.md`, `docs/LAB_HISTORY.md`, `SECURITY.md`, and `docs/ROADMAP.md`.
