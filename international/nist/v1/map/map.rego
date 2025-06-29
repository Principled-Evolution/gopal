package international.nist.v1.map

import rego.v1

metadata := {
	"title": "NIST AI RMF - Map",
	"description": "Policies for the Map function of the NIST AI Risk Management Framework.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

# Allow if all map dimensions are compliant
allow if {
	system_context.allow
	data_provenance.allow
	system_limitations.allow
}

# System Context: Check for clear documentation of the system's context
system_context := { "allow": true, "msg": "System context requirements met." } if {
	# Placeholder: Check for documentation of the system's intended use
	input.map.intended_use_documented
	# Placeholder: Check for documentation of the system's architecture
	input.map.architecture_documented
} else := { "allow": false, "msg": "System context requirements not met." }

# Data Provenance: Check for clear documentation of data sources and lineage
data_provenance := { "allow": true, "msg": "Data provenance requirements met." } if {
	# Placeholder: Check for documentation of data sources
	input.map.data_sources_documented
	# Placeholder: Check for documentation of data processing steps
	input.map.data_processing_documented
} else := { "allow": false, "msg": "Data provenance requirements not met." }

# System Limitations: Check for clear documentation of the system's limitations
system_limitations := { "allow": true, "msg": "System limitations requirements met." } if {
	# Placeholder: Check for documentation of known limitations and potential failure modes
	input.map.known_limitations_documented
	# Placeholder: Check for documentation of out-of-scope use cases
	input.map.out_of_scope_use_cases_documented
} else := { "allow": false, "msg": "System limitations requirements not met." }
