# RequiredMetrics:
#   - capacity.plan_documented
#   - capacity.peak_load_tested
#   - capacity.headroom_ratio
#   - latency.slo_defined
#   - latency.p99_within_slo
#   - resilience.autoscaling_configured
#   - resilience.graceful_degradation_documented
#
# RequiredParams: none
package operational.aiops.v1.scalability

import data.helper_functions.reporting
import rego.v1

metadata := {
	"title": "AIOps Scalability Requirements",
	"description": "Evaluates whether an AI system can carry its expected load. Inference workloads fail differently from ordinary services: capacity is often bounded by a rate-limited or GPU-bound dependency rather than by the service's own replicas, so this policy tests headroom against measured peak load and requires a documented degradation path for when the model tier is unavailable rather than treating autoscaling as sufficient on its own.",
	"version": "1.0.0",
	"category": "Operational",
	"references": [
		"NIST AI RMF 1.0, Manage 2.3 (system performance under expected and unexpected conditions)",
		"Google SRE Workbook, Managing Load",
	],
}

default capacity_planned := false

capacity_planned if {
	input.capacity.plan_documented == true
	input.capacity.peak_load_tested == true
}

# Headroom is measured against tested peak, not against average.
default headroom_sufficient := false

headroom_sufficient if {
	object.get(input, ["capacity", "headroom_ratio"], 0) >= 1.2
}

default latency_governed := false

latency_governed if {
	input.latency.slo_defined == true
	input.latency.p99_within_slo == true
}

default autoscaling_configured := false

autoscaling_configured if {
	input.resilience.autoscaling_configured == true
}

# Autoscaling cannot help when the bound is a rate-limited model provider, so a
# degradation path has to be documented regardless.
default degradation_documented := false

degradation_documented if {
	input.resilience.graceful_degradation_documented == true
}

default allow := false

allow if {
	capacity_planned
	headroom_sufficient
	latency_governed
	autoscaling_configured
	degradation_documented
}

failed_controls := [name |
	some name, satisfied in {
		"capacity plan documented and peak load tested": capacity_planned,
		"at least 20 percent headroom over tested peak": headroom_sufficient,
		"latency SLO defined and p99 within it": latency_governed,
		"autoscaling configured": autoscaling_configured,
		"graceful degradation path documented": degradation_documented,
	}
	satisfied == false
]

policy_metrics := {
	"scalability_controls_failed": {
		"name": "Scalability Controls Not Satisfied",
		"value": sort(failed_controls),
		"control_passed": count(failed_controls) == 0,
	},
	"headroom_ratio": {
		"name": "Headroom Over Tested Peak Load",
		"value": object.get(input, ["capacity", "headroom_ratio"], 0),
		"control_passed": headroom_sufficient,
	},
	"degradation_path": {
		"name": "Graceful Degradation Path Documented",
		"value": object.get(input, ["resilience", "graceful_degradation_documented"], false),
		"control_passed": degradation_documented,
	},
}

report := reporting.compose_report("aiops.scalability", allow, policy_metrics)
