# RequiredMetrics:
#   - model.general_purpose
#   - model.free_and_open_source
#   - model.parameters_publicly_available
#   - model.systemic_risk
#   - documentation.annex_xi_complete
#   - documentation.training_process_documented
#   - documentation.testing_process_documented
#   - documentation.evaluation_results_documented
#
# RequiredParams: none
package international.eu_ai_act.v1.gpai.technical_documentation

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act GPAI Technical Documentation (Article 53(1)(a))",
	"description": "Evaluates the technical documentation a provider of a general-purpose AI model must draw up and keep up to date, including the training and testing process and the results of its evaluation, per Annex XI. Article 53(2) exempts models released under a free and open-source licence with publicly available parameters, but that exemption falls away entirely for a model with systemic risk, which is the interaction most likely to be misread.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 53(1)(a) of the EU AI Act, technical documentation for GPAI models",
		"Article 53(2) of the EU AI Act, free and open-source exemption",
		"Annex XI, technical documentation for general-purpose AI models",
	],
}

default is_gpai := false

is_gpai if {
	declarations.resolve(input, ["model", "general_purpose"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["model", "general_purpose"]))
}

default systemic_risk := false

systemic_risk if {
	declarations.resolve(input, ["model", "systemic_risk"]) == true
}

# Article 53(2): free and open-source with publicly available parameters, but
# never for a systemic risk model.
default exemption_applies := false

exemption_applies if {
	declarations.resolve(input, ["model", "free_and_open_source"]) == true
	declarations.resolve(input, ["model", "parameters_publicly_available"]) == true
	not systemic_risk
}

requirements := {
	"Annex XI documentation complete": "annex_xi_complete",
	"training process documented": "training_process_documented",
	"testing process documented": "testing_process_documented",
	"evaluation results documented": "evaluation_results_documented",
}

unmet contains label if {
	some label, field in requirements
	object.get(input, ["documentation", field], false) != true
}

default documentation_complete := false

documentation_complete if {
	count(unmet) == 0
}

default allow := false

allow if {
	scope_determined
	not is_gpai
}

allow if {
	scope_determined
	is_gpai
	exemption_applies
}

allow if {
	scope_determined
	is_gpai
	not exemption_applies
	documentation_complete
}

policy_metrics := {
	"documentation_requirements_unmet": {
		"name": "Article 53(1)(a) Documentation Requirements Not Met",
		"value": sort([r | some r in unmet]),
		"control_passed": documentation_complete,
	},
	"open_source_exemption_applies": {
		"name": "Article 53(2) Free and Open-Source Exemption Applies",
		"value": exemption_applies,
		"control_passed": allow,
	},
	"systemic_risk_removes_exemption": {
		"name": "Systemic Risk Model (Exemption Unavailable)",
		"value": systemic_risk,
		"control_passed": allow,
	},
}

report := reporting.compose_report("eu_ai_act.gpai.technical_documentation", allow, policy_metrics)
