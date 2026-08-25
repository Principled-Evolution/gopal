# RequiredMetrics:
#   - system.high_risk
#   - oversight.measures_built_into_system
#   - oversight.capabilities_and_limitations_communicated
#   - oversight.automation_bias_addressed
#   - oversight.can_disregard_output
#   - oversight.can_intervene_or_halt
#   - oversight.assigned_persons_competent
#
# RequiredParams: none
package international.eu_ai_act.v1.human_oversight

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Human Oversight (Article 14)",
	"description": "Evaluates a high-risk AI system against the Article 14 human oversight requirements. Article 14 is not satisfied by nominating a person: the system must be designed so oversight is possible, the people assigned must be able to understand its capacities and limitations, remain aware of automation bias, be able to disregard or override an output, and be able to intervene or halt operation. This policy treats each of those as a separate control.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 14 of the EU AI Act, human oversight",
		"Article 14(4)(a) to (e), the specific oversight capabilities",
		"Recital 73 of the EU AI Act",
	],
}

# Article 14 applies to high-risk systems.
default in_scope := false

in_scope if {
	input.system.high_risk == true
}

default scope_determined := false

scope_determined if {
	is_boolean(input.system.high_risk)
}

# Article 14(1) and 14(2): oversight has to be designed into the system.
default designed_for_oversight := false

designed_for_oversight if {
	input.oversight.measures_built_into_system == true
}

# Article 14(4)(a) and (b): understanding capacities and limitations, and
# staying alert to automation bias.
default oversight_informed := false

oversight_informed if {
	input.oversight.capabilities_and_limitations_communicated == true
	input.oversight.automation_bias_addressed == true
}

# Article 14(4)(c) to (e): the ability to disregard an output, and to intervene
# or halt the system.
default oversight_effective := false

oversight_effective if {
	input.oversight.can_disregard_output == true
	input.oversight.can_intervene_or_halt == true
}

default assigned_persons_competent := false

assigned_persons_competent if {
	input.oversight.assigned_persons_competent == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	designed_for_oversight
	oversight_informed
	oversight_effective
	assigned_persons_competent
}

failed_controls := [name |
	some name, satisfied in {
		"Article 14(1)-(2) oversight designed into the system": designed_for_oversight,
		"Article 14(4)(a)-(b) capacities, limitations and automation bias": oversight_informed,
		"Article 14(4)(c)-(e) ability to disregard, intervene or halt": oversight_effective,
		"competence of the assigned persons": assigned_persons_competent,
	}
	satisfied == false
]

policy_metrics := {
	"human_oversight_controls_failed": {
		"name": "Article 14 Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"can_halt_the_system": {
		"name": "Assigned Person Can Intervene or Halt Operation",
		"value": object.get(input, ["oversight", "can_intervene_or_halt"], false),
		"control_passed": oversight_effective,
	},
	"automation_bias_addressed": {
		"name": "Automation Bias Explicitly Addressed",
		"value": object.get(input, ["oversight", "automation_bias_addressed"], false),
		"control_passed": oversight_informed,
	},
}

report := reporting.compose_report("eu_ai_act.human_oversight", allow, policy_metrics)
