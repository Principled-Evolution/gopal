package global.v1.transparency_test

import data.global.v1.transparency

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.7}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {},
	}
}

# Test case for non-compliant input (missing model card)
test_deny_missing_model_card if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": false},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (insufficient model card completeness)
test_deny_insufficient_model_card_completeness if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.5}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing explainability)
test_deny_missing_explainability if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": false},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing limitations)
test_deny_missing_limitations if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": false},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing use cases)
test_deny_missing_use_cases if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": false},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test recommendations for missing model card
test_recommendations_missing_model_card if {
	transparency.recommendations == ["Create a model card documenting the AI system's properties, capabilities, and limitations"] with input as {
		"documentation": {
			"model_card": {"exists": false},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test recommendations for insufficient model card completeness
test_recommendations_insufficient_model_card_completeness if {
	transparency.recommendations == ["Enhance the model card with more comprehensive information about the AI system"] with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.5}},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := transparency.compliance_report with input as {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.85}},
		"params": {"model_card_completeness_threshold": 0.6},
	}

	report.details.model_card_exists == true
	report.details.model_card_completeness == 0.85
	report.details.model_card_completeness_threshold == 0.6
	report.details.explainability_provided == true
	report.details.limitations_documented == true
	report.details.use_cases_defined == true
	report.overall_result == true
	report.recommendations == []
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not transparency.allow with input as {}
}

# The metrics.model_card.completeness spelling, which is what the model card
# rubric in global/v1/documentation emits and what the Hugging Face card adapter
# feeds it. It is the only spelling: the documentation.model_card variants were
# retired in 2.0.0.
canonical_docs := {
	"documentation": {
		"model_card": {"exists": true},
		"explainability": {"provided": true},
		"limitations": {"documented": true},
		"use_cases": {"defined": true},
	},
	"metrics": {"model_card": {"completeness": 0.9}},
}

test_canonical_model_card_completeness_is_read if {
	transparency.allow with input as canonical_docs
}

test_canonical_completeness_below_threshold_denies if {
	not transparency.allow with input as json.patch(
		canonical_docs,
		[{"op": "replace", "path": "/metrics/model_card/completeness", "value": 0.5}],
	)
}

# An absent score must not satisfy allow. resolve leaves it undefined, the rule
# body fails and the default denies.
test_absent_model_card_completeness_does_not_allow if {
	not transparency.allow with input as json.patch(
		canonical_docs,
		[{"op": "remove", "path": "/metrics/model_card/completeness"}],
	)
}

# Declarations may carry who asserted them and until when. Read directly, an
# attestation is an object and `== true` is false, so a valid attestation turned
# a passing check into a failing one and, worse, stopped `non_compliant` firing
# at all: a real finding disappeared rather than a wrong approval appearing.
attested_docs := {
	"evaluated_at": "2026-08-29T00:00:00Z",
	"documentation": {
		"model_card": {"exists": {
			"value": true,
			"asserted_by": "j.smith@example.com",
			"expires": "2027-01-01T00:00:00Z",
		}},
		"explainability": {"provided": true},
		"limitations": {"documented": true},
		"use_cases": {"defined": true},
	},
	"metrics": {"model_card": {"completeness": 0.9}},
}

test_an_attested_declaration_is_read if {
	transparency.allow with input as attested_docs
}

# The whole point. An assertion made once does not hold forever, and a stale one
# must stop counting rather than keep passing.
test_an_expired_attestation_denies if {
	stale := json.patch(attested_docs, [{
		"op": "replace",
		"path": "/documentation/model_card/exists/expires",
		"value": "2026-01-01T00:00:00Z",
	}])
	not transparency.allow with input as stale
}

# The finding that used to vanish. A card that exists but falls short must still
# be reported when the existence claim is attested.
test_attestation_does_not_silence_a_finding if {
	incomplete := json.patch(attested_docs, [{
		"op": "replace", "path": "/metrics/model_card/completeness", "value": 0.4,
	}])
	transparency.non_compliant with input as incomplete
}

# Zero regression: a bare value behaves exactly as it did, which is what makes
# this migration additive rather than breaking.
test_bare_declarations_are_unaffected if {
	bare := {
		"documentation": {
			"model_card": {"exists": true},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"metrics": {"model_card": {"completeness": 0.9}},
	}
	transparency.allow with input as bare
}

# An unmeasured completeness is reported as null, not as 0. Those are different
# findings: 0 means the card is empty, null means nobody has looked, and they go
# to different people. The report must also still exist, because an undefined
# rule inside the object deletes the whole object.
test_report_says_null_for_unmeasured_completeness if {
	report := transparency.compliance_report with input as {"documentation": {
		"model_card": {"exists": true},
		"explainability": {"provided": true},
		"limitations": {"documented": true},
		"use_cases": {"defined": true},
	}}

	report.details.model_card_completeness == null
	report.overall_result == false
}

# The report must survive the submission with no evidence at all, and say what
# is missing. Two separate things used to delete it: an undefined value anywhere
# inside the object, and object.get on a parent that was not there. The
# recommendation has to name an input that is genuinely absent, because a fixed
# string naming one input is wrong whenever that input is the one supplied.
test_report_survives_empty_input_and_names_what_is_missing if {
	report := transparency.compliance_report with input as {}

	report.overall_result == false
	report.details.model_card_completeness == null
	some rec in report.recommendations
	contains(rec, "documentation.model_card.exists")
}
