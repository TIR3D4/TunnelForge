#!/usr/bin/env bash
driver_preflight(){ [[ $1 == foreign ]] || port_free "$SERVICE_PORT" || die "Port busy"; }
driver_install(){ [[ $1 == foreign ]] || { apt-get update -qq; DEBIAN_FRONTEND=noninteractive apt-get install -y rinetd >/dev/null; }; }
driver_configure(){ [[ $1 == foreign ]] || echo "0.0.0.0 $SERVICE_PORT $FOREIGN_IP $SERVICE_PORT" >/etc/rinetd.conf; }
driver_start(){ [[ $1 == foreign ]] || systemctl enable --now rinetd >/dev/null; }
driver_health(){ [[ $1 == foreign ]] && timeout 5 bash -c "</dev/tcp/127.0.0.1/$SERVICE_PORT" || { systemctl is-active rinetd; ss -lntp|grep ":$SERVICE_PORT"; }; }
driver_cleanup(){ [[ $1 == foreign ]] || owned_stop rinetd; }
