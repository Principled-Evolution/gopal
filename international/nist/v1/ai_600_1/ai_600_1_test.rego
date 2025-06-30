package international.nist.v1.ai_600_1_test

import rego.v1
import data.international.nist.v1.ai_600_1

# Helper function to create valid input
valid_input := {
	"governance": {
		"roles_and_responsibilities_defined": true,
		"oversight_mechanisms_in_place": true,
	},
	"transparency": {
		"public_documentation_available": true,
		"decision_explanations_provided": true,
	},
	"fairness": {
		"bias_assessments_conducted": true,
		"bias_mitigation_strategies_in_place": true,
	},
	"map": {
		"intended_use_documented": true,
		"architecture_documented": true,
		"data_sources_documented": true,
		"data_processing_documented": true,
		"known_limitations_documented": true,
		"out_of_scope_use_cases_documented": true,
	},
	"measure": {
		"performance_metrics_defined": true,
		"performance_metrics_tracked": true,
		"bias_metrics_defined": true,
		"bias_metrics_tracked": true,
		"robustness_metrics_defined": true,
		"robustness_metrics_tracked": true,
	},
	"manage": {
		"risk_mitigation_strategies_documented": true,
		"risk_mitigation_strategies_implemented": true,
		"continuous_monitoring_plan_in_place": true,
		"continuous_monitoring_plan_executed": true,
		"incident_response_plan_in_place": true,
		"incident_response_plan_tested": true,
	},
}

test_allow_with_valid_input if {
	ai_600_1.allow with input as valid_input
}

test_deny_missing_governance if {
	not ai_600_1.allow with input as object.remove(valid_input, ["governance"])
}
