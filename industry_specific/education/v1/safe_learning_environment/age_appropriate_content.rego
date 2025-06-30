package education.v1.safe_learning_environment

# @title Detailed Age-Appropriate Content
# @description This policy evaluates whether AI-generated content is appropriate for the student's age and the educational context.
# @version 1.1

# Default to not appropriate.
default appropriate := false

# --- Appropriateness Rules ---

# Appropriate if the content's age rating is suitable for the student's age.
appropriate if {
	is_suitable_for_age(input.content.age_rating, input.student.age, age_rating_map)
}

# Appropriate if the content has been explicitly approved by the instructor for this lesson.
appropriate if {
	input.content.id in input.lesson.approved_content_ids
}

# --- Deny Messages ---

deny contains msg if {
	not appropriate
	msg := sprintf("Content with age rating '%v' is not appropriate for a student of age %v.", [input.content.age_rating, input.student.age])
}

# --- Helper Functions ---

# Defines the mapping of age ratings to minimum required ages.
age_rating_map := {
	"K-2": 5,
	"3-5": 8,
	"6-8": 11,
	"9-12": 14,
	"Post-12": 18,
}

# Checks if the content's age rating is suitable for the student's age.
is_suitable_for_age(rating, age, age_map) if {
	min_age := age_map[rating]
	age >= min_age
}
