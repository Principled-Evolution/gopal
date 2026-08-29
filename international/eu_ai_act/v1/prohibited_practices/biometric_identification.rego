# RequiredMetrics:
#   - system.real_time_remote_biometric_identification
#   - system.publicly_accessible_space
#   - system.law_enforcement_purpose
#   - system.permitted_objective
#   - authorisation.prior_authorisation_obtained
#
# RequiredParams: none
package international.eu_ai_act.v1.prohibited_practices.biometric_identification

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "EU AI Act Prohibition of Real-Time Remote Biometric Identification",
	"description": "Evaluates an AI system against the Article 5(1)(h) prohibition on real-time remote biometric identification in publicly accessible spaces for law enforcement. The prohibition admits a closed list of strictly necessary objectives, and where one of those is relied on Article 5(3) still requires prior judicial or independent administrative authorisation. This policy therefore treats a permitted objective without that authorisation as prohibited, which is the case most likely to be got wrong.",
	"version": "1.0.0",
	"category": "International/EU AI Act",
	"references": [
		"Article 5(1)(h) of the EU AI Act, real-time remote biometric identification",
		"Article 5(3) of the EU AI Act, prior authorisation requirement",
		"Recitals 32 to 34 of the EU AI Act",
	],
}

# The closed list of objectives in Article 5(1)(h)(i) to (iii).
permitted_objectives := {
	"targeted_search_for_victims",
	"missing_persons",
	"prevention_of_imminent_threat_to_life",
	"prevention_of_terrorist_attack",
	"localisation_of_suspect_of_serious_crime",
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["system", "real_time_remote_biometric_identification"]) == true
	declarations.resolve(input, ["system", "publicly_accessible_space"]) == true
	declarations.resolve(input, ["system", "law_enforcement_purpose"]) == true
}

default permitted_objective_claimed := false

permitted_objective_claimed if {
	object.get(input, ["system", "permitted_objective"], "") in permitted_objectives
}

# Article 5(3): relying on a permitted objective does not remove the need for
# prior judicial or independent administrative authorisation.
default prior_authorisation_obtained := false

prior_authorisation_obtained if {
	declarations.resolve(input, ["authorisation", "prior_authorisation_obtained"]) == true
}

default prohibited := false

prohibited if {
	in_scope
	not permitted_objective_claimed
}

prohibited if {
	in_scope
	permitted_objective_claimed
	not prior_authorisation_obtained
}

default not_prohibited := false

not_prohibited if {
	not prohibited
}

default assessment_complete := false

assessment_complete if {
	is_boolean(declarations.resolve(input, ["system", "real_time_remote_biometric_identification"]))
	is_boolean(declarations.resolve(input, ["system", "publicly_accessible_space"]))
	is_boolean(declarations.resolve(input, ["system", "law_enforcement_purpose"]))
}

default allow := false

allow if {
	assessment_complete
	not prohibited
}

policy_metrics := {
	"article_5_1_h_engaged": {
		"name": "Real-Time Remote Biometric Identification in a Public Space for Law Enforcement",
		"value": in_scope,
		"control_passed": not_prohibited,
	},
	"permitted_objective": {
		"name": "Article 5(1)(h) Permitted Objective Relied On",
		"value": object.get(input, ["system", "permitted_objective"], "none"),
		"control_passed": not_prohibited,
	},
	"prior_authorisation": {
		"name": "Article 5(3) Prior Judicial or Administrative Authorisation Obtained",
		"value": prior_authorisation_obtained,
		"control_passed": not_prohibited,
	},
	"assessment_complete": {
		"name": "Article 5(1)(h) Assessment Recorded",
		"value": assessment_complete,
		"control_passed": assessment_complete,
	},
}

report := reporting.compose_report("eu_ai_act.prohibited_practices.biometric_identification", allow, policy_metrics)
