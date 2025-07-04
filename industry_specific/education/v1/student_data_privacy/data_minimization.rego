package industry_specific.education.v1.student_data_privacy

# @title Detailed Data Minimization
# @description This policy ensures that data collection is limited to what is strictly necessary for a specified purpose.
# @version 1.1

# Default to deny unless the data requested is deemed necessary.
default data_minimization_compliant := false

# --- Allow Rules ---

# Allow if every piece of data requested is necessary for the stated purpose.
data_minimization_compliant if {
	every field in input.data_requested {
		is_necessary_for_purpose(field, input.request.purpose)
	}
}

# --- Deny Messages ---

deny contains msg if {
	not data_minimization_compliant
	superfluous_data := {field | some field in input.data_requested; not is_necessary_for_purpose(field, input.request.purpose)}
	msg := sprintf("Data minimization violation: The following data fields are not necessary for the purpose '%v': %v", [input.request.purpose, superfluous_data])
}

# --- Helper Functions ---

# Checks if a field is necessary for a given purpose.
is_necessary_for_purpose(field, purpose) if {
	necessary_data := {
		"academic_advising": {"student_id", "grades", "courses_taken", "attendance_record"},
		"enrollment": {"student_id", "name", "address", "date_of_birth"},
		"tutoring_bot": {"student_id", "current_subject", "recent_questions"},
	}
	field in necessary_data[purpose]
}
