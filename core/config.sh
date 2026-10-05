#!/usr/bin/env bash
toml_get(){ local key=$1 file=${2:-$TF_CONFIG} line val; line=$(grep -E "^[[:space:]]*${key}[[:space:]]*=" "$file"|tail -1||true); [[ -n $line ]]||return 1; val=${line#*=}; val=${val#${val%%[![:space:]]*}}; val=${val%${val##*[![:space:]]}}; [[ $val == \"*\" ]]&&{ val=${val#\"}; val=${val%\"}; }; printf '%s' "$val"; }
load_config(){ [[ -f $TF_CONFIG ]]||die "missing config: $TF_CONFIG (run: tunnelforge init)"; MODE=$(toml_get mode||echo manual); IRAN_IP=$(toml_get iran_ip); FOREIGN_IP=$(toml_get foreign_ip); SERVICE_PORT=$(toml_get service_port); DESTINATION_HOST=$(toml_get destination_host||echo "$FOREIGN_IP"); DESTINATION_PORT=$(toml_get destination_port); TRANSPORT_PORT=$(toml_get transport_port); HEALTH_PORT=$(toml_get health_port||echo 39091); PROTOCOL=$(toml_get protocol||echo tcp); SSH_USER=$(toml_get ssh_user||echo root); SSH_PORT=$(toml_get ssh_port||echo 22); SSH_KEY=$(toml_get ssh_key||true); validate_ipv4 "$IRAN_IP"||die "invalid iran_ip"; validate_ipv4 "$FOREIGN_IP"||die "invalid foreign_ip"; validate_port "$SERVICE_PORT"||die "invalid service_port"; validate_port "$DESTINATION_PORT"||die "invalid destination_port"; validate_port "$TRANSPORT_PORT"||die "invalid transport_port"; validate_port "$HEALTH_PORT"||die "invalid health_port"; [[ $PROTOCOL == tcp ]]||die "v0.1.0 supports tcp only"; }
write_config(){ local i=$1 f=$2 sp=$3 dh=$4 dp=$5 tp=$6 hp=$7 mode=${8:-manual}; atomic_write "$TF_CONFIG" 600 <<EOF
mode = "$mode"
iran_ip = "$i"
foreign_ip = "$f"
service_port = $sp
destination_host = "$dh"
destination_port = $dp
transport_port = $tp
health_port = $hp
protocol = "tcp"
ssh_user = "root"
ssh_port = 22
ssh_key = ""
expert_mode = false
EOF
}
