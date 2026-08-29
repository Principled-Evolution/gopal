# RequiredMetrics:
#   - budget.defined
#   - budget.utilisation_ratio
#   - monitoring.spend_tracked
#   - monitoring.alerting_configured
#   - monitoring.unit_cost_attributable
#   - efficiency.right_sizing_reviewed_days_ago
#
# RequiredParams: none
package operational.cost.v1.resource_efficiency

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "AI Resource Efficiency Requirements",
	"description": "Evaluates cost control around an AI system. The distinguishing risk for inference workloads is that spend scales with usage rather than with provisioned capacity, so an unbounded budget fails silently and only shows up on an invoice. This policy requires a defined budget with utilisation inside it, spend tracked and alerted on, cost attributable to a unit of work, and a recent right-sizing review.",
	"version": "1.0.0",
	"category": "Operational",
	"references": [
		"FinOps Foundation, FinOps for AI",
		"NIST AI RMF 1.0, Manage 2.2 (resourcing)",
	],
}

default budget_defined := false

budget_defined if {
	declarations.resolve(input, ["budget", "defined"]) == true
}

# Utilisation at or over 1.0 means the budget is already exceeded.
default within_budget := false

within_budget if {
	ratio := object.get(input, ["budget", "utilisation_ratio"], 99)
	ratio >= 0
	ratio < 1.0
}

default spend_observable := false

spend_observable if {
	declarations.resolve(input, ["monitoring", "spend_tracked"]) == true
	declarations.resolve(input, ["monitoring", "alerting_configured"]) == true
}

# Without unit cost attribution there is no way to tell an efficiency
# regression from a growth in usage.
default unit_cost_attributable := false

unit_cost_attributable if {
	declarations.resolve(input, ["monitoring", "unit_cost_attributable"]) == true
}

default right_sizing_current := false

right_sizing_current if {
	object.get(input, ["efficiency", "right_sizing_reviewed_days_ago"], 99999) <= 180
}

default allow := false

allow if {
	budget_defined
	within_budget
	spend_observable
	unit_cost_attributable
	right_sizing_current
}

failed_controls := [name |
	some name, satisfied in {
		"budget defined": budget_defined,
		"utilisation within budget": within_budget,
		"spend tracked and alerting configured": spend_observable,
		"cost attributable to a unit of work": unit_cost_attributable,
		"right-sizing reviewed within 180 days": right_sizing_current,
	}
	satisfied == false
]

policy_metrics := {
	"cost_controls_failed": {
		"name": "Resource Efficiency Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"budget_utilisation_ratio": {
		"name": "Budget Utilisation Ratio",
		"value": object.get(input, ["budget", "utilisation_ratio"], -1),
		"control_passed": within_budget,
	},
	"unit_cost_attributable": {
		"name": "Cost Attributable to a Unit of Work",
		"value": object.get(input, ["monitoring", "unit_cost_attributable"], false),
		"control_passed": unit_cost_attributable,
	},
}

report := reporting.compose_report("cost.resource_efficiency", allow, policy_metrics)
