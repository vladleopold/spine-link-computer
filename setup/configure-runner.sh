#!/usr/bin/env bash
set -euo pipefail
set +x
[[ "$EUID" -eq 0 ]] || { echo 'Run this setup script with sudo/root privileges.' >&2; exit 1; }
: "${GITHUB_RUNNER_TOKEN:?Generate a short-lived repository runner registration token first}"
REPO_URL="${GITHUB_REPO_URL:-https://github.com/vladleopold/spine-link-computer}"
RUNNER_USER="${RUNNER_USER:-spine-runner}"
RUNNER_HOME="$(getent passwd "$RUNNER_USER" | cut -d: -f6)"
[[ -n "$RUNNER_HOME" ]] || { echo 'Dedicated spine-runner account is missing.' >&2; exit 1; }

RUNNER_DIR="$RUNNER_HOME/actions-runner"
install -d -o "$RUNNER_USER" -g "$RUNNER_USER" "$RUNNER_DIR"
cd "$RUNNER_DIR"
if [[ ! -x ./config.sh ]]; then
  LOCATION="$(curl -fsSI https://github.com/actions/runner/releases/latest | tr -d '\r' | awk 'tolower($1)=="location:"{print $2}')"
  VERSION="$(printf '%s' "$LOCATION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
  [[ -n "$VERSION" ]] || { echo 'Could not resolve GitHub Actions runner version.' >&2; exit 1; }
  curl -fsSL "https://github.com/actions/runner/releases/download/v${VERSION}/actions-runner-linux-x64-${VERSION}.tar.gz" -o runner.tar.gz
  tar xzf runner.tar.gz
  rm runner.tar.gz
  chown -R "$RUNNER_USER:$RUNNER_USER" "$RUNNER_DIR"
fi
./bin/installdependencies.sh >/dev/null
runuser -u "$RUNNER_USER" -- env HOME="$RUNNER_HOME" ./config.sh \
  --url "$REPO_URL" --token "$GITHUB_RUNNER_TOKEN" \
  --name spine-link-ubuntu-01 --labels spine-editor,chrome --work _work \
  --unattended --replace --disableupdate
./svc.sh install "$RUNNER_USER"
./svc.sh start
unset GITHUB_RUNNER_TOKEN
echo 'GITHUB_ACTIONS_RUNNER_SERVICE_STARTED'
