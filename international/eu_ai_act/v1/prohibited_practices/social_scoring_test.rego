package international.eu_ai_act.v1.prohibited_practices.social_scoring_test

import data.international.eu_ai_act.v1.prohibited_practices.social_scoring as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}

# Regression: allow was unreachable for every input.
#
# Same defect as emotion_recognition. `social_scoring_detected` and
# `detrimental_treatment_detected` each had a `default true` and only a raising
# rule, so nothing could clear them and `allow` could never be satisfied. A
# system measured at 0.0 on both was reported as operating a prohibited social
# scoring practice.
clean := {"metrics": {"social_scoring": {
	"score": 0.0,
	"detrimental_treatment": 0.0,
	"combined_score": 0.0,
}}}

test_allow_when_no_social_scoring_is_detected if {
	policy.allow with input as clean
}

test_neither_detector_fires_on_clean_measurements if {
	policy.social_scoring_detected == false with input as clean
	policy.detrimental_treatment_detected == false with input as clean
}

test_deny_when_social_scoring_detected if {
	not policy.allow with input as {"metrics": {"social_scoring": {
		"score": 0.8,
		"detrimental_treatment": 0.0,
		"combined_score": 0.1,
	}}}
}

test_deny_when_detrimental_treatment_detected if {
	not policy.allow with input as {"metrics": {"social_scoring": {
		"score": 0.0,
		"detrimental_treatment": 0.8,
		"combined_score": 0.1,
	}}}
}

test_detectors_default_to_detected_when_unmeasured if {
	policy.social_scoring_detected with input as {}
	policy.detrimental_treatment_detected with input as {}
	not policy.allow with input as {}
}

test_clean_measurements_pass_without_a_params_object if {
	policy.allow with input as clean
}
