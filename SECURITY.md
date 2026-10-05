# Security policy

## Supported versions

The latest release in the `0.1.x` line receives security fixes while the project remains in early development.

## Reporting a vulnerability

Please do not publish exploit details in a public issue before maintainers have had a reasonable opportunity to assess the report. Use GitHub's private vulnerability reporting feature when it is enabled for this repository.

## Operational security

TunnelForge runs with root privileges and can open network listeners, install packages, create systemd services, and create GRE interfaces. Review scripts before deployment and use host/firewall controls appropriate to your environment.

GOST and wstunnel binaries are pinned to explicit upstream release versions, but v0.1.0 does not yet verify downloaded release archives with a project-maintained checksum. Treat the upstream release source and HTTPS delivery path as part of the trust boundary. Checksum verification is planned for a future release.
