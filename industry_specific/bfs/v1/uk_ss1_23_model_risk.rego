# RequiredMetrics:
#   - model.in_inventory
#   - model.risk_tier
#   - governance.smf_owner_assigned
#   - development.rationale_documented
#   - validation.independent_validation_completed
#   - mitigants.limitations_documented
#
# RequiredParams: none
package industry_specific.bfs.v1.uk_ss1_23_model_risk

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "PRA SS1/23 Model Risk Management (UK Banks)",
	"description": "Evaluates an AI or machine-learning model against the five principles of PRA supervisory statement SS1/23, effective 17 May 2024. SS1/23 expressly extends to modelling techniques using AI, so a firm that has not brought its AI models inside its model risk management framework has a supervisory gap rather than a separate AI problem. Validation expectations are proportionate to the assigned risk tier, and vendor-supplied models are in scope.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"PRA SS1/23, Model risk management principles for banks (May 2023, effective 17 May 2024)",
		"SS1/23 Principle 1, model identification and model risk classification",
		"SS1/23 Principle 2, governance",
		"SS1/23 Principle 3, model development, implementation and use",
		"SS1/23 Principle 4, independent model validation",
		"SS1/23 Principle 5, model risk mitigants",
	],
}

high_risk_tiers := {"high", "1"}

# Principle 1: the model is inventoried and given a risk classification.
default principle_1_identification := false

principle_1_identification if {
	declarations.resolve(input, ["model", "in_inventory"]) == true
	object.get(input, ["model", "risk_tier"], "") != ""
}

# Principle 2: responsibility for the framework sits with a named Senior
# Management Function holder, with an approved policy and board reporting.
default principle_2_governance := false

principle_2_governance if {
	declarations.resolve(input, ["governance", "smf_owner_assigned"]) == true
	declarations.resolve(input, ["governance", "mrm_policy_approved"]) == true
	declarations.resolve(input, ["governance", "board_reporting_in_place"]) == true
}

# Principle 3: development, implementation and use are documented.
default principle_3_development := false

principle_3_development if {
	declarations.resolve(input, ["development", "rationale_documented"]) == true
	declarations.resolve(input, ["development", "data_quality_assessed"]) == true
	declarations.resolve(input, ["development", "testing_documented"]) == true
}

# Principle 4: validation is independent of development. A vendor model still
# needs tailored validation documentation; the vendor's own testing is not it.
default principle_4_validation := false

principle_4_validation if {
	declarations.resolve(input, ["validation", "independent_validation_completed"]) == true
	declarations.resolve(input, ["validation", "validator_independent_of_development"]) == true
	validation_current
}

default validation_current := false

# High-tier models are expected to be revalidated at least annually.
validation_current if {
	high_risk_tier
	object.get(input, ["validation", "last_validation_days_ago"], 99999) <= 365
}

validation_current if {
	not high_risk_tier
	object.get(input, ["validation", "last_validation_days_ago"], 99999) <= 1095
}

default high_risk_tier := false

high_risk_tier if {
	object.get(input, ["model", "risk_tier"], "") in high_risk_tiers
}

# Principle 5: known limitations and any post-model adjustments are tracked,
# with ongoing monitoring in place.
default principle_5_mitigants := false

principle_5_mitigants if {
	declarations.resolve(input, ["mitigants", "limitations_documented"]) == true
	declarations.resolve(input, ["mitigants", "post_model_adjustments_tracked"]) == true
	declarations.resolve(input, ["mitigants", "ongoing_monitoring_in_place"]) == true
}

default allow := false

allow if {
	principle_1_identification
	principle_2_governance
	principle_3_development
	principle_4_validation
	principle_5_mitigants
}

failed_principles := [name |
	some name, satisfied in {
		"Principle 1 - model identification and risk classification": principle_1_identification,
		"Principle 2 - governance": principle_2_governance,
		"Principle 3 - development, implementation and use": principle_3_development,
		"Principle 4 - independent model validation": principle_4_validation,
		"Principle 5 - model risk mitigants": principle_5_mitigants,
	}
	satisfied == false
]

policy_metrics := {
	"ss1_23_principles_failed": {
		"name": "SS1/23 Principles Not Satisfied",
		"value": sort(failed_principles),
		"control_passed": count(failed_principles) == 0,
	},
	"ai_model_inside_mrm_framework": {
		"name": "AI/ML Model Brought Inside the MRM Framework",
		"value": object.get(input, ["model", "is_ai_ml"], false),
		"control_passed": principle_1_identification,
	},
	"validation_proportionate_to_tier": {
		"name": "Independent Validation Current for the Assigned Risk Tier",
		"value": object.get(input, ["model", "risk_tier"], "unclassified"),
		"control_passed": principle_4_validation,
	},
}

report := reporting.compose_report("bfs.uk_ss1_23_model_risk", allow, policy_metrics)
