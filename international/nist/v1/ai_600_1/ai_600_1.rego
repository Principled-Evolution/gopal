package international.nist.v1.ai_600_1

import rego.v1
import data.international.nist.v1.govern
import data.international.nist.v1.map
import data.international.nist.v1.measure
import data.international.nist.v1.manage

metadata := {
	"title": "NIST AI RMF Orchestrator",
	"description": "Orchestrates the NIST AI Risk Management Framework policies.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

allow if {
	govern.allow with input as {
        "governance": object.get(input, "governance", {}),
        "transparency": object.get(input, "transparency", {}),
        "fairness": object.get(input, "fairness", {})
    }
	map.allow with input as {"map": input.map}
	measure.allow with input as {"measure": input.measure}
	manage.allow with input as {"manage": input.manage}
}