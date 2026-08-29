# RequiredMetrics:
#   - system.uses_subliminal_techniques
#   - system.uses_purposefully_manipulative_techniques
#   - system.uses_deceptive_techniques
#   - system.distorts_behaviour
#   - system.causes_or_likely_causes_significant_harm
#
# RequiredParams: none
package international.eu_ai_act.v1.prohibited_practices.manipulation

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Prohibition of Manipulative Techniques",
	"description": "Evaluates an AI system against the Article 5(1)(a) prohibition on subliminal, purposefully manipulative or deceptive techniques. The prohibition is cumulative: a technique is banned where it materially distorts behaviour in a way that impairs informed decision-making AND causes or is reasonably likely to cause significant harm. Recital 29 excludes lawful persuasion that does not deploy such techniques, so ordinary advertising is not caught by this rule.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 5(1)(a) of the EU AI Act, prohibited AI practices",
		"Recital 29 of the EU AI Act",
		"Regulation (EU) 2024/1689",
	],
}

# The three technique classes named in Article 5(1)(a).
technique_fields := {
	"subliminal": "uses_subliminal_techniques",
	"purposefully manipulative": "uses_purposefully_manipulative_techniques",
	"deceptive": "uses_deceptive_techniques",
}

# Inside the comprehension an absent field simply fails the body, so a
# technique that was never declared is not listed as present.
techniques_present := [label |
	some label, field in technique_fields
	input.system[field] == true
]

default uses_prohibited_technique := false

uses_prohibited_technique if {
	count(techniques_present) > 0
}

default distorts_behaviour := false

distorts_behaviour if {
	declarations.resolve(input, ["system", "distorts_behaviour"]) == true
}

default causes_significant_harm := false

causes_significant_harm if {
	declarations.resolve(input, ["system", "causes_or_likely_causes_significant_harm"]) == true
}

# Article 5(1)(a) bites only when all three limbs are met together.
default prohibited := false

prohibited if {
	uses_prohibited_technique
	distorts_behaviour
	causes_significant_harm
}

# The assessment has to be made rather than left blank.
default assessment_complete := false

assessment_complete if {
	is_boolean(declarations.resolve(input, ["system", "distorts_behaviour"]))
	is_boolean(declarations.resolve(input, ["system", "causes_or_likely_causes_significant_harm"]))
}

# `not` is a statement rather than an expression, so the negations a report
# metric needs are expressed as rules.
default no_prohibited_technique := false

no_prohibited_technique if {
	not uses_prohibited_technique
}

default no_behavioural_distortion := false

no_behavioural_distortion if {
	not distorts_behaviour
}

default no_significant_harm := false

no_significant_harm if {
	not causes_significant_harm
}

default allow := false

allow if {
	assessment_complete
	not prohibited
}

policy_metrics := {
	"prohibited_techniques_declared": {
		"name": "Article 5(1)(a) Technique Classes Declared",
		"value": sort(techniques_present),
		"control_passed": no_prohibited_technique,
	},
	"behavioural_distortion": {
		"name": "Materially Distorts Behaviour Impairing Informed Decisions",
		"value": distorts_behaviour,
		"control_passed": no_behavioural_distortion,
	},
	"significant_harm": {
		"name": "Causes or Is Reasonably Likely to Cause Significant Harm",
		"value": causes_significant_harm,
		"control_passed": no_significant_harm,
	},
	"assessment_complete": {
		"name": "Article 5(1)(a) Assessment Recorded",
		"value": assessment_complete,
		"control_passed": assessment_complete,
	},
}

report := reporting.compose_report("eu_ai_act.prohibited_practices.manipulation", allow, policy_metrics)
