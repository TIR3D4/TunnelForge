#!/usr/bin/env bash
set -Eeuo pipefail

[[ $EUID -eq 0 ]] || { echo "Run as root" >&2; exit 1; }

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
INSTALL_ROOT=/opt/tunnelforge
CFG_DIR=/etc/tunnelforge
STATE_DIR=/var/lib/tunnelforge
LOG_DIR=/var/log/tunnelforge

for required in bash install systemctl ss; do
  command -v "$required" >/dev/null 2>&1 || { echo "Missing required command: $required" >&2; exit 1; }
done

install -d -m755 "$INSTALL_ROOT" "$CFG_DIR" "$STATE_DIR" "$LOG_DIR"
rm -rf "$INSTALL_ROOT/core" "$INSTALL_ROOT/drivers" "$INSTALL_ROOT/docs"
cp -a "$SCRIPT_DIR/core" "$SCRIPT_DIR/drivers" "$SCRIPT_DIR/docs" "$INSTALL_ROOT/"
install -m755 "$SCRIPT_DIR/tunnelforge" /usr/local/bin/tunnelforge

if [[ ! -f "$CFG_DIR/config.env" ]]; then
  install -m600 "$SCRIPT_DIR/config/example.env" "$CFG_DIR/config.env"
fi

install -m600 /dev/null "$STATE_DIR/history.log" 2>/dev/null || true
touch "$STATE_DIR/history.log" "$LOG_DIR/tunnelforge.log"
chmod 600 "$STATE_DIR/history.log" "$LOG_DIR/tunnelforge.log"

echo "TunnelForge installed successfully."
echo "Next step: sudo tunnelforge init"
