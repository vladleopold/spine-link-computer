# Spine Link Computer — retired self-hosted runner

**Retired:** this repository previously documented a persistent Ubuntu host registered as a self-hosted GitHub Actions runner. That execution model is no longer approved for this project.

Do not run the bootstrap, Spine installation, or runner-registration scripts in this repository. Do not register a self-hosted runner or install a persistent runner service for Spine Link tasks.

## Approved execution model

All automated project jobs must execute on GitHub-hosted Ubuntu runners from approved public repositories, including:

- `SpineAnimator/sa-public-runner`
- `SpineAnimator/sa-psd-tool-runner`
- `SpineAnimator/2Spine-visual-audit`
- `SpineAnimator/Spine-Link-project-export`

A public reusable workflow is not sufficient by itself when called from a private repository: execution and billing remain in the caller's context. Use public-repository scheduled or explicitly dispatched orchestration where appropriate, and keep private source access read-only and credentials unpersisted.

## Repository status

The remaining setup files are retained as historical reference only. The only active workflow here is the lightweight repository contract check, which runs on GitHub-hosted Ubuntu and verifies that no self-hosted Actions target is enabled.

Licensed Spine Editor assets, activation codes, download URLs, runner registration tokens, private PSDs, and customer deliverables must never be committed to this public repository.
