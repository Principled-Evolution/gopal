package industry_specific.education.v1.fairness_and_equity_test

import data.industry_specific.education.v1.fairness_and_equity as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_unbiased_automated_grading_compliant_denies_on_empty_input if {
	not policy.unbiased_automated_grading_compliant with input as {}
}

# Three policies share this package, and two of them defined a complete rule
# named `thresholds` with different values. OPA raises eval_conflict_error when
# a complete rule produces multiple outputs, which failed the whole package: a
# consumer querying data.industry_specific.education.v1.fairness_and_equity
# received nothing, so all three policies delivered no verdict while opa check
# and opa test both passed.
#
# Referencing both threshold sets in one expression forces them to be evaluated
# together, which is what the package query does and what the individual rule
# tests did not.
test_grading_and_admissions_thresholds_do_not_collide if {
	policy.grading_thresholds.disparate_impact == 0.8
	policy.admissions_thresholds.demographic_parity == 0.1
	policy.grading_thresholds != policy.admissions_thresholds
}
