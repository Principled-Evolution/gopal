package global.v1.common.risk_management_test

import data.global.v1.common.risk_management as rm
import rego.v1

# --- risk_score --------------------------------------------------------------

test_risk_score_reads_the_canonical_name if {
	rm.risk_score({"metrics": {"risk_management": {"score": 0.85}}}) == 0.85
}

# Undefined, not 0.0. Higher is better here, so 0.0 denied and the direction was
# safe, but it denied while reporting a measurement nobody took.
test_risk_score_is_undefined_when_unmeasured if {
	not rm.risk_score({})
	not rm.risk_score({"metrics": {}})
}

test_the_retired_evaluation_spelling_is_not_read if {
	not rm.risk_score({"evaluation": {"risk_management": {"score": 0.42}}})
}

# --- has_adequate_risk_management -------------------------------------------

test_has_adequate_risk_management_above_threshold if {
	rm.has_adequate_risk_management({"metrics": {"risk_management": {"score": 0.9}}}, 0.7)
}

test_has_adequate_risk_management_at_boundary if {
	rm.has_adequate_risk_management({"metrics": {"risk_management": {"score": 0.7}}}, 0.7)
}

test_not_adequate_risk_management_below_threshold if {
	not rm.has_adequate_risk_management({"metrics": {"risk_management": {"score": 0.3}}}, 0.7)
}

# risk_score is undefined for an unmeasured system, so the comparison fails
# and the system is inadequate. Absence does not become adequacy.
test_not_adequate_risk_management_for_unreadable_metrics if {
	not rm.has_adequate_risk_management({}, 0.7)
}

# --- has_adequate_documentation ---------------------------------------------

test_has_adequate_documentation_with_text if {
	rm.has_adequate_documentation({"context": {"risk_documentation": "We assessed the risks."}})
}

test_not_adequate_documentation_when_empty_string if {
	not rm.has_adequate_documentation({"context": {"risk_documentation": ""}})
}

# An absent field leaves the comparison undefined, so it denies.
test_not_adequate_documentation_when_field_absent if {
	not rm.has_adequate_documentation({"context": {}})
}

test_not_adequate_documentation_when_context_absent if {
	not rm.has_adequate_documentation({})
}

# The check is only `!= ""`, so any non-empty value passes, including a value
# that is not documentation at all. Recorded because it is a real weakness: a
# caller that needs substantive documentation should use
# has_required_documentation_sections instead.
test_adequate_documentation_accepts_a_null_value if {
	rm.has_adequate_documentation({"context": {"risk_documentation": null}})
}

# --- has_required_documentation_sections ------------------------------------

test_has_required_sections_when_both_present if {
	rm.has_required_documentation_sections({"context": {"risk_documentation": concat(" ", [
		"Risk Assessment: we reviewed the model.",
		"Mitigation Measures: we added a human reviewer.",
	])}})
}

test_missing_required_sections_when_only_one_present if {
	rm.has_required_documentation_sections({"context": {"risk_documentation": "Risk Assessment only"}}) == false
}

test_missing_required_sections_when_neither_present if {
	rm.has_required_documentation_sections({"context": {"risk_documentation": "Some notes"}}) == false
}

# The section match is case-sensitive and substring-based, so a differently
# capitalised heading does not count.
test_required_sections_are_case_sensitive if {
	rm.has_required_documentation_sections({"context": {"risk_documentation": "risk assessment and mitigation measures"}}) == false
}
