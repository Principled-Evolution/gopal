package international.easa.v1.regulation_2019_947_test

import data.international.easa.v1.regulation_2019_947
import rego.v1

test_allow_open_category_with_class_marking if {
	regulation_2019_947.allow with input as {
		"operation": {"category": "open"},
		"operator": {"registered": true},
		"aircraft": {"class_marking": "C1"},
		"authorization": {"granted": false},
	}
}

test_deny_open_category_without_class_marking if {
	not regulation_2019_947.allow with input as {
		"operation": {"category": "open"},
		"operator": {"registered": true},
		"aircraft": {"class_marking": "unmarked"},
		"authorization": {"granted": false},
	}
}

test_allow_specific_category_with_authorization if {
	regulation_2019_947.allow with input as {
		"operation": {"category": "specific"},
		"operator": {"registered": true},
		"aircraft": {"class_marking": "unmarked"},
		"authorization": {"granted": true},
	}
}

test_deny_specific_category_without_authorization if {
	not regulation_2019_947.allow with input as {
		"operation": {"category": "specific"},
		"operator": {"registered": true},
		"aircraft": {"class_marking": "unmarked"},
		"authorization": {"granted": false},
	}
}

test_allow_certified_category_with_type_certificate if {
	regulation_2019_947.allow with input as {
		"operation": {"category": "certified"},
		"operator": {"registered": true},
		"aircraft": {"type_certificate_held": true},
		"authorization": {"granted": false},
	}
}

test_deny_when_operator_not_registered if {
	not regulation_2019_947.allow with input as {
		"operation": {"category": "open"},
		"operator": {"registered": false},
		"aircraft": {"class_marking": "C1"},
		"authorization": {"granted": false},
	}
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not regulation_2019_947.allow with input as {}
}
