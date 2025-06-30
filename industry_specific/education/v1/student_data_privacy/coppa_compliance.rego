package education.v1.student_data_privacy

# @title Detailed COPPA Compliance
# @description This policy ensures that the collection and processing of personal information from children under 13 complies with COPPA.
# @version 1.1

# Default to deny unless a specific condition allows data collection.
default allow = false

# --- Allow Rules ---

# Allow if the user is 13 or older.
allow {
    input.user.age >= 13
}

# Allow if the user is under 13 but verifiable parental consent has been obtained.
allow {
    input.user.age < 13
    has_verifiable_parental_consent(input.user)
}

# Allow for internal operations of the service (e.g., analytics, debugging).
allow {
    input.request.purpose == "internal_operations"
}


# --- Deny Messages ---

deny[msg] {
    input.user.age < 13
    not has_verifiable_parental_consent(input.user)
    not input.request.purpose == "internal_operations"
    msg := "COPPA violation: Verifiable parental consent is required for users under 13."
}


# --- Helper Functions ---

# Checks for verifiable parental consent.
# This could involve checking a consent form, a government ID, or other methods.
has_verifiable_parental_consent(user) {
    user.consent.parental_consent_status == "verified"
    user.consent.method in {"consent_form", "government_id_verification", "video_conference"}
}
