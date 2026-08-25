package international.eu_ai_act.v1.prohibited_practices.manipulation_test

import data.international.eu_ai_act.v1.prohibited_practices.manipulation as policy
import rego.v1

clean := {"system": {
	"uses_subliminal_techniques": false,
	"uses_purposefully_manipulative_techniques": false,
	"uses_deceptive_techniques": false,
	"distorts_behaviour": false,
	"causes_or_likely_causes_significant_harm": false,
}}

all_three_limbs := {"system": {
	"uses_subliminal_techniques": true,
	"uses_purposefully_manipulative_techniques": false,
	"uses_deceptive_techniques": false,
	"distorts_behaviour": true,
	"causes_or_likely_causes_significant_harm": true,
}}

test_allow_when_no_limb_is_met if {
	policy.allow with input as clean
}

test_deny_when_all_three_limbs_are_met if {
	not policy.allow with input as all_three_limbs
}

# Article 5(1)(a) is cumulative. A manipulative technique that neither distorts
# behaviour nor causes significant harm is not caught by this prohibition, and
# Recital 29 keeps lawful persuasion outside it.
test_allow_technique_without_distortion_or_harm if {
	policy.allow with input as json.patch(all_three_limbs, [
		{"op": "replace", "path": "/system/distorts_behaviour", "value": false},
		{"op": "replace", "path": "/system/causes_or_likely_causes_significant_harm", "value": false},
	])
}

test_allow_technique_and_distortion_without_significant_harm if {
	policy.allow with input as json.patch(all_three_limbs, [{
		"op": "replace", "path": "/system/causes_or_likely_causes_significant_harm", "value": false,
	}])
}

test_allow_distortion_and_harm_without_a_named_technique if {
	policy.allow with input as json.patch(all_three_limbs, [{
		"op": "replace", "path": "/system/uses_subliminal_techniques", "value": false,
	}])
}

# Each of the three technique classes independently satisfies the first limb.
test_deceptive_technique_satisfies_the_first_limb if {
	not policy.allow with input as json.patch(all_three_limbs, [
		{"op": "replace", "path": "/system/uses_subliminal_techniques", "value": false},
		{"op": "replace", "path": "/system/uses_deceptive_techniques", "value": true},
	])
}

test_purposefully_manipulative_technique_satisfies_the_first_limb if {
	not policy.allow with input as json.patch(all_three_limbs, [
		{"op": "replace", "path": "/system/uses_subliminal_techniques", "value": false},
		{"op": "replace", "path": "/system/uses_purposefully_manipulative_techniques", "value": true},
	])
}

test_report_names_the_declared_technique_classes if {
	report := policy.report with input as json.patch(all_three_limbs, [
		{"op": "replace", "path": "/system/uses_deceptive_techniques", "value": true},
	])
	report.metrics.prohibited_techniques_declared.value == ["deceptive", "subliminal"]
}

# The assessment must be recorded. Silence is not a clean bill of health, which
# matters more here than elsewhere because this is a prohibition.
test_deny_when_assessment_not_recorded if {
	not policy.allow with input as {"system": {"uses_subliminal_techniques": false}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
