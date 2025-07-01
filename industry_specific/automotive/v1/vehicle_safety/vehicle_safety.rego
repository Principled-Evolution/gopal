package industry_specific.automotive.v1.vehicle_safety

import rego.v1

# @title Automotive Vehicle Safety Requirements
# @description This policy evaluates AI systems in automotive applications for compliance with key safety standards, including ISO 26262 and ISO/PAS 21448 (SOTIF).
# @version 1.0
# @source ISO 26262: https://www.iso.org/standard/68383.html
# @source ISO/PAS 21448 SOTIF: https://www.iso.org/standard/70939.html
# @source UNECE Regulations on Automated Driving: https://unece.org/transport/vehicle-regulations/wp29/wp29-regulations-under-1958-agreement

default compliant := false

compliant if {
	count(deny) == 0
}

# Hazard Analysis and Risk Assessment (HARA)
default hara_analysis_is_compliant := false

hara_analysis_is_compliant if {
	# Check for the presence of a comprehensive safety assessment in the input
	input.safety_assessment

	# Check for the presence of a HARA analysis
	input.safety_assessment.hara_analysis
	input.safety_assessment.hara_analysis.status == "completed"
	count(input.safety_assessment.hara_analysis.identified_hazards) > 0
}

# Automotive Safety Integrity Level (ASIL) Determination
asil_determination_is_compliant if {
	object.get(input.safety_assessment, "asil_determination", false)
	is_object(input.safety_assessment.asil_determination)
	input.safety_assessment.asil_determination.status == "completed"
	is_string(input.safety_assessment.asil_determination.final_asil_level)
	input.safety_assessment.asil_determination.final_asil_level in ["ASIL A", "ASIL B", "ASIL C", "ASIL D", "QM"]
}

# Safety of the Intended Functionality (SOTIF) Analysis
sotif_analysis_is_compliant if {
	object.get(input.safety_assessment, "sotif_analysis", false)
	is_object(input.safety_assessment.sotif_analysis)
	input.safety_assessment.sotif_analysis.status == "completed"
	count(input.safety_assessment.sotif_analysis.scenarios_analyzed) > 0
}

# Operational Design Domain (ODD) Definition
odd_definition_is_compliant if {
	object.get(input.safety_assessment, "odd_definition", false)
	is_object(input.safety_assessment.odd_definition)
	input.safety_assessment.odd_definition.status == "defined"
	object.get(input.safety_assessment.odd_definition.conditions, "road_types", false)
	object.get(input.safety_assessment.odd_definition.conditions, "weather", false)
	object.get(input.safety_assessment.odd_definition.conditions, "traffic", false)
}

# Deny rule with detailed messages
deny[msg] if {
	not hara_analysis_is_compliant
	msg := "Hazard Analysis and Risk Assessment (HARA) is incomplete or missing."
}

# deny[msg] if {
# 	not asil_determination_is_compliant
# 	msg := "ASIL Determination is incomplete or invalid."
# }
# deny[msg] if {
# 	not sotif_analysis_is_compliant
# 	msg := "Safety of the Intended Functionality (SOTIF) analysis is incomplete or missing."
# }
# deny[msg] if {
# 	not odd_definition_is_compliant
# 	msg := "Operational Design Domain (ODD) is not clearly defined or is missing required conditions."
# }
