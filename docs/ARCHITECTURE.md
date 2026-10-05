# Architecture

## Design goals

TunnelForge keeps orchestration logic separate from transport-specific implementation. The core owns state, validation, logging and lifecycle sequencing; each driver owns only the commands necessary to install, configure, start, check and remove one transport.

## Runtime layout

| Path | Purpose |
|---|---|
| `/usr/local/bin/tunnelforge` | User-facing CLI |
| `/opt/tunnelforge/core/` | Shared helpers and controller |
| `/opt/tunnelforge/drivers/` | Driver implementations |
| `/opt/tunnelforge/docs/` | Installed documentation snapshot |
| `/etc/tunnelforge/config.env` | Node addresses and ports |
| `/var/lib/tunnelforge/state.env` | Active deployment state |
| `/var/lib/tunnelforge/history.log` | Lifecycle/verification audit trail |
| `/var/log/tunnelforge/tunnelforge.log` | Runtime log |

## Lifecycle

`up` follows the same contract for every driver:

1. Validate role and driver name.
2. Load and validate global configuration.
3. Source the selected driver.
4. Run `driver_preflight`.
5. Run `driver_install`.
6. Run `driver_configure`.
7. Run `driver_start`.
8. Run `driver_health`.
9. Persist active state only after the health step succeeds.

`down` loads the active state and invokes `driver_cleanup` for the recorded driver and role.

## Driver contract

Every `drivers/<name>.sh` file must define:

```bash
driver_preflight() { ...; }
driver_install() { ...; }
driver_configure() { ...; }
driver_start() { ...; }
driver_health() { ...; }
driver_cleanup() { ...; }
```

Drivers may use helpers exported by `core/common.sh`, including `die`, `port_free`, `owned_stop`, and validated configuration variables.

## Ownership boundaries

TunnelForge should avoid altering unrelated services. Dedicated units use a `tunnelforge-*` name. The HAProxy and rinetd drivers use distribution-managed service names because they configure those packages directly; operators should not use those drivers on hosts where an existing HAProxy/rinetd configuration must be preserved.

TunnelForge does not modify Xray configuration.

## Verification model

Technical process/listener checks are not equivalent to application success. `USER_VERIFIED` therefore starts as `unknown` and can only be set by an explicit `tunnelforge verify yes|no` command after a real client test.

## Current scope

v0.1.x intentionally uses manual two-node orchestration. SSH orchestration, cross-node deployment transactions, automatic rollback, benchmarks, and deeper integration testing are future work.
