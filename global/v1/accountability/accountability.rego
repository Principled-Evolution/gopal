# RequiredMetrics:
#   - governance.human_oversight.enabled
#   - governance.audit_logging.enabled
#   - metrics.audit_logging.completeness
#   - governance.responsibility.clearly_assigned
#   - governance.incident_response.process_defined
#
# RequiredParams:
#   - audit_logging_completeness_threshold (default 0.8)
#
package global.v1.accountability

import data.helper_functions.declarations
import data.helper_functions.metrics
import rego.v1

# Metadata
metadata := {
	"title": "Global Accountability Policy",
	"description": "General accountability requirements for AI systems",
	"version": "1.0.0",
	"category": "Global",
	"references": ["AICertify Accountability Standards"],
}

# Read through the canonical table rather than one hard-coded path, so a score
# supplied as metrics.audit_logging.completeness is seen as readily as the legacy
# spelling. resolve, not resolve_or: an absent metric must stay undefined so
# the rule body fails and `default := false` denies. A -1 sentinel is right
# where the comparison is `>=`, and silently wrong where it is `<`, because
# -1 is below every threshold and would let an unevaluated system pass.
audit_logging_completeness := metrics.resolve(input, "metrics.audit_logging.completeness")

# Default deny
default allow := false

# Allow if accountability requirements are satisfied
allow if {
	# Check if system has human oversight
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true

	# Check if system has audit logging
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness >= object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)

	# Check if system has explicit responsibility assignment
	declarations.resolve(input, ["governance", "responsibility", "clearly_assigned"]) == true

	# Check if system has incident response process
	declarations.resolve(input, ["governance", "incident_response", "process_defined"]) == true
}

# Non-compliant rules for reporting
non_compliant if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == false
}

non_compliant if {
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == false
}

non_compliant if {
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness < object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)
}

non_compliant if {
	declarations.resolve(input, ["governance", "responsibility", "clearly_assigned"]) == false
}

non_compliant if {
	declarations.resolve(input, ["governance", "incident_response", "process_defined"]) == false
}

# What the report shows for audit logging completeness.
#
# null when nothing was supplied, so an unmeasured system is not reported as one
# that logs nothing. The decision path is undefined in the same case and the
# default denies; a report rule left undefined would instead delete the whole
# compliance_report object and lose the finding silently.
default reported_audit_logging_completeness := null

reported_audit_logging_completeness := metrics.resolve(input, "metrics.audit_logging.completeness")

# Define the compliance report
compliance_report := {
	"policy": "Global Accountability Policy",
	"version": "1.0.0",
	"overall_result": allow,
	"details": {
		"human_oversight_enabled": object.get(input, ["governance", "human_oversight", "enabled"], false),
		"audit_logging_enabled": object.get(input, ["governance", "audit_logging", "enabled"], false),
		"audit_logging_completeness": reported_audit_logging_completeness,
		"audit_logging_completeness_threshold": object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8),
		"responsibility_assigned": object.get(input, ["governance", "responsibility", "clearly_assigned"], false),
		"incident_response_defined": object.get(input, ["governance", "incident_response", "process_defined"], false),
	},
	"recommendations": recommendations,
}

# Generate recommendations based on compliance issues
# See the note in global/v1/transparency: without a default, an unmeasured
# completeness leaves recommendations undefined and takes the whole
# compliance_report with it.
# What to recommend when no branch above matched. See the note in
# global/v1/transparency: without this the report deletes itself, and a fixed
# string naming one input is wrong whenever that input is the one present.
_input_presence := {
	"governance.human_oversight.enabled": declarations.supplied(input, ["governance", "human_oversight", "enabled"]),
	"governance.audit_logging.enabled": declarations.supplied(input, ["governance", "audit_logging", "enabled"]),
	"governance.responsibility.clearly_assigned": declarations.supplied(input, ["governance", "responsibility", "clearly_assigned"]),
	"governance.incident_response.process_defined": declarations.supplied(input, ["governance", "incident_response", "process_defined"]),
	"metrics.audit_logging.completeness": metrics.supplied(input, "metrics.audit_logging.completeness"),
}

# The inputs this policy reads, and whether each arrived. Object iteration in
# Rego is ordered by key, so the list below is stable between runs.
default _unsupplied_recs := ["Every input this policy reads was supplied, but not in a form it recognises. Check the values against the inputs declared at the top of this policy."]

_unsupplied_recs := [sprintf("Supply %v, which this policy reads and did not receive", [name]) |
	some name in _unsupplied_names
] if {
	count(_unsupplied_names) > 0
}

_unsupplied_names := [name |
	some name, present in _input_presence
	not present
]

# One of the branches below matched, or none did and the input is incomplete.
# The two are mutually exclusive, so they cannot conflict.
recommendations := _matched_recommendations if {
	_matched_recommendations
}

recommendations := _unsupplied_recs if {
	not _matched_recommendations
}

_matched_recommendations := human_oversight_recs if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == false
}

_matched_recommendations := audit_logging_recs if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == false
}

_matched_recommendations := audit_logging_completeness_recs if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness < object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)
}

_matched_recommendations := responsibility_recs if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness >= object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)
	declarations.resolve(input, ["governance", "responsibility", "clearly_assigned"]) == false
}

_matched_recommendations := incident_response_recs if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness >= object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)
	declarations.resolve(input, ["governance", "responsibility", "clearly_assigned"]) == true
	declarations.resolve(input, ["governance", "incident_response", "process_defined"]) == false
}

_matched_recommendations := [] if {
	declarations.resolve(input, ["governance", "human_oversight", "enabled"]) == true
	declarations.resolve(input, ["governance", "audit_logging", "enabled"]) == true
	audit_logging_completeness >= object.get(input, ["params", "audit_logging_completeness_threshold"], 0.8)
	declarations.resolve(input, ["governance", "responsibility", "clearly_assigned"]) == true
	declarations.resolve(input, ["governance", "incident_response", "process_defined"]) == true
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
