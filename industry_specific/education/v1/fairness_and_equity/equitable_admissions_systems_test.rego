package industry_specific.education.v1.fairness_and_equity_test

import data.industry_specific.education.v1.fairness_and_equity as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_equitable_admissions_systems_compliant_denies_on_empty_input if {
	not policy.equitable_admissions_systems_compliant with input as {}
}
