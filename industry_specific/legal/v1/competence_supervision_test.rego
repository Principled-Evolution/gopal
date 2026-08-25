package industry_specific.legal.v1.competence_supervision_test

import data.industry_specific.legal.v1.competence_supervision as policy
import rego.v1

compliant := {
	"practitioner": {
		"uses_ai_for_regulated_work": true,
		"technology_competence_maintained": true,
		"training_completed": true,
	},
	"firm": {
		"ai_risk_assessment_before_adoption": true,
		"supervision_system_in_place": true,
		"supervisor_named": true,
	},
	"client": {"ai_use_material": true, "ai_use_disclosed_where_material": true},
}

test_allow_when_governance_is_in_place if {
	policy.allow with input as compliant
}

test_deny_without_technology_competence if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/practitioner/technology_competence_maintained", "value": false,
	}])
}

test_deny_without_training if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/practitioner/training_completed", "value": false,
	}])
}

# Adopting a tool and assessing it afterwards is not assessing it before
# adoption.
test_deny_without_risk_assessment_before_adoption if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/firm/ai_risk_assessment_before_adoption", "value": false,
	}])
}

# A supervision policy with nobody named in it is not effective supervision.
test_deny_when_no_supervisor_named if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/firm/supervisor_named", "value": false,
	}])
}

test_deny_without_supervision_system if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/firm/supervision_system_in_place", "value": false,
	}])
}

# Disclosure is required where the use of AI is material to the client.
test_deny_material_ai_use_not_disclosed if {
	not policy.allow with input as json.patch(compliant, [{
		"op": "replace", "path": "/client/ai_use_disclosed_where_material", "value": false,
	}])
}

test_allow_immaterial_ai_use_without_disclosure if {
	policy.allow with input as json.patch(compliant, [
		{"op": "replace", "path": "/client/ai_use_material", "value": false},
		{"op": "replace", "path": "/client/ai_use_disclosed_where_material", "value": false},
	])
}

# A practitioner not using AI for regulated work is out of scope.
test_allow_when_ai_not_used_for_regulated_work if {
	policy.allow with input as {"practitioner": {"uses_ai_for_regulated_work": false}}
}

test_deny_on_empty_input if {
	not policy.allow with input as {}
}
