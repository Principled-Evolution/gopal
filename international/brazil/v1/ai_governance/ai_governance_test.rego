package international.brazil.v1.ai_governance_test

import data.international.brazil.v1.ai_governance as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_allow_denies_on_empty_input if {
	not policy.allow with input as {}
}
