package industry_specific.aviation.v1.airworthiness.maintenance_test

import data.industry_specific.aviation.v1.airworthiness.maintenance
import rego.v1

compliant_input := {"maintenance": {"program_established": true, "inspection_current": true, "records_retained": true}}

test_allow_when_fully_compliant if {
	maintenance.allow with input as compliant_input
}

test_deny_without_program if {
	input_data := object.union(compliant_input, {"maintenance": {"program_established": false, "inspection_current": true, "records_retained": true}})
	not maintenance.allow with input as input_data
}

test_deny_without_current_inspection if {
	input_data := object.union(compliant_input, {"maintenance": {"program_established": true, "inspection_current": false, "records_retained": true}})
	not maintenance.allow with input as input_data
}

test_deny_without_retained_records if {
	input_data := object.union(compliant_input, {"maintenance": {"program_established": true, "inspection_current": true, "records_retained": false}})
	not maintenance.allow with input as input_data
}
