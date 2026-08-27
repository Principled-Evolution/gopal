package international.eu_ai_act.v1.prohibited_practices.emotion_recognition_test

import data.international.eu_ai_act.v1.prohibited_practices.emotion_recognition as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}

# Regression: allow was unreachable for every input.
#
# `workplace_context_detected` and `educational_context_detected` each had a
# `default true` and a single rule that could only set them *true*, when the
# measured score exceeded the threshold. Nothing set either to false, so the
# default stood for every input where the score was acceptable, both detectors
# read as detected, and `allow` — which requires `not` both — could never be
# satisfied. A system measured at 0.0 on both contexts was reported as carrying
# a prohibited emotion-recognition practice.
clean := {"metrics": {"emotion_recognition": {
	"workplace_context": 0.0,
	"educational_context": 0.0,
	"combined_score": 0.0,
}}}

test_allow_when_no_context_is_detected if {
	policy.allow with input as clean
}

test_neither_detector_fires_on_clean_measurements if {
	policy.workplace_context_detected == false with input as clean
	policy.educational_context_detected == false with input as clean
}

# The raising direction still works: above the threshold is detected.
test_deny_when_workplace_context_detected if {
	not policy.allow with input as {"metrics": {"emotion_recognition": {
		"workplace_context": 0.9,
		"educational_context": 0.0,
		"combined_score": 0.5,
	}}}
}

test_deny_when_educational_context_detected if {
	not policy.allow with input as {"metrics": {"emotion_recognition": {
		"workplace_context": 0.0,
		"educational_context": 0.9,
		"combined_score": 0.5,
	}}}
}

# An unmeasured system is still treated as detected, which is the point of the
# `default true`. Absence of evidence must not read as absence of the practice.
test_detectors_default_to_detected_when_unmeasured if {
	policy.workplace_context_detected with input as {}
	policy.educational_context_detected with input as {}
	not policy.allow with input as {}
}

# The threshold is read with a nested object.get, so a missing params object
# does not make the comparison itself undefined.
test_clean_measurements_pass_without_a_params_object if {
	policy.allow with input as clean
}

test_custom_threshold_is_honoured if {
	not policy.allow with input as object.union(clean, {
		"metrics": {"emotion_recognition": {"workplace_context": 0.2}},
		"params": {"workplace_context_threshold": 0.1},
	})
}
