# Principles of Program Analysis in Latte

A chapter-by-chapter formalization of Flemming Nielson, Hanne Riis Nielson,
and Chris Hankin's *Principles of Program Analysis*, written in Latte with
explicit evidence terms rather than tactics or solver-authored lemmas.

The earlier Lean implementation remains at
[`ppa-lean`](https://github.com/rotbotd/ppa-lean). It is the executable oracle
for this port: examples, transfer functions, and named results should agree,
while the Latte source is allowed to expose a smaller and more readable proof
language.

## Evidence boundary

Latte is presently private and unreleased. This repository publishes only the
authored `.lt` programs and their generated F* views; it does not redistribute
the compiler. The exact frontend used for the checked-in views is recorded in
`LATTE-REVISION`.

The project disables tactics globally:

```latte
verification default = {
  tactics: disabled,
}
```

The project does not disable SMT globally. F* sends elaborator obligations as
basic as constructor disjointness through its solver, so `--no_smt` makes
ordinary dependent pattern matching unusable. Instead, a theorem is a function
returning an unsquashed evidence datatype. Z3 may check the indices of the term
we wrote, but it cannot manufacture a constructor of that datatype. Source
`proof` declarations, generated `Lemma` declarations, `squash`, and admissions
are rejected by the repository policy.

For example, branch conditions in `big_step` are not refined `unit` values that
the solver can fill. They carry an inhabitant of the indexed `equality` type,
whose only constructor is `Reflexive`.

## Current slice

`src/Chapter01/While.lt` defines the labelled WHILE language, states, expression
evaluation, explicit equality evidence, the relational big-step semantics, and
the six-label reaching-definitions program from Section 1.3. The next slice
derives assignment's kill/gen transfer from the concrete semantics.

## Local checks

The public flake checks repository structure, the generated-view policy, and
the generated F* with its locked public F* package:

```console
nix flake check
```

Maintainers with the pinned private Latte checkout can regenerate one source
file with:

```console
LATTE_CLI=/absolute/path/to/latte.cjs ./scripts/regenerate src/Chapter01/While.lt
```
