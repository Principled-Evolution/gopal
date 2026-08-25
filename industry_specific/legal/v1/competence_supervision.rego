# RequiredMetrics:
#   - practitioner.technology_competence_maintained
#   - practitioner.training_completed
#   - firm.ai_risk_assessment_before_adoption
#   - firm.supervision_system_in_place
#   - firm.supervisor_named
#   - client.ai_use_disclosed_where_material
#
# RequiredParams: none
package industry_specific.legal.v1.competence_supervision

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Competence, Supervision and Client Disclosure for Legal AI Use",
	"description": "Evaluates the governance around a legal practitioner's use of AI. The regulators do not require expertise in the technology, but they do require enough competence to understand what the tools in a workflow actually do, a risk assessment before adoption, an effective supervision system with a named supervisor, and disclosure to the client where the use of AI is material. Managers remain accountable for the output of those they supervise however it was produced.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"BSB Handbook Core Duty 7, competence; Bar Standards Board guidance on AI (18 May 2026)",
		"SRA Code of Conduct for Solicitors, paragraphs 3.2 (competent service) and 3.5 (effective supervision)",
		"SRA Code of Conduct for Firms, paragraphs 2.1, 4.3 and 4.4 (governance and supervision)",
		"SRA warning notice, misuse of AI (August 2026)",
	],
}

default scope_determined := false

scope_determined if {
	is_boolean(input.practitioner.uses_ai_for_regulated_work)
}

default in_scope := false

in_scope if {
	input.practitioner.uses_ai_for_regulated_work == true
}

default competence_maintained := false

competence_maintained if {
	input.practitioner.technology_competence_maintained == true
	input.practitioner.training_completed == true
}

default assessed_before_adoption := false

assessed_before_adoption if {
	input.firm.ai_risk_assessment_before_adoption == true
}

# Supervision has to be a system with someone named in it, not an aspiration.
default supervision_effective := false

supervision_effective if {
	input.firm.supervision_system_in_place == true
	input.firm.supervisor_named == true
}

default client_informed := false

client_informed if {
	input.client.ai_use_material == false
}

client_informed if {
	input.client.ai_use_material == true
	input.client.ai_use_disclosed_where_material == true
}

default allow := false

allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	competence_maintained
	assessed_before_adoption
	supervision_effective
	client_informed
}

failed_controls := [name |
	some name, satisfied in {
		"technology competence and training": competence_maintained,
		"risk assessment before adoption": assessed_before_adoption,
		"effective supervision with a named supervisor": supervision_effective,
		"client disclosure where AI use is material": client_informed,
	}
	satisfied == false
]

policy_metrics := {
	"governance_controls_failed": {
		"name": "Competence and Supervision Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"named_supervisor": {
		"name": "Named Supervisor for AI-Assisted Regulated Work",
		"value": object.get(input, ["firm", "supervisor_named"], false),
		"control_passed": supervision_effective,
	},
}

report := reporting.compose_report("legal.competence_supervision", allow, policy_metrics)
