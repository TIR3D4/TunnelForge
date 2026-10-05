#!/usr/bin/env bash
rollback_driver(){ local driver=$1 role=$2;log WARN "rollback driver=$driver role=$role";load_driver "$driver";driver_cleanup "$role"||true;state_clear;history_add action=rollback driver="$driver" role="$role" result=completed; }
