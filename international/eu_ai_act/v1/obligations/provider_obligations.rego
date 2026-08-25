# RequiredMetrics:
#   - system.high_risk
#   - provider.quality_management_system
#   - provider.technical_documentation_kept
#   - provider.logs_kept
#   - provider.conformity_assessment_completed
#   - provider.declaration_of_conformity_drawn_up
#   - provider.ce_marking_affixed
#   - provider.registered_in_eu_database
#   - provider.identification_on_system_or_packaging
#   - provider.corrective_action_process
#   - provider.accessibility_requirements_met
#
# RequiredParams: none
package international.eu_ai_act.v1.obligations.provider_obligations

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Provider Obligations (Article 16)",
	"description": "Evaluates a provider of a high-risk AI system against the Article 16 obligations. Article 16 is a checklist that pulls in the rest of Chapter III by reference, so this policy tests each limb separately and names the ones that fail. Placing a system on the market with any of them outstanding is a breach regardless of how well the underlying model performs.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 16 of the EU AI Act, obligations of providers of high-risk AI systems",
		"Articles 17 to 20, 43, 47, 48 and 49 of the EU AI Act, referenced by Article 16",
	],
}

default in_scope := false

in_scope if {
	input.system.high_risk == true
}

default scope_determined := false

scope_determined if {
	is_boolean(input.system.high_risk)
}

obligations := {
	"Article 16(b) provider identification on the system or packaging": "identification_on_system_or_packaging",
	"Article 16(c) / 17 quality management system": "quality_management_system",
	"Article 16(d) / 18 technical documentation kept": "technical_documentation_kept",
	"Article 16(e) / 19 automatically generated logs kept": "logs_kept",
	"Article 16(f) / 43 conformity assessment": "conformity_assessment_completed",
	"Article 16(g) / 47 EU declaration of conformity": "declaration_of_conformity_drawn_up",
	"Article 16(h) / 48 CE marking affixed": "ce_marking_affixed",
	"Article 16(i) / 49 registration in the EU database": "registered_in_eu_database",
	"Article 16(j) / 20 corrective action process": "corrective_action_process",
	"Article 16(l) accessibility requirements": "accessibility_requirements_met",
}

unmet_obligations contains label if {
	some label, field in obligations
	object.get(input, ["provider", field], false) != true
}

default all_obligations_met := false

all_obligations_met if {
	count(unmet_obligations) == 0
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	all_obligations_met
}

policy_metrics := {
	"article_16_obligations_unmet": {
		"name": "Article 16 Obligations Not Met",
		"value": sort([o | some o in unmet_obligations]),
		"control_passed": all_obligations_met,
	},
	"obligations_unmet_count": {
		"name": "Number of Article 16 Obligations Outstanding",
		"value": count(unmet_obligations),
		"control_passed": all_obligations_met,
	},
}

report := reporting.compose_report("eu_ai_act.obligations.provider_obligations", allow, policy_metrics)
