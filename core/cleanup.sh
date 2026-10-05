#!/usr/bin/env bash
cleanup_current(){ need_root;[[ -f $TF_STATE ]]||{ echo 'No active TunnelForge state';return 0;};local d role;d=$(state_get driver);role=$(state_get role);load_config;load_driver "$d";driver_cleanup "$role";history_add action=down driver="$d" role="$role" result=success;state_clear;log INFO "cleaned driver=$d role=$role"; }
