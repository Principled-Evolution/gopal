package industry_specific.bfs.v1.model_risk_test

import data.industry_specific.bfs.v1.model_risk as policy
import rego.v1

compliant := {
	"model": {"in_inventory": true, "risk_rating": "high"},
	"governance": {"board_approved_policy": true, "owner_named": true},
	"development": {"conceptual_soundness_documented": true},
	"data": {"lineage_documented": true},
	"validation": {
		"independent_review_completed": true,
		"outcomes_analysis_performed": true,
		"last_review_days_ago": 90,
	},
	"monitoring": {"ongoing_monitoring_in_place": true},
}

test_allow_when_all_pillars_satisfied if {
	policy.allow with input as compliant
}

test_deny_when_model_not_in_inventory if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/model/in_inventory", "value": false,
	}])
}

test_deny_when_unrated if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/model/risk_rating", "value": "",
	}])
}

test_deny_without_board_approved_policy if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/governance/board_approved_policy", "value": false,
	}])
}

# BCBS 239: the data feeding the model needs known lineage.
test_deny_without_data_lineage if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/data/lineage_documented", "value": false,
	}])
}

# SR 11-7 treats conceptual soundness review and outcomes analysis as distinct
# validation activities. Doing one is not doing both.
test_deny_without_outcomes_analysis if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/validation/outcomes_analysis_performed", "value": false,
	}])
}

test_deny_without_independent_review if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/validation/independent_review_completed", "value": false,
	}])
}

# Review cadence scales with the risk rating.
test_deny_high_rated_model_with_stale_review if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/validation/last_review_days_ago", "value": 500,
	}])
}

test_allow_low_rated_model_with_same_review_age if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/risk_rating", "value": "low"},
		{"op": "replace", "path": "/validation/last_review_days_ago", "value": 500},
	])
}

test_risk_rating_matching_is_case_insensitive if {
	not policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/risk_rating", "value": "HIGH"},
		{"op": "replace", "path": "/validation/last_review_days_ago", "value": 500},
	])
}

# A missing review date must not read as recently reviewed.
test_deny_when_review_date_absent if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "remove", "path": "/validation/last_review_days_ago",
	}])
}

test_deny_without_ongoing_monitoring if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/monitoring/ongoing_monitoring_in_place", "value": false,
	}])
}

test_report_names_the_failed_pillars if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/model/in_inventory", "value": false},
		{"op": "replace", "path": "/monitoring/ongoing_monitoring_in_place", "value": false},
	])
	report.metrics.model_risk_pillars_failed.value == [
		"model identification and risk rating",
		"ongoing monitoring",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
