# RequiredMetrics:
#   - system.performs_biometric_categorisation
#   - system.inferred_attributes
#   - system.dataset_labelling_only
#   - system.law_enforcement_use
#
# RequiredParams: none
package international.eu_ai_act.v1.prohibited_practices.biometric_categorization

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Prohibition of Sensitive Biometric Categorisation",
	"description": "Evaluates an AI system against the Article 5(1)(g) prohibition on biometric categorisation that deduces or infers race, political opinions, trade union membership, religious or philosophical beliefs, sex life or sexual orientation. Article 5(1)(g) exempts the labelling or filtering of lawfully acquired biometric datasets and categorisation of biometric data in the area of law enforcement, so both exemptions are explicit conditions here.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 5(1)(g) of the EU AI Act, biometric categorisation deducing sensitive attributes",
		"Recital 30 of the EU AI Act",
	],
}

# The sensitive attributes enumerated in Article 5(1)(g).
sensitive_attributes := {
	"race",
	"political_opinions",
	"trade_union_membership",
	"religious_or_philosophical_beliefs",
	"sex_life",
	"sexual_orientation",
}

inferred_sensitive contains attr if {
	some attr in object.get(input, ["system", "inferred_attributes"], [])
	attr in sensitive_attributes
}

default categorises_biometrically := false

categorises_biometrically if {
	declarations.resolve(input, ["system", "performs_biometric_categorisation"]) == true
}

default infers_sensitive_attribute := false

infers_sensitive_attribute if {
	count(inferred_sensitive) > 0
}

# Article 5(1)(g) exemptions.
default exemption_applies := false

exemption_applies if {
	declarations.resolve(input, ["system", "dataset_labelling_only"]) == true
}

exemption_applies if {
	declarations.resolve(input, ["system", "law_enforcement_use"]) == true
}

default prohibited := false

prohibited if {
	categorises_biometrically
	infers_sensitive_attribute
	not exemption_applies
}

default not_prohibited := false

not_prohibited if {
	not prohibited
}

default assessment_complete := false

assessment_complete if {
	is_boolean(declarations.resolve(input, ["system", "performs_biometric_categorisation"]))
}

default allow := false

allow if {
	assessment_complete
	not prohibited
}

policy_metrics := {
	"sensitive_attributes_inferred": {
		"name": "Article 5(1)(g) Sensitive Attributes Inferred",
		"value": sort([a | some a in inferred_sensitive]),
		"control_passed": not_prohibited,
	},
	"biometric_categorisation": {
		"name": "Performs Biometric Categorisation",
		"value": categorises_biometrically,
		"control_passed": not_prohibited,
	},
	"exemption_applies": {
		"name": "Dataset Labelling or Law Enforcement Exemption Applies",
		"value": exemption_applies,
		"control_passed": not_prohibited,
	},
	"assessment_complete": {
		"name": "Article 5(1)(g) Assessment Recorded",
		"value": assessment_complete,
		"control_passed": assessment_complete,
	},
}

report := reporting.compose_report("eu_ai_act.prohibited_practices.biometric_categorization", allow, policy_metrics)
