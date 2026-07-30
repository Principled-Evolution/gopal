package industry_specific.aviation.v1.autonomous_systems.human_oversight_test

import data.industry_specific.aviation.v1.autonomous_systems.human_oversight
import rego.v1

compliant_input := {"oversight": {
	"remote_pilot_monitoring": true,
	"intervention_capability": true,
	"handover_procedure_defined": true,
}}

test_allow_when_fully_compliant if {
	human_oversight.allow with input as compliant_input
}

test_deny_without_monitoring if {
	input_data := object.union(compliant_input, {"oversight": {"remote_pilot_monitoring": false, "intervention_capability": true, "handover_procedure_defined": true}})
	not human_oversight.allow with input as input_data
}

test_deny_without_intervention_capability if {
	input_data := object.union(compliant_input, {"oversight": {"remote_pilot_monitoring": true, "intervention_capability": false, "handover_procedure_defined": true}})
	not human_oversight.allow with input as input_data
}

test_deny_without_handover_procedure if {
	input_data := object.union(compliant_input, {"oversight": {"remote_pilot_monitoring": true, "intervention_capability": true, "handover_procedure_defined": false}})
	not human_oversight.allow with input as input_data
}
