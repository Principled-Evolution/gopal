package industry_specific.aviation.v1.data_management.flight_data_test

import data.industry_specific.aviation.v1.data_management.flight_data
import rego.v1

test_allow_when_recording_and_retention_sufficient if {
	flight_data.allow with input as {"flight_data": {"recording_enabled": true, "retention_days": 120}, "params": {}}
}

test_deny_without_recording if {
	not flight_data.allow with input as {"flight_data": {"recording_enabled": false, "retention_days": 120}, "params": {}}
}

test_deny_with_insufficient_retention if {
	not flight_data.allow with input as {"flight_data": {"recording_enabled": true, "retention_days": 30}, "params": {}}
}

test_allow_with_custom_retention_param if {
	flight_data.allow with input as {"flight_data": {"recording_enabled": true, "retention_days": 30}, "params": {"min_retention_days": 30}}
}
