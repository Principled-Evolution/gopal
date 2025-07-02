# EASA (European Union Aviation Safety Agency) Policies

This directory contains OPA Rego policies for compliance with European Union Aviation Safety Agency regulations for AI systems in aviation.

## Directory Structure

- **v1/**: Version 1 implementation
  - `regulation_2019_947.rego`: Rules and procedures for unmanned aircraft operations
  - `regulation_2019_945.rego`: Requirements for unmanned aircraft systems and operators
  - `u_space.rego`: U-space airspace framework compliance
  - `sora.rego`: Specific Operations Risk Assessment methodology
  - `ai_certification.rego`: AI system certification under EASA framework

## Regulatory Coverage

### Commission Regulation (EU) 2019/947
- Open, specific, and certified categories of UAS operations
- Operational limitations and requirements
- Remote pilot competency requirements
- Registration and marking requirements

### Commission Regulation (EU) 2019/945
- UAS design and manufacturing requirements
- CE marking and conformity assessment
- Technical specifications for UAS classes
- Remote identification and geo-awareness

### U-space Framework
- U-space airspace designation and services
- Common information service (CIS)
- Traffic information service (TIS)
- Strategic conflict resolution service

### SORA (Specific Operations Risk Assessment)
- Ground risk assessment
- Air risk assessment
- Operational safety objectives (OSO)
- Robustness levels and integrity requirements

### AI Certification
- AI system validation and verification
- Explainable AI requirements for aviation
- Continuous learning system oversight
- Human-AI interaction standards

## Usage

These policies evaluate compliance with EASA regulations for AI-enabled aviation systems:

```rego
package my_easa_compliance

import data.international.easa.v1.regulation_2019_947
import data.international.easa.v1.regulation_2019_945
import data.international.easa.v1.sora

# Evaluate EASA compliance for UAS operations
easa_compliant if {
    regulation_2019_947.compliant
    regulation_2019_945.compliant
    # SORA required for specific category operations
    input.operation_category == "specific" implies sora.compliant
}
```

## Implementation Status

All policies are currently PLACEHOLDER status pending detailed implementation as part of the GOP-1 epic phases.

## References

- [Commission Regulation (EU) 2019/947](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019R0947)
- [Commission Regulation (EU) 2019/945](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX%3A32019R0945)
- [U-space Regulation](https://www.easa.europa.eu/en/domains/air-operations/u-space)
- [SORA Methodology](https://www.easa.europa.eu/en/document-library/general-publications/specific-operations-risk-assessment-sora)

## Disclaimer

These policies are based on publicly available EASA regulations and guidance. Users should consult current EASA regulations and seek professional guidance for specific compliance requirements.
