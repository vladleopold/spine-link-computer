#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

# This repository must not schedule work on a persistent/self-hosted runner.
if [[ -e "$ROOT/.github/workflows/spine-worker-health.yml" ]]; then
  echo 'A self-hosted Spine worker workflow must not be present.' >&2
  exit 1
fi
if grep -R -nE 'runs-on:.*self-hosted|runs-on:.*\[.*self-hosted' "$ROOT/.github/workflows"; then
  echo 'A self-hosted Actions runner target was found.' >&2
  exit 1
fi

grep -qi 'retired.*self-hosted\|self-hosted.*retired' "$ROOT/README.md"
if grep -R -nE 'github_pat_[A-Za-z0-9_]+' "$ROOT" --exclude-dir=.git --exclude=test_setup_contract.sh; then
  echo 'A credential-like value was committed.' >&2
  exit 1
fi

echo 'PUBLIC_GITHUB_HOSTED_RUNNER_ONLY_OK'
