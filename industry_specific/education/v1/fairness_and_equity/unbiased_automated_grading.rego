package education.v1.fairness_and_equity

# @title Detailed Unbiased Automated Grading
# @description This policy evaluates automated grading systems to ensure they are fair and equitable across different demographic groups.
# @version 1.1

# Default to not compliant if fairness metrics are not met.
default compliant = false

# --- Compliance Rules ---

# Compliant if the model's bias metrics are within acceptable thresholds for all demographic groups.
compliant if {
    every group in input.bias_report.demographic_groups {
        every metric in group.fairness_metrics {
            is_within_threshold(metric)
        }
    }
}


# --- Deny Messages ---

deny contains msg if {
    not compliant
    failing_metrics := {metric |
        some group in input.bias_report.demographic_groups
        some metric in group.fairness_metrics
        not is_within_threshold(metric)
    }
    msg := sprintf("Automated grading model is not compliant. Fairness metrics are not met: %v", [failing_metrics])
}


# --- Helper Functions ---

# Defines acceptable thresholds for different fairness metrics.
thresholds := {
    "equal_opportunity_difference": 0.05,
    "average_odds_difference": 0.05,
    "disparate_impact": 0.8 # Should be above this value
}

# Checks if a given metric is within its acceptable threshold.
is_within_threshold(metric) if {
    metric.name == "disparate_impact"
    metric.value >= thresholds[metric.name]
}

is_within_threshold(metric) if {
    metric.name != "disparate_impact"
    abs(metric.value) < thresholds[metric.name]
}
