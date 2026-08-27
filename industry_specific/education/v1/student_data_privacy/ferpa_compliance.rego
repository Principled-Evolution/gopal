package industry_specific.education.v1.student_data_privacy

# @title Detailed FERPA Compliance
# @description This policy evaluates data access requests against the Family Educational Rights and Privacy Act (FERPA).
# @version 1.2

# Default to deny unless a specific condition allows access.
default ferpa_compliant := false

# --- Allow Rules ---

# Allow if there is a written consent that meets 34 CFR 99.30 for this request.
ferpa_compliant if {
	has_valid_consent(input.student, input.request, input.data_requested)
}

# Allow if ALL requested data is "directory information" AND the student has NOT opted out.
ferpa_compliant if {
	input.student.directory_information_opt_out == false

	# A request for nothing is not a request. Without this, `every` over an
	# empty collection is vacuously true and the branch allows an empty
	# request, which is the same vacuous-truth trap that `every` invites
	# everywhere in Rego.
	count(input.data_requested) > 0

	every item in input.data_requested {
		is_directory_information(item)
	}
}

# Allow if the request is from a school official with a legitimate educational interest.
ferpa_compliant if {
	is_school_official(input.request.recipient)
	has_legitimate_interest(input.request.purpose)
}

# Allow in a health or safety emergency.
ferpa_compliant if {
	input.request.purpose == "health_or_safety_emergency"
}

# --- Deny Messages ---

deny contains msg if {
	not ferpa_compliant
	msg := sprintf("Access denied. The request for data (%v) does not meet any FERPA exceptions.", [input.data_requested])
}

# --- Helper Functions ---

# Checks if a user is a designated school official.
is_school_official(recipient) if {
	recipient.role == "teacher"
}

is_school_official(recipient) if {
	recipient.role == "administrator"
}

# Checks if the purpose is a legitimate educational interest.
has_legitimate_interest("academic_advising")

has_legitimate_interest("instructional_improvement")

# Defines what constitutes "directory information".
is_directory_information(field) if {
	directory_fields := {"name", "address", "telephone_number", "email_address", "date_of_birth"}
	field in directory_fields
}

# Written consent under 34 CFR 99.30.
#
# The regulation does not treat consent as a flag. A consent is valid only if it
# is signed and dated by the right person (99.30(a), 99.5) and, per 99.30(b),
# specifies the records to be disclosed, states the purpose of the disclosure,
# and identifies the party or class of parties who may receive it. A consent
# that permits disclosing a transcript to a named employer for admissions does
# not permit disclosing it to a data broker for marketing, and a rule that
# checks only a status field cannot tell those apart.
#
# All four elements are required together, so a consent record missing any of
# them leaves this undefined and the request is denied by the default above.
default has_valid_consent(_, _, _) := false

has_valid_consent(student, request, data_requested) if {
	consent := student.consent

	_signed_and_dated(consent)
	_covers_records(consent, data_requested)
	_states_purpose(consent, request)
	_identifies_party(consent, request)
}

# 99.30(a) and 99.30(d): signed and dated by the parent or the eligible student.
# An electronic signature is acceptable where it identifies and authenticates a
# particular person, which is what signature_method records.
_signed_and_dated(consent) if {
	consent.signed_by_role in {"parent", "eligible_student"}
	is_string(consent.signed_date)
	consent.signed_date != ""
	consent.signature_method in {"handwritten", "authenticated_electronic"}
}

# 99.30(b)(1): specifies the records that may be disclosed. Every record asked
# for has to be one the consent names, and asking for nothing is not a request.
_covers_records(consent, data_requested) if {
	count(data_requested) > 0

	every item in data_requested {
		item in consent.records
	}
}

# 99.30(b)(2): states the purpose of the disclosure. The purpose on the request
# must be one the consent actually authorises.
_states_purpose(consent, request) if {
	request.purpose in consent.purposes
}

# 99.30(b)(3): identifies the party or class of parties to whom disclosure may
# be made. Either the named recipient or the class it belongs to will do, since
# the regulation permits a class.
_identifies_party(consent, request) if {
	request.recipient.id in consent.recipients
}

_identifies_party(consent, request) if {
	request.recipient.class in consent.recipient_classes
}
