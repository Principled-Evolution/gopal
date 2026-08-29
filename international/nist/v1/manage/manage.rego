package international.nist.v1.manage

import data.helper_functions.declarations
import rego.v1

metadata := {
	"title": "NIST AI RMF - Manage",
	"description": "Policies for the Manage function of the NIST AI Risk Management Framework.",
	"version": "1.0.0",
	"category": "NIST AI RMF",
	"references": ["NIST AI Risk Management Framework: https://www.nist.gov/itl/ai-risk-management-framework"],
}

# Default deny
default allow := false

# Allow if all manage dimensions are compliant
allow if {
	risk_mitigation.allow
	continuous_monitoring.allow
	incident_response.allow
}

# Risk Mitigation: Check for strategies to mitigate identified risks
default risk_mitigation := {"allow": false, "msg": "Risk mitigation requirements not met."}

risk_mitigation := {"allow": true, "msg": "Risk mitigation requirements met."} if {
	# Check for documented risk mitigation strategies
	declarations.resolve(input, ["manage", "risk_mitigation_strategies_documented"])

	# Check for implementation of risk mitigation strategies
	declarations.resolve(input, ["manage", "risk_mitigation_strategies_implemented"])
}

# Continuous Monitoring: Check for processes to continuously monitor the system
default continuous_monitoring := {"allow": false, "msg": "Continuous monitoring requirements not met."}

continuous_monitoring := {"allow": true, "msg": "Continuous monitoring requirements met."} if {
	# Check for a continuous monitoring plan
	declarations.resolve(input, ["manage", "continuous_monitoring_plan_in_place"])

	# Check for regular execution of the monitoring plan
	declarations.resolve(input, ["manage", "continuous_monitoring_plan_executed"])
}

# Incident Response: Check for a plan to respond to incidents
default incident_response := {"allow": false, "msg": "Incident response requirements not met."}

incident_response := {"allow": true, "msg": "Incident response requirements met."} if {
	# Check for an incident response plan
	declarations.resolve(input, ["manage", "incident_response_plan_in_place"])

	# Check for regular testing of the incident response plan
	declarations.resolve(input, ["manage", "incident_response_plan_tested"])
}
