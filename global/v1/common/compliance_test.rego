package global.v1.common.compliance_test

import data.global.v1.common.compliance

# Test meets_compliance_requirements function
test_meets_compliance_requirements_true if {
	compliance.meets_compliance_requirements(
		{"compliance": {"score": 0.85}},
		0.8,
	)
}

test_meets_compliance_requirements_false if {
	not compliance.meets_compliance_requirements(
		{"compliance": {"score": 0.75}},
		0.8,
	)
}

# Test meets_compliance_requirements_param function
test_meets_compliance_requirements_param_true if {
	compliance.meets_compliance_requirements_param(
		{"compliance": {"score": 0.85}},
		{"compliance_threshold": 0.8},
	)
}

test_meets_compliance_requirements_param_false if {
	not compliance.meets_compliance_requirements_param(
		{"compliance": {"score": 0.75}},
		{"compliance_threshold": 0.8},
	)
}

test_meets_compliance_requirements_param_default if {
	compliance.meets_compliance_requirements_param(
		{"compliance": {"score": 0.85}},
		{},
	)
}

# Test compliance_score function
test_compliance_score_direct if {
	compliance.compliance_score({"compliance": {"score": 0.85}}) == 0.85
}

test_compliance_score_evaluation if {
	compliance.compliance_score({"evaluation": {"compliance": {"score": 0.85}}}) == 0.85
}

test_compliance_score_default if {
	compliance.compliance_score({}) == 0.0
}

# Test has_required_documentation function
test_has_required_documentation_true if {
	compliance.has_required_documentation({"context": {"compliance_documentation": "This is a compliance document"}})
}

test_has_required_documentation_false if {
	not compliance.has_required_documentation({"context": {"compliance_documentation": ""}})
}

# Test has_version_tracking function
test_has_version_tracking_true if {
	compliance.has_version_tracking({"metadata": {"version": "1.0.0"}})
}

test_has_version_tracking_false if {
	not compliance.has_version_tracking({"metadata": {"version": ""}})
}

# Test meets_data_protection function
test_meets_data_protection_true if {
	compliance.meets_data_protection({"requirements": ["data_protection", "other_requirement"]})
}

test_meets_data_protection_false if {
	not compliance.meets_data_protection({"requirements": ["other_requirement"]})
}

# Test has_data_retention_policy function
test_has_data_retention_policy_true if {
	compliance.has_data_retention_policy({"requirements": ["data_retention", "other_requirement"]})
}

test_has_data_retention_policy_false if {
	not compliance.has_data_retention_policy({"requirements": ["other_requirement"]})
}
