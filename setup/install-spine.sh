#!/usr/bin/env bash
set -euo pipefail
set +x
: "${SPINE_ACTIVATION_CODE:?Set SPINE_ACTIVATION_CODE from your authorized Spine license page}"
: "${SPINE_LINUX_URL:?Set SPINE_LINUX_URL to the direct Linux launcher archive URL}"
[[ "$(uname -s)" == Linux ]] || { echo 'Linux only.' >&2; exit 1; }
command -v xvfb-run >/dev/null || { echo 'Run setup/bootstrap-ubuntu.sh first.' >&2; exit 1; }

RUN_AS_USER="${SPINE_RUN_AS_USER:-spine-runner}"
id "$RUN_AS_USER" >/dev/null
HOME_DIR="$(getent passwd "$RUN_AS_USER" | cut -d: -f6)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT
ARCHIVE="$TMP_DIR/spine-linux.gz"

curl --fail --location --silent --show-error --retry 2 --max-time 600 \
  -A 'Mozilla/5.0 (X11; Linux x86_64)' "$SPINE_LINUX_URL" -o "$ARCHIVE"
gzip -t "$ARCHIVE"
mkdir -p "$TMP_DIR/unpacked"
gzip -dc "$ARCHIVE" | tar -xf - -C "$TMP_DIR/unpacked"
SPINE_CLI="$(find "$TMP_DIR/unpacked" -type f -name Spine.sh -print -quit)"
[[ -n "$SPINE_CLI" && -x "$SPINE_CLI" ]] || { echo 'Spine.sh not found in downloaded archive.' >&2; exit 1; }

install -d -o "$RUN_AS_USER" -g "$RUN_AS_USER" -m 0750 /opt/spine
cp -a "$TMP_DIR/unpacked/." /opt/spine/
chown -R "$RUN_AS_USER:$RUN_AS_USER" /opt/spine
SPINE_CLI="$(find /opt/spine -type f -name Spine.sh -print -quit)"
[[ -n "$SPINE_CLI" && -x "$SPINE_CLI" ]] || { echo 'Installed Spine.sh is missing.' >&2; exit 1; }

sudo -u "$RUN_AS_USER" env HOME="$HOME_DIR" xvfb-run -a "$SPINE_CLI" --install "$SPINE_ACTIVATION_CODE" \
  >"$TMP_DIR/activation.log" 2>&1 || {
    echo 'Spine activation failed. Inspect the protected local activation log as host administrator.' >&2
    install -o root -g root -m 0600 "$TMP_DIR/activation.log" /root/spine-activation.log
    exit 1
  }

for version in ${SPINE_VERSIONS:-3.7.94 4.3.26}; do
  sudo -u "$RUN_AS_USER" env HOME="$HOME_DIR" xvfb-run -a "$SPINE_CLI" --update "$version" \
    >"$TMP_DIR/update-$version.log" 2>&1 || {
      echo "Could not install Spine Editor version $version. See protected local log." >&2
      install -o root -g root -m 0600 "$TMP_DIR/update-$version.log" "/root/spine-update-$version.log"
      exit 1
    }
done
printf '%s\n' "$SPINE_CLI" > /opt/spine/Spine.sh.path
chown root:root /opt/spine/Spine.sh.path
chmod 0644 /opt/spine/Spine.sh.path
echo 'SPINE_EDITOR_INSTALLED_AND_ACTIVATED'
