package industry_specific.education.v1.safe_learning_environment_test

import data.industry_specific.education.v1.safe_learning_environment as policy
import rego.v1

passing_report := {
	"security": {"status": "passed", "vulnerabilities": 0},
	"privacy": {"status": "passed", "ferpa_compliant": true, "coppa_compliant": true},
	"pedagogy": {"status": "passed", "curriculum_alignment": 0.9},
}

# A tool with no vetting report at all is not approved.
test_approved_denies_on_empty_input if {
	not policy.approved with input as {}
}

test_approved_when_all_three_reviews_pass if {
	policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": passing_report}}
}

# All three reviews are required, so each one is tested in isolation by breaking
# only that review and leaving the other two passing.
test_not_approved_when_security_status_not_passed if {
	report := json.patch(passing_report, [{
		"op": "replace",
		"path": "/security/status",
		"value": "failed",
	}])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}

# A passed security review that still lists open vulnerabilities must not count.
test_not_approved_when_security_has_open_vulnerabilities if {
	report := json.patch(passing_report, [{
		"op": "replace",
		"path": "/security/vulnerabilities",
		"value": 1,
	}])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}

test_not_approved_when_not_ferpa_compliant if {
	report := json.patch(passing_report, [{
		"op": "replace",
		"path": "/privacy/ferpa_compliant",
		"value": false,
	}])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}

test_not_approved_when_not_coppa_compliant if {
	report := json.patch(passing_report, [{
		"op": "replace",
		"path": "/privacy/coppa_compliant",
		"value": false,
	}])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}

# Curriculum alignment must exceed 0.8, so the boundary value itself fails.
test_not_approved_when_curriculum_alignment_is_exactly_the_threshold if {
	report := json.patch(passing_report, [{
		"op": "replace",
		"path": "/pedagogy/curriculum_alignment",
		"value": 0.8,
	}])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}

# A report missing a whole section leaves its check undefined, which must deny
# rather than being skipped over.
test_not_approved_when_pedagogy_section_absent if {
	report := object.remove(passing_report, ["pedagogy"])
	not policy.approved with input as {"tool": {"name": "TutorBot", "vetting_report": report}}
}
