#!/usr/bin/env bash
# High-level lifecycle orchestration.

TF_VERSION="0.1.0"

prompt_ipv4(){
  local label=$1 value
  while true; do
    read -rp "$label: " value
    validate_ipv4 "$value" && { printf '%s' "$value"; return; }
    echo "Invalid IPv4 address. Try again." >&2
  done
}

prompt_port(){
  local label=$1 default=$2 value
  while true; do
    read -rp "$label [$default]: " value
    value=${value:-$default}
    validate_port "$value" && { printf '%s' "$value"; return; }
    echo "Invalid port. Enter a value between 1 and 65535." >&2
  done
}

tf_init(){
  root_only
  local i f p tp
  i=$(prompt_ipv4 "Iran public IP")
  f=$(prompt_ipv4 "Foreign public IP")
  p=$(prompt_port "Service port" "2020")
  tp=$(prompt_port "Transport port" "30445")
  [[ "$p" != "$tp" ]] || die "SERVICE_PORT and TRANSPORT_PORT must be different"

  cat >"$CFG" <<EOF_CFG
IRAN_IP=$i
FOREIGN_IP=$f
SERVICE_PORT=$p
TRANSPORT_PORT=$tp
PROTOCOL=tcp
EOF_CFG
  chmod 600 "$CFG"
  log "Saved $CFG"
}

tf_config(){ load_cfg; cat "$CFG"; }

tf_drivers(){ cat <<'EOF_DRIVERS'
DRIVER     MODE             STATUS
haproxy    direct TCP       lab-verified
rinetd     direct TCP       lab-verified
socat      direct TCP       lab-verified
gost       relay TCP        lab-verified
wstunnel   WebSocket/TCP    lab-verified
gre        L3 GRE           lab-verified
EOF_DRIVERS
}

tf_up(){
  root_only
  local d=${1:-} role=${2:-}
  [[ -n "$d" ]] || die "Missing driver. Run: tunnelforge drivers"
  [[ "$role" =~ ^(iran|foreign)$ ]] || die "Role must be iran or foreign"
  require_driver "$d"
  load_cfg
  # shellcheck disable=SC1090
  source "$(driver_path "$d")"
  driver_preflight "$role"
  driver_install "$role"
  driver_configure "$role"
  driver_start "$role"
  sleep 1
  driver_health "$role"
  cat >"$STATE" <<EOF_STATE
CURRENT_DRIVER=$d
CURRENT_ROLE=$role
DEPLOYED_AT=$(date -Is)
USER_VERIFIED=unknown
EOF_STATE
  chmod 600 "$STATE"
  record "UP driver=$d role=$role"
  log "Deployed successfully. User verification remains unknown until 'tunnelforge verify yes|no'."
}

tf_down(){
  root_only
  [[ -f "$STATE" ]] || { echo "No active state"; return; }
  # shellcheck disable=SC1090
  set -a; source "$STATE"; set +a
  load_cfg
  require_driver "$CURRENT_DRIVER"
  # shellcheck disable=SC1090
  source "$(driver_path "$CURRENT_DRIVER")"
  driver_cleanup "$CURRENT_ROLE"
  record "DOWN driver=$CURRENT_DRIVER role=$CURRENT_ROLE"
  rm -f "$STATE"
  log "TunnelForge state removed."
}

tf_status(){
  load_cfg
  [[ -f "$STATE" ]] || { echo "No active driver"; return; }
  # shellcheck disable=SC1090
  set -a; source "$STATE"; set +a
  echo "Driver=$CURRENT_DRIVER Role=$CURRENT_ROLE H5_USER_VERIFIED=$USER_VERIFIED"
  require_driver "$CURRENT_DRIVER"
  # shellcheck disable=SC1090
  source "$(driver_path "$CURRENT_DRIVER")"
  driver_health "$CURRENT_ROLE" || true
}

tf_test(){
  load_cfg
  [[ -f "$STATE" ]] || die "No active state"
  # shellcheck disable=SC1090
  set -a; source "$STATE"; set +a
  echo "H3 generic TCP probe:"
  if timeout 5 bash -c "</dev/tcp/127.0.0.1/$SERVICE_PORT"; then
    echo "H3 TCP ACCEPTED"
  else
    echo "H3 TCP FAILED"
    return 1
  fi
  echo "H5 requires testing the real client config. Then run: tunnelforge verify yes|no"
}

tf_verify(){
  root_only
  [[ ${1:-} =~ ^(yes|no)$ ]] || die "Usage: tunnelforge verify yes|no"
  [[ -f "$STATE" ]] || die "No active state"
  sed -i "s/^USER_VERIFIED=.*/USER_VERIFIED=$1/" "$STATE"
  # shellcheck disable=SC1090
  set -a; source "$STATE"; set +a
  record "VERIFY driver=$CURRENT_DRIVER role=$CURRENT_ROLE result=$1"
  log "Verification recorded: $1"
}

tf_version(){ printf 'TunnelForge %s\n' "$TF_VERSION"; }
tf_menu(){ tf_drivers; echo; echo "Use: tunnelforge up DRIVER iran|foreign"; }
