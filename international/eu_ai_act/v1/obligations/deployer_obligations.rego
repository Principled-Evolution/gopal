# RequiredMetrics:
#   - system.high_risk
#   - deployer.uses_per_instructions
#   - deployer.human_oversight_assigned
#   - deployer.oversight_persons_trained_and_authorised
#   - deployer.input_data_relevant
#   - deployer.controls_input_data
#   - deployer.monitors_operation
#   - deployer.reports_serious_incidents
#   - deployer.logs_kept_six_months
#   - deployer.workplace_deployment
#   - deployer.workers_informed
#   - deployer.affects_natural_persons
#   - deployer.affected_persons_informed
#
# RequiredParams: none
package international.eu_ai_act.v1.obligations.deployer_obligations

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Deployer Obligations (Article 26)",
	"description": "Evaluates a deployer of a high-risk AI system against Article 26. Two obligations are conditional rather than universal and are treated as such here: workers and their representatives must be informed before a system is put into service in the workplace, and natural persons subject to a high-risk decision must be told. The input data obligation applies only to the extent the deployer exercises control over that data.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 26 of the EU AI Act, obligations of deployers of high-risk AI systems",
		"Article 26(7), informing workers' representatives",
		"Article 26(11), informing natural persons subject to a decision",
	],
}

default in_scope := false

in_scope if {
	input.system.high_risk == true
}

default scope_determined := false

scope_determined if {
	is_boolean(input.system.high_risk)
}

# Article 26(1) to (6): the universal obligations.
default uses_per_instructions := false

uses_per_instructions if {
	input.deployer.uses_per_instructions == true
}

default oversight_assigned := false

oversight_assigned if {
	input.deployer.human_oversight_assigned == true
	input.deployer.oversight_persons_trained_and_authorised == true
}

# Article 26(4): only to the extent the deployer controls the input data.
default input_data_adequate := false

input_data_adequate if {
	input.deployer.controls_input_data == false
}

input_data_adequate if {
	input.deployer.controls_input_data == true
	input.deployer.input_data_relevant == true
}

default monitoring_in_place := false

monitoring_in_place if {
	input.deployer.monitors_operation == true
	input.deployer.reports_serious_incidents == true
}

default logs_kept := false

logs_kept if {
	input.deployer.logs_kept_six_months == true
}

# Article 26(7): conditional on workplace deployment.
default workers_informed := false

workers_informed if {
	input.deployer.workplace_deployment == false
}

workers_informed if {
	input.deployer.workplace_deployment == true
	input.deployer.workers_informed == true
}

# Article 26(11): conditional on the system affecting natural persons.
default affected_persons_informed := false

affected_persons_informed if {
	input.deployer.affects_natural_persons == false
}

affected_persons_informed if {
	input.deployer.affects_natural_persons == true
	input.deployer.affected_persons_informed == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	uses_per_instructions
	oversight_assigned
	input_data_adequate
	monitoring_in_place
	logs_kept
	workers_informed
	affected_persons_informed
}

failed_obligations := [name |
	some name, satisfied in {
		"Article 26(1) use in accordance with the instructions for use": uses_per_instructions,
		"Article 26(2) human oversight assigned to trained and authorised persons": oversight_assigned,
		"Article 26(4) input data relevant where the deployer controls it": input_data_adequate,
		"Article 26(5) monitoring and serious incident reporting": monitoring_in_place,
		"Article 26(6) logs kept for at least six months": logs_kept,
		"Article 26(7) workers and representatives informed": workers_informed,
		"Article 26(11) affected natural persons informed": affected_persons_informed,
	}
	satisfied == false
]

policy_metrics := {
	"article_26_obligations_failed": {
		"name": "Article 26 Obligations Not Met",
		"value": sort(failed_obligations),
		"control_passed": count(failed_obligations) == 0,
	},
	"workplace_deployment": {
		"name": "Deployed in the Workplace (Engages Article 26(7))",
		"value": object.get(input, ["deployer", "workplace_deployment"], false),
		"control_passed": workers_informed,
	},
	"affects_natural_persons": {
		"name": "Decisions Affect Natural Persons (Engages Article 26(11))",
		"value": object.get(input, ["deployer", "affects_natural_persons"], false),
		"control_passed": affected_persons_informed,
	},
}

report := reporting.compose_report("eu_ai_act.obligations.deployer_obligations", allow, policy_metrics)
