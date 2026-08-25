package international.nist.v1.ai_600_1

import data.international.nist.v1.govern
import data.international.nist.v1.manage
import data.international.nist.v1.map
import data.international.nist.v1.measure
import rego.v1

metadata := {
	"title": "NIST AI RMF Orchestrator",
	"description": "Orchestrates the NIST AI Risk Management Framework policies.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

# Delegate to the four NIST AI RMF function policies. Each carries its own
# default deny, so a missing or incomplete section denies here too.
allow if {
	govern.allow
	map.allow
	measure.allow
	manage.allow
}
