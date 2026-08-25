package industry_specific.legal.v1.client_confidentiality_test

import data.industry_specific.legal.v1.client_confidentiality as policy
import rego.v1

compliant := {
	"data": {"client_confidential_information_entered": true, "privileged_material_entered": true},
	"tool": {
		"public_consumer_tool": false,
		"vendor_assessed": true,
		"contractual_safeguards": true,
		"technical_safeguards": true,
		"organisational_safeguards": true,
		"trains_on_input": false,
		"data_remains_in_secure_environment": true,
	},
}

test_allow_confidential_material_in_a_properly_controlled_tool if {
	policy.allow with input as compliant
}

# The specific harm the SRA warned about: client information pasted into a
# public consumer assistant, putting it in the public domain and waiving
# privilege. No other control compensates for this.
test_deny_confidential_material_in_a_public_consumer_tool if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/tool/public_consumer_tool", "value": true,
	}])
}

test_deny_when_tool_trains_on_input if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/tool/trains_on_input", "value": true,
	}])
}

test_deny_when_tool_not_assessed if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/tool/vendor_assessed", "value": false,
	}])
}

# All three safeguard types are required together.
test_deny_when_organisational_safeguards_missing if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/tool/organisational_safeguards", "value": false,
	}])
}

test_deny_when_data_leaves_secure_environment if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/tool/data_remains_in_secure_environment", "value": false,
	}])
}

# Privileged material alone engages the policy even if the confidentiality flag
# is not set.
test_privileged_material_alone_engages_the_policy if {
	not policy.allow with input as {
		"data": {"client_confidential_information_entered": false, "privileged_material_entered": true},
		"tool": {"public_consumer_tool": true},
	}
}

# No confidential or privileged material: a public tool is fine.
test_allow_public_tool_when_no_confidential_material if {
	policy.allow with input as {
		"data": {"client_confidential_information_entered": false, "privileged_material_entered": false},
		"tool": {"public_consumer_tool": true},
	}
}

test_report_names_the_failed_controls if {
	report := policy.report with input as json.patch(compliant, [
		{"op": "replace", "path": "/tool/public_consumer_tool", "value": true},
		{"op": "replace", "path": "/tool/vendor_assessed", "value": false},
	])
	report.metrics.confidentiality_controls_failed.value == [
		"tool assessed before use",
		"tool is not a public consumer assistant",
	]
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
