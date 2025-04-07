# Governance OPA Library (GOPAL) - for AI System Evaluations

[![OPA Policies CI](https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml/badge.svg)](https://github.com/Principled-Evolution/gopal/actions/workflows/opa-ci.yaml)
[![OPA Version](https://img.shields.io/badge/OPA-Latest-blue.svg)](https://www.openpolicyagent.org/)
[![Regal Linting](https://img.shields.io/badge/linting-regal-yellow.svg)](https://github.com/StyraInc/regal)
[![License: Apache 2.0](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://makeapullrequest.com)

GOPAL is a collection of Open Policy Agent (OPA) policies designed for evaluating AI systems against regulatory requirements, compliance standards, and operational criteria. It serves as the policy engine for [AICertify](https://github.com/principled-evolution/aicertify) but can also be used independently with other OPA-based systems.

<img src="https://www.mermaidchart.com/raw/3a013c43-9ae3-4194-8bba-86b17004c800?theme=light&version=v0.1&format=svg" alt="Mermaid Chart" width="500" height="400">

## Directory Structure

```
gopal/
├── global/               # Global policies applicable across all domains
│   ├── v1/               # Version 1 of global policies
│   └── library/          # Reusable policy components
├── international/        # International regulatory frameworks
│   ├── eu_ai_act/        # European Union AI Act
│   ├── india/            # Indian AI regulatory frameworks
│   └── nist/             # NIST AI standards
├── industry_specific/    # Industry-specific requirements
│   ├── bfs/              # Banking & Financial Services
│   ├── healthcare/       # Healthcare industry
│   └── automotive/       # Automotive industry
├── operational/          # Operational policies
│   ├── aiops/            # AI Operations policies
│   ├── cost/             # Cost management policies
│   └── corporate/        # Corporate internal policies
├── custom/               # Custom policy categories
└── helper_functions/     # Shared utility functions for policies
```

## Policy Organization

Policies are organized in a modular structure to allow for clear separation of concerns and flexible composition:

1. **Global Policies**: Baseline requirements applicable to all AI systems
2. **International Policies**: Requirements from specific regulatory frameworks
3. **Industry-Specific Policies**: Requirements specific to industry verticals
4. **Operational Policies**: Requirements related to operational aspects
5. **Custom Policies**: User-defined policy categories

## Versioning

Each policy category uses versioned directories (e.g., `v1/`) to support evolution while maintaining backward compatibility. When referencing policies:

- Use specific versions when policy stability is required
- Use the latest version when up-to-date compliance is more important

## Integration with AICertify

Gopal is designed to work seamlessly with [AICertify](https://github.com/principled-evolution/aicertify), a framework for systematically evaluating AI systems against regulatory requirements. When used with AICertify, Gopal provides the policy rules that determine compliance status.

## Standalone Usage

Gopal can also be used independently with any OPA-compatible system. The policies follow standard OPA patterns and can be evaluated using the OPA CLI or API.

## Development

### Pre-commit Hooks

This repository includes pre-commit hooks to ensure code quality. The hooks run:

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
curl -L -o regal https://github.com/StyraInc/regal/releases/latest/download/regal_Linux_x86_64
chmod +x regal
sudo mv regal /usr/local/bin/

# Install the pre-commit hooks
pre-commit install
```

## License

This project is licensed under the [Apache 2.0 License](LICENSE).
