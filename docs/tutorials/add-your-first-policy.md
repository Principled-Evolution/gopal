# Add your first GOPAL policy

In 20 minutes you'll write a working AI-governance policy, a test for it, and have both pass GOPAL's CI checks.

We'll write a simple policy: **"the AI system must log every model invocation."** That's a piece of NIST AI RMF *Measure* and EU AI Act Article 12, but here we'll treat it as a freestanding rule so the example stays self-contained.

## Prerequisites

```bash
curl -L -o opa https://openpolicyagent.org/downloads/latest/opa_linux_amd64 \
  && chmod +x opa && sudo mv opa /usr/local/bin/
curl -L -o regal https://github.com/open-policy-agent/regal/releases/latest/download/regal_Linux_x86_64 \
  && chmod +x regal && sudo mv regal /usr/local/bin/
git clone https://github.com/Principled-Evolution/gopal.git
cd gopal
```

## Step 1: Decide where the policy lives

GOPAL groups policies by **scope**:

| Top-level directory | When to use |
|---|---|
| `international/<framework>/v<n>/` | Named regulation crossing borders (EU AI Act, NIST AI RMF, ICAO) |
| `industry_specific/<vertical>/v<n>/` | Vertical-specific (aviation, education, healthcare, bfs, automotive) |
| `global/v<n>/` | Cross-cutting principles (fairness, transparency, toxicity, accountability) |
| `operational/<area>/v<n>/` | Internal ops (cost, AIOps, corporate InfoSec) |
| `custom/` | Your private rules, git-ignored |

For "log every invocation," we'll use `global/v1/logging` because it's cross-cutting.

## Step 2: Scaffold the package

```bash
mkdir -p global/v1/logging
```

Create `global/v1/logging/logging.rego`:

```rego
package global.v1.logging

import rego.v1

metadata := {
    "title": "Invocation Logging Required",
    "description": "Every AI-system invocation must be logged for auditability.",
    "version": "1.0.0",
    "category": "global",
    "references": [
        "NIST AI RMF MEASURE 3.2: Track AI risks and trustworthiness over time",
        "EU AI Act Article 12: Record-keeping",
    ],
}

default allow := false

allow if {
    input.logging.enabled == true
    input.logging.retention_days >= 90
}

default compliance_report := {
    "policy_name": "Invocation Logging Required",
    "compliant": false,
    "reason": "Logging is not configured to meet the minimum requirement.",
    "recommendations": [
        "Enable invocation logging.",
        "Retain logs for at least 90 days.",
    ],
}

compliance_report := {
    "policy_name": "Invocation Logging Required",
    "compliant": true,
    "reason": "Logging is enabled with sufficient retention.",
    "recommendations": [],
} if allow
```

### What's happening

- **Package path** mirrors the directory: `global.v1.logging` lives at `global/v1/logging/`. CI checks this.
- **`import rego.v1`** opts into the modern Rego dialect (required by GOPAL).
- **`metadata`** is a structured comment-as-data block. Tooling can read it; auditors can read it.
- **`default allow := false`**: every GOPAL policy denies by default. The `allow` rule must explicitly establish compliance.
- **`compliance_report`**: the consumer-facing output. Always returns the same shape (`policy_name`, `compliant`, `reason`, `recommendations`).

## Step 3: Write a test

Create `global/v1/logging/logging_test.rego` next to your policy. The trailing `_test.rego` suffix and the matching package name are how OPA finds tests.

```rego
package global.v1.logging_test

import data.global.v1.logging
import rego.v1

test_allow_when_logging_enabled_and_retention_90 if {
    logging.allow with input as {
        "logging": {"enabled": true, "retention_days": 90},
    }
}

test_deny_when_logging_disabled if {
    not logging.allow with input as {
        "logging": {"enabled": false, "retention_days": 365},
    }
}

test_deny_when_retention_below_90 if {
    not logging.allow with input as {
        "logging": {"enabled": true, "retention_days": 30},
    }
}

test_compliance_report_compliant if {
    report := logging.compliance_report with input as {
        "logging": {"enabled": true, "retention_days": 90},
    }
    report.compliant == true
}

test_compliance_report_non_compliant if {
    report := logging.compliance_report with input as {
        "logging": {"enabled": false, "retention_days": 0},
    }
    report.compliant == false
    count(report.recommendations) > 0
}
```

## Step 4: Run it locally

Run the tests:

```bash
opa test global/v1/logging/ -v
```

You should see five `PASS` lines.

Now evaluate it against a sample input:

```bash
echo '{"logging": {"enabled": true, "retention_days": 365}}' \
  | opa eval -d global/v1/logging --stdin-input \
    --format pretty \
    "data.global.v1.logging.compliance_report"
```

Expected output:

```json
{
  "policy_name": "Invocation Logging Required",
  "compliant": true,
  "reason": "Logging is enabled with sufficient retention.",
  "recommendations": []
}
```

Flip `enabled` to `false` and you'll get a non-compliant verdict with recommendations.

## Step 5: Pass CI checks

GOPAL's CI runs two gates. Run them both locally:

```bash
opa check --ignore custom/ .
regal lint --ignore-files custom/ .
```

Both must pass. Common Regal fixes:

- **Variable shadowing**: rename a local variable that shadows an import
- **Use `every`** instead of comprehensions for clarity
- **Use `rule.metadata.title`** in opa fmt-friendly metadata blocks

If you need help with a specific Regal violation, see [the Regal docs](https://docs.styra.com/regal).

## Step 6: (Optional) Add an example

If your policy is useful as a standalone demo, drop it under [`examples/`](../../examples/):

```text
examples/
  logging-retention/
    input.json
    run.sh
    expected-output.json
    README.md
```

See [`examples/eu-ai-act-transparency/`](../../examples/eu-ai-act-transparency/) for the conventions.

## Step 7: Open a PR

Use the `new_policy.md` issue template first if you want to discuss the obligation interpretation before writing code. Otherwise send a PR with:

- the policy file
- the test file
- (optionally) an example
- a one-paragraph description in the PR linking to the regulation or governance principle it encodes

CI will run `opa check`, `opa test`, and `regal lint`. The CHANGELOG should get an entry noting the new policy.

## Going further

| Want to … | See |
|---|---|
| Add a brand-new regulatory framework | [`skills/add-framework/SKILL.md`](../../skills/add-framework/SKILL.md): Claude Code skill that scaffolds the directory tree, framework README, and first policy |
| Use the standard reporting helpers | [`helper_functions/reporting.rego`](../../helper_functions/reporting.rego): `compose_report()`, `validate_required_fields()` |
| Understand authoring conventions in depth | [`AGENTS.md`](../../AGENTS.md) |
| Check which obligations are still open | [`docs/coverage/`](../coverage/) |
