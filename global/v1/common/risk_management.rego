# RequiredMetrics:
#   - risk_management_score
#
# RequiredParams:
#   - risk_management_threshold (default 0.7)
package global.v1.common.risk_management

import rego.v1

# Common risk management rules and utilities for reuse across policies

# Check if risk score exceeds threshold (higher is better for risk management)
has_adequate_risk_management(metrics, threshold) if {
	risk_score(metrics) >= threshold
}

# Get risk management score with reasonable default
risk_score(metrics) := score if {
	score = metrics.risk_management.score
} else := score if {
	score = metrics.evaluation.risk_management.score
} else := 0.0

# Check if risk management score passes threshold
passes_risk_threshold(eval, threshold) if {
	eval.risk_management_score >= threshold
}

# Check if risk documentation is present and adequate
has_adequate_documentation(contract) if {
	contract.context.risk_documentation != ""
}

# Check if risk documentation contains minimum required sections
has_required_documentation_sections(contract) if {
	doc := contract.context.risk_documentation
	contains(doc, "Risk Assessment")
	contains(doc, "Mitigation Measures")
} else := false
