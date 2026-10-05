#!/usr/bin/env bash
IF=tunnelforge-gre;SVC=tunnelforge-gre-service.service;HLT=tunnelforge-gre-health.service;BRG=tunnelforge-gre-destination.service
driver_preflight(){ need_cmd ip;if [[ $1 == iran ]];then port_free "$SERVICE_PORT"||die 'service port busy';port_free "$HEALTH_PORT"||die 'health port busy';else port_free "$SERVICE_PORT"||die 'foreign GRE bridge port busy';fi; };driver_install(){ apt-get update -qq;DEBIAN_FRONTEND=noninteractive apt-get install -y socat iproute2 >/dev/null; };mkunit(){ local n=$1 x=$2;cat >/etc/systemd/system/$n <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=$x
Restart=on-failure
RestartSec=1
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
};driver_configure(){ :; };driver_start(){ local role=$1 localip remote addr;if [[ $role == iran ]];then localip=$IRAN_IP;remote=$FOREIGN_IP;addr=10.202.0.1/30;else localip=$FOREIGN_IP;remote=$IRAN_IP;addr=10.202.0.2/30;fi;ip tunnel del "$IF" 2>/dev/null||true;ip tunnel add "$IF" mode gre local "$localip" remote "$remote" ttl 255;ip link set "$IF" mtu 1400 up;ip addr replace "$addr" dev "$IF";if [[ $role == foreign ]];then health_echo_install;mkunit "$BRG" "/usr/bin/socat TCP-LISTEN:$SERVICE_PORT,bind=10.202.0.2,reuseaddr,fork,nodelay TCP:$DESTINATION_HOST:$DESTINATION_PORT,nodelay";systemctl daemon-reload;systemctl enable --now "$BRG" >/dev/null;else mkunit "$SVC" "/usr/bin/socat TCP-LISTEN:$SERVICE_PORT,bind=0.0.0.0,reuseaddr,fork,nodelay TCP:10.202.0.2:$SERVICE_PORT,nodelay";mkunit "$HLT" "/usr/bin/socat TCP-LISTEN:$HEALTH_PORT,bind=127.0.0.1,reuseaddr,fork,nodelay TCP:10.202.0.2:$HEALTH_PORT,nodelay";systemctl daemon-reload;systemctl enable --now "$SVC" "$HLT" >/dev/null;fi; };driver_stop(){ if [[ $1 == foreign ]];then stop_owned_unit "$BRG";else stop_owned_unit "$SVC";stop_owned_unit "$HLT";fi;ip tunnel del "$IF" 2>/dev/null||true; };driver_status(){ ip link show "$IF" >/dev/null 2>&1&&{ [[ $1 == foreign ]]&&service_active "$BRG"||service_active "$SVC";}; };driver_health(){ if [[ $1 == foreign ]];then ip addr show "$IF"|grep -q '10.202.0.2/30'&&health_h0 "$BRG"&&health_h0 tunnelforge-health-echo.service;else ip addr show "$IF"|grep -q '10.202.0.1/30'&&ping -c1 -W2 10.202.0.2 >/dev/null&&health_h1 "$SERVICE_PORT"&&health_h3;fi; };driver_cleanup(){ driver_stop "$1";if [[ $1 == foreign ]];then health_echo_remove;rm -f /etc/systemd/system/$BRG;else rm -f /etc/systemd/system/$SVC /etc/systemd/system/$HLT;fi;systemctl daemon-reload; };driver_metrics(){ ip -s link show "$IF" 2>/dev/null||true; }
