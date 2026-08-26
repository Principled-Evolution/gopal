package industry_specific.education.v1.fairness_and_equity_test

import data.industry_specific.education.v1.fairness_and_equity as policy
import rego.v1

# An assignment nobody has told us anything about is not equitable. In Rego an
# undefined value is not false, so this also guards against a future refactor
# that drops the `default equitable := false`.
test_equitable_denies_on_empty_input if {
	not policy.equitable with input as {}
}

# Route 1: a comparable offline alternative exists.
test_equitable_with_offline_alternative if {
	policy.equitable with input as {"assignment": {"has_offline_alternative": true}}
}

# Route 2: the school supplies both the device and the connection.
test_equitable_when_school_provides_device_and_internet if {
	policy.equitable with input as {"student": {"resources": {
		"has_school_provided_device": true,
		"has_school_provided_internet": true,
	}}}
}

# A device without a connection is not enough, and vice versa. This is the edge
# that matters in practice: a loaned laptop with no home broadband still leaves
# the student unable to complete the work.
test_not_equitable_with_device_but_no_internet if {
	not policy.equitable with input as {"student": {"resources": {
		"has_school_provided_device": true,
		"has_school_provided_internet": false,
	}}}
}

test_not_equitable_with_internet_but_no_device if {
	not policy.equitable with input as {"student": {"resources": {
		"has_school_provided_device": false,
		"has_school_provided_internet": true,
	}}}
}

# Route 3: the work is achievable on a basic device over a low-bandwidth link.
test_equitable_with_low_bandwidth_and_basic_device if {
	policy.equitable with input as {"assignment": {"requirements": {
		"bandwidth": "low",
		"device_spec": "basic",
	}}}
}

# Low bandwidth alone does not help if the work still needs a high-spec machine.
test_not_equitable_when_device_spec_is_high if {
	not policy.equitable with input as {"assignment": {"requirements": {
		"bandwidth": "low",
		"device_spec": "high",
	}}}
}

# An explicitly false offline alternative must not be read as a pass.
test_not_equitable_when_offline_alternative_is_false if {
	not policy.equitable with input as {"assignment": {"has_offline_alternative": false}}
}

# A denial carries an explanation for the reviewer.
#
# `deny` is a partial set and this package is declared across several files
# (equitable_admissions_systems.rego and unbiased_automated_grading.rego also
# contribute), so their messages merge into the same set. Asserting on the count
# would therefore couple this test to unrelated policies. Match this policy's own
# message instead.
test_deny_message_present_when_not_equitable if {
	some msg in policy.deny with input as {"assignment": {"has_offline_alternative": false}}
	contains(msg, "not equitable")
}

test_no_digital_divide_message_when_equitable if {
	msgs := {msg |
		some msg in policy.deny
		contains(msg, "not equitable")
	} with input as {"assignment": {"has_offline_alternative": true}}
	count(msgs) == 0
}
