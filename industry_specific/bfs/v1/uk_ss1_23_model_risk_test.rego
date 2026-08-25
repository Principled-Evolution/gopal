package industry_specific.bfs.v1.uk_ss1_23_model_risk_test

import data.industry_specific.bfs.v1.uk_ss1_23_model_risk as policy
import rego.v1

compliant := {
	"model": {"id": "credit-scorecard-3", "in_inventory": true, "risk_tier": "high", "is_ai_ml": true, "vendor_supplied": false},
	"governance": {"smf_owner_assigned": true, "mrm_policy_approved": true, "board_reporting_in_place": true},
	"development": {"rationale_documented": true, "data_quality_assessed": true, "testing_documented": true},
	"validation": {"independent_validation_completed": true, "validator_independent_of_development": true, "last_validation_days_ago": 120},
	"mitigants": {"limitations_documented": true, "post_model_adjustments_tracked": true, "ongoing_monitoring_in_place": true},
}

test_allow_when_all_five_principles_satisfied if {
	policy.allow with input as compliant
}

# Principle 1: an AI model outside the inventory is the supervisory gap SS1/23
# is aimed at.
test_deny_when_model_not_in_inventory if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/model/in_inventory", "value": false,
	}])
}

test_deny_when_risk_tier_unclassified if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/model/risk_tier", "value": "",
	}])
}

test_deny_without_smf_owner if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/governance/smf_owner_assigned", "value": false,
	}])
}

# Principle 4: validation by the team that built the model is not independent.
test_deny_when_validator_not_independent if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/validation/validator_independent_of_development", "value": false,
	}])
}

# Validation recency is proportionate to tier: 800 days is stale for a
# high-tier model but acceptable for a lower-tier one.
test_deny_high_tier_with_stale_validation if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/validation/last_validation_days_ago", "value": 800,
	}])
}

test_allow_low_tier_with_same_validation_age if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/risk_tier", "value": "low"},
		{"op": "replace", "path": "/validation/last_validation_days_ago", "value": 800},
	])
}

test_deny_low_tier_beyond_three_years if {
	not policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/risk_tier", "value": "low"},
		{"op": "replace", "path": "/validation/last_validation_days_ago", "value": 1200},
	])
}

# A missing validation date must not read as recently validated.
test_deny_when_validation_date_absent if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/validation/last_validation_days_ago",
	}])
}

test_deny_without_mitigants if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/mitigants/ongoing_monitoring_in_place", "value": false,
	}])
}

test_report_names_the_failed_principles if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/in_inventory", "value": false},
		{"op": "replace", "path": "/governance/smf_owner_assigned", "value": false},
	])
	report.metrics.ss1_23_principles_failed.value == [
		"Principle 1 - model identification and risk classification",
		"Principle 2 - governance",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
