#!/usr/bin/env bash
# Interactive terminal UI for TunnelForge.

ui_color_init(){
  if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != 1 ]]; then
    C_RESET=$'\033[0m'; C_BOLD=$'\033[1m'; C_DIM=$'\033[2m'
    C_CYAN=$'\033[36m'; C_GREEN=$'\033[32m'; C_YELLOW=$'\033[33m'
    C_RED=$'\033[31m'; C_BLUE=$'\033[34m'; C_WHITE=$'\033[97m'
  else
    C_RESET=''; C_BOLD=''; C_DIM=''; C_CYAN=''; C_GREEN=''; C_YELLOW=''; C_RED=''; C_BLUE=''; C_WHITE=''
  fi
}
ui_clear(){ [[ -t 1 ]] && clear || true; }
ui_line(){ printf '%s\n' '────────────────────────────────────────────────────────────'; }
ui_pause(){ echo; read -rp "Press Enter to continue..." _ || true; }

ui_banner(){
  ui_color_init
  ui_clear
  printf '%s%s' "$C_CYAN" "$C_BOLD"
  cat <<'EOF'
 _______                      _ ______
|__   __|                    | |  ____|
   | |_   _ _ __  _ __   ___| | |__ ___  _ __ __ _  ___
   | | | | | '_ \| '_ \ / _ \ |  __/ _ \| '__/ _` |/ _ \
   | | |_| | | | | | | |  __/ | | | (_) | | | (_| |  __/
   |_|\__,_|_| |_|_| |_|\___|_|_|  \___/|_|  \__, |\___|
                                                __/ |
                                               |___/
EOF
  printf '%s' "$C_RESET"
  printf '%sTunnel Experimentation & Deployment Platform%s\n' "$C_DIM" "$C_RESET"
  ui_line
}

ui_config_summary(){
  if [[ -f "$TF_CONFIG" ]]; then
    if load_config >/dev/null 2>&1; then
      printf ' Iran VPS      %s%s%s\n' "$C_WHITE" "$IRAN_IP:$SERVICE_PORT" "$C_RESET"
      printf ' Foreign VPS   %s%s%s\n' "$C_WHITE" "$FOREIGN_IP" "$C_RESET"
      printf ' Destination   %s%s:%s%s\n' "$C_WHITE" "$DESTINATION_HOST" "$DESTINATION_PORT" "$C_RESET"
      printf ' Transport     %s:%s\n' "$FOREIGN_IP" "$TRANSPORT_PORT"
    else
      printf ' Config        %sINVALID%s\n' "$C_RED" "$C_RESET"
    fi
  else
    printf ' Config        %sNot configured%s\n' "$C_YELLOW" "$C_RESET"
  fi

  if [[ -f "$TF_STATE" ]]; then
    local d role uv
    d=$(state_get driver); role=$(state_get role); uv=$(state_get user_verified)
    printf ' Active        %s%s / %s%s\n' "$C_GREEN" "$d" "$role" "$C_RESET"
    printf ' User verify   %s%s%s\n' "$([[ $uv == yes ]] && echo "$C_GREEN" || echo "$C_YELLOW")" "$uv" "$C_RESET"
  else
    printf ' Active        %snone%s\n' "$C_DIM" "$C_RESET"
  fi
  ui_line
}

ui_driver_menu(){
  local choice
  echo " Stable drivers"
  echo "  1) GRE        — L3 tunnel"
  echo "  2) HAProxy    — Direct TCP relay"
  echo "  3) rinetd     — Lightweight TCP relay"
  echo "  4) socat      — Simple TCP relay"
  echo "  5) GOST       — TCP relay tunnel"
  echo "  6) wstunnel   — WebSocket tunnel"
  echo "  0) Back"
  echo
  read -rp " Select driver [0-6]: " choice
  case "$choice" in
    1) printf 'gre';;
    2) printf 'haproxy';;
    3) printf 'rinetd';;
    4) printf 'socat';;
    5) printf 'gost';;
    6) printf 'wstunnel';;
    0|'') return 1;;
    *) echo "Invalid selection" >&2; return 2;;
  esac
}

ui_role_menu(){
  local choice
  echo " Server role"
  echo "  1) Iran Server"
  echo "  2) Foreign Server"
  echo "  0) Back"
  echo
  read -rp " Select role [0-2]: " choice
  case "$choice" in
    1) printf 'iran';;
    2) printf 'foreign';;
    0|'') return 1;;
    *) echo "Invalid selection" >&2; return 2;;
  esac
}

ui_deploy(){
  ui_banner; ui_config_summary
  [[ -f "$TF_CONFIG" ]] || { echo "Run Quick Setup first."; ui_pause; return; }
  local driver role
  driver=$(ui_driver_menu) || return
  echo
  role=$(ui_role_menu) || return
  echo
  printf '%sDeploying %s on %s...%s\n' "$C_CYAN" "$driver" "$role" "$C_RESET"
  cmd_deploy "$driver" "$role"
  ui_pause
}

ui_manual_commands(){
  ui_banner; ui_config_summary
  [[ -f "$TF_CONFIG" ]] || { echo "Run Quick Setup first."; ui_pause; return; }
  local driver
  driver=$(ui_driver_menu) || return
  echo
  cmd_commands "$driver"
  echo
  printf '%sRun Foreign Command first, then Iran Command.%s\n' "$C_YELLOW" "$C_RESET"
  ui_pause
}

ui_benchmark(){
  ui_banner; ui_config_summary
  echo " Benchmark level"
  echo "  1) L1   1 connection"
  echo "  2) L2   50 connections"
  echo "  3) L3   250 connections (confirmation required)"
  echo "  4) L4   1000 connections (confirmation required)"
  echo "  0) Back"
  local c level confirm=''
  read -rp " Select [0-4]: " c
  case "$c" in
    1) level=L1;;
    2) level=L2;;
    3) level=L3; confirm=--yes;;
    4) level=L4; confirm=--yes;;
    *) return;;
  esac
  if [[ -n "$confirm" ]]; then
    read -rp " Heavy benchmark may create significant load. Type YES to continue: " c
    [[ $c == YES ]] || { echo "Cancelled."; ui_pause; return; }
  fi
  benchmark_run "$level" "$confirm"
  ui_pause
}

ui_cleanup(){
  ui_banner; ui_config_summary
  if [[ ! -f "$TF_STATE" ]]; then echo "No active TunnelForge deployment."; ui_pause; return; fi
  local d role ans
  d=$(state_get driver); role=$(state_get role)
  read -rp " Remove TunnelForge deployment $d/$role? [y/N]: " ans
  [[ $ans =~ ^[Yy]$ ]] || return
  cleanup_current
  ui_pause
}

ui_main_menu(){
  while true; do
    ui_banner
    ui_config_summary
    printf '%s Main Menu%s\n' "$C_BOLD" "$C_RESET"
    echo "  1) Quick Setup / Configure"
    echo "  2) Deploy / Change Tunnel"
    echo "  3) Status"
    echo "  4) Test Data Path (H3)"
    echo "  5) Application Test (H4, Foreign)"
    echo "  6) Benchmark"
    echo "  7) Generate Manual Commands"
    echo "  8) Drivers"
    echo "  9) History"
    echo " 10) Cleanup Tunnel"
    echo " 11) Advanced / CLI Help"
    echo "  0) Exit"
    echo
    local choice
    read -rp " Select option: " choice
    case "$choice" in
      1) cmd_init; ui_pause;;
      2) ui_deploy;;
      3) ui_banner; cmd_status; ui_pause;;
      4) ui_banner; cmd_test; ui_pause;;
      5) ui_banner; cmd_app_test; ui_pause;;
      6) ui_benchmark;;
      7) ui_manual_commands;;
      8) ui_banner; cmd_drivers; ui_pause;;
      9) ui_banner; cmd_history; ui_pause;;
      10) ui_cleanup;;
      11) ui_banner; cmd_help; ui_pause;;
      0|q|Q) printf 'Bye.\n'; return 0;;
      *) echo "Invalid option"; sleep 1;;
    esac
  done
}
