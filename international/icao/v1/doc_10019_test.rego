package international.icao.v1.doc_10019_test

import data.international.icao.v1.doc_10019
import rego.v1

test_allow_when_all_requirements_met if {
	doc_10019.allow with input as {"system": {
		"c2_link": {"lost_link_procedure_defined": true},
		"detect_and_avoid": {"equipped": true},
		"remote_pilot": {"qualified": true},
	}}
}

test_deny_when_no_lost_link_procedure if {
	not doc_10019.allow with input as {"system": {
		"c2_link": {"lost_link_procedure_defined": false},
		"detect_and_avoid": {"equipped": true},
		"remote_pilot": {"qualified": true},
	}}
}

test_deny_when_not_equipped_for_detect_and_avoid if {
	not doc_10019.allow with input as {"system": {
		"c2_link": {"lost_link_procedure_defined": true},
		"detect_and_avoid": {"equipped": false},
		"remote_pilot": {"qualified": true},
	}}
}

test_deny_when_remote_pilot_not_qualified if {
	not doc_10019.allow with input as {"system": {
		"c2_link": {"lost_link_procedure_defined": true},
		"detect_and_avoid": {"equipped": true},
		"remote_pilot": {"qualified": false},
	}}
}

test_report_reflects_compliant_state if {
	report := doc_10019.report with input as {"system": {
		"c2_link": {"lost_link_procedure_defined": true},
		"detect_and_avoid": {"equipped": true},
		"remote_pilot": {"qualified": true},
	}}
	report.result == true
	report.metrics.remote_pilot_qualified.control_passed == true
}
