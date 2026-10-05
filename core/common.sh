#!/usr/bin/env bash
# Shared runtime helpers for TunnelForge.

CFG=/etc/tunnelforge/config.env
STATE=/var/lib/tunnelforge/state.env
HISTORY=/var/lib/tunnelforge/history.log
LOG=/var/log/tunnelforge/tunnelforge.log
INSTALL_ROOT=/opt/tunnelforge

log(){ printf '[%s] %s\n' "$(date '+%F %T')" "$*" | tee -a "$LOG"; }
die(){ log "ERROR: $*"; exit 1; }
root_only(){ [[ $EUID -eq 0 ]] || die "Run as root"; }
command_exists(){ command -v "$1" >/dev/null 2>&1; }

validate_ipv4(){
  local ip=$1 IFS=. octets=()
  read -r -a octets <<<"$ip"
  [[ ${#octets[@]} -eq 4 ]] || return 1
  local o
  for o in "${octets[@]}"; do
    [[ $o =~ ^[0-9]{1,3}$ ]] || return 1
    ((10#$o >= 0 && 10#$o <= 255)) || return 1
  done
}

validate_port(){
  [[ $1 =~ ^[0-9]+$ ]] || return 1
  (( $1 >= 1 && $1 <= 65535 ))
}

load_cfg(){
  [[ -f "$CFG" ]] || die "Missing config: $CFG (run: tunnelforge init)"
  # shellcheck disable=SC1090
  set -a; source "$CFG"; set +a
  validate_ipv4 "${IRAN_IP:-}" || die "Invalid IRAN_IP in $CFG"
  validate_ipv4 "${FOREIGN_IP:-}" || die "Invalid FOREIGN_IP in $CFG"
  validate_port "${SERVICE_PORT:-}" || die "Invalid SERVICE_PORT in $CFG"
  validate_port "${TRANSPORT_PORT:-}" || die "Invalid TRANSPORT_PORT in $CFG"
}

record(){ printf '%s\t%s\n' "$(date -Is)" "$*" >>"$HISTORY"; }
driver_path(){ printf '%s/drivers/%s.sh\n' "$INSTALL_ROOT" "$1"; }
require_driver(){ [[ -f "$(driver_path "$1")" ]] || die "Unknown driver: $1"; }
port_free(){ ! ss -lnt 2>/dev/null | grep -qE ":$1[[:space:]]"; }
owned_stop(){ systemctl disable --now "$1" 2>/dev/null || true; }
