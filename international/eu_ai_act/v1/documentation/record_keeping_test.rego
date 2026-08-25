package international.eu_ai_act.v1.documentation.record_keeping_test

import data.international.eu_ai_act.v1.documentation.record_keeping as policy
import rego.v1

compliant := {
	"system": {"high_risk": true},
	"logs": {"retained": true, "retention_months": 12},
}

test_allow_with_twelve_month_retention if {
	policy.allow with input as compliant
}

test_allow_when_not_high_risk if {
	policy.allow with input as {"system": {"high_risk": false}}
}

# Six months is the Article 19 and 26(6) floor.
test_allow_at_the_six_month_floor if {
	policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logs/retention_months", "value": 6}])
}

test_deny_below_the_six_month_floor if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logs/retention_months", "value": 3}])
}

# Generating logs and then discarding them fails, even though the logging
# capability itself is present.
test_deny_when_logs_are_not_retained if {
	not policy.allow with input as json.patch(compliant, [{"op": "replace", "path": "/logs/retained", "value": false}])
}

# Where sectoral law requires longer, the longer period governs.
test_sectoral_minimum_raises_the_requirement if {
	not policy.allow with input as json.patch(compliant, [{"op": "add", "path": "/logs/sectoral_minimum_months", "value": 24}])
}

test_allow_when_sectoral_minimum_is_met if {
	policy.allow with input as json.patch(compliant, [
		{"op": "add", "path": "/logs/sectoral_minimum_months", "value": 24},
		{"op": "replace", "path": "/logs/retention_months", "value": 24},
	])
}

# A sectoral figure below the Act's floor does not lower it.
test_sectoral_minimum_cannot_lower_the_floor if {
	not policy.allow with input as json.patch(compliant, [
		{"op": "add", "path": "/logs/sectoral_minimum_months", "value": 1},
		{"op": "replace", "path": "/logs/retention_months", "value": 2},
	])
}

# An absent retention figure must not read as compliant.
test_deny_when_retention_absent if {
	not policy.allow with input as {"system": {"high_risk": true}, "logs": {"retained": true}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
