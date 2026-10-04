# Log

## 2026-10-04 — Lean becomes the oracle

- Started a separate Latte implementation rather than rewriting the public
  `ppa-lean` history. The Lean artifact remains a behavioral specification for
  worked examples and theorem statements.
- The source policy disables tactics everywhere. Disabling SMT is not a viable
  proof-audit boundary in F*: even a recursive datatype match produces
  constructor-disjointness guards which F* sends through its solver.
- The enforceable boundary is representation rather than solver policy.
  Theorems return unsquashed indexed evidence datatypes; the solver may check
  indices but cannot manufacture an evidence constructor. Latte `proof`
  declarations, generated `Lemma` declarations, squash, and admissions are
  rejected. This was checked against emitted F* and an actual F* run rather
  than guessed from Latte's configuration schema.
- The repository publishes Latte source and generated F* only. Latte itself is
  private and unreleased, so no compiler source, build artifact, or dependency
  is vendored here.
- The first vertical slice is the labelled WHILE syntax, evaluator, relational
  big-step semantics, and Section 1.3's six-label program. Assignment kill/gen
  and its derivation from traces remain next.
- The public flake pins and builds F* 2026.08.02 at commit
  `7bbcb5fa68a6581d7c379e39af0a38316de1e41f`, the exact runtime admitted by
  the recorded Latte frontend. The generated module verifies there while
  tactics are disabled.
