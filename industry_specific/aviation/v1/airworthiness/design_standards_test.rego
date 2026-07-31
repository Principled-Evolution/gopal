package industry_specific.aviation.v1.airworthiness.design_standards_test

import data.industry_specific.aviation.v1.airworthiness.design_standards
import rego.v1

test_allow_when_dal_matches_catastrophic_severity if {
	design_standards.allow with input as {
		"system": {"failure_condition_severity": "catastrophic"},
		"software": {"design_assurance_level": "A"},
	}
}

test_allow_when_dal_exceeds_requirement if {
	design_standards.allow with input as {
		"system": {"failure_condition_severity": "minor"},
		"software": {"design_assurance_level": "A"},
	}
}

test_deny_when_dal_below_requirement if {
	not design_standards.allow with input as {
		"system": {"failure_condition_severity": "catastrophic"},
		"software": {"design_assurance_level": "C"},
	}
}

test_allow_for_no_effect_severity_with_level_e if {
	design_standards.allow with input as {
		"system": {"failure_condition_severity": "no_effect"},
		"software": {"design_assurance_level": "E"},
	}
}
