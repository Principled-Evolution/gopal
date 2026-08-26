package industry_specific.education.v1.assessment_and_evaluation_test

import data.industry_specific.education.v1.assessment_and_evaluation as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_responsible_ai_proctoring_compliant_denies_on_empty_input if {
	not policy.responsible_ai_proctoring_compliant with input as {}
}
