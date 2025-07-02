# Technical Standards Policies

This directory contains OPA Rego policies for compliance with international technical standards for AI systems in aviation.

## Directory Structure

- **v1/**: Version 1 implementation
  - `iso_21384.rego`: General requirements for UAS (ISO 21384 series)
  - `rtca_do_365.rego`: Minimum Operational Performance Standards for UAS
  - `rtca_do_366.rego`: Minimum Aviation System Performance Standards for UAS
  - `eurocae_ed_269.rego`: Guidelines for UAS certification
  - `eurocae_ed_270.rego`: Guidelines for UAS operations
  - `do_178c.rego`: Software considerations in airborne systems certification
  - `do_254.rego`: Design assurance guidance for airborne electronic hardware

## Standards Coverage

### ISO 21384 Series - General Requirements for UAS
- UAS classification and terminology
- General requirements for UAS design
- Quality assurance for UAS manufacturing
- Risk assessment methodologies

### RTCA DO-365 - Minimum Operational Performance Standards
- UAS operational performance requirements
- Command and control link performance
- Detect and avoid system performance
- Navigation and surveillance performance

### RTCA DO-366 - Minimum Aviation System Performance Standards
- UAS system-level performance requirements
- Integration with air traffic management
- Communication system performance
- Safety and security requirements

### EUROCAE ED-269 - UAS Certification Guidelines
- Certification processes for UAS
- Airworthiness requirements
- Type certification procedures
- Continuing airworthiness requirements

### EUROCAE ED-270 - UAS Operations Guidelines
- Operational procedures and protocols
- Pilot training and certification
- Operational risk assessment
- Safety management systems

### DO-178C - Software Considerations
- Software development processes
- Software verification and validation
- Configuration management
- Quality assurance for software

### DO-254 - Hardware Design Assurance
- Hardware development processes
- Hardware verification and validation
- Design assurance levels
- Configuration management for hardware

## Usage

These policies evaluate compliance with technical standards for AI-enabled aviation systems:

```rego
package my_standards_compliance

import data.international.standards.v1.iso_21384
import data.international.standards.v1.rtca_do_365
import data.international.standards.v1.do_178c

# Evaluate technical standards compliance
standards_compliant if {
    iso_21384.compliant
    rtca_do_365.compliant
    # Software certification required for complex AI systems
    input.system_complexity == "complex" implies do_178c.compliant
}
```

## Implementation Status

All policies are currently PLACEHOLDER status pending detailed implementation as part of the GOP-1 epic phases.

## References

- [ISO 21384-1:2019](https://www.iso.org/standard/70932.html) - General requirements for UAS
- [RTCA DO-365](https://www.rtca.org/content/standards-guidance) - Minimum Operational Performance Standards
- [RTCA DO-366](https://www.rtca.org/content/standards-guidance) - Minimum Aviation System Performance Standards
- [EUROCAE ED-269](https://www.eurocae.net/) - Guidelines for UAS certification
- [RTCA DO-178C](https://www.rtca.org/content/standards-guidance) - Software considerations
- [RTCA DO-254](https://www.rtca.org/content/standards-guidance) - Hardware design assurance

## Disclaimer

These policies are based on publicly available technical standards. Users should consult current versions of these standards and seek professional guidance for specific compliance requirements.
