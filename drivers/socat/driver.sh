#!/usr/bin/env bash
SVC=tunnelforge-socat.service;HLT=tunnelforge-socat-health.service
driver_preflight(){ [[ $1 == foreign ]]||{ port_free "$SERVICE_PORT"||die 'service port busy';port_free "$HEALTH_PORT"||die 'health port busy';}; };driver_install(){ [[ $1 == foreign ]]||{ apt-get update -qq;DEBIAN_FRONTEND=noninteractive apt-get install -y socat >/dev/null;}; };mkunit(){ local n=$1 l=$2 dst=$3 bind=$4;cat >/etc/systemd/system/$n <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:$l,bind=$bind,reuseaddr,fork,nodelay TCP:$dst,nodelay
Restart=on-failure
RestartSec=1
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
};driver_configure(){ [[ $1 == foreign ]]&&{ health_echo_install;return;};mkunit "$SVC" "$SERVICE_PORT" "$FOREIGN_IP:$DESTINATION_PORT" 0.0.0.0;mkunit "$HLT" "$HEALTH_PORT" "$FOREIGN_IP:$HEALTH_PORT" 127.0.0.1;systemctl daemon-reload; };driver_start(){ [[ $1 == foreign ]]||systemctl enable --now "$SVC" "$HLT" >/dev/null; };driver_stop(){ [[ $1 == foreign ]]||{ stop_owned_unit "$SVC";stop_owned_unit "$HLT";}; };driver_status(){ [[ $1 == foreign ]]&&service_active tunnelforge-health-echo.service||{ service_active "$SVC"&&service_active "$HLT";}; };driver_health(){ [[ $1 == foreign ]]&&{ health_h0 tunnelforge-health-echo.service&&health_h1 "$HEALTH_PORT";}||{ health_h0 "$SVC"&&health_h0 "$HLT"&&health_h1 "$SERVICE_PORT"&&health_h3;}; };driver_cleanup(){ [[ $1 == foreign ]]&&health_echo_remove||{ driver_stop "$1";rm -f /etc/systemd/system/$SVC /etc/systemd/system/$HLT;systemctl daemon-reload;}; };driver_metrics(){ systemctl show "$SVC" -p MemoryCurrent -p CPUUsageNSec -p NRestarts 2>/dev/null||true; }
