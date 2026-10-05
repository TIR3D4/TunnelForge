#!/usr/bin/env bash
U=tunnelforge-wstunnel.service; B=/usr/local/bin/tf-wstunnel; TP=${TRANSPORT_PORT:-30445}
driver_preflight(){ [[ $1 != iran ]] || port_free "$SERVICE_PORT" || die "Port $SERVICE_PORT is already in use"; }
driver_install(){ [[ -x $B ]] && return; cd /tmp; curl -fsSL https://github.com/erebe/wstunnel/releases/download/v11.0.0/wstunnel_11.0.0_linux_amd64.tar.gz -o tf.tgz; tar -xzf tf.tgz; install -m755 wstunnel $B; }
driver_configure(){ if [[ $1 == foreign ]]; then X="$B server --restrict-to 127.0.0.1:$SERVICE_PORT ws://0.0.0.0:$TP"; else X="$B client --connection-min-idle 4 -L tcp://0.0.0.0:$SERVICE_PORT:127.0.0.1:$SERVICE_PORT ws://$FOREIGN_IP:$TP"; fi; cat >/etc/systemd/system/$U <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=$X
Restart=always
RestartSec=1
TimeoutStopSec=3
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload; }
driver_start(){ systemctl enable --now $U >/dev/null; }
driver_health(){ systemctl is-active $U; [[ $1 == iran ]] && ss -lntp|grep ":$SERVICE_PORT" || ss -lntp|grep ":$TP"; }
driver_cleanup(){ owned_stop $U; rm -f /etc/systemd/system/$U; systemctl daemon-reload; }
