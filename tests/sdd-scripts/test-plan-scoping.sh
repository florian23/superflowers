#!/usr/bin/env bash
# Test: SDD workspace scripts are plan-scoped
# Two different plans must resolve to two different workspace directories.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SCRIPTS="$REPO_ROOT/skills/subagent-driven-development/scripts"

fail() { echo "FAIL: $*" >&2; exit 1; }

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
git init -q .
git config user.email t@t.t
git config user.name t
mkdir -p plans
printf '# Plan A\n\n### Task 1: Alpha\n\nalpha body\n\n### Task 2: Beta\n\nbeta body\n' > plans/plan-a.md
printf '# Plan B\n\n### Task 1: Gamma\n\ngamma body\n' > plans/plan-b.md
git add -A && git commit -qm init

a=$("$SCRIPTS/sdd-workspace" plans/plan-a.md)
b=$("$SCRIPTS/sdd-workspace" plans/plan-b.md)

[ "$a" != "$b" ] || fail "both plans resolved to the same workspace: $a"
case "$a" in */.superflowers/sdd/plan-a) ;; *) fail "unexpected workspace path: $a" ;; esac
case "$b" in */.superflowers/sdd/plan-b) ;; *) fail "unexpected workspace path: $b" ;; esac
[ -f "$work/.superflowers/sdd/.gitignore" ] || fail ".gitignore not written at the sdd/ base"
[ -z "$(git status --porcelain)" ] || fail "workspace leaked into git status"

# task-brief and review-package print "wrote <PATH>: <summary>" on stdout
# (not the bare path), so extract PATH from the message before asserting on it.
briefmsg=$("$SCRIPTS/task-brief" plans/plan-a.md 2)
brief=${briefmsg#wrote }
brief=${brief%%: *}
case "$brief" in "$a"/task-2-brief.md) ;; *) fail "brief not in plan A workspace: $briefmsg" ;; esac
grep -q "beta body" "$brief" || fail "brief missing Task 2 body"
grep -q "alpha body" "$brief" && fail "brief bled Task 1 into Task 2"

base=$(git rev-parse HEAD)
echo change >> plans/plan-a.md
git commit -qam change
pkgmsg=$("$SCRIPTS/review-package" plans/plan-a.md "$base" HEAD)
pkg=${pkgmsg#wrote }
pkg=${pkg%%: *}
case "$pkg" in "$a"/review-*..*.diff) ;; *) fail "package not in plan A workspace: $pkgmsg" ;; esac
grep -q "^# Review package:" "$pkg" || fail "package missing header"

"$SCRIPTS/sdd-workspace" && fail "sdd-workspace accepted a missing PLAN_FILE argument"

echo "PASS: plan-scoping"
