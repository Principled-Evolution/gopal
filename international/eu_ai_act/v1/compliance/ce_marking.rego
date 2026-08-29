# RequiredMetrics:
#   - system.high_risk
#   - system.digital_only
#   - ce_marking.affixed
#   - ce_marking.visible_legible_indelible
#   - ce_marking.digital_marking_accessible
#   - ce_marking.notified_body_involved
#   - ce_marking.notified_body_number_displayed
#
# RequiredParams: none
package international.eu_ai_act.v1.compliance.ce_marking

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act CE Marking (Article 48)",
	"description": "Evaluates the CE marking on a high-risk AI system. Two conditional requirements sit inside Article 48 and are treated as such here: where the system is provided digitally the marking must be accessible digitally rather than physically, and where a notified body was involved in the conformity assessment its identification number must appear alongside the marking. A marking affixed without that number, where a notified body was used, is incomplete.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 48 of the EU AI Act, CE marking",
		"Article 48(2), digital CE marking",
		"Article 48(4), identification number of the notified body",
	],
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "high_risk"]) == true
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["system", "high_risk"]))
}

default marking_affixed := false

marking_affixed if {
	declarations.resolve(input, ["ce_marking", "affixed"]) == true
}

# Article 48(2): physical marking for physical systems, digital for digital.
default digital_only := false

digital_only if {
	declarations.resolve(input, ["system", "digital_only"]) == true
}

default marking_presented_correctly := false

marking_presented_correctly if {
	not digital_only
	declarations.resolve(input, ["ce_marking", "visible_legible_indelible"]) == true
}

marking_presented_correctly if {
	digital_only
	declarations.resolve(input, ["ce_marking", "digital_marking_accessible"]) == true
}

# Article 48(4): the notified body number is required where one was involved.
default notified_body_involved := false

notified_body_involved if {
	declarations.resolve(input, ["ce_marking", "notified_body_involved"]) == true
}

default notified_body_number_ok := false

notified_body_number_ok if {
	not notified_body_involved
}

notified_body_number_ok if {
	notified_body_involved
	declarations.resolve(input, ["ce_marking", "notified_body_number_displayed"]) == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	marking_affixed
	marking_presented_correctly
	notified_body_number_ok
}

policy_metrics := {
	"marking_affixed": {
		"name": "CE Marking Affixed",
		"value": marking_affixed,
		"control_passed": marking_affixed,
	},
	"presentation_correct_for_delivery_form": {
		"name": "Marking Presented Correctly for a Physical or Digital System",
		"value": digital_only,
		"control_passed": marking_presented_correctly,
	},
	"notified_body_number": {
		"name": "Article 48(4) Notified Body Identification Number Displayed Where Required",
		"value": notified_body_involved,
		"control_passed": notified_body_number_ok,
	},
}

report := reporting.compose_report("eu_ai_act.compliance.ce_marking", allow, policy_metrics)
