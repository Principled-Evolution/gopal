package helper_functions.declarations_test

import data.helper_functions.declarations as d
import rego.v1

# A bare value, which is how nearly every input in the wild is written and how
# every existing policy reads. Attestation is an addition, not a migration.
bare := {"ce_marking": {"affixed": true}}

attested := {
	"evaluated_at": "2026-08-29T00:00:00Z",
	"ce_marking": {"affixed": {
		"value": true,
		"asserted_by": "j.smith@example.com",
		"asserted_at": "2026-03-01T00:00:00Z",
		"evidence": "https://grc.example.com/attestation/8814",
		"expires": "2027-03-01T00:00:00Z",
	}},
}

expired := {
	"evaluated_at": "2026-08-29T00:00:00Z",
	"ce_marking": {"affixed": {
		"value": true,
		"asserted_by": "j.smith@example.com",
		"expires": "2026-01-01T00:00:00Z",
	}},
}

path := ["ce_marking", "affixed"]

test_a_bare_value_resolves if {
	d.resolve(bare, path) == true
}

test_an_attestation_resolves_to_its_value if {
	d.resolve(attested, path) == true
}

# The point of the whole file. A stale assertion must not read as a live one.
test_an_expired_attestation_does_not_resolve if {
	not d.resolve(expired, path)
}

# Undefined, not false. The claim has not been refuted, it has gone out of date,
# and a report that cannot tell those apart sends the wrong person to fix it.
# Comparing an undefined value is itself undefined, so `resolve(...) != false`
# cannot express this. A sentinel can: if the stale attestation resolved to
# `false` rather than to nothing, resolve_or would hand back `false` instead of
# the sentinel.
test_expiry_is_undefined_rather_than_false if {
	d.resolve_or(expired, path, "ABSENT") == "ABSENT"
	not d.supplied(expired, path)
	d.stale(expired, path)
}

test_absent_is_not_stale if {
	not d.stale({"evaluated_at": "2026-08-29T00:00:00Z"}, path)
	not d.supplied({}, path)
}

test_supplied_distinguishes_live_from_stale_and_absent if {
	d.supplied(attested, path)
	not d.supplied(expired, path)
	not d.supplied({}, path)
}

# Without a clock nothing expires. An input written by hand should not have its
# declarations voided because it failed to say what day it is; expiry is opted
# into by stating when the evaluation happened.
test_no_evaluated_at_means_nothing_expires if {
	undated := object.remove(expired, {"evaluated_at"})
	d.resolve(undated, path) == true
	not d.stale(undated, path)
}

test_an_attestation_without_an_expiry_never_goes_stale if {
	forever := {
		"evaluated_at": "2099-01-01T00:00:00Z",
		"ce_marking": {"affixed": {"value": true, "asserted_by": "someone"}},
	}
	d.resolve(forever, path) == true
	not d.stale(forever, path)
}

# The boundary. An attestation expiring at the instant of evaluation has
# expired, because "valid until" is a moment it stops being valid.
test_expiry_is_inclusive_of_the_instant if {
	edge := {
		"evaluated_at": "2026-08-29T00:00:00Z",
		"ce_marking": {"affixed": {"value": true, "expires": "2026-08-29T00:00:00Z"}},
	}
	not d.resolve(edge, path)
}

test_a_false_declaration_is_still_false if {
	no := {"ce_marking": {"affixed": {"value": false, "asserted_by": "someone"}}}
	d.resolve(no, path) == false
	d.supplied(no, path)
}

# An object that is genuinely the declared value, rather than an attestation
# wrapper. Policies read structured facts too, and a value key is what
# distinguishes the two.
test_a_plain_object_value_is_not_mistaken_for_an_attestation if {
	structured := {"datasets": {"training": {"documented": true, "size": 4}}}
	d.resolve(structured, ["datasets", "training"]) == {"documented": true, "size": 4}
}

test_resolve_or_returns_the_fallback_when_stale if {
	d.resolve_or(expired, path, -1) == -1
	d.resolve_or(attested, path, -1) == true
	d.resolve_or({}, path, "unknown") == "unknown"
}

test_attribution_reports_who_and_when if {
	who := d.attribution(attested, path)
	who.asserted_by == "j.smith@example.com"
	who.evidence == "https://grc.example.com/attestation/8814"
}

# A bare value has no attribution, and saying so is more useful than inventing
# one. It is the difference between an unsigned claim and a signed one.
test_a_bare_value_has_no_attribution if {
	not d.attribution(bare, path)
}

test_empty_input_supplies_nothing if {
	not d.resolve({}, path)
	not d.supplied({}, path)
	not d.stale({}, path)
	d.resolve_or({}, path, "none") == "none"
}
