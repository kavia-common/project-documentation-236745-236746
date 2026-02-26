#!/usr/bin/env bash
set -euo pipefail
WS="${WS:-/tmp/kavia/workspace/code-generation/project-documentation-236745-236746/Documentation}"
cd "$WS"
PIP_CMD="python3 -m pip"
# deterministic check for mkdocs_material (uses importlib if available to avoid deprecation)
python3 - <<'PY'
import sys
try:
    from importlib.util import find_spec
    ok = find_spec('mkdocs_material') is not None
except Exception:
    import pkgutil
    ok = pkgutil.find_loader('mkdocs_material') is not None
sys.exit(0 if ok else 1)
PY
if [ $? -ne 0 ]; then
  echo "mkdocs-material not present; installing to user site" >&2
  # try user install first
  $PIP_CMD install --user mkdocs-material >/dev/null || {
    echo "pip install mkdocs-material failed" >&2
    $PIP_CMD --version 2>/dev/null || true
    $PIP_CMD show mkdocs-material 2>/dev/null || true
    exit 4
  }
  # verify importability after install
  python3 - <<'PY'
import sys
try:
    from importlib.util import find_spec
    ok = find_spec('mkdocs_material') is not None
except Exception:
    import pkgutil
    ok = pkgutil.find_loader('mkdocs_material') is not None
sys.exit(0 if ok else 2)
PY
  if [ $? -ne 0 ]; then echo "mkdocs-material install did not produce importable package" >&2; exit 5; fi
fi
exit 0
