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

## 2026-10-04 — assignment soundness is evidence construction

- Added the Section 1.3 definition domain, entry state, kill, gen, assignment,
  last-writer state, and coverage relation as type families rather than
  solver-facing propositions.
- `different` has exactly the six unequal pairs of the three-variable WHILE
  language. `variable_comparison(left, right)` returns either indexed sameness
  or one of those six witnesses. The exhaustive nine-case decision is isolated
  in `compare_variables`; the soundness construction therefore retains only
  its two meaningful branches.
- In the same-variable branch, `assignment_sound` constructs the generated
  definition from two `Reflexive` values. In the different-variable branch it
  constructs the preserved definition from the explicit difference witness
  and the incoming coverage function. `generated_present` and
  `other_preserved` expose those two constructor terms separately.
- Generic `both` and `either` initially used implicit type parameters. The
  emitted F* constructors could not reconstruct an unused alternative type
  from `Left` or `Right`, so they now take explicit type parameters. This is a
  frontend surface constraint, not a mathematical axiom.
- The generated dependency pair verifies under the pinned F* runtime with
  tactics disabled and no `Lemma`, `squash`, or admission surface.

## 2026-10-04 — executions carry their last writers

- The original big-step relation exposes the labels in source syntax but
  returns only a final store. That is too weak to state semantic soundness for
  reaching definitions: the analysis concerns which labelled assignment most
  recently wrote each variable along an execution.
- Added `instrumented_big_step`, indexed by both before/after stores and
  before/after last-writer maps. Assignment changes the store and records its
  label; skip preserves both; sequence, conditionals, and loops thread the map
  through the branch and iterations actually executed.
- Added `forget_writers`, a structural recursion over instrumented evidence
  which constructs the corresponding ordinary `big_step` evidence. The writer
  instrumentation therefore refines rather than replaces the existing
  semantics.
- This semantics observes the exit of terminating executions. It does not yet
  state coverage at every labelled program point or observe prefixes of a
  diverging execution. The next proof boundary is a label-indexed analysis
  solution whose loop-head fixpoint is preserved by every terminating
  execution; a genuinely prefix-sensitive theorem will still require a
  small-step or trace-producing relation.
- Removed the blanket `noeq` qualifier from arithmetic expressions, boolean
  expressions, and statements. Those are computational syntax trees with
  decidable leaves, so F* can and should expose structural equality for them.
  `noeq` remains on evidence families and generic evidence containers whose
  fields include functions, recursive derivations, or arbitrary `Type`s.

## 2026-10-04 — the local transfer proof reaches whole executions

- Added `reaching_analysis(program, before, after)`, a syntax-directed analysis
  judgment. Assignment fixes `after` to kill/gen; skip preserves the set;
  sequence threads a middle set; an `if` joins the branch outputs.
- A loop plan carries entry inclusion into a proposed head invariant, analysis
  of the body from that invariant, and back-edge inclusion from the body output
  into the same invariant. This expresses the post-fixpoint obligation needed
  by the soundness proof without pretending a solver computed the fixpoint.
- `analysis_sound` recursively consumes both an analysis plan and an
  instrumented execution. The assignment case is the earlier
  `assignment_sound` constructor program. The branch cases inject the taken
  result into the union. The true-loop case proves the body from the head,
  applies the back-edge inclusion, then recursively checks the remaining
  iterations using a reflexive head-to-head loop plan.
- The first loop attempt incorrectly reused the original `before -> head` plan
  for remaining iterations, even though those iterations begin at `head`.
  F* rejected the call because it had coverage of `head` where coverage of
  `before` was requested. Constructing the recursive `head -> head` plan makes
  the invariant boundary explicit and discharged the exact error.
- The result is soundness at the entry and exit of every syntax node for
  terminating derivations. It still does not publish a label-indexed table for
  the six-label example or quantify over prefixes of divergent execution.
