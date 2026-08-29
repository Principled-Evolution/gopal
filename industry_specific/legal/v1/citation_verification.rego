# RequiredMetrics:
#   - submission.ai_assisted
#   - submission.filed_with_court
#   - submission.citations_total
#   - submission.citations_verified
#   - submission.verification_recorded
#   - submission.verifier_named
#
# RequiredParams: none
package industry_specific.legal.v1.citation_verification

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Verification of AI-Assisted Citations Before Filing",
	"description": "Evaluates whether authorities in an AI-assisted document have been independently verified before the document is put before a court. This is the failure mode regulators have actually sanctioned: fabricated citations reaching court filings, as in R (Ayinde) v Haringey LBC. The professional obligation is unchanged by the use of AI, so an unverified citation is a breach whether a person or a model produced it, and verification has to be recorded and attributable to a named individual.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"SRA warning notice, misuse of AI (August 2026)",
		"SRA Code of Conduct for Solicitors, paragraph 1.4 (not misleading the court) and 2.4 (properly arguable statements)",
		"Bar Standards Board, guidance on the use of AI and other technologies (18 May 2026)",
		"R (on the application of Ayinde) v Haringey LBC",
		"Guidance on the use of artificial intelligence for judicial office holders (31 October 2025)",
	],
}

# The policy engages only for documents going before a court, and that has to be
# asserted rather than inferred from an absent field.
default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["submission", "ai_assisted"]))
	is_boolean(declarations.resolve(input, ["submission", "filed_with_court"]))
}

default in_scope := false

in_scope if {
	declarations.resolve(input, ["submission", "ai_assisted"]) == true
	declarations.resolve(input, ["submission", "filed_with_court"]) == true
}

citations_total := object.get(input, ["submission", "citations_total"], 0)

citations_verified := object.get(input, ["submission", "citations_verified"], 0)

unverified_citations := citations_total - citations_verified

default all_citations_verified := false

all_citations_verified if {
	unverified_citations <= 0
}

# A verification that leaves no record cannot be relied on after the fact, and
# accountability has to attach to a person.
default verification_attributable := false

verification_attributable if {
	declarations.resolve(input, ["submission", "verification_recorded"]) == true
	declarations.resolve(input, ["submission", "verifier_named"]) == true
}

default allow := false

# Not an AI-assisted document going before a court.
allow if {
	scope_determined
	not in_scope
}

allow if {
	scope_determined
	in_scope
	all_citations_verified
	verification_attributable
}

policy_metrics := {
	"unverified_citations": {
		"name": "Citations Not Independently Verified",
		"value": unverified_citations,
		"control_passed": all_citations_verified,
	},
	"verification_recorded": {
		"name": "Verification Recorded and Attributed to a Named Individual",
		"value": verification_attributable,
		"control_passed": verification_attributable,
	},
	"scope": {
		"name": "AI-Assisted Document Filed With a Court",
		"value": in_scope,
		"control_passed": scope_determined,
	},
}

report := reporting.compose_report("legal.citation_verification", allow, policy_metrics)
