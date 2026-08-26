package helper_functions.validation_test

import data.helper_functions.validation
import rego.v1

# --- field_exists ------------------------------------------------------------
#
# field_exists takes a dot-separated path and resolves it with object.get,
# comparing against a sentinel so that a field holding a legitimately falsy
# value still counts as present.

test_field_exists_for_top_level_key if {
	validation.field_exists({"score": 1}, "score")
}

test_field_exists_for_nested_path if {
	validation.field_exists({"metrics": {"fairness": {"score": 0.9}}}, "metrics.fairness.score")
}

test_field_absent_for_missing_top_level_key if {
	not validation.field_exists({"score": 1}, "other")
}

test_field_absent_for_partially_matching_path if {
	not validation.field_exists({"metrics": {"fairness": {}}}, "metrics.fairness.score")
}

test_field_absent_when_parent_missing if {
	not validation.field_exists({}, "metrics.fairness.score")
}

# The sentinel comparison is the important part: false, 0, "" and null are all
# present values, and treating them as missing would make a policy demand a
# truthy value where the regulation only asks for a declaration.
test_field_exists_when_value_is_false if {
	validation.field_exists({"flag": false}, "flag")
}

test_field_exists_when_value_is_zero if {
	validation.field_exists({"count": 0}, "count")
}

test_field_exists_when_value_is_empty_string if {
	validation.field_exists({"note": ""}, "note")
}

test_field_exists_when_value_is_null if {
	validation.field_exists({"note": null}, "note")
}

test_field_exists_when_value_is_empty_object if {
	validation.field_exists({"details": {}}, "details")
}

# --- validate_required_fields ------------------------------------------------

test_validate_reports_valid_when_all_fields_present if {
	result := validation.validate_required_fields(
		["a", "b.c"],
		{"a": 1, "b": {"c": 2}},
	)
	result.is_valid
	count(result.missing) == 0
}

test_validate_lists_every_missing_field if {
	result := validation.validate_required_fields(
		["a", "b.c", "d"],
		{"a": 1},
	)
	not result.is_valid
	result.missing == ["b.c", "d"]
}

test_validate_preserves_the_declared_field_order_in_missing if {
	result := validation.validate_required_fields(
		["z", "y", "x"],
		{},
	)
	result.missing == ["z", "y", "x"]
}

# An empty requirement list is trivially satisfied, including against empty
# input. Policies therefore must not rely on this call alone to establish that
# they received anything at all.
test_validate_is_valid_for_empty_requirements if {
	result := validation.validate_required_fields([], {})
	result.is_valid
}

test_validate_reports_all_missing_for_empty_input if {
	result := validation.validate_required_fields(["a", "b"], {})
	not result.is_valid
	count(result.missing) == 2
}
