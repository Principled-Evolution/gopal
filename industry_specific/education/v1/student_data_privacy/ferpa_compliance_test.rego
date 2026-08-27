package industry_specific.education.v1.student_data_privacy_test

import data.industry_specific.education.v1.student_data_privacy as policy
import rego.v1

# Baseline safety tests: a policy must never approve a system it has no
# evidence about. In Rego an undefined value is not false, so a missing
# default or an undefined intermediate rule can silently fail open.

test_ferpa_compliant_denies_on_empty_input if {
	not policy.ferpa_compliant with input as {}
}

# --- Written consent, 34 CFR 99.30 -----------------------------------------
#
# A consent record carrying every element the regulation requires. Each test
# below removes or changes exactly one element, so a failure names the element
# that stopped being enforced.

valid_consent_input := {
	"student": {"consent": {
		"signed_by_role": "parent",
		"signed_date": "2026-01-15",
		"signature_method": "handwritten",
		"records": ["transcript", "attendance_record"],
		"purposes": ["college_admissions"],
		"recipients": ["university-of-example"],
		"recipient_classes": [],
	}},
	"request": {
		"purpose": "college_admissions",
		"recipient": {"id": "university-of-example", "role": "external"},
	},
	"data_requested": ["transcript"],
}

test_consent_with_every_required_element_allows if {
	policy.ferpa_compliant with input as valid_consent_input
}

test_consent_may_identify_a_class_of_parties if {
	policy.ferpa_compliant with input as json.patch(valid_consent_input, [
		{"op": "replace", "path": "/student/consent/recipients", "value": []},
		{"op": "replace", "path": "/student/consent/recipient_classes", "value": ["accredited_universities"]},
		{"op": "add", "path": "/request/recipient/class", "value": "accredited_universities"},
	])
}

# 99.30(a): signed and dated.

test_consent_without_a_signature_role_denies if {
	not policy.ferpa_compliant with input as json.remove(valid_consent_input, ["/student/consent/signed_by_role"])
}

test_consent_signed_by_the_wrong_person_denies if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/student/consent/signed_by_role",
		"value": "school_registrar",
	}])
}

test_consent_without_a_date_denies if {
	not policy.ferpa_compliant with input as json.remove(valid_consent_input, ["/student/consent/signed_date"])
}

test_consent_with_an_empty_date_denies if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/student/consent/signed_date",
		"value": "",
	}])
}

test_consent_with_an_unauthenticated_signature_denies if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/student/consent/signature_method",
		"value": "typed_name",
	}])
}

test_consent_signed_electronically_with_authentication_allows if {
	policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/student/consent/signature_method",
		"value": "authenticated_electronic",
	}])
}

# 99.30(b)(1): specifies the records that may be disclosed.

test_consent_does_not_cover_a_record_that_was_not_named if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/data_requested",
		"value": ["transcript", "disciplinary_record"],
	}])
}

# `every` over an empty collection is vacuously true, so without an explicit
# count check a request for no records at all would satisfy the consent branch.
test_consent_does_not_authorise_an_empty_request if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/data_requested",
		"value": [],
	}])
}

# 99.30(b)(2): states the purpose of the disclosure.

test_consent_does_not_cover_a_different_purpose if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/request/purpose",
		"value": "marketing",
	}])
}

test_consent_without_any_stated_purpose_denies if {
	not policy.ferpa_compliant with input as json.remove(valid_consent_input, ["/student/consent/purposes"])
}

# 99.30(b)(3): identifies the party or class of parties.

test_consent_does_not_cover_a_different_recipient if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [{
		"op": "replace",
		"path": "/request/recipient/id",
		"value": "data-broker-inc",
	}])
}

test_consent_without_any_named_party_denies if {
	not policy.ferpa_compliant with input as json.patch(valid_consent_input, [
		{"op": "replace", "path": "/student/consent/recipients", "value": []},
		{"op": "replace", "path": "/student/consent/recipient_classes", "value": []},
	])
}

# The shape this policy used to accept. A status flag and a scope list say
# nothing about who signed, why, or who receives the data, so they no longer
# clear the consent branch on their own.
test_a_bare_active_status_flag_no_longer_allows if {
	not policy.ferpa_compliant with input as {
		"student": {"consent": {"status": "active", "scope": ["transcript"]}},
		"request": {"purpose": "college_admissions", "recipient": {"id": "university-of-example"}},
		"data_requested": ["transcript"],
	}
}

# The default on has_valid_consent is what makes it total. Asserting `== false`
# rather than `not ...` is deliberate: without the default the call is undefined
# for a consent record that is missing everything, `not undefined` would still
# pass, and the guard could be deleted with no test noticing.
test_has_valid_consent_is_false_not_undefined_for_junk if {
	policy.has_valid_consent({}, {}, []) == false
	policy.has_valid_consent({"consent": {}}, {"purpose": "x"}, ["transcript"]) == false
}

# --- Directory information -------------------------------------------------

test_directory_information_allows_when_not_opted_out if {
	policy.ferpa_compliant with input as {
		"student": {"directory_information_opt_out": false},
		"data_requested": ["name", "email_address"],
	}
}

test_directory_information_denies_when_opted_out if {
	not policy.ferpa_compliant with input as {
		"student": {"directory_information_opt_out": true},
		"data_requested": ["name"],
	}
}

test_directory_information_denies_a_non_directory_field if {
	not policy.ferpa_compliant with input as {
		"student": {"directory_information_opt_out": false},
		"data_requested": ["name", "transcript"],
	}
}

# Same vacuous-truth trap as the consent branch.
test_directory_information_denies_an_empty_request if {
	not policy.ferpa_compliant with input as {
		"student": {"directory_information_opt_out": false},
		"data_requested": [],
	}
}

# --- School officials and emergencies --------------------------------------

test_school_official_with_legitimate_interest_allows if {
	policy.ferpa_compliant with input as {"request": {
		"recipient": {"role": "teacher"},
		"purpose": "academic_advising",
	}}
}

test_school_official_without_legitimate_interest_denies if {
	not policy.ferpa_compliant with input as {"request": {
		"recipient": {"role": "teacher"},
		"purpose": "marketing",
	}}
}

test_non_official_with_legitimate_purpose_denies if {
	not policy.ferpa_compliant with input as {"request": {
		"recipient": {"role": "vendor"},
		"purpose": "academic_advising",
	}}
}

test_health_or_safety_emergency_allows if {
	policy.ferpa_compliant with input as {"request": {"purpose": "health_or_safety_emergency"}}
}
