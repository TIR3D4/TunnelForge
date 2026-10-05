#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."&&pwd)
if grep -R -nE 'iptables[[:space:]]+-F|pkill[[:space:]]+-9|rm[[:space:]]+-rf[[:space:]]+/etc/(nginx|xray|haproxy)' "$ROOT/core" "$ROOT/drivers";then echo 'dangerous broad cleanup pattern found' >&2;exit 1;fi
