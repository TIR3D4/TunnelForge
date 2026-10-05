#!/usr/bin/env bash
set -Eeuo pipefail
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."&&pwd);cd "$ROOT"
echo '== Bash syntax ==';while IFS= read -r f;do bash -n "$f";echo "PASS $f";done < <(find . -type f -name '*.sh'|sort)
echo '== Unit-style checks ==';for t in tests/test_*.sh;do bash "$t";echo "PASS $t";done
if command -v shellcheck >/dev/null 2>&1;then echo '== ShellCheck ==';shellcheck -x -S error install.sh cmd/*.sh core/*.sh drivers/*/*.sh tests/*.sh;else echo 'ShellCheck not installed locally; CI installs it.';fi
echo 'All checks passed.'
