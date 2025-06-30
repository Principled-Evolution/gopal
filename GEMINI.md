# Gemini Workspace Context: AI Governance Policies (Rego)

This repository contains a collection of Rego policies for AI governance and risk management. The policies are organized into a clear, hierarchical structure to ensure consistency and ease of navigation.

## Core Principles

1.  **Structure is Key:** All policies are organized by domain, version, and category. Adherence to this structure is mandatory.
2.  **Rego is the Standard:** All policies are written in the Rego language (`.rego`).
3.  **Testing is Required:** Every new policy must be accompanied by a corresponding test file.
4.  **Metadata is Essential:** Every policy file must include standardized metadata annotations.
5.  **Traceability is Mandatory:** The source of every policy must be documented.

## How to Add a New Policy

Follow these steps to add a new policy to the repository.

### 1. Directory Structure

All policies reside within a specific directory structure. When adding a new policy, place it in the appropriate location:

`{domain}/{version}/{category}/{policy_name}.rego`

-   **`{domain}`**: The top-level domain for the policy (e.g., `global`, `industry_specific`, `international`).
-   **`{version}`**: The version of the policy set (e.g., `v1`).
-   **`{category}`**: The specific risk or functional area the policy addresses (e.g., `fairness`, `student_data_privacy`).
-   **`{policy_name}.rego`**: The name of the policy file, using snake_case (e.g., `unbiased_automated_grading.rego`).

### 2. Policy File Requirements

Every `.rego` file must include the following:

-   **Package Declaration:** The package name must match the directory path.
    ```rego
    package industry_specific.education.v1.student_data_privacy
    ```

-   **Metadata Annotations:** Include a title, description, version, and a reference to the source.
    ```rego
    # @title Detailed FERPA Compliance
    # @description This policy evaluates data access requests against FERPA.
    # @version 1.1
    # @source https://www.ecfr.gov/current/title-34/subtitle-A/part-99
    ```

-   **Default Rule:** Define a default behavior (usually `deny` or `not compliant`).

-   **Clear Deny Messages:** If a policy check fails, it should return a clear, informative message using `deny[msg]`.

### 3. Source and Disclaimer README

At the appropriate directory level (e.g., `/international/eu_ai_act/v1/`), you must include a `README.md` file that contains:

-   **Source Information:** A link to the official government or organizational policy that the Rego files are based on.
-   **Disclaimer:** A standard disclaimer.

**Example `README.md`:**
```markdown
# EU AI Act Policies (Version 1)

The policies in this directory are based on the official text of the EU AI Act.

**Source:** [Link to the official EU AI Act text]

**Disclaimer:** These policies are provided for informational purposes only and do not constitute legal advice. They are intended to represent the requirements of the EU AI Act in the Rego policy language but have not been certified by any regulatory body.
```

### 4. Testing

-   For every `my_policy.rego` file, you must create a corresponding `my_policy_test.rego` in the same directory.
-   Tests should cover both `allow`/`compliant` and `deny`/`non-compliant` scenarios.
-   Use mock `input` data to simulate realistic policy evaluation scenarios.
