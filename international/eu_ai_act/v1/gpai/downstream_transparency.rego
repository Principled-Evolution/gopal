# RequiredMetrics:
#   - model.general_purpose
#   - model.free_and_open_source
#   - model.parameters_publicly_available
#   - model.systemic_risk
#   - downstream.annex_xii_information_provided
#   - downstream.enables_downstream_compliance
#   - copyright.policy_in_place
#   - copyright.respects_article_4_3_reservations
#   - training_content.public_summary_available
#   - training_content.summary_sufficiently_detailed
#
# RequiredParams: none
package international.eu_ai_act.v1.gpai.downstream_transparency

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act GPAI Downstream, Copyright and Training Content Obligations (Article 53(1)(b) to (d))",
	"description": "Evaluates the three Article 53 obligations that face outward from a general-purpose AI model provider: information and documentation to downstream providers so they can meet their own obligations, a policy to comply with Union copyright law including the Article 4(3) DSM text and data mining reservations, and a sufficiently detailed publicly available summary of the training content. The free and open-source exemption in Article 53(2) reaches only the downstream information duty; the copyright policy and training content summary apply regardless.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 53(1)(b) of the EU AI Act, information to downstream providers",
		"Article 53(1)(c) of the EU AI Act, Union copyright policy and Article 4(3) DSM reservations",
		"Article 53(1)(d) of the EU AI Act, public summary of training content",
		"Article 53(2) of the EU AI Act, scope of the free and open-source exemption",
		"Annex XII, information for downstream providers",
	],
}

default is_gpai := false

is_gpai if {
	input.model.general_purpose == true
}

default scope_determined := false

scope_determined if {
	is_boolean(input.model.general_purpose)
}

default systemic_risk := false

systemic_risk if {
	input.model.systemic_risk == true
}

# Article 53(2) reaches (a) and (b) only, and never for systemic risk models.
default downstream_exemption_applies := false

downstream_exemption_applies if {
	input.model.free_and_open_source == true
	input.model.parameters_publicly_available == true
	not systemic_risk
}

default downstream_information_met := false

downstream_information_met if {
	downstream_exemption_applies
}

downstream_information_met if {
	input.downstream.annex_xii_information_provided == true
	input.downstream.enables_downstream_compliance == true
}

# Article 53(1)(c) and (d) apply regardless of the licence.
default copyright_policy_met := false

copyright_policy_met if {
	input.copyright.policy_in_place == true
	input.copyright.respects_article_4_3_reservations == true
}

default training_summary_met := false

training_summary_met if {
	input.training_content.public_summary_available == true
	input.training_content.summary_sufficiently_detailed == true
}

default allow := false

allow if {
	scope_determined
	not is_gpai
}

allow if {
	scope_determined
	is_gpai
	downstream_information_met
	copyright_policy_met
	training_summary_met
}

failed_obligations := [name |
	some name, satisfied in {
		"Article 53(1)(b) information to downstream providers": downstream_information_met,
		"Article 53(1)(c) Union copyright policy and Article 4(3) reservations": copyright_policy_met,
		"Article 53(1)(d) public summary of training content": training_summary_met,
	}
	satisfied == false
]

policy_metrics := {
	"article_53_obligations_failed": {
		"name": "Article 53(1)(b) to (d) Obligations Not Met",
		"value": sort(failed_obligations),
		"control_passed": count(failed_obligations) == 0,
	},
	"downstream_exemption_applies": {
		"name": "Article 53(2) Exemption Applies to the Downstream Information Duty",
		"value": downstream_exemption_applies,
		"control_passed": downstream_information_met,
	},
	"copyright_reservations_respected": {
		"name": "Article 4(3) DSM Text and Data Mining Reservations Respected",
		"value": object.get(input, ["copyright", "respects_article_4_3_reservations"], false),
		"control_passed": copyright_policy_met,
	},
}

report := reporting.compose_report("eu_ai_act.gpai.downstream_transparency", allow, policy_metrics)
