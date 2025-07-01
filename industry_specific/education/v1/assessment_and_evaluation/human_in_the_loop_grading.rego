package industry_specific.education.v1.assessment_and_evaluation

# @title Detailed Human-in-the-Loop Grading
# @description This policy mandates human oversight for automated grading systems, especially for high-stakes assessments.
# @version 1.1

# Default to not compliant.
default human_in_the_loop_compliant := false

# --- Compliance Rules ---

# Compliant if a human reviews the grade, especially for high-stakes or low-confidence scores.
human_in_the_loop_compliant if {
	is_human_review_required(input.assessment)
	input.grading_process.human_reviewer_assigned == true
}

# Compliant if the assessment is low-stakes, where full automation is acceptable.
human_in_the_loop_compliant if {
	not is_human_review_required(input.assessment)
}

# --- Deny Messages ---

deny contains msg if {
	is_human_review_required(input.assessment)
	not input.grading_process.human_reviewer_assigned
	msg := sprintf("Human review is required for this %v assessment (final grade impact: %v%%), but no reviewer was assigned.", [input.assessment.type, input.assessment.final_grade_impact_percent])
}

# --- Helper Functions ---

# Determines if human review is required based on the assessment's weight or the AI's confidence.
is_human_review_required(assessment) if {
	assessment.type == "final_exam"
}

is_human_review_required(assessment) if {
	assessment.final_grade_impact_percent > 20
}

is_human_review_required(assessment) if {
	assessment.ai_confidence_score < 0.85
}
