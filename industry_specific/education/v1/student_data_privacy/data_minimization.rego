package education.v1.student_data_privacy

# @title Detailed Data Minimization
# @description This policy ensures that data collection is limited to what is strictly necessary for a specified purpose.
# @version 1.1

# Default to deny unless the data requested is deemed necessary.
default allow = false

# --- Allow Rules ---

# Allow if every piece of data requested is necessary for the stated purpose.
allow if {
    every field in input.data_requested {
        is_necessary_for_purpose(field, input.request.purpose)
    }
}


# --- Deny Messages ---

deny contains msg if {
    not allow
    superfluous_data := {field | field := input.data_requested[_]; not is_necessary_for_purpose(field, input.request.purpose)}
    msg := sprintf("Data minimization violation: The following data fields are not necessary for the purpose '%v': %v", [input.request.purpose, superfluous_data])
}


# --- Helper Functions ---

# Defines the necessary data fields for each purpose.
necessary_data := {
    "academic_advising": {"student_id", "grades", "courses_taken", "attendance_record"},
    "enrollment": {"student_id", "name", "address", "date_of_birth"},
    "tutoring_bot": {"student_id", "current_subject", "recent_questions"}
}

# Checks if a field is necessary for a given purpose.
is_necessary_for_purpose(field, purpose) if {
    field in necessary_data[purpose]
}
