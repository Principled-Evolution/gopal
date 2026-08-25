package operational.corporate.v1.infosec_test

import data.operational.corporate.v1.infosec as policy
import rego.v1

compliant := {
	"access": {"least_privilege_enforced": true, "authentication_required": true},
	"data": {"encrypted_in_transit": true, "encrypted_at_rest": true},
	"secrets": {"managed_outside_prompts": true},
	"resilience": {"untrusted_input_reaches_model": false, "prompt_injection_controls_in_place": false},
	"logging": {"security_events_logged": true},
	"vulnerability": {"review_days_ago": 30},
}

test_allow_when_all_controls_present if {
	policy.allow with input as compliant
}

test_deny_without_authentication if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/access/authentication_required", "value": false}])
}

test_deny_without_encryption_at_rest if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/data/encrypted_at_rest", "value": false}])
}

# A credential in a prompt is in the context window, the provider's logs, and
# any retained transcript.
test_deny_when_secrets_live_in_prompts if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/secrets/managed_outside_prompts", "value": false}])
}

# Injection controls are required only where untrusted input actually reaches
# the model, but then they are required absolutely.
test_deny_untrusted_input_without_injection_controls if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/resilience/untrusted_input_reaches_model", "value": true}])
}

test_allow_untrusted_input_with_injection_controls if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/resilience/untrusted_input_reaches_model", "value": true},
		{"op": "replace", "path": "/resilience/prompt_injection_controls_in_place", "value": true},
	])
}

test_deny_without_security_event_logging if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logging/security_events_logged", "value": false}])
}

test_deny_when_vulnerability_review_stale if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/vulnerability/review_days_ago", "value": 200}])
}

test_allow_at_ninety_day_boundary if {
	policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/vulnerability/review_days_ago", "value": 90}])
}

# An absent review date must not read as recently reviewed.
test_deny_when_review_date_absent if {
	not policy.allow with input as json.patch(compliant, [{"op": "remove", "path": "/vulnerability/review_days_ago"}])
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
