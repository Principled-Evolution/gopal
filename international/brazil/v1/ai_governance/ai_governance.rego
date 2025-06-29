package international.brazil.v1.ai_governance

import rego.v1

metadata := {
	"title": "Brazil AI Governance Policy (Bill 2338/2023)",
	"description": "Policies based on Brazil's Bill of Law No. 2,338/2023 for AI governance, adopting a risk-based approach.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"Brazil Bill of Law No. 2,338/2023 (PL 2338/23)",
		"Brazilian Artificial Intelligence Strategy (EBIA) 2021"
	],
}

# Default deny
default allow := false

# Excessive Risk: Prohibited systems
allow := false if {
	input.ai_system.risk_category == "excessive_risk"
	input.ai_system.type == "autonomous_weapons_system" # Example of a prohibited system
}

# High-Risk: Subject to stringent compliance
allow if {
	input.ai_system.risk_category == "high_risk"
	right_to_explanation.allow
	right_to_contest.allow
	right_to_human_review.allow
	algorithmic_impact_assessment.allow
	robustness_accuracy_reliability.allow
	oversight_authority.allow
}

# Other Systems: Basic requirements
allow if {
	input.ai_system.risk_category == "other_systems"
	input.ai_system.basic_requirements_met
}

# Right to Explanation
right_to_explanation := { "allow": true, "msg": "Right to explanation met." } if {
	input.rights.explanation_provided
} else := { "allow": false, "msg": "Right to explanation not met." }

# Right to Contest
right_to_contest := { "allow": true, "msg": "Right to contest met." } if {
	input.rights.contest_mechanism_available
} else := { "allow": false, "msg": "Right to contest not met." }

# Right to Human Review
right_to_human_review := { "allow": true, "msg": "Right to human review met." } if {
	input.rights.human_review_available
} else := { "allow": false, "msg": "Right to human review not met." }

# Algorithmic Impact Assessment
algorithmic_impact_assessment := { "allow": true, "msg": "Algorithmic impact assessment conducted." } if {
	input.compliance.algorithmic_impact_assessment_conducted
} else := { "allow": false, "msg": "Algorithmic impact assessment not conducted." }

# Robustness, Accuracy, Reliability
robustness_accuracy_reliability := { "allow": true, "msg": "Robustness, accuracy, and reliability ensured." } if {
	input.compliance.robustness_ensured
	input.compliance.accuracy_ensured
	input.compliance.reliability_ensured
} else := { "allow": false, "msg": "Robustness, accuracy, or reliability not ensured." }

# Oversight Authority
oversight_authority := { "allow": true, "msg": "Oversight authority requirements met." } if {
	input.compliance.oversight_authority_engaged
} else := { "allow": false, "msg": "Oversight authority requirements not met." }