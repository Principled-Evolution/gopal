package industry_specific.aviation.v1.autonomous_systems.decision_making_test

import data.industry_specific.aviation.v1.autonomous_systems.decision_making
import rego.v1

compliant_input := {"decision_system": {
	"decision_logging_enabled": true,
	"explainable": true,
	"override_capability": true,
}}

test_allow_when_fully_compliant if {
	decision_making.allow with input as compliant_input
}

test_deny_without_logging if {
	input_data := object.union(compliant_input, {"decision_system": {"decision_logging_enabled": false, "explainable": true, "override_capability": true}})
	not decision_making.allow with input as input_data
}

test_deny_without_explainability if {
	input_data := object.union(compliant_input, {"decision_system": {"decision_logging_enabled": true, "explainable": false, "override_capability": true}})
	not decision_making.allow with input as input_data
}

test_deny_without_override_capability if {
	input_data := object.union(compliant_input, {"decision_system": {"decision_logging_enabled": true, "explainable": true, "override_capability": false}})
	not decision_making.allow with input as input_data
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not decision_making.allow with input as {}
}
