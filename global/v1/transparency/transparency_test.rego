package global.v1.transparency_test

import data.global.v1.transparency

# Test case for compliant input with custom parameters
test_allow_with_custom_params if {
	transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.7,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for compliant input with default parameters
test_allow_with_default_params if {
	transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {},
	}
}

# Test case for non-compliant input (missing model card)
test_deny_missing_model_card if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": false,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (insufficient model card completeness)
test_deny_insufficient_model_card_completeness if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.5,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing explainability)
test_deny_missing_explainability if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": false},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing limitations)
test_deny_missing_limitations if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": false},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test case for non-compliant input (missing use cases)
test_deny_missing_use_cases if {
	not transparency.allow with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": false},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test recommendations for missing model card
test_recommendations_missing_model_card if {
	transparency.recommendations == ["Create a model card documenting the AI system's properties, capabilities, and limitations"] with input as {
		"documentation": {
			"model_card": {
				"exists": false,
				"completeness_score": 0,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test recommendations for insufficient model card completeness
test_recommendations_insufficient_model_card_completeness if {
	transparency.recommendations == ["Enhance the model card with more comprehensive information about the AI system"] with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.5,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}
}

# Test compliance report details
test_compliance_report_details if {
	report := transparency.compliance_report with input as {
		"documentation": {
			"model_card": {
				"exists": true,
				"completeness_score": 0.85,
			},
			"explainability": {"provided": true},
			"limitations": {"documented": true},
			"use_cases": {"defined": true},
		},
		"params": {"model_card_completeness_threshold": 0.6},
	}

	report.details.model_card_exists == true
	report.details.model_card_completeness == 0.85
	report.details.model_card_completeness_threshold == 0.6
	report.details.explainability_provided == true
	report.details.limitations_documented == true
	report.details.use_cases_defined == true
	report.overall_result == true
	report.recommendations == []
}
