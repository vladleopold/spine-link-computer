#!/usr/bin/env bash
set -euo pipefail
command -v google-chrome >/dev/null
google-chrome --version
command -v xvfb-run >/dev/null
SPINE_CLI="${SPINE_CLI:-$(cat /opt/spine/Spine.sh.path 2>/dev/null || true)}"
[[ -x "$SPINE_CLI" ]] || { echo 'Spine.sh is not installed.' >&2; exit 1; }
if [[ "$(id -un)" == "spine-runner" ]]; then
  HOME=/home/spine-runner xvfb-run -a "$SPINE_CLI" --version
else
  sudo -u spine-runner env HOME=/home/spine-runner xvfb-run -a "$SPINE_CLI" --version
fi
echo 'WORKER_HEALTH_OK'
