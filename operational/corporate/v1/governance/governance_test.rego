package operational.corporate.v1.governance_test

import data.operational.corporate.v1.governance as policy
import rego.v1

compliant := {
	"governance": {
		"ai_policy_approved": true,
		"system_in_inventory": true,
		"accountable_owner_named": true,
		"review_cadence_days": 90,
		"staff_training_completed": true,
	},
	"third_party": {"vendor_in_use": false, "due_diligence_completed": false},
}

test_allow_when_all_controls_present if {
	policy.allow with input as compliant
}

test_deny_without_approved_policy if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/ai_policy_approved", "value": false}])
}

test_deny_when_system_not_inventoried if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/system_in_inventory", "value": false}])
}

test_deny_without_named_owner if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/accountable_owner_named", "value": false}])
}

# A cadence of zero, or one longer than a year, is not a review cadence.
test_deny_on_zero_cadence if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/review_cadence_days", "value": 0}])
}

test_deny_on_cadence_longer_than_annual if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/review_cadence_days", "value": 400}])
}

test_allow_at_annual_cadence_boundary if {
	policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/review_cadence_days", "value": 365}])
}

test_deny_without_staff_training if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/governance/staff_training_completed", "value": false}])
}

# Bringing in a vendor adds a control rather than removing one.
test_deny_vendor_without_due_diligence if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/third_party/vendor_in_use", "value": true}])
}

test_allow_vendor_with_due_diligence if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/third_party/vendor_in_use", "value": true},
		{"op": "replace", "path": "/third_party/due_diligence_completed", "value": true},
	])
}

test_report_names_the_failed_controls if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/governance/ai_policy_approved", "value": false},
		{"op": "replace", "path": "/governance/review_cadence_days", "value": 0},
	])
	report.metrics.governance_controls_failed.value == [
		"approved AI policy",
		"review cadence defined and no longer than annual",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
