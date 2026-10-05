#!/usr/bin/env bash
driver_preflight(){ [[ $1 == foreign ]] || port_free "$SERVICE_PORT" || die "Port busy"; }
driver_install(){ [[ $1 == foreign ]] || { apt-get update -qq; DEBIAN_FRONTEND=noninteractive apt-get install -y haproxy >/dev/null; }; }
driver_configure(){ [[ $1 == foreign ]] && return; cat >/etc/haproxy/haproxy.cfg <<EOF
global
 maxconn 50000
defaults
 mode tcp
 timeout connect 5s
 timeout client 1h
 timeout server 1h
frontend tf
 bind 0.0.0.0:$SERVICE_PORT
 default_backend dst
backend dst
 server foreign $FOREIGN_IP:$SERVICE_PORT check
EOF
haproxy -c -f /etc/haproxy/haproxy.cfg; }
driver_start(){ [[ $1 == foreign ]] || systemctl enable --now haproxy >/dev/null; }
driver_health(){ if [[ $1 == iran ]]; then echo "H0 $(systemctl is-active haproxy)"; ss -lntp|grep ":$SERVICE_PORT"; else timeout 5 bash -c "</dev/tcp/127.0.0.1/$SERVICE_PORT"; fi; }
driver_cleanup(){ [[ $1 == foreign ]] || owned_stop haproxy; }
