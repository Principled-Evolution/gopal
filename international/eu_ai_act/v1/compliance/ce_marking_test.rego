package international.eu_ai_act.v1.compliance.ce_marking_test

import data.international.eu_ai_act.v1.compliance.ce_marking as policy
import rego.v1

physical := {
	"system": {"high_risk": true, "digital_only": false},
	"ce_marking": {
		"affixed": true,
		"visible_legible_indelible": true,
		"digital_marking_accessible": false,
		"notified_body_involved": false,
		"notified_body_number_displayed": false,
	},
}

test_allow_physical_marking if {
	policy.allow with input as physical
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

test_deny_when_marking_not_affixed if {
	not policy.allow with input as json.patch(physical, [{"op": "replace", "path": "/ce_marking/affixed", "value": false}])
}

test_deny_physical_marking_not_visible_legible_indelible if {
	not policy.allow with input as json.patch(physical, [{"op": "replace", "path": "/ce_marking/visible_legible_indelible", "value": false}])
}

# Article 48(2): a digitally provided system needs a digitally accessible
# marking, and physical legibility is not the applicable test.
test_deny_digital_system_without_accessible_digital_marking if {
	not policy.allow with input as json.patch(physical, [{"op": "replace", "path": "/system/digital_only", "value": true}])
}

test_allow_digital_system_with_accessible_digital_marking if {
	policy.allow with input as json.patch(physical, [
		{"op": "replace", "path": "/system/digital_only", "value": true},
		{"op": "replace", "path": "/ce_marking/digital_marking_accessible", "value": true},
	])
}

# Article 48(4): where a notified body was involved, its number must appear.
test_deny_notified_body_without_its_number if {
	not policy.allow with input as json.patch(physical, [{"op": "replace", "path": "/ce_marking/notified_body_involved", "value": true}])
}

test_allow_notified_body_with_its_number if {
	policy.allow with input as json.patch(physical, [
		{"op": "replace", "path": "/ce_marking/notified_body_involved", "value": true},
		{"op": "replace", "path": "/ce_marking/notified_body_number_displayed", "value": true},
	])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
