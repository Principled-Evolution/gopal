package industry_specific.legal.v1.citation_verification_test

import data.industry_specific.legal.v1.citation_verification as policy
import rego.v1

compliant := {"submission": {
	"ai_assisted": true,
	"filed_with_court": true,
	"citations_total": 12,
	"citations_verified": 12,
	"verification_recorded": true,
	"verifier_named": true,
}}

test_allow_when_every_citation_verified if {
	policy.allow with input as compliant
}

# The Ayinde failure mode: AI-assisted authorities reaching a court filing
# without independent verification.
test_deny_when_a_single_citation_is_unverified if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/submission/citations_verified", "value": 11,
	}])
}

test_report_counts_the_unverified_citations if {
	report := policy.report with input as json.patch(compliant, [{
		"op": "replace", "path": "/submission/citations_verified", "value": 9,
	}])
	report.metrics.unverified_citations.value == 3
	report.metrics.unverified_citations.control_passed == false
}

# Verification nobody recorded cannot be relied on afterwards.
test_deny_when_verification_not_recorded if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/submission/verification_recorded", "value": false,
	}])
}

# Accountability has to attach to a person.
test_deny_when_no_verifier_named if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/submission/verifier_named", "value": false,
	}])
}

# A document not going before a court is outside this policy.
test_allow_when_not_filed_with_court if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/submission/filed_with_court", "value": false},
		{"op": "replace", "path": "/submission/citations_verified", "value": 0},
	])
}

test_allow_when_document_not_ai_assisted if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/submission/ai_assisted", "value": false},
		{"op": "replace", "path": "/submission/citations_verified", "value": 0},
	])
}

# A missing verified count must not read as fully verified.
test_deny_when_verified_count_absent if {
	not policy.allow with input as {"submission": {
		"ai_assisted": true,
		"filed_with_court": true,
		"citations_total": 5,
		"verification_recorded": true,
		"verifier_named": true,
	}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
