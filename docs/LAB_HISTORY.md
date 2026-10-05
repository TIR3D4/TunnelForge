# Lab History

Reference environment from the supplied Master Spec: Iran Ubuntu 24.04, Foreign Ubuntu 22.04, destination Xray TCP :2020.

## User-verified successes
- GRE
- HAProxy
- rinetd
- socat
- GOST relay
- wstunnel WebSocket

## Failed or inconclusive
- WireGuard: UDP return path problem; Iran received 0 bytes.
- FRP: control login succeeded but real proxy path failed.
- Chisel: WS/SSH handshake failed.
- Rathole: control/listener existed but was unstable and real config failed.
- Backhaul TCPMUX: control/mux existed but real data path failed.

These results are evidence from one real lab, not universal claims about the upstream projects.
