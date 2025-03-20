package global.v1.accountability_test

import data.global.v1.accountability

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {},
	}
}

# Test case for non-compliant input (missing human oversight)
test_deny_missing_human_oversight if {
	not accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": false},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test case for non-compliant input (missing audit logging)
test_deny_missing_audit_logging if {
	not accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": false,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test case for non-compliant input (insufficient audit logging completeness)
test_deny_insufficient_audit_logging_completeness if {
	not accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.7,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test case for non-compliant input (missing responsibility assignment)
test_deny_missing_responsibility_assignment if {
	not accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": false},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test case for non-compliant input (missing incident response)
test_deny_missing_incident_response if {
	not accountability.allow with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": false},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test recommendations for missing human oversight
test_recommendations_human_oversight if {
	accountability.recommendations == ["Implement human oversight mechanisms for the AI system"] with input as {
		"governance": {
			"human_oversight": {"enabled": false},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test recommendations for missing audit logging
test_recommendations_audit_logging if {
	accountability.recommendations == ["Enable comprehensive audit logging for all AI system actions and decisions"] with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": false,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test recommendations for insufficient audit logging completeness
test_recommendations_audit_logging_completeness if {
	accountability.recommendations[0] == "Enhance audit logging to capture more comprehensive information about system operations" with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.7,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := accountability.compliance_report with input as {
		"governance": {
			"human_oversight": {"enabled": true},
			"audit_logging": {
				"enabled": true,
				"completeness_score": 0.85,
			},
			"responsibility": {"clearly_assigned": true},
			"incident_response": {"process_defined": true},
		},
		"params": {"audit_logging_completeness_threshold": 0.75},
	}

	report.details.human_oversight_enabled == true
	report.details.audit_logging_enabled == true
	report.details.audit_logging_completeness == 0.85
	report.details.audit_logging_completeness_threshold == 0.75
	report.details.responsibility_assigned == true
	report.details.incident_response_defined == true
	report.overall_result == true
	report.recommendations == []
}
