package international.standards.v1.iso_21384_test

import data.international.standards.v1.iso_21384
import rego.v1

test_allow_when_fully_compliant if {
	iso_21384.allow with input as {
		"safety_management": {"system_established": true, "risk_assessment_completed": true},
		"operations": {"procedures_documented": true},
	}
}

test_deny_without_safety_management_system if {
	not iso_21384.allow with input as {
		"safety_management": {"system_established": false, "risk_assessment_completed": true},
		"operations": {"procedures_documented": true},
	}
}

test_deny_without_risk_assessment if {
	not iso_21384.allow with input as {
		"safety_management": {"system_established": true, "risk_assessment_completed": false},
		"operations": {"procedures_documented": true},
	}
}

test_deny_without_documented_procedures if {
	not iso_21384.allow with input as {
		"safety_management": {"system_established": true, "risk_assessment_completed": true},
		"operations": {"procedures_documented": false},
	}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not iso_21384.allow with input as {}
}
