# Healthcare Policies

This directory encodes general healthcare-AI safety principles (patient safety, diagnostic-system fairness and content-safety thresholds), informed by HIPAA and EU AI Act healthcare-relevant provisions rather than one single named statute.

- `diagnostic_safety/diagnostic_safety.rego`: fairness, content-safety, and risk-management thresholds for multi-specialist diagnostic AI systems. See its own [README](diagnostic_safety/README.md) for details and an AICertify usage example.
- `patient_safety/patient_safety.rego`: currently a scaffold (`default allow := false` placeholder); not yet implemented.

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
