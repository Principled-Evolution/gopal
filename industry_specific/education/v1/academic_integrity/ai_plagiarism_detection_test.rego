package industry_specific.education.v1.academic_integrity_test

import data.industry_specific.education.v1.academic_integrity as policy
import rego.v1

# With no submission at all there is nothing to flag.
#
# Note on direction: unlike the approval policies in this library, `false` here
# is the permissive answer, because this rule raises a concern rather than
# granting one. A caller that treats `not flag_for_review` as "this submission
# is clean" would therefore read a missing detection report as clean. Callers
# should check that input.submission.ai_detection_reports is actually present
# before drawing that conclusion.
test_flag_for_review_is_false_on_empty_input if {
	not policy.flag_for_review with input as {}
}

# Route 1: the mean of all detector scores exceeds 0.90.
test_flag_when_average_score_exceeds_threshold if {
	policy.flag_for_review with input as {"submission": {"ai_detection_reports": [
		{"detector_confidence": "low", "ai_score": 0.94},
		{"detector_confidence": "low", "ai_score": 0.92},
	]}}
}

# Just under the mean threshold, with no single high-confidence hit, is not flagged.
test_no_flag_when_average_is_below_threshold if {
	not policy.flag_for_review with input as {"submission": {"ai_detection_reports": [
		{"detector_confidence": "low", "ai_score": 0.5},
		{"detector_confidence": "low", "ai_score": 0.6},
	]}}
}

# Route 2: one high-confidence detector above 0.95 is enough on its own, even
# when the average across detectors stays low.
test_flag_on_single_high_confidence_detector if {
	policy.flag_for_review with input as {"submission": {"ai_detection_reports": [
		{"detector_confidence": "high", "ai_score": 0.96},
		{"detector_confidence": "low", "ai_score": 0.01},
	]}}
}

# The same score from a low-confidence detector does not trigger route 2.
test_no_flag_on_high_score_from_low_confidence_detector if {
	not policy.flag_for_review with input as {"submission": {"ai_detection_reports": [
		{"detector_confidence": "low", "ai_score": 0.96},
		{"detector_confidence": "low", "ai_score": 0.01},
	]}}
}

# Route 2 uses a strict inequality, so a high-confidence score of exactly 0.95
# does not flag on its own. A second low score keeps the mean under route 1's
# 0.90 threshold, so this isolates the boundary rather than tripping the average.
test_no_flag_when_high_confidence_score_is_exactly_the_threshold if {
	not policy.flag_for_review with input as {"submission": {"ai_detection_reports": [
		{"detector_confidence": "high", "ai_score": 0.95},
		{"detector_confidence": "low", "ai_score": 0.10},
	]}}
}

# The two routes are genuinely independent: a single report at exactly 0.95 is
# still flagged, because the mean of one score clears route 1's 0.90 threshold.
test_flag_on_single_report_at_threshold_via_average_route if {
	policy.flag_for_review with input as {"submission": {"ai_detection_reports": [{
		"detector_confidence": "high",
		"ai_score": 0.95,
	}]}}
}

# An empty report list must not flag, and must not error either: all_scores
# requires a non-empty list, so avg falls through to its 0 default.
test_no_flag_on_empty_report_list if {
	not policy.flag_for_review with input as {"submission": {"ai_detection_reports": []}}
}

# A flagged submission explains itself to the reviewer.
test_deny_message_present_when_flagged if {
	count(policy.deny) > 0 with input as {"submission": {"ai_detection_reports": [{
		"detector_confidence": "high",
		"ai_score": 0.99,
	}]}}
}
