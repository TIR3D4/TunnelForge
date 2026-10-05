#!/usr/bin/env bash
IF=tf-gre
driver_preflight(){ command -v ip >/dev/null; }
driver_install(){ :; }
driver_configure(){ :; }
driver_start(){
 if [[ $1 == iran ]]; then localip=$IRAN_IP; remote=$FOREIGN_IP; addr=10.202.0.1/30; else localip=$FOREIGN_IP; remote=$IRAN_IP; addr=10.202.0.2/30; fi
 ip tunnel del $IF 2>/dev/null || true
 ip tunnel add $IF mode gre local $localip remote $remote ttl 255
 ip link set $IF mtu 1400 up
 ip addr replace $addr dev $IF
}
driver_health(){ ip addr show $IF; }
driver_cleanup(){ ip tunnel del $IF 2>/dev/null || true; }
