# Declarations: the other 171 fields

Most writing about AI compliance tooling is about measurement. Measurement is
the smaller half.

Of the 185 input fields the 29 EU AI Act policies in this library read, **171
are declarations and 14 are measurements**. No tool can observe whether a
conformity assessment was completed, whether a person can halt the system, or
whether technical documentation has been retained for ten years. Somebody
asserts those, and the library takes their word.

That ratio is not a gap to be closed. It is what the regulation is mostly made
of, and any product claiming to automate it away is describing something other
than the Act. What can be improved is the friction of getting a true declaration
into a policy, and how long the library goes on believing it.

This document sets out how that works and which layer owns which part.

## The three layers

The division is not by technology. It is by what each layer is allowed to
decide.

| | Owns | Decides |
| --- | --- | --- |
| **GOPAL** | the rules, and what an input *means* | what an obligation requires, when it applies, when a declaration has gone stale |
| **AICertify** | gathering inputs and running OPA | how to obtain a value, from a tool, a file, or a registry |
| **Grace** | workflow, identity, memory | who is asked, when they are asked again, and what is kept as evidence |

The line that matters is the first one. **Whether an expired attestation still
counts is a policy judgement, not a tool behaviour**, so it lives in Rego where
it can be read, argued with and versioned. If it lived in AICertify, two
consumers of the same policies could disagree about whether a system complies,
and both would be able to point at a green check.

## What a declaration is

The simple form is a value, and it always will be:

```json
{ "ce_marking": { "affixed": true } }
```

Most inputs are written by hand or produced by a tool with no provenance to
offer, and requiring more would make the common case worse to serve the rare
one.

The attested form adds who said it and how long it holds:

```json
{
  "evaluated_at": "2026-08-29T00:00:00Z",
  "ce_marking": {
    "affixed": {
      "value": true,
      "asserted_by": "j.smith@example.com",
      "asserted_at": "2026-03-01T00:00:00Z",
      "evidence": "https://grc.example.com/attestation/8814",
      "expires": "2027-03-01T00:00:00Z"
    }
  }
}
```

[`helper_functions/declarations.rego`](../helper_functions/declarations.rego)
reads both.

### Why expiry is the interesting field

Taking somebody's word is reasonable. Taking it forever is not.

An assertion that CE marking was affixed, made two years ago against a system
that has changed forty times since, sits in the input document looking exactly
like one made this morning. It is worse than a missing declaration, because a
missing one is visibly missing.

An expired attestation resolves to **undefined**, not to `false`. The claim has
not been refuted, it has gone out of date. A policy with `default := false`
denies either way, but a report can tell the difference, and the difference
decides who gets the work: *answer this* goes to whoever owns the system,
*re-attest this* goes back to whoever signed it last time.

That is the same distinction this library already makes for a missing
measurement, and for the same reason.

### The clock is an input

`evaluated_at` is read from the document rather than from `time.now_ns()`.

An evaluation that consults the wall clock is not reproducible. The same bundle
and the same input would produce different verdicts on different days with
nothing in either to explain why, and an auditor re-running last quarter's
evidence has to get last quarter's answer.

Where no `evaluated_at` is supplied, nothing expires. Expiry is a property the
caller opts into by saying when the evaluation happened, rather than a trap for
inputs that never mentioned time.

## Reducing the friction, in the order worth doing it

### 1. Ask what determines scope, before asking anything else

**18 of the 29 EU policies are gated on applicability**, covering 143 of the 171
declared fields. Declaring `system.high_risk = false` and
`model.general_purpose = false` puts 15 policies out of scope immediately.

The remaining 11 policies, 28 fields, are almost entirely the prohibited
practice screens, which genuinely do apply to everyone.

So the burden is not 171. It is roughly 28 plus whatever scope pulls in, and
three or four answers decide the rest. Any interface that asks all 171 up front
is asking most people most of the questions they do not have to answer, and it
will feel like a compliance questionnaire because that is what it has become.

The applicability model is already in the policies. What is missing is anything
that consumes it.

### 2. Separate what is declared once from what is declared per release

Of the 151 unique declared fields, **57 are organisation or product level** and
94 are per system.

`ce_marking.affixed`, `declaration.drawn_up`, `provider.quality_management_system`
are properties of a company or a product line, not of this week's build. They
should be asserted once, in one document, and inherited by every system that
company ships. Re-asking them per system is most of the perceived burden and
none of the value.

### 3. Derive what is actually observable

Some fields called declarations are not judgements at all.
`documentation.model_card.exists` is answerable by looking in the repository.
`logging.retention_days` is in a log configuration. `system.version` is in the
release.

These want the same treatment as toxicity and fairness: an adapter that reads
the source of truth and emits the value. The difference is that the source is a
registry, a config or a CI run rather than a model evaluation. That is the
natural next family of adapters after Detoxify and Fairlearn, and every field
moved from asserted to derived is a field nobody has to remember.

### 4. Import from where declarations already live

Most of these facts exist. They are in a GRC platform, a ticket, a vendor
questionnaire response, or a page somebody wrote in Confluence. They are simply
not in a form a policy can read.

The temptation is to build connectors. The better first move is to **document
the format and let anyone map into it**, because the number of systems where a
declaration might live is unbounded and chasing them is work that ages badly.
One documented schema, with provenance, plus a reference importer or two, lets
an organisation connect whatever it already has. Managed connectors are then a
service somebody can choose to buy rather than the only way in.

### 5. Treat re-attestation as a scheduled activity

Declarations decay on a timetable that has nothing to do with releases. Knowing
that eleven attestations expire next quarter, and who signed each, is a workflow
problem: it needs identity, reminders, and a record of what was asked and
answered. That is what a platform is for, and it is the part that cannot
sensibly live in a policy library or a Python package.

## Where each piece belongs

**GOPAL** owns the meaning. The rules, the applicability gates, the canonical
input names, and the semantics of a stale declaration. Apache-2.0, no
dependencies beyond OPA, and no opinion about where a value came from.

**AICertify** owns the gathering. Evaluators that measure, adapters that convert
somebody else's measurement, and declaration sources that read a value from a
file, a registry or a CI run. It assembles a document and runs the policies. It
should not decide what a policy means, and after the model-card rubric moved
into Rego it no longer does.

**Grace** owns the remembering. Who was asked, who answered, what evidence they
attached, when it expires, and what to do about the ones that have. Managed
connectors to the systems where declarations already live. Rollups across many
systems and many teams. None of that belongs in a policy library, and all of it
is worth paying for if you have more than a handful of systems.

The test for whether something is in the right layer: **could two organisations
using the same policies reach different verdicts on the same evidence?** If yes,
it is in the wrong layer and belongs further down.

## Status

Implemented: the attested declaration format, expiry as undefined, provenance
lookup, and the reproducible clock, all in
[`helper_functions/declarations.rego`](../helper_functions/declarations.rego)
with tests.

Not yet: policies still read declarations directly rather than through
`declarations.resolve`, so attestation and expiry are available but not
enforced. That migration is the same shape as the one
[`helper_functions/metrics.rego`](../helper_functions/metrics.rego) went
through, and should be done the same way: additive, one policy at a time, with
the existing tests passing unchanged beside new ones.
