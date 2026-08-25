# RequiredMetrics:
#   - decision.significant
#   - decision.meaningful_human_involvement
#   - decision.special_category_data_involved
#   - decision.article_9_condition
#   - safeguards.information_provided
#   - safeguards.representations_enabled
#   - safeguards.human_intervention_available
#   - safeguards.decision_contestable
#
# RequiredParams: none
package international.uk.v1.automated_decision_making

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "UK GDPR Automated Decision-Making (Articles 22A-22D)",
	"description": "Evaluates a significant decision taken about a data subject against the automated decision-making regime substituted into the UK GDPR by section 80 of the Data (Use and Access) Act 2025, in force 5 February 2026. This regime replaced the former Article 22 prohibition with a permission-plus-safeguards model: solely automated significant decisions are permitted for ordinary personal data provided the Article 22C safeguards are in place, while decisions relying on special category data remain restricted and additionally require an Article 9(2) condition.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"UK GDPR Article 22A (meaning of significant decision; based solely on automated processing)",
		"UK GDPR Article 22B (significant decisions involving special category data)",
		"UK GDPR Article 22C (safeguards for significant decisions)",
		"UK GDPR Article 22D (Secretary of State power on meaningful human involvement)",
		"Data (Use and Access) Act 2025, section 80; commencement SI 2026/82",
	],
}

# Article 22A: the regime engages only where the decision is significant and
# there is no meaningful human involvement in taking it.
default solely_automated := false

solely_automated if {
	input.decision.meaningful_human_involvement == false
}

default significant := false

significant if {
	input.decision.significant == true
}

default in_scope := false

in_scope if {
	significant
	solely_automated
}

default special_category_involved := false

special_category_involved if {
	input.decision.special_category_data_involved == true
}

# Article 22C: the safeguards must, at a minimum, give the data subject
# information about the decision, let them make representations, let them obtain
# human intervention, and let them contest the decision.
default safeguards_in_place := false

safeguards_in_place if {
	input.safeguards.information_provided == true
	input.safeguards.representations_enabled == true
	input.safeguards.human_intervention_available == true
	input.safeguards.decision_contestable == true
}

# Article 9(2) condition, required where special category data is relied on.
default article_9_condition_met := false

article_9_condition_met if {
	object.get(input, ["decision", "article_9_condition"], "") != ""
}

# Scope has to be asserted, not inferred from silence. Without both Article 22A
# facts the policy cannot tell whether the regime engages, and defaults to deny
# rather than reading missing data as "out of scope".
default scope_determined := false

scope_determined if {
	is_boolean(input.decision.significant)
	is_boolean(input.decision.meaningful_human_involvement)
}

default allow := false

# Out of scope: the decision is not significant, or a human was meaningfully
# involved in taking it.
allow if {
	scope_determined
	not in_scope
}

# Ordinary personal data: permitted with the Article 22C safeguards.
allow if {
	scope_determined
	in_scope
	not special_category_involved
	safeguards_in_place
}

# Special category data: restricted under Article 22B, so an Article 9(2)
# condition is required in addition to the safeguards.
allow if {
	scope_determined
	in_scope
	special_category_involved
	article_9_condition_met
	safeguards_in_place
}

missing_safeguards := [name |
	some name, key in {
		"information about the decision": "information_provided",
		"ability to make representations": "representations_enabled",
		"ability to obtain human intervention": "human_intervention_available",
		"ability to contest the decision": "decision_contestable",
	}
	object.get(input, ["safeguards", key], false) != true
]

policy_metrics := {
	"scope_determined": {
		"name": "Article 22A Scope Facts Asserted",
		"value": scope_determined,
		"control_passed": scope_determined,
	},
	"regime_engaged": {
		"name": "Article 22A Regime Engaged (Significant and Solely Automated)",
		"value": in_scope,
		"control_passed": true,
	},
	"article_22c_safeguards": {
		"name": "Article 22C Safeguards Missing",
		"value": sort(missing_safeguards),
		"control_passed": safeguards_in_place,
	},
	"special_category_restriction": {
		"name": "Article 22B Special Category Condition Satisfied Where Required",
		"value": object.get(input, ["decision", "article_9_condition"], "none"),
		"control_passed": allow,
	},
}

report := reporting.compose_report("uk.automated_decision_making", allow, policy_metrics)
