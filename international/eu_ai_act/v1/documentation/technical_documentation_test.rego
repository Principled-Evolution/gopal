package international.eu_ai_act.v1.documentation.technical_documentation_test

import data.international.eu_ai_act.v1.documentation.technical_documentation as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}

# A threshold's documented default must apply when the caller sends no params
# at all. This policy read `object.get(input.params, "completeness_threshold",
# 0.8)`, and when the input carried no `params` key `input.params` was
# undefined, so object.get was undefined, so the rule body failed and the
# `default := false` denied. A well-documented 0.8 default that never applied,
# across 47 call sites in 10 files. The safe form is
# `object.get(input, ["params", ...], default)`, which handles the absent key.
no_params := {"metrics": {"model_card": {
	"completeness": 0.86,
	"quality": 0.81,
	"compliance_level": 0.9,
	"section_scores": {"intended_use": 0.9},
}}}

test_documented_defaults_apply_when_no_params_are_sent if {
	policy.completeness_sufficient with input as no_params
	policy.quality_sufficient with input as no_params
}

test_an_explicit_param_still_overrides_the_default if {
	stricter := object.union(no_params, {"params": {"completeness_threshold": 0.95}})
	not policy.completeness_sufficient with input as stricter
}
