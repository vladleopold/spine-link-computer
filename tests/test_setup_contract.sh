#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
grep -q 'google-chrome-stable' "$ROOT/setup/bootstrap-ubuntu.sh"
grep -q 'SPINE_ACTIVATION_CODE' "$ROOT/setup/install-spine.sh"
grep -q -- '--install' "$ROOT/setup/install-spine.sh"
grep -q '3.7.94' "$ROOT/setup/install-spine.sh"
grep -q '4.3.26' "$ROOT/setup/install-spine.sh"
grep -q 'GITHUB_RUNNER_TOKEN' "$ROOT/setup/configure-runner.sh"
grep -q '3Spine-core' "$ROOT/setup/configure-runner.sh"
grep -q 'spine-editor' "$ROOT/setup/configure-runner.sh"
grep -q 'actions/runners/registration-token' "$ROOT/README.md"
grep -q 'root privileges' "$ROOT/setup/configure-runner.sh"
if grep -R -nE 'github_pat_[A-Za-z0-9_]+' "$ROOT" --exclude-dir=.git --exclude=test_setup_contract.sh; then
  echo 'A credential-like value was committed.' >&2
  exit 1
fi
echo 'SETUP_CONTRACT_OK'
