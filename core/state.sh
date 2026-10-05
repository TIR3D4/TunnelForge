#!/usr/bin/env bash
state_set(){ python3 "$TF_ROOT/scripts/state.py" set "$TF_STATE" "$@"; chmod 600 "$TF_STATE"; }; state_get(){ python3 "$TF_ROOT/scripts/state.py" get "$TF_STATE" "$1" 2>/dev/null||true; }; state_clear(){ rm -f "$TF_STATE"; }; history_add(){ python3 "$TF_ROOT/scripts/state.py" history "$TF_HISTORY" "$@"; chmod 600 "$TF_HISTORY"; }
