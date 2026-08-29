# RequiredMetrics:
#   - model.in_inventory
#   - model.risk_rating
#   - governance.board_approved_policy
#   - governance.owner_named
#   - development.conceptual_soundness_documented
#   - validation.independent_review_completed
#   - validation.outcomes_analysis_performed
#   - monitoring.ongoing_monitoring_in_place
#   - data.lineage_documented
#
# RequiredParams: none
package industry_specific.bfs.v1.model_risk

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Model Risk Management for AI Models (SR 11-7 / OCC 2011-12 / BCBS 239)",
	"description": "Evaluates an AI or machine-learning model against the US supervisory expectations for model risk management in SR 11-7 and OCC 2011-12, together with the risk data aggregation expectations in BCBS 239. SR 11-7 rests on three pillars: robust model development and implementation, independent validation covering conceptual soundness and outcomes analysis, and governance with policies and controls. For the equivalent UK expectations see uk_ss1_23_model_risk in this directory.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"Federal Reserve SR 11-7, Supervisory Guidance on Model Risk Management",
		"OCC Bulletin 2011-12, Sound Practices for Model Risk Management",
		"BCBS 239, Principles for effective risk data aggregation and risk reporting",
	],
}

high_risk_ratings := {"high", "1", "tier1", "tier 1"}

# SR 11-7 expects a complete inventory with a risk rating driving the intensity
# of the controls applied.
default identified := false

identified if {
	declarations.resolve(input, ["model", "in_inventory"]) == true
	object.get(input, ["model", "risk_rating"], "") != ""
}

# Governance: board-approved policy and a named owner accountable for the model.
default governed := false

governed if {
	declarations.resolve(input, ["governance", "board_approved_policy"]) == true
	declarations.resolve(input, ["governance", "owner_named"]) == true
}

# Development and implementation: the conceptual soundness of the approach is
# documented, and BCBS 239 expects the data feeding it to have known lineage.
default developed := false

developed if {
	declarations.resolve(input, ["development", "conceptual_soundness_documented"]) == true
	declarations.resolve(input, ["data", "lineage_documented"]) == true
}

# Validation: SR 11-7 names conceptual soundness review and outcomes analysis as
# distinct activities, and expects the reviewer to be independent.
default validated := false

validated if {
	declarations.resolve(input, ["validation", "independent_review_completed"]) == true
	declarations.resolve(input, ["validation", "outcomes_analysis_performed"]) == true
	validation_current
}

default validation_current := false

# High-rated models are expected to be reviewed at least annually.
validation_current if {
	high_risk_rating
	object.get(input, ["validation", "last_review_days_ago"], 99999) <= 365
}

validation_current if {
	not high_risk_rating
	object.get(input, ["validation", "last_review_days_ago"], 99999) <= 1095
}

default high_risk_rating := false

high_risk_rating if {
	lower(object.get(input, ["model", "risk_rating"], "")) in high_risk_ratings
}

# Ongoing monitoring is the control that catches drift after go-live.
default monitored := false

monitored if {
	declarations.resolve(input, ["monitoring", "ongoing_monitoring_in_place"]) == true
}

default allow := false

allow if {
	identified
	governed
	developed
	validated
	monitored
}

failed_pillars := [name |
	some name, satisfied in {
		"model identification and risk rating": identified,
		"governance, policy and named ownership": governed,
		"development, conceptual soundness and data lineage": developed,
		"independent validation and outcomes analysis": validated,
		"ongoing monitoring": monitored,
	}
	satisfied == false
]

policy_metrics := {
	"model_risk_pillars_failed": {
		"name": "Model Risk Management Pillars Not Satisfied",
		"value": sort(failed_pillars),
		"control_passed": count(failed_pillars) == 0,
	},
	"validation_current_for_rating": {
		"name": "Independent Validation Current for the Assigned Risk Rating",
		"value": object.get(input, ["model", "risk_rating"], "unrated"),
		"control_passed": validated,
	},
	"outcomes_analysis": {
		"name": "Outcomes Analysis Performed (SR 11-7 Validation Element)",
		"value": object.get(input, ["validation", "outcomes_analysis_performed"], false),
		"control_passed": validated,
	},
}

report := reporting.compose_report("bfs.model_risk", allow, policy_metrics)
