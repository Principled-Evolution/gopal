package education.v1.safe_learning_environment

# @title Detailed Instructional Tool Vetting
# @description This policy ensures that third-party AI tools are properly vetted against security, privacy, and pedagogical standards before use.
# @version 1.1

# Default to not approved.
default approved = false

# --- Approval Rules ---

# Approved if the tool meets all vetting requirements.
approved if {
    has_passed_security_review(input.tool.vetting_report)
    has_passed_privacy_review(input.tool.vetting_report)
    has_passed_pedagogical_review(input.tool.vetting_report)
}


# --- Deny Messages ---

deny contains msg if {
    not approved
    failures := {failure |
        report := input.tool.vetting_report
        not has_passed_security_review(report); failure := "Security Review Failed"
    } | {failure |
        report := input.tool.vetting_report
        not has_passed_privacy_review(report); failure := "Privacy Review Failed"
    } | {failure |
        report := input.tool.vetting_report
        not has_passed_pedagogical_review(report); failure := "Pedagogical Review Failed"
    }
    msg := sprintf("Instructional tool '%v' is not approved. Vetting failures: %v", [input.tool.name, failures])
}


# --- Helper Functions ---

# Checks if the security review was passed.
has_passed_security_review(report) if {
    report.security.status == "passed"
    report.security.vulnerabilities == 0
}

# Checks if the privacy review was passed (e.g., FERPA/COPPA compliant).
has_passed_privacy_review(report) if {
    report.privacy.status == "passed"
    report.privacy.ferpa_compliant == true
    report.privacy.coppa_compliant == true
}

# Checks if the pedagogical review was passed (e.g., aligns with curriculum).
has_passed_pedagogical_review(report) if {
    report.pedagogy.status == "passed"
    report.pedagogy.curriculum_alignment > 0.8
}
