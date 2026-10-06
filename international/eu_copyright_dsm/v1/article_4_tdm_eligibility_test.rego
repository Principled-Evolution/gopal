package international.eu_copyright_dsm.v1.article_4_tdm_eligibility_test

import data.international.eu_copyright_dsm.v1.article_4_tdm_eligibility
import rego.v1

attestation(value, expires) := {
	"value": value,
	"asserted_by": "external-observation-provider",
	"asserted_at": "2026-10-06T11:00:00Z",
	"evidence": "urn:evidence:synthetic:article4",
	"expires": expires,
}

article4_input(tdm, lawful_access, reservation_status) := {
	"evaluated_at": "2026-10-06T12:00:00Z",
	"copyright_dsm": {
		"article4": {
			"qualifies_as_tdm": attestation(tdm, "2026-10-06T13:00:00Z"),
			"lawful_access": attestation(lawful_access, "2026-10-06T13:00:00Z"),
			"reservation_status": attestation(reservation_status, "2026-10-06T13:00:00Z"),
		},
	},
}

test_eligible_on_complete_current_declarations if {
	article_4_tdm_eligibility.eligible with input as article4_input(true, true, "not_expressly_reserved")
}

test_eligible_denies_on_empty_input if {
	not article_4_tdm_eligibility.eligible with input as {}
}

test_express_reservation_is_ineligible_and_reported if {
	input_doc := article4_input(true, true, "expressly_reserved")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"express_reservation_observed" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_lawful_access_false_is_ineligible_and_reported if {
	input_doc := article4_input(true, false, "not_expressly_reserved")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"lawful_access_not_established" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_lawful_access_missing_is_ineligible_and_reported if {
	input_doc := {
		"evaluated_at": "2026-10-06T12:00:00Z",
		"copyright_dsm": {
			"article4": {
				"qualifies_as_tdm": attestation(true, "2026-10-06T13:00:00Z"),
				"reservation_status": attestation("not_expressly_reserved", "2026-10-06T13:00:00Z"),
			},
		},
	}
	not article_4_tdm_eligibility.eligible with input as input_doc
	"lawful_access_missing" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_expired_reservation_evidence_is_ineligible_and_reported if {
	input_doc := {
		"evaluated_at": "2026-10-06T12:00:00Z",
		"copyright_dsm": {
			"article4": {
				"qualifies_as_tdm": attestation(true, "2026-10-06T13:00:00Z"),
				"lawful_access": attestation(true, "2026-10-06T13:00:00Z"),
				"reservation_status": attestation("not_expressly_reserved", "2026-10-06T11:59:59Z"),
			},
		},
	}
	not article_4_tdm_eligibility.eligible with input as input_doc
	"reservation_status_expired" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_unknown_reservation_status_is_ineligible_and_reported if {
	input_doc := article4_input(true, true, "unknown")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"reservation_status_unknown" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_unverifiable_reservation_status_is_ineligible_and_reported if {
	input_doc := article4_input(true, true, "unverifiable")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"reservation_status_unverifiable" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_no_reservation_observed_is_not_permission if {
	input_doc := article4_input(true, true, "no_reservation_observed")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"absence_of_reservation_not_established" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}

test_tdm_purpose_false_is_ineligible_and_reported if {
	input_doc := article4_input(false, true, "not_expressly_reserved")
	not article_4_tdm_eligibility.eligible with input as input_doc
	"tdm_purpose_not_established" in article_4_tdm_eligibility.report.unresolved_conditions with input as input_doc
}
