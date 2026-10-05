#!/usr/bin/env bash
health_h0(){ service_active "$1"; }; health_h1(){ ss -H -lnt|awk '{print $4}'|grep -Eq ":$1$"; }; health_h3(){ python3 "$TF_ROOT/health/probe.py" 127.0.0.1 "$HEALTH_PORT" --token-file "$TF_HEALTH_TOKEN_FILE"; }; health_destination(){ timeout 5 bash -c "exec 3<>/dev/tcp/$DESTINATION_HOST/$DESTINATION_PORT" >/dev/null 2>&1; }
health_echo_install(){ need_root;load_config;[[ -s $TF_HEALTH_TOKEN_FILE ]]||die "missing shared health token";cat >/etc/systemd/system/tunnelforge-health-echo.service <<EOF
[Unit]
After=network-online.target
[Service]
ExecStart=/usr/bin/python3 $TF_ROOT/health/echo_server.py --bind 0.0.0.0 --port $HEALTH_PORT --token-file $TF_HEALTH_TOKEN_FILE
Restart=on-failure
RestartSec=1
NoNewPrivileges=true
PrivateTmp=true
ProtectSystem=strict
ProtectHome=true
ReadOnlyPaths=$TF_HEALTH_TOKEN_FILE $TF_ROOT
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload;systemctl enable --now tunnelforge-health-echo.service >/dev/null; }; health_echo_remove(){ stop_owned_unit tunnelforge-health-echo.service;rm -f /etc/systemd/system/tunnelforge-health-echo.service;systemctl daemon-reload; }
