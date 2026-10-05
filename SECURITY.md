# Security Policy

TunnelForge performs privileged networking operations. Review changes as root-level infrastructure code.

## Rules
- Never commit SSH keys, tokens, or production credentials.
- TunnelForge does not install, edit, restart, or delete Xray.
- No third-party installer scripts are used.
- GOST and wstunnel assets are version-pinned and SHA256-verified.
- Runtime secrets live under `/etc/tunnelforge/secrets/` with restrictive permissions.
- Cleanup may touch only TunnelForge-owned resources.
- No global firewall flushes or broad process kills are permitted.

Use GitHub private vulnerability reporting when available. The authenticated H3 health port should be restricted to the Iran VPS with provider/cloud firewall rules when practical.
