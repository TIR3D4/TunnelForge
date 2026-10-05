# TunnelForge

> A lightweight, driver-based toolkit for deploying and validating two-node Linux tunnels.

[![CI](https://github.com/TIR3D4/TunnelForge/actions/workflows/ci.yml/badge.svg)](https://github.com/TIR3D4/TunnelForge/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/Bash-5%2B-4EAA25?logo=gnubash&logoColor=white)](https://www.gnu.org/software/bash/)

TunnelForge provides one consistent CLI around multiple TCP/L3 tunneling approaches. Each transport is isolated in a small driver, while the core controller handles configuration, lifecycle, state, health checks, history, and explicit user verification.

## Features

- Modular driver architecture
- HAProxy, rinetd, socat, GOST, wstunnel, and GRE drivers
- Two explicit node roles: `iran` and `foreign`
- Persistent deployment state and audit history
- Health checks plus explicit real-client verification
- systemd-managed long-running services
- Input validation for IPv4 addresses and ports
- Bash syntax and ShellCheck CI
- Minimal host changes; TunnelForge-owned units use the `tunnelforge-*` prefix where applicable

## Supported environment

TunnelForge targets modern Debian/Ubuntu-style Linux systems using systemd. Installation and tunnel lifecycle commands require root privileges. Some drivers install packages with `apt-get`, and binary-backed drivers currently target `linux/amd64`.

## Quick start

Clone the repository and install:

```bash
git clone https://github.com/TIR3D4/TunnelForge.git
cd TunnelForge
sudo bash install.sh
sudo tunnelforge init
```

List available drivers:

```bash
tunnelforge drivers
```

Deploy the same driver on both servers. Run the command matching each server's role:

```bash
sudo tunnelforge up wstunnel foreign
sudo tunnelforge up wstunnel iran
```

Then inspect and test:

```bash
tunnelforge status
tunnelforge test
sudo tunnelforge verify yes
```

To remove the active TunnelForge deployment:

```bash
sudo tunnelforge down
```

## How it works

```text
CLI (/usr/local/bin/tunnelforge)
        |
        v
Core controller + shared helpers
        |
        +---- config: /etc/tunnelforge/config.env
        +---- state:  /var/lib/tunnelforge/state.env
        +---- log:    /var/log/tunnelforge/tunnelforge.log
        |
        v
Selected driver
  |-- haproxy
  |-- rinetd
  |-- socat
  |-- gost
  |-- wstunnel
  `-- gre
```

See [Architecture](docs/ARCHITECTURE.md) for lifecycle and extension details.

## Driver matrix

| Driver | Mode | Iran node | Foreign node | Status |
|---|---|---|---|---|
| HAProxy | Direct TCP | TCP forwarder | Existing target service | Lab verified |
| rinetd | Direct TCP | TCP forwarder | Existing target service | Lab verified |
| socat | Direct TCP | TCP forwarder | Existing target service | Lab verified |
| GOST | Relay TCP | Local forwarder | Relay listener | Lab verified |
| wstunnel | WebSocket/TCP | Client/listener | Server listener | Lab verified |
| GRE | L3 GRE | GRE endpoint | GRE endpoint | Lab verified |

“Lab verified” means the driver was included as a working experiment in the original project. It is not a guarantee of compatibility with every provider, firewall, kernel, or production workload.

## CLI

```text
tunnelforge init
tunnelforge config
tunnelforge drivers
tunnelforge up DRIVER iran|foreign
tunnelforge status
tunnelforge test
tunnelforge verify yes|no
tunnelforge history
tunnelforge down
tunnelforge version
```

Detailed command notes are in [docs/CLI.md](docs/CLI.md).

## Configuration

Default configuration file:

```text
/etc/tunnelforge/config.env
```

Example:

```dotenv
IRAN_IP=203.0.113.10
FOREIGN_IP=198.51.100.20
SERVICE_PORT=2020
TRANSPORT_PORT=30445
PROTOCOL=tcp
```

Use real public IP addresses. The example addresses above are documentation-only ranges.

## Health model

TunnelForge intentionally separates technical health from real-user verification. A local listener or successful TCP probe does not prove that the full end-user path works.

- **H0-H3**: technical process/listener/connectivity checks
- **H5**: explicit confirmation after testing the real client configuration

Record H5 only after an actual client test:

```bash
sudo tunnelforge verify yes
```

## Development

Run the local checks:

```bash
bash tests/run.sh
```

If ShellCheck is installed, the test runner uses it automatically.

## Security notes

TunnelForge performs privileged networking and service-management operations. Review configuration before deployment, restrict firewall exposure to only the ports you need, and test on disposable infrastructure before production use. Binary-backed drivers are pinned to specific upstream release versions but are downloaded at install time; see [SECURITY.md](SECURITY.md) for the current trust model and reporting guidance.

## Roadmap

Planned directions include SSH-based two-node orchestration, automated benchmarking, richer rollback/state handling, architecture-aware binary downloads, checksum verification for upstream artifacts, and broader integration tests.

## Contributing

Contributions are welcome. Read [CONTRIBUTING.md](CONTRIBUTING.md) before submitting a pull request.

## License

MIT — see [LICENSE](LICENSE).
