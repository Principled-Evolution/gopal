package industry_specific.education.v1.fairness_and_equity

# @title Detailed Equitable Admissions Systems
# @description This policy evaluates AI-driven admissions systems to ensure they do not create or amplify inequities.
# @version 1.1

# Default to not compliant if fairness metrics are not met.
default equitable_admissions_systems_compliant := false

# --- Compliance Rules ---

# Compliant if the model does not use prohibited features and meets fairness thresholds.
equitable_admissions_systems_compliant if {
	not uses_prohibited_features(input.admissions_model.features, prohibited_features)
	every group in input.bias_report.demographic_groups {
		every metric in group.fairness_metrics {
			is_within_threshold(metric, thresholds)
		}
	}
}

# --- Deny Messages ---

deny contains msg if {
	uses_prohibited_features(input.admissions_model.features, prohibited_features)
	prohibited := {feature | some feature in input.admissions_model.features; is_prohibited(feature, prohibited_features)}
	msg := sprintf("Admissions model is not compliant. It uses prohibited features: %v", [prohibited])
}

deny contains msg if {
	not equitable_admissions_systems_compliant
	not uses_prohibited_features(input.admissions_model.features, prohibited_features)
	failing_metrics := {metric |
		some group in input.bias_report.demographic_groups
		some metric in group.fairness_metrics
		not is_within_threshold(metric, thresholds)
	}
	msg := sprintf("Admissions model is not compliant. Fairness metrics are not met: %v", [failing_metrics])
}

# --- Helper Functions ---

# Defines prohibited features for admissions models.
prohibited_features := {"race", "gender", "zip_code_proxy"}

is_prohibited(feature, prohibited) if {
	feature in prohibited
}

uses_prohibited_features(features, prohibited) if {
	some feature in features
	is_prohibited(feature, prohibited)
}

# Defines acceptable thresholds for different fairness metrics.
thresholds := {
	"demographic_parity": 0.1,
	"equalized_odds": 0.1,
}

is_within_threshold(metric, thresholds) if {
	abs(metric.value) < thresholds[metric.name]
}
