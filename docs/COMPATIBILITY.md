# Compatibility Matrix

This document outlines the compatibility between Gopal and AICertify versions.

## Version Compatibility

| Gopal Version | Compatible AICertify Versions | Notes |
|---------------|-------------------------------|-------|
| 1.0.0         | All current versions          | Initial release, compatible with all existing AICertify versions |

## Compatibility Policy

Gopal follows semantic versioning (MAJOR.MINOR.PATCH):

- **MAJOR** version changes indicate incompatible API changes
- **MINOR** version changes add functionality in a backward-compatible manner
- **PATCH** version changes include backward-compatible bug fixes

### Compatibility Guarantees

- AICertify will maintain compatibility with the latest MAJOR version of Gopal
- MINOR and PATCH updates of Gopal should be compatible with existing AICertify versions
- When a new MAJOR version of Gopal is released, AICertify will provide migration guidance

## Deprecation

Semantic versioning says a breaking change waits for a major version. It does not
say how long something must be deprecated first, or where that is written down, so
this does.

**A deprecation is recorded as data, not prose.** Legacy metric spellings carry
their deprecation version in `deprecated_since` in
[`helper_functions/metrics.rego`](../helper_functions/metrics.rego). A deprecation
that lives only in a changelog is one somebody has to remember.

**The window is two minor releases**, not a date. This library releases when there
is something to release, so a calendar deadline either falls between releases and
means nothing, or ages into a date nobody chose. Two minors means a consumer who
upgrades every other release still meets the deprecation once before it goes.

**The timer fires at the major version and nowhere else.**
[`scripts/check-deprecations.sh`](../scripts/check-deprecations.sh) reports status
during normal development and fails the build if a major release is cut while
matured deprecations remain in the table. That is the one moment the question has
to be answered, so it is the only moment it interrupts.

**Removal is a judgement, not a finding.** GOPAL makes no outbound calls and
collects nothing, so nobody here will ever observe that an external input still
uses a legacy name. `metrics.deprecated(input)` reports that to the caller running
the policy, not back to us. The window exists so a user has a release in which to
notice and object; it is not a measurement period, and silence at the end of it is
the absence of evidence rather than evidence of absence.

Callers who want to know whether they are affected can ask directly:

```rego
data.helper_functions.metrics.deprecated(input)
```

which returns each legacy spelling the input used and the canonical name to send
instead, and an empty object when there is nothing to change.

## Checking Compatibility

The PolicyLoader in AICertify checks the Gopal version at runtime and will log warnings if potential compatibility issues are detected.
