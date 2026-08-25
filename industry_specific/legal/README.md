# Legal Services AI Policies

This directory contains OPA Rego policies for AI use in regulated legal practice.

This vertical exists because the legal profession is one of the few where AI misuse has already produced published regulatory and judicial consequences rather than hypothetical risk. The failure modes are specific and repeatable: fabricated case citations reaching court filings, and client confidential material pasted into public AI assistants. The policies here encode the controls the regulators have said they expect, and they are written so that a failing evaluation names the control that failed.

The professional obligations themselves are unchanged by the use of AI. A practitioner is accountable for work produced in their name however it was prepared, which is why these policies test verification and supervision rather than the model.

## Directory Structure

- **v1/**:
  - `citation_verification.rego` - authorities in an AI-assisted document are independently verified before filing, with the verification recorded and attributable to a named individual
  - `client_confidentiality.rego` - whether client confidential or privileged material may be entered into a given tool, including the public-consumer-assistant case that can waive privilege outright
  - `competence_supervision.rego` - technology competence, risk assessment before adoption, effective supervision with a named supervisor, and client disclosure where AI use is material

## Jurisdictional note

The references are drawn from the regulators of England and Wales: the SRA for solicitors and firms, the BSB for barristers, and the judiciary's own guidance for judicial office holders. The controls generalise well, because the underlying duties (do not mislead the court, preserve confidentiality and privilege, supervise competently) are close to universal across common-law jurisdictions. The citations will not be.

## Disclaimer

The policies provided in this directory are for informational purposes only and do not constitute legal advice. These policies are based on publicly available information and interpretations of relevant regulations and frameworks. Users are advised to consult with legal professionals for specific guidance related to their AI systems and compliance obligations.
