# Jerico Global PTY Control Plane — Phase 0 Fix8-B Closure Clash

Date: 2026-09-05

## Role and decision boundary

You are one of four independent read-only clash reviewers. Resolve the 2 PASS / 2 FAIL disagreement in the Fix8-B closure review by returning to current primary source and reproducing the disputed false-green. Do not implement a repair. Gate 0 remains `UNVERIFIED`.

Apply `/Users/alperduzgun/Documents/feedback_investigation_clash_rules.md` literally. Inspect primary source before relying on reports. Label load-bearing claims `REPRODUCED`, `DIRECT SOURCE`, `INFERRED`, or `ASSUMED`; self-falsify; run cheap reproducers; explicitly answer what neither side investigated.

Only a reproduced/direct-source Phase 0 authority, integrity, lost-work, duplicate-effect, cross-tab blast-radius, unbounded-memory or release-gate false-green defect may require a repair. Defer Phase 1+, retention/TTL/compaction, provider-specific future behavior, cosmetic issues and unrelated hardening.

## Target

- Read-only worktree: `/Users/alperduzgun/Development/jerico-global-pty-control-plane`
- Branch: `feat/global-pty-control-plane`
- HEAD: `184fdbde344a708b68a28743d433b4e74858914b`
- Tracked porcelain: 35 entries, SHA-256 `6ecfbb22fa3a5d694168dedebead818ce22d62865510a402fbecbe75dd1521a3`
- Full porcelain: 66 entries, SHA-256 `be6335dc9eb9539711ff68bc9ab323d0173fc0ad746fffdfd836cb12661de82e`

Read target `AGENTS.md` and `CLAUDE.md`. Do not modify the target, install, stage, stash, reset, clean, checkout, commit, format or alter shared services. Mutations belong only in a reviewer-owned `mktemp -d` copy and must be cleaned. Never expose secrets or brief bodies in logs.

## Binding reports

- AGY1 PASS: `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-agy1.md`, SHA-256 `bc818a581e09dd7305284de423a158b170c85b6687f84034b7c7eec7d82da101`
- Codex Sol FAIL: `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-codex.md`, SHA-256 `0080d3ef13f0bba81186a0f77d80fb58ce64687746ebe0211bb82cb9cf8d003f`
- Codex Terra FAIL: `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-terra.md`, SHA-256 `7a76ecd28f56fa060236cfcaea88d7c1ea300aa015af8c8904e20adb56ce6474`
- AGY2 PASS: `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-agy2.md`, SHA-256 `4e1bd6bfdaae6ca108e2644b5c1e94f03ad5a69e93051849c52b92cc200a9dc5`

Reports are leads, not proof.

## Disputed evidence to reproduce

The checked-in product call is correct. The dispute is whether its test is still an unacceptable release-gate false-green.

In private copies, independently test:

1. comment decoy: preserve the canonical call only in a comment and make the actual final call pass `true`;
2. dead-closure decoy: preserve the canonical call in an unused closure and make the actual final call pass `true`;
3. unreachable-branch decoy: preserve the canonical call under `if (false)` and make the actual final call pass `true`;
4. helper suffix: change the helper's direct predicate to `(projectId === attemptProjectId && wsId === attemptWorkspaceId) || true` while preserving the canonical textual prefix.

Run the exact focused lifecycle/surface suite for each. Web typecheck one representative compiling decoy. Record exact pass/fail counts.

## Required decisions

1. Does each decoy compile, and does the focused suite stay green while the effective final predicate is unconditional?
2. Does that reproduce the exact Fix8-B failure class required to turn red, or is it legitimately deferable? Apply the written closure boundary, not preference.
3. Did the PASS reports inspect the same lexical/control-flow class, and did AGY1 misclassify a reproduced false-green?
4. What did neither side investigate?
5. If repair is required, specify the smallest acceptance contract that closes all reproduced decoys without expanding into a general compiler project. Decide whether it remains bounded enough for Spark/high or requires Sol/high.
6. Verify manifest/worktree identity was not changed by the review.

## Report contract

Write only the output path assigned by your wrapper. Include actual harness/model/version/effort/full-access evidence, verified report hashes, commands/results, disposition for all four decoys, self-falsification, shared-blind-spot answer, smallest repair contract and owner recommendation, cleanup and final identity.

Use exactly one verdict:

- `FIX8B_CLASH_PASS` — no Phase 0 repair remains.
- `FIX8B_CLASH_FIX_REQUIRED` — a bounded Phase 0 false-green repair is confirmed.
- `FIX8B_CLASH_BLOCKED`
- `FIX8B_CLASH_UNVERIFIED`

End with exact final non-rendered line `DONE`.

