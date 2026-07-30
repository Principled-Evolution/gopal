package international.standards.v1.rtca_do_365_test

import data.international.standards.v1.rtca_do_365
import rego.v1

test_allow_when_fully_compliant if {
	rtca_do_365.allow with input as {
		"daa_system": {"equipped": true, "surveillance_volume_nm": 2.5, "alert_timeliness_compliant": true},
		"params": {},
	}
}

test_deny_when_not_equipped if {
	not rtca_do_365.allow with input as {
		"daa_system": {"equipped": false, "surveillance_volume_nm": 2.5, "alert_timeliness_compliant": true},
		"params": {},
	}
}

test_deny_when_surveillance_volume_below_minimum if {
	not rtca_do_365.allow with input as {
		"daa_system": {"equipped": true, "surveillance_volume_nm": 0.5, "alert_timeliness_compliant": true},
		"params": {},
	}
}

test_deny_when_alerts_not_timely if {
	not rtca_do_365.allow with input as {
		"daa_system": {"equipped": true, "surveillance_volume_nm": 2.5, "alert_timeliness_compliant": false},
		"params": {},
	}
}

test_allow_with_custom_minimum_param if {
	rtca_do_365.allow with input as {
		"daa_system": {"equipped": true, "surveillance_volume_nm": 3.5, "alert_timeliness_compliant": true},
		"params": {"min_surveillance_volume_nm": 3.0},
	}
}
