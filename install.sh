#!/usr/bin/env bash
set -Eeuo pipefail
[[ ${EUID:-$(id -u)} -eq 0 ]] || { echo "Run as root" >&2; exit 1; }
SRC=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd); ROOT=/opt/tunnelforge
for c in bash python3 systemctl ss awk grep sed tar base64; do command -v "$c" >/dev/null || { echo "Missing required command: $c" >&2; exit 1; }; done
install -d -m755 "$ROOT" /etc/tunnelforge/secrets /etc/tunnelforge/generated /var/lib/tunnelforge /var/log/tunnelforge /usr/local/bin
for p in VERSION cmd core drivers experimental benchmark health scripts docs config; do rm -rf "$ROOT/$p"; cp -a "$SRC/$p" "$ROOT/$p"; done
ln -sfn "$ROOT/cmd/tunnelforge.sh" /usr/local/bin/tunnelforge
chmod 755 "$ROOT/cmd/tunnelforge.sh" "$ROOT"/core/*.sh "$ROOT"/drivers/*/driver.sh "$ROOT"/health/*.py "$ROOT"/benchmark/*.py "$ROOT"/scripts/*.py
[[ -f /etc/tunnelforge/config.toml ]] || install -m600 "$SRC/config/example.toml" /etc/tunnelforge/config.toml
touch /var/lib/tunnelforge/history.jsonl /var/log/tunnelforge/tunnelforge.log
chmod 600 /etc/tunnelforge/config.toml /var/lib/tunnelforge/history.jsonl /var/log/tunnelforge/tunnelforge.log
printf 'TunnelForge %s installed.\nNext: sudo tunnelforge init\n' "$(cat "$ROOT/VERSION")"
