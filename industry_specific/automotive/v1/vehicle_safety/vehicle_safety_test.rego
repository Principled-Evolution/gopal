package industry_specific.automotive.v1.vehicle_safety_test

import rego.v1

import data.industry_specific.automotive.v1.vehicle_safety

# Test case for a compliant AI system
test_compliant_system if {
	vehicle_safety.compliant with input as {"safety_assessment": {
		"hara_analysis": {
			"status": "completed",
			"identified_hazards": [
				{"id": "H-001", "description": "Unintended acceleration"},
				{"id": "H-002", "description": "Unintended braking"},
			],
		},
		"asil_determination": {
			"status": "completed",
			"final_asil_level": "ASIL D",
		},
		"sotif_analysis": {
			"status": "completed",
			"scenarios_analyzed": [
				{"id": "S-001", "description": "Sensor failure in heavy rain"},
				{"id": "S-002", "description": "Misinterpretation of road signs"},
			],
		},
		"odd_definition": {
			"status": "defined",
			"conditions": {
				"road_types": ["highway", "urban"],
				"weather": ["clear", "rain"],
				"traffic": ["light", "moderate"],
			},
		},
	}}
}

# Test case for a non-compliant system (missing HARA)
test_missing_hara if {
	vehicle_safety.deny["Hazard Analysis and Risk Assessment (HARA) is incomplete or missing."] with input as {"safety_assessment": {
		"asil_determination": {
			"status": "completed",
			"final_asil_level": "ASIL C",
		},
		"sotif_analysis": {
			"status": "completed",
			"scenarios_analyzed": [{"id": "S-001", "description": "Sensor failure in heavy rain"}],
		},
		"odd_definition": {
			"status": "defined",
			"conditions": {
				"road_types": ["highway"],
				"weather": ["clear"],
				"traffic": ["light"],
			},
		},
	}}
}
