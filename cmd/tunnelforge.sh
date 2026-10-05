#!/usr/bin/env bash
set -Eeuo pipefail
TF_ROOT=${TF_ROOT:-/opt/tunnelforge}
for f in common logging config state driver health remote rollback cleanup benchmark controller menu; do
  source "$TF_ROOT/core/$f.sh"
done
setup_logging

cmd_help(){
  cat <<'EOF'
TunnelForge - tunnel experimentation & deployment platform

Usage:
  tunnelforge                         Interactive menu
  tunnelforge init                    Configure endpoints and ports
  tunnelforge drivers                 List stable/experimental drivers
  tunnelforge commands DRIVER         Generate Manual Mode commands
  tunnelforge deploy DRIVER ROLE      Deploy on iran|foreign
  tunnelforge orchestrate DRIVER      Deploy both nodes over SSH
  tunnelforge status                  Show H0-H5 status
  tunnelforge test                    H3 authenticated data-path test
  tunnelforge app-test                H4 destination test (Foreign)
  tunnelforge verify yes|no           Record real-user H5 result
  tunnelforge benchmark LEVEL [--yes]
  tunnelforge next
  tunnelforge auto
  tunnelforge history
  tunnelforge down
EOF
}

if (($# == 0)); then
  ui_main_menu
  exit 0
fi

cmd=$1
shift || true
case "$cmd" in
  menu) ui_main_menu;;
  init) cmd_init "$@";;
  config) cmd_config;;
  drivers) cmd_drivers;;
  deploy|up) cmd_deploy "$@";;
  down|cleanup) cleanup_current;;
  status) cmd_status;;
  test) cmd_test;;
  app-test) cmd_app_test;;
  verify) cmd_verify "$@";;
  history) cmd_history;;
  commands) cmd_commands "$@";;
  import-runtime) cmd_import_runtime "$@";;
  orchestrate) cmd_orchestrate "$@";;
  benchmark) benchmark_run "$@";;
  next) cmd_next;;
  auto) cmd_auto;;
  version|--version|-v) cat "$TF_ROOT/VERSION";;
  help|--help|-h) cmd_help;;
  *) die "unknown command: $cmd";;
esac
