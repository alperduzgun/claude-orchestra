# Model Selection Rule — Claude and Codex

**CRITICAL:** Use the right model for the right task. Don't default to the most capable — default to the most appropriate.

## Quick Decision

```
Multi-step reasoning, architecture decisions, multi-file synthesis?
  → Claude: Opus
  → Codex: GPT-5.5

Implementation, code review, real engineering work?
  → Claude: Sonnet
  → Codex: gpt-5.4

Boilerplate, format, extract, watch, summarize?
  → Claude: Haiku
  → Codex: gpt-5.4-mini
```

If unsure between two: pick the cheaper one. If output is bad, escalate.

---

## Crosswalk

Use the same task routing logic across AI families:

| Task shape | Claude family | Codex family |
|------------|---------------|--------------|
| Strategic reasoning, orchestration, architecture | Opus | GPT-5.5 |
| Engineering implementation and review | Sonnet | gpt-5.4 |
| Cheap structured work, watch loops, formatting | Haiku | gpt-5.4-mini |

The names differ. The operating principle does not.

---

## Opus — Strategic Layer

**Use for:**
- **Orchestration:** managing multiple workers, dispatch + clash protocols, sentinel coordination (deciding what to watch, when to escalate — not the polling loop itself)
- **Architecture decisions:** system design, large refactor planning, tradeoff analysis
- **Spec writing:** requirements clarification, edge case discovery
- **Multi-file code review:** PR review, regression analysis across components
- **Complex debugging:** race conditions, distributed systems, production crashes
- **Cross-project synthesis:** "what's the state of all my projects"

**Don't use for:**
- Single-file edits, basic CRUD
- Documentation updates
- Format/lint/style work
- Anything Sonnet can do in < 30s

---

## Sonnet — Engineering Default

**Use for (most engineering tasks):**
- Feature implementation (new code, new tests)
- Bug fix where root cause is known
- Single-feature code review
- Test writing (unit, integration, E2E)
- API/library migration
- Documentation: README, API docs, technical writing
- Refactoring within a module
- Worker sessions in dual/orchestra patterns

**This is the default. When in doubt, pick Sonnet.**

**Don't use for:**
- Pure boilerplate (commit messages, PR descriptions, status snapshots) → Haiku
- Multi-system orchestration → Opus
- Trivial format conversion → Haiku

---

## Haiku — Cheap, Fast, High-Frequency

**Use for everything boring + structured:**

### Watch & Probe
- Sentinel file monitoring — the polling loop itself (poll for marker, detect stuck workers, emit status events)
- Health checks (server up?, daemon alive?, port listening?)
- Branch/commit metadata gathering
- Test output parsing ("23/25 PASS, 2 FAIL: name + reason")
- Log scanning for patterns

### Format & Extract
- Conventional commit message from `git diff`
- PR description from `git log main..HEAD`
- Status snapshot from multiple sources → structured JSON
- Selector catalog generation (grep + categorize)
- TODO/FIXME extraction
- Translation (TR ↔ EN for canonical archive)

### Boilerplate
- Report template filling (commit hash + filenames + test count)
- File listing with one-liner descriptions
- Code skeleton from spec
- Type stub generation

### Quick Lookup
- "What does this function do?" (single function context)
- "Is this syntax correct?"
- "Find all files matching pattern X"

**Don't use for:**
- Multi-step reasoning
- Anything requiring judgment about tradeoffs
- Code review beyond style/lint

### Research Tasks — Haiku vs Sonnet Boundary

Research tasks are misleading: most look like "lookup" but contain hidden reasoning. Clear distinction:

**Haiku research (single-step, no inference):**
- Grep + count: "How many files use useEffect?"
- Pattern extraction: "List all data-testids"
- Metadata: "Branches with age, last commit, ahead/behind counts"
- Single-file lookup: "What does this function do?" (single function)
- Concrete-rule inference: "Is spinner visible? Is context % > 80?" (regex/threshold)
- Test output parsing: "23/25 PASS, 2 FAIL: ..." (structured output)
- Pure prose translation (jargon-light)

**Sonnet research (multi-step, inference required):**
- Multi-file trace: "Which DB table does endpoint X write to?" (route → service → repo → DB)
- Cross-source pattern: "Find common pattern across 3 files"
- Comparison + judgment: "Find contradictions across config files"
- Semantic state inference: "Is the worker still actively thinking?"
- Analytical writing: report analysis/verdict sections (not template filling)
- Technical translation (with code + jargon)
- Root cause investigation
- "Which approach is better?" type questions

### Step Count Heuristic

```
1 step  (extract / grep / lookup / format)     → Haiku
≥2 steps (compare / trace / synthesize)         → Sonnet
Multi-source + tradeoff + decision              → Opus
```

**Don't think in terms of a "border zone" — there's a clear line.** If the task requires "read X, look at Y, compare with Z, then decide Q": minimum 2 steps → Sonnet.

### Common False Positive — Reports

Task: writing a PHASE-X-REVIEW report.

**Misconception:** "Reports = boilerplate = 80% Haiku"

**Actual breakdown:**
- Template scaffold (titles, headers, table structure) — ~20% → Haiku ✅
- Commit hashes, file lists, test counts, numeric output — ~30% → Haiku ✅
- **Analysis content (root cause, reasoning, hypothesis) — ~50% → Sonnet** ❌ Haiku cannot do this

So roughly half of any report is Sonnet territory, only scaffold + listings are Haiku. **The "Reports → Haiku" oversimplification is wrong.**

---

## Anti-Patterns (Save Money + Quality)

| Anti-pattern | Fix |
|--------------|-----|
| Opus for single typo fix | Use Haiku |
| Sonnet writing PR descriptions | Use Haiku |
| Opus reviewing format/lint | Use Haiku |
| Haiku doing multi-file refactor | Use Sonnet |
| Sonnet orchestrating 3+ workers | Use Opus |
| Opus generating commit messages | Use Haiku |

---

## Hybrid Pattern (Best Practice)

Layer models in workflow:

```
Opus    ── strategy + clash synthesis
   ↓ task brief
Sonnet  ── implement + review
   ↓ raw output
Haiku   ── extract + format + commit msg + status snapshot
   ↓ structured to Opus
```

### Concrete Pipeline Example

1. **Opus orchestrator** plans the task, dispatches worker
2. **Sonnet worker** implements the feature
3. **Haiku** generates commit message from diff
4. **Sonnet** reviews PR
5. **Haiku** writes PR description
6. **Haiku** monitors CI, emits status events
7. **Opus** decides next step based on Haiku's status report

Cost: ~5x cheaper than all-Opus, ~95% quality maintained.

---

## Codex Mapping

Codex does not use the Opus / Sonnet / Haiku product names, but the same separation still applies.

### GPT-5.5 — Strategic Layer

**Use for:**
- orchestration across multiple workers or projects
- architecture and tradeoff decisions
- complex debugging with competing hypotheses
- multi-source review and synthesis
- spec design and acceptance criteria work

**Don't use for:**
- routine file edits
- simple bug fixes with known root cause
- status formatting or log parsing
- repetitive watch loops

### gpt-5.4 — Engineering Default

**Use for:**
- feature implementation
- code review with behavioral judgment
- writing and fixing tests
- medium-complexity debugging
- refactors inside a bounded area
- documentation with technical substance

**This is the default Codex worker model.**

### gpt-5.4-mini — Cheap, Fast, High-Frequency

**Use for:**
- status checks
- test output summaries
- commit message drafts
- PR description drafts
- simple extraction tasks
- grep-followed-by-format tasks
- watch / probe / monitor loops

**Don't use for:**
- architecture decisions
- code review requiring judgment
- multi-file implementation

### Codex Reasoning Effort

Within the Codex family, adjust reasoning effort before changing models:

| Situation | Model | Reasoning |
|-----------|-------|-----------|
| Quick lookup, extraction, watch | gpt-5.4-mini | low / medium |
| Normal engineering task | gpt-5.4 | medium |
| Hard bug or tricky refactor in one system | gpt-5.4 or GPT-5.5 | high |
| Cross-system design or orchestration | GPT-5.5 | high / xhigh |

Rule of thumb:
- Raise reasoning before raising model when the task is still in the same tier.
- Raise model when the task changes tier.

Examples:
- `gpt-5.4` with `high` for a difficult implementation bug
- `GPT-5.5` with `medium` or `high` for architecture planning
- `gpt-5.4-mini` with `low` for continuous status polling

---

## Worker Session Defaults (Orchestra/Multi-Agent Pattern)

When using `dev start <alias>` or similar multi-worker setups:

- **Orchestrator session (current Claude Code instance):** Opus
- **Worker sessions (second Claude Code instance):** Sonnet
- **Background watchers, status aggregators:** Haiku
- **Codex equivalent:** orchestrator = GPT-5.5, worker = gpt-5.4, watcher = gpt-5.4-mini
- **Note:** Kimi and Qwen run at their own model tier and do not map directly to these names

Override only when:
- Worker doing complex debug → temporarily Opus
- Worker doing pure boilerplate → temporarily Haiku

For Codex:
- Worker doing complex debug → temporarily GPT-5.5 or gpt-5.4 with `high`
- Worker doing pure boilerplate → temporarily gpt-5.4-mini

---

## Cost Awareness

Approximate relative cost per equivalent output:

| Model | Cost | Speed |
|-------|------|-------|
| Opus | 5x | 1x |
| Sonnet | 1x | ~3x faster than Opus |
| Haiku | 0.2x | ~10x faster than Opus |

Boilerplate that runs 100x/day on Opus = real money. Same task on Haiku = imperceptible cost.

---

## Decision Heuristic

Before any non-trivial task, ask:

1. **Does this require synthesis across multiple sources/files?**
   Claude → Opus
   Codex → GPT-5.5
2. **Does this require writing real code or making engineering judgment?**
   Claude → Sonnet
   Codex → gpt-5.4
3. **Is this format/extract/watch/summarize?**
   Claude → Haiku
   Codex → gpt-5.4-mini

If still unsure:
- Claude path: start with Sonnet, escalate to Opus only if quality is insufficient
- Codex path: start with gpt-5.4, escalate to GPT-5.5 only if quality is insufficient

---

## Triggers for Auto-Downshift

Move from Sonnet → Haiku when task is one of:
- "Generate commit message"
- "Write PR description"
- "Summarize test output"
- "Extract data-testids from these files"
- "Convert this output to JSON"
- "Watch this file until X"
- "Translate this to English"
- "List unmerged branches"
- "What's the status of X"

Move from Opus → Sonnet when task is one of:
- Single-feature implementation (after planning)
- Single-file review
- Bug fix with known root cause
- Routine refactor

---

## Application

This rule applies globally. Whenever spawning sub-agents, choosing models for tools, or recommending model usage, follow these guidelines. When in doubt, prefer the cheaper option and escalate only if needed.
