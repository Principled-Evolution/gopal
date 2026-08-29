# RequiredMetrics:
#   - system.predicts_criminal_offence_risk
#   - system.based_solely_on_profiling
#   - system.supports_human_assessment
#   - system.grounded_in_objective_verifiable_facts
#
# RequiredParams: none
package international.eu_ai_act.v1.prohibited_practices.criminal_profiling

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Prohibition of Predictive Criminal Profiling",
	"description": "Evaluates an AI system against the Article 5(1)(d) prohibition on assessing or predicting the risk of a natural person committing a criminal offence based solely on profiling or on assessing personality traits and characteristics. The Article carves out systems that support a human assessment already grounded in objective and verifiable facts directly linked to criminal activity, so this policy treats that carve-out as an explicit condition rather than assuming it.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 5(1)(d) of the EU AI Act, predictive policing based on profiling",
		"Recital 42 of the EU AI Act",
	],
}

default predicts_offence_risk := false

predicts_offence_risk if {
	declarations.resolve(input, ["system", "predicts_criminal_offence_risk"]) == true
}

default based_solely_on_profiling := false

based_solely_on_profiling if {
	declarations.resolve(input, ["system", "based_solely_on_profiling"]) == true
}

# The Article 5(1)(d) carve-out: supporting a human assessment that is itself
# grounded in objective, verifiable facts directly linked to criminal activity.
default carve_out_applies := false

carve_out_applies if {
	declarations.resolve(input, ["system", "supports_human_assessment"]) == true
	declarations.resolve(input, ["system", "grounded_in_objective_verifiable_facts"]) == true
}

default prohibited := false

prohibited if {
	predicts_offence_risk
	based_solely_on_profiling
	not carve_out_applies
}

default not_prohibited := false

not_prohibited if {
	not prohibited
}

default assessment_complete := false

assessment_complete if {
	is_boolean(declarations.resolve(input, ["system", "predicts_criminal_offence_risk"]))
	is_boolean(declarations.resolve(input, ["system", "based_solely_on_profiling"]))
}

default allow := false

allow if {
	assessment_complete
	not prohibited
}

policy_metrics := {
	"predicts_offence_risk": {
		"name": "Assesses or Predicts Risk of Committing a Criminal Offence",
		"value": predicts_offence_risk,
		"control_passed": not_prohibited,
	},
	"based_solely_on_profiling": {
		"name": "Based Solely on Profiling or Personality Traits",
		"value": based_solely_on_profiling,
		"control_passed": not_prohibited,
	},
	"human_assessment_carve_out": {
		"name": "Supports a Human Assessment Grounded in Objective Verifiable Facts",
		"value": carve_out_applies,
		"control_passed": not_prohibited,
	},
	"assessment_complete": {
		"name": "Article 5(1)(d) Assessment Recorded",
		"value": assessment_complete,
		"control_passed": assessment_complete,
	},
}

report := reporting.compose_report("eu_ai_act.prohibited_practices.criminal_profiling", allow, policy_metrics)
