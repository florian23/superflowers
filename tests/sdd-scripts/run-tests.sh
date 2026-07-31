#!/usr/bin/env bash
# Run every deterministic SDD helper-script test in this directory.
# Unlike tests/claude-code/, these make no model calls — they are fast and hermetic.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

failed=0
for t in "$SCRIPT_DIR"/test-*.sh; do
  [ -f "$t" ] || continue
  echo "=== $(basename "$t") ==="
  if "$t"; then
    echo ""
  else
    echo "FAILED: $(basename "$t")" >&2
    failed=1
  fi
done

exit "$failed"
