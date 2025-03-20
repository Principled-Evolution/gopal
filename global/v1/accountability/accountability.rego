# RequiredMetrics:
#   - governance.human_oversight.enabled
#   - governance.audit_logging.enabled
#   - governance.audit_logging.completeness_score
#   - governance.responsibility.clearly_assigned
#   - governance.incident_response.process_defined
#
# RequiredParams:
#   - audit_logging_completeness_threshold (default 0.8)
#
package global.v1.accountability

import rego.v1

# Metadata
metadata := {
	"title": "Global Accountability Policy",
	"description": "General accountability requirements for AI systems",
	"version": "1.0.0",
	"category": "Global",
	"references": ["AICertify Accountability Standards"],
}

# Default deny
default allow := false

# Allow if accountability requirements are satisfied
allow if {
	# Check if system has human oversight
	input.governance.human_oversight.enabled == true

	# Check if system has audit logging
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score >= object.get(input.params, "audit_logging_completeness_threshold", 0.8)

	# Check if system has explicit responsibility assignment
	input.governance.responsibility.clearly_assigned == true

	# Check if system has incident response process
	input.governance.incident_response.process_defined == true
}

# Non-compliant rules for reporting
non_compliant if {
	input.governance.human_oversight.enabled == false
}

non_compliant if {
	input.governance.audit_logging.enabled == false
}

non_compliant if {
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score < object.get(input.params, "audit_logging_completeness_threshold", 0.8)
}

non_compliant if {
	input.governance.responsibility.clearly_assigned == false
}

non_compliant if {
	input.governance.incident_response.process_defined == false
}

# Define the compliance report
compliance_report := {
	"policy": "Global Accountability Policy",
	"version": "1.0.0",
	"overall_result": allow,
	"details": {
		"human_oversight_enabled": object.get(input.governance, ["human_oversight", "enabled"], false),
		"audit_logging_enabled": object.get(input.governance, ["audit_logging", "enabled"], false),
		"audit_logging_completeness": object.get(input.governance, ["audit_logging", "completeness_score"], 0),
		"audit_logging_completeness_threshold": object.get(input.params, "audit_logging_completeness_threshold", 0.8),
		"responsibility_assigned": object.get(input.governance, ["responsibility", "clearly_assigned"], false),
		"incident_response_defined": object.get(input.governance, ["incident_response", "process_defined"], false),
	},
	"recommendations": recommendations,
}

# Generate recommendations based on compliance issues
recommendations := human_oversight_recs if {
	input.governance.human_oversight.enabled == false
}

recommendations := audit_logging_recs if {
	input.governance.human_oversight.enabled == true
	input.governance.audit_logging.enabled == false
}

recommendations := audit_logging_completeness_recs if {
	input.governance.human_oversight.enabled == true
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score < object.get(input.params, "audit_logging_completeness_threshold", 0.8)
}

recommendations := responsibility_recs if {
	input.governance.human_oversight.enabled == true
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score >= object.get(input.params, "audit_logging_completeness_threshold", 0.8)
	input.governance.responsibility.clearly_assigned == false
}

recommendations := incident_response_recs if {
	input.governance.human_oversight.enabled == true
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score >= object.get(input.params, "audit_logging_completeness_threshold", 0.8)
	input.governance.responsibility.clearly_assigned == true
	input.governance.incident_response.process_defined == false
}

recommendations := [] if {
	input.governance.human_oversight.enabled == true
	input.governance.audit_logging.enabled == true
	input.governance.audit_logging.completeness_score >= object.get(input.params, "audit_logging_completeness_threshold", 0.8)
	input.governance.responsibility.clearly_assigned == true
	input.governance.incident_response.process_defined == true
}

# Define recommendation values
human_oversight_recs := ["Implement human oversight mechanisms for the AI system"]

audit_logging_recs := ["Enable comprehensive audit logging for all AI system actions and decisions"]

# Break long lines using concat
audit_logging_completeness_recs := [concat(" ", [
	"Enhance audit logging to capture more comprehensive information",
	"about system operations",
])]

responsibility_recs := ["Clearly assign and document responsibilities for the AI system operation and governance"]

# Break long lines using concat
incident_response_recs := [concat(" ", [
	"Define and document an incident response process for AI system failures",
	"or unintended consequences",
])]
