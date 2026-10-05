#!/usr/bin/env bash
set -Eeuo pipefail
TF_ROOT=${TF_ROOT:-/opt/tunnelforge}
for f in common logging config state driver health remote rollback cleanup benchmark controller;do source "$TF_ROOT/core/$f.sh";done
setup_logging
cmd=${1:-help};shift||true
case "$cmd" in init)cmd_init "$@";;config)cmd_config;;drivers)cmd_drivers;;deploy|up)cmd_deploy "$@";;down|cleanup)cleanup_current;;status)cmd_status;;test)cmd_test;;verify)cmd_verify "$@";;history)cmd_history;;commands)cmd_commands "$@";;import-runtime)cmd_import_runtime "$@";;orchestrate)cmd_orchestrate "$@";;benchmark)benchmark_run "$@";;next)cmd_next;;auto)cmd_auto;;version|--version|-v)cat "$TF_ROOT/VERSION";;help|--help|-h)cat <<'EOF'
TunnelForge - tunnel experimentation & deployment platform

Usage:
  tunnelforge init
  tunnelforge drivers
  tunnelforge commands DRIVER
  tunnelforge deploy DRIVER iran|foreign
  tunnelforge orchestrate DRIVER
  tunnelforge status
  tunnelforge test
  tunnelforge verify yes|no
  tunnelforge benchmark L1|L2|L3|L4 [--yes]
  tunnelforge next
  tunnelforge auto
  tunnelforge history
  tunnelforge down
EOF
;;*)die "unknown command: $cmd";;esac
