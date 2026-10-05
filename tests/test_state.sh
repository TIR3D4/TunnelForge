#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."&&pwd);TMP=$(mktemp -d);trap 'rm -rf "$TMP"' EXIT
export TF_ROOT=$ROOT TF_STATE=$TMP/state.json TF_HISTORY=$TMP/history.jsonl;source "$ROOT/core/state.sh";state_set driver=wstunnel role=iran user_verified=unknown;[[ $(state_get driver) == wstunnel ]];state_set user_verified=yes;[[ $(state_get user_verified) == yes ]];history_add action=test result=success;grep -q '"action": "test"' "$TF_HISTORY"
