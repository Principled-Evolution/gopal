package industry_specific.education.v1.safe_learning_environment_test

import data.industry_specific.education.v1.safe_learning_environment as policy
import rego.v1

# Content we know nothing about is not appropriate for anyone.
test_appropriate_denies_on_empty_input if {
	not policy.appropriate with input as {}
}

# The age_rating_map floors are K-2:5, 3-5:8, 6-8:11, 9-12:14, Post-12:18.
test_appropriate_when_student_meets_age_floor if {
	policy.appropriate with input as {
		"content": {"age_rating": "3-5"},
		"student": {"age": 8},
	}
}

test_appropriate_when_student_is_older_than_floor if {
	policy.appropriate with input as {
		"content": {"age_rating": "K-2"},
		"student": {"age": 17},
	}
}

# One year under the floor must fail, since this is the boundary a real
# deployment gets wrong.
test_not_appropriate_when_student_is_one_year_under_floor if {
	not policy.appropriate with input as {
		"content": {"age_rating": "9-12"},
		"student": {"age": 13},
	}
}

test_not_appropriate_for_post_12_content_shown_to_a_minor if {
	not policy.appropriate with input as {
		"content": {"age_rating": "Post-12"},
		"student": {"age": 12},
	}
}

# An age rating outside the map has no floor to compare against, so
# is_suitable_for_age is undefined and the content must not be approved.
test_not_appropriate_for_unknown_age_rating if {
	not policy.appropriate with input as {
		"content": {"age_rating": "Adults-Only"},
		"student": {"age": 40},
	}
}

# A missing student age must not pass, whatever the rating says.
test_not_appropriate_when_student_age_absent if {
	not policy.appropriate with input as {"content": {"age_rating": "K-2"}}
}

# Instructor approval is an independent route: content the instructor has
# cleared for this lesson is appropriate even without a usable age rating.
test_appropriate_when_instructor_approved_the_content if {
	policy.appropriate with input as {
		"content": {"id": "vid-42", "age_rating": "Post-12"},
		"student": {"age": 11},
		"lesson": {"approved_content_ids": ["vid-41", "vid-42"]},
	}
}

# Approval is per item, so an unlisted id is not covered by a sibling's approval.
test_not_appropriate_when_content_id_not_in_approved_list if {
	not policy.appropriate with input as {
		"content": {"id": "vid-99", "age_rating": "Post-12"},
		"student": {"age": 11},
		"lesson": {"approved_content_ids": ["vid-41", "vid-42"]},
	}
}
