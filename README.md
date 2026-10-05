# TunnelForge

**Tunnel Experimentation & Deployment Platform for two-VPS paths.**

TunnelForge deploys, validates, benchmarks and cleans up tunnel/relay methods between an Iran VPS and a Foreign VPS without confusing an active process with a working data path.

```text
Client -> Iran VPS : service_port -> Selected Tunnel -> Foreign VPS -> destination_host:destination_port -> Xray/TCP service
```

## Interactive UI

Run the command without arguments:

```bash
sudo tunnelforge
```

TunnelForge opens an interactive terminal dashboard with numbered choices for setup, Iran/Foreign role deployment, tunnel selection, status, H3/H4 tests, benchmark, history and cleanup. The normal CLI remains available for automation.

## Health model

H0 Process -> H1 Listener -> H2 Transport -> **H3 authenticated byte path through the selected driver** -> H4 direct Foreign destination probe -> H5 explicit real-user verification.

H5 is never inferred automatically.

## Stable / Experimental

Stable: `gre`, `haproxy`, `rinetd`, `socat`, `gost`, `wstunnel`.

Experimental catalog: WireGuard, FRP, Chisel, Rathole, Backhaul TCPMUX.

### GRE reference path

GRE is aligned to the real path that passed the user's live client test:

```text
Client
 -> Iran :2020 (socat)
 -> GRE 10.202.0.1/30 <-> 10.202.0.2/30
 -> Foreign 10.202.0.2:2020 (socat)
 -> 127.0.0.1:2020
 -> existing destination service
```

A destination already bound to `127.0.0.1:2020` is valid and no longer incorrectly blocks GRE deployment on `10.202.0.2:2020`.

## Install

```bash
git clone https://github.com/TIR3D4/TunnelForge.git
cd TunnelForge
sudo bash install.sh
sudo tunnelforge
```

For Manual Mode, configure once and use **Generate Manual Commands** from the menu. Run the generated Foreign command first and Iran command second.

## CLI

```text
tunnelforge
tunnelforge init
tunnelforge drivers
tunnelforge commands DRIVER
tunnelforge deploy DRIVER iran|foreign
tunnelforge orchestrate DRIVER
tunnelforge status
tunnelforge test
tunnelforge app-test
tunnelforge verify yes|no
tunnelforge benchmark L1|L2|L3|L4 [--yes]
tunnelforge next
tunnelforge auto
tunnelforge history
tunnelforge down
```

## Security

TunnelForge does not modify Xray, globally flush firewalls, broadly kill processes, or remove unrelated services. GOST/wstunnel binaries are version-pinned and SHA256-verified. Runtime secrets stay outside Git.

See `docs/ARCHITECTURE.md`, `docs/HEALTH_MODEL.md`, `docs/LAB_HISTORY.md`, `SECURITY.md`, and `docs/ROADMAP.md`.
