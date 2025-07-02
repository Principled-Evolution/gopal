# International Policies

This directory contains policies specific to international regulatory frameworks and standards for AI systems.

## Directory Structure

- **eu_ai_act/**: Policies related to the European Union AI Act
  - **v1/**: Version 1 implementation
    - `fairness.rego`: Fairness requirements under EU AI Act
    - `transparency.rego`: Transparency requirements under EU AI Act
    - `risk_management.rego`: Risk management requirements under EU AI Act

- **india/**: Policies related to Indian AI regulatory frameworks
  - **v1/**: Version 1 implementation
    - `digital_india_policy.rego`: Digital India AI policy requirements

- **nist/**: Policies related to NIST AI standards
  - **v1/**: Version 1 implementation
    - `ai_600_1.rego`: NIST AI 600-1 framework requirements

- **faa/**: Policies related to US Federal Aviation Administration regulations
  - **v1/**: Version 1 implementation
    - `part_107.rego`: Small Unmanned Aircraft Systems (sUAS) regulations
    - `part_135.rego`: Commuter and On-Demand Operations
    - `bvlos_waiver.rego`: Beyond Visual Line of Sight waiver requirements
    - `remote_id.rego`: Remote identification requirements
    - `advanced_air_mobility.rego`: Advanced Air Mobility (AAM) framework

- **easa/**: Policies related to European Union Aviation Safety Agency regulations
  - **v1/**: Version 1 implementation
    - `regulation_2019_947.rego`: Rules and procedures for unmanned aircraft operations
    - `regulation_2019_945.rego`: Requirements for unmanned aircraft systems and operators
    - `u_space.rego`: U-space airspace framework compliance
    - `sora.rego`: Specific Operations Risk Assessment methodology
    - `ai_certification.rego`: AI system certification under EASA framework

- **icao/**: Policies related to International Civil Aviation Organization standards
  - **v1/**: Version 1 implementation
    - `annex_2.rego`: Rules of the Air for RPAS
    - `annex_6.rego`: Operation of Aircraft - RPAS provisions
    - `doc_10019.rego`: Manual on RPAS compliance
    - `sarps.rego`: Standards and Recommended Practices for RPAS
    - `global_utm.rego`: Global UTM (Unmanned Traffic Management) framework

- **standards/**: Policies related to international technical standards
  - **v1/**: Version 1 implementation
    - `iso_21384.rego`: General requirements for UAS (ISO 21384 series)
    - `rtca_do_365.rego`: Minimum Operational Performance Standards for UAS
    - `rtca_do_366.rego`: Minimum Aviation System Performance Standards for UAS
    - `eurocae_ed_269.rego`: Guidelines for UAS certification
    - `eurocae_ed_270.rego`: Guidelines for UAS operations
    - `do_178c.rego`: Software considerations in airborne systems certification
    - `do_254.rego`: Design assurance guidance for airborne electronic hardware

## Usage

International policies provide requirements specific to regulatory frameworks from different regions and international standards bodies. These can be applied based on the jurisdiction in which the AI system operates.

## Adding New Policies

When adding new international policies:
1. Place them in the appropriate framework and version directory (e.g., eu_ai_act/v1/)
2. Follow the naming convention: `<policy_area>.rego`
3. Use the package name `international.<framework>.<version>.<policy_area>`
4. Include comprehensive metadata and documentation including references to specific sections of the regulatory text

## Composition

International policies can import global policies to extend them with specific requirements:

```rego
import data.global.v1.fairness
```

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.