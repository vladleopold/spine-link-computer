# Spine Link Computer — Ubuntu CI worker

Dedicated Ubuntu 24.04 x86_64 machine for Spine Link automation. The worker is a self-hosted GitHub Actions runner with Google Chrome, Xvfb/software OpenGL and the licensed Spine launcher/editor.

## Why jobs were queued

A job targeting self-hosted, linux, X64 stays queued until a matching runner is online. GitHub-hosted Actions cannot turn this repository into a persistent server. This repository supplies the reproducible server bootstrap; it must be run on an Ubuntu VM/host that remains powered on and connected to GitHub.

## Bootstrap (Ubuntu 24.04 x86_64)

Use a dedicated machine and a dedicated Linux account. Do not run the runner as root.

    git clone https://github.com/vladleopold/spine-link-computer.git
    cd spine-link-computer
    sudo bash setup/bootstrap-ubuntu.sh

Install the licensed Spine launcher/editor. The license page in the private Spine.txt Library file contains the activation code and Linux download link. Do not commit either value or paste them into chat/logs.

    read -rsp 'Spine activation code: ' SPINE_ACTIVATION_CODE; echo
    read -rsp 'Direct Linux launcher download URL: ' SPINE_LINUX_URL; echo
    export SPINE_ACTIVATION_CODE SPINE_LINUX_URL
    bash setup/install-spine.sh
    unset SPINE_ACTIVATION_CODE SPINE_LINUX_URL

The installer activates using Spine.sh --install and installs pinned editor versions 3.7.94 and 4.3.26. Confirm the license terms authorize the intended CI use and seat; Esoteric Software distinguishes named-user licenses from dedicated CI/Enterprise seats.

Register the runner with a short-lived registration token generated while authenticated as a repository administrator:

    gh auth login
    export GITHUB_RUNNER_TOKEN="$(gh api repos/vladleopold/spine-link-computer/actions/runners/registration-token --method POST --jq .token)"
    sudo -u spine-runner env GITHUB_RUNNER_TOKEN="$GITHUB_RUNNER_TOKEN" bash setup/configure-runner.sh
    unset GITHUB_RUNNER_TOKEN

The token is short-lived and is not written into this repository. The runner is registered with labels self-hosted,linux,X64,spine-editor,chrome and installed as a system service.

## Verification

    bash tests/test_setup_contract.sh
    bash setup/verify-worker.sh

Then open Settings → Actions → Runners and verify the worker is Idle/Online. Trigger the manual workflow Spine worker health check. It verifies Chrome, Xvfb, Spine CLI and both installed editor versions.

## Secrets and safety

- Never commit .env, activation codes, license-page URLs, runner tokens, or downloaded licensed binaries.
- Keep the host dedicated to the authorized license holder; restrict SSH and runner account access.
- The worker is single-job by default to prevent concurrent use of one licensed editor installation.
- GitHub Actions logs must never print secret values.
- A runner is not online until the Ubuntu host is provisioned, the service is started, and GitHub reports it online.
