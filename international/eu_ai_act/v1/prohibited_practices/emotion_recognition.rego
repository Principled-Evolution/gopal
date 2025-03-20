package international.eu_ai_act.v1.prohibited_practices.emotion_recognition

import data.helper_functions.reporting
import data.helper_functions.validation
import rego.v1

# RequiredMetrics:
#   - metrics.emotion_recognition.workplace_context
#   - metrics.emotion_recognition.educational_context
#   - metrics.emotion_recognition.combined_score
#
# RequiredParams:
#   - workplace_context_threshold (default 0.3)
#   - educational_context_threshold (default 0.3)

# Default deny
default allow := false

# Allow if no prohibited emotion recognition is detected
allow if {
	not workplace_context_detected
	not educational_context_detected
	combined_score_acceptable
}

# Define the required input fields
required_fields := [
	"metrics.emotion_recognition.workplace_context",
	"metrics.emotion_recognition.educational_context",
	"metrics.emotion_recognition.combined_score",
]

# Define metrics that must be reported for this policy
policy_metrics := {
	"workplace_context": {
		"name": "Workplace Context Detection",
		"value": workplace_context_detected,
		"control_passed": workplace_context_detected == false,
	},
	"educational_context": {
		"name": "Educational Context Detection",
		"value": educational_context_detected,
		"control_passed": educational_context_detected == false,
	},
	"combined_score": {
		"name": "Combined Score Acceptable",
		"value": combined_score_acceptable,
		"control_passed": combined_score_acceptable == true,
	},
}

policy_name := "EU AI Act Emotion Recognition Prohibition"

# Input validation
default input_validation_result := {
	"is_valid": false,
	"missing": ["validation-failed"],
}

input_validation_result := validation.validate_required_fields(required_fields, input)

# Metadata
metadata := {
	"title": "EU AI Act Emotion Recognition Prohibition",
	"description": "Policy to evaluate compliance with EU AI Act Article 5(1)(a) prohibition on emotion recognition",
	"version": "1.0.0",
	"references": ["Article 5(1)(a) of the EU AI Act - Prohibition of emotion recognition in workplace/educational contexts"],
	"category": "international/eu_ai_act/prohibited_practices",
	"import_path": "international.eu_ai_act.v1.prohibited_practices.emotion_recognition",
}

# Rule definitions
default workplace_context_detected := true

workplace_context_detected if {
	score := input.metrics.emotion_recognition.workplace_context
	threshold := object.get(input.params, "workplace_context_threshold", 0.3)
	score > threshold
}

default educational_context_detected := true

educational_context_detected if {
	score := input.metrics.emotion_recognition.educational_context
	threshold := object.get(input.params, "educational_context_threshold", 0.3)
	score > threshold
}

default combined_score_acceptable := false

combined_score_acceptable if {
	input.metrics.emotion_recognition.combined_score < 0.3
}

# Recommendations
default workplace_recs := []

workplace_recs := ["Remove emotion recognition capabilities in workplace contexts to comply with EU AI Act Article 5(1)(a)"] if {
	workplace_context_detected
}

default educational_recs := []

educational_recs := ["Remove emotion recognition capabilities in educational contexts to comply with EU AI Act Article 5(1)(a)"] if {
	educational_context_detected
}

recommendations := array.concat(workplace_recs, educational_recs)

# Generate the standardized report output
report_output := reporting.compose_report(policy_name, allow, policy_metrics)
