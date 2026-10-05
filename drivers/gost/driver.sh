#!/usr/bin/env bash
SERVER=tunnelforge-gost.service;CLIENT=tunnelforge-gost-client.service;HEALTH=tunnelforge-gost-health.service;BIN=/usr/local/lib/tunnelforge/gost;VER=3.3.0
driver_preflight(){ if [[ $1 == iran ]];then port_free "$SERVICE_PORT"||die 'service port busy';port_free "$HEALTH_PORT"||die 'health port busy';else port_free "$TRANSPORT_PORT"||die 'transport port busy';fi; }
driver_install(){ local arch url sha tmp;arch=$(uname -m);case $arch in x86_64)arch=amd64;sha=676fb7f78d267b6ae73df719c0c7f2b565dde7147da935cfafbc1e1da558b6d5;;aarch64|arm64)arch=arm64;sha=d03699e3f385d4ff5dad68046712adfcc7515325a064d2ab046e0bece30f8f8f;;*)die "unsupported gost arch: $arch";;esac;[[ -x $BIN ]]&&"$BIN" -V 2>&1|grep -q "$VER"&&return 0;need_cmd curl;need_cmd sha256sum;tmp=$(mktemp -d);url="https://github.com/go-gost/gost/releases/download/v$VER/gost_${VER}_linux_${arch}.tar.gz";curl --fail --location --proto '=https' --tlsv1.2 "$url" -o "$tmp/a.tgz";echo "$sha  $tmp/a.tgz"|sha256sum -c -;tar -xzf "$tmp/a.tgz" -C "$tmp";install -d -m755 "$(dirname "$BIN")";install -m755 "$(find "$tmp" -type f -name gost|head -1)" "$BIN";rm -rf "$tmp"; }
mkunit(){ local n=$1 x=$2;cat >/etc/systemd/system/$n <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=$x
Restart=always
RestartSec=1
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
};driver_configure(){ if [[ $1 == foreign ]];then health_echo_install;mkunit "$SERVER" "$BIN -L relay://0.0.0.0:$TRANSPORT_PORT";else mkunit "$CLIENT" "$BIN -L tcp://0.0.0.0:$SERVICE_PORT/$DESTINATION_HOST:$DESTINATION_PORT -F relay://$FOREIGN_IP:$TRANSPORT_PORT";mkunit "$HEALTH" "$BIN -L tcp://127.0.0.1:$HEALTH_PORT/127.0.0.1:$HEALTH_PORT -F relay://$FOREIGN_IP:$TRANSPORT_PORT";fi;systemctl daemon-reload; };driver_start(){ [[ $1 == foreign ]]&&systemctl enable --now "$SERVER" >/dev/null||systemctl enable --now "$CLIENT" "$HEALTH" >/dev/null; };driver_stop(){ if [[ $1 == foreign ]];then stop_owned_unit "$SERVER";else stop_owned_unit "$CLIENT";stop_owned_unit "$HEALTH";fi; };driver_status(){ [[ $1 == foreign ]]&&service_active "$SERVER"||{ service_active "$CLIENT"&&service_active "$HEALTH";}; };driver_health(){ if [[ $1 == foreign ]];then health_h0 "$SERVER"&&health_h1 "$TRANSPORT_PORT"&&health_h0 tunnelforge-health-echo.service;else health_h0 "$CLIENT"&&health_h1 "$SERVICE_PORT"&&ss -Hnt|grep -q "$FOREIGN_IP:$TRANSPORT_PORT"&&health_h3;fi; };driver_cleanup(){ driver_stop "$1";if [[ $1 == foreign ]];then health_echo_remove;rm -f /etc/systemd/system/$SERVER;else rm -f /etc/systemd/system/$CLIENT /etc/systemd/system/$HEALTH;fi;systemctl daemon-reload; };driver_metrics(){ systemctl show "$([[ $1 == foreign ]]&&echo "$SERVER"||echo "$CLIENT")" -p MemoryCurrent -p CPUUsageNSec -p NRestarts 2>/dev/null||true; }
