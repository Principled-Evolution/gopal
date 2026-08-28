package industry_specific.healthcare.v1.patient_safety_test

import data.industry_specific.healthcare.v1.patient_safety as policy
import rego.v1

compliant := {
	"evaluation": {
		"patient_safety": {"score": 0.97},
		"clinical_validation": {"score": 0.93},
		"risk_assessment": {"score": 0.92},
	},
	"oversight": {"clinician_in_the_loop": true, "adverse_event_reporting_in_place": true},
}

test_allow_when_all_controls_met if {
	policy.allow with input as compliant
}

# The patient-safety threshold is 0.95, higher than the diagnostic_safety
# sibling, because these controls sit closest to patient harm.
test_deny_patient_safety_below_default_threshold if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/evaluation/patient_safety/score", "value": 0.94,
	}])
}

test_allow_at_threshold_boundary if {
	policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/evaluation/patient_safety/score", "value": 0.95,
	}])
}

test_thresholds_can_be_overridden_by_params if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/evaluation/patient_safety/score", "value": 0.90},
		{"op": "add", "path": "/params", "value": {"patient_safety_threshold": 0.85}},
	])
}

test_deny_clinical_validation_below_threshold if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/evaluation/clinical_validation/score", "value": 0.5,
	}])
}

test_deny_risk_assessment_below_threshold if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/evaluation/risk_assessment/score", "value": 0.1,
	}])
}

# Good Machine Learning Practice expects a clinician in the loop and a route for
# reporting adverse events. Strong scores do not substitute for either.
test_deny_without_clinician_in_the_loop if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/oversight/clinician_in_the_loop", "value": false,
	}])
}

test_deny_without_adverse_event_reporting if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/oversight/adverse_event_reporting_in_place", "value": false,
	}])
}

# An absent score must fail its threshold rather than dropping out of the
# assessment, which is the failure mode the diagnostic_safety sibling had.
test_deny_when_a_score_is_absent if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/evaluation/patient_safety",
	}])
}

test_report_names_the_failed_controls if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "remove", "path": "/evaluation/risk_assessment"},
		{"op": "replace", "path": "/oversight/clinician_in_the_loop", "value": false},
	])
	report.metrics.patient_safety_controls_failed.value == [
		"clinician oversight and adverse event reporting",
		"risk assessment score",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}

# The canonical metrics.<name>.score spelling, which is what an evaluator
# publishing through helper_functions/metrics.rego supplies. The legacy
# evaluation.<name>.score tests above must keep passing alongside these: the
# point of the migration was to add a spelling, not to swap one for another.
canonical := {
	"metrics": {
		"patient_safety": {"score": 0.97},
		"clinical_validation": {"score": 0.93},
		"risk_assessment": {"score": 0.92},
	},
	"oversight": {"clinician_in_the_loop": true, "adverse_event_reporting_in_place": true},
}

test_allow_when_scores_arrive_under_the_canonical_names if {
	policy.allow with input as canonical
}

test_canonical_score_below_threshold_still_denies if {
	not policy.patient_safety_met with input as json.patch(
		canonical,
		[{"op": "replace", "path": "/metrics/patient_safety/score", "value": 0.94}],
	)
}

# A supplied canonical score wins over a legacy one. The table lists the
# canonical path first, so this is the resolution order, not a coincidence.
test_canonical_wins_over_legacy if {
	both := object.union(canonical, {"evaluation": {"patient_safety": {"score": 0.10}}})
	policy.patient_safety_met with input as both
}

# An absent score must fail its threshold rather than drop out of the
# assessment. This is the -1 sentinel doing its job through resolve_or.
test_absent_canonical_score_denies if {
	not policy.patient_safety_met with input as {
		"metrics": {"clinical_validation": {"score": 0.93}},
		"oversight": {"clinician_in_the_loop": true, "adverse_event_reporting_in_place": true},
	}
}
