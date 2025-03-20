# RequiredMetrics:
#   - compliance.score
#
# RequiredParams:
#   - compliance_threshold (default 0.8)
#
package global.v1.common.compliance

import rego.v1

# Common compliance rules and utilities for reuse across policies

# Check if compliance score exceeds threshold
meets_compliance_requirements(metrics, threshold) if {
	compliance_score(metrics) >= threshold
}

# Parameterized version that reads from input.params
meets_compliance_requirements_param(metrics, input_params) if {
	compliance_score(metrics) >= object.get(input_params, "compliance_threshold", 0.8)
}

# Get compliance score with reasonable default
compliance_score(metrics) := score if {
	score = metrics.compliance.score
} else := score if {
	score = metrics.evaluation.compliance.score
} else := 0.0

# Check if contract has required compliance documentation
has_required_documentation(contract) if {
	contract.context.compliance_documentation != ""
}

# Check if contract has proper version tracking
has_version_tracking(contract) if {
	contract.metadata.version != ""
}

# Check if contract meets data protection requirements
meets_data_protection(contract) if {
	"data_protection" in contract.requirements
}

# Check if contract specifies data retention policies
has_data_retention_policy(contract) if {
	"data_retention" in contract.requirements
}
