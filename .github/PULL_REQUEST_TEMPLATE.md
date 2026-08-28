## What this changes

<!-- One or two sentences. -->

## Type

- [ ] New policy (specify framework path)
- [ ] New framework directory
- [ ] Policy update (semver MINOR — backward compatible)
- [ ] Policy update (semver MAJOR — breaking; new `v2/` directory)
- [ ] Bug fix
- [ ] Tooling / CI / docs

## Checklist

- [ ] Every new `.rego` has a sibling `*_test.rego` covering both `allow` and `deny` paths
- [ ] Metadata block (`# METADATA` with `title`, `description`, `version`, `source`) is present on every new policy
- [ ] Framework-level `README.md` lists the new policy and includes the standard disclaimer
- [ ] `opa check --ignore custom/ .` passes locally
- [ ] `regal lint --ignore-files custom/ .` passes locally
- [ ] If breaking: new `v2/` directory created, `v1/` left untouched, [COMPATIBILITY.md](../docs/COMPATIBILITY.md) updated

## Source(s)

<!-- Link the official regulation, standard, or document this policy encodes. -->

## Notes for reviewers

<!-- Anything subtle? Articles you chose to defer to a follow-up PR? Trade-offs in modeling? -->
