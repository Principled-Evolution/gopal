# RequiredMetrics:
#   - system.high_risk
#   - datasets.relevant
#   - datasets.sufficiently_representative
#   - datasets.errors_addressed
#   - datasets.complete_to_the_extent_possible
#   - datasets.contextual_characteristics_considered
#
# RequiredParams: none
package international.eu_ai_act.v1.data_governance.data_quality

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Data Quality Criteria (Article 10(3) to 10(4))",
	"description": "Evaluates the training, validation and testing datasets of a high-risk AI system against the Article 10(3) quality criteria: relevant, sufficiently representative, and to the best extent possible free of errors and complete. Article 10(4) adds that the characteristics of the specific geographical, contextual, behavioural or functional setting must be considered, which is the criterion most often skipped when a dataset is reused across markets.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 10(3) of the EU AI Act, dataset quality criteria",
		"Article 10(4) of the EU AI Act, geographical, contextual, behavioural and functional setting",
		"Recital 67 of the EU AI Act",
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

# Article 10(3): the four criteria are cumulative.
criteria := {
	"relevant": "relevant",
	"sufficiently representative": "sufficiently_representative",
	"errors addressed to the extent possible": "errors_addressed",
	"complete to the extent possible": "complete_to_the_extent_possible",
}

unmet_criteria contains label if {
	some label, field in criteria
	object.get(input, ["datasets", field], false) != true
}

default quality_criteria_met := false

quality_criteria_met if {
	count(unmet_criteria) == 0
}

# Article 10(4): the deployment setting has to be taken into account.
default setting_considered := false

setting_considered if {
	input.datasets.contextual_characteristics_considered == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	quality_criteria_met
	setting_considered
}

policy_metrics := {
	"article_10_3_criteria_unmet": {
		"name": "Article 10(3) Dataset Criteria Not Met",
		"value": sort([c | some c in unmet_criteria]),
		"control_passed": quality_criteria_met,
	},
	"deployment_setting_considered": {
		"name": "Article 10(4) Geographical, Contextual, Behavioural and Functional Setting Considered",
		"value": object.get(input, ["datasets", "contextual_characteristics_considered"], false),
		"control_passed": setting_considered,
	},
}

report := reporting.compose_report("eu_ai_act.data_governance.data_quality", allow, policy_metrics)
