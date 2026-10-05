#!/usr/bin/env bash
SERVER=tunnelforge-wstunnel.service;CLIENT=tunnelforge-wstunnel-client.service;HEALTH=tunnelforge-wstunnel-health.service;BIN=/usr/local/lib/tunnelforge/wstunnel;VER=11.0.0
driver_preflight(){ if [[ $1 == iran ]];then port_free "$SERVICE_PORT"||die 'service port busy';port_free "$HEALTH_PORT"||die 'health port busy';else port_free "$TRANSPORT_PORT"||die 'transport port busy';fi; }
driver_install(){ local arch url sha tmp;arch=$(uname -m);case $arch in x86_64)arch=amd64;sha=9708a99717b5a951453c2ff7c14c25d3418d02ca7fcb96fdb382a8f2083bab5e;;aarch64|arm64)arch=arm64;sha=b86abf73e340ed0c3ff9a77a5458aa27213784920ec65513132b36def45edc94;;*)die "unsupported wstunnel arch: $arch";;esac;[[ -x $BIN ]]&&"$BIN" --version 2>&1|grep -q "$VER"&&return 0;need_cmd curl;need_cmd sha256sum;tmp=$(mktemp -d);url="https://github.com/erebe/wstunnel/releases/download/v$VER/wstunnel_${VER}_linux_${arch}.tar.gz";curl --fail --location --proto '=https' --tlsv1.2 "$url" -o "$tmp/a.tgz";echo "$sha  $tmp/a.tgz"|sha256sum -c -;tar -xzf "$tmp/a.tgz" -C "$tmp";install -d -m755 "$(dirname "$BIN")";install -m755 "$(find "$tmp" -type f -name wstunnel|head -1)" "$BIN";rm -rf "$tmp"; }
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
};driver_configure(){ if [[ $1 == foreign ]];then health_echo_install;mkunit "$SERVER" "$BIN server --restrict-to $DESTINATION_HOST:$DESTINATION_PORT --restrict-to 127.0.0.1:$HEALTH_PORT ws://0.0.0.0:$TRANSPORT_PORT";else mkunit "$CLIENT" "$BIN client --connection-min-idle 4 -L tcp://0.0.0.0:$SERVICE_PORT:$DESTINATION_HOST:$DESTINATION_PORT ws://$FOREIGN_IP:$TRANSPORT_PORT";mkunit "$HEALTH" "$BIN client --connection-min-idle 1 -L tcp://127.0.0.1:$HEALTH_PORT:127.0.0.1:$HEALTH_PORT ws://$FOREIGN_IP:$TRANSPORT_PORT";fi;systemctl daemon-reload; };driver_start(){ [[ $1 == foreign ]]&&systemctl enable --now "$SERVER" >/dev/null||systemctl enable --now "$CLIENT" "$HEALTH" >/dev/null; };driver_stop(){ if [[ $1 == foreign ]];then stop_owned_unit "$SERVER";else stop_owned_unit "$CLIENT";stop_owned_unit "$HEALTH";fi; };driver_status(){ [[ $1 == foreign ]]&&service_active "$SERVER"||{ service_active "$CLIENT"&&service_active "$HEALTH";}; };driver_health(){ if [[ $1 == foreign ]];then health_h0 "$SERVER"&&health_h1 "$TRANSPORT_PORT"&&health_h0 tunnelforge-health-echo.service;else health_h0 "$CLIENT"&&health_h1 "$SERVICE_PORT"&&ss -Hnt|grep -q "$FOREIGN_IP:$TRANSPORT_PORT"&&health_h3;fi; };driver_cleanup(){ driver_stop "$1";if [[ $1 == foreign ]];then health_echo_remove;rm -f /etc/systemd/system/$SERVER;else rm -f /etc/systemd/system/$CLIENT /etc/systemd/system/$HEALTH;fi;systemctl daemon-reload; };driver_metrics(){ systemctl show "$([[ $1 == foreign ]]&&echo "$SERVER"||echo "$CLIENT")" -p MemoryCurrent -p CPUUsageNSec -p NRestarts 2>/dev/null||true; }
