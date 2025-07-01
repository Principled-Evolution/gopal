package industry_specific.education.v1.fairness_and_equity

# @title Detailed Digital Divide Mitigation
# @description This policy ensures that technology-based assignments provide equitable alternatives for students facing a digital divide.
# @version 1.1

# Default to not equitable unless mitigation strategies are in place.
default equitable := false

# --- Equity Rules ---

# Equitable if a comparable offline alternative is available.
equitable if {
	input.assignment.has_offline_alternative == true
}

# Equitable if the school provides all necessary resources (device and internet).
equitable if {
	input.student.resources.has_school_provided_device == true
	input.student.resources.has_school_provided_internet == true
}

# Equitable if the assignment can be completed with low-bandwidth or basic devices.
equitable if {
	input.assignment.requirements.bandwidth == "low"
	input.assignment.requirements.device_spec == "basic"
}

# --- Deny Messages ---

deny contains msg if {
	not equitable
	msg := "Assignment is not equitable. No sufficient alternative or resources provided for students impacted by the digital divide."
}
