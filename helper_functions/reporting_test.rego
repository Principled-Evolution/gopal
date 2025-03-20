package helper_functions.reporting_test

import data.helper_functions.reporting
import rego.v1

test_compose_report if {
	# Setup test data
	policy_name := "Test Policy"
	result := true
	metrics := {
		"metric1": {
			"name": "Test Metric 1",
			"value": true,
			"control_passed": true,
		},
		"metric2": {
			"name": "Test Metric 2",
			"value": false,
			"control_passed": false,
		},
	}

	# Call the function
	report := reporting.compose_report(policy_name, result, metrics)

	# Assertions
	report.policy == policy_name
	report.result == result
	report.metrics == metrics
	report.timestamp > 0 # Ensure timestamp exists and is positive
}

test_compose_report_empty_metrics if {
	# Test with empty metrics
	report := reporting.compose_report("Empty Policy", false, {})

	# Assertions
	report.policy == "Empty Policy"
	report.result == false
	report.metrics == {}
	report.timestamp > 0
}

test_compose_report_structure if {
	# Test full structure with all fields
	metrics := {"test_metric": {
		"name": "Test Metric",
		"value": true,
		"control_passed": true,
	}}

	report := reporting.compose_report("Structure Test", true, metrics)

	# Assert all required fields exist
	required_fields := {"policy", "result", "metrics", "timestamp"}
	missing_fields := required_fields - object.keys(report)
	count(missing_fields) == 0
}

# Test invalid metric structure - missing required field
test_compose_report_invalid_metric_missing_field if {
	metrics := {"invalid_metric": {
		"name": "Test Metric",
		"value": true,
		# missing control_passed field
	}}

	report := reporting.compose_report("Invalid Test", true, metrics)

	# Should return error
	report.error != null
	startswith(report.error, "Invalid metric structure")
}

# Test invalid metric structure - wrong type for name
test_compose_report_invalid_metric_wrong_name_type if {
	metrics := {"invalid_metric": {
		"name": 123, # should be string
		"value": true,
		"control_passed": true,
	}}

	report := reporting.compose_report("Invalid Test", true, metrics)

	# Should return error
	report.error != null
	startswith(report.error, "Invalid metric structure")
}

# Test invalid metric structure - wrong type for control_passed
test_compose_report_invalid_metric_wrong_control_type if {
	metrics := {"invalid_metric": {
		"name": "Test Metric",
		"value": true,
		"control_passed": "true", # should be boolean
	}}

	report := reporting.compose_report("Invalid Test", true, metrics)

	# Should return error
	report.error != null
	startswith(report.error, "Invalid metric structure")
}

# Test invalid metric structure - extra field
test_compose_report_invalid_metric_extra_field if {
	metrics := {"invalid_metric": {
		"name": "Test Metric",
		"value": true,
		"control_passed": true,
		"extra": "should not be here",
	}}

	report := reporting.compose_report("Invalid Test", true, metrics)

	# Should return error
	report.error != null
	startswith(report.error, "Invalid metric structure")
}

# Test report validation
test_is_valid_report if {
	test_report := {
		"policy": "Test Policy",
		"metrics": {"metric1": {
			"name": "Test Metric",
			"value": true,
			"control_passed": true,
		}},
	}

	reporting.is_valid_report(test_report)
}

# Test report validation with invalid report
test_is_valid_report_invalid if {
	invalid_report := {
		"policy": "Test Policy",
		"metrics": {"metric1": {
			"name": 123, # Invalid: name should be string
			"value": true,
			"control_passed": true,
		}},
	}

	not reporting.is_valid_report(invalid_report)
}
