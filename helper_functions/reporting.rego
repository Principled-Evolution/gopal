package helper_functions.reporting

import rego.v1

# Validate metric structure has exactly the required fields with correct types
is_valid_metric(metric) := false if {
	# Check if metric is an object
	not is_object(metric)
} else := false if {
	# Check required fields exist with exact match
	required_fields := {"name", "value", "control_passed"}
	metric_fields := {field | some field in object.keys(metric)}
	required_fields != metric_fields
} else := false if {
	# Validate types
	not is_string(metric.name)
} else := false if {
	not is_boolean(metric.control_passed)
} else := true

# default case when all validations pass

# Validate entire metrics object structure
validate_metrics(metrics) := {"valid": valid, "errors": errors} if {
	# Collect validation errors for each metric
	errors := [msg |
		some metric_key, metric in metrics
		not is_valid_metric(metric)
		msg := sprintf("Invalid metric structure for '%v'. Each metric must contain exactly: name (string), value (any), control_passed (boolean)", [metric_key])
	]

	valid := count(errors) == 0
}

# Compose a standardized report output.
# Parameters:
#   policy_name: string - name of the policy being evaluated
#   result: boolean - overall result of the policy evaluation
#   metrics: object - map of metric keys to objects containing name, value, and control_passed
compose_report(policy_name, result, metrics) := report if {
	# Validate metrics structure
	validation := validate_metrics(metrics)
	validation.valid

	# Generate report if validation passes
	report := {
		"policy": policy_name,
		"result": result,
		"metrics": metrics,
		"timestamp": time.now_ns(),
	}
} else := {"error": validation.errors[0]} if {
	# Return first error if validation fails
	validation := validate_metrics(metrics)
	not validation.valid
}

# Helper rule to validate report structure
is_valid_report(report) if {
	is_object(report)
	report.policy != null
	report.metrics != null

	# Validate metrics structure
	validation := validate_metrics(report.metrics)
	validation.valid
} else := false

# Helper rule to check if a value is a report_output
is_report_output(value) if {
	is_valid_report(value)
} else := false
