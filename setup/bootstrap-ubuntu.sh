#!/usr/bin/env bash
set -euo pipefail
[[ "$(uname -s)" == Linux ]] || { echo 'Ubuntu/Linux only.' >&2; exit 1; }
. /etc/os-release
[[ "$ID" == ubuntu && "${VERSION_ID%%.*}" == 24 ]] || {
  echo "Expected Ubuntu 24.04 (found ${PRETTY_NAME:-unknown})." >&2; exit 1;
}
[[ "$(dpkg --print-architecture)" == amd64 ]] || { echo 'Expected x86_64/amd64.' >&2; exit 1; }

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y --no-install-recommends \
  sudo ca-certificates curl wget gnupg git jq unzip zip xz-utils gzip tar \
  python3 python3-pip python3-venv nodejs npm \
  xvfb xauth x11-utils x11-xserver-utils \
  libgl1 libgl1-mesa-dri libglx-mesa0 libegl1 libxrandr2 libxrender1 \
  libxi6 libxext6 libxfixes3 libxcursor1 libasound2t64 libnss3 \
  libatk1.0-0t64 libatk-bridge2.0-0t64 libcups2t64 libdrm2 libgbm1 \
  libgtk-3-0t64 fonts-liberation

install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
  | gpg --dearmor --yes -o /etc/apt/keyrings/google-chrome.gpg
chmod 0644 /etc/apt/keyrings/google-chrome.gpg
echo 'deb [arch=amd64 signed-by=/etc/apt/keyrings/google-chrome.gpg] https://dl.google.com/linux/chrome/deb/ stable main' \
  > /etc/apt/sources.list.d/google-chrome.list
apt-get update
apt-get install -y google-chrome-stable

if ! id spine-runner >/dev/null 2>&1; then
  useradd --create-home --shell /bin/bash spine-runner
fi
install -d -o spine-runner -g spine-runner -m 0750 /opt/spine
echo 'UBUNTU_WORKER_PACKAGES_INSTALLED'
google-chrome --version
