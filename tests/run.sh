#!/usr/bin/env bash
set -Eeuo pipefail

ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
cd "$ROOT"

mapfile -t shell_files < <(find . -type f -name '*.sh' -o -path './tunnelforge' | sort)

printf 'Running bash syntax checks...\n'
for file in "${shell_files[@]}"; do
  bash -n "$file"
  printf '  PASS %s\n' "$file"
done

printf 'Checking driver contract...\n'
for file in drivers/*.sh; do
  for fn in driver_preflight driver_install driver_configure driver_start driver_health driver_cleanup; do
    grep -Eq "(^|[[:space:]])${fn}[[:space:]]*\(\)" "$file" || {
      printf '  FAIL %s missing %s\n' "$file" "$fn" >&2
      exit 1
    }
  done
  printf '  PASS %s\n' "$file"
done

if command -v shellcheck >/dev/null 2>&1; then
  printf 'Running ShellCheck...\n'
  shellcheck -x install.sh tunnelforge core/*.sh drivers/*.sh tests/*.sh
else
  printf 'ShellCheck not installed; skipping local lint. CI runs it.\n'
fi

printf 'All checks passed.\n'
