package international.eu_ai_act.v1.transparency_test

import data.international.eu_ai_act.v1.transparency as policy
import rego.v1

# A system with complete documentation and a measured, acceptable toxicity
# reading. Every case below is this fixture with one thing taken away.
compliant := {
	"documentation": {
		"technical_documentation": {"completeness": 0.9},
		"explainability": {"completeness": 0.9},
	},
	"metrics": {
		"model_card": {"completeness": 0.9},
		"toxicity": {"max_toxicity": 0.08},
	},
}

test_allow_when_documented_and_toxicity_measured_low if {
	policy.allow with input as compliant
}

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}

# The defect this suite was written for. `allow` used to require
# `not has_high_toxicity`, and has_high_toxicity is undefined when nothing was
# measured. Undefined negates to true, so a fully documented system that had
# never been tested for toxicity satisfied the toxicity condition of Article 13.
test_unmeasured_toxicity_denies if {
	not policy.allow with input as object.remove(compliant, {"metrics"})
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/metrics/toxicity",
	}])
}

# And it must say so, rather than denying for an unrelated stated reason.
test_unmeasured_toxicity_is_reported_as_unmeasured if {
	reason := policy.compliance_reason with input as json.patch(compliant, [{
		"op": "remove", "path": "/metrics/toxicity",
	}])
	contains(reason, "has not been measured")
}

test_high_toxicity_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/metrics/toxicity/max_toxicity", "value": 0.8,
	}])
}

# 0.7 is the limit, and the limit is allowed. The rules either side of it are
# `<= 0.7` and `> 0.7`, so this pins which one owns the boundary.
test_toxicity_at_the_threshold_allows if {
	policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/metrics/toxicity/max_toxicity", "value": 0.7,
	}])
}

test_toxicity_just_above_the_threshold_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/metrics/toxicity/max_toxicity", "value": 0.71,
	}])
}

test_missing_documentation_denies if {
	not policy.allow with input as object.remove(compliant, {"documentation"})
}

# Each of the three completeness readings gates allow on its own.
test_incomplete_technical_documentation_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/documentation/technical_documentation/completeness", "value": 0.6,
	}])
}

test_incomplete_model_card_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/metrics/model_card/completeness", "value": 0.6,
	}])
}

test_incomplete_explainability_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/documentation/explainability/completeness", "value": 0.6,
	}])
}

# Absent is not the same as low, and neither may pass.
test_absent_completeness_denies if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/documentation/explainability",
	}])
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/metrics/model_card",
	}])
}

# The report must exist and agree with the decision. A report rule that goes
# undefined deletes the finding rather than stating it.
test_report_agrees_with_the_decision if {
	pass_report := policy.compliance_report with input as compliant
	pass_report.compliant == true

	fail_report := policy.compliance_report with input as json.patch(compliant, [{
		"op": "remove", "path": "/metrics/toxicity",
	}])
	fail_report.compliant == false
}

# Each failure shape gets its own reason. A chain that collapses two different
# failures into one message sends the wrong work to the wrong person, and the
# ordering that keeps them apart is easy to break by inserting a branch.
#
# Each reason is bound to a variable first. `x with input as doc == y` parses
# as `x with input as (doc == y)`: the comparison is swallowed into the input
# and the expression asserts only that x is truthy, so the test passes whatever
# the reason turns out to be.
test_each_failure_shape_has_its_own_reason if {
	incomplete := json.patch(compliant, [{
		"op": "replace", "path": "/documentation/technical_documentation/completeness", "value": 0.5,
	}])
	toxic := json.patch(compliant, [{
		"op": "replace", "path": "/metrics/toxicity/max_toxicity", "value": 0.9,
	}])
	unmeasured := json.patch(compliant, [{"op": "remove", "path": "/metrics/toxicity"}])
	incomplete_unmeasured := json.patch(unmeasured, [{
		"op": "replace", "path": "/documentation/technical_documentation/completeness", "value": 0.5,
	}])
	incomplete_toxic := json.patch(incomplete, [{
		"op": "replace", "path": "/metrics/toxicity/max_toxicity", "value": 0.9,
	}])

	met_reason := policy.compliance_reason with input as compliant
	met_reason == policy.reasons.met

	none_reason := policy.compliance_reason with input as {}
	none_reason == policy.reasons.no_documentation

	incomplete_reason := policy.compliance_reason with input as incomplete
	incomplete_reason == policy.reasons.incomplete

	toxic_reason := policy.compliance_reason with input as toxic
	toxic_reason == policy.reasons.high_toxicity

	unmeasured_reason := policy.compliance_reason with input as unmeasured
	unmeasured_reason == policy.reasons.unmeasured_toxicity

	both_missing_reason := policy.compliance_reason with input as incomplete_unmeasured
	both_missing_reason == policy.reasons.incomplete_and_unmeasured

	both_bad_reason := policy.compliance_reason with input as incomplete_toxic
	both_bad_reason == policy.reasons.incomplete_and_toxic
}
