# RequiredMetrics:
#   - system.high_risk
#   - logs.retained
#   - logs.retention_months
#   - logs.role
#
# RequiredParams: none
package international.eu_ai_act.v1.documentation.record_keeping

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Log Retention (Articles 19 and 26(6))",
	"description": "Evaluates whether logs generated under Article 12 are retained for the period the Act requires. Both providers under Article 19 and deployers under Article 26(6) must keep the logs for at least six months, unless a longer period applies under Union or national law. A system that generates logs but discards them fails this even though its logging capability is present.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 19 of the EU AI Act, automatically generated logs kept by providers",
		"Article 26(6) of the EU AI Act, logs kept by deployers",
		"Article 12 of the EU AI Act, record-keeping",
	],
}

minimum_retention_months := 6

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

default logs_retained := false

logs_retained if {
	declarations.resolve(input, ["logs", "retained"]) == true
}

# At least six months, or longer where sectoral law requires it.
default retention_sufficient := false

retention_sufficient if {
	object.get(input, ["logs", "retention_months"], 0) >= required_months
}

required_months := months if {
	months := object.get(input, ["logs", "sectoral_minimum_months"], minimum_retention_months)
	months > minimum_retention_months
} else := minimum_retention_months

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	logs_retained
	retention_sufficient
}

policy_metrics := {
	"logs_retained": {
		"name": "Automatically Generated Logs Are Retained",
		"value": logs_retained,
		"control_passed": logs_retained,
	},
	"retention_months": {
		"name": "Log Retention Period (Months)",
		"value": object.get(input, ["logs", "retention_months"], 0),
		"control_passed": retention_sufficient,
	},
	"required_months": {
		"name": "Required Retention Period (Months)",
		"value": required_months,
		"control_passed": retention_sufficient,
	},
}

report := reporting.compose_report("eu_ai_act.documentation.record_keeping", allow, policy_metrics)
