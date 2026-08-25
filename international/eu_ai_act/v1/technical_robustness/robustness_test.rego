package international.eu_ai_act.v1.technical_robustness_test

import data.international.eu_ai_act.v1.technical_robustness as policy
import rego.v1

compliant := {
	"system": {"high_risk": true, "continues_to_learn_after_deployment": false},
	"accuracy": {"metrics_declared": true, "declared_in_instructions": true},
	"robustness": {"resilience_tested": true, "fallback_or_fail_safe_documented": true, "feedback_loop_risk_addressed": false},
	"cybersecurity": {"controls_in_place": true, "adversarial_attacks_addressed": true},
}

test_allow_when_all_article_15_controls_met if {
	policy.allow with input as compliant
}

test_allow_when_system_is_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

# Article 15(2): measuring accuracy is not the same as declaring it to the
# deployer in the instructions for use.
test_deny_when_accuracy_measured_but_not_declared if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/accuracy/declared_in_instructions", "value": false}])
}

test_deny_without_accuracy_metrics if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/accuracy/metrics_declared", "value": false}])
}

test_deny_without_documented_fallback if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/robustness/fallback_or_fail_safe_documented", "value": false}])
}

# Article 15(4) engages only where the system keeps learning in use, and then
# it engages absolutely.
test_deny_continuous_learning_without_feedback_loop_controls if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/system/continues_to_learn_after_deployment", "value": true}])
}

test_allow_continuous_learning_with_feedback_loop_controls if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/system/continues_to_learn_after_deployment", "value": true},
		{"op": "replace", "path": "/robustness/feedback_loop_risk_addressed", "value": true},
	])
}

# Article 15(5): conventional controls alone do not cover the AI-specific
# attack surface.
test_deny_conventional_security_without_adversarial_controls if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/cybersecurity/adversarial_attacks_addressed", "value": false}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
