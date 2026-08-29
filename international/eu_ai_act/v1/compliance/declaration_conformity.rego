# RequiredMetrics:
#   - system.high_risk
#   - declaration.drawn_up
#   - declaration.machine_readable
#   - declaration.annex_v_content_complete
#   - declaration.retained_ten_years
#   - declaration.translated_for_market
#
# RequiredParams: none
package international.eu_ai_act.v1.compliance.declaration_conformity

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act EU Declaration of Conformity (Article 47)",
	"description": "Evaluates the EU declaration of conformity for a high-risk AI system. Article 47 requires more than the document existing: it must be machine readable, physically or electronically signed, contain the information set out in Annex V, be kept at the disposal of the national authorities for ten years, and be translated into a language required by the Member State where the system is placed on the market.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 47 of the EU AI Act, EU declaration of conformity",
		"Article 47(1), ten-year retention at the disposal of national authorities",
		"Annex V, EU declaration of conformity content",
	],
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

requirements := {
	"Article 47(1) declaration drawn up": "drawn_up",
	"Article 47(1) machine readable": "machine_readable",
	"Annex V content complete": "annex_v_content_complete",
	"Article 47(1) retained for ten years": "retained_ten_years",
	"Article 47(2) translated for the market": "translated_for_market",
}

unmet contains label if {
	some label, field in requirements
	object.get(input, ["declaration", field], false) != true
}

default all_met := false

all_met if {
	count(unmet) == 0
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	all_met
}

policy_metrics := {
	"article_47_requirements_unmet": {
		"name": "Article 47 Declaration Requirements Not Met",
		"value": sort([r | some r in unmet]),
		"control_passed": all_met,
	},
	"machine_readable": {
		"name": "Declaration Is Machine Readable",
		"value": object.get(input, ["declaration", "machine_readable"], false),
		"control_passed": all_met,
	},
}

report := reporting.compose_report("eu_ai_act.compliance.declaration_conformity", allow, policy_metrics)
