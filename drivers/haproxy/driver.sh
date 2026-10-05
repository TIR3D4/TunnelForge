#!/usr/bin/env bash
UNIT=tunnelforge-haproxy.service;CONF=/etc/tunnelforge/generated/haproxy.cfg
driver_preflight(){ [[ $1 == foreign ]]||{ port_free "$SERVICE_PORT"||die "service port busy";port_free "$HEALTH_PORT"||die "health port busy";}; }
driver_install(){ [[ $1 == foreign ]]||{ apt-get update -qq;DEBIAN_FRONTEND=noninteractive apt-get install -y haproxy >/dev/null;}; }
driver_configure(){ [[ $1 == foreign ]]&&{ health_echo_install;return;};mkdir -p /etc/tunnelforge/generated;cat >"$CONF" <<EOF
global
 maxconn 50000
 log stdout format raw local0
defaults
 mode tcp
 timeout connect 5s
 timeout client 1h
 timeout server 1h
frontend service
 bind 0.0.0.0:$SERVICE_PORT
 default_backend app
backend app
 server foreign $FOREIGN_IP:$DESTINATION_PORT check
frontend health
 bind 127.0.0.1:$HEALTH_PORT
 default_backend health_remote
backend health_remote
 server foreign $FOREIGN_IP:$HEALTH_PORT check
EOF
haproxy -c -f "$CONF" >/dev/null;cat >/etc/systemd/system/$UNIT <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=/usr/sbin/haproxy -Ws -f $CONF -p /run/tunnelforge-haproxy.pid
Restart=on-failure
RestartSec=1
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload; }
driver_start(){ [[ $1 == foreign ]]||systemctl enable --now "$UNIT" >/dev/null; };driver_stop(){ [[ $1 == foreign ]]||stop_owned_unit "$UNIT"; };driver_status(){ [[ $1 == foreign ]]&&service_active tunnelforge-health-echo.service||service_active "$UNIT"; };driver_health(){ [[ $1 == foreign ]]&&{ health_h0 tunnelforge-health-echo.service&&health_h1 "$HEALTH_PORT";}||{ health_h0 "$UNIT"&&health_h1 "$SERVICE_PORT"&&health_h3;}; };driver_cleanup(){ [[ $1 == foreign ]]&&health_echo_remove||{ driver_stop "$1";rm -f "$CONF" /etc/systemd/system/$UNIT;systemctl daemon-reload;}; };driver_metrics(){ systemctl show "$UNIT" -p MemoryCurrent -p CPUUsageNSec -p NRestarts 2>/dev/null||true; }
