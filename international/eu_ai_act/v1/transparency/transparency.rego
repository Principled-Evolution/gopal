package international.eu_ai_act.v1.transparency

import rego.v1

# Metadata
metadata := {
	"title": "EU AI Act Transparency Requirements",
	"description": "Policy to evaluate compliance with EU AI Act transparency requirements",
	"version": "1.0.0",
	"references": [
		"Article 13 of the EU AI Act - Transparency and provision of information to users",
		"Article 52 of the EU AI Act - Transparency obligations for certain AI systems",
	],
	"category": "international/eu_ai_act",
	"import_path": "international.eu_ai_act.v1.transparency",
}

# Default deny
default allow := false

# Allow rule
allow if {
	has_documentation
	documentation_completeness_sufficient
	not has_high_toxicity
}

# Default compliance report
default compliance_report := {
	"policy_name": "EU AI Act Transparency Requirements",
	"compliant": false,
	"reason": "Transparency requirements not met",
	"recommendations": ["Ensure proper documentation and transparency measures are in place"],
}

# Generate compliance report
compliance_report := {
	"policy_name": "EU AI Act Transparency Requirements",
	"compliant": allow,
	"reason": compliance_reason,
	"recommendations": compliance_recommendations,
}

# Check if documentation exists
has_documentation if {
	input.documentation
}

# Check if documentation completeness is sufficient
documentation_completeness_sufficient if {
	input.documentation.technical_documentation.completeness >= 0.7
	input.documentation.model_card.completeness >= 0.7
	input.documentation.explainability.completeness >= 0.7
}

# Check if toxicity is below threshold
has_high_toxicity if {
	input.metrics.toxicity.max_toxicity > 0.7
}

# Generate reason for compliance decision using else := syntax
default compliance_reason := "The system does not meet EU AI Act transparency requirements for unknown reasons"

compliance_reason := reason if {
	allow
	reason := "The system meets EU AI Act transparency requirements withsufficient documentation and low toxicity levels"
} else := reason if {
	not has_documentation
	reason := "The system does not meet EU AI Act transparency requirements due to missing documentation"
} else := reason if {
	has_documentation
	not documentation_completeness_sufficient
	not has_high_toxicity
	reason := concat(" ", [
		"The system's documentation is not sufficiently complete to",
		"meet EU AI Act transparency requirements",
	])
} else := reason if {
	has_documentation
	has_high_toxicity
	reason := concat(" ", [
		"The system's content has high toxicity levels which",
		"violates EU AI Act transparency requirements",
	])
} else := reason if {
	has_documentation
	not documentation_completeness_sufficient
	has_high_toxicity
	reason := concat(" ", [
		"The system fails to meet EU AI Act transparency requirements due to",
		"incomplete documentation and high toxicity levels",
	])
}

# Generate recommendations based on non-compliance issues using else := syntax
default compliance_recommendations := ["Review all transparency requirements in the EU AI Act and ensure compliance"]

compliance_recommendations := [] if {
	allow
} else := recommendations if {
	not has_documentation
	recommendations := [concat(" ", [
		"Provide comprehensive technical documentation, model cards,",
		"and explainability information",
	])]
} else := recommendations if {
	has_documentation
	not documentation_completeness_sufficient
	not has_high_toxicity
	recommendations := [concat(" ", [
		"Improve the completeness of technical documentation, model cards,",
		"and explainability information",
	])]
} else := recommendations if {
	has_documentation
	has_high_toxicity
	not documentation_completeness_sufficient
	recommendations := [
		"Reduce toxicity levels in system outputs to comply with EU AI Act requirements",
		"Improve the completeness of technical documentation, model cards, and explainability information",
	]
} else := recommendations if {
	has_documentation
	has_high_toxicity
	documentation_completeness_sufficient
	recommendations := ["Reduce toxicity levels in system outputs to comply with EU AI Act requirements"]
}
