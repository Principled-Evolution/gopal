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

## Checking Compatibility

The PolicyLoader in AICertify checks the Gopal version at runtime and will log warnings if potential compatibility issues are detected.
