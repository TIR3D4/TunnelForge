# CLI reference

## `tunnelforge init`

Interactive root-only setup. Validates both public IPv4 addresses and service/transport ports before writing `/etc/tunnelforge/config.env` with mode `0600`.

## `tunnelforge config`

Loads, validates, and prints the active configuration.

## `tunnelforge drivers`

Lists bundled drivers and their transport mode.

## `tunnelforge up DRIVER iran|foreign`

Runs the selected driver's preflight, installation, configuration, startup and health lifecycle. State is persisted only after the health step succeeds.

## `tunnelforge status`

Prints the active driver/role, H5 verification state, and the driver's current health output.

## `tunnelforge test`

Runs a generic TCP probe against `127.0.0.1:SERVICE_PORT`. This is a technical check and does not infer end-user success.

## `tunnelforge verify yes|no`

Explicitly records whether a real client test succeeded.

## `tunnelforge history`

Prints the lifecycle and verification audit history.

## `tunnelforge down`

Invokes the active driver's cleanup hook and removes TunnelForge state.

## `tunnelforge version`

Prints the installed TunnelForge version.

## Health terminology

H0-H3 represent technical health stages. H5 is explicit real-user verification and is never inferred from a process state or TCP socket alone.
