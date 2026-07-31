package international.easa.v1.sora_test

import data.international.easa.v1.sora
import rego.v1

test_allow_when_fully_assessed_and_mitigated if {
	sora.allow with input as {
		"assessment": {"ground_risk_class": 4, "air_risk_class": "b", "sail_determined": true},
		"mitigations": {"adequate": true},
	}
}

test_deny_without_ground_risk_class if {
	not sora.allow with input as {
		"assessment": {"ground_risk_class": 0, "air_risk_class": "b", "sail_determined": true},
		"mitigations": {"adequate": true},
	}
}

test_deny_with_invalid_air_risk_class if {
	not sora.allow with input as {
		"assessment": {"ground_risk_class": 4, "air_risk_class": "z", "sail_determined": true},
		"mitigations": {"adequate": true},
	}
}

test_deny_without_sail_determined if {
	not sora.allow with input as {
		"assessment": {"ground_risk_class": 4, "air_risk_class": "b", "sail_determined": false},
		"mitigations": {"adequate": true},
	}
}

test_deny_without_adequate_mitigations if {
	not sora.allow with input as {
		"assessment": {"ground_risk_class": 4, "air_risk_class": "b", "sail_determined": true},
		"mitigations": {"adequate": false},
	}
}
