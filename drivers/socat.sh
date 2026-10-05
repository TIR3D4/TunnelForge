#!/usr/bin/env bash
U=tunnelforge-socat.service
driver_preflight(){ [[ $1 == foreign ]] || port_free "$SERVICE_PORT" || die "Port busy"; }
driver_install(){ [[ $1 == foreign ]] || { apt-get update -qq; DEBIAN_FRONTEND=noninteractive apt-get install -y socat >/dev/null; }; }
driver_configure(){ [[ $1 == foreign ]] && return; cat >/etc/systemd/system/$U <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:$SERVICE_PORT,bind=0.0.0.0,reuseaddr,fork,nodelay TCP:$FOREIGN_IP:$SERVICE_PORT,nodelay
Restart=always
RestartSec=1
TimeoutStopSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload; }
driver_start(){ [[ $1 == foreign ]] || systemctl enable --now $U >/dev/null; }
driver_health(){ [[ $1 == foreign ]] && timeout 5 bash -c "</dev/tcp/127.0.0.1/$SERVICE_PORT" || { systemctl is-active $U; ss -lntp|grep ":$SERVICE_PORT"; }; }
driver_cleanup(){ [[ $1 == foreign ]] || { owned_stop $U; rm -f /etc/systemd/system/$U; systemctl daemon-reload; }; }
