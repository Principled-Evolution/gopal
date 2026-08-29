# RequiredMetrics:
#   - data.client_confidential_information_entered
#   - tool.public_consumer_tool
#   - tool.vendor_assessed
#   - tool.trains_on_input
#   - tool.data_remains_in_secure_environment
#   - tool.contractual_safeguards
#
# RequiredParams: none
package industry_specific.legal.v1.client_confidentiality

import data.helper_functions.declarations
import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "Client Confidentiality and Privilege in Legal AI Tools",
	"description": "Evaluates whether client confidential or privileged material may be entered into a given AI tool. The regulators' concern is concrete: entering client information into a public consumer assistant places it in the public domain and can waive legal professional privilege irretrievably. Where confidential material is involved, the tool must be assessed and backed by contractual, technical and organisational safeguards, must not train on the input, and client data must stay inside a secure environment.",
	"version": "1.0.0",
	"category": "Industry Specific",
	"references": [
		"SRA warning notice, misuse of AI (August 2026)",
		"SRA Code of Conduct for Solicitors, paragraph 6.3 (confidentiality)",
		"SRA Code of Conduct for Firms, paragraph 6.3 (confidentiality)",
		"BSB Handbook Core Duty 6 and rC86, confidentiality",
		"Bar Standards Board, guidance on the use of AI and other technologies (18 May 2026)",
	],
}

default scope_determined := false

scope_determined if {
	is_boolean(declarations.resolve(input, ["data", "client_confidential_information_entered"]))
}

default confidential_material_involved := false

confidential_material_involved if {
	declarations.resolve(input, ["data", "client_confidential_information_entered"]) == true
}

confidential_material_involved if {
	declarations.resolve(input, ["data", "privileged_material_entered"]) == true
}

# A public consumer assistant is never an acceptable destination for client
# confidential material, whatever other controls a firm has.
default public_consumer_tool := false

public_consumer_tool if {
	declarations.resolve(input, ["tool", "public_consumer_tool"]) == true
}

default tool_assessed := false

tool_assessed if {
	declarations.resolve(input, ["tool", "vendor_assessed"]) == true
}

default safeguards_in_place := false

safeguards_in_place if {
	declarations.resolve(input, ["tool", "contractual_safeguards"]) == true
	declarations.resolve(input, ["tool", "technical_safeguards"]) == true
	declarations.resolve(input, ["tool", "organisational_safeguards"]) == true
}

default tool_is_not_public := false

tool_is_not_public if {
	not public_consumer_tool
}

default data_contained := false

data_contained if {
	declarations.resolve(input, ["tool", "trains_on_input"]) == false
	declarations.resolve(input, ["tool", "data_remains_in_secure_environment"]) == true
}

default allow := false

# No confidential or privileged material is involved.
allow if {
	scope_determined
	not confidential_material_involved
}

allow if {
	scope_determined
	confidential_material_involved
	not public_consumer_tool
	tool_assessed
	safeguards_in_place
	data_contained
}

failed_controls := [name |
	some name, satisfied in {
		"tool is not a public consumer assistant": tool_is_not_public,
		"tool assessed before use": tool_assessed,
		"contractual, technical and organisational safeguards": safeguards_in_place,
		"input not used for training and data held in a secure environment": data_contained,
	}
	satisfied == false
]

policy_metrics := {
	"confidentiality_controls_failed": {
		"name": "Confidentiality Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"privilege_at_risk": {
		"name": "Confidential Material Entered Into a Public Consumer Tool",
		"value": public_consumer_tool,
		"control_passed": allow,
	},
}

report := reporting.compose_report("legal.client_confidentiality", allow, policy_metrics)
