#!/usr/bin/env bash
U=tunnelforge-gost.service; B=/usr/local/bin/tf-gost; TP=${TRANSPORT_PORT:-30443}
driver_preflight(){ [[ $1 != iran ]] || port_free "$SERVICE_PORT" || die "Port $SERVICE_PORT is already in use"; }
driver_install(){ [[ -x $B ]] && return; cd /tmp; curl -fsSL https://github.com/go-gost/gost/releases/download/v3.3.0/gost_3.3.0_linux_amd64.tar.gz -o tf.tgz; tar -xzf tf.tgz; install -m755 gost $B; }
driver_configure(){ if [[ $1 == foreign ]]; then X="$B -L relay://:$TP"; else X="$B -L tcp://:$SERVICE_PORT/$FOREIGN_IP:$SERVICE_PORT -F relay://$FOREIGN_IP:$TP"; fi; cat >/etc/systemd/system/$U <<EOF
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
