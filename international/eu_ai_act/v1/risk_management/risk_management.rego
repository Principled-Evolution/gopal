package international.eu_ai_act.v1.risk_management

import rego.v1

# Metadata
metadata := {
	"title": "EU AI Act Risk Management Requirements",
	"description": "Policy to evaluate compliance with EU AI Act risk management requirements",
	"version": "1.0.0",
	"references": [
		"Article 9 of the EU AI Act - Risk management system",
		"Article 15 of the EU AI Act - Accuracy, robustness and cybersecurity",
	],
	"category": "international/eu_ai_act",
	"import_path": "international.eu_ai_act.v1.risk_management",
}

# Default deny
default allow := false

# Allow rules
allow if {
	has_risk_management_system
	completeness_sufficient
	not has_high_risk_level
}

# Check if risk management system exists
has_risk_management_system if {
	input.risk_management
}

# Check if risk management completeness is sufficient
completeness_sufficient if {
	input.risk_management.risk_assessment.completeness >= 0.7
	input.risk_management.mitigation_measures.completeness >= 0.7
	input.risk_management.monitoring_system.completeness >= 0.7
}

# Check if risk level is below threshold
has_high_risk_level if {
	input.risk_management.risk_assessment.overall_risk > 0.7
}

# Generate reason for compliance decision
reason_compliant := concat(" ", [
	"The system meets EU AI Act risk management requirements with sufficient",
	"risk assessment and mitigation measures",
])

reason_no_system := "The system does not have a risk management system in place"

reason_incomplete := concat(" ", [
	"The system's risk management is not sufficiently complete to meet",
	"EU AI Act requirements",
])

reason_high_risk := concat(" ", [
	"The system has a high risk level which requires additional controls",
	"under the EU AI Act",
])

reason_unknown := "The system does not meet EU AI Act risk management requirements for unknown reasons"

# Generate recommendations based on non-compliance issues
rec_no_system := [concat(" ", [
	"Implement a comprehensive risk management system that includes risk assessment,",
	"mitigation measures, and monitoring",
])]

rec_incomplete := [concat(" ", [
	"Improve the completeness of risk assessment, mitigation measures,",
	"and monitoring system documentation",
])]

rec_high_risk := [concat(" ", [
	"Implement additional controls and safeguards to reduce",
	"the overall risk level of the system",
])]

rec_unknown := ["Review all risk management requirements in the EU AI Act and ensure compliance"]

# Generate details about compliance evaluation
system_details := {"risk_management_system": {
	"exists": has_risk_management_system,
	"completeness": {
		"risk_assessment": object.get(input, ["risk_management", "risk_assessment", "completeness"], 0),
		"mitigation_measures": object.get(input, ["risk_management", "mitigation_measures", "completeness"], 0),
		"monitoring_system": object.get(input, ["risk_management", "monitoring_system", "completeness"], 0),
	},
	"risk_level": object.get(input, ["risk_management", "risk_assessment", "overall_risk"], 1),
}}

# Define the compliance report
compliance_report := {
	"policy_name": "EU AI Act Risk Management Requirements",
	"compliant": allow,
	"reason": reason,
	"recommendations": recommendations,
	"details": system_details,
}

# Determine the appropriate reason
reason := reason_compliant if {
	allow
}

reason := reason_no_system if {
	not has_risk_management_system
}

reason := reason_incomplete if {
	has_risk_management_system
	not completeness_sufficient
}

reason := reason_high_risk if {
	has_risk_management_system
	completeness_sufficient
	has_high_risk_level
}

reason := reason_unknown if {
	not allow
	has_risk_management_system
	completeness_sufficient
	not has_high_risk_level
}

# Determine the appropriate recommendations
recommendations := [] if {
	allow
}

recommendations := rec_no_system if {
	not has_risk_management_system
}

recommendations := rec_incomplete if {
	has_risk_management_system
	not completeness_sufficient
}

recommendations := rec_high_risk if {
	has_risk_management_system
	completeness_sufficient
	has_high_risk_level
}

recommendations := rec_unknown if {
	not allow
	has_risk_management_system
	completeness_sufficient
	not has_high_risk_level
}
