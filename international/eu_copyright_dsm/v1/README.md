# EU Copyright in the Digital Single Market Directive (v1)

The policies in this directory encode narrowly scoped conditions from Directive (EU) 2019/790 on copyright and related rights in the Digital Single Market.

**Source**: https://eur-lex.europa.eu/legal-content/EN/ALL/?uri=CELEX:32019L0790

**Disclaimer**: These policies are provided for informational purposes only and do not constitute legal advice. They represent the authors' interpretation of the cited Directive-level source text in Rego and have not been certified by any regulatory body. They do not determine compliance with Member State implementing law.

## Policies

- `article_4_tdm_eligibility.rego`: evaluates eligibility for the Article 4 text-and-data-mining exception on supplied facts only. It requires a TDM purpose, lawful access, and a current positive fact that the use has not been expressly reserved. It does not issue a licence or permission, determine ownership, or establish complete legality.

## Input boundary

The policy uses GOPAL's existing declaration format. Each fact may be supplied as a bare value or as an attested declaration carrying `value`, `asserted_by`, `asserted_at`, `evidence`, and `expires`. A top-level `evaluated_at` makes expiry handling reproducible.

The three legal facts remain separate under `copyright_dsm.article4`:

- `qualifies_as_tdm`: whether the activity satisfies the supplied Article 2(2) TDM-purpose fact.
- `lawful_access`: whether lawful access is established for the supplied facts.
- `reservation_status`: one of the caller's normalized facts, including `not_expressly_reserved`, `expressly_reserved`, `no_reservation_observed`, `unknown`, or `unverifiable`.

`no_reservation_observed` is deliberately not equivalent to `not_expressly_reserved`. Absence of an observation does not establish absence of an express reservation.
