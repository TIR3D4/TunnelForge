# TunnelForge

**Tunnel Experimentation & Deployment Platform for two-VPS paths.**

TunnelForge deploys, validates, benchmarks and cleans up tunnel/relay methods between an Iran VPS and a Foreign VPS without confusing an active process with a working data path.

```text
Client -> Iran VPS : service_port -> Selected Tunnel -> Foreign VPS -> destination_host:destination_port -> Xray/TCP service
```

`service_port` is the client-facing Iran port. `destination_host:destination_port` is the existing Foreign service. `transport_port` is internal to relay drivers. TunnelForge never manages Xray.

## Health model
H0 Process -> H1 Listener -> H2 Transport -> **H3 authenticated byte path through the selected driver** -> H4 direct Foreign destination probe -> H5 explicit real-user verification.

H4 is deliberately **not** inferred by connecting to the Iran listener; that was a false-positive failure mode in the original prototype. In Manual Mode run `tunnelforge app-test` on Foreign. Orchestrated Mode runs it automatically. H5 always remains explicit.

## Stable / Experimental
Stable: `gre`, `haproxy`, `rinetd`, `socat`, `gost`, `wstunnel`. Experimental catalog: WireGuard, FRP, Chisel, Rathole, Backhaul TCPMUX. These statuses come from the supplied real lab history and are not universal claims about upstream projects.

## Quick start
```bash
git clone https://github.com/TIR3D4/TunnelForge.git
cd TunnelForge
sudo bash install.sh
sudo tunnelforge init
sudo tunnelforge commands wstunnel
```
Run the generated Foreign Command first, then Iran Command. The commands embed a shared H3 token; treat them as sensitive.

On Iran:
```bash
tunnelforge status
sudo tunnelforge test
```
On Foreign:
```bash
sudo tunnelforge app-test
```
After the real client/Xray config works:
```bash
sudo tunnelforge verify yes
```

## Orchestrated SSH mode
Configure SSH fields in `/etc/tunnelforge/config.toml` and install TunnelForge on both VPSs, then:
```bash
sudo tunnelforge orchestrate wstunnel
```
Foreign is deployed first, Iran second; H3 and Foreign H4 are checked; failure cleans both sides. `auto` is available only for orchestrated mode.

## Commands
```text
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

## Benchmark / security
L1=1, L2=50, L3=250, L4=1000 authenticated echo connections. L3+ requires `--yes`; L2+ requires H5=yes. GOST and wstunnel official release assets are version-pinned and SHA256-verified. No unknown installer scripts, broad `pkill`, firewall flush, or Xray modification are used.

See `docs/ARCHITECTURE.md`, `docs/HEALTH_MODEL.md`, `docs/LAB_HISTORY.md`, `SECURITY.md`, and `docs/ROADMAP.md`.
