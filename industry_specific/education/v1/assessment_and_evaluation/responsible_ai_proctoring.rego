package industry_specific.education.v1.assessment_and_evaluation

# @title Detailed Responsible AI Proctoring
# @description This policy ensures that AI proctoring systems are used responsibly, respecting student privacy and providing due process.
# @version 1.1

# Default to not compliant.
default responsible_ai_proctoring_compliant := false

# --- Compliance Rules ---

# Compliant if student consent is obtained, data handling is secure, and an appeals process exists.
responsible_ai_proctoring_compliant if {
	input.proctoring_session.student_consent_given == true
	is_data_handling_secure(input.proctoring_session.data_handling)
	has_human_review_and_appeals(input.proctoring_session.review_process)
}

# --- Deny Messages ---

deny contains msg if {
	not responsible_ai_proctoring_compliant
	failures := ({failure |
		not input.proctoring_session.student_consent_given
		failure := "Student consent not given"
	} | {failure |
		not is_data_handling_secure(input.proctoring_session.data_handling)
		failure := "Insecure data handling"
	}) | {failure |
		not has_human_review_and_appeals(input.proctoring_session.review_process)
		failure := "Lack of human review or appeals process"
	}
	msg := sprintf("AI proctoring session is not compliant. Failures: %v", [failures])
}

# --- Helper Functions ---

# Checks for secure data handling practices.
is_data_handling_secure(handling) if {
	handling.encryption_enabled == true
	handling.data_retention_period_days <= 30
}

# Checks for a robust human review and appeals process.
has_human_review_and_appeals(process) if {
	process.human_review_required_for_all_flags == true
	process.student_appeal_possible == true
}
