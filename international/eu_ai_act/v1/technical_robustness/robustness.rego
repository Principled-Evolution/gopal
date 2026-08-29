# RequiredMetrics:
#   - system.high_risk
#   - accuracy.metrics_declared
#   - accuracy.declared_in_instructions
#   - robustness.resilience_tested
#   - robustness.fallback_or_fail_safe_documented
#   - robustness.feedback_loop_risk_addressed
#   - cybersecurity.controls_in_place
#   - cybersecurity.adversarial_attacks_addressed
#
# RequiredParams: none
package international.eu_ai_act.v1.technical_robustness

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Accuracy, Robustness and Cybersecurity (Article 15)",
	"description": "Evaluates a high-risk AI system against Article 15. Three requirements sit inside it that are easy to lose: accuracy metrics must be declared in the instructions for use rather than merely measured, systems that continue to learn after deployment must address feedback loops, and cybersecurity must cover AI-specific attacks such as data poisoning, model poisoning and adversarial examples rather than only conventional controls.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 15 of the EU AI Act, accuracy, robustness and cybersecurity",
		"Article 15(2), declaration of accuracy metrics in the instructions for use",
		"Article 15(4), feedback loops in systems that continue to learn",
		"Article 15(5), AI-specific cybersecurity attacks",
	],
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

# Article 15(2): the metrics have to reach the deployer, not just exist.
default accuracy_declared := false

accuracy_declared if {
	declarations.resolve(input, ["accuracy", "metrics_declared"]) == true
	declarations.resolve(input, ["accuracy", "declared_in_instructions"]) == true
}

default resilient := false

resilient if {
	declarations.resolve(input, ["robustness", "resilience_tested"]) == true
	declarations.resolve(input, ["robustness", "fallback_or_fail_safe_documented"]) == true
}

# Article 15(4): only engages where the system continues to learn in use.
default continues_to_learn := false

continues_to_learn if {
	declarations.resolve(input, ["system", "continues_to_learn_after_deployment"]) == true
}

default feedback_loops_addressed := false

feedback_loops_addressed if {
	not continues_to_learn
}

feedback_loops_addressed if {
	continues_to_learn
	declarations.resolve(input, ["robustness", "feedback_loop_risk_addressed"]) == true
}

# Article 15(5): conventional controls plus the AI-specific attack surface.
default secured := false

secured if {
	declarations.resolve(input, ["cybersecurity", "controls_in_place"]) == true
	declarations.resolve(input, ["cybersecurity", "adversarial_attacks_addressed"]) == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	accuracy_declared
	resilient
	feedback_loops_addressed
	secured
}

failed_controls := [name |
	some name, satisfied in {
		"Article 15(2) accuracy metrics declared in the instructions for use": accuracy_declared,
		"Article 15(1) robustness tested with a documented fallback": resilient,
		"Article 15(4) feedback loops addressed where the system keeps learning": feedback_loops_addressed,
		"Article 15(5) cybersecurity including AI-specific attacks": secured,
	}
	satisfied == false
]

policy_metrics := {
	"article_15_controls_failed": {
		"name": "Article 15 Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"accuracy_reaches_the_deployer": {
		"name": "Accuracy Metrics Declared in the Instructions for Use",
		"value": object.get(input, ["accuracy", "declared_in_instructions"], false),
		"control_passed": accuracy_declared,
	},
	"adversarial_attacks_addressed": {
		"name": "Data Poisoning, Model Poisoning and Adversarial Examples Addressed",
		"value": object.get(input, ["cybersecurity", "adversarial_attacks_addressed"], false),
		"control_passed": secured,
	},
	"continues_to_learn": {
		"name": "System Continues to Learn After Deployment",
		"value": continues_to_learn,
		"control_passed": feedback_loops_addressed,
	},
}

report := reporting.compose_report("eu_ai_act.technical_robustness", allow, policy_metrics)
