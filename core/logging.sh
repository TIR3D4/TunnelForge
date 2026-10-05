#!/usr/bin/env bash
setup_logging(){ mkdir -p "$TF_LOG_DIR" "$TF_VAR"; touch "$TF_LOG" "$TF_HISTORY"; chmod 600 "$TF_LOG" "$TF_HISTORY"; }
