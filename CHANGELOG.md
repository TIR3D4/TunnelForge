# Changelog

All notable changes to this project will be documented in this file.

The format is inspired by Keep a Changelog and the project follows semantic versioning where practical during pre-1.0 development.

## [Unreleased]

### Planned
- Cross-node SSH orchestration
- Architecture-aware binary downloads
- Upstream artifact checksum verification
- Automated benchmarks and broader integration tests

## [0.1.0] - 2026-10-05

### Added
- Driver-based two-node tunnel manager
- HAProxy, rinetd, socat, GOST, wstunnel, and GRE drivers
- Persistent configuration, state, history, and logs
- Explicit H5 user verification model
- IPv4 and port validation
- CLI help/version commands
- Bash syntax test suite and GitHub Actions CI
- Project documentation, contribution guide, security policy, and issue/PR templates

### Fixed
- GOST and wstunnel Iran-side preflight now correctly fail when the service port is already occupied
- Installer now resolves project files relative to its own location instead of the caller's working directory
