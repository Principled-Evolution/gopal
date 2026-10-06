# RequiredMetrics:
#   - copyright_dsm.article4.qualifies_as_tdm
#   - copyright_dsm.article4.lawful_access
#   - copyright_dsm.article4.reservation_status
#
# RequiredParams: none
package international.eu_copyright_dsm.v1.article_4_tdm_eligibility

import data.helper_functions.declarations
import rego.v1

metadata := {
	"title": "Directive (EU) 2019/790 Article 4 TDM exception eligibility",
	"description": "Evaluates eligibility for the Article 4 text-and-data-mining exception on supplied Directive-level facts. This is not a licence, permission, ownership determination, Member State law assessment, or complete legality decision.",
	"version": "1.0.0",
	"category": "International",
	"references": [
		"Directive (EU) 2019/790, Article 2(2) — definition of text and data mining",
		"Directive (EU) 2019/790, Article 4(1) — lawfully accessible works and other subject matter for TDM",
		"Directive (EU) 2019/790, Article 4(3) — exception conditional on use not having been expressly reserved; machine-readable means for online content",
		"Directive (EU) 2019/790, Recital 18 — context for the Article 4 TDM exception and reservation of rights",
		"https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:32019L0790",
	],
}

default eligible := false

eligible if {
	declarations.resolve(input, ["copyright_dsm", "article4", "qualifies_as_tdm"]) == true
	declarations.resolve(input, ["copyright_dsm", "article4", "lawful_access"]) == true
	declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"]) == "not_expressly_reserved"
}

unresolved_conditions contains "tdm_purpose_expired" if {
	declarations.stale(input, ["copyright_dsm", "article4", "qualifies_as_tdm"])
}

unresolved_conditions contains "tdm_purpose_missing" if {
	not declarations.supplied(input, ["copyright_dsm", "article4", "qualifies_as_tdm"])
	not declarations.stale(input, ["copyright_dsm", "article4", "qualifies_as_tdm"])
}

unresolved_conditions contains "tdm_purpose_not_established" if {
	declarations.supplied(input, ["copyright_dsm", "article4", "qualifies_as_tdm"])
	declarations.resolve(input, ["copyright_dsm", "article4", "qualifies_as_tdm"]) != true
}

unresolved_conditions contains "lawful_access_expired" if {
	declarations.stale(input, ["copyright_dsm", "article4", "lawful_access"])
}

unresolved_conditions contains "lawful_access_missing" if {
	not declarations.supplied(input, ["copyright_dsm", "article4", "lawful_access"])
	not declarations.stale(input, ["copyright_dsm", "article4", "lawful_access"])
}

unresolved_conditions contains "lawful_access_not_established" if {
	declarations.supplied(input, ["copyright_dsm", "article4", "lawful_access"])
	declarations.resolve(input, ["copyright_dsm", "article4", "lawful_access"]) != true
}

unresolved_conditions contains "reservation_status_expired" if {
	declarations.stale(input, ["copyright_dsm", "article4", "reservation_status"])
}

unresolved_conditions contains "reservation_status_missing" if {
	not declarations.supplied(input, ["copyright_dsm", "article4", "reservation_status"])
	not declarations.stale(input, ["copyright_dsm", "article4", "reservation_status"])
}

unresolved_conditions contains "express_reservation_observed" if {
	declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"]) == "expressly_reserved"
}

unresolved_conditions contains "absence_of_reservation_not_established" if {
	declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"]) == "no_reservation_observed"
}

unresolved_conditions contains "reservation_status_unknown" if {
	declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"]) == "unknown"
}

unresolved_conditions contains "reservation_status_unverifiable" if {
	declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"]) == "unverifiable"
}

unresolved_conditions contains "reservation_status_unrecognized" if {
	status := declarations.resolve(input, ["copyright_dsm", "article4", "reservation_status"])
	not status in {
		"not_expressly_reserved",
		"expressly_reserved",
		"no_reservation_observed",
		"unknown",
		"unverifiable",
	}
}

report := {
	"policy": "eu_copyright_dsm.article_4_tdm_eligibility",
	"result": eligible,
	"unresolved_conditions": sort(unresolved_conditions),
	"scope": "Directive-level Article 4 exception eligibility on supplied facts only",
}
