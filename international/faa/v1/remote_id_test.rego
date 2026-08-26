package international.faa.v1.remote_id_test

import data.international.faa.v1.remote_id
import rego.v1

test_allow_with_standard_remote_id if {
	remote_id.allow with input as {
		"aircraft": {"standard_remote_id_equipped": true, "broadcast_module_attached": false},
		"operation": {"within_fria": false},
	}
}

test_allow_with_broadcast_module if {
	remote_id.allow with input as {
		"aircraft": {"standard_remote_id_equipped": false, "broadcast_module_attached": true},
		"operation": {"within_fria": false},
	}
}

test_allow_within_fria if {
	remote_id.allow with input as {
		"aircraft": {"standard_remote_id_equipped": false, "broadcast_module_attached": false},
		"operation": {"within_fria": true},
	}
}

test_deny_when_none_apply if {
	not remote_id.allow with input as {
		"aircraft": {"standard_remote_id_equipped": false, "broadcast_module_attached": false},
		"operation": {"within_fria": false},
	}
}

test_report_identifies_compliance_method if {
	report := remote_id.report with input as {
		"aircraft": {"standard_remote_id_equipped": true, "broadcast_module_attached": false},
		"operation": {"within_fria": false},
	}
	report.metrics.remote_id_compliance_method.value == "standard_remote_id"
}

# An unevaluated system must never satisfy allow. In Rego an undefined value is
# not false, so a permissive default or an undefined intermediate rule can let a
# system with no evidence pass.
test_allow_denies_on_empty_input if {
	not remote_id.allow with input as {}
}
