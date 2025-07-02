# FAA (Federal Aviation Administration) Policies

This directory contains OPA Rego policies for compliance with United States Federal Aviation Administration regulations and guidance for AI systems in aviation.

## Directory Structure

- **v1/**: Version 1 implementation
  - `part_107.rego`: Small Unmanned Aircraft Systems (sUAS) regulations
  - `part_135.rego`: Commuter and On-Demand Operations
  - `bvlos_waiver.rego`: Beyond Visual Line of Sight waiver requirements
  - `remote_id.rego`: Remote identification requirements
  - `advanced_air_mobility.rego`: Advanced Air Mobility (AAM) framework

## Regulatory Coverage

### Part 107 - Small Unmanned Aircraft Systems
- Operating limitations and requirements
- Remote pilot certification
- Aircraft registration and marking
- Operational restrictions and waivers

### Part 135 - Commuter and On-Demand Operations
- Commercial drone operations
- Operator certification requirements
- Operational control and safety management
- Maintenance and inspection requirements

### BVLOS Operations
- Visual observer alternatives
- Detect and avoid requirements
- Communication and control link standards
- Risk assessment and mitigation

### Remote ID
- Remote identification broadcast requirements
- Standard and limited remote ID compliance
- Network-based remote ID services
- Privacy and security considerations

### Advanced Air Mobility (AAM)
- Urban Air Mobility operations
- Vertiport design and operations
- Air traffic integration
- Passenger-carrying autonomous operations

## Usage

These policies evaluate compliance with FAA regulations for AI-enabled aviation systems:

```rego
package my_faa_compliance

import data.international.faa.v1.part_107
import data.international.faa.v1.remote_id
import data.international.faa.v1.bvlos_waiver

# Evaluate FAA compliance for sUAS operations
faa_compliant if {
    part_107.compliant
    remote_id.compliant
    # BVLOS waiver only required for beyond visual line of sight operations
    input.operation_type == "BVLOS" implies bvlos_waiver.compliant
}
```

## Implementation Status

All policies are currently PLACEHOLDER status pending detailed implementation as part of the GOP-1 epic phases.

## References

- [FAA Part 107](https://www.faa.gov/uas/commercial_operators/part_107_summary/)
- [FAA Part 135](https://www.faa.gov/air_traffic/publications/atpubs/aim_html/chap4_section_3.html)
- [Remote ID Rule](https://www.faa.gov/uas/getting_started/remote_id/)
- [Advanced Air Mobility](https://www.faa.gov/air_traffic/technology/aam/)

## Disclaimer

These policies are based on publicly available FAA regulations and guidance. Users should consult current FAA regulations and seek professional guidance for specific compliance requirements.
