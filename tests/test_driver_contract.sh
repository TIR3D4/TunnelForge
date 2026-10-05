#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."&&pwd)
for f in "$ROOT"/drivers/*/driver.sh;do for fn in driver_preflight driver_install driver_configure driver_start driver_stop driver_status driver_health driver_cleanup driver_metrics;do grep -Eq "^${fn}[[:space:]]*\(\)" "$f"||{ echo "missing $fn in $f" >&2;exit 1;};done;done
