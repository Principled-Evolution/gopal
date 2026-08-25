# RequiredMetrics:
#   - access.least_privilege_enforced
#   - access.authentication_required
#   - data.encrypted_in_transit
#   - data.encrypted_at_rest
#   - secrets.managed_outside_prompts
#   - resilience.prompt_injection_controls_in_place
#   - logging.security_events_logged
#   - vulnerability.review_days_ago
#
# RequiredParams: none
package operational.corporate.v1.infosec

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Corporate Information Security Requirements for AI",
	"description": "Evaluates the information security controls around an AI system. Alongside the conventional controls of authentication, least privilege, encryption in transit and at rest, and security event logging, this policy tests two that are specific to AI systems: secrets must be managed outside prompts and context windows, and controls against prompt injection must exist where untrusted input reaches a model.",
	"version": "1.0.0",
	"category": "Operational",
	"references": [
		"ISO/IEC 27001:2022, information security management",
		"NIST AI RMF 1.0, Manage function",
		"OWASP Top 10 for Large Language Model Applications",
	],
}

default access_controlled := false

access_controlled if {
	input.access.least_privilege_enforced == true
	input.access.authentication_required == true
}

default data_encrypted := false

data_encrypted if {
	input.data.encrypted_in_transit == true
	input.data.encrypted_at_rest == true
}

# A credential pasted into a prompt is in the context window, the provider's
# logs, and any transcript retained downstream.
default secrets_managed := false

secrets_managed if {
	input.secrets.managed_outside_prompts == true
}

default untrusted_input_reaches_model := false

untrusted_input_reaches_model if {
	input.resilience.untrusted_input_reaches_model == true
}

default injection_controls_adequate := false

injection_controls_adequate if {
	not untrusted_input_reaches_model
}

injection_controls_adequate if {
	untrusted_input_reaches_model
	input.resilience.prompt_injection_controls_in_place == true
}

default events_logged := false

events_logged if {
	input.logging.security_events_logged == true
}

default vulnerability_review_current := false

vulnerability_review_current if {
	object.get(input, ["vulnerability", "review_days_ago"], 99999) <= 90
}

default allow := false

allow if {
	access_controlled
	data_encrypted
	secrets_managed
	injection_controls_adequate
	events_logged
	vulnerability_review_current
}

failed_controls := [name |
	some name, satisfied in {
		"authentication and least privilege": access_controlled,
		"encryption in transit and at rest": data_encrypted,
		"secrets managed outside prompts and context windows": secrets_managed,
		"prompt injection controls where untrusted input reaches the model": injection_controls_adequate,
		"security event logging": events_logged,
		"vulnerability review within 90 days": vulnerability_review_current,
	}
	satisfied == false
]

policy_metrics := {
	"infosec_controls_failed": {
		"name": "Information Security Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"secrets_outside_prompts": {
		"name": "Secrets Managed Outside Prompts and Context Windows",
		"value": object.get(input, ["secrets", "managed_outside_prompts"], false),
		"control_passed": secrets_managed,
	},
	"untrusted_input_path": {
		"name": "Untrusted Input Reaches the Model",
		"value": untrusted_input_reaches_model,
		"control_passed": injection_controls_adequate,
	},
	"vulnerability_review_days_ago": {
		"name": "Days Since Last Vulnerability Review",
		"value": object.get(input, ["vulnerability", "review_days_ago"], -1),
		"control_passed": vulnerability_review_current,
	},
}

report := reporting.compose_report("corporate.infosec", allow, policy_metrics)
