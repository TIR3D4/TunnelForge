# Health Model

TunnelForge never equates `active`, `LISTEN`, TCP acceptance, or a control channel with a working tunnel.

- **H0 PROCESS** — service/process is alive.
- **H1 LISTENER** — required local listeners exist.
- **H2 TRANSPORT** — transport/control is established when applicable.
- **H3 DATA_PATH** — authenticated bytes traverse the selected driver to the Foreign health endpoint and return.
- **H4 APPLICATION** — the configured destination path accepts an application TCP connection.
- **H5 USER_VERIFIED** — the user explicitly confirms the real client configuration works.

FRP, Rathole and Backhaul in the supplied lab history are examples of why H2 must not be promoted to success.
