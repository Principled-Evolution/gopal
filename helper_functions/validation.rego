package helper_functions.validation

import rego.v1

field_exists(obj, field_path) if {
	unique_default := "__FIELD_NOT_FOUND__" # A sentinel unlikely to occur in your data

	# Split the dotted field path and use object.get to retrieve the value.
	object.get(obj, split(field_path, "."), unique_default) != unique_default
}

validate_required_fields(required_fields, provided_input) := result if {
	missing := [field |
		some field in required_fields
		not field_exists(provided_input, field)
	]
	result = {
		"is_valid": count(missing) == 0,
		"missing": missing,
	}
}
