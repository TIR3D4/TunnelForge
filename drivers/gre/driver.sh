#!/usr/bin/env bash
IF=tunnelforge-gre
SVC=tunnelforge-gre-service.service
HLT=tunnelforge-gre-health.service
BRG=tunnelforge-gre-destination.service

# A service bound only to 127.0.0.1:SERVICE_PORT is valid and must coexist
# with the GRE bridge on 10.202.0.2:SERVICE_PORT. Only wildcard listeners
# would prevent the address-specific GRE bridge bind.
gre_foreign_bridge_available(){
  ! ss -H -lnt 2>/dev/null | awk '{print $4}' | grep -Eq "(^|:)0\.0\.0\.0:${SERVICE_PORT}$|^\*:${SERVICE_PORT}$|^\[::\]:${SERVICE_PORT}$"
}

driver_preflight(){
  need_cmd ip
  need_cmd ss
  if [[ $1 == iran ]]; then
    port_free "$SERVICE_PORT" || die "Iran service port $SERVICE_PORT is busy"
    port_free "$HEALTH_PORT" || die "Iran health port $HEALTH_PORT is busy"
  else
    gre_foreign_bridge_available || die "a wildcard listener already owns Foreign port $SERVICE_PORT"
  fi
}

driver_install(){
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y socat iproute2 >/dev/null
}

mkunit(){
  local name=$1 exec=$2
  cat >"/etc/systemd/system/$name" <<EOF
[Unit]
Description=TunnelForge GRE component
After=network-online.target
Wants=network-online.target

[Service]
ExecStart=$exec
Restart=on-failure
RestartSec=1
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
}

driver_configure(){ :; }

driver_start(){
  local role=$1 local_ip remote_ip address
  if [[ $role == iran ]]; then
    local_ip=$IRAN_IP
    remote_ip=$FOREIGN_IP
    address=10.202.0.1/30
  else
    local_ip=$FOREIGN_IP
    remote_ip=$IRAN_IP
    address=10.202.0.2/30
  fi

  ip tunnel del "$IF" 2>/dev/null || true
  ip tunnel add "$IF" mode gre local "$local_ip" remote "$remote_ip" ttl 255
  ip addr replace "$address" dev "$IF"
  ip link set "$IF" mtu 1400 up

  if [[ $role == foreign ]]; then
    # Matches the real-world configuration verified by the user:
    # 10.202.0.2:SERVICE_PORT -> 127.0.0.1:DESTINATION_PORT.
    health_echo_install
    mkunit "$BRG" "/usr/bin/socat TCP-LISTEN:$SERVICE_PORT,bind=10.202.0.2,reuseaddr,fork,nodelay TCP:$DESTINATION_HOST:$DESTINATION_PORT,nodelay"
    systemctl daemon-reload
    systemctl enable --now "$BRG" >/dev/null
  else
    mkunit "$SVC" "/usr/bin/socat TCP-LISTEN:$SERVICE_PORT,bind=0.0.0.0,reuseaddr,fork,nodelay TCP:10.202.0.2:$SERVICE_PORT,nodelay"
    mkunit "$HLT" "/usr/bin/socat TCP-LISTEN:$HEALTH_PORT,bind=127.0.0.1,reuseaddr,fork,nodelay TCP:10.202.0.2:$HEALTH_PORT,nodelay"
    systemctl daemon-reload
    systemctl enable --now "$SVC" "$HLT" >/dev/null
  fi
}

driver_stop(){
  if [[ $1 == foreign ]]; then
    stop_owned_unit "$BRG"
  else
    stop_owned_unit "$SVC"
    stop_owned_unit "$HLT"
  fi
  ip tunnel del "$IF" 2>/dev/null || true
}

driver_status(){
  ip link show "$IF" >/dev/null 2>&1 || return 1
  if [[ $1 == foreign ]]; then
    service_active "$BRG"
  else
    service_active "$SVC" && service_active "$HLT"
  fi
}

driver_health(){
  if [[ $1 == foreign ]]; then
    ip addr show "$IF" | grep -q '10.202.0.2/30' &&
      health_h0 "$BRG" &&
      health_h0 tunnelforge-health-echo.service
  else
    ip addr show "$IF" | grep -q '10.202.0.1/30' &&
      ping -c1 -W2 10.202.0.2 >/dev/null &&
      health_h1 "$SERVICE_PORT" &&
      health_h3
  fi
}

driver_cleanup(){
  driver_stop "$1"
  if [[ $1 == foreign ]]; then
    health_echo_remove
    rm -f "/etc/systemd/system/$BRG"
  else
    rm -f "/etc/systemd/system/$SVC" "/etc/systemd/system/$HLT"
  fi
  systemctl daemon-reload
}

driver_metrics(){
  ip -s link show "$IF" 2>/dev/null || true
}
