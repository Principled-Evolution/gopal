package industry_specific.education.v1.student_data_privacy_test

import data.industry_specific.education.v1.student_data_privacy as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_coppa_compliant_denies_on_empty_input if {
	not policy.coppa_compliant with input as {}
}
