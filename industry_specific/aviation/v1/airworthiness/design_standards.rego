# RequiredMetrics:
#   - system.failure_condition_severity
#   - software.design_assurance_level
#
# RequiredParams: none
package industry_specific.aviation.v1.airworthiness.design_standards

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Aviation Software/Hardware Design Assurance",
	"description": "Evaluates whether a system's software Design Assurance Level (DAL) is at least as rigorous as its worst-case failure condition severity requires.",
	"version": "1.0.0",
	"category": "Industry-Specific",
	"references": [
		"RTCA DO-178C - Software Considerations in Airborne Systems and Equipment Certification",
		"RTCA DO-254 - Design Assurance Guidance for Airborne Electronic Hardware",
	],
}

# Failure condition severity to minimum required DAL, per DO-178C Table (A=Catastrophic ... E=No Effect)
required_dal := {
	"catastrophic": "A",
	"hazardous": "B",
	"major": "C",
	"minor": "D",
	"no_effect": "E",
}

dal_rank := {"A": 5, "B": 4, "C": 3, "D": 2, "E": 1}

default allow := false

allow if {
	severity := input.system.failure_condition_severity
	minimum_dal := required_dal[severity]
	dal_rank[input.software.design_assurance_level] >= dal_rank[minimum_dal]
}

policy_metrics := {
	"design_assurance_level_sufficient": {
		"name": "Design Assurance Level Meets Failure Condition Severity",
		"value": object.get(input.software, "design_assurance_level", null),
		"control_passed": allow,
	},
}

report := reporting.compose_report("aviation.airworthiness.design_standards", allow, policy_metrics)
