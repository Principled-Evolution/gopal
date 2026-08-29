# RequiredMetrics:
#   - operation.category
#   - operator.registered
#   - aircraft.class_marking
#   - authorization.granted
#
# RequiredParams: none
package international.easa.v1.regulation_2019_947

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EASA Regulation 2019/947 - Rules for UAS Operation",
	"description": "Evaluates UAS operations against the Open, Specific, and Certified category requirements of Commission Implementing Regulation (EU) 2019/947.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"Commission Implementing Regulation (EU) 2019/947, Annex Part A (Open category), Part B (Specific category)",
	],
}

default allow := false

allow if {
	declarations.resolve(input, ["operation", "category"]) == "open"
	declarations.resolve(input, ["operator", "registered"]) == true
	declarations.resolve(input, ["aircraft", "class_marking"]) in {"C0", "C1", "C2", "C3", "C4"}
}

allow if {
	declarations.resolve(input, ["operation", "category"]) == "specific"
	declarations.resolve(input, ["operator", "registered"]) == true
	declarations.resolve(input, ["authorization", "granted"]) == true
}

allow if {
	declarations.resolve(input, ["operation", "category"]) == "certified"
	declarations.resolve(input, ["operator", "registered"]) == true
	declarations.resolve(input, ["aircraft", "type_certificate_held"]) == true
}

policy_metrics := {
	"operator_registered": {
		"name": "Operator Registered",
		"value": object.get(input.operator, "registered", false),
		"control_passed": object.get(input.operator, "registered", false) == true,
	},
	"category_requirements_met": {
		"name": "Category-Specific Requirements Met",
		"value": allow,
		"control_passed": allow,
	},
}

report := reporting.compose_report("easa.regulation_2019_947", allow, policy_metrics)
