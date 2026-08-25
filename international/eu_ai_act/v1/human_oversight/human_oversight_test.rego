package international.eu_ai_act.v1.human_oversight_test

import data.international.eu_ai_act.v1.human_oversight as policy
import rego.v1

compliant := {
	"system": {"high_risk": true},
	"oversight": {
		"measures_built_into_system": true,
		"capabilities_and_limitations_communicated": true,
		"automation_bias_addressed": true,
		"can_disregard_output": true,
		"can_intervene_or_halt": true,
		"assigned_persons_competent": true,
	},
}

test_allow_when_all_article_14_controls_met if {
	policy.allow with input as compliant
}

# Article 14 applies to high-risk systems.
test_allow_when_system_is_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_when_risk_class_not_asserted if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/system/high_risk"}])
}

# Nominating a person is not oversight if the system was not built to allow it.
test_deny_without_oversight_designed_into_the_system if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/measures_built_into_system", "value": false}])
}

test_deny_without_automation_bias_addressed if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/automation_bias_addressed", "value": false}])
}

test_deny_when_capabilities_not_communicated if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/capabilities_and_limitations_communicated", "value": false}])
}

# Article 14(4)(c) to (e): being able to disregard an output and being able to
# halt the system are distinct capabilities.
test_deny_without_ability_to_disregard_output if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/can_disregard_output", "value": false}])
}

test_deny_without_ability_to_halt if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/can_intervene_or_halt", "value": false}])
}

test_deny_when_assigned_persons_not_competent if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/oversight/assigned_persons_competent", "value": false}])
}

test_report_names_the_failed_controls if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/oversight/can_intervene_or_halt", "value": false},
		{"op": "replace", "path": "/oversight/assigned_persons_competent", "value": false},
	])
	report.metrics.human_oversight_controls_failed.value == [
		"Article 14(4)(c)-(e) ability to disregard, intervene or halt",
		"competence of the assigned persons",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
