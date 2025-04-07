# GitHub Workflows for OPA Policies

This directory contains GitHub Actions workflows for the OPA policies submodule.

## Workflows

- **opa-ci.yaml**: Runs OPA checks and Regal linting on all Rego files in the repository.
  - Triggers: Push to main, pull requests to main, manual workflow dispatch
  - Actions:
    - Installs OPA and Regal
    - Runs `opa check .` to validate all policies
    - Runs `regal lint .` to lint all Rego files

## Pre-commit Hooks

The repository also includes pre-commit hooks in the `.pre-commit-config.yaml` file at the root of the repository. These hooks run:

1. Basic file checks (trailing whitespace, end-of-file, etc.)
2. OPA check (`opa check .`)
3. Regal lint (`regal lint .`)

To use the pre-commit hooks locally, install pre-commit, OPA, and Regal, then run:

```bash
# Install pre-commit
pip install pre-commit

# Install OPA
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64
chmod 755 opa
sudo mv opa /usr/local/bin/

# Install Regal
curl -L -o regal.tar.gz https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64.tar.gz
tar -xzf regal.tar.gz
sudo mv regal /usr/local/bin/

# Install the pre-commit hooks
pre-commit install
```
