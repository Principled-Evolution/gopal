package international.nist.v1.ai_600_1

import data.international.nist.v1.govern
import data.international.nist.v1.manage
import data.international.nist.v1.map
import data.international.nist.v1.measure
import rego.v1

metadata := {
	"title": "NIST AI RMF Orchestrator",
	"description": "Orchestrates the NIST AI Risk Management Framework policies.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

allow if {
	govern_compliant
	map_compliant
	measure_compliant
	manage_compliant
}

# Helper rules to check compliance for each function
govern_compliant if {
	governance_input := {
		"governance": object.get(input, "governance", {}),
		"transparency": object.get(input, "transparency", {}),
		"fairness": object.get(input, "fairness", {}),
	}

	# Check governance requirements directly
	governance_input.governance
	governance_input.transparency
	governance_input.fairness
}

map_compliant if {
	input.map
}

measure_compliant if {
	input.measure
}

manage_compliant if {
	input.manage
}
