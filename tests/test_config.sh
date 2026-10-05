#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."&&pwd);TMP=$(mktemp -d);trap 'rm -rf "$TMP"' EXIT
export TF_ROOT=$ROOT TF_ETC=$TMP/etc TF_VAR=$TMP/var TF_LOG_DIR=$TMP/log TF_CONFIG=$TMP/etc/config.toml TF_SECRETS=$TMP/etc/secrets TF_HEALTH_TOKEN_FILE=$TMP/etc/secrets/health.token TF_LOG=$TMP/log/tf.log TF_STATE=$TMP/var/state.json TF_HISTORY=$TMP/var/history.jsonl
mkdir -p "$TF_ETC" "$TF_SECRETS" "$TF_VAR" "$TF_LOG_DIR";source "$ROOT/core/common.sh";source "$ROOT/core/config.sh"
write_config 37.202.244.218 87.120.106.61 2020 87.120.106.61 2020 30445 39091 manual;load_config
[[ $IRAN_IP == 37.202.244.218 && $FOREIGN_IP == 87.120.106.61 && $SERVICE_PORT == 2020 && $DESTINATION_PORT == 2020 ]];validate_ipv4 1.2.3.4;! validate_ipv4 999.2.3.4;validate_port 65535;! validate_port 70000
