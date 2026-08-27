package global.v1.common.risk_management_test

import data.global.v1.common.risk_management as rm
import rego.v1

# --- risk_score --------------------------------------------------------------

test_risk_score_prefers_risk_management_score if {
	rm.risk_score({"risk_management": {"score": 0.85}}) == 0.85
}

test_risk_score_falls_back_to_evaluation_path if {
	rm.risk_score({"evaluation": {"risk_management": {"score": 0.42}}}) == 0.42
}

test_risk_score_first_shape_wins if {
	rm.risk_score({
		"risk_management": {"score": 0.10},
		"evaluation": {"risk_management": {"score": 0.90}},
	}) == 0.10
}

# Higher is better for risk management, so the 0.0 fallback denies. Absence of
# evidence fails, which is the direction a compliance library wants.
test_risk_score_defaults_to_zero if {
	rm.risk_score({}) == 0.0
}

# --- has_adequate_risk_management -------------------------------------------

test_has_adequate_risk_management_above_threshold if {
	rm.has_adequate_risk_management({"risk_management": {"score": 0.9}}, 0.7)
}

test_has_adequate_risk_management_at_boundary if {
	rm.has_adequate_risk_management({"risk_management": {"score": 0.7}}, 0.7)
}

test_not_adequate_risk_management_below_threshold if {
	not rm.has_adequate_risk_management({"risk_management": {"score": 0.3}}, 0.7)
}

# Follows from the 0.0 fallback: an unmeasured system is inadequate.
test_not_adequate_risk_management_for_unreadable_metrics if {
	not rm.has_adequate_risk_management({}, 0.7)
}

# --- passes_risk_threshold ---------------------------------------------------

test_passes_risk_threshold_above if {
	rm.passes_risk_threshold({"risk_management_score": 0.8}, 0.7)
}

test_passes_risk_threshold_at_boundary if {
	rm.passes_risk_threshold({"risk_management_score": 0.7}, 0.7)
}

test_fails_risk_threshold_below if {
	not rm.passes_risk_threshold({"risk_management_score": 0.1}, 0.7)
}

test_fails_risk_threshold_when_score_absent if {
	not rm.passes_risk_threshold({}, 0.7)
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
