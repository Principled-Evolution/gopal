# RequiredMetrics:
#   - model.general_purpose
#   - model.cumulative_training_compute_flops
#   - model.commission_designated_systemic_risk
#   - notification.commission_notified
#   - systemic_risk.model_evaluation_with_adversarial_testing
#   - systemic_risk.risks_assessed_and_mitigated
#   - systemic_risk.serious_incidents_reported_to_ai_office
#   - systemic_risk.cybersecurity_protection_adequate
#
# RequiredParams: none
package international.eu_ai_act.v1.gpai.systemic_risk_classification

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act GPAI Systemic Risk Classification and Obligations (Articles 51, 52 and 55)",
	"description": "Classifies a general-purpose AI model against the Article 51 systemic risk criteria and, where it qualifies, tests the Article 55 obligations that follow. Article 51(2) sets a rebuttable presumption of high impact capabilities at cumulative training compute above 10^25 floating point operations, and Article 52(1) requires notification of the Commission without delay and within two weeks of meeting it. A model can also be designated by Commission decision regardless of compute.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 51 of the EU AI Act, classification of general-purpose AI models with systemic risk",
		"Article 51(2), the 10^25 FLOP presumption",
		"Article 52(1), notification of the Commission within two weeks",
		"Article 55 of the EU AI Act, obligations of providers of GPAI models with systemic risk",
	],
}

# Article 51(2) presumption threshold.
flop_threshold := 1e25

default is_gpai := false

is_gpai if {
	declarations.resolve(input, ["model", "general_purpose"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["model", "general_purpose"]))
}

default exceeds_compute_threshold := false

exceeds_compute_threshold if {
	object.get(input, ["model", "cumulative_training_compute_flops"], 0) > flop_threshold
}

default commission_designated := false

commission_designated if {
	declarations.resolve(input, ["model", "commission_designated_systemic_risk"]) == true
}

default systemic_risk := false

systemic_risk if {
	is_gpai
	exceeds_compute_threshold
}

systemic_risk if {
	is_gpai
	commission_designated
}

# Article 52(1): notification is required once the threshold is met.
default commission_notified := false

commission_notified if {
	declarations.resolve(input, ["notification", "commission_notified"]) == true
}

# Article 55 obligations, engaged by the classification.
article_55_obligations := {
	"Article 55(1)(a) model evaluation including adversarial testing": "model_evaluation_with_adversarial_testing",
	"Article 55(1)(b) systemic risks assessed and mitigated": "risks_assessed_and_mitigated",
	"Article 55(1)(c) serious incidents reported to the AI Office": "serious_incidents_reported_to_ai_office",
	"Article 55(1)(d) adequate cybersecurity protection": "cybersecurity_protection_adequate",
}

unmet_article_55 contains label if {
	systemic_risk
	some label, field in article_55_obligations
	object.get(input, ["systemic_risk", field], false) != true
}

default article_55_met := false

article_55_met if {
	not systemic_risk
}

article_55_met if {
	systemic_risk
	count(unmet_article_55) == 0
}

default allow := false

allow if {
	scope_determined
	not is_gpai
}

allow if {
	scope_determined
	is_gpai
	not systemic_risk
}

allow if {
	scope_determined
	is_gpai
	systemic_risk
	commission_notified
	article_55_met
}

policy_metrics := {
	"systemic_risk_classification": {
		"name": "Classified as a GPAI Model With Systemic Risk",
		"value": systemic_risk,
		"control_passed": allow,
	},
	"cumulative_training_compute_flops": {
		"name": "Cumulative Training Compute (FLOPs)",
		"value": object.get(input, ["model", "cumulative_training_compute_flops"], 0),
		"control_passed": true,
	},
	"commission_notified": {
		"name": "Article 52(1) Commission Notified",
		"value": commission_notified,
		"control_passed": allow,
	},
	"article_55_obligations_unmet": {
		"name": "Article 55 Obligations Not Met",
		"value": sort([o | some o in unmet_article_55]),
		"control_passed": article_55_met,
	},
}

report := reporting.compose_report("eu_ai_act.gpai.systemic_risk_classification", allow, policy_metrics)
