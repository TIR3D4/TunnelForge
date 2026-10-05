# Contributing

Thanks for improving TunnelForge.

## Development workflow

1. Fork the repository and create a focused branch.
2. Keep transport-specific logic inside `drivers/`.
3. Keep common validation/state/logging logic inside `core/`.
4. Run `bash tests/run.sh` before opening a pull request.
5. Update documentation when behavior or CLI output changes.
6. Avoid unrelated formatting changes in the same pull request.

## Driver requirements

A new driver must implement the complete driver contract documented in `docs/ARCHITECTURE.md`. Cleanup should remove only resources owned by that driver. Long-running custom services should use a `tunnelforge-*` systemd unit name.

## Pull requests

Describe the problem, implementation, test method, supported distributions/architectures, and any host-level side effects. Networking changes should include a rollback or cleanup path.
