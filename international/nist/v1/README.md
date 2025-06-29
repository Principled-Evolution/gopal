# NIST AI Risk Management Framework Policies

This directory contains OPA Rego policies for the NIST AI Risk Management Framework (RMF).

The policies are organized according to the four functions of the NIST AI RMF:

- **Govern:** Policies related to the governance of AI systems.
- **Map:** Policies related to mapping and understanding the context of AI systems.
- **Measure:** Policies related to measuring and assessing the performance of AI systems.
- **Manage:** Policies related to managing the risks associated with AI systems.

The `ai_600_1/ai_600_1.rego` policy acts as an orchestrator, importing and applying the policies from each of these functions.
