# Jerico Global PTY Control Plane — Orchestrator Handoff

Date: 2026-09-05  
Current phase: Phase 0  
Gate: `UNVERIFIED`  
Immediate state: Fix8-B closure review split 2 PASS / 2 FAIL; a reproduced release-gate false-green remains.

## User intent and permanent operating rules

- Continue autonomously through every phase; no routine permission questions.
- Use the dedicated worktree only.
- Every worker task must be sent as an `.md` brief.
- Before dispatch, give the user a short Turkish summary.
- Use all four reviewers in `jerico` and `jerico-dev`; clash conflicting findings under `/Users/alperduzgun/Documents/feedback_investigation_clash_rules.md`.
- Every worker must run in provider-native unrestricted/full-access mode; verify the visible live state before dispatch.
- After every `dev send`, perform a real wait and `dev peek`.
- After every completed task, send `/clear` for author-bias/context management.
- Never kill or interrupt workers without explicit user approval.
- Never expose secrets; avoid broad `ps` output. Use targeted metadata-only checks.
- Retention/TTL/compaction cleanup is intentionally deferred so the current Phase 0 flow is not disturbed.
- OpenCode is replaced by AGY2 for the approved Phase 0 bootstrap; unavailable Claude review was replaced by Codex Terra. Do not mislabel substitute evidence.
- The dual developer pool is Sol + Spark, but one implementation task always has exactly one owner: Sol **or** Spark, never both.

## Worktree identity

- Worktree: `/Users/alperduzgun/Development/jerico-global-pty-control-plane`
- Branch: `feat/global-pty-control-plane`
- HEAD: `184fdbde344a708b68a28743d433b4e74858914b`
- Tracked-only porcelain: 35 entries, SHA-256 `6ecfbb22fa3a5d694168dedebead818ce22d62865510a402fbecbe75dd1521a3`
- Full porcelain: 66 entries, SHA-256 `be6335dc9eb9539711ff68bc9ab323d0173fc0ad746fffdfd836cb12661de82e`
- Changed-path union: 75 paths.
- Manifest union: 75 paths.
- Present hashed files: 73, zero mismatches at checkpoint.
- Only unhashed paths: deleted `apps/web/src/lib/components/ExecutionModal.svelte` and self-referential `docs/validation/global-pty-control-plane/phase-0/evidence-manifest.json`.
- `git diff --check`: pass.

Current key hashes:

- `apps/web/src/lib/components/RunConfigView.svelte`: `acf575b083c2588d9a29741d8d93fddb97f436bbc0cabcf62b51cd7955fb524e`
- `apps/web/src/lib/orch-start-surface-contract.test.ts`: `41c7d9cff08a58559c5a704bbd390932c374ee36991dc4d834269a21e86d59e1`
- Phase 0 evidence manifest: `54ce16708602b67d3bc93def52929269ef11aa69e3fef85a40249a8bf383a5ab`
- Fix8-B builder report `/tmp/jerico-global-pty-phase-0-fix8b-builder.md`: `59aaee62f743a049824cce626e842da302d06f36a40e4a7490c0b121e6e5bf50`

## Worker topology at checkpoint

All task sessions were cleared after their latest completed task.

| Slot | Harness/model | Effort/access | Purpose |
|---|---|---|---|
| `jerico --left` | Antigravity CLI 1.1.26, Gemini 3.8 Flash | medium, native unrestricted | AGY1 reviewer |
| `jerico --right` | Codex CLI 0.152.1, `gpt-5.6-sol` | high, YOLO | Codex live/final reviewer |
| `jerico-dev --left` | Codex CLI 0.152.1, `gpt-5.6-terra` | high, YOLO | Terra reviewer replacing unavailable Claude |
| `jerico-dev --right` | Antigravity CLI 1.1.26, Gemini 3.6 Flash | high, native unrestricted | AGY2 replacing OpenCode |
| `jerico-developer --left` | Codex CLI 0.152.1, `gpt-5.6-sol` | high, YOLO | complex implementation owner |
| `jerico-developer --right` | Codex CLI 0.152.1, `gpt-5.3-codex-spark` | high, YOLO | bounded implementation owner |

Re-verify live identity/access before every dispatch; this table is a checkpoint, not current authority.

## Phase 0 progress

Fix8 repaired and verified the six accepted Fix7 areas:

1. request-correlated pending-start ownership/adopt/abandon;
2. production-connected caller-surface evidence;
3. complete immutable fallback leases with null-safe fencing;
4. independent exact per-row cross-session wake CAS;
5. fail-closed terminal authority reachability;
6. computed-key planning audit coverage.

Fix8 rereview/clash found one remaining issue: RunConfig's final post-ACK caller assertion could be changed to `true` without turning the relevant tests red. Fix8-B, implemented by Spark, added `activeScopeMatches()` and a reusable mutation validator. A manifest hash mismatch in the test artifact was then corrected; independent reconciliation returned 75/75 paths and 73/73 hashes.

## Latest closure-review artifacts

All four reports exist and end with exact `DONE`:

| Reviewer | Verdict | Artifact SHA-256 |
|---|---|---|
| AGY1 | `FIX8B_CLOSURE_PASS` | `bc818a581e09dd7305284de423a158b170c85b6687f84034b7c7eec7d82da101` |
| Codex Sol | `FIX8B_CLOSURE_FAIL` | `0080d3ef13f0bba81186a0f77d80fb58ce64687746ebe0211bb82cb9cf8d003f` |
| Codex Terra | `FIX8B_CLOSURE_FAIL` | `7a76ecd28f56fa060236cfcaea88d7c1ea300aa015af8c8904e20adb56ce6474` |
| AGY2 | `FIX8B_CLOSURE_PASS` | `4e1bd6bfdaae6ca108e2644b5c1e94f03ad5a69e93051849c52b92cc200a9dc5` |

Paths:

- `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-agy1.md`
- `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-codex.md`
- `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-terra.md`
- `/tmp/jerico-global-pty-phase-0-fix8b-closure-review-agy2.md`

## Open blocker — primary evidence

Checked-in production wiring is correct. The defect is in release evidence: `runConfigScopeContract` scans raw text with greedy regular expressions and does not prove that the canonical call is the sole reachable final call controlling success.

Reproduced false-greens:

1. Codex Sol placed a canonical call in an unused closure, then made the actual final call `acceptResult(..., true)`. The focused 19-test suite and web typecheck remained green.
2. Terra placed a canonical call behind `if (false)`, followed by the actual `acceptResult(..., true)`. The focused 19-test suite remained green.
3. Codex Sol also reproduced a comment-only canonical decoy.
4. AGY1 independently found a helper expression suffix evasion (`... && ... || true`) that remained green, but classified it as deferred. Under the explicit closure boundary, this is release-gate false-green evidence and must be clashed, not silently accepted.

This does not show current product behavior is wrong. It shows the gate can approve a future broken caller. The strongest bounded remedy proposed by Sol/Terra is structural validation: inspect executable call expressions, require exactly one production `acceptResult` call, require its third argument to be the zero-argument `activeScopeMatches()` call, verify that helper's direct expression is exactly the two current-vs-captured comparisons, and bind the same call to the ACK/result/success path. At minimum, comment, dead-closure, `if(false)` decoy and `|| true` helper mutations must all turn red.

## Dispatch incident to avoid

During the closure review, four `dev send` calls were run concurrently. Due to transport/session behavior, the AGY2 wrapper path was delivered to three other panes. No workers were killed. Correct individual wrappers were sent and acknowledged, and each final artifact used the correct path.

Binding operational correction: dispatch workers sequentially. After each `dev send`, wait and `dev peek` before the next dispatch.

## Exact next steps

1. Read and verify the four latest reports from primary evidence.
2. Dispatch the prepared Fix8-B closure clash brief and four wrappers sequentially to all four reviewers.
3. Hash and validate all four clash reports; send `/clear` after each completed task.
4. Write a clash resolution. The expected evidence-based outcome is likely one bounded repair, but do not predeclare it.
5. If repair is confirmed, assign exactly one developer:
   - Spark/high if the resolution remains a bounded test-only structural validator/mutation task;
   - Sol/high if it requires cross-layer production refactoring or nontrivial compiler/control-flow work.
6. Reconcile manifest and canonical evidence after the repair.
7. Run one tightly scoped four-worker closure rereview. Clash only genuine disagreement; do not reopen settled architecture.
8. When closure passes, delegate immutable revision/final Gate 0 evidence to Sol/high, run the Gate 0 finalizer, and mark `PASS` only if every mandatory item is proven.
9. Start Phase 1 only after Gate 0 is `PASS`.

## Hard scope boundary

Another repair is allowed only for a reproduced/direct-source Phase 0 authority, integrity, lost-work, duplicate-effect, cross-tab blast-radius, unbounded-memory or release-gate false-green defect. Defer cosmetic issues, general regex aesthetics, retention/TTL/compaction, crash durability and all Phase 1+ primitives unless they directly cause a current verified Phase 0 failure.

