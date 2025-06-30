package education.v1.student_data_privacy

# @title Detailed FERPA Compliance
# @description This policy evaluates data access requests against the Family Educational Rights and Privacy Act (FERPA).
# @version 1.1

# Default to deny unless a specific condition allows access.
default allow = false

# --- Allow Rules ---

# Allow if the student has provided explicit, valid consent for the requested data.
allow {
    has_valid_consent(input.student, input.data_requested)
}

# Allow if ALL requested data is "directory information" AND the student has NOT opted out.
allow {
    every item in input.data_requested {
        is_directory_information(item)
    }
    not input.student.directory_information_opt_out
}

# Allow if the request is from a school official with a legitimate educational interest.
allow {
    is_school_official(input.request.recipient)
    has_legitimate_interest(input.request.purpose)
}

# Allow in a health or safety emergency.
allow {
    input.request.purpose == "health_or_safety_emergency"
}


# --- Deny Messages ---

deny[msg] {
    not allow
    msg := sprintf("Access denied. The request for data (%v) does not meet any FERPA exceptions.", [input.data_requested])
}


# --- Helper Functions ---

# Checks if a user is a designated school official.
is_school_official(recipient) {
    recipient.role == "teacher"
}
is_school_official(recipient) {
    recipient.role == "administrator"
}

# Checks if the purpose is a legitimate educational interest.
has_legitimate_interest(purpose) {
    purpose == "academic_advising"
}
has_legitimate_interest(purpose) {
    purpose == "instructional_improvement"
}

# Defines what constitutes "directory information".
is_directory_information(field) {
    directory_fields := {"name", "address", "telephone_number", "email_address", "date_of_birth"}
    field in directory_fields
}

# Checks for valid consent (placeholder logic).
has_valid_consent(student, data) {
    student.consent.status == "active"
    every item in data {
        item in student.consent.scope
    }
}
