package international.nist.v1.govern

import rego.v1

metadata := {
	"title": "NIST AI RMF - Govern",
	"description": "Policies for the Govern function of the NIST AI Risk Management Framework.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

# Allow if all governance dimensions are compliant
allow if {
	accountability.allow
	transparency.allow
	fairness.allow
}

# Accountability: Check for clear lines of responsibility and oversight
accountability := { "allow": true, "msg": "Accountability requirements met." } if {
	# Placeholder: Check for defined roles and responsibilities
	input.governance.roles_and_responsibilities_defined
	# Placeholder: Check for established oversight mechanisms
	input.governance.oversight_mechanisms_in_place
} else := { "allow": false, "msg": "Accountability requirements not met." }

# Transparency: Check for clear communication about the AI system
transparency := { "allow": true, "msg": "Transparency requirements met." } if {
	# Placeholder: Check for public documentation about the system's purpose and limitations
	input.transparency.public_documentation_available
	# Placeholder: Check for clear explanations of the system's decisions
	input.transparency.decision_explanations_provided
} else := { "allow": false, "msg": "Transparency requirements not met." }

# Fairness: Check for measures to mitigate bias
fairness := { "allow": true, "msg": "Fairness requirements met." } if {
	# Placeholder: Check for regular bias assessments
	input.fairness.bias_assessments_conducted
	# Placeholder: Check for mitigation strategies for identified biases
	input.fairness.bias_mitigation_strategies_in_place
} else := { "allow": false, "msg": "Fairness requirements not met." }
