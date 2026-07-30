package industry_specific.aviation.v1.airworthiness.certification_test

import data.industry_specific.aviation.v1.airworthiness.certification
import rego.v1

test_allow_when_certified_and_compliant if {
	certification.allow with input as {"aircraft": {"type_certificate_held": true, "airworthiness_directive_compliant": true}}
}

test_deny_without_type_certificate if {
	not certification.allow with input as {"aircraft": {"type_certificate_held": false, "airworthiness_directive_compliant": true}}
}

test_deny_without_ad_compliance if {
	not certification.allow with input as {"aircraft": {"type_certificate_held": true, "airworthiness_directive_compliant": false}}
}
