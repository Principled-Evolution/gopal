package industry_specific.aviation.v1.flight_operations.emergency_procedures_test

import data.industry_specific.aviation.v1.flight_operations.emergency_procedures
import rego.v1

compliant_input := {"emergency_procedures": {
	"lost_link_procedure_defined": true,
	"contingency_landing_sites_identified": true,
	"crew_trained": true,
}}

test_allow_when_fully_compliant if {
	emergency_procedures.allow with input as compliant_input
}

test_deny_without_lost_link_procedure if {
	input_data := object.union(compliant_input, {"emergency_procedures": {"lost_link_procedure_defined": false, "contingency_landing_sites_identified": true, "crew_trained": true}})
	not emergency_procedures.allow with input as input_data
}

test_deny_without_contingency_sites if {
	input_data := object.union(compliant_input, {"emergency_procedures": {"lost_link_procedure_defined": true, "contingency_landing_sites_identified": false, "crew_trained": true}})
	not emergency_procedures.allow with input as input_data
}

test_deny_without_crew_training if {
	input_data := object.union(compliant_input, {"emergency_procedures": {"lost_link_procedure_defined": true, "contingency_landing_sites_identified": true, "crew_trained": false}})
	not emergency_procedures.allow with input as input_data
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not emergency_procedures.allow with input as {}
}
